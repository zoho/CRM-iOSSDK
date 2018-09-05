//
//  ZCRMDashBoardMetaComponent.swift
//  Pods
//
//  Created by Kalyani shiva on 30/07/18.
//

import Foundation

public class ZCRMDashBoardMetaComponent {
    
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

extension ZCRMDashBoardMetaComponent: CustomDebugStringConvertible{
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

extension ZCRMDashBoardMetaComponent.LayoutProperties {
    
    mutating func setComponentX(position:Int?)
    {
        componentXPosition = position
    }
    
    mutating func setComponentY(position:Int?)
    {
        componentYPosition = position
    }
    
    mutating func setComponent(width:Int?)
    {
        componentWidth = width
    }
    
    mutating func setComponent(height:Int?)
    {
        componentHeight = height
    }
    
}


//MARK:- Meta Component Layout Properties Getters

extension ZCRMDashBoardMetaComponent.LayoutProperties {
    
    mutating func getComponentXPosition() -> Int?
    {
        return componentXPosition
    }
    
    mutating func getComponentYPosition() -> Int?
    {
        return componentYPosition
    }
    
    mutating func getComponentWidth() -> Int?
    {
        return componentWidth
    }
    
    mutating func getComponentHeight() -> Int?
    {
        return componentHeight
    }
    
}



//MARK:- Meta Component Setters

extension ZCRMDashBoardMetaComponent {
    
    func setComponent(ID:Int64?)
    {
        componentID = ID ?? Int64()
    }
    
    func setComponent(Name:String?)
    {
        componentName = Name ?? String()
    }
    
    func setIfComponentIsSystemGenerated(_ value:Bool?)
    {
        isSystemGenerated = value ?? Bool()
    }
    
    func setIfComponentIsFavourite(_ value:Bool?)
    {
        isFavouriteComponent = value ?? Bool()
    }
    
    func setLayoutProperties(_ layoutProps:LayoutProperties)
    {
        self.properties = layoutProps
    }
    
}


//MARK:- Metacomponent Getters

extension ZCRMDashBoardMetaComponent {
    
    func getComponentID() -> Int64
    {
        return componentID
    }
    
    func getComponentName() -> String
    {
        return componentName
    }
    
    func getIfComponentIsSystemGenerated() -> Bool
    {
        return isSystemGenerated
    }
    
    func getIfComponentIsFavourite() -> Bool
    {
        return isFavouriteComponent
    }
    
    func getLayoutProperties() -> LayoutProperties
    {
        return properties
    }
}


