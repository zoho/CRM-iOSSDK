//
//  DashBoardAPIHandler.swift
//
//  Created by Kalyani shiva on 12/07/18.
//


import Foundation


class DashBoardAPIHandler: CommonAPIHandler {
    
    // Avoids ambiguity of back and front slashes in path names like  /\(analytics)/\(dbID)
    let SLASH = "/"
    
    // Replaces Hyphens in label with 'none'
    let HYPHEN = "-"
    let NONE = "none"
    
    
    // Handler Return Type
    typealias dashBoardComponent = ZCRMRestClient.dashBoardComponent
    
    typealias ArrayOfDashBoards = ZCRMRestClient.ArrayOfDashBoard
    
    typealias dashBoard = ZCRMRestClient.dashBoard
    
    typealias refreshResponse = ZCRMRestClient.refreshResponse
    
    typealias ArrayOfColorThemes = ZCRMRestClient.ArrayOfColorThemes
    
    
    // API Names
    typealias dashBoardAPINames = ZCRMDashBoard.Properties.APINames
    
    typealias metaComponentAPINames = ZCRMDashBoardMetaComponent.Properties.APINames
    
    typealias componentAPINames = ZCRMDashBoardComponent.Properties.APINames
    
    typealias colorPaletteAPINames = ZCRMDashBoardComponentColorThemes.Properties.APINames
    
    
    // Model Objects
    typealias CompCategory = ZCRMDashBoardComponent.ComponentCategory
    
    typealias CompObjective  = ZCRMDashBoardComponent.Objective
    
    typealias CompSegmentRanges = ZCRMDashBoardComponent.SegmentRanges
    
    typealias ComponentMarkers = ZCRMDashBoardComponent.ComponentMarkers
    
    typealias AggregateColumn = ZCRMDashBoardComponent.AggregateColumnInfo
    
    typealias GroupingColumn = ZCRMDashBoardComponent.GroupingColumnInfo
    
    typealias VerticalGrouping = ZCRMDashBoardComponent.VerticalGrouping
    
    typealias AllowedValues = ZCRMDashBoardComponent.AllowedValues
    
    typealias ComponentChunks = ZCRMDashBoardComponent.ComponentChunks
    
    typealias Aggregate = ZCRMDashBoardComponent.Aggregate
    
    // used for dict keys
    typealias colorPaletteKeys = ZCRMDashBoardComponentColorThemes.ColorPalette
    
    // used for parsing out ColorPaletteName
    typealias colorPalette = ZCRMDashBoardComponentColorThemes.ColorPalette
    
    //Path Name
    typealias URLPathName = ZCRMDashBoard.Properties.URLPathName
    
    //Meta - Component Parser Return Type
    typealias MetaComponentLayoutPropsTuple =
        (width:Int?,height:Int?,xPosition:Int?,yPosition:Int?)
    
    
    //Component Parser Return Type
    typealias SegmentRangesTuple = (color:String?,startPos:String?,endPos:String?)
    
    typealias GroupingConfig = (AllowedValues:[AllowedValues]?,CustomGroups:[String]?)
    
}




//MARK:- DICTIONARY KEYS FOR PARSER FUNCTIONS

extension DashBoardAPIHandler {
    
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
    
    internal func getAllDashBoards(FromPage page:Int,WithPerPageOf perPage:Int,then
        OnCompletion: @escaping ArrayOfDashBoards) {
        
        let URLPath = "\(SLASH)\(URLPathName.ANALYTICS)"
        setUrlPath(urlPath: URLPath)
        
        setRequestMethod(requestMethod: .GET)
        
        //MARK:- perPage is  YET TO BE SUPPORTED
        //let validPerPage = perPage > 200 ? 200 : perPage
        //addRequestParam(param: .perPage, value: "\(validPerPage)")
        
    
        
        addRequestParam(param: CommonRequestParam.page, value: "\(page)")
        
        setJSONRootKey(key: JSONRootKey.ANALYTICS)
        
        
        let request = APIRequest(handler: self)
        request.getBulkAPIResponse { (bulkAPIResponse, error)  in
            
            guard error == nil else { OnCompletion (nil,bulkAPIResponse,error) ; return }
            guard let bulkAPIResponse = bulkAPIResponse else
            {
                OnCompletion([ZCRMDashBoard()],nil,error)
                print("BulkAPIResponse is NIL")
                return
            }
            
            let dashBoardResponse =  bulkAPIResponse.getResponseJSON() // [String:[[String:Any]]
            
            let arrayOfDashBoardJSON = dashBoardResponse  // [[String:Any]]
                .getArrayOfDictionaries(key:JSONRootKey.ANALYTICS)
            
            
            var arrayOfDashBoardObj = [ZCRMDashBoard]()
            
            for dashBoardJSON in arrayOfDashBoardJSON {
                let dashBoardObj = self.getDashBoardObjectFrom(dashBoardJSON)
                arrayOfDashBoardObj.append(dashBoardObj)
            }
            
            OnCompletion(arrayOfDashBoardObj,bulkAPIResponse,nil)
        } // closure ends
        
    } // func ends
    
    
    internal func getDashBoardWith(ID dbID:Int64,then OnCompletion: @escaping dashBoard) {
        
        
        let URLPath = "\(SLASH)\(URLPathName.ANALYTICS)\(SLASH)\(dbID)"
        setUrlPath(urlPath: URLPath)
        
        setRequestMethod(requestMethod: .GET)
        
        setJSONRootKey(key: JSONRootKey.ANALYTICS)
        
        let request = APIRequest(handler: self)
        request.getAPIResponse { (APIResponse, error) in
            
            guard error == nil else {OnCompletion(nil,APIResponse,error); return}
            guard let APIResponse = APIResponse else
            {
                OnCompletion(ZCRMDashBoard(),nil,error)
                print("APIResponse is NIL")
                return
            }
            
            let dashBoardResponse = APIResponse.getResponseJSON() // [String:[[String:Any]]]
            
            let dashBoardJSON = dashBoardResponse
                .getArrayOfDictionaries(key: JSONRootKey.ANALYTICS)[0]
            
            let dashBoardObj = self.getDashBoardObjectFrom(dashBoardJSON)
            
            OnCompletion(dashBoardObj,APIResponse,nil)
            
        }
        
    } // func ends
    
