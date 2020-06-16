//
//  ZCRMDashboardComponent.swift
//  Pods
//
//  Created by Kalyani shiva on 22/08/18.
//
import Foundation
open class ZCRMDashboardComponent : ZCRMDashboardComponentDelegate {

    public internal( set ) var markers : [ ComponentMarkers ]?
    public internal( set ) var lastFetchedTimeLabel : String?
    public internal( set ) var lastFetchedTimeValue : String?
    public internal( set ) var componentChunks = [ ComponentChunks ]()
    
    /// Component Visualisation Props
    public internal( set ) var maxRows : Int?
    public internal( set ) var objective : Objective?
    public internal( set ) var colorPaletteName : colorPalette?
    public internal( set ) var colorPaletteStartingIndex : Int?
    public internal( set ) var segmentRanges : [ SegmentRanges ]?
    public internal( set ) var period : ComponentPeriod?
    
    public typealias colorPalette = ZCRMAnalyticsColorThemes.ColorPalette
    
    public enum Objective: String
    {
        case increase = "increase"
        case decrease = "decrease"
    }
    
    public enum Duration : Int
    {
        case day = 1
        case week = 7
        case month = 30
        case quarter = 90
        case year = 365
    }
    
    func addComponentChunks(chunks: ComponentChunks)
    {
        componentChunks.append(chunks)
    }
    
    public func refreshComponent( onCompletion: @escaping refreshResponse)
    {
        DashboardAPIHandler(cacheFlavour: .noCache).refreshComponentForObject(oldCompObj: self, period: self.period)
        {
            (refreshResult) in
            onCompletion(refreshResult)
        }
    } // func ends
    
    public func getData( drilldownParams : ZCRMQuery.GetDrilldownDataParams, completion : @escaping( Result.DataResponse< ZCRMAnalyticsData, APIResponse > ) -> () )
    {
        if self.componentChunks.isEmpty
        {
            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( ErrorCode.invalidOperation ) : Component chunks is empty, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code : ErrorCode.invalidOperation, message : "Component chunks is empty", details : nil ) ) )
        }
        else
        {
            if self.componentChunks[0].id != nil
            {
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.invalidOperation) : Use the method 'getData' in ComponentChunks, \( APIConstants.DETAILS ) : -")
                completion( .failure( ZCRMError.processingError( code : ErrorCode.invalidOperation, message : "Use the method 'getData' in ComponentChunks", details : nil ) ) )
            }
            else
            {
                DashboardAPIHandler( cacheFlavour : .urlVsResponse ).getDrilldownData( componentId : self.id, dashboardId : self.dashboardId, reportId : self.reportId, componentChunkId : nil, dataParams : drilldownParams ) { ( result ) in
                    completion( result )
                }
            }
        }
    }
    
    public func getDataFromServer( drilldownParams : ZCRMQuery.GetDrilldownDataParams, completion : @escaping( Result.DataResponse< ZCRMAnalyticsData, APIResponse > ) -> () )
    {
        if self.componentChunks.isEmpty
        {
            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( ErrorCode.invalidOperation ) : Component chunks is empty, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code : ErrorCode.invalidOperation, message : "Component chunks is empty", details : nil ) ) )
        }
        else
        {
            if self.componentChunks[0].id != nil
            {
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.invalidOperation) : Use the method 'getData' in ComponentChunks, \( APIConstants.DETAILS ) : -")
                completion( .failure( ZCRMError.processingError( code : ErrorCode.invalidOperation, message : "Use the method 'getData' in ComponentChunks", details : nil ) ) )
            }
            else
            {
                DashboardAPIHandler( cacheFlavour : .noCache ).getDrilldownData( componentId : self.id, dashboardId : self.dashboardId, reportId : self.reportId, componentChunkId : nil, dataParams : drilldownParams ) { ( result ) in
                    completion( result )
                }
            }
        }
    }
    
    public func downloadAsImage( completion : @escaping( Result.Response< FileAPIResponse > ) -> () )
    {
        DashboardAPIHandler( cacheFlavour : .noCache ).downloadComponentPhoto( period : self.period, dashboardId : self.dashboardId, componentId : self.id) { ( result ) in
                completion( result )
        }
    }
    
    public func downloadAsImage( fileDownloadDelegate : ZCRMFileDownloadDelegate )
    {
        DashboardAPIHandler( cacheFlavour : .noCache ).downloadComponentPhoto( period : self.period, dashboardId : self.dashboardId, componentId : self.id, fileDownloadDelegate : fileDownloadDelegate )
    }
    
    public func changeAnomaly(byPeriod period : ComponentPeriod, completion : @escaping ( Result.DataResponse< ZCRMDashboardComponent, APIResponse > ) -> ())
    {
        DashboardAPIHandler(cacheFlavour: .urlVsResponse).changeAnomalyPeriod(period: period, self, self.name, self.category) { result in
            completion( result )
        }
    }
}
// Dashboard Component Refresh ...
extension ZCRMDashboardComponent
{
    public typealias refreshResponse = ZCRMSDKUtil.ZCRMAnalytics.RefreshResponse
}
extension ZCRMDashboardComponent
{
    public struct ComponentChunks : Hashable
    {
        public internal(set) var groupingColumnInfo = [GroupingColumnInfo]()
        public internal(set) var aggregateColumnInfo = [AggregateColumnInfo]()
        public internal(set) var verticalGrouping = [VerticalGrouping]()
        public internal(set) var verticalGroupingTotalAggregate: [Aggregate]?
        public internal(set) var name:String?
        public internal(set) var objective:Objective?
        public internal( set ) var id : Int64?
        internal unowned var component : ZCRMDashboardComponentDelegate
        
