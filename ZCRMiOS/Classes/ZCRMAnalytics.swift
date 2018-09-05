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
    
    public func getAllDashBoards(then Oncompletion:@escaping ArrayOfDashBoards)
        
    {
        // 200 is the maxNumber of records that can be retreived in an API Call
        DashBoardAPIHandler().getAllDashBoards(FromPage: 1, WithPerPageOf: 200) {
            (resultType) in
            Oncompletion(resultType)
        }
        
    }
    
    
    public func getAllDashboards(FromPage page:Int?,PerPage perPage:Int?,then Oncompletion: @escaping ArrayOfDashBoards)
        
    {
        let unwrappedPage = page ?? 1
        let unwrappedPerPage = perPage ?? 200
        
        DashBoardAPIHandler().getAllDashBoards(FromPage: unwrappedPage, WithPerPageOf: unwrappedPerPage) {
            (resultType) in
            Oncompletion(resultType)
        }
        
    }
    
    
    public func getDashBoardWith(ID:Int64,then OnCompletion:
        @escaping dashBoard)
        
    {
        DashBoardAPIHandler().getDashBoardWith(ID: ID) {
            (resultType) in
            OnCompletion(resultType)
        }
        
    }
    
    
    public func getComponentWith(ID cmpID: Int64, FromDashBoardID dbID: Int64,OnCompletion:
        @escaping dashBoardComponent)
        
    {
        
        DashBoardAPIHandler().getComponentWith(ID: cmpID, FromDashBoardID: dbID) {
            (resultType) in
            
            OnCompletion(resultType)
        }
        
    }
    
    
    
    public func refreshComponentWith(ID cmpID: Int64,InDashBoardID dbID: Int64,OnCompletion:
        @escaping refreshResponse)
        
    {
        
        DashBoardAPIHandler().refreshComponentWith(ID: cmpID, InDashBoardID: dbID) {
            (resultType) in
            
            OnCompletion(resultType)
        }
        
    }
    
    
    
    public func refreshDashBoardWith(ID dbID: Int64,OnCompletion:
        @escaping refreshResponse)
        
    {
        
        DashBoardAPIHandler().refreshDashBoardWith(ID: dbID) { (resultType) in
            
            OnCompletion(resultType)
            
        }
        
    }
    
    
    
    public func getDashBoardComponentColorThemes( OnCompletion:
        @escaping ArrayOfColorThemes )
        
    {
        
        DashBoardAPIHandler().getDashBoardComponentColorThemes { (resultType) in
            
            OnCompletion(resultType)
        }
        
    }
    
    
} // end of class
