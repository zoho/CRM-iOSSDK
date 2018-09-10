//
//  DashboardAPIHandler.swift
//
//  Created by Kalyani shiva on 12/07/18.
//
import Foundation

class DashboardAPIHandler: CommonAPIHandler {
    
    // used by dashboard and component Refresh
    fileprivate let refreshSuccess = "success"
    
    // Return Types used by dashBoard and dashboardComponent Refresh Methods
    public typealias dashboardResult = Result.DataResponse<ZCRMDashboard,APIResponse>
    public typealias componentResult = Result.DataResponse<ZCRMDashboardComponent,APIResponse>
    
    // Result Type Completion Handlers
    public typealias dashboard = ZCRMAnalytics.dashboard
    public typealias ArrayOfDashboards = ZCRMAnalytics.ArrayOfDashboards
    public typealias dashBoardComponent = ZCRMAnalytics.dashboardComponent
    public typealias refreshResponse = ZCRMAnalytics.refreshResponse
    public typealias ArrayOfColorThemes = ZCRMAnalytics.ArrayOfColorThemes
    
    // API Names
    fileprivate typealias dashBoardAPINames = ZCRMDashboard.Properties.ResponseJSONKeys
    fileprivate typealias metaComponentAPINames = ZCRMDashboardComponentMeta.Properties.ResponseJSONKeys
    fileprivate typealias componentAPINames = ZCRMDashboardComponent.Properties.ResponseJSONKeys
    fileprivate typealias colorPaletteAPINames = ZCRMDashboardComponentColorThemes.Properties.ResponseJSONKeys
    
    // Model Objects
    fileprivate typealias CompCategory = ZCRMDashboardComponent.ComponentCategory
    fileprivate typealias CompObjective  = ZCRMDashboardComponent.Objective
    fileprivate typealias CompSegmentRanges = ZCRMDashboardComponent.SegmentRanges
    fileprivate typealias ComponentMarkers = ZCRMDashboardComponent.ComponentMarkers
    fileprivate typealias AggregateColumn = ZCRMDashboardComponent.AggregateColumnInfo
    fileprivate typealias GroupingColumn = ZCRMDashboardComponent.GroupingColumnInfo
    fileprivate typealias VerticalGrouping = ZCRMDashboardComponent.VerticalGrouping
    fileprivate typealias AllowedValues = ZCRMDashboardComponent.AllowedValues
    fileprivate typealias ComponentChunks = ZCRMDashboardComponent.ComponentChunks
    fileprivate typealias Aggregate = ZCRMDashboardComponent.Aggregate
    
    // used for dict keys
    fileprivate typealias colorPaletteKeys = ZCRMDashboardComponentColorThemes.ColorPalette
    // used for parsing out ColorPaletteName
    fileprivate typealias colorPalette = ZCRMDashboardComponentColorThemes.ColorPalette
    //Path Name
    fileprivate typealias URLPathName = ZCRMDashboard.Properties.URLPathName
    
    //Meta - Component Parser Return Type
    fileprivate typealias MetaComponentLayoutPropsTuple =
        (width:Int?,height:Int?,xPosition:Int?,yPosition:Int?)
    //Component Parser Return Type
    fileprivate typealias SegmentRangesTuple = (color:String?,startPos:String?,endPos:String?)
    fileprivate typealias GroupingConfig = (AllowedValues:[AllowedValues]?,CustomGroups:[String]?)
    
}




//MARK:- DICTIONARY KEYS FOR PARSER FUNCTIONS

fileprivate extension DashboardAPIHandler {
    
    enum AggregateColumnKeys: String {
        case label
        case type
        case name
        case decimalPlaces
        case aggregation
    }
    enum GroupingColumnKeys: String {
        case label
        case type
        case name
        case allowedValues
        case customGroups
    }
    enum VerticalGroupingKeys: String {
        case label
        case value
        case key
        case aggregate
        case subGrouping
    }
    enum ComponentChunkKeys: String {
        case verticalGrouping
        case groupingColumn
        case aggregateColumn
        case name
        case properties
        
    }
    // Might expand in the future
    enum ComponentChunkPropKeys: String {
        case objective
    }
    enum ColorThemeKeys: String {
        case name
        case colorPalettes
        
    }
    
}



//MARK:- HANDLER FUNCTIONS

extension DashboardAPIHandler {
    
