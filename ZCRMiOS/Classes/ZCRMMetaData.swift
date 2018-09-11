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
    
    public func getAllModules( completion : @escaping( Result.DataResponse< [ ZCRMModule ], BulkAPIResponse > ) -> () )
    {
        MetaDataAPIHandler().getAllModules( modifiedSince : nil) { ( result ) in
            completion( result )
        }
    }
    
    public func getAllModules( modifiedSince : String, completion : @escaping( Result.DataResponse< [ ZCRMModule ], BulkAPIResponse > ) -> () )
	{
        MetaDataAPIHandler().getAllModules( modifiedSince : modifiedSince) { ( result ) in
            completion( result )
        }
	}
	
    public func getModule( moduleAPIName : String, completion : @escaping( Result.DataResponse< ZCRMModule, APIResponse > ) -> () )
	{
        MetaDataAPIHandler().getModule( apiName : moduleAPIName) { ( result ) in
            completion( result )
        }
	}
	
}
