//
//  ZCRMDashboardComponentDelegate.swift
//  ZCRMiOS
//
//  Created by Umashri R on 06/05/19.
//

public struct ZCRMDashboardComponentCategory : Equatable {
    public var type : ZCRMDashboardComponentDelegate.ZCRMDashboardComponentType
    public var identifier : ZCRMDashboardComponent.CategoryIdentifier
    
    public static func == ( lhs : ZCRMDashboardComponentCategory, rhs : ZCRMDashboardComponentCategory ) -> Bool
    {
        return lhs.type == rhs.type
    }
}

open class ZCRMDashboardComponentDelegate : ZCRMEntity
{
    public internal(set) var id : Int64 = APIConstants.INT64_MOCK
    internal var dashboardId : Int64 = APIConstants.INT64_MOCK
    public internal(set) var reportId : Int64?
    public internal(set) var category : ZCRMDashboardComponentCategory = ZCRMDashboardComponentCategory(type: .unknown( "" ), identifier: .unknown)
    public internal(set) var name : String = APIConstants.STRING_MOCK
    
    init( cmpId : Int64, name : String, dbId : Int64 )
    {
        self.name = name
        self.id = cmpId
        self.dashboardId = dbId
    }
    
    public enum ZCRMDashboardComponentType : Hashable
    {
        case chart( ZCRMDashboardComponent.Chart )
        case kpi( ZCRMDashboardComponent.KPI )
        case comparator( ZCRMDashboardComponent.Comparator )
        case anomalyDetector( ZCRMDashboardComponent.AnomalyDetector )
        case targetMeter( ZCRMDashboardComponent.TargetMeter )
        case funnel( ZCRMDashboardComponent.Funnel )
        case cohort( ZCRMDashboardComponent.Cohort )
        case quadrant( ZCRMDashboardComponent.Quadrant )
        case unknown( String )
        
        var rawValue : String {
            self.getType()
        }
        
        internal static func getTypeWith( _ category : ZCRMDashboardComponent.CategoryIdentifier, _ rawValue : String) -> ZCRMDashboardComponentType
        {
            switch category
            {
            case .chart :
                return .chart( ZCRMDashboardComponent.Chart.getType( rawValue ) )
            case .kpi :
                return .kpi( ZCRMDashboardComponent.KPI.getType( rawValue ) )
            case .comparator :
                return .comparator( ZCRMDashboardComponent.Comparator.getType( rawValue ) )
            case .anomalyDetector :
                return .anomalyDetector( ZCRMDashboardComponent.AnomalyDetector.getType( rawValue ) )
            case .targetMeter :
                return .targetMeter( ZCRMDashboardComponent.TargetMeter.getType( rawValue ) )
            case .funnel :
                return .funnel( ZCRMDashboardComponent.Funnel.getType( rawValue ) )
            case .cohort :
                return .cohort( ZCRMDashboardComponent.Cohort.getType( rawValue ) )
            case .quadrant :
                return .quadrant( ZCRMDashboardComponent.Quadrant.getType( rawValue ) )
            default :
                return .unknown( rawValue )
            }
        }
        
        private func getType() -> String
        {
            switch self {
            case .kpi( let type ):
                return type.rawValue
            case .funnel( let type ):
                return type.rawValue
            case .quadrant( let type ):
                return type.rawValue
            case .chart( let type ):
                return type.rawValue
            case .comparator( let type ):
                return type.rawValue
            case .anomalyDetector( let type ):
                return type.rawValue
            case .targetMeter(let type ):
                return type.rawValue
            case .cohort( let type ):
                return type.rawValue
            case .unknown( let type ):
                return type
            }
        }
        
        func getKPIType() -> ZCRMDashboardComponent.KPI
        {
            switch self
            {
            case .kpi( let type ) :
                return type
            default :
                ZCRMLogger.logError(message: "The component category must be KPI to use this method but it used on type : \( self )")
                return .unhandled
            }
        }
        
