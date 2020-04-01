//
//  DashboardAPIHandler.swift
//  ZCRMiOS
//
//  Created by Kalyani shiva on 12/07/18.
//
import Foundation
class DashboardAPIHandler: CommonAPIHandler
{
    fileprivate let cache : CacheFlavour
    
    init( cacheFlavour : CacheFlavour )
    {
        self.cache = cacheFlavour
    }
    
    override func setModuleName() {
        self.requestedModule = "Analytics"
    }
    
    // used by dashboard and component Refresh
    fileprivate let refreshSuccess = "success"
    
    // Return Types used by dashBoard and dashboardComponent Refresh Methods
    public typealias DashboardResult = Result.DataResponse<ZCRMDashboard,APIResponse>
    public typealias ComponentResult = Result.DataResponse<ZCRMDashboardComponent,APIResponse>
    
    // Result Type Completion Handlers
    public typealias Dashboard = ZCRMSDKUtil.ZCRMAnalytics.Dashboard
    public typealias ArrayOfDashboards = ZCRMSDKUtil.ZCRMAnalytics.ArrayOfDashboards
    public typealias DashBoardComponent = ZCRMSDKUtil.ZCRMAnalytics.DashboardComponent
    public typealias RefreshResponse = ZCRMSDKUtil.ZCRMAnalytics.RefreshResponse
    public typealias ArrayOfColorThemes = ZCRMSDKUtil.ZCRMAnalytics.ArrayOfColorThemes
    
    // API Names
    fileprivate typealias DashBoardAPINames = ZCRMDashboard.ResponseJSONKeys
    fileprivate typealias MetaComponentAPINames = ZCRMDashboardComponentMeta.ResponseJSONKeys
    fileprivate typealias ComponentAPINames = ZCRMDashboardComponent.ResponseJSONKeys
    fileprivate typealias ColorPaletteAPINames = ZCRMAnalyticsColorThemes.ResponseJSONKeys
    fileprivate typealias DrilldownDataAPINames = ZCRMAnalyticsData.ResponseJSONKeys
    
    // Model Objects
    fileprivate typealias CompCategory = ZCRMDashboardComponent.ComponentCategory
    fileprivate typealias CompObjective  = ZCRMDashboardComponent.Objective
    fileprivate typealias CompSegmentRanges = ZCRMDashboardComponent.SegmentRanges
    fileprivate typealias ComponentMarkers = ZCRMDashboardComponent.ComponentMarkers
    fileprivate typealias AggregateColumn = ZCRMDashboardComponent.AggregateColumnInfo
    fileprivate typealias GroupingColumn = ZCRMDashboardComponent.GroupingColumnInfo
    fileprivate typealias VerticalGrouping = ZCRMDashboardComponent.VerticalGrouping
    fileprivate typealias GroupingConfigData = ZCRMDashboardComponent.GroupingConfigData
    fileprivate typealias ComponentChunks = ZCRMDashboardComponent.ComponentChunks
    fileprivate typealias Aggregate = ZCRMDashboardComponent.Aggregate
    
    // used for dict keys
    fileprivate typealias ColorPaletteKeys = ZCRMAnalyticsColorThemes.ColorPalette
    // used for parsing out ColorPaletteName
    fileprivate typealias ColorPalette = ZCRMAnalyticsColorThemes.ColorPalette
    //Path Name
    fileprivate typealias URLPathContants = ZCRMDashboard.URLPathConstants
    
    //Meta - Component Parser Return Type
    fileprivate typealias MetaComponentLayoutPropsTuple = (width:Int?,height:Int?,xPosition:Int?,yPosition:Int?)
    //Component Parser Return Type
    fileprivate typealias SegmentRangesTuple = (color:String?,startPos:String?,endPos:String?)
    fileprivate typealias GroupingConfigDetails = (AllowedValues:[GroupingConfigData]?,CustomGroups:[GroupingConfigData]?)
}

/// DICTIONARY KEYS FOR PARSER FUNCTIONS
fileprivate extension DashboardAPIHandler
{
    enum AggregateColumnKeys: String
    {
        case label
        case type
        case name
        case decimalPlaces
        case aggregation
    }
    enum GroupingColumnKeys: String
    {
        case label
        case type
        case name
        case allowedValues
        case customGroups
    }
    enum VerticalGroupingKeys: String
    {
        case label
        case value
        case key
        case aggregate
        case subGrouping
    }
    enum ComponentChunkKeys: String
    {
        case verticalGrouping
        case groupingColumn
        case aggregateColumn
        case name
        case properties
    }
    // Might expand in the future
    enum ComponentChunkPropKeys: String
    {
        case objective
    }
    enum ColorThemeKeys: String
    {
        case name
        case colorPalettes
    }
}

