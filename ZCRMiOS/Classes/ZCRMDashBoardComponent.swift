//
//  ZCRMDashboardComponent.swift
//  Pods
//
//  Created by Kalyani shiva on 22/08/18.
//


import Foundation

public class ZCRMDashboardComponent {
    
    fileprivate var componentId: Int64
    fileprivate var dashboardId: Int64
    fileprivate var name: String
    fileprivate var category = ComponentCategory.chart
    fileprivate var reportId:Int64?
    fileprivate var componentMarkers: [ComponentMarkers]?
    fileprivate var lastFetchedTimeLabel: String?
    fileprivate var lastFetchedTimeValue: String?
    fileprivate var componentChunks = [ComponentChunks]()
    
    //MARK: Component Visualisation Props
    fileprivate var maximumRows: Int?
    fileprivate var objective: Objective?
    fileprivate var type = String() // Component Type
    fileprivate var colorPaletteName: colorPalette?
    fileprivate var colorPaletteStartingIndex: Int?
    fileprivate var segmentRanges: [SegmentRanges]?
    
    init(cmpId: Int64,name: String,dbId: Int64) {
        self.name = name
        self.componentId = cmpId
        self.dashboardId = dbId
    }
}

//MARK:- Enums

extension ZCRMDashboardComponent
{
    public typealias colorPalette = ZCRMDashboardComponentColorThemes.ColorPalette
    
    public enum Objective: String {
        case increase = "increase"
        case decrease = "decrease"
    }
    
    public enum ComponentCategory: String {
        case chart = "chart"
        case kpi = "kpi"
        case comparator = "comparator"
        case anomalyDetector = "trends"
        case targetMeter = "target_meter"
        case funnel = "funnel"
    }
}


extension ZCRMDashboardComponent: CustomDebugStringConvertible
{
    
    public var debugDescription: String{
        return """
        <--- DASHBOARD COMPONENT DEBUG DESCRIPTION --->
        DASHBOARD COMPONENT PROPERTIES ---------------X
        
        Name: \(name)
        Category: \(category.rawValue)
        Type: \(type)
        
        ReportID: \(String(describing: reportId))
        Objective: \(objective?.rawValue ?? "nil")
        Maximum Rows: \(String(describing: maximumRows))
        Component Markers: \(String(describing: componentMarkers))
        
        VISUALIZATION PROPERTIES --------------------X
        
        ColorPaletteName: \(colorPaletteName?.rawValue ?? "nil")
        ColorPalette Starting Index: \(String(describing: colorPaletteStartingIndex))
        Segment Ranges: \(String(describing: segmentRanges))
        
        LastFetchedTime Label: \(String(describing: lastFetchedTimeLabel))
        LastFetchedTime Value: \(String(describing: lastFetchedTimeValue))
        <-------------------------------------------->
        """
    }
}


// Dashboard Component Refresh ...
extension ZCRMDashboardComponent {
    
    public typealias refreshResponse = ZCRMAnalytics.refreshResponse
    
    public func refreshComponent(onCompletion: @escaping refreshResponse){
        
        DashboardAPIHandler().refreshComponentForObject(oldCompObj: self) {
            (refreshResult) in
            onCompletion(refreshResult)
        }
        
    } // func ends
    
}


//MARK:- Getters
extension ZCRMDashboardComponent {
    
    public func getCategory() -> ComponentCategory
    {
        return category
    }
    
    public func getName() -> String
    {
        return name
    }
    
    public func getLastFetchedTimeLabel() -> String?
    {
        return lastFetchedTimeLabel
    }
    
    public func getLastFetchedTimeValue() -> String?
    {
        return lastFetchedTimeValue
    }
    
    public func getReportID() -> Int64?
    {
        return reportId
    }
    
    public func getMaximumRows() -> Int?
    {
        return maximumRows
    }
    
    public func getObjective() -> Objective?
    {
        return objective
    }
    
    public func getType() -> String
    {
        return type
    }
    
    public func getColorPaletteName() -> colorPalette?
    {
        return colorPaletteName
    }
    
    public func getColorPaletteStartingIndex() -> Int?
    {
        return colorPaletteStartingIndex
    }
    
    public func getSegmentRanges() -> [SegmentRanges]?
    {
        return segmentRanges
    }
    
    public func getComponentMarkers() -> [ComponentMarkers]?
    {
        return componentMarkers
    }
    
    public func getComponentChunks() -> [ComponentChunks]
    {
        return componentChunks
    }
    
    public func getComponentId() -> Int64
    {
        return componentId
    }
    
    public func getDashboardId() -> Int64
    {
        return dashboardId
    }
}

//MARK:- Setters
extension ZCRMDashboardComponent {
    
    func setCategory(category: ComponentCategory?)
    {
        self.category = category ?? ComponentCategory.chart
    }
    
    func setName(name: String?)
    {
        self.name = name ?? String()
    }
    
