//
//  DashboardAPIHandler.swift
//  ZCRMiOS
//
//  Created by Kalyani shiva on 12/07/18.
//
import Foundation
class DashboardAPIHandler: CommonAPIHandler
{
    // used by dashboard and component Refresh
    fileprivate let refreshSuccess = "success"
    
    // Return Types used by dashBoard and dashboardComponent Refresh Methods
    public typealias DashboardResult = Result.DataResponse<ZCRMDashboard,APIResponse>
    public typealias ComponentResult = Result.DataResponse<ZCRMDashboardComponent,APIResponse>
    
    // Result Type Completion Handlers
    public typealias Dashboard = ZCRMAnalytics.Dashboard
    public typealias ArrayOfDashboards = ZCRMAnalytics.ArrayOfDashboards
    public typealias DashBoardComponent = ZCRMAnalytics.DashboardComponent
    public typealias RefreshResponse = ZCRMAnalytics.RefreshResponse
    public typealias ArrayOfColorThemes = ZCRMAnalytics.ArrayOfColorThemes
    
    // API Names
    fileprivate typealias DashBoardAPINames = ZCRMDashboard.Properties.ResponseJSONKeys
    fileprivate typealias MetaComponentAPINames = ZCRMDashboardComponentMeta.Properties.ResponseJSONKeys
    fileprivate typealias ComponentAPINames = ZCRMDashboardComponent.Properties.ResponseJSONKeys
    fileprivate typealias ColorPaletteAPINames = ZCRMDashboardComponentColorThemes.Properties.ResponseJSONKeys
    
    // Model Objects
    fileprivate typealias CompCategory = ZCRMDashboardComponent.ComponentCategory
    fileprivate typealias CompObjective  = ZCRMDashboardComponent.Objective
    fileprivate typealias CompSegmentRanges = ZCRMDashboardComponent.SegmentRanges
    fileprivate typealias ComponentMarkers = ZCRMDashboardComponent.ComponentMarkers
    fileprivate typealias AggregateColumn = ZCRMDashboardComponent.AggregateColumnInfo
    fileprivate typealias GroupingColumn = ZCRMDashboardComponent.GroupingColumnInfo
    fileprivate typealias VerticalGrouping = ZCRMDashboardComponent.VerticalGrouping
    fileprivate typealias GroupingValue = ZCRMDashboardComponent.GroupingValue
    fileprivate typealias ComponentChunks = ZCRMDashboardComponent.ComponentChunks
    fileprivate typealias Aggregate = ZCRMDashboardComponent.Aggregate
    
    // used for dict keys
    fileprivate typealias ColorPaletteKeys = ZCRMDashboardComponentColorThemes.ColorPalette
    // used for parsing out ColorPaletteName
    fileprivate typealias ColorPalette = ZCRMDashboardComponentColorThemes.ColorPalette
    //Path Name
    fileprivate typealias URLPathName = ZCRMDashboard.Properties.URLPathName
    
    //Meta - Component Parser Return Type
    fileprivate typealias MetaComponentLayoutPropsTuple = (width:Int?,height:Int?,xPosition:Int?,yPosition:Int?)
    //Component Parser Return Type
    fileprivate typealias SegmentRangesTuple = (color:String?,startPos:String?,endPos:String?)
    fileprivate typealias GroupingConfigDetails = (AllowedValues:[GroupingValue]?,CustomGroups:[GroupingValue]?)
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
    func getAllDashboards(fromPage page:Int,withPerPageOf perPage:Int, searchWord : String?, queryScope : ZCRMAnalytics.QueryScope?, then onCompletion: @escaping ArrayOfDashboards)
    {
        let URLPath = "/\(URLPathName.ANALYTICS)"
        var arrayOfDashboardObj = [ZCRMDashboard]()
        setUrlPath(urlPath: URLPath)
        setRequestMethod(requestMethod: .GET)
        //perPage is  YET TO BE SUPPORTED
        //let validPerPage = perPage > 200 ? 200 : perPage
        //addRequestParam(param: .perPage, value: "\(validPerPage)")
        addRequestParam(param: "page" , value: String(page) )
        if let searchWord = searchWord
        {
            addRequestParam(param: ZCRMAnalytics.RequestParamKeys.searchWord, value: searchWord)
        }
        if let queryScope = queryScope
        {
            addRequestParam(param: ZCRMAnalytics.RequestParamKeys.queryScope, value: queryScope.rawValue)
        }
        setJSONRootKey(key: JSONRootKey.ANALYTICS)
        let request = APIRequest(handler: self)
        request.getBulkAPIResponse { (resultType) in
            do
            {
                let bulkAPIResponse = try resultType.resolve()
                let dashBoardResponse =  bulkAPIResponse.getResponseJSON() // [String:[[String:Any]]
                if dashBoardResponse.isEmpty == false
                {
                    let arrayOfDashboardJSON = dashBoardResponse.getArrayOfDictionaries(key:JSONRootKey.ANALYTICS) // [[String:Any]]
                    if arrayOfDashboardJSON.isEmpty == true
                    {
                        onCompletion( .failure( ZCRMError.SDKError( code: ErrorCode.RESPONSE_NIL, message: ErrorMessage.RESPONSE_JSON_NIL_MSG ) ) )
                        return
                    }
                    for dashBoardJSON in arrayOfDashboardJSON
                    {
                        let dashBoardObj = try self.getZCRMDashboardObjectFrom(dashBoardJSON)
                        arrayOfDashboardObj.append(dashBoardObj)
                    }
                }
                onCompletion(.success(arrayOfDashboardObj,bulkAPIResponse))
            }
            catch
            {
                onCompletion(.failure(typeCastToZCRMError(error)))
            }
        } // completion ends
    } // func ends
    
