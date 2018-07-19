//
//  ZCRMMetadata.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 11/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

public class ZCRMMetaData
{
    public init() {}
    
    public func getAllModules( modifiedSince : String?, completion : @escaping( BulkAPIResponse?, [ ZCRMModule ]?, Error? ) -> () )
	{
        MetaDataAPIHandler().getAllModules( modifiedSince : modifiedSince) { ( response, modules, error ) in
            completion( response, modules, error )
        }
	}
	
    public func getModule( moduleAPIName : String, completion : @escaping( APIResponse?, ZCRMModule?, Error? ) -> () )
	{
        MetaDataAPIHandler().getModule( apiName : moduleAPIName) { ( response, module, error ) in
            completion( response, module, error )
        }
	}
	
}