///HANDLER FUNCTIONS
extension DashboardAPIHandler
{
    func searchDashboards( searchWord : String, completion : @escaping ([ZCRMDashboard]?, ZCRMError?) -> () )
    {
        setJSONRootKey(key: JSONRootKey.ANALYTICS)
        let url = "https://\( ZCRMSDKClient.shared.apiBaseURL )/\(CRM)/\(ZCRMSDKClient.shared.apiVersion)/\(URLPathContants.analytics)"
        var dashboards : [ZCRMDashboard] = [ZCRMDashboard]()
        do
        {
            if let responseFromDb = try ZCRMSDKClient.shared.getNonPersistentDB().searchData(withURL: url)
            {
                for value in responseFromDb.values
                {
                    let response = try BulkAPIResponse(responseJSON: value, responseJSONRootKey: JSONRootKey.ANALYTICS, requestAPIName: "Analytics")
                    let dashboardResponse = response.getResponseJSON()
                    if dashboardResponse.isEmpty == false
                    {
                        let arrayOfDashboardJSON = try dashboardResponse.getArrayOfDictionaries( key : JSONRootKey.ANALYTICS )
                        if arrayOfDashboardJSON.isEmpty == true
                        {
                            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.responseNil) : \(ErrorMessage.responseJSONNilMsg), \( APIConstants.DETAILS ) : -")
                            completion( nil, ZCRMError.sdkError( code: ErrorCode.responseNil, message: ErrorMessage.responseJSONNilMsg , details : nil ) )
                            return
                        }
                        for dashboardJSON in arrayOfDashboardJSON
                        {
                            if try dashboardJSON.getString( key : DashBoardAPINames.dashboardName ).contains( searchWord )
                            {
                                let dashboardObj = try self.getZCRMDashboardObjectFrom(dashboardJSON)
                                dashboards.append(dashboardObj)
                            }
                        }
                    }
                }
                dashboards = Array( Set( dashboards ) )
                completion( dashboards, nil )
            }
        }
        catch
        {
            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
            completion( nil, typeCastToZCRMError( error ) )
        }
    }
    
    func getDashboards( fromPage page :Int?, withPerPageOf perPage : Int?, searchWord : String?, dashboardFilter : DashboardFilter?, then onCompletion : @escaping ArrayOfDashboards )
    {
        setIsCacheable( true )
        let URLPath = "\( URLPathContants.analytics )"
        var arrayOfDashboardObj = [ ZCRMDashboard ]()
        setUrlPath( urlPath : URLPath )
        setRequestMethod( requestMethod : .get )
        if let page = page
        {
            addRequestParam( param : RequestParamKeys.page, value : String( page ) )
        }
        if let perPage = perPage
        {
            addRequestParam(param: RequestParamKeys.perPage, value: String( ( perPage > 200 ) ? 200 : perPage ))
        }
        if let searchWord = searchWord
        {
            setIsCacheable( false )
            addRequestParam( param : RequestParamKeys.searchWord, value : searchWord )
        }
        if let dashboardFilter = dashboardFilter
        {
            addRequestParam( param : RequestParamKeys.queryScope, value : dashboardFilter.rawValue )
        }
        setJSONRootKey( key : JSONRootKey.ANALYTICS )
        let request = APIRequest( handler : self, cacheFlavour : self.cache )
        ZCRMLogger.logDebug( message : "Request : \( request.toString() )" )
        request.getBulkAPIResponse { ( resultType ) in
            do
            {
                let bulkAPIResponse = try resultType.resolve()
                let dashBoardResponse =  bulkAPIResponse.getResponseJSON() // [String:[[String:Any]]
                if dashBoardResponse.isEmpty == false
                {
                    let arrayOfDashboardJSON = try dashBoardResponse.getArrayOfDictionaries( key : JSONRootKey.ANALYTICS ) // [[String:Any]]
                    if arrayOfDashboardJSON.isEmpty == true
                    {
                        ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( ErrorCode.responseNil ) : \( ErrorMessage.responseJSONNilMsg ), \( APIConstants.DETAILS ) : -" )
                        onCompletion( .failure( ZCRMError.sdkError( code : ErrorCode.responseNil, message : ErrorMessage.responseJSONNilMsg , details : nil ) ) )
                        return
                    }
                    for dashBoardJSON in arrayOfDashboardJSON
                    {
                        let dashBoardObj = try self.getZCRMDashboardObjectFrom( dashBoardJSON )
                        arrayOfDashboardObj.append( dashBoardObj )
                    }
                }
                onCompletion( .success( arrayOfDashboardObj, bulkAPIResponse ) )
            }
            catch
            {
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                onCompletion( .failure( typeCastToZCRMError( error ) ) )
            }
        } // completion ends
    } // func ends
    
    func getDashboardWithId(id dbID:Int64,then onCompletion: @escaping Dashboard)
    {
        setIsCacheable(true)
        let URLPath = "\(URLPathContants.analytics)/\(dbID)"
        setUrlPath(urlPath: URLPath)
        setRequestMethod(requestMethod: .get)
        setJSONRootKey(key: JSONRootKey.ANALYTICS)
        let request = APIRequest(handler: self, cacheFlavour: self.cache)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        request.getAPIResponse { (resultType) in
            do
            {
                let APIResponse = try resultType.resolve()
                let dashBoardResponse = APIResponse.getResponseJSON() // [String:[[String:Any]]]
                let dashBoardJSON = try dashBoardResponse.getArrayOfDictionaries( key : JSONRootKey.ANALYTICS )[ 0 ]
                let dashboardObj = try self.getZCRMDashboardObjectFrom(dashBoardJSON)
                onCompletion(.success(dashboardObj,APIResponse))
            }
            catch
            {
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                onCompletion(.failure(typeCastToZCRMError(error)))
            }
        } // completion
    } // func ends
    
    func getComponentWith(id cmpID: Int64,fromDashboardID dbID: Int64, name : String?, category : ZCRMDashboardComponent.ComponentCategory? ,period : ComponentPeriod?, then onCompletion: @escaping DashBoardComponent)
    {
        setIsCacheable(true)
        let URLPath = "\(URLPathContants.analytics)/\(dbID)/\(URLPathContants.components)/\(cmpID)"
        setUrlPath(urlPath: URLPath)
        setRequestMethod(requestMethod: .get)
        if let period = period
        {
            addRequestParam( param : RequestParamKeys.period, value : period.rawValue )
        }
        //Setting this has no effect but only to communicate the fact that its Response has
        // no root key
        setJSONRootKey(key: JSONRootKey.NIL)
        let request = APIRequest(handler: self, cacheFlavour: self.cache)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        request.getAPIResponse { (resultType) in
            do
            {
                switch resultType
                {
                case .success(let apiResponse) :
                    let dashBoardComponentJSON = apiResponse.getResponseJSON() // [String:Any]
                    if dashBoardComponentJSON.hasValue( forKey : ComponentAPINames.refreshStatus )
                    {
                        onCompletion( .failure( ZCRMError.processingError( code : ErrorCode.processingError, message : "Unable to fetch component", details : dashBoardComponentJSON ) ) )
                        return
                    }
                    let dashBoardComponentObj = try self.getDashboardComponentFrom(dashBoardComponentJSON, Using: cmpID, And: dbID)
                    dashBoardComponentObj.dashboardId = dbID
                    onCompletion(.success(dashBoardComponentObj,apiResponse))
                case .failure(let error) :
                    if error.ZCRMErrordetails?.code == ErrorCode.invalidData && category == ZCRMDashboardComponent.ComponentCategory.anomalyDetector {
                        guard let name = name, let category = category else {
                            ZCRMLogger.logError(message: "Code : \( ErrorCode.insufficientData ) - Message : \( ErrorMessage.unableToConstructComponent ), Component Name And Category Cannot Be Empty")
                            onCompletion( .failure( ZCRMError.processingError(code: ErrorCode.insufficientData, message: ErrorMessage.unableToConstructComponent, details: nil) ) )
                            return
                        }
                        let component = ZCRMDashboardComponent(cmpId: cmpID, name: name, dbId: dbID)
                        component.period = period
                        component.type = "spline"
                        component.category = category
                        let response = APIResponse()
                        onCompletion( .success(component, response))
                        return
                    }
                    ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                    onCompletion(.failure(typeCastToZCRMError(error)))
                }
            }
            catch
            {
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                onCompletion(.failure(typeCastToZCRMError(error)))
            }
        } // completion
    }  // func ends
    
    func refreshComponentForObject(oldCompObj: ZCRMDashboardComponent, period : ComponentPeriod?, onCompletion: @escaping RefreshResponse)
    {
        setIsCacheable(false)
        let cmpID = oldCompObj.id
        let dbID = oldCompObj.dashboardId
        let URLPath = "\(URLPathContants.analytics)/\(dbID)/\(URLPathContants.components)/\(cmpID)/\(URLPathContants.refresh)"
        setUrlPath(urlPath: URLPath)
        setRequestMethod(requestMethod: .post)
        setJSONRootKey(key: JSONRootKey.DATA)
        let request = APIRequest(handler: self, cacheFlavour: self.cache)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        // API CALL 1: REFRESH COMPONENT
        request.getAPIResponse { (resultType) in
            
            switch resultType
            {
            case .success( let response ) :
                guard response.getStatus() == self.refreshSuccess else {
                    do
                    {
                        try ZCRMSDKClient.shared.getNonPersistentDB().deleteZCRMDashboardComponent(id: "\( oldCompObj.id )")
                    }
                    catch
                    {
                        ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                        onCompletion(.failure( typeCastToZCRMError( error ) ))
                        return
                    }
                    ZCRMLogger.logError( message : "Code : \( ErrorCode.internalError ) - Message : Refresh Failed!, Details : -")
                    onCompletion( .failure( ZCRMError.sdkError(code: ErrorCode.internalError, message: "Refresh Failed!", details : nil) ))
                    return
                }
                self.getComponentWith(id: cmpID, fromDashboardID: dbID, name: nil, category: nil, period: period) { (cmpResult) in
                    switch cmpResult
                    {
                    case .success( let newCompObj, _ ) :
                        do
                        {
                            guard try self.didSetComponentProperties(of: newCompObj, to: oldCompObj)
                                else {
                                    // transferring new db props to old one failed !
                                    let unknownError = ZCRMError.inValidError(code: ErrorCode.responseNil, message: ErrorMessage.responseNilMsg, details : nil)
                                    ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( unknownError )" )
                                    onCompletion(.failure(unknownError))
                                    return
                            }
                        }
                        catch
                        {
                            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                            onCompletion(.failure(typeCastToZCRMError(error)))
                            return
                        }
                        // Component Refresh and Get succeeded ...
                        onCompletion(.success( response ))
                    case .failure( let error ) :
                        ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                        onCompletion(.failure( error ))
                    }
                }
            case .failure( let error ) :
                if error.ZCRMErrordetails?.code != ErrorCode.noInternetConnection && error.ZCRMErrordetails?.code != ErrorCode.networkConnectionLost && error.ZCRMErrordetails?.code != ErrorCode.requestTimeOut
                {
                    do
                    {
                        try ZCRMSDKClient.shared.getNonPersistentDB().deleteZCRMDashboardComponent(id: "\( oldCompObj.id )")
                    }
                    catch
                    {
                        ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                        onCompletion(.failure( typeCastToZCRMError( error ) ))
                        return
                    }
                }
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                onCompletion(.failure( typeCastToZCRMError( error ) ))
            }
        } // Component Refresh completion ends
    } // RefreshComponentForObject  ends
    
    func refreshDashboardForObject(_ oldDashBoardObj:ZCRMDashboard, onCompletion: @escaping RefreshResponse)
    {
        setIsCacheable(false)
        let dbID = oldDashBoardObj.id
        let URLPath = "\(URLPathContants.analytics)/\(dbID)/\(URLPathContants.refresh)"
        setUrlPath(urlPath: URLPath)
        setRequestMethod(requestMethod: .post)
        setJSONRootKey(key: JSONRootKey.DATA)
        let urlRequest = APIRequest(handler: self, cacheFlavour: self.cache)
        ZCRMLogger.logDebug(message: "Request : \(urlRequest.toString())")
        // API CALL 1 : REFRESH DASHBOARD WITH ID
        urlRequest.getAPIResponse { (refreshResult) in
            
            switch refreshResult
            {
            case .success( let response ) :
                guard response.getStatus() == self.refreshSuccess else {
                    do
                    {
                        if let url = urlRequest.request?.url?.deletingLastPathComponent().absoluteString.dropLast()
                        {
                            try ZCRMSDKClient.shared.getNonPersistentDB().deleteData(withURL: String( url ) )
                        }
                    }
                    catch
                    {
                        ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                        onCompletion(.failure( typeCastToZCRMError( error ) ))
                        return
                    }
                    ZCRMLogger.logError( message : "Code : \( ErrorCode.internalError ) - Message : Refresh Failed!, Details : -")
                    onCompletion( .failure( ZCRMError.sdkError(code: ErrorCode.internalError, message: "Refresh Failed!", details : nil) ))
                    return
                }
               self.getDashboardWithId(id: dbID){ (dbResult) in
                
                    switch dbResult
                    {
                    case .success(let newDashboard, _) :
                        do
                        {
                            guard try self.didSetDashBoardProperties(of: newDashboard, to: oldDashBoardObj) else {
                                // transferring new db props to old one failed !
                                let errorMsg = "Refresh Failed! Unable to set dashBoard Properties"
                                let propertySetError = ZCRMError.processingError(code: ErrorCode.responseNil, message: errorMsg, details : nil)
                                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( propertySetError )" )
                                onCompletion(.failure(propertySetError))
                                return
                            }
                            // Refresh and getDashBoard succeeds ...
                            onCompletion(.success( response ))
                            return
                        }
                        catch
                        {
                            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                            onCompletion(.failure(typeCastToZCRMError(error)))
                        }
                    case .failure(let error) :
                        ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                        onCompletion(.failure( error ))
                    }
                }
            case .failure( let error ) :
                if error.ZCRMErrordetails?.code != ErrorCode.noInternetConnection && error.ZCRMErrordetails?.code != ErrorCode.networkConnectionLost && error.ZCRMErrordetails?.code != ErrorCode.requestTimeOut
                {
                    do
                    {
                        guard let url = urlRequest.request?.url?.deletingLastPathComponent().absoluteString.dropLast() else
                        {
                             throw ZCRMError.inValidError(code: ErrorCode.invalidData, message: "Unable To Construct Url For Delete Data During Faulty Response In Dashoard Refresh", details: nil)
                        }
                        try ZCRMSDKClient.shared.getNonPersistentDB().deleteData(withURL: String( url ) )
                    }
                    catch
                    {
                        ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                        onCompletion(.failure( typeCastToZCRMError( error ) ))
                        return
                    }
                }
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                onCompletion(.failure( typeCastToZCRMError( error ) ))
            }
        }
    } // func ends
    
    internal func changeAnomalyPeriod( period : ComponentPeriod, _ oldCompObj : ZCRMDashboardComponent, _ name : String, _ category : ZCRMDashboardComponent.ComponentCategory, completion : @escaping DashBoardComponent)
    {
        guard oldCompObj.category == CompCategory.anomalyDetector else
        {
            completion( .failure( ZCRMError.inValidError(code: ErrorCode.invalidData, message: "Edit component by period is applicable only for AnomalyComponent", details: nil) ) )
            return
        }
        
        self.getComponentWith(id: oldCompObj.id, fromDashboardID: oldCompObj.dashboardId, name: name, category: category, period: period) { result in
            switch result
            {
            case .success(let newCompObj, let response) :
                do
                {
                    guard try self.didSetComponentProperties(of: newCompObj, to: oldCompObj)
                        else {
                            // transferring new db props to old one failed !
                            let unknownError = ZCRMError.inValidError(code: ErrorCode.responseNil, message: ErrorMessage.responseNilMsg, details : nil)
                            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( unknownError )" )
                            completion(.failure(unknownError))
                            return
                    }
                    completion( .success( oldCompObj, response ) )
                }
                catch
                {
                    ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                    completion(.failure(typeCastToZCRMError(error)))
                }
            case .failure(let error) :
                completion( .failure( error ))
            }
        }
    }

    
    func getDashboardComponentColorThemes(onCompletion: @escaping ArrayOfColorThemes)
    {
        setIsCacheable(true)
        let URLPath = "\(URLPathContants.analytics)/\(URLPathContants.colorThemes)"
        setJSONRootKey(key: JSONRootKey.NIL)
        setUrlPath(urlPath: URLPath)
        setRequestMethod(requestMethod: .get)
        let request = APIRequest(handler: self, cacheFlavour: self.cache)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        request.getAPIResponse { (resultType) in
            do
            {
                let APIResponse = try resultType.resolve()
                let colorThemesResponseJSON = APIResponse.getResponseJSON() //[String:Any]
                let colorThemesJSON = try colorThemesResponseJSON.getArrayOfDictionaries( key : ColorPaletteAPINames.colorThemes )
                let ArrayOfcolorThemes = try self.getArrayOfZCRMDashboardComponentColorThemes(colorThemesJSON)
                onCompletion(.success(ArrayOfcolorThemes,APIResponse))
            }
            catch
            {
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                onCompletion(.failure(typeCastToZCRMError(error)))
            }
        } // Completion
    } // func ends
    
    func getDrilldownData( componentId : Int64, dashboardId : Int64, reportId : Int64?, componentChunkId : Int64?, dataParams : ZCRMQuery.GetDrilldownDataParams, completion : @escaping( Result.DataResponse< ZCRMAnalyticsData, APIResponse > ) -> () )
    {
        setIsCacheable(true)
        setJSONRootKey(key: JSONRootKey.NIL)
        setUrlPath(urlPath: "\(URLPathContants.analytics)/\(dashboardId)/\(URLPathContants.components)/\(componentId)/\(URLPathContants.data)")
        setRequestMethod(requestMethod: .get)
        if let criteria = dataParams.criteria
        {
            guard let drilldownQuery = criteria.drilldownQuery else
            {
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( ErrorCode.internalError) : Criteria cannot be constructed, \( APIConstants.DETAILS ) : -" )
                completion( .failure( ZCRMError.processingError( code : ErrorCode.internalError, message : "Criteria cannot be constructed", details : nil ) ) )
                return
            }
            var query : String = "["
            query.append( contentsOf : drilldownQuery )
            query.append( "]" )
            addRequestParam( param : RequestParamKeys.criteria, value : query )
        }
        if let page = dataParams.page
        {
            addRequestParam( param : RequestParamKeys.page, value : String( page ) )
        }
        if let reportId = reportId
        {
            addRequestParam( param : RequestParamKeys.reportId, value : String( reportId ) )
        }
        if let fromHierarchy = dataParams.fromHierarchy
        {
            addRequestParam( param : RequestParamKeys.fromHierarchy, value : String( fromHierarchy ) )
        }
        if let drilldown = dataParams.getDrilldownAsString()
        {
            addRequestParam( param : RequestParamKeys.drilldown, value : drilldown )
        }
        if let sortBy = dataParams.sortBy
        {
            addRequestParam( param : RequestParamKeys.sortColumn, value : sortBy )
        }
        if let sortOrder = dataParams.sortOrder
        {
            if sortOrder == SortOrder.ascending
            {
                addRequestParam( param : RequestParamKeys.orderBy, value : RequestParamKeys.ascending )
            }
            else
            {
                addRequestParam( param : RequestParamKeys.orderBy, value : RequestParamKeys.descending )
            }
        }
        if let fromIndex = dataParams.fromIndex
        {
            addRequestParam( param : RequestParamKeys.fromIndex, value : String( fromIndex ) )
        }
        if let componentChunkId = componentChunkId
        {
            addRequestParam( param : RequestParamKeys.subComponentId, value : String( componentChunkId ) )
        }
        
        let request : APIRequest = APIRequest(handler: self, cacheFlavour: self.cache)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getAPIResponse { ( resultType ) in
            do
            {
                let response = try resultType.resolve()
                let responseJSON : [ String : Any ] = response.getResponseJSON()
                var drilldownData : ZCRMAnalyticsData = ZCRMAnalyticsData( componentId: componentId, dashboardId: dashboardId, criteria: dataParams.criteria)
                drilldownData.reportId = reportId
                drilldownData = try self.getZCRMDrilldownData(drilldownData: drilldownData, drilldownDataJSON: responseJSON)
                response.setData(data: drilldownData)
                completion( .success( drilldownData, response ))
            }
            catch
            {
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func downloadComponentPhoto( period : ComponentPeriod?, dashboardId : Int64, componentId : Int64, completion : @escaping( Result.Response< FileAPIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.NIL )
        setUrlPath( urlPath : "\( URLPathContants.analytics )/\( dashboardId )/\( URLPathContants.components )/\( componentId )/\( URLPathContants.image )" )
        setRequestMethod( requestMethod : .get )
        if let period = period
        {
            addRequestParam( param : RequestParamKeys.period, value : period.rawValue )
        }
        let request : FileAPIRequest = FileAPIRequest( handler : self )
        ZCRMLogger.logDebug( message : "Request : \( request.toString() )" )
        
        request.downloadFile { ( resultType ) in
            do{
                let response = try resultType.resolve()
                completion( .success( response ) )
            }
            catch{
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func downloadComponentPhoto( period : ComponentPeriod?, dashboardId : Int64, componentId : Int64, fileDownloadDelegate : ZCRMFileDownloadDelegate )
    {
        setJSONRootKey( key : JSONRootKey.NIL )
        setUrlPath( urlPath : "\( URLPathContants.analytics )/\( dashboardId )/\( URLPathContants.components )/\( componentId )/\( URLPathContants.image )" )
        setRequestMethod( requestMethod : .get )
        if let period = period
        {
            addRequestParam( param : RequestParamKeys.period, value : period.rawValue )
        }
        let request : FileAPIRequest = FileAPIRequest( handler : self, fileDownloadDelegate : fileDownloadDelegate, "\( componentId )" )
        ZCRMLogger.logDebug( message : "Request : \( request.toString() )" )
        
        request.downloadFile()
    }
} // extension ends

///Refresh Handler Helper functions
fileprivate extension DashboardAPIHandler
{
    /// Dashboard Refresh Helper Functions
    func resolveRefreshResult(_ refreshResult: Result.Response<APIResponse>) -> (refreshResponse: APIResponse?,refreshError: ZCRMError?)
    {
        do
        {
            let apiResponseObj = try refreshResult.resolve()
            // API call 1 -> Refreshes DashBoard Failed
            guard apiResponseObj.getStatus() == self.refreshSuccess else {
                let errorObj = ZCRMError.sdkError(code: ErrorCode.internalError, message: "Refresh Failed!", details : nil)
                return (nil, errorObj)
            }
            return (apiResponseObj,nil)
        }
        catch let refreshError
        {
            // API call 1 -> Refreshes DashBoard Failed
            return (nil,typeCastToZCRMError(refreshError))
        }
    } // func ends
    
    func resolveDashboardGetResult(_ resultType: DashboardResult) -> (ZCRMDashboard?,ZCRMError?)
    {
        do
        {
            let result = try resultType.resolve()
            let dashBoardObj = result.data
            return (dashBoardObj,nil)
        }
        catch let error
        {
            return (nil,typeCastToZCRMError(error))
        }
    } // func ends
    
    func didSetDashBoardProperties(of refreshedDashboard:ZCRMDashboard?, to oldDashBoard: ZCRMDashboard) throws -> Bool
    {
        guard let refreshedDashboard = refreshedDashboard else {
            return false
        }
        oldDashBoard.id = refreshedDashboard.id
        oldDashBoard.name = refreshedDashboard.name
        oldDashBoard.accessType = refreshedDashboard.accessType
        oldDashBoard.isSystemGenerated = refreshedDashboard.isSystemGenerated
        oldDashBoard.isTrends = refreshedDashboard.isTrends
        oldDashBoard.componentMeta = refreshedDashboard.componentMeta
        return true
    }
    
    // Component Refresh Helper functions
    func resolveComponentGetResult(_ resultType: ComponentResult) -> (ZCRMDashboardComponent?, ZCRMError?)
    {
        do
        {
            let result = try resultType.resolve()
            let compObj = result.data
            return (compObj,nil)
        }
        catch let error
        {
            return (nil,typeCastToZCRMError(error))
        }
    } // func ends
    
    func didSetComponentProperties(of refreshedComp: ZCRMDashboardComponent?, to oldComp: ZCRMDashboardComponent) throws -> Bool
    {
        guard let refreshedComp = refreshedComp else {
            return false
        }
        oldComp.name = refreshedComp.name
        oldComp.id = refreshedComp.id
        oldComp.dashboardId = refreshedComp.dashboardId
        oldComp.category = refreshedComp.category
        oldComp.type = refreshedComp.type
        oldComp.objective = refreshedComp.objective
        oldComp.reportId = refreshedComp.reportId
        oldComp.segmentRanges = refreshedComp.segmentRanges
        oldComp.colorPaletteName = refreshedComp.colorPaletteName
        oldComp.colorPaletteStartingIndex = refreshedComp.colorPaletteStartingIndex
        oldComp.markers = refreshedComp.markers
        oldComp.maxRows = refreshedComp.maxRows
        oldComp.lastFetchedTimeLabel = refreshedComp.lastFetchedTimeLabel
        oldComp.lastFetchedTimeValue = refreshedComp.lastFetchedTimeValue
        oldComp.componentChunks = refreshedComp.componentChunks
        oldComp.period = refreshedComp.period
        return true
    } // func ends
} // end of extension

///HANDLER PARSING FUNCTIONS
fileprivate extension DashboardAPIHandler {
    ///*** DASHBOARD PARSERS ***
    func getZCRMDashboardObjectFrom(_ dashBoardJSON: [String:Any] ) throws -> ZCRMDashboard
    {
        let dashBoardObj = ZCRMDashboard( id : try dashBoardJSON.getInt64( key : DashBoardAPINames.dashboardID ), name : try dashBoardJSON.getString( key : DashBoardAPINames.dashboardName ) )
        if let isSalesTrend = dashBoardJSON.optBoolean(key: DashBoardAPINames.isSalesTrends)
        {
            dashBoardObj.isTrends = isSalesTrend
        }
        if let isSystemGenerated = dashBoardJSON.optBoolean(key: DashBoardAPINames.isSystemGenerated)
        {
            dashBoardObj.isSystemGenerated = isSystemGenerated
        }
        if let accessType = dashBoardJSON.optString(key: DashBoardAPINames.accessType) {
            dashBoardObj.accessType = accessType
        }
        if dashBoardJSON.hasValue(forKey: DashBoardAPINames.metaComponents)
        {
            let arrayOfMetaComponent = try getArrayOfZCRMDashboardComponentMeta(dashBoardObj.id,From: dashBoardJSON)
            dashBoardObj.componentMeta = arrayOfMetaComponent
        }
        if let isFavourite = dashBoardJSON.optBoolean( key : DashBoardAPINames.favorited )
        {
            dashBoardObj.isFavourite = isFavourite
        }
        return dashBoardObj
    }
} // end of extension

fileprivate extension DashboardAPIHandler
{
    ///*** DASHBOARD META-COMPONENT PARSERS  ***
    func getArrayOfZCRMDashboardComponentMeta(_ dashboardId : Int64, From dashBoardJSON:[String:Any]) throws -> [ZCRMDashboardComponentMeta]
    {
        let metaComponentAPIName = ZCRMDashboard.ResponseJSONKeys.metaComponents
        let arrayOfMetaComponentJSON = try dashBoardJSON.getArrayOfDictionaries( key : metaComponentAPIName )
        var metaComponentObjArray = [ZCRMDashboardComponentMeta]()
        for dashBoardMetaComponentJSON in arrayOfMetaComponentJSON {
            let metaComponentObj = try getDashboardMetaComponentFrom(dashboardId, dashBoardMetaComponentJSON)
            metaComponentObjArray.append(metaComponentObj)
        }
        return metaComponentObjArray
    }
    
    func getDashboardMetaComponentFrom(_ dashboardId : Int64, _ metaComponentJSON:[String:Any]) throws -> ZCRMDashboardComponentMeta
    {
        guard let componentProperties = metaComponentJSON[ ComponentAPINames.componentProps ] as? [String: Any],
            let visualisationProperties = componentProperties[ ComponentAPINames.visualizationProps ] as? [String: Any],
            let componentType = visualisationProperties[ ComponentAPINames.type ] as? String else {
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.valueNil) : Unable to construct component meta!")
                throw ZCRMError.inValidError(code: ErrorCode.valueNil, message: "\( ComponentAPINames.componentType ) cannot be nil", details: nil)
        }

        let metaComponentObj = try ZCRMDashboardComponentMeta( id : metaComponentJSON.getInt64( key : MetaComponentAPINames.componentID ), name : metaComponentJSON.getString( key : MetaComponentAPINames.componentName ), type: componentType, dashboardId: dashboardId )
        
        if let isFavorite = metaComponentJSON.optBoolean(key: MetaComponentAPINames.favouriteComponent)
        {
            metaComponentObj.isFavourite = isFavorite
        }
        metaComponentObj.category = try CompCategory( componentCategory : metaComponentJSON.getString( key : MetaComponentAPINames.componentType ) )
        if let isEditable = metaComponentJSON.optBoolean( key : MetaComponentAPINames.editable )
        {
            metaComponentObj.isEditable = isEditable
        }
        metaComponentObj.isSystemGenerated = try metaComponentJSON.getBoolean(key: MetaComponentAPINames.systemGenerated)
        let itemPropsJSON = try metaComponentJSON.getDictionary(key: MetaComponentAPINames.itemProps)
        if let layoutJSON = itemPropsJSON.optDictionary(key: MetaComponentAPINames.layout)
        {
            var metaComponentLayoutObj = metaComponentObj.layoutProperties
            metaComponentLayoutObj.x = Int(layoutJSON.optString(key: MetaComponentAPINames.componentXPosition) ?? "default")
            metaComponentLayoutObj.y = Int(layoutJSON.optString(key: MetaComponentAPINames.componentYPosition) ?? "default")
            metaComponentLayoutObj.width = Int(layoutJSON.optString(key: MetaComponentAPINames.componentWidth) ?? "default")
            metaComponentLayoutObj.height = Int(layoutJSON.optString(key: MetaComponentAPINames.componentHeight) ?? "default")
            metaComponentObj.layoutProperties = metaComponentLayoutObj
        }
        return metaComponentObj
    }
} // Extension ends

extension DashboardAPIHandler
{
    /**
       To construct component object from component JSON (Zia Chat)
    
       - Parameters:
           - componentJSON : JSON from which the Dashboard Component object has to be constructed
           - cmpId : Component Id whose object has to be constructed
           - dbId : Dashboarcd Id in which the component is available
    
       - Returns: A ZCRMDashboarcComponent whose object has been constructed from the given json.
    */

    internal func getDashboardComponentFrom(_ componentJSON: [String:Any], Using cmpId: Int64, And dbId: Int64) throws -> ZCRMDashboardComponent
    {
        let componentObj = try ZCRMDashboardComponent( cmpId : cmpId, name : componentJSON.getString( key : ComponentAPINames.componentName ), dbId : dbId )
        componentObj.category = CompCategory( componentCategory : try componentJSON.getString( key : ComponentAPINames.componentCategory ) )
        componentObj.reportId = componentJSON.optInt64(key: ComponentAPINames.reportID)
        if componentJSON.hasValue(forKey: ComponentAPINames.componentMarker)
        {
            if let arrayOfComponentMarkersObj = try getComponentMarkersFrom(componentJSON)
            {
                componentObj.markers = arrayOfComponentMarkersObj
            }
        }
        let ArrayOfComponentChunksJSON = componentJSON.optArrayOfDictionaries(key: ComponentAPINames.componentChunks)
        try setComponentChunksValues(To: componentObj, Using: ArrayOfComponentChunksJSON)
        if let lastFetchedTimeJSON = componentJSON.optDictionary(key: ComponentAPINames.lastFetchedTime)
        {
            componentObj.lastFetchedTimeLabel = lastFetchedTimeJSON.optString(key: ComponentAPINames.label)
            componentObj.lastFetchedTimeValue = lastFetchedTimeJSON.optString(key: ComponentAPINames.value)
        }
        try setComponentPropertiesFor(componentObj, Using: componentJSON)
        return componentObj
    } // func ends
}

fileprivate extension DashboardAPIHandler
{
    func getComponentMarkersFrom(_ componentJSON:[String:Any]) throws -> [ComponentMarkers]?
    {
        let Key = ComponentAPINames.componentMarker
        let ArrayOfCompMarkerJSON = try componentJSON.getArrayOfDictionaries( key : Key )
        var ArrayOfComponentMarkerObj = [ComponentMarkers]()
        var x:String? // can be User ID (Int64) or pickListValue (String)
        for compMarkersJSON  in ArrayOfCompMarkerJSON
        {
            x = compMarkersJSON.optString(key: ComponentAPINames.componentMarkerXPosition)
            let y = try compMarkersJSON.getDictionary( key : ComponentAPINames.componentMarkerYPosition )
            let yLabel = try y.getString( key : ComponentAPINames.label )
            let yValue = try y.getInt( key : ComponentAPINames.value )
            ArrayOfComponentMarkerObj.append( ComponentMarkers( xValue : x, yValue : ComponentMarkers.AxisData( label : yLabel, value : yValue ) ) )
        } // loop ends
        return ArrayOfComponentMarkerObj
    }
    
    func setComponentPropertiesFor(_ componentObject:ZCRMDashboardComponent, Using componentJSON: [String:Any]) throws
    {
        let Key = ComponentAPINames.componentProps
        let componentPropsJSON = try componentJSON.getDictionary( key : Key )
        if let objectiveString = componentPropsJSON.optString(key: ComponentAPINames.objective) {
            let objectiveEnum = CompObjective(rawValue: objectiveString)
            componentObject.objective = objectiveEnum
        }
        if let maximumRows = componentPropsJSON.optInt(key: ComponentAPINames.maximumRows) {
            componentObject.maxRows = maximumRows
        }
        try setVisualizationPropertiesFor(componentObject: componentObject,
                                          Using: componentPropsJSON)
    } // func ends
    
    //COMPONENT VISUALIZATION PROPERTIES
    func setVisualizationPropertiesFor(componentObject:ZCRMDashboardComponent, Using componentPropsJSON: [String:Any]) throws
    {
        let Key = ComponentAPINames.visualizationProps
        let visualizationPropsJSON = try componentPropsJSON.getDictionary( key : Key )
        let componentType = try visualizationPropsJSON.getString( key : ComponentAPINames.componentType )
        componentObject.type = componentType
        if let ArrayOfSegmentRangeObj = try getArrayOfSegmentRangesFrom(visualizationPropsJSON)
        {
            componentObject.segmentRanges = ArrayOfSegmentRangeObj
        }
        if let colorPaletteTuple = try getColorPaletteFrom(visualizationPropsJSON){
            componentObject.colorPaletteName = colorPaletteTuple.name
            componentObject.colorPaletteStartingIndex = colorPaletteTuple.index
        }
    } // func ends
    
    func getArrayOfSegmentRangesFrom(_ visualizationPropsJSON: [String:Any]) throws -> [CompSegmentRanges]?
    {
        let Key = ComponentAPINames.segmentRanges
        guard visualizationPropsJSON.hasKey(forKey: Key) else {
            return nil
        }
        let ArrayOfSegmentRangesJSON = try visualizationPropsJSON.getArrayOfDictionaries( key : Key )
        var ArrayOfSegmentRangeObj = [CompSegmentRanges]()
        var SegmentStartPos:String?
        var SegmentEndPos:String?
        var SegmentColor:String?
        for segmentRangesJSON in ArrayOfSegmentRangesJSON
        {
            SegmentStartPos = segmentRangesJSON.optString(key: ComponentAPINames.segmentStarts)
            SegmentEndPos = segmentRangesJSON.optString(key: ComponentAPINames.segmentEnds)
            SegmentColor = segmentRangesJSON.optString(key: ComponentAPINames.segmentColor)
            let Tuple = (SegmentColor,SegmentStartPos,SegmentEndPos)
            if let segmentRangesObj = try constructSegmentRangesObjectFrom(Tuple)
            {
                ArrayOfSegmentRangeObj.append(segmentRangesObj)
            }
        } // Loop ends
        return ArrayOfSegmentRangeObj
    } // function ends
    
    func constructSegmentRangesObjectFrom(_ Tuple:SegmentRangesTuple) throws -> CompSegmentRanges?
    {
        guard var startPosPercent = Tuple.startPos, var endPosPercent = Tuple.endPos else {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.valueNil) : Unable to construct segment ranges object from tuple, \( APIConstants.DETAILS ) : -")
            throw ZCRMError.inValidError( code : ErrorCode.valueNil, message : "Unable to construct segment ranges object from tuple", details : nil)
        }
        // Removing % and converting to number
        startPosPercent.removeLast()
        endPosPercent.removeLast()
        let startPosInt =  Int(startPosPercent)
        let endPosInt = Int(endPosPercent)
        guard let color = Tuple.color,
            let startPos = startPosInt,
            let endPos = endPosInt else {
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.valueNil) : Unable to construct segment ranges object from tuple, \( APIConstants.DETAILS ) : -")
                throw ZCRMError.inValidError( code : ErrorCode.valueNil, message : "Unable to construct segment ranges object from tuple", details : nil )
        }
        return CompSegmentRanges(color: color, startPosition: startPos, endPosition: endPos)
    } // func ends
    
    func getColorPaletteFrom(_ visualizationPropsJSON: [String:Any]) throws -> (name:ColorPalette,index:Int)?
    {
        let Key = ComponentAPINames.colorPalette
        guard visualizationPropsJSON.hasKey(forKey: Key) else {
            return nil
        }
        let colorPaletteJSON = try visualizationPropsJSON.getDictionary( key : Key )
        guard let name = ColorPalette(rawValue: try colorPaletteJSON.getString(key: ComponentAPINames.colorPaletteName)) else {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.valueNil) : \( ComponentAPINames.colorPalette ) must not be nil, \( APIConstants.DETAILS ) : -")
            throw ZCRMError.inValidError( code : ErrorCode.valueNil, message : "\( ComponentAPINames.colorPalette ) must not be nil", details : nil )
        }
        return ( name,try colorPaletteJSON.getInt( key : ComponentAPINames.colorPaletteStartingIndex ) )
    } // func ends
    
    //COMPONENT CHUNKS
    func setComponentChunksValues(To componentObj:ZCRMDashboardComponent, Using chunks: [[String:Any]]?) throws
    {
        guard let ArrayOfComponentChunksJSON = chunks else {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.valueNil) : Failed to get component chunks [String:Any], \( APIConstants.DETAILS ) : -")
            throw ZCRMError.inValidError( code : ErrorCode.valueNil, message : "Failed to get component chunks [String:Any]", details : nil)
        }
        for componentChunksJSON in ArrayOfComponentChunksJSON
        {
            var componentChunksObj = ComponentChunks( component: componentObj )
            componentChunksObj.id = componentChunksJSON.optInt64(key: ComponentAPINames.id)
            if componentChunksJSON.hasValue(forKey: ComponentAPINames.dataMap)
            {
                if try componentChunksJSON.getDictionary( key : ComponentAPINames.dataMap ).hasValue( forKey : "T" )
                {
                    let aggregates = try getArrayOfVerticalGroupingTotalAggregate(componentChunksJSON: componentChunksJSON)
                    for aggregate in aggregates
                    {
                        componentChunksObj.addVerticalGroupingTotalAggregate(aggregate)
                    }
                }
            }
            if componentChunksJSON.hasValue(forKey: ComponentAPINames.aggregateColumn)
            {
                let aggregateColumn = try getArrayOfAggregateColumnInfo(Using: componentChunksJSON)
                for aggregateObj in aggregateColumn
                {
                    componentChunksObj.addAggregateColumnInfo(aggregateObj)
                }
            }
            if componentChunksJSON.hasValue(forKey: ComponentAPINames.groupingColumn)
            {
                let groupingColumn = try getArrayOfGroupingColumnInfo(Using: componentChunksJSON, componentObj )
                for groupingObj in groupingColumn
                {
                    componentChunksObj.addGroupingColumnInfo(groupingObj)
                }
            }
            if componentChunksJSON.hasValue(forKey: ComponentAPINames.verticalGrouping)
            {
                let verticalGroupingJSON = try componentChunksJSON.getArrayOfDictionaries( key : ComponentAPINames.verticalGrouping )
                if verticalGroupingJSON.isEmpty == false
                {
                    let verticalGrouping = try getArrayOfVerticalGrouping(Using: componentChunksJSON, ArrayOfVerticalGroupingJSON: verticalGroupingJSON)
                    for verticalObj in verticalGrouping
                    {
                        componentChunksObj.addVerticalGrouping(verticalObj)
                    }
                }
            }
            componentChunksObj.name = componentChunksJSON.optString(key: ComponentAPINames.name)
            if componentChunksJSON.hasValue( forKey : ComponentAPINames.componentProps ), let objective = try componentChunksJSON.getDictionary( key : ComponentAPINames.componentProps ).optString( key : ComponentAPINames.objective )
            {
                componentChunksObj.objective = CompObjective(rawValue: objective)
            }
            componentObj.addComponentChunks(chunks: componentChunksObj)
        } // outer loop ends
    } // func ends
    
    func getArrayOfVerticalGroupingTotalAggregate(componentChunksJSON : [ String:Any ]) throws -> [Aggregate]
    {
        let Key = ComponentAPINames.aggregates
        let ArrayOfAggregateJSON = try componentChunksJSON.getDictionary( key : ComponentAPINames.dataMap ).getDictionary( key : "T" ).getArrayOfDictionaries( key : Key )
        var aggregates : [Aggregate] = [Aggregate]()
        for aggr in ArrayOfAggregateJSON
        {
            guard let aggrLabel = try self.optValueAsString(dict: aggr, key: ComponentAPINames.label) else
            {
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.invalidData) : \(ComponentAPINames.label) should be of type Int, Double or String, \( APIConstants.DETAILS ) : -")
                throw ZCRMError.inValidError( code : ErrorCode.invalidData, message : "\(ComponentAPINames.label) should be of type Int, Double or String", details : nil )
            }
            if let aggrValue : Double = self.getDoubleValue(dict: aggr, key: ComponentAPINames.value)
            {
                var aggrObj : Aggregate = Aggregate(label: aggrLabel, value: aggrValue)
                aggrObj.applyTransformation()
                aggregates.append(aggrObj)
            }
            else
            {
                var aggrObj : Aggregate = Aggregate(label: aggrLabel, value: 0)
                aggrObj.applyTransformation()
                aggregates.append(aggrObj)
            }
        }
        return aggregates
    }
    
    //AGGREGATE COLUMN INFO
    func getArrayOfAggregateColumnInfo(Using componentChunksJSON: [String:Any] ) throws -> [AggregateColumn]
    {
        let Key = ComponentAPINames.aggregateColumn
        var ArrayOfAggregateColumnObj = [AggregateColumn]()
        let ArrayOfAggregateColumnJSON = try componentChunksJSON.getArrayOfDictionaries( key : Key )
        // Keys are of Enum Type to avoid typos at set and get sites
        for aggregateColumnJSON in ArrayOfAggregateColumnJSON
        {
            ArrayOfAggregateColumnObj.append(AggregateColumn(label: try aggregateColumnJSON.getString( key : ComponentAPINames.label ),
                                                             type: aggregateColumnJSON.optString(key: ComponentAPINames.type),
                                                             name: aggregateColumnJSON.optString(key: ComponentAPINames.name),
                                                             value: aggregateColumnJSON.optString(key: ComponentAPINames.value),
                                                             decimalPlaces: aggregateColumnJSON.optInt(key: ComponentAPINames.decimalPlaces),
                                                             aggregation: aggregateColumnJSON.optArray(key: ComponentAPINames.aggregations) as? [String]))
        }
        return ArrayOfAggregateColumnObj
    } // func ends
    
    //GROUPING COLUMN INFO
    func getArrayOfGroupingColumnInfo(Using componentChunksJSON: [String:Any], _ componentObj : ZCRMDashboardComponent ) throws -> [GroupingColumn]
    {
        let Key = ComponentAPINames.groupingColumn
        var ArrayOfGroupingColumnObj = [GroupingColumn]()
        var formula : GroupingColumn.Formula?
        let ArrayOfGroupingColumnJSON = try componentChunksJSON.getArrayOfDictionaries( key : Key )
        for groupingColumnJSON in ArrayOfGroupingColumnJSON
        {
            var allowedValues : [GroupingConfigData]?
            var customGroups : [GroupingConfigData]?
            let name = groupingColumnJSON.optString( key : ComponentAPINames.name )
            if let groupingConfig = groupingColumnJSON.optDictionary(key: ComponentAPINames.groupingConfig)
            {
                if let allowedValuesJSON = groupingConfig.optArrayOfDictionaries(key: ComponentAPINames.allowedValues)
                {
                    allowedValues = [GroupingConfigData]()
                    for allowedValueJSON in allowedValuesJSON
                    {
                        let allowedValue : GroupingConfigData = GroupingConfigData(label: allowedValueJSON.optString(key: ComponentAPINames.label), value: try allowedValueJSON.getString( key : ComponentAPINames.value ) )
                        allowedValues?.append(allowedValue)
                    }
                }
                if let customGroupsJSON = groupingConfig.optArrayOfDictionaries(key: ComponentAPINames.customGroups)
                {
                    customGroups = [GroupingConfigData]()
                    for customGroupJSON in customGroupsJSON
                    {
                        let customGroup : GroupingConfigData = GroupingConfigData( label : try customGroupJSON.getString( key : ComponentAPINames.label ), value : try customGroupJSON.getString( key : ComponentAPINames.value ) )
                        customGroups?.append(customGroup)
                    }
                }
                if let formulaJSON = groupingConfig.optDictionary( key : ComponentAPINames.formula )
                {
                    let expression = try formulaJSON.getString( key : ComponentAPINames.expression )
                    let duration = self.getDaycount( formulaExpression : expression )
                    let detailsJSON = try formulaJSON.getDictionary( key : ComponentAPINames.details )
                    if detailsJSON.count > 2
                    {
                        ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( ErrorCode.invalidData ) : \( ComponentAPINames.details ) should contain only 2 values, \( APIConstants.DETAILS ) : -" )
                        throw ZCRMError.inValidError( code : ErrorCode.invalidData, message : "\( ComponentAPINames.label ) should contain only 2 values", details : nil )
                    }
                    var details = [ [String : String ] ]( repeating : [ "" : "" ], count : 2 )
                    for ( key, value ) in detailsJSON
                    {
                        if let detailsVal = value as? [ String : String ]
                        {
                            var detailJSON = [ String : String ]()
                            detailJSON[ ComponentAPINames.label ] = try detailsVal.getString( key : ComponentAPINames.label )
                            if key == name
                            {
                                details[ 0 ] = detailJSON
                            }
                            else
                            {
                                details[ 1 ] = detailJSON
                            }
                        }
                        else
                        {
                            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.invalidData) : \(ComponentAPINames.details) should be of type Dictionary< String, String >, \( APIConstants.DETAILS ) : -")
                            throw ZCRMError.inValidError( code : ErrorCode.invalidData, message : "\(ComponentAPINames.label) should be of type Dictionary< String, String >", details : nil )
                        }
                    }
                    formula = GroupingColumn.Formula( expression : expression, details : details, duration : duration )
                }
            }
            ArrayOfGroupingColumnObj.append(GroupingColumn( label : try groupingColumnJSON.getString( key : ComponentAPINames.label ),
                                                            type : try groupingColumnJSON.getString( key : ComponentAPINames.type ),
                                                           name : name,
                                                           groupingType : groupingColumnJSON.optString( key : ComponentAPINames.groupingType ),
                                                           allowedValues : allowedValues,
                                                           customGroups : customGroups,
                                                           formula : formula ) )
            
            if let frequency = groupingColumnJSON.optString( key : ComponentAPINames.frequency )
            {
                if let period = ComponentPeriod(rawValue: frequency)
                {
                    componentObj.period = period
                }
                else
                {
                    ZCRMLogger.logDebug(message: "New Frequency Encountered In API - \( frequency )")
                }
            }
        }
        return ArrayOfGroupingColumnObj
    } // func ends
    
    func getDaycount( formulaExpression : String ) -> ZCRMDashboardComponent.Duration? {
        guard let dayCountIndexMinus1 = formulaExpression.firstIndex( of : "/" ) else
        {
            ZCRMLogger.logDebug( message : "Cannot find day count index inside formula expression!" )
            return nil
        }
        let dayCountStartIndex = formulaExpression.index( dayCountIndexMinus1, offsetBy : 1 )
        let dayCountEndIndex = formulaExpression.index( before : formulaExpression.endIndex )
        guard let dayCount = Int( String( formulaExpression[ dayCountStartIndex...dayCountEndIndex ] ) ) else
        {
            ZCRMLogger.logDebug( message : "Cannot extract day count from formula!" )
            return nil
        }
        guard let duration = ZCRMDashboardComponent.Duration( rawValue : dayCount ) else {
            ZCRMLogger.logDebug( message : "Unkown day count encountered!" )
            return nil
        }
        return duration
    }
    
    //VERTICAL GROUPING
    func getArrayOfVerticalGrouping(Using componentChunksJSON: [String:Any], ArrayOfVerticalGroupingJSON : [[String:Any]] ) throws -> [VerticalGrouping]
    {
        //This gets used during SubGrouping Recursion
        var ArrayOfVerticalGroupingObj = [VerticalGrouping]()
        var subGrouping = [VerticalGrouping]()
        for verticalGroupingJSON in ArrayOfVerticalGroupingJSON
        {
            var aggregates = [Aggregate]()
            let key = verticalGroupingJSON.optString(key: ComponentAPINames.key)
            guard let label = try self.optValueAsString(dict: verticalGroupingJSON, key: ComponentAPINames.label) else
            {
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.invalidData) : \(ComponentAPINames.label) should be of type Int, Double or String, \( APIConstants.DETAILS ) : -")
                throw ZCRMError.inValidError( code : ErrorCode.invalidData, message : "\(ComponentAPINames.label) should be of type Int, Double or String", details : nil )
            }
            if let aggrKey = key
            {
                if let aggregate = try componentChunksJSON.getDictionary( key : ComponentAPINames.dataMap ).getDictionary( key : aggrKey ).optArrayOfDictionaries( key : ComponentAPINames.aggregates )
                {
                    for aggr in aggregate
                    {
                        guard let aggrLabel = try self.optValueAsString(dict: aggr, key: ComponentAPINames.label) else
                        {
                            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.invalidData) : \(ComponentAPINames.label) should be of type Int, Double or String, \( APIConstants.DETAILS ) : -")
                            throw ZCRMError.inValidError( code : ErrorCode.invalidData, message : "\(ComponentAPINames.label) should be of type Int, Double or String", details : nil )
                        }
                        if let aggrValue : Double = self.getDoubleValue(dict: aggr, key: ComponentAPINames.value)
                        {
                            var aggrObj : Aggregate = Aggregate(label: aggrLabel, value: aggrValue)
                            aggrObj.applyTransformation()
                            aggregates.append(aggrObj)
                        }
                        else
                        {
                            var aggrObj : Aggregate = Aggregate(label: aggrLabel, value: 0)
                            aggrObj.applyTransformation()
                            aggregates.append(aggrObj)
                        }
                    }
                }
            }
            if let subGroupingJSON = verticalGroupingJSON.optArrayOfDictionaries(key: ComponentAPINames.subGrouping)
            {
                if subGroupingJSON.isEmpty == false
                {
                    subGrouping = try self.getArrayOfVerticalGrouping(Using: componentChunksJSON, ArrayOfVerticalGroupingJSON: subGroupingJSON)
                }
            }
            ArrayOfVerticalGroupingObj.append(VerticalGrouping(label: label,
                                                               value: try self.optValueAsString( dict : verticalGroupingJSON, key : ComponentAPINames.value ),
                                                               key: key,
                                                               aggregate: aggregates,
                                                               subGrouping: subGrouping))
        }
        return ArrayOfVerticalGroupingObj.map {
            var verticalGrouping = $0
            verticalGrouping.applyTransformation()
            return verticalGrouping
        }
        
    } // func ends
    
    func optValueAsString(dict: [ String : Any ], key : String) throws -> String? {
        guard let valueForKey = dict[ key ]  else { return nil }
        var unwrappedValue : Any = valueForKey
        switch valueForKey {
        case Optional<Any>.some(let value) :
            unwrappedValue = value
        default :
            unwrappedValue = valueForKey
        }
        return "\( unwrappedValue )" == "<null>" ? nil : "\( unwrappedValue )"
    }
    
    func getDoubleValue(dict : [String : Any], key : String) -> Double? {
        guard let valueForKey = dict[ key ] else { return nil }
        return dict.optDouble(key : key) ?? Double("\( valueForKey )")
    }
}