        init( component : ZCRMDashboardComponentDelegate ) {
            self.component = component
        }
        
        public func getData( drilldownParams : ZCRMQuery.GetDrilldownDataParams, completion : @escaping( Result.DataResponse< ZCRMAnalyticsData, APIResponse > ) -> () )
        {
            if let id = self.id
            {
                DashboardAPIHandler( cacheFlavour : .urlVsResponse ).getDrilldownData( componentId : self.component.id, dashboardId : self.component.dashboardId, reportId : self.component.reportId, componentChunkId : id, dataParams : drilldownParams ) { ( result ) in
                    completion( result )
                }
            }
            else
            {
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.invalidOperation) : Use the method 'getData' in ZCRMDashboardComponent, \( APIConstants.DETAILS ) : -")
                completion( .failure( ZCRMError.processingError( code : ErrorCode.invalidOperation, message : "Use the method 'getData' in ZCRMDashboardComponent", details : nil ) ) )
            }
        }
        
        public func getDataFromServer( drilldownParams : ZCRMQuery.GetDrilldownDataParams, completion : @escaping( Result.DataResponse< ZCRMAnalyticsData, APIResponse > ) -> () )
        {
            if let id = self.id
            {
                DashboardAPIHandler( cacheFlavour : .noCache ).getDrilldownData( componentId : self.component.id, dashboardId : self.component.dashboardId, reportId : self.component.reportId, componentChunkId : id, dataParams : drilldownParams ) { ( result ) in
                    completion( result )
                }
            }
            else
            {
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.invalidOperation) : Use the method 'getData' in ZCRMDashboardComponent, \( APIConstants.DETAILS ) : -")
                completion( .failure( ZCRMError.processingError( code : ErrorCode.invalidOperation, message : "Use the method 'getData' in ZCRMDashboardComponent", details : nil ) ) )
            }
        }
        
        public static func == (lhs: ZCRMDashboardComponent.ComponentChunks, rhs: ZCRMDashboardComponent.ComponentChunks) -> Bool {
            return lhs.groupingColumnInfo == rhs.groupingColumnInfo && lhs.aggregateColumnInfo == rhs.aggregateColumnInfo && lhs.verticalGrouping == rhs.verticalGrouping && lhs.verticalGroupingTotalAggregate == rhs.verticalGroupingTotalAggregate && lhs.name == rhs.name && lhs.objective == rhs.objective && lhs.id == rhs.id && lhs.component == rhs.component
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine( id )
        }
    }
    
    public struct GroupingColumnInfo : Equatable
    {
        public internal(set) var label : String = APIConstants.STRING_MOCK
        public internal(set) var type : String = APIConstants.STRING_MOCK
        public internal(set) var name : String?
        public internal(set) var groupingType : String?
        public internal(set) var allowedValues: [GroupingConfigData]?
        public internal(set) var customGroups: [GroupingConfigData]?
        public internal( set ) var formula : Formula?
        
        public struct Formula : Equatable
        {
            public internal( set ) var expression : String
            public internal( set ) var details = [ [ String : String ] ]()
            public internal( set ) var duration : Duration?
        }
    }
    
    public struct AggregateColumnInfo : Equatable
    {
        public internal(set) var label : String = APIConstants.STRING_MOCK
        public internal(set) var type : String?
        public internal(set) var name : String?
        public internal(set) var value : String?
        public internal(set) var decimalPlaces: Int?
        public internal(set) var aggregation: [String]?
    }
    
    public struct VerticalGrouping : Equatable, PropertyTransformer
    {
        public static var keyPathAndTransformationDict: [PartialKeyPath<ZCRMDashboardComponent.VerticalGrouping> : Any] = [:]
        public var keyPathAndUnTransformedValuesDict: [PartialKeyPath<ZCRMDashboardComponent.VerticalGrouping> : Any] = [:]
        
        public internal(set) var label : String = APIConstants.STRING_MOCK
        public internal(set) var value: String?
        public internal(set) var key : String?
        public internal(set) var aggregate : [Aggregate] = [Aggregate]()
        public internal(set) var subGrouping:[VerticalGrouping]?
        
        init(label: String, value: String?, key: String?, aggregate: [Aggregate], subGrouping: [VerticalGrouping]?) {
            self.label = label
            self.value = value
            self.key = key
            self.aggregate = aggregate
            self.subGrouping = subGrouping
        }
        
        public static func == (lhs: ZCRMDashboardComponent.VerticalGrouping, rhs: ZCRMDashboardComponent.VerticalGrouping) -> Bool {
            return lhs.label == rhs.label &&
                   lhs.value == rhs.value &&
                   lhs.key == rhs.key &&
                   lhs.aggregate == rhs.aggregate &&
                   lhs.subGrouping == rhs.subGrouping
        }
    }
    
    public struct Aggregate : Equatable, PropertyTransformer
    {
        public static var keyPathAndTransformationDict: [PartialKeyPath<ZCRMDashboardComponent.Aggregate> : Any] = [:]
        public var keyPathAndUnTransformedValuesDict: [PartialKeyPath<ZCRMDashboardComponent.Aggregate> : Any] = [:]
        
        public internal(set) var label : String = APIConstants.STRING_MOCK
        public internal(set) var value : Double = APIConstants.DOUBLE_MOCK
        
        init(label: String, value: Double) {
            self.label = label
            self.value = value
        }
        
        public static func == (lhs: ZCRMDashboardComponent.Aggregate, rhs: ZCRMDashboardComponent.Aggregate) -> Bool {
            return lhs.label == rhs.label &&
                   lhs.value == rhs.value
        }
    }
    
    public struct GroupingConfigData : Equatable
    {
        // TODO : Label should be made a Server filled property
        public internal(set) var label : String?
        public internal(set) var value : String = APIConstants.STRING_MOCK
    }
    
    public struct ComponentMarkers : Equatable
    {
        public internal( set ) var xValue : String? // Can contain userID -> Int64 or PickList values -> String
        public internal( set ) var yValue : AxisData // User's Target
        
        public struct AxisData : Equatable
        {
            public internal( set ) var label : String
            public internal( set ) var value : Int
        }
    }
    
    public struct SegmentRanges : Equatable
    {
        // Start and End Positions are in Percentage
        public internal(set) var color : String = APIConstants.STRING_MOCK  // Color Hex Code
        public internal(set) var startPosition : Int = APIConstants.INT_MOCK // %
        public internal(set) var endPosition : Int = APIConstants.INT_MOCK // %
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
        static let groupingType = "grouping_type"
        static let frequency = "date_granularity"
        
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
        static let id = "id"
        
        static let formula = "formula"
        static let expression = "expression"
        static let details = "details"
        static let refreshStatus = "refresh_status"
    }
}

