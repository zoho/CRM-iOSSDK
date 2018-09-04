//
//  DashBoardAPIHandler.swift
//
//  Created by Kalyani shiva on 12/07/18.
//
import Foundation

class DashBoardAPIHandler: CommonAPIHandler {
    
    // Handler Return Type
    internal typealias dashBoard = (Result.DataResponse<ZCRMDashBoard,APIResponse>) -> Void
    internal typealias ArrayOfDashBoards = (Result.DataResponse<[ZCRMDashBoard],BulkAPIResponse>) -> Void
    internal typealias dashBoardComponent = (Result.DataResponse<ZCRMDashBoardComponent,APIResponse>) -> Void
    internal typealias refreshResponse = (Result.Response<APIResponse>) -> Void
    internal typealias ArrayOfColorThemes = (Result.DataResponse<[ZCRMDashBoardComponentColorThemes],APIResponse>) -> Void
    // API Names
    fileprivate typealias dashBoardAPINames = ZCRMDashBoard.Properties.APIResponseKeys
    fileprivate typealias metaComponentAPINames = ZCRMDashBoardMetaComponent.Properties.APIResponseKeys
    fileprivate typealias componentAPINames = ZCRMDashBoardComponent.Properties.APIResponseKeys
    fileprivate typealias colorPaletteAPINames = ZCRMDashBoardComponentColorThemes.Properties.APIResponseKeys
    // Model Objects
    fileprivate typealias CompCategory = ZCRMDashBoardComponent.ComponentCategory
    fileprivate typealias CompObjective  = ZCRMDashBoardComponent.Objective
    fileprivate typealias CompSegmentRanges = ZCRMDashBoardComponent.SegmentRanges
    fileprivate typealias ComponentMarkers = ZCRMDashBoardComponent.ComponentMarkers
    fileprivate typealias AggregateColumn = ZCRMDashBoardComponent.AggregateColumnInfo
    fileprivate typealias GroupingColumn = ZCRMDashBoardComponent.GroupingColumnInfo
    fileprivate typealias VerticalGrouping = ZCRMDashBoardComponent.VerticalGrouping
    fileprivate typealias AllowedValues = ZCRMDashBoardComponent.AllowedValues
    fileprivate typealias ComponentChunks = ZCRMDashBoardComponent.ComponentChunks
    fileprivate typealias Aggregate = ZCRMDashBoardComponent.Aggregate
    // used for dict keys
    fileprivate typealias colorPaletteKeys = ZCRMDashBoardComponentColorThemes.ColorPalette
    // used for parsing out ColorPaletteName
    fileprivate typealias colorPalette = ZCRMDashBoardComponentColorThemes.ColorPalette
    //Path Name
    fileprivate typealias URLPathName = ZCRMDashBoard.Properties.URLPathName
    //Meta - Component Parser Return Type
    fileprivate typealias MetaComponentLayoutPropsTuple =
        (width:Int?,height:Int?,xPosition:Int?,yPosition:Int?)
    //Component Parser Return Type
    fileprivate typealias SegmentRangesTuple = (color:String?,startPos:String?,endPos:String?)
    fileprivate typealias GroupingConfig = (AllowedValues:[AllowedValues]?,CustomGroups:[String]?)
    
}




//MARK:- DICTIONARY KEYS FOR PARSER FUNCTIONS

