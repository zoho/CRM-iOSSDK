//
//  ZCRMCustomButton.swift
//  ZCRMiOS
//
//  Created by Sarath Kumar Rajendran on 08/04/18.
//	Copyright © 2018 zohocrm. All rights reserved.
//

public class ZCRMCustomButton : ZCRMEntity
{
	private var name : String?
	private var id : Int64?
	private var relatedListName : String?
	private var description : String?
	private var url : String?
	private var arguments : [String]?
		
	private var buttonDisplay : ButtonDisplay?
	private var urlEncoding : UrlEncoding?
	private var buttonAction : ButtonAction?
	private var buttonPosition : ButtonPosition?
	private var customFunction : ZCRMCustomFunction?
	
	private var modifiedTime : String?
	private var modifiedBy : ZCRMUser?
	private var profiles : [ZCRMProfile]?
	
	init( id : Int64 , name : String )
	{
		self.id = id
		self.name = name
	}
	
	public func getID() -> Int64?
	{
			return self.id
	}
	
	public func getName() -> String?
	{
		return self.name
	}
	
	internal func setRelatedListName( relatedListName : String? )
	{
		self.relatedListName = relatedListName
		
	}
	
	internal func setDescription( description : String? )
	{
		self.description = description
	}
	
	public func getDescription() -> String?
	{
		return self.description
	}
	
	internal func setUrl( url : String? )
	{
		self.url = url
	}
	
	public func getUrl() -> String?
	{
		return self.url
	}
	
	internal func setArguments( arguments : [String]? )
	{
		self.arguments = arguments
	}
	
	public func getArguments() -> [String]?
	{
		return self.arguments
	}
	
	internal func setButtonDisplay( display : ButtonDisplay? )
	{
		self.buttonDisplay = display
	}
	
	public func getButtonDisplay() -> ButtonDisplay?
	{
		return self.buttonDisplay
	}
	
	internal func setUrlEncoding ( urlEncoding : UrlEncoding? )
	{
		self.urlEncoding = urlEncoding
	}
	
	internal func setButtonAction ( buttonAction : ButtonAction? )
	{
		self.buttonAction = buttonAction
	}
	
	public func getButtonAction() -> ButtonAction?
	{
		return self.buttonAction
	}
	
	internal func setButtonPosition( buttonPosition : ButtonPosition? )
	{
		self.buttonPosition = buttonPosition
	}
	
	public func getButtonPositon() -> ButtonPosition?
	{
		return self.buttonPosition
	}
	
	internal func setCustonFunction( customFunction : ZCRMCustomFunction? )
	{
		self.customFunction = customFunction
	}
	
	internal func setModifiedTime( modifiedTime : String )
	{
		self.modifiedTime = modifiedTime
	}
	
	 public func getModifiedTime() -> String?
	{
		return self.modifiedTime
	}
	
	internal func setModifiedBy( modifiedBy :  ZCRMUser )
	{
		self.modifiedBy = modifiedBy
	}
	
	internal func setProfiles( profiles : [ZCRMProfile] )
	{
		self.profiles = profiles
	}
	
	public func getProfiles() -> [ZCRMProfile]?
	{
		return self.profiles
	}
	
	public func executeButton()
	{
		if(self.buttonAction == .URL)
		{
			if(self.arguments != nil && (self.arguments?.count)! > 1)
			{
				//wants to send request and get response
			}
		}
		else if(self.buttonAction == .CUSTOM_FUNCTION)
		{
			
		}
		else if(self.buttonAction == .WEB_TAB)
		{
			
		}
	}
	
}


public class ZCRMCustomFunction
{
	
	private var name : String?
	private var id : Int64?
	private var arguments : String?
	private var description : String?
	
	init( id : Int64 , name : String )
	{
		self.id = id
		self.name = name
	}
	
	internal func setArguments( arguments : String )
	{
		self.arguments = arguments
		
	}
	
	internal func setDescription( description : String )
	{
		self.description = description
	}
	
}



