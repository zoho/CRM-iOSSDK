//
//  ZCRMDashBoardComponentColorThemes.swift
//  Pods
//
//  Created by Kalyani shiva on 30/08/18.
//

import Foundation


public class ZCRMDashBoardComponentColorThemes {
    
    
    var name = String()
    var colorPalette = [ColorPalette:[String]]()
    
    
    public enum ColorPalette: String {
        
        case standard
        case general
        case vibrant
        case basic
        
    }
    
}

// Getters

extension ZCRMDashBoardComponentColorThemes {
    
    public func getName() -> String
    {
        return name
    }
    
    public func getColorPalette() -> [ColorPalette:[String]]
    {
        return colorPalette
    }
    
    public func getValuesForColorPalette(Name: ColorPalette) -> [String]?
    {
        switch Name {
        case .standard:
            return colorPalette[.standard]
            
        case .general:
            return colorPalette[.general]
            
        case .vibrant:
            return colorPalette[.vibrant]
            
        case .basic:
            return colorPalette[.basic]
            
        }
    }
    
}

// Setters

extension ZCRMDashBoardComponentColorThemes {
    
    public func set(Name: String)
    {
        name = Name
    }
    
    public func setColor(Palette: [ColorPalette:[String]] )
    {
        colorPalette = Palette
    }
    
}

extension ZCRMDashBoardComponentColorThemes {
    
    struct Properties {
        
        struct ResponseJSONKeys {
            
            static let name = "name"
            static let colorThemes = "color_themes" // DashBoardComponentColorThemes
            static let colorPalettes = "color_palettes"
        }
        
    }
    
}

