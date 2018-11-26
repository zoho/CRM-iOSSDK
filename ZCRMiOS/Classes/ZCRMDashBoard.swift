//
//  ZCRMDashBoard.swift
//
//  Created by Kalyani shiva on 12/07/18.
//
import Foundation
public class ZCRMDashboard{
    
    public var id : Int64 = APIConstants.INT64_MOCK
    public var name : String = APIConstants.STRING_MOCK
    public var isSystemGenerated : Bool?
    public var isSalesTrends :Bool?
    public var accessType : String?
    public var dashboardComponentMeta:[ZCRMDashboardComponentMeta]?
    
    init(id: Int64, name: String)
    {
        self.id = id
        self.name = name
    }
    
    struct Properties
    {
        static let jsonRootKey = "Analytics"
        
        struct URLPathName
        {
            static let ANALYTICS = "Analytics"
            static let COMPONENTS = "components"
            static let REFRESH = "refresh"
            static let COLORTHEMES = "color_themes"
        }
        
        struct ResponseJSONKeys
        {
            static let dashboardID = "id"
            static let dashboardName = "name"
            static let isSystemGenerated = "system_generated"
            static let isSalesTrends = "trends"
            static let accessType = "access_type"
            static let metaComponents = "components"
        }
    }
    
    public func refresh(onCompletion: @escaping refreshResponse)
    {
        DashboardAPIHandler().refreshDashboardForObject(self) { (refreshResult) in
            onCompletion(refreshResult)
        }
    } // func ends
    
    public func getComponentWith(id cmpID: Int64, onCompletion: @escaping dashboardComponent)
    {
        let dashboardId = self.id
        DashboardAPIHandler().getComponentWith(id: cmpID, fromDashboardID: dashboardId) {
            (resultType) in
            onCompletion(resultType)
        }
    } // func ends
}
//Dashboard Refresh ...
extension ZCRMDashboard
{
    public typealias refreshResponse = ZCRMAnalytics.RefreshResponse
    public typealias dashboardComponent = ZCRMAnalytics.DashboardComponent
} // extension ends

