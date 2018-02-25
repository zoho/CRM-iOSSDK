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
    
    public func getOrganisationDetails() throws -> APIResponse
    {
        return try OrganizationAPIHandler().getOrganizationDetails()
    }
    
    public func getModule( moduleAPIName : String ) throws -> APIResponse
    {
        return try MetaDataAPIHandler().getModule( apiName : moduleAPIName )
    }
    
    public func getAllModules() throws -> BulkAPIResponse
    {
        return try self.getAllModules( modifiedSince : nil )
    }
    
    public func getAllModules( modifiedSince : String? ) throws -> BulkAPIResponse
    {
        return try MetaDataAPIHandler().getAllModules( modifiedSince : modifiedSince )
    }
    
    public func getCurrentUser() throws -> APIResponse
    {
        return try UserAPIHandler().getCurrentUser()
    }
}
