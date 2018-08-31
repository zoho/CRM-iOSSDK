//
//  ZCRMRestClient.swift
//  ZCRMiOS
//
//  Created by Boopathy P on 06/09/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

import Foundation

public class ZCRMRestClient
{
    public init() {}
    
    public typealias dashBoard = (ZCRMDashBoard?,APIResponse?,Error?) -> Void
    public typealias ArrayOfDashBoard = ([ZCRMDashBoard]?,BulkAPIResponse?,Error?) -> Void
    public typealias dashBoardComponent = (ZCRMDashBoardComponent?,APIResponse?,Error?) -> Void
    public typealias refreshResponse = (APIResponse?,Error?) -> Void
    public typealias ArrayOfColorThemes = ([ZCRMDashBoardComponentColorThemes]?,APIResponse?,Error?) -> Void
    
    
    
    public func getOrganisationDetails( completion : @escaping( ZCRMOrganisation?, APIResponse?, Error? ) -> () )
    {
        OrganizationAPIHandler().getOrganizationDetails() { ( org, response, error ) in
            completion( org, response, error )
        }
    }
    
    public func getModule( moduleAPIName : String, completion : @escaping( ZCRMModule?, APIResponse?, Error? ) -> () )
    {
        MetaDataAPIHandler().getModule( apiName : moduleAPIName ) { ( module, response, error ) in
            completion( module, response, error )
        }
    }
    
    public func getAllModules( completion : @escaping( [ ZCRMModule ]?, BulkAPIResponse?, Error? ) -> () )
    {
        MetaDataAPIHandler().getAllModules( modifiedSince : nil ) { ( modules, response, error ) in
            completion( modules, response, error )
        }
    }
    
    public func getAllModules( modifiedSince : String, completion : @escaping( [ ZCRMModule ]?, BulkAPIResponse?, Error? ) -> () )
    {
        MetaDataAPIHandler().getAllModules( modifiedSince : modifiedSince ) { ( modules, response, error ) in
            completion( modules, response, error )
        }
    }
    
    public func getCurrentUser( completion : @escaping( ZCRMUser?, APIResponse?, Error? ) -> () )
    {
        UserAPIHandler().getCurrentUser() { ( user, response, error ) in
            completion( user, response, error )
        }
    }
    
    public func getAllDashBoards(then Oncompletion:@escaping ArrayOfDashBoard)
    {
        // 200 is the maxNumber of records that can be retreived in an API Call
        DashBoardAPIHandler().getAllDashBoards(FromPage:1, WithPerPageOf: 200)
        {
            (dashBoards,bulkAPIResponse,error)  in
            Oncompletion(dashBoards,bulkAPIResponse,error)
        }
    }
    
    public func getAllDashboards(FromPage page:Int?,PerPage perPage:Int?,then
        Oncompletion:@escaping ArrayOfDashBoard)
        
    {
        let unwrappedPage = page ?? 1
        let unwrappedPerPage = perPage ?? 200
        
        DashBoardAPIHandler().getAllDashBoards(FromPage: unwrappedPage,
                                               WithPerPageOf: unwrappedPerPage)
        {
            (dashBoards,bulkAPIResponse,error) in
            Oncompletion(dashBoards,bulkAPIResponse,error)
        }
        
    }
    
    public func getDashBoardWith(ID:Int64,then OnCompletion:@escaping dashBoard)
    {
        DashBoardAPIHandler().getDashBoardWith(ID: ID)
        {
            (dashBoard,APIResponse,error) in
            OnCompletion(dashBoard,APIResponse,error)
        }
        
    }
    
    
    public func getComponentWith(ID cmpID: Int64, FromDashBoardID dbID: Int64,
                                 OnCompletion: @escaping dashBoardComponent)
        
    {
        DashBoardAPIHandler().getComponentWith(ID: cmpID, FromDashBoardID: dbID)
        {
            (dashBoardComponent,APIResponse,error) in
            OnCompletion(dashBoardComponent,APIResponse,error)
        }
        
    }
    
    
    public func refreshComponentWith(ID cmpID: Int64,InDashBoardID dbID: Int64,OnCompletion: @escaping refreshResponse)
    {
        
        DashBoardAPIHandler().refreshComponentWith(ID: cmpID, InDashBoardID: dbID)
        {
            
            (APIResponse, error) in
            OnCompletion(APIResponse,error)
        }
        
    }
    
    
    public func refreshDashBoardWith(ID dbID: Int64, OnCompletion: @escaping refreshResponse )
    {
        
        DashBoardAPIHandler().refreshDashBoardWith(ID: dbID)
        {
            
            (APIResponse, error) in
            OnCompletion(APIResponse,error)
        }
        
    }
    
    
    public func getDashBoardComponentColorThemes( OnCompletion: @escaping ArrayOfColorThemes )
    {
        
        DashBoardAPIHandler().getDashBoardComponentColorThemes {
            (ArrayOfColorThemes, APIResponse, error) in
            
            OnCompletion(ArrayOfColorThemes, APIResponse, error)
            
        }
        
    }
    
    
} // end of class