    func getAllDashboards(fromPage page:Int,withPerPageOf perPage:Int,then
        onCompletion: @escaping ArrayOfDashboards)  {
        
        let URLPath = "/\(URLPathName.ANALYTICS)"
        setUrlPath(urlPath: URLPath)
        setRequestMethod(requestMethod: .GET)
        
        //MARK:- perPage is  YET TO BE SUPPORTED
        //let validPerPage = perPage > 200 ? 200 : perPage
        //addRequestParam(param: .perPage, value: "\(validPerPage)")
        
        addRequestParam(.page, value: "\(page)")
        setJSONRootKey(key: JSONRootKey.ANALYTICS)
        let request = APIRequest(handler: self)
        request.getBulkAPIResponse { (resultType) in
            
            do {
                let bulkAPIResponse = try resultType.resolve()
                let dashBoardResponse =  bulkAPIResponse.getResponseJSON() // [String:[[String:Any]]
                let arrayOfDashboardJSON = dashBoardResponse  // [[String:Any]]
                    .getArrayOfDictionaries(key:JSONRootKey.ANALYTICS)
                
                var arrayOfDashboardObj = [ZCRMDashboard]()
                for dashBoardJSON in arrayOfDashboardJSON
                {
                    if let dashBoardObj = self.getZCRMDashboardObjectFrom(dashBoardJSON){
                        arrayOfDashboardObj.append(dashBoardObj)
                    }
                }
                onCompletion(.success(arrayOfDashboardObj,bulkAPIResponse))
            } catch {
                onCompletion(.failure(typeCastToZCRMError(error)))
            }
        } // completion ends
    } // func ends
    
    
    func getDashboardWithId(id dbID:Int64,then onCompletion: @escaping dashboard)
    {
        let URLPath = "/\(URLPathName.ANALYTICS)/\(dbID)"
        setUrlPath(urlPath: URLPath)
        setRequestMethod(requestMethod: .GET)
        setJSONRootKey(key: JSONRootKey.ANALYTICS)
        let request = APIRequest(handler: self)
        request.getAPIResponse { (resultType) in
            do{
                let APIResponse = try resultType.resolve()
                let dashBoardResponse = APIResponse.getResponseJSON() // [String:[[String:Any]]]
                let dashBoardJSON = dashBoardResponse
                    .getArrayOfDictionaries(key: JSONRootKey.ANALYTICS)[0]
                
                guard let dashBoardObj = self.getZCRMDashboardObjectFrom(dashBoardJSON) else {
                    onCompletion(.failure(ZCRMError.SDKError(code: ErrorCode.INTERNAL_ERROR,
                                                             message: "Failed to get Dashboard")))
                    return
                }
                onCompletion(.success(dashBoardObj,APIResponse))
            } catch {
                onCompletion(.failure(typeCastToZCRMError(error)))
            }
        } // completion
    } // func ends
    
    
    func getComponentWith(id cmpID: Int64,fromDashboardID dbID: Int64,then
        onCompletion: @escaping dashBoardComponent)
    {
        let URLPath =
        "/\(URLPathName.ANALYTICS)/\(dbID)/\(URLPathName.COMPONENTS)/\(cmpID)"
        setUrlPath(urlPath: URLPath)
        setRequestMethod(requestMethod: .GET)
        //Setting this has no effect but only to communicate the fact that its Response has
        // no root key
        setJSONRootKey(key: JSONRootKey.NILL)
        let request = APIRequest(handler: self)
        request.getAPIResponse { (resultType) in
            do{
                let APIResponse = try resultType.resolve()
                let dashBoardComponentJSON = APIResponse.getResponseJSON() // [String:Any]
                
                guard let dashBoardComponentObj = self.getDashboardComponentFrom(dashBoardComponentJSON,
                                                                                 Using:cmpID,
                                                                                 And: dbID)
                    else {
                        onCompletion(.failure(ZCRMError.ProcessingError(code: ErrorCode.INTERNAL_ERROR,
                                                                        message: "Unable to get Component")))
                        return
                }
                onCompletion(.success(dashBoardComponentObj,APIResponse))
            }
            catch
            {
                onCompletion(.failure(typeCastToZCRMError(error)))
            }
        } // completion
        
    }  // func ends
    
    
    func refreshComponentForObject(oldCompObj: ZCRMDashboardComponent,
                                   onCompletion: @escaping refreshResponse){
        
        let cmpID = oldCompObj.getComponentId()
        let dbID = oldCompObj.getDashboardId()
        
        let URLPath =
        "/\(URLPathName.ANALYTICS)/\(dbID)/\(URLPathName.COMPONENTS)/\(cmpID)/\(URLPathName.REFRESH)"
        setUrlPath(urlPath: URLPath)
        
        setRequestMethod(requestMethod: .POST)
        setJSONRootKey(key: JSONRootKey.DATA)
        
        let request = APIRequest(handler: self)
        
        // API CALL 1: REFRESH COMPONENT
        request.getAPIResponse { (resultType) in
            
            let refreshResultTuple = self.resolveComponentRefreshResult(resultType)
            
            //If refresh Component Fails...
            guard refreshResultTuple.refreshError == nil else {
                onCompletion(resultType)
                return
            }
            
            guard let refreshResponse = refreshResultTuple.refreshResponse else {
                //Should never occur ...
                // At this point Both Refresh Error and Refresh Response are NIL
                let unknownErrMsg = "Refresh failed due to unknown reason !"
                let unknownError = ZCRMError.InValidError(code: .INTERNAL_ERROR, message: unknownErrMsg)
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
                
                guard self.didSetComponentProperties(of: newCompObj, to: oldCompObj)
                    else {
                        // transferring new db props to old one failed !
                        let errorMsg = "Refresh Failed ! Unable to set Comp Properties"
                        let propertySetError =
                            ZCRMError.ProcessingError(code: .INTERNAL_ERROR, message: errorMsg)
                        onCompletion(.failure(propertySetError))
                        return
                }
                
                // Component Refresh and Get succeeded ...
                onCompletion(.success(refreshResponse))
                
            } // New Component Get Completion ends
            
        } // Component Refresh completion ends
        
    } // RefreshComponentForObject  ends
    
    
    func refreshDashboardForObject(_ oldDashBoardObj:ZCRMDashboard,
                                   onCompletion: @escaping refreshResponse) {
        
        let dbID = oldDashBoardObj.getId()
        let URLPath = "/\(URLPathName.ANALYTICS)/\(dbID)/\(URLPathName.REFRESH)"
        setUrlPath(urlPath: URLPath)
        setRequestMethod(requestMethod: .POST)
        setJSONRootKey(key: JSONRootKey.DATA)
        let request = APIRequest(handler: self)
        
        // API CALL 1 : REFRESH DASHBOARD WITH ID
        request.getAPIResponse { (refreshResult) in
            
            let refreshResultTuple = self.resolveDashBoardRefreshResult(refreshResult)
            
            //If refresh dashBoard fails .. pass the result
            guard refreshResultTuple.refreshError == nil else {
                onCompletion(refreshResult)
                return
            }
            
            guard let refreshResponse = refreshResultTuple.refreshResponse else {
                //Should never occur ...
                // At this point Both Refresh Error and Refresh Response are NIL
                let unknownErrMsg = "Refresh failed due to unknown reason !"
                let unknownError = ZCRMError.InValidError(code: .INTERNAL_ERROR, message: unknownErrMsg)
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
                
                guard self.didSetDashBoardProperties(of: newDashBoard, to: oldDashBoardObj) else {
                    // transferring new db props to old one failed !
                    let errorMsg = "Refresh Failed ! Unable to set dashBoard Properties"
                    let propertySetError =
                        ZCRMError.ProcessingError(code: .INTERNAL_ERROR, message: errorMsg)
                    
                    onCompletion(.failure(propertySetError))
                    return
                }
                
                // Refresh and getDashBoard succeeds ...
                onCompletion(.success(refreshResponse))
                return
                
            } // getDashBoard completion
            
        } // API Response completion
        
    } // func ends
    
    
    func getDashboardComponentColorThemes(onCompletion: @escaping ArrayOfColorThemes) {
        
        let URLPath = "/\(URLPathName.ANALYTICS)/\(URLPathName.COLORTHEMES)"
        setUrlPath(urlPath: URLPath)
        setRequestMethod(requestMethod: .GET)
        setJSONRootKey(key: JSONRootKey.NILL)
        let request = APIRequest(handler: self)
        request.getAPIResponse { (resultType) in
            do{
                let APIResponse = try resultType.resolve()
                let colorThemesResponseJSON = APIResponse.getResponseJSON() //[String:Any]
                let colorThemesJSON = colorThemesResponseJSON.getArrayOfDictionaries(key: colorPaletteAPINames.colorThemes)
                let ArrayOfcolorThemes = self.getArrayOfZCRMDashboardComponentColorThemes(colorThemesJSON)
                onCompletion(.success(ArrayOfcolorThemes,APIResponse))
            } catch {
                onCompletion(.failure(typeCastToZCRMError(error)))
            }
            
        } // Completion
        
    } // func ends
    
} // extension ends