    internal func getComponentWith(ID cmpID: Int64,FromDashBoardID dbID: Int64,then
        OnCompletion: @escaping dashBoardComponent) {
        
        let URLPath =
        "\(SLASH)\(URLPathName.ANALYTICS)\(SLASH)\(dbID)\(SLASH)\(URLPathName.COMPONENTS)\(SLASH)\(cmpID)"
        
        setUrlPath(urlPath: URLPath)
        
        setRequestMethod(requestMethod: .GET)
        
        //Setting this has no effect but only to communicate the fact that its Response has
        // no root key
        setJSONRootKey(key: JSONRootKey.NILL)
        
        let request = APIRequest(handler: self)
        request.getAPIResponse {  ( APIResponse, error ) in
            
            guard error == nil else {OnCompletion(nil,APIResponse,error); return}
            guard let APIResponse = APIResponse else
            {
                OnCompletion(ZCRMDashBoardComponent(),nil,error)
                print("APIResponse is NIL")
                return
            }
            
            let dashBoardComponentJSON = APIResponse.getResponseJSON() // [String:Any]
            
            let dashBoardComponentObj = self.getDashBoardComponentFrom(dashBoardComponentJSON)
            
            OnCompletion(dashBoardComponentObj,APIResponse,nil)
            
        }
        
    }
    
    
    internal func refreshComponentWith(ID cmpID: Int64,InDashBoardID dbID: Int64 , OnCompletion: @escaping refreshResponse) {
        
        let URLPath =
        "\(SLASH)\(URLPathName.ANALYTICS)\(SLASH)\(dbID)\(SLASH)\(URLPathName.COMPONENTS)\(SLASH)\(cmpID)\(SLASH)\(URLPathName.REFRESH)"
        
        setUrlPath(urlPath: URLPath)
        
        setRequestMethod(requestMethod: .POST)
        
        setJSONRootKey(key: JSONRootKey.DATA)
        
        let request = APIRequest(handler: self)
        request.getAPIResponse {  ( APIResponse, error ) in
            
            guard error == nil else {OnCompletion(APIResponse,error); return}
            guard let APIResponse = APIResponse else
            {
                OnCompletion(nil,error)
                print("APIResponse is NIL")
                return
            }
            
            OnCompletion(APIResponse,nil)
            
        }
        
        
    } // func ends
    
    
    internal func refreshDashBoardWith(ID dbID: Int64, OnCompletion: @escaping refreshResponse) {
        
        let URLPath = "\(SLASH)\(URLPathName.ANALYTICS)\(SLASH)\(dbID)\(SLASH)\(URLPathName.REFRESH)"
        
        setUrlPath(urlPath: URLPath)
        
        setRequestMethod(requestMethod: .POST)
        
        setJSONRootKey(key: JSONRootKey.DATA)
        
        let request = APIRequest(handler: self)
        request.getAPIResponse {  ( APIResponse, error ) in
            
            guard error == nil else {OnCompletion(APIResponse,error); return}
            guard let APIResponse = APIResponse else
            {
                OnCompletion(nil,error)
                print("APIResponse is NIL")
                return
            }
            
            OnCompletion(APIResponse,nil)
            
        }
        
    } // func ends
    
    
    internal func getDashBoardComponentColorThemes(OnCompletion: @escaping ArrayOfColorThemes) {
        
        let URLPath = "\(SLASH)\(URLPathName.ANALYTICS)\(SLASH)\(URLPathName.COLORTHEMES)"
        
        print("URL Path \(URLPath)")
        
        setUrlPath(urlPath: URLPath)
        
        setRequestMethod(requestMethod: .GET)
        
        setJSONRootKey(key: JSONRootKey.NILL)
        
        let request = APIRequest(handler: self)
        request.getAPIResponse {  ( APIResponse, error ) in
            
            guard error == nil else {OnCompletion(nil,APIResponse,error); return}
            guard let APIResponse = APIResponse else
            {
                OnCompletion(nil,nil,error)
                print("APIResponse is NIL")
                return
            }
            
            let colorThemesResponseJSON = APIResponse.getResponseJSON() //[String:Any]
            
            let colorThemesJSON = colorThemesResponseJSON.getArrayOfDictionaries(key: colorPaletteAPINames.colorThemes)
            
            
            let ArrayOfcolorThemes = self.getArrayOfColorThemesObjFrom(colorThemesJSON)
            
            OnCompletion(ArrayOfcolorThemes,APIResponse,nil)
            
        }
        
    } // func ends
    
    
} // extension ends