    func getDashboardWithId(id dbID:Int64,then onCompletion: @escaping Dashboard)
    {
        let URLPath = "/\(URLPathName.ANALYTICS)/\(dbID)"
        setUrlPath(urlPath: URLPath)
        setRequestMethod(requestMethod: .GET)
        setJSONRootKey(key: JSONRootKey.ANALYTICS)
        let request = APIRequest(handler: self)
        print( "Request : \(request.toString())" )
        request.getAPIResponse { (resultType) in
            do
            {
                let APIResponse = try resultType.resolve()
                let dashBoardResponse = APIResponse.getResponseJSON() // [String:[[String:Any]]]
                let dashBoardJSON = dashBoardResponse.getArrayOfDictionaries(key: JSONRootKey.ANALYTICS)[0]
                let dashboardObj = try self.getZCRMDashboardObjectFrom(dashBoardJSON)
                onCompletion(.success(dashboardObj,APIResponse))
            }
            catch
            {
                onCompletion(.failure(typeCastToZCRMError(error)))
            }
        } // completion
    } // func ends
    
    func getComponentWith(id cmpID: Int64,fromDashboardID dbID: Int64,then onCompletion: @escaping DashBoardComponent)
    {
        let URLPath = "/\(URLPathName.ANALYTICS)/\(dbID)/\(URLPathName.COMPONENTS)/\(cmpID)"
        setUrlPath(urlPath: URLPath)
        setRequestMethod(requestMethod: .GET)
        //Setting this has no effect but only to communicate the fact that its Response has
        // no root key
        setJSONRootKey(key: JSONRootKey.NIL)
        let request = APIRequest(handler: self)
        print("\(request.toString())")
        request.getAPIResponse { (resultType) in
            do
            {
                let APIResponse = try resultType.resolve()
                let dashBoardComponentJSON = APIResponse.getResponseJSON() // [String:Any]
                let dashBoardComponentObj = try self.getDashboardComponentFrom(dashBoardComponentJSON, Using: cmpID, And: dbID)
                onCompletion(.success(dashBoardComponentObj,APIResponse))
            }
            catch
            {
                onCompletion(.failure(typeCastToZCRMError(error)))
            }
        } // completion
    }  // func ends
    
    func refreshComponentForObject(oldCompObj: ZCRMDashboardComponent, onCompletion: @escaping RefreshResponse)
    {
        let cmpID = oldCompObj.componentId
        let dbID = oldCompObj.dashboardId
        let URLPath = "/\(URLPathName.ANALYTICS)/\(dbID)/\(URLPathName.COMPONENTS)/\(cmpID)/\(URLPathName.REFRESH)"
        setUrlPath(urlPath: URLPath)
        setRequestMethod(requestMethod: .POST)
        setJSONRootKey(key: JSONRootKey.DATA)
        let request = APIRequest(handler: self)
        // API CALL 1: REFRESH COMPONENT
        request.getAPIResponse { (resultType) in
            let refreshResultTuple = self.resolveRefreshResult(resultType)
            //If refresh Component Fails...
            guard refreshResultTuple.refreshError == nil else{
                onCompletion(resultType)
                return
            }
            guard let refreshResponse = refreshResultTuple.refreshResponse else {
                //Should never occur ...
                // At this point Both Refresh Error and Refresh Response are NIL
                let unknownError = ZCRMError.InValidError(code: ErrorCode.RESPONSE_NIL, message: ErrorMessage.RESPONSE_NIL_MSG)
                onCompletion(.failure(unknownError))
                return
            }
            // API CALL 2: GET COMPONENT WITH ID
            self.getComponentWith(id: cmpID, fromDashboardID: dbID) { (cmpResult) in
                let (newCompObj,cmpError) = self.resolveComponentGetResult(cmpResult)
                //Comp Get Failed ...
                if let cmpError = cmpError {
                    onCompletion(.failure(cmpError))
                }
                do
                {
                    guard try self.didSetComponentProperties(of: newCompObj, to: oldCompObj)
                        else {
                            // transferring new db props to old one failed !
                            let unknownError = ZCRMError.InValidError(code: ErrorCode.RESPONSE_NIL, message: ErrorMessage.RESPONSE_NIL_MSG)
                            onCompletion(.failure(unknownError))
                            return
                    }
                    // Component Refresh and Get succeeded ...
                    onCompletion(.success(refreshResponse))
                }
                catch
                {
                    onCompletion(.failure(typeCastToZCRMError(error)))
                }
            } // New Component Get Completion ends
        } // Component Refresh completion ends
    } // RefreshComponentForObject  ends
    
