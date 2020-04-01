//
//  ZCRMDashBoardComponentMeta.swift
//  ZCRMiOS
//
//  Created by Kalyani shiva on 30/07/18.
//
import Foundation
public class ZCRMDashboardComponentMeta : ZCRMEntity
{
    public internal( set ) var id : Int64
    public internal( set ) var name : String
    public internal( set ) var isFavourite : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var isSystemGenerated : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var layoutProperties : LayoutProperties = LayoutProperties()
    public internal( set ) var type : String = APIConstants.STRING_MOCK
    public internal( set ) var category : ZCRMDashboardComponent.ComponentCategory = ZCRMDashboardComponent.ComponentCategory.chart
    public internal( set ) var isEditable : Bool = APIConstants.BOOL_MOCK
    internal var dashboardId : Int64
    public typealias dashboardComponent = ZCRMSDKUtil.ZCRMAnalytics.DashboardComponent
    
    init( id : Int64, name : String, type : String, dashboardId : Int64 )
    {
        self.id = id
        self.name = name
        self.type = type
        self.dashboardId = dashboardId
    }
    
    public func getComponent(onCompletion: @escaping dashboardComponent)
    {
        DashboardAPIHandler(cacheFlavour: .urlVsResponse).getComponentWith(id: self.id, fromDashboardID: self.dashboardId, name : self.name, category : self.category , period: nil) {
            (resultType) in
            onCompletion(resultType)
        }
    } // func ends
    
    public func getComponentFromServer(onCompletion: @escaping dashboardComponent)
    {
        DashboardAPIHandler(cacheFlavour: .noCache).getComponentWith(id: self.id, fromDashboardID: self.dashboardId, name : self.name, category : self.category, period: nil) {
            (resultType) in
            onCompletion(resultType)
        }
    } // func ends
    
    public func getComponent(period : ComponentPeriod, onCompletion: @escaping dashboardComponent)
    {
        DashboardAPIHandler(cacheFlavour: .urlVsResponse).getComponentWith(id: self.id, fromDashboardID: self.dashboardId, name : self.name, category : self.category, period: period) {
            (resultType) in
            onCompletion(resultType)
        }
    } // func ends
    
    public func getComponentFromServer(period : ComponentPeriod, onCompletion: @escaping dashboardComponent)
    {
        DashboardAPIHandler(cacheFlavour: .noCache).getComponentWith(id: self.id, fromDashboardID: self.dashboardId, name : self.name, category : self.category, period: period) {
            (resultType) in
            onCompletion(resultType)
        }
    } // func ends
    
    public struct LayoutProperties : Equatable
    {
        public internal( set ) var x : Int?
        public internal( set ) var y : Int?
        public internal( set ) var width : Int?
        public internal( set ) var height : Int?
        
        public static func == (lhs: LayoutProperties, rhs: LayoutProperties) -> Bool {
            return lhs.x == rhs.x &&
                lhs.y == rhs.y &&
                lhs.width == rhs.width &&
                lhs.height == rhs.height
        }
    }
    
    struct ResponseJSONKeys
    {
        static let componentID = "id"
        static let componentName = "name"
        static let favouriteComponent = "favorited"
        static let componentWidth = "width"
        static let componentHeight = "height"
        static let componentXPosition = "x"
        static let componentYPosition = "y"
        static let systemGenerated = "system_generated"
        static let itemProps = "item_props"
        static let layout = "layout"
        static let componentType = "component_type"
        static let editable = "editable"
    }
}

extension ZCRMDashboardComponentMeta : Hashable
{
    public func hash( into hasher : inout Hasher ) {
        hasher.combine( id )
    }
    
    public static func == (lhs: ZCRMDashboardComponentMeta, rhs: ZCRMDashboardComponentMeta) -> Bool {
        return lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.isFavourite == rhs.isFavourite &&
            lhs.isSystemGenerated == rhs.isSystemGenerated &&
            lhs.layoutProperties == rhs.layoutProperties &&
            lhs.category == rhs.category &&
            lhs.isEditable == rhs.isEditable
    }
}
