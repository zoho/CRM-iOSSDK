//
//  ZCRMDashBoard.swift
//
//  Created by Kalyani shiva on 12/07/18.
//

import Foundation

public class ZCRMDashBoard{
    
    fileprivate var dashBoardID = Int64()
    fileprivate var dashBoardName = String()
    fileprivate var isSystemGenerated = Bool()
    fileprivate var isSalesTrends = Bool()
    fileprivate var accessType = String()
    fileprivate var dashBoardMetaComponent:[ZCRMDashBoardMetaComponent]?
    
    struct Properties {
        
        static let jsonRootKey = "Analytics"
        
        struct URLPathName {
            static let ANALYTICS = "Analytics"
            static let COMPONENTS = "components"
            static let REFRESH = "refresh"
            static let COLORTHEMES = "color_themes"
        }
        
        struct APINames {
            static let dashBoardID = "id"
            static let dashBoardName = "name"
            static let isSystemGenerated = "system_generated"
            static let isSalesTrends = "trends"
            static let accessType = "access_type"
            static let metaComponents = "components"
        }
        
    }
    
}


extension ZCRMDashBoard: CustomDebugStringConvertible{
    
    public var debugDescription: String{
        
        return """
        
        <--- DASHBOARD DEBUG DESCRIPTION --->
        
        DASHBOARD PROPERTIES
        
        ID : \(dashBoardID)
        Name : \(dashBoardName)
        System Generated Dashboard : \(isSystemGenerated)
        Sales Trend : \(isSalesTrends)
        Access Type : \(accessType)
        Meta Component : \(String(describing: getArrayOfDashBoardMetaComponent()))
        
        <-------------------------------------------->
        
        """
    }
    
}


extension ZCRMDashBoard { // Settters
    
    public func setDashBoard(ID:String?){
        self.dashBoardID =  Int64(ID ?? "default") ?? Int64()
    }
    
    public func setDashBoard(Name:String?){
        dashBoardName = Name ?? String()
    }
    
    public func setIfDashBoardIsSystemGenerated(_ value:Bool?){
        isSystemGenerated = value ?? Bool()
    }
    
    public func setIfDashBoardIsSalesTrend(_ value:Bool?){
        isSalesTrends = value ?? Bool()
    }
    
    public func setDashBoardAccessType(_ value:String?){
        accessType = value ?? String()
    }
    
    internal func setArrayOfDashBoardMetaComponent(_ value:[ZCRMDashBoardMetaComponent]){
        
        dashBoardMetaComponent = value
    }
    
}

extension ZCRMDashBoard { // Getters
    
    public func getDashBoardID() -> Int64{
        return dashBoardID
    }
    
    public func getDashBoardName() -> String{
        return dashBoardName
    }
    
    public func getIfDashBoardIsSystemGenerated() -> Bool{
        return isSystemGenerated
    }
    
    public func getIfDashBoardIsSalesTrend() -> Bool{
        return isSalesTrends
    }
    
    public func getDashBoardAccessType() -> String{
        return accessType
    }
    
    public func getArrayOfDashBoardMetaComponent() -> [ZCRMDashBoardMetaComponent]?{
        return dashBoardMetaComponent
    }
    
}