extension ZCRMDashboardComponent
{
    public static func == (lhs: ZCRMDashboardComponent, rhs: ZCRMDashboardComponent) -> Bool
    {
        let equals = lhs.id == rhs.id &&
            lhs.dashboardId == rhs.dashboardId &&
            lhs.name == rhs.name &&
            lhs.category == rhs.category &&
            lhs.reportId == rhs.reportId &&
            lhs.markers == rhs.markers &&
            lhs.lastFetchedTimeLabel == rhs.lastFetchedTimeLabel &&
            lhs.lastFetchedTimeValue == rhs.lastFetchedTimeValue &&
            lhs.componentChunks == rhs.componentChunks &&
            lhs.maxRows == rhs.maxRows &&
            lhs.objective == rhs.objective &&
            lhs.colorPaletteName == rhs.colorPaletteName &&
            lhs.colorPaletteStartingIndex == rhs.colorPaletteStartingIndex &&
            lhs.segmentRanges == rhs.segmentRanges &&
            lhs.period == rhs.period
        return equals
    }
}

extension ZCRMDashboardComponent
{
    public enum CategoryIdentifier : String, Hashable
    {
        case chart
        case kpi
        case comparator
        case anomalyDetector = "trends"
        case targetMeter = "target_meter"
        case funnel
        case cohort
        case quadrant
        case unknown
        