//MARK:- Refresh Handler Helper functions
fileprivate extension DashboardAPIHandler {
    
    //MARK:- Dashboard Refresh Helper Functions
    
    func resolveDashBoardRefreshResult(_ refreshResult: Result.Response<APIResponse>) -> (refreshResponse: APIResponse?,refreshError: ZCRMError?) {
        
        do {
            let APIResponseObj = try refreshResult.resolve()
            
            // API call 1 -> Refreshes DashBoard Failed
            guard APIResponseObj.getStatus() == self.refreshSuccess else {
                let errorObj = ZCRMError.SDKError(code: .INTERNAL_ERROR, message: "Refresh Failed!")
                return (nil, errorObj)
            }
            
            return (APIResponseObj,nil)
            
        } catch let refreshError {
            // API call 1 -> Refreshes DashBoard Failed
            return (nil,typeCastToZCRMError(refreshError))
        }
        
    } // func ends
    
    
    
    func resolveDashboardGetResult(_ resultType: dashboardResult) ->
        (ZCRMDashboard?,ZCRMError?) {
            
            do {
                let result = try resultType.resolve()
                let dashBoardObj = result.data
                return (dashBoardObj,nil)
            } catch let error {
                print("Refresh Failed ! Reason: \(error)")
                return (nil,typeCastToZCRMError(error))
            }
            
    } // func ends
    
    
    
    func didSetDashBoardProperties(of refreshedDashboard:ZCRMDashboard?,
                                   to oldDashBoard: ZCRMDashboard) -> Bool {
        
        guard let refreshedDashboard = refreshedDashboard else {
            return false
        }
        
        let id = refreshedDashboard.getId()
        let name = refreshedDashboard.getName()
        let accessType = refreshedDashboard.getAccessType()
        let isSalesTrend = refreshedDashboard.getIfSalesTrend()
        let isSystemGenerated = refreshedDashboard.getIfSystemGenerated()
        
        guard let arrayOfDashboardMetaComponent =
            refreshedDashboard.getArrayOfDashBoardComponentMeta() else {
                print("Dashboard Refresh Failed! New dashboard Meta Components are nil ")
                return false
        }
        
        print("NEW DASH DAWW \(refreshedDashboard)")
        
        oldDashBoard.setId(id: id)
        oldDashBoard.setName(name: name)
        oldDashBoard.setAccessTypeAs(accessType)
        oldDashBoard.setIfSalesTrend(isSalesTrend)
        oldDashBoard.setIfSystemGenerated(isSystemGenerated)
        oldDashBoard.setArrayOfDashBoardComponentMeta(arrayOfDashboardMetaComponent)
        return true
        
    }
    
    //MARK:- Component Refresh Helper functions
    
    func resolveComponentRefreshResult(_ refreshResult: Result.Response<APIResponse>) ->
        (refreshResponse: APIResponse?,refreshError: ZCRMError?) {
            
            do {
                let APIResponseObj = try refreshResult.resolve()
                // API call 1 -> Refresh Component Failed
                guard APIResponseObj.getStatus() == self.refreshSuccess else {
                    let errorObj = ZCRMError.SDKError(code: .INTERNAL_ERROR, message: "Refresh Failed!")
                    return (nil, errorObj)
                }
                
                return (APIResponseObj,nil)
                
            } catch let refreshError {
                // API call 1 -> Refreshes Component Failed
                return (nil,typeCastToZCRMError(refreshError))
            }
            
    } // func ends
    
    
    func resolveComponentGetResult(_ resultType: componentResult) ->
        (ZCRMDashboardComponent?, ZCRMError?) {
            
            do {
                let result = try resultType.resolve()
                let compObj = result.data
                return (compObj,nil)
            } catch let error {
                print("Refresh Failed ! Reason: \(error)")
                return (nil,typeCastToZCRMError(error))
            }
            
    } // func ends
    
    
    func didSetComponentProperties(of refreshedComp: ZCRMDashboardComponent?,
                                   to oldComp: ZCRMDashboardComponent) -> Bool {
        
        guard let refreshedComp = refreshedComp else {
            return false
        }
        
        let name = refreshedComp.getName()
        let cmpId = refreshedComp.getComponentId()
        let dbId = refreshedComp.getDashboardId()
        let category = refreshedComp.getCategory()
        let type = refreshedComp.getType()
        let objective = refreshedComp.getObjective()
        let reportID = refreshedComp.getReportID()
        let segmentRanges = refreshedComp.getSegmentRanges()
        let colorPaletteName = refreshedComp.getColorPaletteName()
        let colorPaletteIndex = refreshedComp.getColorPaletteStartingIndex()
        let componentMarkers = refreshedComp.getComponentMarkers()
        let maxRows = refreshedComp.getMaximumRows()
        let compChunks = refreshedComp.getComponentChunks()
        let lastFetchedLabel = refreshedComp.getLastFetchedTimeLabel()
        let lastFetchedValue = refreshedComp.getLastFetchedTimeValue()
        
        oldComp.setName(name: name)
        oldComp.setComponentId(id: cmpId)
        oldComp.setDashboardId(id: dbId)
        oldComp.setCategory(category: category)
        oldComp.setType(type: type)
        oldComp.setObjective(objective: objective)
        oldComp.setReportId(reportId: reportID)
        oldComp.setSegmentRanges(ranges: segmentRanges)
        oldComp.setColorPaletteName(name: colorPaletteName)
        oldComp.setColorPaletteStartingIndex(index: colorPaletteIndex)
        oldComp.setComponentMarkers(markers: componentMarkers)
        oldComp.setMaximumRows(rows: maxRows)
        oldComp.setLastFetchedTimeLabel(label: lastFetchedLabel)
        oldComp.setLastFetchedTimeValue(value: lastFetchedValue)
        
        compChunks.forEach { (chunk) in
            oldComp.addComponentChunks(chunks: chunk)
        }
        
        return true
        
    } // func ends
    
    
} // end of extension


//MARK:- HANDLER PARSING FUNCTIONS
//MARK:-

fileprivate extension DashboardAPIHandler {
    
    //MARK: *** DASHBOARD PARSERS ***
    
    func getZCRMDashboardObjectFrom(_ dashBoardJSON: [String:Any] ) -> ZCRMDashboard? {
        
        guard let id = dashBoardJSON.optInt64(key: dashBoardAPINames.dashboardID),
            let name = dashBoardJSON.optString(key: dashBoardAPINames.dashboardName) else {
                return nil
        }
        
        let dashBoardObj = ZCRMDashboard(id: id, name: name)
        
        dashBoardObj.setId(id: id)
        dashBoardObj.setName(name: name)
        
        if let isSalesTrend = dashBoardJSON.optBoolean(key: dashBoardAPINames.isSalesTrends) {
            dashBoardObj.setIfSalesTrend(isSalesTrend)
        }
        
        if let accessType = dashBoardJSON.optString(key: dashBoardAPINames.accessType){
            dashBoardObj.setAccessTypeAs(accessType)
        }
        
        if let arrayOfMetaComponent = getArrayOfZCRMDashboardComponentMeta(From: dashBoardJSON){
            dashBoardObj.setArrayOfDashBoardComponentMeta(arrayOfMetaComponent)
        }
        
        return dashBoardObj
    }
    
} // end of extension


fileprivate extension DashboardAPIHandler {
    
    //MARK:- *** DASHBOARD META-COMPONENT PARSERS  ***
    
    func getArrayOfZCRMDashboardComponentMeta(From dashBoardJSON:[String:Any]) -> [ZCRMDashboardComponentMeta]? {
        
        let metaComponentAPIName = ZCRMDashboard.Properties.ResponseJSONKeys.metaComponents
        
        guard let arrayOfMetaComponentJSON = dashBoardJSON.optArrayOfDictionaries(key: metaComponentAPIName) else {
            if dashBoardJSON.hasKey(forKey: metaComponentAPIName) {
                print("Failed to get arrayOfMetaComponentJSON from dashBoardJSON !")
            }
            return nil
        }
        
        var metaComponentObjArray = [ZCRMDashboardComponentMeta]()
        for dashBoardMetaComponentJSON in arrayOfMetaComponentJSON {
            let metaComponentObj = getDashboardMetaComponentFrom(dashBoardMetaComponentJSON)
            metaComponentObjArray.append(metaComponentObj)
        }
        return metaComponentObjArray
    }
    
    
    
    
    func getDashboardMetaComponentFrom(_ metaComponentJSON:[String:Any]) -> ZCRMDashboardComponentMeta {
        
        let metaComponentObj = ZCRMDashboardComponentMeta()
        let id = metaComponentJSON.optInt64(key: metaComponentAPINames.componentID)
        metaComponentObj.setid(id: id)
        
        let Name = metaComponentJSON.optString(key: metaComponentAPINames.componentName)
        metaComponentObj.setName(name: Name)
        
        if let isFavourite = metaComponentJSON.optBoolean(key: metaComponentAPINames.favouriteComponent){
            metaComponentObj.setIfFavourite(isFavourite)
        }
        
        let isSystemGenerated = metaComponentJSON.optBoolean(key: metaComponentAPINames.systemGenerated)
        metaComponentObj.setIfSystemGenerated(isSystemGenerated)
        
        let JSONlayoutValues =
            getDashboardMetaComponentLayoutPropsFrom(metaComponentJSON)
        var metaComponentLayoutObj = metaComponentObj.getLayoutProperties()
        metaComponentLayoutObj.setComponentXPosition(position: JSONlayoutValues?.xPosition)
        metaComponentLayoutObj.setComponentYPosition(position: JSONlayoutValues?.yPosition)
        metaComponentLayoutObj.setComponentWidth(width: JSONlayoutValues?.width)
        metaComponentLayoutObj.setComponentHeight(height: JSONlayoutValues?.height)
        metaComponentObj.setLayoutProperties(metaComponentLayoutObj)
        return metaComponentObj
    }
    
    
    
    func getDashboardMetaComponentLayoutPropsFrom(_ metaComponentJSON:[String:Any]) -> MetaComponentLayoutPropsTuple?
    {
        var width:Int?
        var height:Int?
        var xPosition:Int?
        var yPosition:Int?
        
        guard let itemPropsJSON =
            metaComponentJSON.optDictionary(key: metaComponentAPINames.itemProps) else {
                print("Failed to get itemPropsJSON from metaComponentJSON ")
                return nil
        }
        
        guard let layoutJSON = itemPropsJSON.optDictionary(key: metaComponentAPINames.layout) else {
            print("Failed to get LayoutJSONDict From ItemPropsJSON ")
            return nil
        }
        
        width = Int(layoutJSON.optString(key: metaComponentAPINames.componentWidth) ?? "default")
        height = Int(layoutJSON.optString(key: metaComponentAPINames.componentHeight) ?? "default")
        xPosition = Int(layoutJSON.optString(key: metaComponentAPINames.componentXPosition) ?? "default")
        yPosition = Int(layoutJSON.optString(key: metaComponentAPINames.componentYPosition) ?? "default")
        
        return (width: width, height: height, xPosition: xPosition, yPosition: yPosition)
    }
    
} // Extension ends