///DASHBOARD COMPONENT COLOR THEMES PARSER
fileprivate extension DashboardAPIHandler
{
    func getArrayOfZCRMDashboardComponentColorThemes(_ ArrayOfColorThemesJSON:[[String:Any]]) throws -> [ZCRMAnalyticsColorThemes]
    {
        var ArraycolorThemesObj = [ZCRMAnalyticsColorThemes]()
        var colorPalette: [ColorPaletteKeys:[String]]?
        var colorThemesValues = [ColorThemeKeys:Any]() // extendable in the future
        do
        {
            for colorThemesJSON in ArrayOfColorThemesJSON
            {
                for (key,value) in colorThemesJSON
                {
                    switch (key)
                    {
                    case ColorPaletteAPINames.name:
                        colorThemesValues[.name] = value
                    case ColorPaletteAPINames.colorPalettes:
                        colorPalette = try getArrayOfColorPaletteFrom(value as? [String:Any])
                    default:
                        ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.valueNil) : Unknown key \(key) encountered in color themes parsing, \( APIConstants.DETAILS ) : -")
                        throw ZCRMError.inValidError( code : ErrorCode.valueNil, message : "Unknown key \(key) encountered in color themes parsing", details : nil)
                    } // case ends
                } // inner loop ends
                if let colorThemeObj = try constructColorPaletteObjFrom(colorThemesValues,colorPalette)
                {
                    ArraycolorThemesObj.append(colorThemeObj)
                }
            } // outer loop ends
        }
        catch
        {
            throw typeCastToZCRMError(error)
        }
        return ArraycolorThemesObj
    } // func ends
    
    func getArrayOfColorPaletteFrom(_ colorPaletteJSON: [String:Any]?) throws -> [ColorPaletteKeys:[String]]?
    {
        guard let colorPaletteJSON = colorPaletteJSON else {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.valueNil) : Failed to typecast color palette JSON to [String:Any], \( APIConstants.DETAILS ) : -")
            throw ZCRMError.inValidError( code : ErrorCode.valueNil, message : "Failed to typecast color palette JSON to [String:Any]", details : nil)
        }
        var colorPaletteValues = [ColorPaletteKeys:[String]]()
        for (key,value) in colorPaletteJSON
        {
            switch (key)
            {
            case ColorPaletteKeys.standard.rawValue:
                colorPaletteValues[.standard] = value as? [String]
            case ColorPaletteKeys.basic.rawValue:
                colorPaletteValues[.basic] = value as? [String]
            case ColorPaletteKeys.general.rawValue:
                colorPaletteValues[.general] = value as? [String]
            case ColorPaletteKeys.vibrant.rawValue:
                colorPaletteValues[.vibrant] = value as? [String]
            default:
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.valueNil) : Unknown color palette \(key) found!!, \( APIConstants.DETAILS ) : -")
                throw ZCRMError.inValidError( code : ErrorCode.valueNil, message : "Unknown color palette \(key) found!!", details : nil )
            }
        }
        return colorPaletteValues
    } // func ends
    
    func constructColorPaletteObjFrom(_ dict:[ColorThemeKeys:Any],_ colorPalette: [ColorPaletteKeys:[String]]?) throws -> ZCRMAnalyticsColorThemes?
    {
        guard let colorPalette = colorPalette else {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.valueNil) : Unable to construct color palette object, \( APIConstants.DETAILS ) : -")
            throw ZCRMError.inValidError( code : ErrorCode.valueNil, message : "Unable to construct color palette object", details : nil )
        }
        let colorPaletteObj = ZCRMAnalyticsColorThemes()
        colorPaletteObj.colorPalette = colorPalette
        colorPaletteObj.name = try dict.getString( key : .name )
        return colorPaletteObj
    }
} // extension ends