    func refreshDashboardForObject(_ oldDashBoardObj:ZCRMDashboard, onCompletion: @escaping RefreshResponse)
    {
        let dbID = oldDashBoardObj.id
        let URLPath = "/\(URLPathName.ANALYTICS)/\(dbID)/\(URLPathName.REFRESH)"
        setUrlPath(urlPath: URLPath)
        setRequestMethod(requestMethod: .POST)
        setJSONRootKey(key: JSONRootKey.DATA)
        let request = APIRequest(handler: self)
        // API CALL 1 : REFRESH DASHBOARD WITH ID
        request.getAPIResponse { (refreshResult) in
            let refreshResultTuple = self.resolveRefreshResult(refreshResult)
            //If refresh dashBoard fails .. pass the result
            guard refreshResultTuple.refreshError == nil else {
                onCompletion(refreshResult)
                return
            }
            guard let refreshResponse = refreshResultTuple.refreshResponse else {
                //Should never occur ...
                // At this point Both Refresh Error and Refresh Response are NIL
                let unknownError = ZCRMError.InValidError(code: ErrorCode.RESPONSE_NIL, message: ErrorMessage.RESPONSE_NIL_MSG)
                onCompletion(.failure(unknownError))
                return
            }
            // API CALL 2 : GET DASHBOARD WITH ID
            self.getDashboardWithId(id: dbID){ (dbResult) in
                let (newDashBoard,dbError) = self.resolveDashboardGetResult(dbResult)
                // if getDashBoard fails...
                if let dbError = dbError {
                    onCompletion(.failure(dbError))
                    return
                }
                do
                {
                    guard try self.didSetDashBoardProperties(of: newDashBoard, to: oldDashBoardObj) else {
                        // transferring new db props to old one failed !
                        let errorMsg = "Refresh Failed! Unable to set dashBoard Properties"
                        let propertySetError = ZCRMError.ProcessingError(code: ErrorCode.RESPONSE_NIL, message: errorMsg)
                        onCompletion(.failure(propertySetError))
                        return
                    }
                    // Refresh and getDashBoard succeeds ...
                    onCompletion(.success(refreshResponse))
                    return
                }
                catch
                {
                    onCompletion(.failure(typeCastToZCRMError(error)))
                }
            }// getDashBoard completion
        } // API Response completion
    } // func ends
    
