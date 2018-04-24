//
//  ZCRMDeveloperSpace.swift
//  ZCRMiOS
//
//  Created by Sarath Kumar Rajendran on 20/04/18.
//

public class ZCRMDeveloperSpace : ZCRMEntity
{
	
	public init()
	{
		
	}

	public func getAllStandAloneFunctions() throws -> BulkAPIResponse
	{
		return try DeveloperSpaceAPIHandler().getAllFunctions(type: FuntionType.org , category: FuntionCategory.standalone , start: 1 , limit: 80 )
	}
	
	public func getStandAloneFuntion( id : Int64 ) throws -> APIResponse
	{
		return try DeveloperSpaceAPIHandler().getFuntion(id: id , source: FunctionSource.crm )
	}
	
}

