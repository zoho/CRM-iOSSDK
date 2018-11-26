//
//  ZCRMDashBoardComponentMeta.swift
//  ZCRMiOS
//
//  Created by Kalyani shiva on 30/07/18.
//
import Foundation
public class ZCRMDashboardComponentMeta : ZCRMEntity
{
    public var componentID : Int64 = APIConstants.INT64_MOCK
    public var componentName : String = APIConstants.STRING_MOCK
    public var isFavouriteComponent : Bool = APIConstants.BOOL_MOCK
    public var isSystemGenerated : Bool = APIConstants.BOOL_MOCK
    public var properties : LayoutProperties = LayoutProperties()
    
    public struct LayoutProperties
    {
        public var componentXPosition:Int?
        public var componentYPosition:Int?
        public var componentWidth:Int?
        public var componentHeight:Int?
    }
    
    struct Properties
    {
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
        }
    }
}
