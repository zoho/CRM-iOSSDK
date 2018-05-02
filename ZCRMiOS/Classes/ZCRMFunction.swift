//
//  ZCRMFunction.swift
//  ZCRMiOS
//
//  Created by Sarath Kumar Rajendran on 20/04/18.
//


public class ZCRMFunction : ZCRMEntity
{
	
	private var displayName : String
	private var id : Int64
	private var description : String?
	
	private var apiName : String?
	private var name : String?
	private var source : String?
	private var config : Bool?
	private var category : FuntionCategory?
	private var params : [ String : FunctionParamType ] = [ String : FunctionParamType ]()
	private var restAPI : [RestApi]?
	private var returnType : String?
	private var script : String?
	private var workflow : String?
	
	init( id : Int64 , displayName : String )
	{
		self.id = id
		self.displayName = displayName
	}
	
	public func getID() -> Int64
	{
		return self.id
	}
	
	public func getDisplayName() -> String
	{
		return self.displayName
	}
	
	internal func setDescription( description : String? )
	{
		self.description = description
	}
	
	public func getDescription() -> String?
	{
		return self.description
	}
	
	internal func setApiName( apiName : String? )
	{
		self.apiName = apiName
	}
	
	public func getApiName() -> String?
	{
		return self.apiName
	}
	
	internal func setName( name : String? )
	{
		self.name = name
	}
	
	public func getName() -> String?
	{
		return self.name
	}
	
	internal func setSource( source : String? )
	{
		self.source = source
	}
	
	public func getSource() -> String?
	{
		return self.source
	}
	
	internal func setConfig( config : Bool? )
	{
		self.config = config
	}
	
	public func getConfig() -> Bool?
	{
		return self.config
	}
	
	internal func setCategory( category : FuntionCategory? )
	{
		self.category = category
	}
	
	internal func getCategory() -> FuntionCategory?
	{
		return self.category
	}
	
	internal func setRestAPI ( restAPI : [RestApi]? )
	{
		self.restAPI = restAPI
	}
	
	public func getRestApi( ) -> [RestApi]?
	{
		return self.restAPI
	}
	
	internal func addParam( name : String? , type : FunctionParamType? )
	{
		if let name = name
		{
			self.params[name] = type
		}
	}
	
	public func getParams() -> [ String : FunctionParamType ]?
	{
		return self.params
	}
	
	internal func setReturnType( returnType : String? )
	{
		self.returnType = returnType
	}
	
	public func getReturnType() -> String?
	{
		return self.returnType
	}
	
	internal func setScript( script : String )
	{
		self.script = script
	}
	
	public func getScript() -> String?
	{
		return self.script
	}
	
	internal func setWorkflow( workflow : String? )
	{
		self.workflow = workflow
	}
	
	public func getWorkflow() -> String?
	{
		return self.workflow
	}

	public func executeAPI( api : RestApi , params : [ String : Any ]  ) throws -> String
	{
		let url : URL
		var isOAuth : Bool = true
		if !params.equateKeys(dictionary: self.params )
		{
			throw ZCRMSDKError.InValidError("Invalid paramter found")
		}
		if let apis : [RestApi] = self.restAPI
		{
			if apis.index(of: api) != nil
			{
				url = URL(string: api.getUrl()! )!
				if api.getType()?.rawValue == "zapikey"
				{
					isOAuth = false
				}
			}
			else
			{
				throw ZCRMSDKError.InValidError( "Invalid RestApi object found" )
			}
		}
		else
		{
			throw ZCRMSDKError.InValidError( "No RestApi's for this ZCRMFunction")
		}
		
		return try DeveloperSpaceAPIHandler().executeRestApi(url: url, params:  params , isOAuth: isOAuth )
	}
}


public class RestApi
{
	private var active : Bool?
	private var type : RestApiType?
	private var url : String?
	
	init() {}
	
	internal func setActive( active : Bool )
	{
		self.active = active
	}
	
	public func isActive() -> Bool?
	{
		return self.active
	}
	
	internal func setType( type : RestApiType? )
	{
		self.type = type
	}
	
	public func getType() -> RestApiType?
	{
		return self.type
	}
	
	internal func setUrl( url : String )
	{
		self.url = url
	}
	
	public func getUrl() -> String?
	{
		return self.url
	}
}

extension RestApi: Equatable
{
	
	public static func==(_ lhs: RestApi, _ rhs: RestApi) -> Bool
	{
		return lhs.isActive() == rhs.isActive() && lhs.getType()?.rawValue == rhs.getType()?.rawValue && lhs.getUrl() == rhs.getUrl()
	}
}
