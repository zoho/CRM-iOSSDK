//
//  ZCRMDashboardComponentDelegate.swift
//  ZCRMiOS
//
//  Created by Umashri R on 06/05/19.
//

open class ZCRMDashboardComponentDelegate : ZCRMEntity
{
    public internal(set) var id : Int64 = APIConstants.INT64_MOCK
    internal var dashboardId : Int64 = APIConstants.INT64_MOCK
    public internal(set) var reportId : Int64?
    public internal(set) var category : ComponentCategory = ComponentCategory.chart
    public internal(set) var name : String = APIConstants.STRING_MOCK
    
    init( cmpId : Int64, name : String, dbId : Int64 )
    {
        self.name = name
        self.id = cmpId
        self.dashboardId = dbId
    }
    
    public enum ComponentCategory : String
    {
        case chart = "chart"
        case kpi = "kpi"
        case comparator = "comparator"
        case anomalyDetector = "trends"
        case targetMeter = "target_meter"
        case funnel = "funnel"
        case cohort = "cohort"
        case quadrant = "quadrant"
        case unknown
        
        init( componentCategory : String )
        {
            if let code = ComponentCategory( rawValue : componentCategory )
            {
                self = code
            }
            else
            {
                ZCRMLogger.logDebug(message: "UNKNOWN -> Component Category : \( componentCategory )")
                self = .unknown
            }
        }
    }
}

extension ZCRMDashboardComponentDelegate : Equatable
{
    public static func == (lhs: ZCRMDashboardComponentDelegate, rhs: ZCRMDashboardComponentDelegate) -> Bool {
        let equals = lhs.id == rhs.id &&
            lhs.dashboardId == rhs.dashboardId &&
            lhs.reportId == rhs.reportId &&
            lhs.category == rhs.category &&
            lhs.name == rhs.name
        return equals
    }
}
