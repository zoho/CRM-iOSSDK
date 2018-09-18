//
//  ZCRMModule.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 14/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

open class ZCRMModule : ZCRMModuleDelegate
{
    var moduleAPIName : String
    var singularLabel : String
    var pluralLabel : String
    var id : Int64 = APIConstants.INT64_MOCK
    public var systemName : String = APIConstants.STRING_MOCK
    
    public var creatable : Bool = APIConstants.BOOL_MOCK
    public var viewable : Bool = APIConstants.BOOL_MOCK
    public var convertible : Bool = APIConstants.BOOL_MOCK
    public var editable : Bool = APIConstants.BOOL_MOCK
    public var deletable : Bool = APIConstants.BOOL_MOCK
    
    public var modifiedBy : ZCRMUserDelegate = USER_MOCK
    public var modifiedTime : String = APIConstants.STRING_MOCK
    
    public var allowedProfiles : [ZCRMProfileDelegate]?
    public var relatedLists : [ZCRMModuleRelation]?

    
    public var globalSearchSupported : Bool = APIConstants.BOOL_MOCK
    public var visibility : Int = APIConstants.INT_MOCK
    public var apiSupported : Bool = APIConstants.BOOL_MOCK
    public var quickCreate : Bool = APIConstants.BOOL_MOCK
    public var scoringSupported : Bool = APIConstants.BOOL_MOCK
    public var sequenceNumber : Int = APIConstants.INT_MOCK
    public var generatedType : String = APIConstants.STRING_MOCK
    public var businessCardFieldLimit : Int = APIConstants.INT_MOCK
    public var webLink : String?
    
    public var arguments : [ [ String : Any ] ] = [ [ String : Any ] ]()
    public var properties : [ String ] = [ APIConstants.STRING_MOCK ]
    
    public var displayField : String = APIConstants.STRING_MOCK
    public var searchLayoutFields : [ String ] = [ String ]()
    public var parentModule : ZCRMModule?
    public var customView : ZCRMCustomView?
    
    public var isKanbanView : Bool = APIConstants.BOOL_MOCK
    public var filterStatus : Bool = APIConstants.BOOL_MOCK
    public var isSubMenuPresent : Bool = APIConstants.BOOL_MOCK
    public var perPage : Int = APIConstants.INT_MOCK
    public var isFilterSupported : Bool = APIConstants.BOOL_MOCK
    public var isFeedsRequired : Bool = APIConstants.BOOL_MOCK
    public var parenModule : ZCRMModuleDelegate?
    
    public init( moduleAPIName : String, singularLabel : String, pluralLabel : String )
    {
		self.moduleAPIName = moduleAPIName
        self.singularLabel = singularLabel
        self.pluralLabel = pluralLabel
        super.init( apiName : moduleAPIName )
	}
    
    func addAllowdProfile( profile : ZCRMProfileDelegate )
    {
        self.allowedProfiles?.append( profile )
    }
}
