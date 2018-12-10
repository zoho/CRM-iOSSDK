//
//  ZCRMDashboardComponent.swift
//  Pods
//
//  Created by Kalyani shiva on 22/08/18.
//
import Foundation
open class ZCRMDashboardComponent {
    
    public var componentId: Int64 = APIConstants.INT64_MOCK
    internal var dashboardId: Int64 = APIConstants.INT64_MOCK
    public var name: String = APIConstants.STRING_MOCK
    public var category = ComponentCategory.chart
    public var reportId:Int64?
    public var componentMarkers: [ComponentMarkers]?
    public var lastFetchedTimeLabel: String?
    public var lastFetchedTimeValue: String?
    public var componentChunks = [ComponentChunks]()
    
    /// Component Visualisation Props
    public var maximumRows: Int?
    public var objective: Objective?
    public var type : String = APIConstants.STRING_MOCK // Component Type
    public var colorPaletteName: colorPalette?
    public var colorPaletteStartingIndex: Int?
    public var segmentRanges: [SegmentRanges]?
    
    init(cmpId: Int64,name: String,dbId: Int64) {
        self.name = name
        self.componentId = cmpId
        self.dashboardId = dbId
    }
}
/// Enums
extension ZCRMDashboardComponent
{
    public typealias colorPalette = ZCRMDashboardComponentColorThemes.ColorPalette
    
    public enum Objective: String
    {
        case increase = "increase"
        case decrease = "decrease"
    }
    
    public enum ComponentCategory: String
    {
        case chart = "chart"
        case kpi = "kpi"
        case comparator = "comparator"
        case anomalyDetector = "trends"
        case targetMeter = "target_meter"
        case funnel = "funnel"
    }
    
    func addComponentChunks(chunks: ComponentChunks)
    {
        componentChunks.append(chunks)
    }
    
    public func refreshComponent(onCompletion: @escaping refreshResponse)
    {
        DashboardAPIHandler().refreshComponentForObject(oldCompObj: self)
        {
            (refreshResult) in
            onCompletion(refreshResult)
        }
    } // func ends
}
// Dashboard Component Refresh ...
extension ZCRMDashboardComponent
{
    public typealias refreshResponse = ZCRMAnalytics.RefreshResponse
}
extension ZCRMDashboardComponent
{
    public struct ComponentChunks
    {
        public internal(set) var groupingColumnInfo = [GroupingColumnInfo]()
        public internal(set) var aggregateColumnInfo = [AggregateColumnInfo]()
        public internal(set) var verticalGrouping = [VerticalGrouping]()
        public internal(set) var verticalGroupingTotalAggregate: [Aggregate]?
        public internal(set) var name:String?
        public internal(set) var objective:Objective?
    }
    
    public struct GroupingColumnInfo
    {
        public internal(set) var label : String = APIConstants.STRING_MOCK
        public internal(set) var type : String = APIConstants.STRING_MOCK
        public internal(set) var name : String = APIConstants.STRING_MOCK
        public internal(set) var allowedValues: [GroupingValue]?
        public internal(set) var customGroups: [GroupingValue]?
        
        init(label: String, type: String, name: String, allowedValues: [GroupingValue]?, customGroups: [GroupingValue]?)
        {
            self.label = label
            self.type = type
            self.name = name
            self.allowedValues = allowedValues
            self.customGroups = customGroups
        }
    }
    
    public struct AggregateColumnInfo
    {
        public internal(set) var label : String = APIConstants.STRING_MOCK
        public internal(set) var type : String = APIConstants.STRING_MOCK
        public internal(set) var name : String = APIConstants.STRING_MOCK
        public internal(set) var decimalPlaces: Int?
        public internal(set) var aggregation: [String]?
        
        init(label: String, type: String, name: String, decimalPlaces: Int?, aggregation: [String]?)
        {
            self.label = label
            self.type = type
            self.name = name
            self.decimalPlaces = decimalPlaces
            self.aggregation = aggregation
        }
    }
    
    public struct VerticalGrouping
    {
        public internal(set) var label : String = APIConstants.STRING_MOCK
        public internal(set) var value: String?
        public internal(set) var key : String = APIConstants.STRING_MOCK
        public internal(set) var aggregate : [Aggregate] = [Aggregate]()
        public internal(set) var subGrouping:[VerticalGrouping]?
        
        init(label: String, value: String?, key: String, aggregate: [Aggregate], subGrouping: [VerticalGrouping]?)
        {
            self.label = label
            self.value = value
            self.key = key
            self.aggregate = aggregate
            self.subGrouping = subGrouping
        }
    }
    
    public struct Aggregate
    {
        public internal(set) var label : String = APIConstants.STRING_MOCK
        public internal(set) var value : Double = APIConstants.DOUBLE_MOCK
        init(label:String, value:Double)
        {
            self.label = label
            self.value = value
        }
    }
    
    public struct GroupingValue
    {
        public internal(set) var label : String = APIConstants.STRING_MOCK
        public internal(set) var value : String = APIConstants.STRING_MOCK
        init(label:String,value:String)
        {
            self.label = label
            self.value = value
        }
    }
    
    public struct ComponentMarkers
    {
        public internal(set) var xValue:String? // Can contain userID -> Int64 or PickList values -> String
        public internal(set) var yValue : Int = APIConstants.INT_MOCK // User's Target
        
        init(x:String?,y:Int)
        {
            xValue = x
            yValue = y
        }
    }
    
    public struct SegmentRanges
    {
        // Start and End Positions are in Percentage
        public internal(set) var color : String = APIConstants.STRING_MOCK  // Color Hex Code
        public internal(set) var startPosition : Int = APIConstants.INT_MOCK // %
        public internal(set) var endPosition : Int = APIConstants.INT_MOCK // %
        
        init(color:String,startPos:Int,endPos:Int)
        {
            self.color = color
            startPosition = startPos
            endPosition = endPos
        }
    }
} // extension ends ...
/// Component Chunk Setters
extension ZCRMDashboardComponent.ComponentChunks
{
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
    
    mutating func addVerticalGroupingTotalAggregate(_ grouping: ZCRMDashboardComponent.Aggregate)
    {
        if verticalGroupingTotalAggregate == nil
        {
            verticalGroupingTotalAggregate = [ZCRMDashboardComponent.Aggregate]()
        }
        verticalGroupingTotalAggregate?.append(grouping)
    }
}
/// Properties & APINames
extension ZCRMDashboardComponent
{
    internal struct Properties
    {
        struct ResponseJSONKeys
        {
            static let componentProps = "component_props"
            static let visualizationProps = "visualization_props"
            static let componentType = "type"
            static let reportID = "report_id"
            static let maximumRows = "max_rows"
            static let objective = "objective"
            static let componentName = "name"
            static let componentCategory = "component_type"
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