    func setComponentMarkers(markers: [ComponentMarkers]?)
    {
        componentMarkers = markers
    }
    
    func setLastFetchedTimeLabel(label: String?)
    {
        lastFetchedTimeLabel = label
    }
    
    func setLastFetchedTimeValue(value: String?)
    {
        lastFetchedTimeValue = value
    }
    
    func setReportId(reportId: Int64?)
    {
        self.reportId = reportId
    }
    
    func setMaximumRows(rows: Int?)
    {
        maximumRows = rows
    }
    
    func setObjective(objective: Objective?)
    {
        self.objective = objective
    }
    
    func setType(type: String?)
    {
        self.type = type ?? String()
    }
    
    func setColorPaletteName(name: colorPalette?)
    {
        colorPaletteName = name
    }
    
    func setColorPaletteStartingIndex(index: Int?)
    {
        colorPaletteStartingIndex = index
    }
    
    func setSegmentRanges(ranges: [SegmentRanges]?)
    {
        segmentRanges = ranges
    }
    
    func addComponentChunks(chunks: ComponentChunks)
    {
        componentChunks.append(chunks)
    }
    
    func setComponentId(id: Int64)
    {
        self.componentId = id
    }
    
    func setDashboardId(id: Int64)
    {
        self.dashboardId = id
    }
    
}


//MARK:- JSON Model Structures

extension ZCRMDashboardComponent
{
    
    public struct ComponentChunks {
        var groupingColumnInfo = [GroupingColumnInfo]()
        var aggregateColumnInfo = [AggregateColumnInfo]()
        var verticalGrouping = [VerticalGrouping]()
        var name:String?
        var objective:Objective?
    }
    
    public struct GroupingColumnInfo {
        var label = String()
        var type = String()
        var name = String()
        var allowedValues: [AllowedValues]?
        var customGroups: [String]?
        
        init(label: String,
             type: String,
             name: String,
             allowedValues: [AllowedValues]?,
             customGroups: [String]?) {
            
            self.label = label
            self.type = type
            self.name = name
            self.allowedValues = allowedValues
            self.customGroups = customGroups
        }
    }
    
    public struct AggregateColumnInfo {
        var label = String()
        var type = String()
        var name = String()
        var decimalPlaces: Int?
        var aggregation: [String]?
        
        init(label: String,
             type: String,
             name: String,
             decimalPlaces: Int?,
             aggregation: [String]?) {
            
            self.label = label
            self.type = type
            self.name = name
            self.decimalPlaces = decimalPlaces
            self.aggregation = aggregation
            
        }
    }
    
    public struct VerticalGrouping {
        var label = String()
        var value: String?
        var key = String()
        var aggregate = [Aggregate]()
        var subGrouping:[VerticalGrouping]?
        
        init(label: String,
             value: String?,
             key: String,
             aggregate: [Aggregate],
             subGrouping: [VerticalGrouping]?) {
            
            self.label = label
            self.value = value
            self.key = key
            self.aggregate = aggregate
            self.subGrouping = subGrouping
            
        }
    }
    
    internal struct Aggregate {
        var label = String()
        var value = String()
        init(label:String,value:String) {
            self.label = label
            self.value = value
        }
    }
    
    internal struct AllowedValues {
        var label = String()
        var value = String()
        init(label:String,value:String) {
            self.label = label
            self.value = value
        }
    }
    
    public struct ComponentMarkers {
        var xValue:String? // Can contain userID -> Int64 or PickList values -> String
        var yValue = Int() // User's Target
        init(x:String?,y:Int) {
            xValue = x
            yValue = y
        }
    }
    
    public struct SegmentRanges {
        // Start and End Positions are in Percentage
        var color = String()  // Color Hex Code
        var startPosition = Int() // %
        var endPosition = Int() // %
        
        init(color:String,startPos:Int,endPos:Int) {
            self.color = color
            startPosition = startPos
            endPosition = endPos
        }
        
    }
    
} // extension ends ...


//MARK:- Component Chunk Setters
extension ZCRMDashboardComponent.ComponentChunks {
    
    mutating func addGroupingColumnInfo(_ info: ZCRMDashboardComponent.GroupingColumnInfo)
    {
        groupingColumnInfo.append(info)
    }
    
    mutating func addAggregateColumnInfo(_ info: ZCRMDashboardComponent.AggregateColumnInfo)
    {
        aggregateColumnInfo.append(info)
    }
    
    mutating func addVerticalGrouping(_ grouping: ZCRMDashboardComponent.VerticalGrouping)
    {
        verticalGrouping.append(grouping)
    }
    
    mutating func setName(name:String?)
    {
        self.name = name
    }
    
    mutating func setObjective(objective:ZCRMDashboardComponent.Objective?)
    {
        self.objective = objective
    }
    
}

//MARK:- Component Chunk Getters
extension ZCRMDashboardComponent.ComponentChunks {
    
    public func getGroupingColumnInfo() -> [ZCRMDashboardComponent.GroupingColumnInfo]
    {
        return groupingColumnInfo
    }
    