fileprivate extension DashBoardAPIHandler {
    
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

extension DashBoardAPIHandler {
    
    func getAllDashBoards(FromPage page:Int,WithPerPageOf perPage:Int,then
        OnCompletion: @escaping ArrayOfDashBoards)  {
        
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
                let arrayOfDashBoardJSON = dashBoardResponse  // [[String:Any]]
                    .getArrayOfDictionaries(key:JSONRootKey.ANALYTICS)
                
                var arrayOfDashBoardObj = [ZCRMDashBoard]()
                for dashBoardJSON in arrayOfDashBoardJSON {
                    
                    if let dashBoardObj = self.getZCRMDashBoardObjectFrom(dashBoardJSON){
                        arrayOfDashBoardObj.append(dashBoardObj)
                    }
                }
                OnCompletion(.success(arrayOfDashBoardObj,bulkAPIResponse))
                
            } catch {
                OnCompletion(.failure(error as! ZCRMError))
            }
        } // completion ends
    } // func ends
    
    
    func getDashBoardWith(ID dbID:Int64,then OnCompletion: @escaping dashBoard) {
        
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
                
                guard let dashBoardObj = self.getZCRMDashBoardObjectFrom(dashBoardJSON) else {
                    OnCompletion(.failure(ZCRMError.SDKError(code: ErrorCode.INTERNAL_ERROR,
                                                             message: "Failed to get DashBoard")))
                    return
                }
                OnCompletion(.success(dashBoardObj,APIResponse))
            } catch {
                OnCompletion(.failure(typeCastToZCRMError(error)))
            }
            
        } // completion
    } // func ends
    
    
    func getComponentWith(ID cmpID: Int64,FromDashBoardID dbID: Int64,then
        OnCompletion: @escaping dashBoardComponent) {
        
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
                
                guard let dashBoardComponentObj = self.getDashBoardComponentFrom(dashBoardComponentJSON) else {
                    OnCompletion(.failure(ZCRMError.ProcessingError(code: ErrorCode.INTERNAL_ERROR, message: "Unable to get Component")))
                    
                    return
                }
                OnCompletion(.success(dashBoardComponentObj,APIResponse))
                
            } catch {
                OnCompletion(.failure(error as! ZCRMError))
            }
            
        } // completion
        
    }  // func ends
    
    
    func refreshComponentWith(ID cmpID: Int64,InDashBoardID dbID: Int64 , OnCompletion: @escaping refreshResponse) {
        
        let URLPath =
        "/\(URLPathName.ANALYTICS)/\(dbID)/\(URLPathName.COMPONENTS)/\(cmpID)/\(URLPathName.REFRESH)"
        setUrlPath(urlPath: URLPath)
        setRequestMethod(requestMethod: .POST)
        setJSONRootKey(key: JSONRootKey.DATA)
        let request = APIRequest(handler: self)
        request.getAPIResponse { (resultType) in
            do{
                let APIResponse = try resultType.resolve()
                OnCompletion(.success(APIResponse))
                
            } catch {
                OnCompletion(.failure(error as! ZCRMError))
            }
        } // completion
    } // func ends
    
    
    func refreshDashBoardWith(ID dbID: Int64, OnCompletion: @escaping refreshResponse) {
        
        let URLPath = "/\(URLPathName.ANALYTICS)/\(dbID)/\(URLPathName.REFRESH)"
        setUrlPath(urlPath: URLPath)
        setRequestMethod(requestMethod: .POST)
        setJSONRootKey(key: JSONRootKey.DATA)
        let request = APIRequest(handler: self)
        request.getAPIResponse { (resultType) in
            do{
                let APIResponse = try resultType.resolve()
                OnCompletion(.success(APIResponse))
            } catch {
                OnCompletion(.failure(error as! ZCRMError))
            }
        } // completion
    } // func ends
    
    
    func getDashBoardComponentColorThemes(OnCompletion: @escaping ArrayOfColorThemes) {
        
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
                let ArrayOfcolorThemes = self.getArrayOfColorThemesObjFrom(colorThemesJSON)
                OnCompletion(.success(ArrayOfcolorThemes,APIResponse))
            } catch {
                OnCompletion(.failure(error as! ZCRMError))
            }
        } // Completion
    } // func ends
    
    
} // extension ends


//MARK:- HANDLER PARSING FUNCTIONS
//MARK:-

fileprivate extension DashBoardAPIHandler {
    
    //MARK: *** DASHBOARD PARSERS ***
    
    func getZCRMDashBoardObjectFrom(_ dashBoardJSON: [String:Any] ) -> ZCRMDashBoard? {
        
        
        guard let Id = dashBoardJSON.optInt64(key: dashBoardAPINames.dashBoardID),
            let Name = dashBoardJSON.optString(key: dashBoardAPINames.dashBoardName) else {
                return nil
        }
        
        let dashBoardObj = ZCRMDashBoard(ID: Id, Name: Name)
        
        dashBoardObj.setDashBoard(ID: Id)
        dashBoardObj.setDashBoard(Name: Name)
        
        if let isSalesTrend = dashBoardJSON.optBoolean(key: dashBoardAPINames.isSalesTrends) {
            dashBoardObj.setIfDashBoardIsSalesTrend(isSalesTrend)
        }
        
        if let accessType = dashBoardJSON.optString(key: dashBoardAPINames.accessType){
            dashBoardObj.setDashBoardAccessType(accessType)
        }
        
        if let arrayOfMetaComponent = getArrayOfZCRMDashBoardMetaComponent(From: dashBoardJSON){
            dashBoardObj.setArrayOfDashBoardMetaComponent(arrayOfMetaComponent)
        }
        
        return dashBoardObj
    }
    
} // end of extension