//MARK:- HANDLER PARSING FUNCTIONS
//MARK:-

extension DashBoardAPIHandler {
    
    //MARK: *** DASHBOARD PARSERS ***
    
    internal func getDashBoardObjectFrom(_ dashBoardJSON: [String:Any] ) -> ZCRMDashBoard {
        
        let dashBoardObj = ZCRMDashBoard()
        
        for (key,value) in dashBoardJSON {
            
            switch (key) {
                
            case dashBoardAPINames.dashBoardID :
                dashBoardObj.setDashBoard(ID: value as? String)
                
            case dashBoardAPINames.dashBoardName:
                dashBoardObj.setDashBoard(Name: value as? String)
                
            case dashBoardAPINames.isSalesTrends:
                dashBoardObj.setIfDashBoardIsSalesTrend(value as? Bool)
                
            case dashBoardAPINames.isSystemGenerated:
                dashBoardObj.setIfDashBoardIsSystemGenerated(value as? Bool)
                
            case dashBoardAPINames.accessType:
                dashBoardObj.setDashBoardAccessType(value as? String)
                
            case dashBoardAPINames.metaComponents:
                let arrayOfMetaComponent = getArrayOfDashBoardMetaComponent(From: dashBoardJSON)
                dashBoardObj.setArrayOfDashBoardMetaComponent(arrayOfMetaComponent)
                
            default :
                print("UNKNOWN KEY ENCOUNTERED IN DASHBOARD PARSING !! \(key)")
                
            }
            
        }
        
        return dashBoardObj
    }
    
} // end of extension




extension DashBoardAPIHandler {
    
    
    
    //MARK:- *** DASHBOARD META-COMPONENT PARSERS ***
    
    internal func getArrayOfDashBoardMetaComponent(From dashBoardJSON:[String:Any]) -> [ZCRMDashBoardMetaComponent] {
        
        var metaComponentObjArray = [ZCRMDashBoardMetaComponent]()
        
        let metaComponentAPIName = ZCRMDashBoard.Properties.APINames.metaComponents
        let arrayOfMetaComponentJSON = dashBoardJSON
            .getArrayOfDictionaries(key: metaComponentAPIName)
        
        for dashBoardMetaComponentJSON in arrayOfMetaComponentJSON {
            
            let metaComponentObj = getDashBoardMetaComponentFrom(dashBoardMetaComponentJSON)
            metaComponentObjArray.append(metaComponentObj)
            
        }
        
        return metaComponentObjArray
    }
    
    
    
    
    internal func getDashBoardMetaComponentFrom(_ metaComponentJSON:[String:Any]) -> ZCRMDashBoardMetaComponent {
        
        let metaComponentObj = ZCRMDashBoardMetaComponent()
        
        for (key,value) in metaComponentJSON {
            
            switch (key){
                
            case metaComponentAPINames.componentID:
                metaComponentObj.setComponent(ID: value as? String)
                
            case metaComponentAPINames.componentName:
                metaComponentObj.setComponent(Name: value as? String)
                
            case metaComponentAPINames.favouriteComponent:
                metaComponentObj.setIfComponentIsFavourite(value as? Bool)
                
            case metaComponentAPINames.systemGenerated:
                metaComponentObj.setIfComponentIsSystemGenerated(value as? Bool)
                
            case metaComponentAPINames.itemProps:
                
                let JSONlayoutValues =
                    getDashBoardMetaComponentLayoutPropsFrom(metaComponentJSON)
                
                var metaComponentLayoutObj = metaComponentObj.getLayoutProperties()
                
                metaComponentLayoutObj.setComponentX(Position: JSONlayoutValues.xPosition)
                metaComponentLayoutObj.setComponentY(Position: JSONlayoutValues.yPosition)
                metaComponentLayoutObj.setComponent(Width: JSONlayoutValues.width)
                metaComponentLayoutObj.setComponent(Height: JSONlayoutValues.height)
                
                metaComponentObj.setLayoutProperties(metaComponentLayoutObj)
                
                
            default:
                print("UNKNOWN KEY \(key) ENCOUNTERED IN DASHBOARD META COMPONENT PARSING !!")
                
            }
            
        }
        
        return metaComponentObj
    }
    
    
    
    internal func getDashBoardMetaComponentLayoutPropsFrom(_ metaComponentJSON:[String:Any]) ->   MetaComponentLayoutPropsTuple {
        
        var width:Int?
        var height:Int?
        var xPosition:Int?
        var yPosition:Int?
        
        
        let itemPropsJSON =
            metaComponentJSON.getDictionary(key: metaComponentAPINames.itemProps)
        
        let layoutJSON = itemPropsJSON.getDictionary(key: metaComponentAPINames.layout)
        
        
        for (key,value) in layoutJSON {
            
            switch (key) {
                
            case metaComponentAPINames.componentWidth:
                width = Int((value as? String) ?? "default")
                
            case metaComponentAPINames.componentHeight:
                height = Int((value as? String) ?? "default")
                
            case metaComponentAPINames.componentXPosition:
                xPosition = Int((value as? String) ?? "default")
                
            case metaComponentAPINames.componentYPosition:
                yPosition = Int((value as? String) ?? "default")
                
            default:
                print("UNKNOWN KEY \(key) ENCOUNTERED IN DASHBOARD META COMPONENT LAYOUT PARSING !!")
                
            }
            
        }
        
        return (width: width, height: height, xPosition: xPosition, yPosition: yPosition)
    }
    
    
} // Extension ends