    func getDashboardComponentColorThemes(onCompletion: @escaping ArrayOfColorThemes)
    {
        let URLPath = "/\(URLPathName.ANALYTICS)/\(URLPathName.COLORTHEMES)"
        setJSONRootKey(key: JSONRootKey.NIL)
        setUrlPath(urlPath: URLPath)
        setRequestMethod(requestMethod: .GET)
        let request = APIRequest(handler: self)
        request.getAPIResponse { (resultType) in
            do
            {
                let APIResponse = try resultType.resolve()
                let colorThemesResponseJSON = APIResponse.getResponseJSON() //[String:Any]
                let colorThemesJSON = colorThemesResponseJSON.getArrayOfDictionaries(key: ColorPaletteAPINames.colorThemes)
                let ArrayOfcolorThemes = try self.getArrayOfZCRMDashboardComponentColorThemes(colorThemesJSON)
                onCompletion(.success(ArrayOfcolorThemes,APIResponse))
            }
            catch
            {
                onCompletion(.failure(typeCastToZCRMError(error)))
            }
        } // Completion
    } // func ends
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
                let errorObj = ZCRMError.SDKError(code: ErrorCode.INTERNAL_ERROR, message: "Refresh Failed!")
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
        if refreshedDashboard.id == APIConstants.INT64_MOCK
        {
            throw ZCRMError.InValidError( code : ErrorCode.VALUE_NIL, message : "\(DashBoardAPINames.dashboardID) must not be nil" )
        }
        oldDashBoard.id = refreshedDashboard.id
        if refreshedDashboard.name == APIConstants.STRING_MOCK
        {
            throw ZCRMError.InValidError( code : ErrorCode.VALUE_NIL, message : "\(DashBoardAPINames.dashboardName) must not be nil" )
        }
        oldDashBoard.name = refreshedDashboard.name
        oldDashBoard.accessType = refreshedDashboard.accessType
        oldDashBoard.isSystemGenerated = refreshedDashboard.isSystemGenerated
        oldDashBoard.isSalesTrends = refreshedDashboard.isSalesTrends
        oldDashBoard.dashboardComponentMeta = refreshedDashboard.dashboardComponentMeta
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
        if refreshedComp.name == APIConstants.STRING_MOCK
        {
            throw ZCRMError.InValidError( code : ErrorCode.VALUE_NIL, message : "\(ComponentAPINames.componentName) must not be nil" )
        }
        oldComp.name = refreshedComp.name
        if refreshedComp.componentId == APIConstants.INT64_MOCK
        {
            throw ZCRMError.InValidError( code : ErrorCode.VALUE_NIL, message : "Component Id must not be nil" )
        }
        oldComp.componentId = refreshedComp.componentId
        if refreshedComp.dashboardId == APIConstants.INT64_MOCK
        {
            throw ZCRMError.InValidError( code : ErrorCode.VALUE_NIL, message : "Dashboard Id must not be nil" )
        }
        oldComp.dashboardId = refreshedComp.dashboardId
        oldComp.category = refreshedComp.category
        if refreshedComp.type == APIConstants.STRING_MOCK
        {
            throw ZCRMError.InValidError( code : ErrorCode.VALUE_NIL, message : "\(ComponentAPINames.type) must not be nil" )
        }
        oldComp.type = refreshedComp.type
        oldComp.objective = refreshedComp.objective
        oldComp.reportId = refreshedComp.reportId
        oldComp.segmentRanges = refreshedComp.segmentRanges
        oldComp.colorPaletteName = refreshedComp.colorPaletteName
        oldComp.colorPaletteStartingIndex = refreshedComp.colorPaletteStartingIndex
        oldComp.componentMarkers = refreshedComp.componentMarkers
        oldComp.maximumRows = refreshedComp.maximumRows
        oldComp.lastFetchedTimeLabel = refreshedComp.lastFetchedTimeLabel
        oldComp.lastFetchedTimeValue = refreshedComp.lastFetchedTimeValue
        oldComp.componentChunks = refreshedComp.componentChunks
        return true
    } // func ends
} // end of extension

///HANDLER PARSING FUNCTIONS
fileprivate extension DashboardAPIHandler {
    ///*** DASHBOARD PARSERS ***
    func getZCRMDashboardObjectFrom(_ dashBoardJSON: [String:Any] ) throws -> ZCRMDashboard
    {
        try dashBoardJSON.valueCheck(forKey: DashBoardAPINames.dashboardID)
        try dashBoardJSON.valueCheck(forKey: DashBoardAPINames.dashboardName)
        let dashBoardObj = ZCRMDashboard(id: dashBoardJSON.getInt64(key: DashBoardAPINames.dashboardID), name: dashBoardJSON.getString(key: DashBoardAPINames.dashboardName))
        if let isSalesTrend = dashBoardJSON.optBoolean(key: DashBoardAPINames.isSalesTrends)
        {
            dashBoardObj.isSalesTrends = isSalesTrend
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
            let arrayOfMetaComponent = try getArrayOfZCRMDashboardComponentMeta(From: dashBoardJSON)
            dashBoardObj.dashboardComponentMeta = arrayOfMetaComponent
        }
        return dashBoardObj
    }
} // end of extension

