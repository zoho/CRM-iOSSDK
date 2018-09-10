//
//  ZCRMDashBoardComponentMeta.swift
//  Pods
//
//  Created by Kalyani shiva on 30/07/18.
//

import Foundation

public class ZCRMDashboardComponentMeta {
    
    fileprivate var componentID = Int64()
    fileprivate var componentName = String()
    fileprivate var isFavouriteComponent = Bool()
    fileprivate var isSystemGenerated = Bool()
    fileprivate var properties = LayoutProperties()
    
    public struct LayoutProperties {
        
        fileprivate var componentXPosition:Int?
        fileprivate var componentYPosition:Int?
        fileprivate var componentWidth:Int?
        fileprivate var componentHeight:Int?
    }
    
    struct Properties {
        
        struct ResponseJSONKeys {
            
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

extension ZCRMDashboardComponentMeta: CustomDebugStringConvertible{
    public var debugDescription: String {
        return """
        
        <---- META-COMPONENT DEBUG DESCRIPTION ----->
        
        COMPONENT GENERAL PROPERTIES
        
        ID: \(componentID)
        Name: \(componentName)
        System Generated Component: \(isSystemGenerated)
        Favourite Component: \(isFavouriteComponent)
        
        COMPONENT LAYOUT PROPERTIES
        
        xPosition: \(String(describing: properties.componentXPosition))
        yPosition: \(String(describing: properties.componentYPosition))
        Width: \(String(describing: properties.componentWidth))
        Height: \(String(describing: properties.componentHeight))
        
        <-------------------------------------------->
        
        """
    }
}


//MARK:- Meta Component Layout Properties Setters

extension ZCRMDashboardComponentMeta.LayoutProperties {
    
    mutating func setComponentXPosition(position:Int?)
    {
        componentXPosition = position
    }
    
    mutating func setComponentYPosition(position:Int?)
    {
        componentYPosition = position
    }
    
    mutating func setComponentWidth(width:Int?)
    {
        componentWidth = width
    }
    
    mutating func setComponentHeight(height:Int?)
    {
        componentHeight = height
    }
    
}


//MARK:- Meta Component Layout Properties Getters

extension ZCRMDashboardComponentMeta.LayoutProperties {
    
    public mutating func getComponentXPosition() -> Int?
    {
        return componentXPosition
    }
    
    public mutating func getComponentYPosition() -> Int?
    {
        return componentYPosition
    }
    
    public mutating func getComponentWidth() -> Int?
    {
        return componentWidth
    }
    
    public mutating func getComponentHeight() -> Int?
    {
        return componentHeight
    }
    
}



//MARK:- Meta Component Setters

extension ZCRMDashboardComponentMeta {
    
    func setid(id:Int64?)
    {
        componentID = id ?? Int64()
    }
    
    func setName(name:String?)
    {
        componentName = name ?? String()
    }
    
    func setIfSystemGenerated(_ value:Bool?)
    {
        isSystemGenerated = value ?? Bool()
    }
    
    func setIfFavourite(_ value:Bool?)
    {
        isFavouriteComponent = value ?? Bool()
    }
    
    func setLayoutProperties(_ layoutProps:LayoutProperties)
    {
        self.properties = layoutProps
    }
    
}


//MARK:- Metacomponent Getters

extension ZCRMDashboardComponentMeta {
    
    public func getComponentID() -> Int64
    {
        return componentID
    }
    
    public func getComponentName() -> String
    {
        return componentName
    }
    
    public func getIfComponentIsSystemGenerated() -> Bool
    {
        return isSystemGenerated
    }
    
    public func getIfComponentIsFavourite() -> Bool
    {
        return isFavouriteComponent
    }
    
    public func getLayoutProperties() -> LayoutProperties
    {
        return properties
    }
}


