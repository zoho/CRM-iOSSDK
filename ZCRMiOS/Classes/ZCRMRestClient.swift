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
    
    public func getOrganisationDetails( completion : @escaping( APIResponse?, Error? ) -> () )
    {
        OrganizationAPIHandler().getOrganizationDetails() { ( response, error ) in
            completion( response, error )
        }
    }
    
    public func getModule( moduleAPIName : String, completion : @escaping( APIResponse?, ZCRMModule?, Error? ) -> () )
    {
        MetaDataAPIHandler().getModule( apiName : moduleAPIName ) { ( response, module, error ) in
            completion( response, module, error )
        }
    }
    
    public func getAllModules( completion : @escaping( BulkAPIResponse?, [ ZCRMModule ]?, Error? ) -> () )
    {
        MetaDataAPIHandler().getAllModules( modifiedSince : nil ) { ( response, modules, error ) in
            completion( response, modules, error )
        }
    }
    
    public func getAllModules( modifiedSince : String, completion : @escaping( BulkAPIResponse?, [ ZCRMModule ]?, Error? ) -> () )
    {
        MetaDataAPIHandler().getAllModules( modifiedSince : modifiedSince ) { ( response, modules, error ) in
            completion( response, modules, error )
        }
    }
    
    public func getCurrentUser( completion : @escaping( APIResponse?, ZCRMUser?, Error? ) -> () )
    {
        UserAPIHandler().getCurrentUser() { ( response, user, error ) in
            completion( response, user, error )
        }
    }
}
