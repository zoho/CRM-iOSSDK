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
    
    public func getAllModules( modifiedSince : String?, completion : @escaping( BulkAPIResponse?, Error? ) -> () )
	{
        MetaDataAPIHandler().getAllModules( modifiedSince : modifiedSince) { ( response, error ) in
            completion( response, error )
        }
	}
	
    public func getModule( moduleAPIName : String, completion : @escaping( APIResponse?, Error? ) -> () )
	{
        MetaDataAPIHandler().getModule( apiName : moduleAPIName) { ( response, error ) in
            completion( response, error )
        }
	}
	
}