extension DashBoardAPIHandler {
    
    //MARK:- *** DASHBOARD COMPONENT PARSERS ***
    
    
    internal func getDashBoardComponentFrom(_ componentJSON: [String:Any]) -> ZCRMDashBoardComponent {
        
        let componentObj = ZCRMDashBoardComponent()
        
        for(key,value) in componentJSON {
            
            switch(key) {
                
            case componentAPINames.componentName:
                componentObj.setComponent(Name: value as? String)
                
            case componentAPINames.componentCategory:
                let category = CompCategory(rawValue: (value as? String) ?? "default")
                componentObj.setComponent(Category: category)
                
            case componentAPINames.componentMarker:
                let arrayOfComponentMarkersObj = getComponentMarkersFrom(componentJSON)
                componentObj.setComponent(Markers: arrayOfComponentMarkersObj)
                
            case componentAPINames.componentProps:
                setComponentPropertiesFor(componentObj, Using: componentJSON)
                
            case componentAPINames.reportID:
                componentObj.setReport(ID: value as? Int64)
                
            case componentAPINames.componentChunks:
                setComponentChunksValues(To: componentObj, Using: value as? [[String:Any]])
                
            default:
                print("UNKNOWN KEY \(key) ENCOUNTERED IN COMPONENT PARSING")
                
            } // switch ends
            
        } // loop ends
        
        return componentObj
    } // func ends
    
    
    
    
    internal func getComponentMarkersFrom(_ componentJSON:[String:Any]) -> [ComponentMarkers] {
        
        
        let ArrayOfCompMarkerJSON = componentJSON.getArrayOfDictionaries(key: componentAPINames.componentMarker)
        
        var ArrayOfComponentMarkerObj = [ComponentMarkers]()
        
        var x:String? // can be User ID (Int64) or pickListValue (String)
        var y:Int?
        
        
        for compMarkersJSON  in ArrayOfCompMarkerJSON {
            
            for (key,value) in compMarkersJSON {
                
                switch (key) {
                    
                case componentAPINames.componentMarkerXPosition:
                    x = value as? String
                case componentAPINames.componentMarkerYPosition:
                    y = value as? Int
                    
                default:
                    print("UNKNOWN KEY \(key) ENCOUNTERED IN COMPONENT MARKER PARSING")
                    
                } // switch ends
                
            } // inner loop
            
            if let componentMarkerObj = constructComponentMarkerFrom(xValue: x, yValue: y) {
                
                ArrayOfComponentMarkerObj.append(componentMarkerObj)
                
            }
            
        } // outer loop
        
        return ArrayOfComponentMarkerObj
    }
    
    
    
    internal func constructComponentMarkerFrom(xValue: String?,yValue: Int?) -> ComponentMarkers? {
        
        
        let debugMsg = """
        
        UNABLE TO CONSTRUCT COMPONENT MARKER OBJECT
        xValue: \(xValue ?? "NILL")
        yValue: \(String(describing: yValue))
        
        """
        
        guard let yValue = yValue else {
            print(debugMsg)
            return nil
        }
        
        return ComponentMarkers(x: xValue, y: yValue)
        
        
    } // func ends
    
    
    
    
    internal func setComponentPropertiesFor(_ componentObject:ZCRMDashBoardComponent,
                                            Using componentJSON: [String:Any]) {
        
        let componentPropsJSON = componentJSON.getDictionary(key: componentAPINames.componentProps)
        
        for (key,value) in componentPropsJSON {
            
            switch (key) {
                
            case componentAPINames.objective:
                let objective = CompObjective(rawValue: (value as? String) ?? "default")
                componentObject.setObjective(objective)
                
            case componentAPINames.maximumRows:
                componentObject.setMaximum(Rows: value as? Int)
                
            case componentAPINames.visualizationProps:
                setVisualizationPropertiesFor(componentObject: componentObject,
                                              Using: componentPropsJSON)
                
                
            default:
                print("UNKNOWN KEY \(key) ENCOUNTERED IN COMPONENT PROPERTIES PARSING")
                
            }
            
        }
        
    } // func ends
    
    
    //MARK:- COMPONENT VISUALIZATION PROPERTIES
    