fileprivate extension DashboardAPIHandler
{
    func getZCRMDrilldownData( drilldownData : ZCRMAnalyticsData, drilldownDataJSON : [ String : Any ] ) throws -> ZCRMAnalyticsData
    {
        var drilldown : ZCRMAnalyticsData = drilldownData
        if drilldownData.reportId != nil
        {
            drilldown = try self.setDrilldownWithReports( drilldownData : drilldownData, drilldownDataJSON : drilldownDataJSON)
        }
        else if let componentChuncks = drilldownDataJSON.optArrayOfDictionaries(key: DrilldownDataAPINames.componentChuncks)
        {
            drilldown.componentName = drilldownDataJSON.optString(key: DrilldownDataAPINames.name)
            drilldown = try self.setDrilldownDataWithoutReports(drilldownData: drilldownData, componentChuncks: componentChuncks)
        }
        return drilldown
    }
    
    func setDrilldownWithReports( drilldownData : ZCRMAnalyticsData, drilldownDataJSON : [ String : Any ] ) throws -> ZCRMAnalyticsData
    {
        if let requestedObj = drilldownDataJSON.optDictionary(key: DrilldownDataAPINames.requestedObj), let reportId = requestedObj.optInt64(key: DrilldownDataAPINames.reportId)
        {
            drilldownData.reportId = reportId
            drilldownData.count = try requestedObj.getInt( key : DrilldownDataAPINames.limitListCount )
            if let module = requestedObj.optString(key: DrilldownDataAPINames.module)
            {
                drilldownData.module = module
            }
            if let reqType = requestedObj.optString(key: DrilldownDataAPINames.reqType)
            {
                drilldownData.requestType = reqType
            }
            if let totalCount = requestedObj.optInt(key: DrilldownDataAPINames.totalRowCount)
            {
                drilldownData.rowCount = totalCount
            }
            drilldownData.componentName = requestedObj.optString(key: DrilldownDataAPINames.type)
            if let headings = drilldownDataJSON.optArrayOfDictionaries(key: DrilldownDataAPINames.heading)
            {
                for heading in headings
                {
                    let field = try self.setFieldsForDrilldownWithReports(heading: heading)
                    drilldownData.fields.append( field )
                }
            }
            if let body = drilldownDataJSON.optArrayOfDictionaries(key: DrilldownDataAPINames.body)
            {
                for dict in body
                {
                    let data : ZCRMAnalyticsData.Row = try self.setDataForDrilldownWithReports(dict: dict, fields: drilldownData.fields)
                    drilldownData.rows.append(data)
                }
            }
        }
        return drilldownData
    }
    
    func setFieldsForDrilldownWithReports( heading : [ String : Any ] ) throws -> ZCRMAnalyticsData.Field
    {
        var isSortable : Bool?
        isSortable = heading.optBoolean(key: DrilldownDataAPINames.isSortable)
        let field : ZCRMAnalyticsData.Field = ZCRMAnalyticsData.Field( name : try heading.getString( key : DrilldownDataAPINames.columnName ),
                                                                      label : try heading.getString( key : DrilldownDataAPINames.fieldLabel ),
                                                                      isSortable : isSortable )
        return field
    }
    
    func setDataForDrilldownWithReports( dict : [ String : Any ], fields : [ ZCRMAnalyticsData.Field ] ) throws -> ZCRMAnalyticsData.Row
    {
        var data : ZCRMAnalyticsData.Row = ZCRMAnalyticsData.Row()
        var fieldVsValue : [ String : Any ] = [ String : Any ]()
        for (key, value) in dict
        {
            if key != DrilldownDataAPINames.content
            {
                fieldVsValue[ key ] = value
            }
        }
        data.fieldVsValue = fieldVsValue
        if let contents = dict.optArray(key: DrilldownDataAPINames.content)
        {
            for index in 0..<contents.count
            {
                let content : ZCRMAnalyticsData.Cell = try self.setContentForDrilldownWithReports(contents: contents, fields: fields, index: index)
                data.cells.append(content)
            }
        }
        return data
    }
    
    func setContentForDrilldownWithReports( contents : [ Any ], fields : [ ZCRMAnalyticsData.Field ], index : Int ) throws -> ZCRMAnalyticsData.Cell
    {
        var content : ZCRMAnalyticsData.Cell = ZCRMAnalyticsData.Cell()
        content.key = fields[index].name
        if contents[index] is [ String : Any ], let contentDict = contents[index] as? [ String : Any ]
        {
            if let module = contentDict.optString(key: DrilldownDataAPINames.Module)
            {
                if module == DrilldownDataAPINames.users
                {
                    content.label = "None"
                    content.value = try contentDict.getInt64( key : DrilldownDataAPINames.entityId )
                }
                else
                {
                    if contentDict.hasValue(forKey: DrilldownDataAPINames.entityId)
                    {
                        let record : ZCRMRecordDelegate = ZCRMRecordDelegate( id : try contentDict.getInt64( key : DrilldownDataAPINames.entityId ), moduleAPIName : module )
                        content.value = record
                        if let label = contentDict.optString(key: DrilldownDataAPINames.displayLabel)
                        {
                            record.label = getValue(value: label)
                            content.label = getValue(value: label)
                        }
                    }
                    else
                    {
                        content.value = nil
                        if let label = contentDict.optString(key: DrilldownDataAPINames.displayLabel)
                        {
                            content.label = getValue(value: label)
                        }
                    }
                }
            }
        }
        else
        {
            if let label = contents[index] as? String, label.isEmpty != true
            {
                content.label = getValue(value: label)
                content.value = contents[index]
            }
        }
        return content
    }

    func setDrilldownDataWithoutReports( drilldownData : ZCRMAnalyticsData, componentChuncks : [[ String : Any ]] ) throws -> ZCRMAnalyticsData
    {
        for componentChunk in componentChuncks
        {
            if let columnInfo = componentChunk.optDictionary(key: DrilldownDataAPINames.aggregateColumnInfo), let aggregateLabel = columnInfo.optString(key: DrilldownDataAPINames.label)
            {
                drilldownData.aggregateLabel = aggregateLabel
            }
            if let aggregates = try componentChunk.getDictionary( key : DrilldownDataAPINames.dataMap ).getDictionary( key : "T" ).optArrayOfDictionaries( key : DrilldownDataAPINames.aggregates ), let count = aggregates[ 0 ].optInt( key : DrilldownDataAPINames.value )
            {
                drilldownData.count = count
            }
            if let detailColumnInfo = componentChunk.optArrayOfDictionaries(key: DrilldownDataAPINames.detailColumnInfo)
            {
                for details in detailColumnInfo
                {
                    let field : ZCRMAnalyticsData.Field = try self.setFieldsForDrilldownWithoutReports(details: details)
                    drilldownData.fields.append(field)
                }
            }
            if let rows = try componentChunk.getDictionary( key : DrilldownDataAPINames.dataMap ).getDictionary( key : "T" ).optArrayOfDictionaries( key : DrilldownDataAPINames.rows )
            {
                for row in rows
                {
                    let data : ZCRMAnalyticsData.Row = try self.setDataForDrilldownWithoutReports(row: row, fields: drilldownData.fields)
                    drilldownData.rows.append(data)
                }
            }
        }
        return drilldownData
    }
    
    func setFieldsForDrilldownWithoutReports( details : [ String : Any ] )throws -> ZCRMAnalyticsData.Field
    {
        let field : ZCRMAnalyticsData.Field = ZCRMAnalyticsData.Field( name : try details.getString( key : DrilldownDataAPINames.name ), label : try details.getString( key : DrilldownDataAPINames.label ), isSortable : nil )
        return field
    }
    
    func setDataForDrilldownWithoutReports( row : [ String : Any ], fields : [ ZCRMAnalyticsData.Field ] )throws -> ZCRMAnalyticsData.Row
    {
        var data : ZCRMAnalyticsData.Row = ZCRMAnalyticsData.Row()
        if let cells = row.optArrayOfDictionaries(key: DrilldownDataAPINames.cells)
        {
            for index in 0..<cells.count
            {
                var content : ZCRMAnalyticsData.Cell = ZCRMAnalyticsData.Cell()
                content.key = fields[index].name
                if cells[index].hasValue(forKey: DrilldownDataAPINames.module)
                {
                    if cells[ index ].hasValue(forKey: DrilldownDataAPINames.value)
                    {
                        let record : ZCRMRecordDelegate = ZCRMRecordDelegate( id : try cells[ index ].getInt64( key : DrilldownDataAPINames.value ), moduleAPIName : try cells[ index ].getString( key : DrilldownDataAPINames.module ) )
                        content.value = record
                        if let label = cells[index].optString(key: DrilldownDataAPINames.label)
                        {
                            record.label = getValue(value: label)
                            content.label = getValue(value: label)
                        }
                    }
                    else
                    {
                        if cells[ index ].hasValue(forKey: DrilldownDataAPINames.label)
                        {
                            let label = try cells[ index ].getString( key : DrilldownDataAPINames.label )
                            content.label = getValue(value: label)
                            content.value = nil
                        }
                    }
                }
                else
                {
                    if let label = try self.optValueAsString(dict: cells[index], key: DrilldownDataAPINames.label) {
                        content.label = label
                    }
                    if let value = try self.optValueAsString(dict: cells[index], key: DrilldownDataAPINames.value) {
                        content.value = value
                    }
                }
                data.cells.append(content)
            }
        }
        return data
    }
    
    func getValue( value : String ) -> String
    {
        if value == "-"
        {
            return "None"
        }
        return value
    }
}

extension RequestParamKeys
{
    static let searchWord = "searchword"
    static let queryScope = "query_scope"
    static let period = "period"
    static let criteria = "criteria"
    static let reportId = "report_id"
    static let fromHierarchy = "from_hierarchy"
    static let drilldown = "drill_down"
    static let sortColumn = "sort_column"
    static let orderBy = "order_by"
    static let fromIndex = "from_index"
    static let ascending = "ascending"
    static let descending = "descending"
    static let subComponentId = "subComponentId"
}
