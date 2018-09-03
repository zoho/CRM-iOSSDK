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
    private lazy var ZCRMAnalyticsObj = ZCRMAnalytics()
    
    public init() {}
    
    
    
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
    
    public func getZCRMAnalyticsInstance() -> ZCRMAnalytics
    {
        return ZCRMAnalyticsObj
    }
    
    
} // end of class