    internal func setVisualizationPropertiesFor(componentObject:ZCRMDashBoardComponent,
                                                Using componentPropsJSON: [String:Any]) {
        
        
        let visualizationPropsJSON = componentPropsJSON
            .getDictionary(key: componentAPINames.visualizationProps)
        
        
        for (key,value) in visualizationPropsJSON {
            
            switch (key){
                
            case componentAPINames.componentType:
                componentObject.setComponent(Type: value as? String)
                
            case componentAPINames.segmentRanges:
                let ArrayOfSegmentRangeObj = getArrayOfSegmentRangesFrom(visualizationPropsJSON)
                componentObject.setSegment(Ranges: ArrayOfSegmentRangeObj)
                
            case componentAPINames.colorPalette:
                if let colorPaletteTuple = getColorPaletteFrom(visualizationPropsJSON){
                    componentObject.setColorPalette(Name: colorPaletteTuple.name)
                    componentObject.setColorPaletteStarting(Index: colorPaletteTuple.index)
                }
                
            default:
                print("UNKNOWN KEY \(key) ENCOUNTERED IN COMPONENT VISUALIZATION PROPERTIES PARSING")
                
            } // Switch case ends
            
            
        } // loop ends
        
        
    } // func ends
    
    
    
    internal func getArrayOfSegmentRangesFrom(_ visualizationPropsJSON: [String:Any]) ->
        [CompSegmentRanges] {
            
            let ArrayOfSegmentRangesJSON = visualizationPropsJSON
                .getArrayOfDictionaries(key: componentAPINames.segmentRanges)
            
            var ArrayOfSegmentRangeObj = [CompSegmentRanges]()
            
            var startPos:String?
            var endPos:String?
            var color:String?
            
            for segmentRangesJSON in ArrayOfSegmentRangesJSON {
                
                for (key,value) in segmentRangesJSON {
                    
                    switch (key) {
                        
                    case componentAPINames.segmentStarts:
                        startPos = value as? String
                        
                    case componentAPINames.segmentEnds:
                        endPos =  value as? String
                        
                    case componentAPINames.segmentColor:
                        color = value as? String
                        
                    default:
                        print("UNKNOWN KEY \(key) ENCOUNTERED IN COMPONENT SEGMENT RANGE PARSING")
                        
                    } // Switch Case ends
                    
                } // inner Loop ends
                
                let Tuple = (color,startPos,endPos)
                
                if let segmentRangesObj = constructSegmentRangesObjectFrom(Tuple) {
                    ArrayOfSegmentRangeObj.append(segmentRangesObj)
                }
                
            } // outer Loop ends
            
            return ArrayOfSegmentRangeObj
            
    } // function ends
    
    
    
    internal func constructSegmentRangesObjectFrom(_ Tuple:SegmentRangesTuple) -> CompSegmentRanges? {
        
        
        let debugMsg = """
        
        UNABLE TO CONSTRUCT SEGMENT RANGES OBJECT FROM TUPLE

        """
        
        
        guard var startPosPercent = Tuple.startPos, var endPosPercent = Tuple.endPos else {
            
            print(debugMsg)
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
                
                print(debugMsg)
                print("REASON: Found NIL Values")
                return nil
        }
        
        
        return CompSegmentRanges(color: color, startPos: startPos, endPos: endPos)
        
        
    } // func ends
    
    
    
    
    func getColorPaletteFrom(_ visualizationPropsJSON: [String:Any]) -> (name:colorPalette,index:Int)? {
        
        let colorPaletteJSON = visualizationPropsJSON
            .getDictionary(key: componentAPINames.colorPalette)
        
        var name:String?
        var index:Int?
        
        for (key,value) in colorPaletteJSON {
            
            switch (key) {
                
            case componentAPINames.colorPaletteName:
                name = value as? String
                
            case componentAPINames.colorPaletteStartingIndex:
                index = value as? Int
                
            default:
                print("UNKNOWN KEY \(key) ENCOUNTERED IN COMPONENT COLOR PALETTE PARSING")
                
            }
            
        } // loop ends
        
        
        if let name = colorPalette.init(rawValue: name ?? "default") ,let index = index {
            return (name,index)
        }
        
        // When Optional Binding Fails ...
        
        let debugMsg = """
        
        UNABLE TO EXTRACT COLOR PALETTE VALUES FROM JSON
        Palette Name: \(name ?? "NILL"),
        Palette StartingIndex: \(String(describing: index)),
        
        """
        
        print(debugMsg)
        
        return nil
        
    } // func ends
    
    
    //MARK:- COMPONENT CHUNKS
    
    internal func setComponentChunksValues(To componentObj:ZCRMDashBoardComponent,
                                           Using chunks: [[String:Any]]?) {
        
        
        guard let ArrayOfComponentChunksJSON = chunks else {
            print("FAILED TO TYPECAST COMPONENT CHUNKS TO [STRING:ANY]")
            return
            
        }
        
        
        var componentChunkValues = [ComponentChunkKeys:Any]()
        
        for componentChunksJSON in ArrayOfComponentChunksJSON {
            
            for (key,value ) in componentChunksJSON {
                
                switch (key) {
                    
                case componentAPINames.aggregateColumn:
                    let aggregateColumn = getArrayOfAggregateColumnInfo(Using: componentChunksJSON)
                    componentChunkValues[.aggregateColumn] = aggregateColumn
                    
                case componentAPINames.groupingColumn:
                    let groupingColumn = getArrayOfGroupingColumnInfo(Using: componentChunksJSON)
                    componentChunkValues[.groupingColumn] = groupingColumn
                    
                case componentAPINames.verticalGrouping:
                    let verticalGrouping = getArrayOfVerticalGrouping(Using: componentChunksJSON)
                    componentChunkValues[.verticalGrouping] = verticalGrouping
                    
                case componentAPINames.name:
                    componentChunkValues[.name] = value
                    
                case componentAPINames.componentProps:
                    componentChunkValues[.properties] = setComponentChunkPropertiesFor(value as? [String:Any])
                    
                case componentAPINames.dataMap:
                    continue
                    
                    
                default:
                    print("UNKNOWN KEY \(key) ENCOUNTERED IN COMPONENT CHUNKS PARSING")
                    
                } // switch ends
                
            } // inner loop ends
            
            if let componentChunksObj = constructComponentChunksObjFrom(componentChunkValues) {
                componentObj.addComponent(Chunks: componentChunksObj)
            }
            
        } // outer loop ends
        
    } // func ends
    
    
    
    
    