    public func getAggregateColumnInfo() -> [ZCRMDashboardComponent.AggregateColumnInfo]
    {
        return aggregateColumnInfo
    }
    
    public func getVerticalGrouping() -> [ZCRMDashboardComponent.VerticalGrouping]
    {
        return verticalGrouping
    }
    
    public mutating func getName() -> String?
    {
        return name
    }
    
    public mutating func getObjective() -> ZCRMDashboardComponent.Objective?
    {
        return objective
    }
    
}




//MARK:- Properties & APINames

extension ZCRMDashboardComponent {
    
    internal struct Properties {
        
        struct ResponseJSONKeys {
            
            static let componentProps = "component_props" //
            
            static let visualizationProps = "visualization_props"
            
            static let componentType = "type"
            
            static let reportID = "report_id"
            
            static let maximumRows = "max_rows"
            
            static let objective = "objective" //
            
            static let componentName = "name" //
            
            static let componentCategory = "component_type" //
            
            static let lastFetchedTime = "last_fetched_time"
            
            static let colorPalette = "color_palette"
            static let colorPaletteName = "name"
            static let colorPaletteStartingIndex = "starting_index"
            
            static let componentChunks = "component_chunks"
            static let dataMap = "data_map"
            static let total = "T"
            static let aggregates = "aggregates"
            static let rows = "rows"
            
            static let aggregateColumn = "aggregate_column_info"
            static let aggregations = "aggregations"
            static let type = "type"
            static let name = "name"
            static let decimalPlaces = "decimal_places"
            
            static let groupingColumn = "grouping_column_info"
            static let groupingConfig = "grouping_config"
            static let customGroups = "custom_groups"
            static let allowedValues = "allowed_values"
            
            
            static let verticalGrouping = "vertical_groupings"
            static let label = "label"
            static let value = "value"
            static let key = "key"
            static let subGrouping = "groupings"
            
            
            static let componentMarker = "component_markers"
            static let componentMarkerXPosition = "x"
            static let componentMarkerYPosition = "y"
            
            
            static let segmentRanges = "segment_ranges"
            static let segmentColor = "color"
            static let segmentStarts = "start_position"
            static let segmentEnds = "end_position"
            
            
        }
        
    }
    
}


extension ZCRMDashboardComponent.SegmentRanges: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        
        return """
        
        <--- SEGMENT RANGES ---->
        
        Color: \(color)
        StartPosition: \(startPosition)%
        EndPosition: \(endPosition)%
        
        """
        
    }
    
}


extension ZCRMDashboardComponent.AllowedValues: CustomDebugStringConvertible {
    
    var debugDescription: String {
        
        return """
        
        <--- ALLOWED VALUES --->
        
        Label: \(label)
        Value: \(value)
        
        """
    }
    
}


extension ZCRMDashboardComponent.ComponentMarkers: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        
        return """
        
        <--- COMPONENT MARKERS --->
        
        X: \(xValue ?? "nil")
        Y: \(yValue)
        
        """
    }
    
}


extension ZCRMDashboardComponent.Aggregate: CustomDebugStringConvertible {
    
    var debugDescription: String {
        
        return """
        
        <--- AGGREGATE --->
        
        Label: \(label)
        Value: \(value)
        
        """
        
    }
    
}


extension ZCRMDashboardComponent.VerticalGrouping: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        
        return """
        
        <---- VERTICAL GROUPING ---->
        
        Label: \(label)
        Value: \(value ?? "nil")
        Key: \(key)
        Aggregate: \(aggregate)
        SubGrouping: \(String(describing: subGrouping))
        
        """
        
    }
    
}


extension ZCRMDashboardComponent.GroupingColumnInfo: CustomDebugStringConvertible {
    
    
    public var debugDescription: String {
        return """
        
        <--- GROUPING COLUMN INFO --->
        
        Label: \(label)
        Type: \(type)
        Name: \(name)
        Allowed Values: \(String(describing: allowedValues))
        Custom Groups: \(String(describing: customGroups))
        
        """
    }
    
    
}


extension ZCRMDashboardComponent.AggregateColumnInfo: CustomDebugStringConvertible {
    
    
    public var debugDescription: String {
        
        return """
        
        <--- AGGREGATE COLUMN INFO --->
        
        Label: \(label)
        Type: \(type)
        Name: \(name)
        Decimal Places: \(String(describing: decimalPlaces))
        Aggregation: \(String(describing: aggregation))
        
        """
        
    }
    
    
}


extension ZCRMDashboardComponent.ComponentChunks: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        return """
        
        <--- Component Chunks --->
        
        Grouping Column: \(groupingColumnInfo)
        Aggregate Column: \(aggregateColumnInfo)
        Vertical Grouping: \(verticalGrouping)
        Name: \(name ?? "nil")
        Objective: \(objective?.rawValue ?? "nil")
        
        
        """
    }
    
    
}