        static func getIdentifier( rawValue : String ) -> CategoryIdentifier
        {
            if let identifier = CategoryIdentifier( rawValue: rawValue )
            {
                return identifier
            }
            ZCRMLogger.logDebug(message: "UNKNOWN -> Component Category : \( rawValue )")
            return .unknown
        }
    }
    
    public enum Chart: String {
        case pie
        case column
        case bar
        case donut
        case funnel
        case stackedBar = "bar_stacked"
        case stackedColumn = "column_stacked"
        case stackedColumn100Percent = "column_stacked_100percent"
        case stackedBar100Percent = "bar_stacked_100percent"
        case areaspline
        case heatmap
        case table
        case spline
        case unhandled
        
        static func getType(_ rawValue : String) -> Chart
        {
            if let type = Chart( rawValue: rawValue )
            {
                return type
            }
            ZCRMLogger.logDebug(message: "UNHANDLED -> Component type : \( rawValue )")
            return .unhandled
        }
    }

    public enum TargetMeter: String {
        case normalGauge = "dial_gauge_with_max_value"
        case trafficLightGauge = "traffic_list"
        case bar
        case multipleBar = "multiple_bar"
        case unhandled
        
        static func getType(_ rawValue : String) -> TargetMeter
        {
            if let type = TargetMeter( rawValue: rawValue )
            {
                return type
            }
            ZCRMLogger.logDebug(message: "UNHANDLED -> Component type : \( rawValue )")
            return .unhandled
        }
    }

    public enum Comparator : String {
        case elegant
        case classic
        case sport
        case unhandled
        
        static func getType(_ rawValue : String) -> Comparator
        {
            if let type = Comparator( rawValue: rawValue )
            {
                return type
            }
            ZCRMLogger.logDebug(message: "UNHANDLED -> Component type : \( rawValue )")
            return .unhandled
        }
    }

    public enum KPI: String {
        case scoreCard = "scorecard"
        case standard
        case basic
        case growthIndex = "growth_index"
        case rankings = "scorecard_bar"
        case unhandled
        
        static func getType(_ rawValue : String) -> KPI
        {
            if let type = KPI( rawValue: rawValue )
            {
                return type
            }
            ZCRMLogger.logDebug(message: "UNHANDLED -> Component type : \( rawValue )")
            return .unhandled
        }
    }

    public enum Funnel: String {
        case standard
        case compact
        case segment
        case path
        case classic
        case unhandled
        
        static func getType(_ rawValue : String) -> Funnel
        {
            if let type = Funnel( rawValue: rawValue )
            {
                return type
            }
            ZCRMLogger.logDebug(message: "UNHANDLED -> Component type : \( rawValue )")
            return .unhandled
        }
    }

    public enum AnomalyDetector: String {
        case table
        case spline
        case unhandled
        
        static func getType(_ rawValue : String) -> AnomalyDetector
        {
            if let type = AnomalyDetector( rawValue: rawValue )
            {
                return type
            }
            ZCRMLogger.logDebug(message: "UNHANDLED -> Component type : \( rawValue )")
            return .unhandled
        }
    }

    public enum Cohort: String {
        case basic
        case standard
        case advanced
        case unhandled
        
        static func getType(_ rawValue : String) -> Cohort
        {
            if let type = Cohort( rawValue: rawValue )
            {
                return type
            }
            ZCRMLogger.logDebug(message: "UNHANDLED -> Component type : \( rawValue )")
            return .unhandled
        }
    }

    public enum Quadrant: String {
        case standard
        case advanced
        case unhandled
        
        static func getType(_ rawValue : String) -> Quadrant
        {
            if let type = Quadrant( rawValue: rawValue )
            {
                return type
            }
            ZCRMLogger.logDebug(message: "UNHANDLED -> Component type : \( rawValue )")
            return .unhandled
        }
    }

}