fileprivate extension DashboardAPIHandler {
    
    //MARK:- *** DASHBOARD COMPONENT PARSERS ***
    func getDashboardComponentFrom(_ componentJSON: [String:Any],
                                   Using cmpId: Int64,
                                   And dbId: Int64) -> ZCRMDashboardComponent? {
        
        
        let componentName = componentJSON.optString(key: componentAPINames.componentName)
        
        let componentCategoryString = componentJSON.optString(key: componentAPINames.componentCategory)
        let componentCategoryEnum = CompCategory(rawValue: componentCategoryString ?? "default")
        
        guard let name = componentName, let category = componentCategoryEnum else {
            return nil
        }
        
        let componentObj = ZCRMDashboardComponent(cmpId: cmpId, name: name, dbId: dbId)
        
        componentObj.setCategory(category: category)
        
        let reportID = componentJSON.optInt64(key: componentAPINames.reportID)
        componentObj.setReportId(reportId: reportID)
        
        
        if let arrayOfComponentMarkersObj = getComponentMarkersFrom(componentJSON) {
            componentObj.setComponentMarkers(markers: arrayOfComponentMarkersObj)
        }
        
        let ArrayOfComponentChunksJSON = componentJSON.optArrayOfDictionaries(key: componentAPINames.componentChunks)
        setComponentChunksValues(To: componentObj, Using: ArrayOfComponentChunksJSON)
        
        if let lastFetchedTimeJSON = componentJSON.optDictionary(key: componentAPINames.lastFetchedTime) {
            
            if let lastFetchedTime = getLastFetchedTimeUsing(lastFetchedTimeJSON) {
                componentObj.setLastFetchedTimeLabel(label: lastFetchedTime.Label)
                componentObj.setLastFetchedTimeValue(value: lastFetchedTime.Value)
            }
        }
        
        setComponentPropertiesFor(componentObj, Using: componentJSON)
        return componentObj
    } // func ends
    
    
    
    func getLastFetchedTimeUsing(_ lastFetchedTimeJSON:[String:Any]) -> (Label:String,Value:String)? {
        
        guard let lastFetchedTimeLabel = lastFetchedTimeJSON.optString(key: componentAPINames.label),
            let lastFetchedTimeValue = lastFetchedTimeJSON.optString(key: componentAPINames.value) else {
                
                print("Last Fetched Time Parsing Failed ! Found NIL Values ...")
                return nil
        }
        return (lastFetchedTimeLabel,lastFetchedTimeValue)
        
    } // func ends
    
    
    func getComponentMarkersFrom(_ componentJSON:[String:Any]) -> [ComponentMarkers]? {
        
        let Key = componentAPINames.componentMarker
        
        guard componentJSON.hasKey(forKey: Key) else { return nil }
        
        guard let ArrayOfCompMarkerJSON = componentJSON.optArrayOfDictionaries(key: Key) else {
            
            print("Failed to get ArrayOfCompMarkerJSON From ComponentJSON")
            return nil
        }
        
        var ArrayOfComponentMarkerObj = [ComponentMarkers]()
        var x:String? // can be User ID (Int64) or pickListValue (String)
        var y:Int?
        
        for compMarkersJSON  in ArrayOfCompMarkerJSON {
            x = compMarkersJSON.optString(key: componentAPINames.componentMarkerXPosition)
            y = compMarkersJSON.optInt(key: componentAPINames.componentMarkerYPosition)
            
            if let componentMarkerObj = constructComponentMarkerFrom(xValue: x, yValue: y) {
                ArrayOfComponentMarkerObj.append(componentMarkerObj)
            }
        } // loop ends
        return ArrayOfComponentMarkerObj
    }
    
    
    
    func constructComponentMarkerFrom(xValue: String?,yValue: Int?) -> ComponentMarkers? {
        let debugMsg = """
        
        UNABLE TO CONSTRUCT COMPONENT MARKER OBJECT
        xValue: \(xValue ?? "NILL")
        yValue: \(String(describing: yValue))
        
        """
        guard let yValue = yValue else {
            print(debugMsg.lowercased())
            return nil
        }
        return ComponentMarkers(x: xValue, y: yValue)
    } // func ends
    
    
    
    func setComponentPropertiesFor(_ componentObject:ZCRMDashboardComponent,
                                   Using componentJSON: [String:Any]) {
        
        let Key = componentAPINames.componentProps
        
        guard componentJSON.hasKey(forKey: Key) else {
            print("Component JSON has no key named \(Key) Returning ...")
            return
        }
        
        guard let componentPropsJSON = componentJSON.optDictionary(key: Key) else {
            print("Failed to get componentPropsJSON from componentJSON !")
            return
        }
        
        if let objectiveString = componentPropsJSON.optString(key: componentAPINames.objective) {
            let objectiveEnum = CompObjective(rawValue: objectiveString)
            componentObject.setObjective(objective: objectiveEnum)
        }
        if let maximumRows = componentPropsJSON.optInt(key: componentAPINames.maximumRows) {
            componentObject.setMaximumRows(rows: maximumRows)
        }
        setVisualizationPropertiesFor(componentObject: componentObject,
                                      Using: componentPropsJSON)
    } // func ends
    
    
    //MARK:- COMPONENT VISUALIZATION PROPERTIES
    
    func setVisualizationPropertiesFor(componentObject:ZCRMDashboardComponent,
                                       Using componentPropsJSON: [String:Any]) {
        
        let Key = componentAPINames.visualizationProps
        
        guard componentPropsJSON.hasKey(forKey: Key) else {
            print("Component Props JSON has no key named \(Key) Returning ...")
            return
        }
        
        guard let visualizationPropsJSON = componentPropsJSON.optDictionary(key: Key ) else {
            print("Failed to get visualizationPropsJSON from componentPropsJSON !")
            return
        }
        
        let componentType = visualizationPropsJSON.optString(key: componentAPINames.componentType)
        componentObject.setType(type: componentType)
        
        let ArrayOfSegmentRangeObj = getArrayOfSegmentRangesFrom(visualizationPropsJSON)
        componentObject.setSegmentRanges(ranges: ArrayOfSegmentRangeObj)
        
        if let colorPaletteTuple = getColorPaletteFrom(visualizationPropsJSON){
            componentObject.setColorPaletteName(name: colorPaletteTuple.name)
            componentObject.setColorPaletteStartingIndex(index: colorPaletteTuple.index)
        }
        
    } // func ends
    
    
    
    func getArrayOfSegmentRangesFrom(_ visualizationPropsJSON: [String:Any]) ->
        [CompSegmentRanges]? {
            
            let Key = componentAPINames.segmentRanges
            
            guard visualizationPropsJSON.hasKey(forKey: Key) else {
                return nil
            }
            
            guard let ArrayOfSegmentRangesJSON = visualizationPropsJSON.optArrayOfDictionaries(key: Key) else {
                print("Failed to get ArrayOfSegmentRangesJSON From visualizationPropsJSON")
                return nil
            }
            
            var ArrayOfSegmentRangeObj = [CompSegmentRanges]()
            
            var SegmentStartPos:String?
            var SegmentEndPos:String?
            var SegmentColor:String?
            
            for segmentRangesJSON in ArrayOfSegmentRangesJSON {
                
                SegmentStartPos = segmentRangesJSON.optString(key: componentAPINames.segmentStarts)
                SegmentEndPos = segmentRangesJSON.optString(key: componentAPINames.segmentEnds)
                SegmentColor = segmentRangesJSON.optString(key: componentAPINames.segmentColor)
                
                let Tuple = (SegmentColor,SegmentStartPos,SegmentEndPos)
                
                if let segmentRangesObj = constructSegmentRangesObjectFrom(Tuple) {
                    ArrayOfSegmentRangeObj.append(segmentRangesObj)
                }
                
            } // Loop ends
            return ArrayOfSegmentRangeObj
            
    } // function ends
    
    
    
    func constructSegmentRangesObjectFrom(_ Tuple:SegmentRangesTuple) -> CompSegmentRanges? {
        
        let debugMsg = "UNABLE TO CONSTRUCT SEGMENT RANGES OBJECT FROM TUPLE".lowercased()
        
        guard var startPosPercent = Tuple.startPos, var endPosPercent = Tuple.endPos else {
            print(debugMsg.lowercased())
            return nil
        }
        // Removing % and converting to number
        startPosPercent.removeLast()
        endPosPercent.removeLast()
        
        let startPosInt =  Int(startPosPercent)
        let endPosInt = Int(endPosPercent)
        
        guard let color = Tuple.color,
            let startPos = startPosInt,
            let endPos = endPosInt else {
                print(debugMsg.lowercased())
                print("REASON: Found NIL Values")
                return nil
        }
        return CompSegmentRanges(color: color, startPos: startPos, endPos: endPos)
    } // func ends
    
    
    func getColorPaletteFrom(_ visualizationPropsJSON: [String:Any]) -> (name:colorPalette,index:Int)? {
        
        let Key = componentAPINames.colorPalette
        
        guard visualizationPropsJSON.hasKey(forKey: Key) else {
            return nil
        }
        
        guard let colorPaletteJSON = visualizationPropsJSON.optDictionary(key: Key) else {
            print("Failed to get colorPaletteJSON from visualizationPropsJSON ")
            return nil
        }
        // colorpaltte Name
        let colorPaletteName = colorPaletteJSON.optString(key: componentAPINames.colorPaletteName)
        let colorPaletteNameEnum = colorPalette(rawValue: colorPaletteName ?? "default")
        // starting index
        let colorPaletteStartingIndex = colorPaletteJSON.optInt(key: componentAPINames.colorPaletteStartingIndex)
        
        guard let name = colorPaletteNameEnum , let index = colorPaletteStartingIndex else {
            let debugMsg = """
            
            UNABLE TO EXTRACT COLOR PALETTE VALUES FROM JSON
            Palette Name: \(colorPaletteName ?? "NILL"),
            Palette StartingIndex: \(String(describing: colorPaletteStartingIndex)),
            
            """
            print(debugMsg.lowercased())
            return nil
        }
        return (name,index)
    } // func ends
    
    
    //MARK:- COMPONENT CHUNKS
    func setComponentChunksValues(To componentObj:ZCRMDashboardComponent,
                                  Using chunks: [[String:Any]]?) {
        
        guard let ArrayOfComponentChunksJSON = chunks else {
            print("FAILED TO GET COMPONENT CHUNKS [STRING:ANY]".lowercased())
            return
        }
        
        var componentChunkValues = [ComponentChunkKeys:Any]()
        
        for componentChunksJSON in ArrayOfComponentChunksJSON {
            
            let aggregateColumn = getArrayOfAggregateColumnInfo(Using: componentChunksJSON)
            componentChunkValues[.aggregateColumn] = aggregateColumn
            
            let groupingColumn = getArrayOfGroupingColumnInfo(Using: componentChunksJSON)
            componentChunkValues[.groupingColumn] = groupingColumn
            
            let verticalGrouping = getArrayOfVerticalGrouping(Using: componentChunksJSON)
            componentChunkValues[.verticalGrouping] = verticalGrouping
            
            componentChunkValues[.name] = componentChunksJSON.optString(key: componentAPINames.name)
            componentChunkValues[.properties] = setComponentChunkPropertiesUsing(componentChunksJSON)
            
            if let componentChunksObj = constructComponentChunksObjFrom(componentChunkValues)
            {
                componentObj.addComponentChunks(chunks: componentChunksObj)
                componentChunkValues.removeAll()
            }
            
        } // outer loop ends
    } // func ends
    
    
    func setComponentChunkPropertiesUsing(_ componentChunksJSON:[String:Any] ) -> [ComponentChunkPropKeys:Any]? {
        
        let Key = componentAPINames.componentProps
        
        guard componentChunksJSON.hasKey(forKey: Key) else {
            print("componentChunksJSON has no key named \(Key). Returning ...")
            return nil
        }
        
        guard let componentChunkPropsJSON = componentChunksJSON.optDictionary(key: Key) else {
            if componentChunksJSON.hasKey(forKey: Key) {
                print("Unable to get componentChunkPropsJSON From componentChunksJSON")
            }
            return nil
        }
        
        var componentChunkPropValues = [ComponentChunkPropKeys:Any]()
        
        for (key,value) in componentChunkPropsJSON {
            switch (key) {
                
            case componentAPINames.objective:
                componentChunkPropValues[.objective] = value
                
            // More could appear in the future ..
            default:
                print("ADD KEY \(key) TO COMPONENT CHUNK PROPERTIES PARSING !".lowercased())
                
            }
        }
        return componentChunkPropValues
    }
    
    
    func constructComponentChunksObjFrom(_ dict:[ComponentChunkKeys:Any]) -> ComponentChunks? {
        
        let debugMsg = """
        
        UNABLE TO CONSTRUCT COMPONENT CHUNK OBJ FROM VALUES
        REASON:- TypeCast to native types from Any failed !
        
        Vertical Grouping: \(dict[.verticalGrouping] ?? "NILL"),
        Aggregate Column: \(dict[.aggregateColumn] ?? "NILL"),
        Grouping Column: \(dict[.groupingColumn] ?? "NILL"),
        
        """
        guard let ArrayOfVerticalGrouping = dict[.verticalGrouping] as? [VerticalGrouping],
            let ArrayOfAggregateColumn = dict[.aggregateColumn] as? [AggregateColumn],
            let ArrayOfGroupingColumn = dict[.groupingColumn] as? [GroupingColumn] else {
                
                print(debugMsg.lowercased())
                return nil
                
        }
        
        var componentChunksObj = ComponentChunks()
        
        for verticalObj in ArrayOfVerticalGrouping {
            componentChunksObj.addVerticalGrouping(verticalObj)
        }
        for aggregateObj in ArrayOfAggregateColumn {
            componentChunksObj.addAggregateColumnInfo(aggregateObj)
        }
        for groupingObj in ArrayOfGroupingColumn {
            componentChunksObj.addGroupingColumnInfo(groupingObj)
        }
        if let componentName = dict[.name] as? String {
            componentChunksObj.setName(name: componentName)
        }
        
        // Parsing out Component Chunk Component Properties
        if let componentChunkPropsDict = dict[.properties] as? [ComponentChunkPropKeys:Any]
        {
            if let objectiveString = componentChunkPropsDict[.objective] as? String {
                let objective =  CompObjective(rawValue: objectiveString)
                componentChunksObj.setObjective(objective: objective)
            }
        }
        return componentChunksObj
    }
    
    
    //MARK:- AGGREGATE COLUMN INFO
    func getArrayOfAggregateColumnInfo(Using componentChunksJSON: [String:Any] ) -> [AggregateColumn]? {
        
        let Key = componentAPINames.aggregateColumn
        
        guard componentChunksJSON.hasKey(forKey: Key) else {
            print("componentChunksJSON has no key named \(Key). Returning ...")
            return nil
        }
        
        guard let ArrayOfAggregateColumnJSON = componentChunksJSON.optArrayOfDictionaries(key: Key) else {
            print("Failed to get ArrayOfAggregateColumnJSON From componentChunksJSON  ")
            return nil
        }
        
        // Keys are of Enum Type to avoid typos at set and get sites
        var aggregateColValues = [AggregateColumnKeys:Any]()
        var ArrayOfAggregateColumnObj = [AggregateColumn]()
        
        for aggregateColumnJSON in ArrayOfAggregateColumnJSON {
            
            for (key,value) in aggregateColumnJSON {
                
                switch (key) {
                    
                case componentAPINames.label:
                    aggregateColValues[.label] = value
                    
                case componentAPINames.type:
                    aggregateColValues[.type] = value
                    
                case componentAPINames.name:
                    aggregateColValues[.name] = value
                    
                case componentAPINames.decimalPlaces:
                    aggregateColValues[.decimalPlaces] = value
                    
                case componentAPINames.aggregations:
                    aggregateColValues[.aggregation] = value
                    
                default:
                    print("UNKNOWN KEY \(key) ENCOUNTERED IN COMPONENT AGGREGATE COLUMN PARSING".lowercased())
                    
                } // switch case ends
            } // inner loop ends
            
            if let aggregateColObj = constructAggregateColumnObjFrom(aggregateColValues)
            {
                ArrayOfAggregateColumnObj.append(aggregateColObj)
                aggregateColValues.removeAll()
            }
        } // outer loop ends
        return ArrayOfAggregateColumnObj
    } // func ends
    
    
    func constructAggregateColumnObjFrom(_ dict:[AggregateColumnKeys:Any] ) -> AggregateColumn? {
        let debugMsg = """
        
        UNABLE TO CONSTRUCT AGGREAGTE COLUMN OBJECT FROM VALUES
        
        Label: \(dict[.label] ?? "NILL"),
        Type: \(dict[.type] ?? "NILL"),
        Name: \(dict[.name] ?? "NILL"),
        Decimal Places: \(String(describing: dict[.decimalPlaces])),
        Aggregates: \(dict[.aggregation] ?? ["NILL"])
        
        """
        
        let decimalPlaces = dict.optInt(key: .decimalPlaces)
        
        if dict.hasKey(forKey: .decimalPlaces) && decimalPlaces == nil {
            print("Decimal Places Parsing in Aggregate Column FAILED !! \(String(describing: dict[.decimalPlaces]))")
        }
        
        if  let label = dict.optString(key: .label),
            let type = dict.optString(key: .type),
            let name = dict.optString(key: .name),
            let aggregation = dict[.aggregation] as? [String] {
            
            return AggregateColumn(label: label,
                                   type: type,
                                   name: name,
                                   decimalPlaces: decimalPlaces,
                                   aggregation: aggregation)
        }
        print(debugMsg.lowercased())
        return nil
    }
    
    
    //MARK:- GROUPING COLUMN INFO
    func getArrayOfGroupingColumnInfo(Using componentChunksJSON: [String:Any]) -> [GroupingColumn]? {
        
        let Key = componentAPINames.groupingColumn
        
        guard let ArrayOfGroupingColumnJSON = componentChunksJSON.optArrayOfDictionaries(key: Key) else {
            
            print("Unable to get ArrayOfGroupingColumnJSON From componentChunksJSON  ")
            return nil
        }
        
        var groupingColumnValues = [GroupingColumnKeys:Any]()
        var ArrayOfGroupingColumnObj = [GroupingColumn]()
        
        for groupingColumnJSON in ArrayOfGroupingColumnJSON {
            
            for (key,value) in groupingColumnJSON {
                
                switch (key) {
                    
                case componentAPINames.label:
                    groupingColumnValues[.label] = value
                    
                case componentAPINames.type:
                    groupingColumnValues[.type] = value
                    
                case componentAPINames.name:
                    groupingColumnValues[.name] = value
                    
                case componentAPINames.groupingConfig:
                    if let groupingConfigTuple = getGroupingConfigValuesFrom(groupingColumnJSON) {
                        groupingColumnValues[.allowedValues] = groupingConfigTuple.AllowedValues
                        groupingColumnValues[.customGroups] = groupingConfigTuple.CustomGroups
                    }
                    
                default:
                    print("UNKNOWN KEY \(key) ENCOUNTERED IN GROUPING COLUMN PARSING".lowercased())
                }
            } // inner loop
            
            if let groupingColumnObj = constructGroupingColumnObjFrom(groupingColumnValues) {
                ArrayOfGroupingColumnObj.append(groupingColumnObj)
                groupingColumnValues.removeAll()
            }
        } // outer loop
        return ArrayOfGroupingColumnObj
    } // func ends
    
    
    //
    func constructGroupingColumnObjFrom(_ dict:[GroupingColumnKeys:Any]) -> GroupingColumn? {
        
        // They might or might not exist in JSON
        let allowedValues = dict[.allowedValues] as? [AllowedValues]
        let customGroups = dict[.customGroups] as? [String]
        
        // If they exist in JSON and still end up with NIL values ...
        if dict.hasKey(forKey: .allowedValues) && allowedValues == nil {
            
            print("Allowed Values Parsing in Grouping Column FAILED !! \(String(describing: dict[.allowedValues]))")
        }
        
        if dict.hasKey(forKey: .customGroups) && customGroups == nil {
            
            print("Custom Groups Parsing in Grouping Column FAILED !! \(String(describing: dict[.customGroups]))")
        }
        
        if  let label = dict.optString(key: .label),
            let type = dict.optString(key: .type),
            let name = dict.optString(key: .name) {
            
            return GroupingColumn(label: label,
                                  type: type,
                                  name: name,
                                  allowedValues: allowedValues,
                                  customGroups: customGroups)
        }
        
        //optional binding fails....
        let debugMsg = """
        
        UNABLE TO CONSTRUCT GROUPING COLUMN OBJECT FROM VALUES
        
        Label: \(dict[.label] ?? "NILL"),
        Type: \(dict[.type] ?? "NILL"),
        Name: \(dict[.name] ?? "NILL"),
        Allowed Values: \(dict[.allowedValues] ?? "NILL"),
        Custom Groups: \(dict[.customGroups] ?? ["NILL"])
        
        """
        print(debugMsg.lowercased())
        return nil
    }
    
    
    func getGroupingConfigValuesFrom(_ groupingColumnJSON:[String:Any])-> GroupingConfig? {
        
        guard let groupingConfigJSON = groupingColumnJSON.optDictionary(key: componentAPINames.groupingConfig) else {
            print("Failed to get groupingConfigJSON from groupingColumnJSON  ")
            return nil
        }
        
        var ArrayOfAllowedValues: [AllowedValues]?
        var ArrayOfCustomGroups: [String]?
        
        for (key,value) in groupingConfigJSON {
            
            switch (key) {
                
            case componentAPINames.allowedValues:
                ArrayOfAllowedValues = getArrayOfAllowedValuesObjFrom(value as? [[String:Any]])
                
            case componentAPINames.customGroups:
                ArrayOfCustomGroups = value as? [String]
                
                if ArrayOfCustomGroups == nil {
                    print("UNABLE TO PARSE CUSTOM GROUPS IN GROUPING COL INFO ")
                }
                
            default:
                print("UNKNOWN KEY \(key) ENCOUNTERED IN GROUPING COL CONFIG PARSING")
                
            } // switch ends
        } // inner loop
        return (ArrayOfAllowedValues,ArrayOfCustomGroups)
    } // func ends
    
    
    func getArrayOfAllowedValuesObjFrom(_ ArrayOfAllowedValuesJSON: [[String:Any]]?) -> [AllowedValues]? {
        
        var ArrayOfAllowedValuesObj = [AllowedValues]()
        
        guard let ArrayOfAllowedValuesJSON = ArrayOfAllowedValuesJSON else {
            print("UNABLE TO TYPECAST ALLOWED VALUES TO [STRING:ANY]".lowercased())
            return nil
        }
        
        // AV-> AllowedValue
        var AVlabel:String?
        var AVvalue:String?
        
        for allowedValuesJSON in ArrayOfAllowedValuesJSON {
            
            AVlabel = allowedValuesJSON.optString(key: componentAPINames.label)
            AVvalue = allowedValuesJSON.optString(key: componentAPINames.value)
            
            if let allowedValues = constructAllowedValuesObjFrom(label: AVlabel, value: AVvalue) {
                ArrayOfAllowedValuesObj.append(allowedValues)
            }
        } // outer loop
        return ArrayOfAllowedValuesObj
    } // func ends
    
    
    func constructAllowedValuesObjFrom(label:String?,value:String?) -> AllowedValues? {
        
        if let label = label, let value = value {
            return AllowedValues(label: label, value: value)
        }
        let debugMsg =
        """
        UNABLE TO CONSTRUCT ALLOWED VALUES OBJECT
        Label: \(label ?? "NILL")
        Value: \(value ?? "NILL")
        
        """
        print(debugMsg.lowercased())
        return nil
    }
    
    
    //MARK:- VERTICAL GROUPING
    func getArrayOfVerticalGrouping(Using componentChunksJSON: [String:Any], _ ArrayOfVerticalGroupingJSONParam: [[String:Any]]? = nil ) -> [VerticalGrouping] {
        
        var ArrayOfVerticalGroupingJSON = [[String:Any]]()
        
        let ArrayOfVerticalJSONFromComponentChunks = componentChunksJSON.optArrayOfDictionaries(key: componentAPINames.verticalGrouping)
        
        if let ArrayOfVerticalJSONFromComponentChunks =  ArrayOfVerticalJSONFromComponentChunks {
            
            ArrayOfVerticalGroupingJSON = ArrayOfVerticalJSONFromComponentChunks
        }
        //This gets used during SubGrouping Recursion
        if let ArrayOfVerticalGroupingJSONParam =  ArrayOfVerticalGroupingJSONParam {
            
            ArrayOfVerticalGroupingJSON = ArrayOfVerticalGroupingJSONParam
        }
        
        var ArrayOfVerticalGroupingObj = [VerticalGrouping]()
        var verticalGroupingValues = [VerticalGroupingKeys:Any]()
        
        for verticalGroupingJSON in ArrayOfVerticalGroupingJSON {
            
            for (key,value) in verticalGroupingJSON {
                
                switch(key) {
                    
                case componentAPINames.label:
                    verticalGroupingValues[.label] = value
                    
                case componentAPINames.value:
                    verticalGroupingValues[.value] = value
                    
                case componentAPINames.key:
                    verticalGroupingValues[.key] = value
                    
                    // Matches Key in Vertical Grouping With DataMap Keys
                    let aggreagtes = getAggreagtesForVerticalGrouping(Key: value, Using: componentChunksJSON)
                    // Aggreagtes For Key are set here ..
                    verticalGroupingValues[.aggregate] = aggreagtes
                    
                case componentAPINames.subGrouping:
                    if value as? [[String:Any]] != nil { // If another SubGrouping Exists ...
                        verticalGroupingValues[.subGrouping] = value  // [[String:Any]]
                    }
                    
                default:
                    print("UNKNOWN KEY \(key) ENCOUNTERED IN VERTICAL GROUPING  PARSING".lowercased())
                    
                } // switch ends
                
            } // inner loop
            
            if let verticalGroupingObj = constructVerticalGroupingObjFrom(verticalGroupingValues,componentChunksJSON){
                
                ArrayOfVerticalGroupingObj.append(verticalGroupingObj)
                verticalGroupingValues.removeAll()
            }
        } // outer loop
        return ArrayOfVerticalGroupingObj
    } // func ends
    
    
    
    func constructVerticalGroupingObjFrom(_ dict: [VerticalGroupingKeys:Any], _ componentChunksJSON: [String:Any]) -> VerticalGrouping? {
        
        let debugMsg =
        """
        UNABLE TO CONSTRUCT VERTICAL GROUPING OBJECT
        Label: \(dict[.label] ?? "NILL")
        Value: \(dict[.value] ?? "NILL")
        Key: \(dict[.key] ?? "NILL")
        Aggregates: \(dict[.aggregate] ?? "NILL")
        subGrouping: \(dict[.subGrouping] ?? "NILL")
        
        """
        // Value can be 'null' so its not checked for non-optional type
        let value = dict[.value] as? String
        let DictLabel = dict[.label] as? String
        let sanitizedDictLabel = convertLabelToNoneIfHyphen(DictLabel) // '-' replaced by 'none'
        
        guard let label = sanitizedDictLabel,
            let key = dict[.key] as? String,
            let aggregates = dict[.aggregate] as? [Aggregate] else {
                
                print(debugMsg.lowercased())
                return nil
        }
        
        var ArrayOfSubgroupingObjs:[VerticalGrouping]?
        
        if dict.hasKey(forKey: .subGrouping) {
            
            guard let ArrayOfSubGroupingJSON = dict[.subGrouping] as? [[String:Any]] else {
                print(" VERTICAL GROUPING OBJECT CONSTRUCTION FAILED.\n UNABLE TO TYPECAST VERTICAL SUBGROUPING TO [[STRING:ANY]]".lowercased())
                return nil
            }
            
            ArrayOfSubgroupingObjs = getArrayOfVerticalGrouping(Using: componentChunksJSON, ArrayOfSubGroupingJSON)
        }
        
        let subGrouping = ArrayOfSubgroupingObjs ?? nil
        
        return VerticalGrouping(label: label,
                                value: value,
                                key: key,
                                aggregate: aggregates,
                                subGrouping: subGrouping)
        
    } // func ends
    
    
    func convertLabelToNoneIfHyphen(_ value: String?) -> String? {
        // Replaces Hyphens in label with 'none'
        guard let label = value else { return nil }
        
        if label == "-"  {
            return "none"
        } else {
            return value
        }
        
    } // func ends
    
    
    func getAggreagtesForVerticalGrouping(Key: Any,Using componentChunksJSON:[String:Any]) -> [Aggregate]? {
        
        var reason = "Default Reason Value (Vertical Groupuing getAggregates)"
        var debugMsg: String {
            
            return """
            UNABLE TO CONSTRUCT AGGREGATES FOR VERTICAL GROUPING KEY
            REASON: \(reason)
            """
        }
        guard let Key = Key as? String else {
            
            reason = "Unable to TypeCast Vertical Grouping Key to STRING"
            print(debugMsg.lowercased())
            return nil
            
        }
        
        let dataMapJSON = componentChunksJSON.getDictionary(key: componentAPINames.dataMap)
        
        for (dataMapkey,value) in dataMapJSON {
            
            if dataMapkey == Key {
                return getAggregatesObjFrom(mapKeyJSON: value)
            }
        } // end of loop
        
        reason = "AGGREAGATES NOT FOUND FOR GIVEN VERTICAL KEY \(Key)"
        print(debugMsg.lowercased())
        return nil
        
    } // func ends
    
    
    func getAggregatesObjFrom(mapKeyJSON:Any) -> [Aggregate]? {
        
        let debugMsg =
            
        """
        UNABLE TO CONSTRUCT AGGREGATE FOR VERTICAL GROUPING KEY
        REASON: Failed to typecast MapKeyJSON to [String:Any]

        """
        guard let mapKeyJSON = mapKeyJSON as? [String:Any] else {
            print(debugMsg.lowercased())
            return nil
        }
        // AG -> Aggreagtes
        var AGlabel:String?
        var AGvalue:String?
        var ArrayOfAggregatesObj = [Aggregate]()
        
        let ArrayOfAggreagatesJSON = mapKeyJSON.getArrayOfDictionaries(key: componentAPINames.aggregates)
        
        for aggreagatesJSON in ArrayOfAggreagatesJSON {
            
            for (key,value) in aggreagatesJSON {
                
                switch (key) {
                    
                case componentAPINames.label:
                    AGlabel = typeCastAggregate(Label: value)
                    
                case componentAPINames.value:
                    AGvalue = typeCastAggregate(Value: value)
                    
                default:
                    print("UNKNOWN KEY \(key) ENCOUNTERED IN DATA MAP AGGREGATES PARSING".lowercased())
                    
                } // switch key
                
            } // inner loop
            
            
            if let aggregatesObj = constructAggregatesObjFrom(AGlabel, AGvalue) {
                ArrayOfAggregatesObj.append(aggregatesObj)
            }
        } // outer loop
        return ArrayOfAggregatesObj
    }
    
    // If Double , typecast to Double and return it as String
    // Else typecast to String and return
    
    func typeCastAggregate(Label value:Any) -> String? {
        
        if let number = value as? Double {
            return String(number)
        }
        
        if value is NSNull {
            return "nil"
        }
        
        return value as? String
        
    } // func ends
    
    
    func typeCastAggregate(Value value:Any) -> String? {
        return typeCastAggregate(Label: value)
    }
    
    
    func constructAggregatesObjFrom(_ label:String?, _ value:String?) -> Aggregate? {
        
        let debugMsg =
            
        """
        UNABLE TO CONSTRUCT AGGREGATE FOR VERTICAL GROUPING KEY
        REASON: NIL FOUND FOR REQUIRED VALUES
        
        Label: \(label ?? "NILL")
        Value: \(value ?? "NILL")
        
        """
        guard let label = label, let value = value else {
            print(debugMsg.lowercased())
            return nil
        }
        return Aggregate(label: label, value: value)
        
    }
    
} // extension ends


