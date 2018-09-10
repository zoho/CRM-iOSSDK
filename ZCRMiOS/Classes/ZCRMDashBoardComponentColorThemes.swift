//
//  ZCRMDashBoardComponentColorThemes.swift
//  Pods
//
//  Created by Kalyani shiva on 30/08/18.
//

import Foundation


public class ZCRMDashboardComponentColorThemes {
    
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
extension ZCRMDashboardComponentColorThemes {
    
    public func getColorThemeName() -> String
    {
        return name
    }
    
    public func getColorPalette() -> [ColorPalette:[String]]
    {
        return colorPalette
    }
    
    public func getValuesForColorPaletteName(name: ColorPalette) -> [String]?
    {
        switch name {
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
extension ZCRMDashboardComponentColorThemes {
    
    func setColorThemeName(name: String)
    {
        self.name = name
    }
    
    func setColorPalette(palette: [ColorPalette:[String]] )
    {
        colorPalette = palette
    }
    
}

extension ZCRMDashboardComponentColorThemes {
    
    struct Properties {
        
        struct ResponseJSONKeys {
            
            static let name = "name"
            static let colorThemes = "color_themes" // DashBoardComponentColorThemes
            static let colorPalettes = "color_palettes"
        }
    }
}

