//
//  ZCRMDashBoardComponentColorThemes.swift
//  ZCRMiOS
//
//  Created by Kalyani shiva on 30/08/18.
//
import Foundation
open class ZCRMAnalyticsColorThemes {
    
    public internal(set) var name : String = APIConstants.STRING_MOCK
    var colorPalette = [ColorPalette:[String]]()
    
    public enum ColorPalette: String {
        case standard
        case general
        case vibrant
        case basic
        case cohortBasicPalette = "Cohort Basic Palette"
    }
    
    public func getColors( colorPaletteType : ColorPalette ) -> [ String ]?
    {
        switch colorPaletteType {
        case .standard:
            return colorPalette[.standard]
        case .general:
            return colorPalette[.general]
        case .vibrant:
            return colorPalette[.vibrant]
        case .basic:
            return colorPalette[.basic]
        case .cohortBasicPalette:
            return colorPalette[.cohortBasicPalette]
        }
    }
    
    public func getColor( colorPaletteType : ColorPalette, index : Int ) -> String?
    {
        let colorPalette : [ String ]? = self.colorPalette[ colorPaletteType ]
        return colorPalette?[ index ]
    }
}
extension ZCRMAnalyticsColorThemes
{
    struct ResponseJSONKeys
    {
        static let name = "name"
        static let colorThemes = "color_themes" // DashBoardComponentColorThemes
        static let colorPalettes = "color_palettes"
    }
}