fileprivate extension DashBoardAPIHandler {
    
    //MARK:- *** DASHBOARD META-COMPONENT PARSERS  ***
    
    func getArrayOfZCRMDashBoardMetaComponent(From dashBoardJSON:[String:Any]) -> [ZCRMDashBoardMetaComponent]? {
        
        let metaComponentAPIName = ZCRMDashBoard.Properties.APINames.metaComponents
        guard let arrayOfMetaComponentJSON = dashBoardJSON.optArrayOfDictionaries(key: metaComponentAPIName) else {
            if dashBoardJSON.hasKey(forKey: metaComponentAPIName) {
                print("Failed to get arrayOfMetaComponentJSON from dashBoardJSON !")
            }
            return nil
        }
        
        var metaComponentObjArray = [ZCRMDashBoardMetaComponent]()
        for dashBoardMetaComponentJSON in arrayOfMetaComponentJSON {
            let metaComponentObj = getDashBoardMetaComponentFrom(dashBoardMetaComponentJSON)
            metaComponentObjArray.append(metaComponentObj)
        }
        return metaComponentObjArray
    }
    
    
    
    
    func getDashBoardMetaComponentFrom(_ metaComponentJSON:[String:Any]) -> ZCRMDashBoardMetaComponent {
        
        let metaComponentObj = ZCRMDashBoardMetaComponent()
        let ID = metaComponentJSON.optString(key: metaComponentAPINames.componentID)
        metaComponentObj.setComponent(ID: ID)
        
        let Name = metaComponentJSON.optString(key: metaComponentAPINames.componentName)
        
        metaComponentObj.setComponent(Name: Name)
        if let isFavourite = metaComponentJSON.optBoolean(key: metaComponentAPINames.favouriteComponent){
            metaComponentObj.setIfComponentIsFavourite(isFavourite)
        }
        
        let isSystemGenerated = metaComponentJSON.optBoolean(key: metaComponentAPINames.systemGenerated)
        metaComponentObj.setIfComponentIsSystemGenerated(isSystemGenerated)
        
        let JSONlayoutValues =
            getDashBoardMetaComponentLayoutPropsFrom(metaComponentJSON)
        var metaComponentLayoutObj = metaComponentObj.getLayoutProperties()
        metaComponentLayoutObj.setComponentX(Position: JSONlayoutValues?.xPosition)
        metaComponentLayoutObj.setComponentY(Position: JSONlayoutValues?.yPosition)
        metaComponentLayoutObj.setComponent(Width: JSONlayoutValues?.width)
        metaComponentLayoutObj.setComponent(Height: JSONlayoutValues?.height)
        metaComponentObj.setLayoutProperties(metaComponentLayoutObj)
        return metaComponentObj
    }
    
    
    
    func getDashBoardMetaComponentLayoutPropsFrom(_ metaComponentJSON:[String:Any]) -> MetaComponentLayoutPropsTuple?
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



fileprivate extension DashBoardAPIHandler {
    
    //MARK:- *** DASHBOARD COMPONENT PARSERS ***
    func getDashBoardComponentFrom(_ componentJSON: [String:Any]) -> ZCRMDashBoardComponent? {
        
        
        let componentName = componentJSON.optString(key: componentAPINames.componentName)
        
        let componentCategoryString = componentJSON.optString(key: componentAPINames.componentCategory)
        let componentCategoryEnum = CompCategory(rawValue: componentCategoryString ?? "default")
        
        guard let name = componentName, let category = componentCategoryEnum else {
            return nil
        }
        
        let componentObj = ZCRMDashBoardComponent(name: name, category: category)
        
        componentObj.setComponent(Name: componentName)
        componentObj.setComponent(Category: componentCategoryEnum)
        
        
        let reportID = componentJSON.optInt64(key: componentAPINames.reportID)
        componentObj.setReport(ID: reportID)
        
        
        if let arrayOfComponentMarkersObj = getComponentMarkersFrom(componentJSON) {
            componentObj.setComponent(Markers: arrayOfComponentMarkersObj)
        }
        
        let ArrayOfComponentChunksJSON = componentJSON.optArrayOfDictionaries(key: componentAPINames.componentChunks)
        setComponentChunksValues(To: componentObj, Using: ArrayOfComponentChunksJSON)
        
        if let lastFetchedTimeJSON = componentJSON.optDictionary(key: componentAPINames.lastFetchedTime) {
            
            if let lastFetchedTime = getLastFetchedTimeUsing(lastFetchedTimeJSON) {
                componentObj.setLastFetchedTime(Label: lastFetchedTime.Label)
                componentObj.setLastFetchedTime(Value: lastFetchedTime.Value)
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
    
    
    
    func setComponentPropertiesFor(_ componentObject:ZCRMDashBoardComponent,
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
            componentObject.setObjective(objectiveEnum)
        }
        if let maximumRows = componentPropsJSON.optInt(key: componentAPINames.maximumRows) {
            componentObject.setMaximum(Rows: maximumRows)
        }
        setVisualizationPropertiesFor(componentObject: componentObject,
                                      Using: componentPropsJSON)
    } // func ends
    
    
    //MARK:- COMPONENT VISUALIZATION PROPERTIES
    
    func setVisualizationPropertiesFor(componentObject:ZCRMDashBoardComponent,
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
        componentObject.setComponent(Type: componentType)
        
        let ArrayOfSegmentRangeObj = getArrayOfSegmentRangesFrom(visualizationPropsJSON)
        componentObject.setSegment(Ranges: ArrayOfSegmentRangeObj)
        
        if let colorPaletteTuple = getColorPaletteFrom(visualizationPropsJSON){
            componentObject.setColorPalette(Name: colorPaletteTuple.name)
            componentObject.setColorPaletteStarting(Index: colorPaletteTuple.index)
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
        
        let colorPaletteName = colorPaletteJSON.optString(key: componentAPINames.colorPaletteName)
        let colorPaletteNameEnum = colorPalette(rawValue: colorPaletteName ?? "default")
        
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
    
    func setComponentChunksValues(To componentObj:ZCRMDashBoardComponent,
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
            
            if let componentChunksObj = constructComponentChunksObjFrom(componentChunkValues) {
                
                componentObj.addComponent(Chunks: componentChunksObj)
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
            componentChunksObj.set(Name: componentName)
        }
        
        // Parsing out Component Chunk Component Properties
        if let componentChunkPropsDict = dict[.properties] as? [ComponentChunkPropKeys:Any] {
            
            if let objectiveString = componentChunkPropsDict[.objective] as? String {
                
                let objective =  CompObjective(rawValue: objectiveString)
                componentChunksObj.set(Objective: objective)
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

fileprivate extension DashBoardAPIHandler {
    
    
    func getArrayOfColorThemesObjFrom(_ ArrayOfColorThemesJSON:[[String:Any]]) -> [ZCRMDashBoardComponentColorThemes]{
        
        var ArraycolorThemesObj = [ZCRMDashBoardComponentColorThemes]()
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
    
    
    
    func constructColorPaletteObjFrom(_ dict:[ColorThemeKeys:Any],_ colorPalette: [colorPaletteKeys:[String]]?) -> ZCRMDashBoardComponentColorThemes? {
        
        guard let name = dict.optString(key: .name) ,let colorPalette = colorPalette else {
            
            print("UNABLE TO CONSTRUCT COLOR PALETTE OBJECT".lowercased())
            return nil
            
        }
        
        let colorPaletteObj = ZCRMDashBoardComponentColorThemes()
        colorPaletteObj.setColor(Palette: colorPalette)
        colorPaletteObj.set(Name: name)
        return colorPaletteObj
        
    }
    
} // extension ends
