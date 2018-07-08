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
    
    public func getModule( moduleAPIName : String, completion : @escaping( APIResponse?, Error? ) -> () )
    {
        MetaDataAPIHandler().getModule( apiName : moduleAPIName ) { ( response, error ) in
            completion( response, error )
        }
    }
    
    public func getAllModules( completion : @escaping( BulkAPIResponse?, Error? ) -> () )
    {
        self.getAllModules( modifiedSince : nil ) { ( response, error ) in
            completion( response, error )
        }
    }
    
    public func getAllModules( modifiedSince : String?, completion : @escaping( BulkAPIResponse?, Error? ) -> () )
    {
        MetaDataAPIHandler().getAllModules( modifiedSince : modifiedSince ) { ( response, error ) in
            completion( response, error )
        }
    }
    
    public func getCurrentUser( completion : @escaping( APIResponse?, Error? ) -> () )
    {
        UserAPIHandler().getCurrentUser() { ( response, error ) in
            completion( response, error )
        }
    }
}
