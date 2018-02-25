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
    
    public func getAllModules( modifiedSince : String? ) throws -> BulkAPIResponse
	{
		return try MetaDataAPIHandler().getAllModules( modifiedSince : modifiedSince )
	}
	
	public func getModule(moduleAPIName : String) throws -> APIResponse
	{
		return try MetaDataAPIHandler().getModule(apiName: moduleAPIName)
	}
	
}