        func getFunnelType() -> ZCRMDashboardComponent.Funnel
        {
            switch self
            {
            case .funnel( let type ) :
                return type
            default :
                ZCRMLogger.logError(message: "The component category must be Funnel to use this method but it used on type : \( self )")
                return .unhandled
            }
        }
        
        func getQuadrantType() -> ZCRMDashboardComponent.Quadrant
        {
            switch self
            {
            case .quadrant( let type ) :
                return type
            default :
                ZCRMLogger.logError(message: "The component category must be Quadrant to use this method but it used on type : \( self )")
                return .unhandled
            }
        }
        
        func getChartType() -> ZCRMDashboardComponent.Chart
        {
            switch self
            {
            case .chart( let type ) :
                return type
            default :
                ZCRMLogger.logError(message: "The component category must be Chart to use this method but it used on type : \( self )")
                return .unhandled
            }
        }
        
        func getComparatorType() -> ZCRMDashboardComponent.Comparator
        {
            switch self
            {
            case .comparator(let type) :
                return type
            default :
                ZCRMLogger.logError(message: "The component category must be Comparator to use this method but it used on type : \( self )")
                return .unhandled
            }
        }
        
        func getAnomalyDetectorType() -> ZCRMDashboardComponent.AnomalyDetector
        {
            switch self
            {
            case .anomalyDetector(let type) :
                return type
            default :
                ZCRMLogger.logError(message: "The component category must be AnomalyDetector to use this method but it used on type : \( self )")
                return .unhandled
            }
        }
        
        func getTargetMeterType() -> ZCRMDashboardComponent.TargetMeter
        {
            switch self
            {
            case .targetMeter(let type) :
                return type
            default :
                ZCRMLogger.logError(message: "The component category must be TargetMeter to use this method but it used on type : \( self )")
                return .unhandled
            }
        }
        
        func getCohortType() -> ZCRMDashboardComponent.Cohort
        {
            switch self
            {
            case .cohort(let type) :
                return type
            default :
                ZCRMLogger.logError(message: "The component category must be Cohort to use this method but it used on type : \( self )")
                return .unhandled
            }
        }
        
        public static func == ( lhs : ZCRMDashboardComponentType, rhs : ZCRMDashboardComponentType ) -> Bool
        {
            switch ( lhs, rhs )
            {
            case ( .chart( let lhsType ), .chart( let rhsType ) ) :
                if lhsType == rhsType
                {
                    return true
                }
                return false
            case ( .kpi( let lhsType ), .kpi( let rhsType ) ) :
                if lhsType == rhsType
                {
                    return true
                }
                return false
            case ( .comparator( let lhsType ), .comparator( let rhsType ) ) :
                if lhsType == rhsType
                {
                    return true
                }
                return false
            case ( .anomalyDetector( let lhsType ), .anomalyDetector( let rhsType ) ) :
                if lhsType == rhsType
                {
                    return true
                }
                return false
            case ( .targetMeter( let lhsType ), .targetMeter( let rhsType ) ) :
                if lhsType == rhsType
                {
                    return true
                }
                return false
            case ( .funnel( let lhsType ), .funnel( let rhsType ) ) :
                if lhsType == rhsType
                {
                    return true
                }
                return false
            case ( .cohort( let lhsType ), .cohort( let rhsType ) ) :
                if lhsType == rhsType
                {
                    return true
                }
                return false
            case ( .quadrant( let lhsType ), .quadrant( let rhsType ) ) :
                if lhsType == rhsType
                {
                    return true
                }
                return false
            case ( .unknown( let lhsType ), .unknown( let rhsType ) ) :
                if lhsType == rhsType
                {
                    return true
                }
                return false
            default :
                return false
            }
        }
    }
}

extension ZCRMDashboardComponentDelegate : Hashable
{
    public static func == (lhs: ZCRMDashboardComponentDelegate, rhs: ZCRMDashboardComponentDelegate) -> Bool {
        let equals = lhs.id == rhs.id &&
            lhs.dashboardId == rhs.dashboardId &&
            lhs.reportId == rhs.reportId &&
            lhs.category == rhs.category &&
            lhs.name == rhs.name
        return equals
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine( id )
    }
}
