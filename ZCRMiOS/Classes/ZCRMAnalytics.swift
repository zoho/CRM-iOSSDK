//
//  ZCRMAnalytics.swift
//  ZCRMiOS
//
//  Created by Kalyani shiva on 02/09/18.
//

import Foundation

public class ZCRMAnalytics {
    
    // SINGLETON OBJECT : There's no need for more than one instance of ZCRMAnalytics to exist
    // It's not actually a class and is just used for grouping methods under a name
    // No stored Properties and methods to manipulate properties
    private init(){}
    public static var shared = ZCRMAnalytics()
    
}


//MARK:- Public Getters
extension ZCRMAnalytics {
    
    public func getAllDashboards(then onCompletion:@escaping ArrayOfDashboards)
        
    {
        // 200 is the maxNumber of records that can be retreived in an API Call
        DashboardAPIHandler().getAllDashboards(fromPage: 1, withPerPageOf: 200) {
            (resultType) in
            onCompletion(resultType)
        }
        
    }
    
    
    public func getAllDashboards(fromPage page:Int, perPage:Int, then onCompletion:
        @escaping ArrayOfDashboards)
        
    {
        
        DashboardAPIHandler().getAllDashboards(fromPage: page,withPerPageOf: perPage) {
            
            (resultType) in
            onCompletion(resultType)
        }
        
    }
    
    
    public func getDashboardWithId(id: Int64,then onCompletion:
        @escaping dashboard)
        
    {
        DashboardAPIHandler().getDashboardWithId(id: id) {
            (resultType) in
            onCompletion(resultType)
        }
        
    }
    
    
    public func getDashboardComponentColorThemes( onCompletion:
        @escaping ArrayOfColorThemes )
        
    {
        
        DashboardAPIHandler().getDashboardComponentColorThemes { (resultType) in
            
            onCompletion(resultType)
        }
        
    }
    
    
} // end of class


//MARK:- (TypeAliases) Used by Model and Handler Classes
extension ZCRMAnalytics {
    
    public typealias dashboard =
        (Result.DataResponse<ZCRMDashboard,APIResponse>) -> Void
    
    public typealias ArrayOfDashboards =
        (Result.DataResponse<[ZCRMDashboard],BulkAPIResponse>) -> Void
    
    public typealias ArrayOfColorThemes = (Result.DataResponse<[ZCRMDashboardComponentColorThemes],APIResponse>) -> Void
    
    public typealias refreshResponse =
        (Result.Response<APIResponse>) -> Void
    
    public typealias dashboardComponent =
        (Result.DataResponse<ZCRMDashboardComponent,APIResponse>) -> Void
    
}
