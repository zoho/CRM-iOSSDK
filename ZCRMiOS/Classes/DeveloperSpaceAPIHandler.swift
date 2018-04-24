//
//  DeveloperSpaceAPIHandler.swift
//  ZCRMiOS
//
//  Created by Sarath Kumar Rajendran on 20/04/18.
//

internal class DeveloperSpaceAPIHandler : CommonAPIHandler
{
	
	override init()
	{
		
	}
	
	// MARK: - Handler Functions
	
	internal func getAllFunctions( type : FuntionType , category : FuntionCategory? , start : Int , limit : Int ) throws -> BulkAPIResponse
	{
		setUrlPath(urlPath: "/settings/functions")
		setRequestMethod(requestMethod: .GET )
		addRequestParam(param: "type" , value: type.rawValue )
		addRequestParam(param: "start", value: String(start) )
		addRequestParam(param: "limit", value: String(limit) )
		if category != nil {
			addRequestParam(param: "category" , value: category!.rawValue )
		}
		let request : APIRequest = APIRequest(handler: self )
		print("Request : \( request.toString() )")
		
		let response : BulkAPIResponse = try request.getBulkAPIResponse()
		let responseJSON : [ String : Any ] = response.getResponseJSON()
		if responseJSON.isEmpty == false
		{
			response.setData(data: self.getAllZCRMFunctions(functionList: responseJSON.getArrayOfDictionaries(key: "functions" )))
		}
		return response
	}
	
	internal func getFuntion( id : Int64 , source : FunctionSource ) throws -> APIResponse
	{
		setUrlPath(urlPath: "/settings/functions/\(id)" )
		addRequestParam(param: "source" , value: source.rawValue )
		let request : APIRequest = APIRequest(handler: self )
		print("Request : \( request.toString() )")
		let response : APIResponse = try request.getAPIResponse()
		let responseJSON : [ String : Any ] = response.getResponseJSON()
		let functionList : [[ String : Any ]] = responseJSON.getArrayOfDictionaries(key: "functions" )
		if responseJSON.isEmpty == false
		{
			response.setData(data: self.getZCRMFunction(functionDetails: functionList[0] ))
		}
		return response
	}
	
	internal func executeRestApi( url : URL , params : [ String : Any ] , isOAuth : Bool ) throws -> String
	{
		setUrl( url : url )
		setRequestMethod( requestMethod : .POST )
		setRequestType( isOAuthRequest :  isOAuth )
		var reqBodyObj : [String:[String:Any]] = [String:[String:Any]]()
		reqBodyObj["arguments"] = params
		setRequestBody(requestBody: reqBodyObj )
		
		let request : APIRequest = APIRequest(handler: self )
		print( "Request : \( request.toString() )" )
		let response = try request.getAPIResponse()
		let responseJSON = response.getResponseJSON()
		let detailsJSON = responseJSON.getDictionary(key: "details" )
		var outputStr : String = String()
		if detailsJSON.isEmpty == false {
			outputStr = detailsJSON["output"] as! String
		}
		else
		{
			throw ZCRMSDKError.InValidError( detailsJSON["message"] as! String )
		}
		return outputStr
	}

	// MARK: - Utility Functions
	
	internal func getAllZCRMFunctions( functionList : [ [String : Any ]] ) -> [ZCRMFunction]
	{
		var zcrmFunctions : [ZCRMFunction] = [ZCRMFunction]()
		for function in functionList
		{
			zcrmFunctions.append( self.getZCRMFunction(functionDetails: function ))
		}
		return zcrmFunctions
	}
	
	internal func getZCRMFunction( functionDetails : [String : Any ]) -> ZCRMFunction
	{
		let zcrmFunction = ZCRMFunction(id: functionDetails.getInt64(key: "id" ) , displayName: functionDetails.getString(key: "display_name") )
		zcrmFunction.setName(name: functionDetails.getString(key: "name") )
		zcrmFunction.setSource(source: functionDetails.getString(key: "source" ))
		zcrmFunction.setConfig(config: functionDetails.getBoolean(key: "config" ) )
		if functionDetails.hasValue(forKey: "description" )
		{
			zcrmFunction.setDescription(description: functionDetails.getString(key: "description" ))
		}
		if functionDetails.hasValue(forKey: "api_name" )
		{
			zcrmFunction.setName(name: functionDetails.getString(key: "api_name") )
		}
		if functionDetails.hasValue(forKey: "rest_api" )
		{
			let apiList = functionDetails.getArrayOfDictionaries(key: "rest_api" )
			var restApiList : [RestApi] = [RestApi]()
			for api in apiList
			{
				let restApi = RestApi()
				restApi.setActive(active: api.getBoolean(key: "active" ))
				var type : RestApiType?
				switch api.getString(key: "type" )
				{
					case "oauth":
						type = .oauth
					case "zapikey":
						type = .zapikey
					default :
						print(" RestApi type \(api.getString(key: "type"))")
				}
				restApi.setType(type: type )
				restApi.setUrl(url: api.getString(key: "url" ))
				restApiList.append(restApi)
			}
			zcrmFunction.setRestAPI(restAPI: restApiList)
		}
		if functionDetails.hasKey(forKey: "params")
		{
			let params = functionDetails.getArrayOfDictionaries(key: "params" )
			for param in params
			{
				var paramType : FunctionParamType?
				switch param.getString(key: "value" )
				{
					case "STRING" :
						paramType = .STRING
					case "BIGINT" :
						paramType = .BIGINT
					case "TIMESTAMP" :
						paramType = .TIMESTAMP
					case "DECIMAL"	:
						paramType = .DECIMAL
					case "BOOLEAN" :
						paramType = .BOOLEAN
					default :
						print("param type \(param.getString(key: "value"))")
				}
				
				zcrmFunction.addParam(name: param.getString(key: "name") , type: paramType )
			}
		}
		if functionDetails.hasKey(forKey: "return_type" )
		{
			zcrmFunction.setReturnType(returnType: functionDetails.getString(key: "return_type"))
		}
		if functionDetails.hasKey(forKey: "script" )
		{
			zcrmFunction.setScript(script: functionDetails.getString(key: "script" ))
		}
		if functionDetails.hasValue(forKey: "workflow")
		{
			zcrmFunction.setWorkflow(workflow: functionDetails.getString(key: "workflow" ))
		}
		return zcrmFunction
	}
}
