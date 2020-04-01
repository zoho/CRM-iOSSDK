//
//  ZCRMDashBoard.swift
//
//  Created by Kalyani shiva on 12/07/18.
//
import Foundation
public class ZCRMDashboard : ZCRMEntity {
    
    public internal( set ) var id : Int64 = APIConstants.INT64_MOCK
    public internal( set ) var name : String = APIConstants.STRING_MOCK
    public internal( set ) var isSystemGenerated : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var isTrends : Bool?
    public internal( set ) var accessType : String?
    public internal( set ) var componentMeta : [ ZCRMDashboardComponentMeta ]?
    public internal( set ) var isFavourite : Bool?
    
    init(id: Int64, name: String)
    {
        self.id = id
        self.name = name
    }
    
    static let jsonRootKey = "Analytics"
    
    struct URLPathConstants
    {
        static let analytics = "Analytics"
        static let components = "components"
        static let refresh = "refresh"
        static let colorThemes = "color_themes"
        static let data = "data"
        static let image = "image"
    }
    
    struct ResponseJSONKeys
    {
        static let dashboardID = "id"
        static let dashboardName = "name"
        static let isSystemGenerated = "system_generated"
        static let isSalesTrends = "trends"
        static let accessType = "access_type"
        static let metaComponents = "components"
        static let favorited = "favorited"
    }
    
    public func refresh(onCompletion: @escaping refreshResponse)
    {
        DashboardAPIHandler(cacheFlavour: .noCache).refreshDashboardForObject(self) { (refreshResult) in
            onCompletion(refreshResult)
        }
    } // func ends
}
//Dashboard Refresh ...
extension ZCRMDashboard
{
    public typealias refreshResponse = ZCRMSDKUtil.ZCRMAnalytics.RefreshResponse
    public typealias dashboardComponent = ZCRMSDKUtil.ZCRMAnalytics.DashboardComponent
} // extension ends

extension ZCRMDashboard : Hashable
{
    public func hash(into hasher: inout Hasher) {
        hasher.combine( self.id )
    }
    
    public static func == (lhs: ZCRMDashboard, rhs: ZCRMDashboard) -> Bool {
        return lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.isSystemGenerated == rhs.isSystemGenerated &&
            lhs.isTrends == rhs.isTrends &&
            lhs.accessType == rhs.accessType &&
            lhs.componentMeta == rhs.componentMeta
    }
}