fileprivate extension DashboardAPIHandler
{
    ///*** DASHBOARD META-COMPONENT PARSERS  ***
    func getArrayOfZCRMDashboardComponentMeta(From dashBoardJSON:[String:Any]) throws -> [ZCRMDashboardComponentMeta]
    {
        let metaComponentAPIName = ZCRMDashboard.Properties.ResponseJSONKeys.metaComponents
        try dashBoardJSON.valueCheck(forKey: metaComponentAPIName)
        let arrayOfMetaComponentJSON = dashBoardJSON.getArrayOfDictionaries(key: metaComponentAPIName)
        var metaComponentObjArray = [ZCRMDashboardComponentMeta]()
        for dashBoardMetaComponentJSON in arrayOfMetaComponentJSON {
            let metaComponentObj = try getDashboardMetaComponentFrom(dashBoardMetaComponentJSON)
            metaComponentObjArray.append(metaComponentObj)
        }
        return metaComponentObjArray
    }
    
    func getDashboardMetaComponentFrom(_ metaComponentJSON:[String:Any]) throws -> ZCRMDashboardComponentMeta
    {
        let metaComponentObj = ZCRMDashboardComponentMeta()
        try metaComponentJSON.valueCheck(forKey: MetaComponentAPINames.componentID)
        metaComponentObj.componentID = metaComponentJSON.getInt64(key: MetaComponentAPINames.componentID)
        try metaComponentJSON.valueCheck(forKey: MetaComponentAPINames.componentName)
        metaComponentObj.componentName = metaComponentJSON.getString(key: MetaComponentAPINames.componentName)
        if let isFavorite = metaComponentJSON.optBoolean(key: MetaComponentAPINames.favouriteComponent)
        {
            metaComponentObj.isFavouriteComponent = isFavorite
        }
        try metaComponentJSON.valueCheck(forKey: MetaComponentAPINames.systemGenerated)
        metaComponentObj.isSystemGenerated = metaComponentJSON.getBoolean(key: MetaComponentAPINames.systemGenerated)
        try metaComponentJSON.valueCheck(forKey: MetaComponentAPINames.itemProps)
        let itemPropsJSON = metaComponentJSON.getDictionary(key: MetaComponentAPINames.itemProps)
        try itemPropsJSON.valueCheck(forKey: MetaComponentAPINames.layout)
        let layoutJSON = itemPropsJSON.getDictionary(key: MetaComponentAPINames.layout)
        var metaComponentLayoutObj = metaComponentObj.properties
        metaComponentLayoutObj.componentXPosition = Int(layoutJSON.optString(key: MetaComponentAPINames.componentXPosition) ?? "default")
        metaComponentLayoutObj.componentYPosition = Int(layoutJSON.optString(key: MetaComponentAPINames.componentYPosition) ?? "default")
        metaComponentLayoutObj.componentWidth = Int(layoutJSON.optString(key: MetaComponentAPINames.componentWidth) ?? "default")
        metaComponentLayoutObj.componentHeight = Int(layoutJSON.optString(key: MetaComponentAPINames.componentHeight) ?? "default")
        metaComponentObj.properties = metaComponentLayoutObj
        return metaComponentObj
    }
} // Extension ends

