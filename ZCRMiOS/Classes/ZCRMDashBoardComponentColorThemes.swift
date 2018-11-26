//
//  ZCRMDashBoardComponentColorThemes.swift
//  ZCRMiOS
//
//  Created by Kalyani shiva on 30/08/18.
//
import Foundation
open class ZCRMDashboardComponentColorThemes {
    
    public var name : String = APIConstants.STRING_MOCK
    var colorPalette = [ColorPalette:[String]]()
    
    public enum ColorPalette: String {
        case standard
        case general
        case vibrant
        case basic
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
extension ZCRMDashboardComponentColorThemes
{
    struct Properties
    {
        struct ResponseJSONKeys
        {
            static let name = "name"
            static let colorThemes = "color_themes" // DashBoardComponentColorThemes
            static let colorPalettes = "color_palettes"
        }
    }
}