//MARK:- DASHBOARD COMPONENT COLOR THEMES PARSER

fileprivate extension DashboardAPIHandler {
    
    func getArrayOfZCRMDashboardComponentColorThemes(_ ArrayOfColorThemesJSON:[[String:Any]]) -> [ZCRMDashboardComponentColorThemes]{
        
        var ArraycolorThemesObj = [ZCRMDashboardComponentColorThemes]()
        var colorPalette: [colorPaletteKeys:[String]]?
        var colorThemesValues = [ColorThemeKeys:Any]() // extendable in the future
        
        for colorThemesJSON in ArrayOfColorThemesJSON {
            
            for (key,value) in colorThemesJSON {
                
                switch (key) {
                    
                case colorPaletteAPINames.name:
                    colorThemesValues[.name] = value
                case colorPaletteAPINames.colorPalettes:
                    colorPalette = getArrayOfColorPaletteFrom(value as? [String:Any])
                default:
                    print("UNKNOWN KEY \(key) ENCOUNTERED IN COLOR THEMES PARSING".lowercased())
                    
                } // case ends
                
            } // inner loop ends
            
            if let colorThemeObj = constructColorPaletteObjFrom(colorThemesValues,colorPalette) {
                ArraycolorThemesObj.append(colorThemeObj)
            }
            
        } // outer loop ends
        
        return ArraycolorThemesObj
        
    } // func ends
    
    
    func getArrayOfColorPaletteFrom(_ colorPaletteJSON: [String:Any]?) -> [colorPaletteKeys:[String]]? {
        
        guard let colorPaletteJSON = colorPaletteJSON else {
            print("FAILED TO TYPECAST COLOR PALETTE JSON TO [STRING:ANY]".lowercased())
            return nil
        }
        
        var colorPaletteValues = [colorPaletteKeys:[String]]()
        
        for (key,value) in colorPaletteJSON {
            
            switch (key) {
                
            case colorPaletteKeys.standard.rawValue:
                colorPaletteValues[.standard] = value as? [String]
                
            case colorPaletteKeys.basic.rawValue:
                colorPaletteValues[.basic] = value as? [String]
                
            case colorPaletteKeys.general.rawValue:
                colorPaletteValues[.general] = value as? [String]
                
            case colorPaletteKeys.vibrant.rawValue:
                colorPaletteValues[.vibrant] = value as? [String]
                
            default:
                print("UNKNOWN COLOR PALETTE \(key) FOUND !!".lowercased())
                
            }
        }
        return colorPaletteValues
    } // func ends
    
    
    
    func constructColorPaletteObjFrom(_ dict:[ColorThemeKeys:Any],_ colorPalette: [colorPaletteKeys:[String]]?) -> ZCRMDashboardComponentColorThemes? {
        
        guard let name = dict.optString(key: .name) ,let colorPalette = colorPalette else {
            
            print("UNABLE TO CONSTRUCT COLOR PALETTE OBJECT".lowercased())
            return nil
        }
        
        let colorPaletteObj = ZCRMDashboardComponentColorThemes()
        colorPaletteObj.setColorPalette(palette: colorPalette)
        colorPaletteObj.setColorThemeName(name: name)
        return colorPaletteObj
    }
    
} // extension ends