    internal func setComponentChunkPropertiesFor(_ componentPropsJSON:[String:Any]? ) -> [ComponentChunkPropKeys:Any]? {
        
        
        guard let componentPropsJSON = componentPropsJSON else {
            
            print("FAILED TO TYPECAST COMPONENT CHUNK PROPS TO [ STRING: ANY ]")
            return nil
        }
        
        var componentChunkPropValues = [ComponentChunkPropKeys:Any]()
        
        for (key,value) in componentPropsJSON {
            
            switch (key) {
                
            case componentAPINames.objective:
                componentChunkPropValues[.objective] = value
                
                // More could appear in the future ..
                
            default:
                print("ADD KEY \(key) TO COMPONENT CHUNK PROPERTIES PARSING !")
                
            }
            
        }
        
        return componentChunkPropValues
        
    }
    
    
    
    
    internal func constructComponentChunksObjFrom(_ dict:[ComponentChunkKeys:Any]) -> ComponentChunks? {
        
        
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
                
                print(debugMsg)
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
    
    internal func getArrayOfAggregateColumnInfo(Using componentChunksJSON: [String:Any] ) -> [AggregateColumn] {
        
        
        
        // Keys are of Enum Type to avoid typos at set and get sites
        var aggregateColValues = [AggregateColumnKeys:Any]()
        
        var ArrayOfAggregateColumnObj = [AggregateColumn]()
        
        let ArrayOfAggregateColumnJSON = componentChunksJSON
            .getArrayOfDictionaries(key: componentAPINames.aggregateColumn)
        
        
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
                    print("UNKNOWN KEY \(key) ENCOUNTERED IN COMPONENT AGGREGATE COLUMN PARSING")
                    
                } // switch case ends
                
            } // inner loop ends
            
