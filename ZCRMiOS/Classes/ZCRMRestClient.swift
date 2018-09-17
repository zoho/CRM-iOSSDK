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
    
    public func getOrganisationDetails( completion : @escaping( Result.DataResponse< ZCRMOrganisation, APIResponse > ) -> () )
    {
        OrganizationAPIHandler().getOrganizationDetails() { ( result ) in
            completion( result )
        }
    }
    
    public func getModule( moduleAPIName : String, completion : @escaping( Result.DataResponse< ZCRMModule, APIResponse > ) -> () )
    {
        MetaDataAPIHandler().getModule( apiName : moduleAPIName ) { ( result ) in
            completion( result )
        }
    }
    
    public func getAllModules( completion : @escaping( Result.DataResponse< [ ZCRMModule ], BulkAPIResponse > ) -> () )
    {
        MetaDataAPIHandler().getAllModules( modifiedSince : nil ) { ( result ) in
            completion( result )
        }
    }
    
    public func getAllModules( modifiedSince : String, completion : @escaping( Result.DataResponse< [ ZCRMModule ], BulkAPIResponse > ) -> () )
    {
        MetaDataAPIHandler().getAllModules( modifiedSince : modifiedSince ) { ( result ) in
            completion( result )
        }
    }
    
    public func getCurrentUser( completion : @escaping( Result.DataResponse< ZCRMUser, APIResponse > ) -> () )
    {
        UserAPIHandler().getCurrentUser() { ( result ) in
            completion( result )
        }
    }
}
