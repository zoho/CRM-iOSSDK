//
//  ZCRMDashBoard.swift
//
//  Created by Kalyani shiva on 12/07/18.
//

import Foundation

public class ZCRMDashboard{
    
    fileprivate var id: Int64
    fileprivate var name: String
    fileprivate var isSystemGenerated = Bool()
    fileprivate var isSalesTrends = Bool()
    fileprivate var accessType = String()
    fileprivate var dashboardComponentMeta:[ZCRMDashboardComponentMeta]?
    
    init(id: Int64, name: String) {
        self.id = id
        self.name = name
    }
    
    
    struct Properties {
        
        static let jsonRootKey = "Analytics"
        
        struct URLPathName {
            static let ANALYTICS = "Analytics"
            static let COMPONENTS = "components"
            static let REFRESH = "refresh"
            static let COLORTHEMES = "color_themes"
        }
        
        struct ResponseJSONKeys {
            static let dashboardID = "id"
            static let dashboardName = "name"
            static let isSystemGenerated = "system_generated"
            static let isSalesTrends = "trends"
            static let accessType = "access_type"
            static let metaComponents = "components"
        }
    }
}


extension ZCRMDashboard: CustomDebugStringConvertible{
    public var debugDescription: String{
        
        return """
        
        <--- DASHBOARD DEBUG DESCRIPTION --->
        
        DASHBOARD PROPERTIES
        
        ID : \(id)
        Name : \(name)
        System Generated Dashboard : \(isSystemGenerated)
        Sales Trend : \(isSalesTrends)
        Access Type : \(accessType)
        Meta Component : \(String(describing: getArrayOfDashBoardComponentMeta()))
        
        <-------------------------------------------->
        
        """
    }
}

//Dashboard Refresh ...
extension ZCRMDashboard {
    
    public typealias refreshResponse = ZCRMAnalytics.refreshResponse
    public typealias dashboardComponent = ZCRMAnalytics.dashboardComponent
    
    
    public func refresh(onCompletion: @escaping refreshResponse) {
        
        DashboardAPIHandler().refreshDashboardForObject(self) { (refreshResult) in
            onCompletion(refreshResult)
        }
        
    } // func ends
    
    
    public func getComponentWith(id cmpID: Int64, onCompletion:
        @escaping dashboardComponent)
        
    {
        let dashboardId = self.id
        
        DashboardAPIHandler().getComponentWith(id: cmpID, fromDashboardID: dashboardId) {
            (resultType) in
            
            onCompletion(resultType)
        }
        
    } // func ends
    
    
} // extension ends


extension ZCRMDashboard { // Settters
    
    func setId(id:Int64?){
        self.id =  id ?? Int64()
    }
    
    func setName(name:String?){
        self.name = name ?? String()
    }
    
    func setIfSystemGenerated(_ value:Bool?){
        isSystemGenerated = value ?? Bool()
    }
    
    func setIfSalesTrend(_ value:Bool?){
        isSalesTrends = value ?? Bool()
    }
    
    func setAccessTypeAs(_ value:String?){
        accessType = value ?? String()
    }
    
    func setArrayOfDashBoardComponentMeta(_ value:[ZCRMDashboardComponentMeta]){
        
        dashboardComponentMeta = value
    }
    
}

extension ZCRMDashboard { // Getters
    
    public func getId() -> Int64{
        return id
    }
    
    public func getName() -> String{
        return name
    }
    
    public func getIfSystemGenerated() -> Bool{
        return isSystemGenerated
    }
    
    public func getIfSalesTrend() -> Bool{
        return isSalesTrends
    }
    
    public func getAccessType() -> String{
        return accessType
    }
    
    public func getArrayOfDashBoardComponentMeta() -> [ZCRMDashboardComponentMeta]?{
        return dashboardComponentMeta
    }
    
}