            if let aggregateColObj = constructAggregateColumnObjFrom(aggregateColValues)
            {
                ArrayOfAggregateColumnObj.append(aggregateColObj)
            }
            
        } // outer loop ends
        
        return ArrayOfAggregateColumnObj
        
    } // func ends
    
    
    
    
    internal func constructAggregateColumnObjFrom(_ dict:[AggregateColumnKeys:Any] ) -> AggregateColumn? {
        
        
        let debugMsg = """
        
        UNABLE TO CONSTRUCT AGGREAGTE COLUMN OBJECT FROM VALUES
        
        Label: \(dict[.label] ?? "NILL"),
        Type: \(dict[.type] ?? "NILL"),
        Name: \(dict[.name] ?? "NILL"),
        Decimal Places: \(String(describing: dict[.decimalPlaces])),
        Aggregates: \(dict[.aggregation] ?? ["NILL"])
        
        """
        
        
        // Decimal Places exists in JSON but cannot be typecasted to INT
        
        if dict.hasKey(forKey: .decimalPlaces) {
            
            guard  ( dict[.decimalPlaces] as? Int ) != nil else {
                print(debugMsg)
                return nil
            }
            
        }
        
        
        // Only Decimal Places is Optional
        // But if it exists in JSON, It must be passed to Init() else Dont create Object
        
        let decimalPlaces = dict[.decimalPlaces] as? Int
        
        if let label = dict[.label] as? String,
            let type = dict[.type] as? String,
            let name = dict[.name] as? String,
            let aggregation = dict[.aggregation] as? [String] {
            
            return AggregateColumn(label: label,
                                   type: type,
                                   name: name,
                                   decimalPlaces: decimalPlaces,
                                   aggregation: aggregation)
            
        }
        
        print(debugMsg)
        return nil
        
    }
    
    //MARK:- GROUPING COLUMN INFO
    
    internal func getArrayOfGroupingColumnInfo(Using componentChunksJSON: [String:Any]) -> [GroupingColumn] {
        
        var groupingColumnValues = [GroupingColumnKeys:Any]()
        
        var ArrayOfGroupingColumnObj = [GroupingColumn]()
        
        let ArrayOfGroupingColumnJSON = componentChunksJSON.getArrayOfDictionaries(key: componentAPINames.groupingColumn)
        
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
                    let groupingConfigTuple = getGroupingConfigValuesFrom(groupingColumnJSON)
                    groupingColumnValues[.allowedValues] = groupingConfigTuple.AllowedValues
                    groupingColumnValues[.customGroups] = groupingConfigTuple.CustomGroups
                    
                default:
                    print("UNKNOWN KEY \(key) ENCOUNTERED IN GROUPING COLUMN PARSING")
                }
                
            } // inner loop
            
            if let groupingColumnObj = constructGroupingColumnObjFrom(groupingColumnValues) {
                ArrayOfGroupingColumnObj.append(groupingColumnObj)
            }
            
        } // outer loop
        
        return ArrayOfGroupingColumnObj
        
    } // func ends
    
    
    
    internal func constructGroupingColumnObjFrom(_ dict:[GroupingColumnKeys:Any])
        -> GroupingColumn? {
            
            
            
            // Both are optional values
            let allowedValues = dict[.allowedValues] as? [AllowedValues]
            let customGroups = dict[.customGroups] as? [String]
            
            
            if  let label = dict[.label] as? String,
                let type = dict[.type] as? String,
                let name = dict[.name] as? String {
                
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
            
            print(debugMsg)
            
            return nil
            
            
    }
    
    
    
    
    internal func getGroupingConfigValuesFrom(_ groupingColumnJSON:[String:Any])-> GroupingConfig {
        
        let groupingConfigJSON = groupingColumnJSON.getDictionary(key: componentAPINames.groupingConfig)
        
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
    
    
    
    
    internal func getArrayOfAllowedValuesObjFrom(_ ArrayOfAllowedValuesJSON: [[String:Any]]?) -> [AllowedValues]? {
        
        var ArrayOfAllowedValuesObj = [AllowedValues]()
        
        guard let ArrayOfAllowedValuesJSON = ArrayOfAllowedValuesJSON else {
            print("UNABLE TO TYPECAST ALLOWED VALUES TO [STRING:ANY]")
            return nil
        }
        
        // AV-> AllowedValue
        var AVlabel:String?
        var AVvalue:String?
        
        
        for allowedValuesJSON in ArrayOfAllowedValuesJSON {
            
            for (key,value) in allowedValuesJSON {
                
                switch (key) {
                    
                case componentAPINames.label:
                    AVlabel = value as? String
                    
                case componentAPINames.value:
                    AVvalue = value as? String
                    
                default:
                    print("UNKNOWN KEY \(key) ENCOUNTERED IN ALLOWED VALUES  PARSING")
                    
                } // switch
                
            } // inner loop
            
            if let allowedValues = constructAllowedValuesObjFrom(label: AVlabel, value: AVvalue) {
                ArrayOfAllowedValuesObj.append(allowedValues)
            }
            
        } // outer loop
        
        return ArrayOfAllowedValuesObj
        
    } // func ends
    
    
    
    
    internal func constructAllowedValuesObjFrom(label:String?,value:String?) -> AllowedValues? {
        
        if let label = label, let value = value {
            return AllowedValues(label: label, value: value)
        }
        
        let debugMsg =
        """
        UNABLE TO CONSTRUCT ALLOWED VALUES OBJECT
        Label: \(label ?? "NILL")
        Value: \(value ?? "NILL")
        
        """
        
        print(debugMsg)
        return nil
        
    }
    
    
    //MARK:- VERTICAL GROUPING
    
    internal func getArrayOfVerticalGrouping(Using componentChunksJSON: [String:Any],    _ ArrayOfVerticalGroupingJSONParam: [[String:Any]]? = nil ) -> [VerticalGrouping] {
        
        
        
        var ArrayOfVerticalGroupingJSON = [[String:Any]]()
        
        if let unwrappedValue = ArrayOfVerticalGroupingJSONParam {
            
            ArrayOfVerticalGroupingJSON = unwrappedValue
            
        } else {
            
            ArrayOfVerticalGroupingJSON = componentChunksJSON.getArrayOfDictionaries(key: componentAPINames.verticalGrouping)
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
                    if value as? [[String:Any]] != nil {
                        //                    print("VALUE IRUKU DAW \(value)")
                        verticalGroupingValues[.subGrouping] = value  // [[String:Any]]
                    } else { /*print("VALUE EMPTY DAW \(value)") */ }
                    
                default:
                    print("UNKNOWN KEY \(key) ENCOUNTERED IN VERTICAL GROUPING  PARSING")
                    
                    
                } // switch ends
                
            } // inner loop
            
            
            if let verticalGroupingObj = constructVerticalGroupingObjFrom(verticalGroupingValues,componentChunksJSON) {
                
                ArrayOfVerticalGroupingObj.append(verticalGroupingObj)
            }
            
            
        } // outer loop
        
        return ArrayOfVerticalGroupingObj
        
    } // func ends
    
    
    
    
    
    internal func constructVerticalGroupingObjFrom(_ dict: [VerticalGroupingKeys:Any], _ componentChunksJSON: [String:Any]) -> VerticalGrouping? {
        
        
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
                
                print(debugMsg)
                return nil
                
        }
        
        
        var ArrayOfSubgroupingObjs:[VerticalGrouping]?
        
        if dict.hasKey(forKey: .subGrouping) {
            
            guard let ArrayOfSubGroupingJSON = dict[.subGrouping] as? [[String:Any]] else {
                
                print(" VERTICAL GROUPING OBJECT CONSTRUCTION FAILED.\n UNABLE TO TYPECAST VERTICAL SUBGROUPING TO [[STRING:ANY]]")
                
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
    
    
    
    
    internal func convertLabelToNoneIfHyphen(_ value: String?) -> String? {
        
        guard let label = value else { return nil }
        
        if label == HYPHEN  {
            return NONE
        } else {
            return value
        }
        
    } // func ends
    
    
    
    
    internal func getAggreagtesForVerticalGrouping(Key: Any,Using componentChunksJSON:[String:Any]) -> [Aggregate]? {
        
        
        var reason = "Default Reason Value"
        
        var debugMsg: String {
            
            return """
            UNABLE TO CONSTRUCT AGGREGATES FOR VERTICAL GROUPING KEY
            REASON: \(reason)
            """
        }
        
        
        guard let Key = Key as? String else {
            
            reason = "Unable to TypeCast Vertical Grouping Key to STRING"
            print(debugMsg)
            return nil
            
        }
        
        
        let dataMapJSON = componentChunksJSON.getDictionary(key: componentAPINames.dataMap)
        
        for (dataMapkey,value) in dataMapJSON {
            
            if dataMapkey == Key {
                
                return getAggregatesObjFrom(mapKeyJSON: value)
                
            }
            
        } // end of loop
        
        
        reason = "AGGREAGATES NOT FOUND FOR GIVEN VERTICAL KEY \(Key)"
        
        print(debugMsg)
        
        return nil
        
        
    } // func ends
    
    
    
    
    internal func getAggregatesObjFrom(mapKeyJSON:Any) -> [Aggregate]? {
        
        let debugMsg =
            
        """
        UNABLE TO CONSTRUCT AGGREGATE FOR VERTICAL GROUPING KEY
        REASON: Failed to typecast MapKeyJSON to [String:Any]

        """
        
        
        guard let mapKeyJSON = mapKeyJSON as? [String:Any] else {
            print(debugMsg)
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
                    print("UNKNOWN KEY \(key) ENCOUNTERED IN DATA MAP AGGREGATES PARSING")
                    
                } // switch key
                
            } // inner loop
            
            
            if let aggregatesObj = constructAggregatesObjFrom(AGlabel, AGvalue) {
                ArrayOfAggregatesObj.append(aggregatesObj)
            }
            
        } // outer loop
        
        return ArrayOfAggregatesObj
        
    }
    
    
    
    internal func typeCastAggregate(Label value:Any) -> String? {
        
        if let number = value as? Double {
            
            return String(number)
            
        } else {
            
            return value as? String
            
        }
        
    } // func ends
    
    
    
    internal func typeCastAggregate(Value value:Any) -> String? {
        
        return typeCastAggregate(Label: value)
        
    }
    
    
    
    internal func constructAggregatesObjFrom(_ label:String?, _ value:String?) -> Aggregate? {
        
        let debugMsg =
            
        """
        UNABLE TO CONSTRUCT AGGREGATE FOR VERTICAL GROUPING KEY
        REASON: NIL FOUND FOR REQUIRED VALUES
        
        Label: \(label ?? "NILL")
        Value: \(value ?? "NILL")
        
        """
        
        guard let label = label, let value = value else {
            print(debugMsg)
            return nil
        }
        
        
        return Aggregate(label: label, value: value)
        
    }
    
    
} // extension ends


