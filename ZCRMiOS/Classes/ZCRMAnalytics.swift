//
//  ZCRMAnalytics.swift
//  ZCRMiOS
//
//  Created by Kalyani shiva on 02/09/18.
//

import Foundation

public class ZCRMAnalytics {
    
    public typealias dashBoard =
        (Result.DataResponse<ZCRMDashBoard,APIResponse>) -> Void
    
    public typealias ArrayOfDashBoards = (Result.DataResponse<[ZCRMDashBoard],BulkAPIResponse>) -> Void
    
    public typealias dashBoardComponent = (Result.DataResponse<ZCRMDashBoardComponent,APIResponse>) -> Void
    
    public typealias refreshResponse = (Result.Response<APIResponse>) -> Void
    
    public typealias ArrayOfColorThemes = (Result.DataResponse<[ZCRMDashBoardComponentColorThemes],APIResponse>) -> Void
    
}

//MARK:- Public Getters
extension ZCRMAnalytics {
    
    public func getAllDashBoards(then onCompletion:@escaping ArrayOfDashBoards)
        
    {
        // 200 is the maxNumber of records that can be retreived in an API Call
        DashBoardAPIHandler().getAllDashBoards(fromPage: 1, withPerPageOf: 200) {
            (resultType) in
            onCompletion(resultType)
        }
        
    }
    
    
    public func getAllDashboards(fromPage page:Int?,perPage:Int?,then onCompletion: @escaping ArrayOfDashBoards)
        
    {
        let unwrappedPage = page ?? 1
        let unwrappedPerPage = perPage ?? 200
        
        DashBoardAPIHandler().getAllDashBoards(fromPage: unwrappedPage,withPerPageOf: unwrappedPerPage) {
            
            (resultType) in
            onCompletion(resultType)
        }
        
    }
    
    
    public func getDashBoardWith(id:Int64,then onCompletion:
        @escaping dashBoard)
        
    {
        DashBoardAPIHandler().getDashBoardWith(id: id) {
            (resultType) in
            onCompletion(resultType)
        }
        
    }
    
    
    public func getComponentWith(id cmpID: Int64, fromDashBoardID dbId: Int64,onCompletion:
        @escaping dashBoardComponent)
        
    {
        
        DashBoardAPIHandler().getComponentWith(id: cmpID, fromDashBoardID: dbId) {
            (resultType) in
            
            onCompletion(resultType)
        }
        
    }
    
    
    
    public func refreshComponentWith(id cmpID: Int64,inDashBoardID dbId: Int64,onCompletion:
        @escaping refreshResponse)
        
    {
        
        DashBoardAPIHandler().refreshComponentWith(id: cmpID, inDashBoardID: dbId) {
            (resultType) in
            
            onCompletion(resultType)
        }
        
    }
    
    
    
    public func refreshDashBoardWith(id dbId: Int64,onCompletion:
        @escaping refreshResponse)
        
    {
        
        DashBoardAPIHandler().refreshDashBoardWith(id: dbId) { (resultType) in
            
            onCompletion(resultType)
            
        }
        
    }
    
    
    
    public func getDashBoardComponentColorThemes( onCompletion:
        @escaping ArrayOfColorThemes )
        
    {
        
        DashBoardAPIHandler().getDashBoardComponentColorThemes { (resultType) in
            
            onCompletion(resultType)
        }
        
    }
    
    
} // end of class