fileprivate extension DashboardAPIHandler
{
    // *** DASHBOARD COMPONENT PARSERS ***
    func getDashboardComponentFrom(_ componentJSON: [String:Any], Using cmpId: Int64, And dbId: Int64) throws -> ZCRMDashboardComponent
    {
        try componentJSON.valueCheck(forKey: ComponentAPINames.componentName)
        try componentJSON.valueCheck(forKey: ComponentAPINames.componentCategory)
        let componentObj = ZCRMDashboardComponent(cmpId: cmpId, name: componentJSON.getString(key: ComponentAPINames.componentName), dbId: dbId)
        if let category = CompCategory(rawValue: componentJSON.getString(key: ComponentAPINames.componentCategory))
        {
            componentObj.category = category
        }
        componentObj.reportId = componentJSON.optInt64(key: ComponentAPINames.reportID)
        if componentJSON.hasValue(forKey: ComponentAPINames.componentMarker)
        {
            if let arrayOfComponentMarkersObj = try getComponentMarkersFrom(componentJSON)
            {
                componentObj.componentMarkers = arrayOfComponentMarkersObj
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
    
    func getComponentMarkersFrom(_ componentJSON:[String:Any]) throws -> [ComponentMarkers]?
    {
        let Key = ComponentAPINames.componentMarker
        try componentJSON.valueCheck(forKey: Key)
        let ArrayOfCompMarkerJSON = componentJSON.getArrayOfDictionaries(key: Key)
        var ArrayOfComponentMarkerObj = [ComponentMarkers]()
        var x:String? // can be User ID (Int64) or pickListValue (String)
        for compMarkersJSON  in ArrayOfCompMarkerJSON
        {
            x = compMarkersJSON.optString(key: ComponentAPINames.componentMarkerXPosition)
            try compMarkersJSON.valueCheck(forKey: ComponentAPINames.componentMarkerYPosition)
            let y = compMarkersJSON.getInt(key: ComponentAPINames.componentMarkerYPosition)
            ArrayOfComponentMarkerObj.append(ComponentMarkers(x: x, y: y))
        } // loop ends
        return ArrayOfComponentMarkerObj
    }
    
    func setComponentPropertiesFor(_ componentObject:ZCRMDashboardComponent, Using componentJSON: [String:Any]) throws
    {
        let Key = ComponentAPINames.componentProps
        try componentJSON.valueCheck(forKey: Key)
        let componentPropsJSON = componentJSON.getDictionary(key: Key)
        if let objectiveString = componentPropsJSON.optString(key: ComponentAPINames.objective) {
            let objectiveEnum = CompObjective(rawValue: objectiveString)
            componentObject.objective = objectiveEnum
        }
        if let maximumRows = componentPropsJSON.optInt(key: ComponentAPINames.maximumRows) {
            componentObject.maximumRows = maximumRows
        }
        try setVisualizationPropertiesFor(componentObject: componentObject,
                                          Using: componentPropsJSON)
    } // func ends
    
    //COMPONENT VISUALIZATION PROPERTIES
    func setVisualizationPropertiesFor(componentObject:ZCRMDashboardComponent, Using componentPropsJSON: [String:Any]) throws
    {
        let Key = ComponentAPINames.visualizationProps
        try componentPropsJSON.valueCheck(forKey: Key)
        let visualizationPropsJSON = componentPropsJSON.getDictionary(key: Key )
        try visualizationPropsJSON.valueCheck(forKey: ComponentAPINames.componentType)
        let componentType = visualizationPropsJSON.getString(key: ComponentAPINames.componentType)
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
        try visualizationPropsJSON.valueCheck(forKey: Key)
        let ArrayOfSegmentRangesJSON = visualizationPropsJSON.getArrayOfDictionaries(key: Key)
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
            throw ZCRMError.InValidError( code : ErrorCode.VALUE_NIL, message : "Unable to construct segment ranges object from tuple")
        }
        // Removing % and converting to number
        startPosPercent.removeLast()
        endPosPercent.removeLast()
        let startPosInt =  Int(startPosPercent)
        let endPosInt = Int(endPosPercent)
        guard let color = Tuple.color,
            let startPos = startPosInt,
            let endPos = endPosInt else {
                throw ZCRMError.InValidError( code : ErrorCode.VALUE_NIL, message : "Unable to construct segment ranges object from tuple" )
        }
        return CompSegmentRanges(color: color, startPos: startPos, endPos: endPos)
    } // func ends
    
    func getColorPaletteFrom(_ visualizationPropsJSON: [String:Any]) throws -> (name:ColorPalette,index:Int)?
    {
        let Key = ComponentAPINames.colorPalette
        guard visualizationPropsJSON.hasKey(forKey: Key) else {
            return nil
        }
        try visualizationPropsJSON.valueCheck(forKey: Key)
        let colorPaletteJSON = visualizationPropsJSON.getDictionary(key: Key)
        try colorPaletteJSON.valueCheck(forKey: ComponentAPINames.colorPaletteName)
        try colorPaletteJSON.valueCheck(forKey: ComponentAPINames.colorPaletteStartingIndex)
        guard let name = ColorPalette(rawValue: colorPaletteJSON.getString(key: ComponentAPINames.colorPaletteName)) else {
            throw ZCRMError.InValidError( code : ErrorCode.VALUE_NIL, message : "\( ComponentAPINames.colorPalette ) must not be nil" )
        }
        return (name,colorPaletteJSON.getInt(key: ComponentAPINames.colorPaletteStartingIndex))
    } // func ends
    
    //COMPONENT CHUNKS
    func setComponentChunksValues(To componentObj:ZCRMDashboardComponent, Using chunks: [[String:Any]]?) throws
    {
        guard let ArrayOfComponentChunksJSON = chunks else {
            throw ZCRMError.InValidError( code : ErrorCode.VALUE_NIL, message : "Failed to get component chunks [String:Any]")
        }
        for componentChunksJSON in ArrayOfComponentChunksJSON
        {
            var componentChunksObj = ComponentChunks()
            if componentChunksJSON.hasValue(forKey: ComponentAPINames.dataMap)
            {
                if componentChunksJSON.getDictionary(key: ComponentAPINames.dataMap).hasValue(forKey: "T")
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
                let groupingColumn = try getArrayOfGroupingColumnInfo(Using: componentChunksJSON)
                for groupingObj in groupingColumn
                {
                    componentChunksObj.addGroupingColumnInfo(groupingObj)
                }
            }
            if componentChunksJSON.hasValue(forKey: ComponentAPINames.verticalGrouping)
            {
                let verticalGroupingJSON = componentChunksJSON.getArrayOfDictionaries(key: ComponentAPINames.verticalGrouping)
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
            if componentChunksJSON.hasValue(forKey: ComponentAPINames.componentProps)
            {
                componentChunksObj.objective = CompObjective(rawValue: componentChunksJSON.getDictionary(key: ComponentAPINames.componentProps).optString(key: ComponentAPINames.objective)!)
            }
            componentObj.addComponentChunks(chunks: componentChunksObj)
        } // outer loop ends
    } // func ends
    
    func getArrayOfVerticalGroupingTotalAggregate(componentChunksJSON : [ String:Any ]) throws -> [Aggregate]
    {
        let Key = ComponentAPINames.aggregates
        try componentChunksJSON.getDictionary(key: ComponentAPINames.dataMap).getDictionary(key: "T").valueCheck(forKey: Key)
        let ArrayOfAggregateJSON = componentChunksJSON.getDictionary(key: ComponentAPINames.dataMap).getDictionary(key: "T").getArrayOfDictionaries(key: Key)
        var aggregates : [Aggregate] = [Aggregate]()
        for aggr in ArrayOfAggregateJSON
        {
            let aggrLabel : String = try self.getValue(dict: aggr, key: ComponentAPINames.label)
            var aggrObj : Aggregate
            if let val = aggr.optDouble(key: ComponentAPINames.value)
            {
                aggrObj = Aggregate(label: aggrLabel, value: val)
                aggregates.append(aggrObj)
            }
            else
            {
                aggrObj = Aggregate(label: aggrLabel, value: 0)
                aggregates.append(aggrObj)
            }
            aggregates.append(aggrObj)
        }
        return aggregates
    }
    
    //AGGREGATE COLUMN INFO
    func getArrayOfAggregateColumnInfo(Using componentChunksJSON: [String:Any] ) throws -> [AggregateColumn]
    {
        let Key = ComponentAPINames.aggregateColumn
        var ArrayOfAggregateColumnObj = [AggregateColumn]()
        try componentChunksJSON.valueCheck(forKey: Key)
        let ArrayOfAggregateColumnJSON = componentChunksJSON.getArrayOfDictionaries(key: Key)
        // Keys are of Enum Type to avoid typos at set and get sites
        for aggregateColumnJSON in ArrayOfAggregateColumnJSON
        {
            try aggregateColumnJSON.valueCheck(forKey: ComponentAPINames.label)
            try aggregateColumnJSON.valueCheck(forKey: ComponentAPINames.type)
            try aggregateColumnJSON.valueCheck(forKey: ComponentAPINames.name)
            ArrayOfAggregateColumnObj.append(AggregateColumn(label: aggregateColumnJSON.getString(key: ComponentAPINames.label),
                                                             type: aggregateColumnJSON.getString(key: ComponentAPINames.type),
                                                             name: aggregateColumnJSON.getString(key: ComponentAPINames.name),
                                                             decimalPlaces: aggregateColumnJSON.optInt(key: ComponentAPINames.decimalPlaces),
                                                             aggregation: aggregateColumnJSON.optArray(key: ComponentAPINames.aggregations) as? [String]))
        }
        return ArrayOfAggregateColumnObj
    } // func ends
    
    //GROUPING COLUMN INFO
    func getArrayOfGroupingColumnInfo(Using componentChunksJSON: [String:Any]) throws -> [GroupingColumn]
    {
        let Key = ComponentAPINames.groupingColumn
        var ArrayOfGroupingColumnObj = [GroupingColumn]()
        try componentChunksJSON.valueCheck(forKey: Key)
        let ArrayOfGroupingColumnJSON = componentChunksJSON.getArrayOfDictionaries(key: Key)
        for groupingColumnJSON in ArrayOfGroupingColumnJSON
        {
            var allowedValues : [GroupingValue] = [GroupingValue]()
            var customGroups : [GroupingValue] = [GroupingValue]()
            try groupingColumnJSON.valueCheck(forKey: ComponentAPINames.label)
            try groupingColumnJSON.valueCheck(forKey: ComponentAPINames.type)
            try groupingColumnJSON.valueCheck(forKey: ComponentAPINames.name)
            if let groupingConfig = groupingColumnJSON.optDictionary(key: ComponentAPINames.groupingConfig)
            {
                if let allowedValuesJSON = groupingConfig.optArrayOfDictionaries(key: ComponentAPINames.allowedValues)
                {
                    for allowedValueJSON in allowedValuesJSON
                    {
                        let allowedValue : GroupingValue = GroupingValue(label: allowedValueJSON.getString(key: ComponentAPINames.label),
                                                                         value: allowedValueJSON.getString(key: ComponentAPINames.value))
                        allowedValues.append(allowedValue)
                    }
                }
                if let customGroupsJSON = groupingConfig.optArrayOfDictionaries(key: ComponentAPINames.customGroups)
                {
                    for customGroupJSON in customGroupsJSON
                    {
                        let customGroup : GroupingValue = GroupingValue(label: customGroupJSON.getString(key: ComponentAPINames.label),
                                                                        value: customGroupJSON.getString(key: ComponentAPINames.value))
                        customGroups.append(customGroup)
                    }
                }
            }
            ArrayOfGroupingColumnObj.append(GroupingColumn(label: groupingColumnJSON.getString(key: ComponentAPINames.label),
                                                           type: groupingColumnJSON.getString(key: ComponentAPINames.type),
                                                           name: groupingColumnJSON.getString(key: ComponentAPINames.name),
                                                           allowedValues: allowedValues,
                                                           customGroups: customGroups))
        }
        return ArrayOfGroupingColumnObj
    } // func ends
    
    //VERTICAL GROUPING
    func getArrayOfVerticalGrouping(Using componentChunksJSON: [String:Any], ArrayOfVerticalGroupingJSON : [[String:Any]] ) throws -> [VerticalGrouping]
    {
        //This gets used during SubGrouping Recursion
        var label : String
        var ArrayOfVerticalGroupingObj = [VerticalGrouping]()
        var subGrouping = [VerticalGrouping]()
        for verticalGroupingJSON in ArrayOfVerticalGroupingJSON
        {
            var aggregates = [Aggregate]()
            try verticalGroupingJSON.valueCheck(forKey: ComponentAPINames.label)
            try verticalGroupingJSON.valueCheck(forKey: ComponentAPINames.key)
            let key = verticalGroupingJSON.getString(key: ComponentAPINames.key)
            label = try self.getValue(dict: verticalGroupingJSON, key: ComponentAPINames.label)
            if let aggregate = componentChunksJSON.getDictionary(key: ComponentAPINames.dataMap).getDictionary(key: key).optArrayOfDictionaries(key: ComponentAPINames.aggregates)
            {
                for aggr in aggregate
                {
                    let aggrLabel : String = try self.getValue(dict: aggr, key: ComponentAPINames.label)
                    var aggrObj : Aggregate
                    if let val = aggr.optDouble(key: ComponentAPINames.value)
                    {
                        aggrObj = Aggregate(label: aggrLabel, value: val)
                        aggregates.append(aggrObj)
                    }
                    else
                    {
                        aggrObj = Aggregate(label: aggrLabel, value: 0)
                        aggregates.append(aggrObj)
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
                                                               value: verticalGroupingJSON.optString(key: ComponentAPINames.value),
                                                               key: key,
                                                               aggregate: aggregates,
                                                               subGrouping: subGrouping))
        }
        return ArrayOfVerticalGroupingObj
    } // func ends
    
    func getValue(dict: [String:Any], key: String) throws -> String
    {
        var value : String
        if dict.optString(key: key) == "-"  {
            value = "none"
        }
        else if let label = dict.optString(key: key)
        {
            value = label
        }
        else if let label = dict.optInt(key: key)
        {
            value = String(label)
        }
        else if let label = dict.optDouble(key: key)
        {
            value = String(label)
        }
        else
        {
            throw ZCRMError.InValidError( code : ErrorCode.INVALID_DATA, message : "\(key) should be of type Int, Double or String" )
        }
        return value
    }
}

///DASHBOARD COMPONENT COLOR THEMES PARSER
fileprivate extension DashboardAPIHandler
{
    func getArrayOfZCRMDashboardComponentColorThemes(_ ArrayOfColorThemesJSON:[[String:Any]]) throws -> [ZCRMDashboardComponentColorThemes]
    {
        var ArraycolorThemesObj = [ZCRMDashboardComponentColorThemes]()
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
                        throw ZCRMError.InValidError( code : ErrorCode.VALUE_NIL, message : "Unknown key \(key) encountered in color themes parsing")
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
            throw ZCRMError.InValidError( code : ErrorCode.VALUE_NIL, message : "Failed to typecast color palette JSON to [String:Any]")
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
                throw ZCRMError.InValidError( code : ErrorCode.VALUE_NIL, message : "Unknown color palette \(key) found!!" )
            }
        }
        return colorPaletteValues
    } // func ends
    
    func constructColorPaletteObjFrom(_ dict:[ColorThemeKeys:Any],_ colorPalette: [ColorPaletteKeys:[String]]?) throws -> ZCRMDashboardComponentColorThemes?
    {
        guard let colorPalette = colorPalette else {
            throw ZCRMError.InValidError( code : ErrorCode.VALUE_NIL, message : "Unable to construct color palette object" )
        }
        try dict.valueCheck(forKey: .name)
        let colorPaletteObj = ZCRMDashboardComponentColorThemes()
        colorPaletteObj.colorPalette = colorPalette
        colorPaletteObj.name = dict.getString(key: .name)
        return colorPaletteObj
    }
} // extension ends
