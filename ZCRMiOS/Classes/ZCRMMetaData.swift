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
    
    public func getAllModules( completion : @escaping( [ ZCRMModule ]?, BulkAPIResponse?, Error? ) -> () )
    {
        MetaDataAPIHandler().getAllModules( modifiedSince : nil) { ( modules, response, error ) in
            completion( modules, response, error )
        }
    }
    
    public func getAllModules( modifiedSince : String, completion : @escaping( [ ZCRMModule ]?, BulkAPIResponse?, Error? ) -> () )
	{
        MetaDataAPIHandler().getAllModules( modifiedSince : modifiedSince) { ( modules, response, error ) in
            completion( modules, response, error )
        }
	}
	
    public func getModule( moduleAPIName : String, completion : @escaping( ZCRMModule?, APIResponse?, Error? ) -> () )
	{
        MetaDataAPIHandler().getModule( apiName : moduleAPIName) { ( module, response, error ) in
            completion( module, response, error )
        }
	}
	
}