//MARK:- DASHBOARD COMPONENT COLOR THEMES PARSER

extension DashBoardAPIHandler {
    
    
    internal func getArrayOfColorThemesObjFrom(_ ArrayOfColorThemesJSON:[[String:Any]]) -> [ZCRMDashBoardComponentColorThemes]  {
        
        
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
                    print("UNKNOWN KEY \(key) ENCOUNTERED IN COLOR THEMES PARSING")
                    
                    
                } // case ends
                
                
            } // inner loop ends
            
            if let colorThemeObj = constructColorPaletteObjFrom(colorThemesValues,colorPalette) {
                
                ArraycolorThemesObj.append(colorThemeObj)
                
            }
            
        } // outer loop ends
        
        return ArraycolorThemesObj
        
    } // func ends
    
    
    
    
    fileprivate func getArrayOfColorPaletteFrom(_ colorPaletteJSON: [String:Any]?) -> [colorPaletteKeys:[String]]? {
        
        
        guard let colorPaletteJSON = colorPaletteJSON else {
            print("FAILED TO TYPECAST COLOR PALETTE JSON TO [STRING:ANY]")
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
                print("UNKNOWN COLOR PALETTE \(key) FOUND !!")
                
            }
            
        }
        
        return colorPaletteValues
        
    } // func ends
    
    
    
    fileprivate func constructColorPaletteObjFrom(_ dict:[ColorThemeKeys:Any],_ colorPalette: [colorPaletteKeys:[String]]?) -> ZCRMDashBoardComponentColorThemes? {
        
        
        guard let name = dict[.name] as? String ,let colorPalette = colorPalette else {
            
            print("UNABLE TO CONSTRUCT COLOR PALETTE OBJECT")
            return nil
            
        }
        
        let colorPaletteObj = ZCRMDashBoardComponentColorThemes()
        
        colorPaletteObj.setColor(Palette: colorPalette)
        colorPaletteObj.set(Name: name)
        
        
        return colorPaletteObj
        
    }
    
    
    
} // extension ends
