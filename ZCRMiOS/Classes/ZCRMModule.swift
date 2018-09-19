//
//  ZCRMModule.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 14/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

open class ZCRMModule : ZCRMModuleDelegate
{
    public var singularLabel : String
    public var pluralLabel : String
    public var id : Int64 = APIConstants.INT64_MOCK
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
    public var sequenceNumber : Int?
    public var generatedType : String = APIConstants.STRING_MOCK
    public var businessCardFieldLimit : Int?
    public var webLink : String?
    
    public var arguments : [ [ String : Any ] ]?
    public var properties : [ String ] = [ APIConstants.STRING_MOCK ]
    
    public var displayField : String?
    public var searchLayoutFields : [ String ]?
    public var parentModule : ZCRMModule?
    public var customView : ZCRMCustomView?
    
    public var isKanbanView : Bool = APIConstants.BOOL_MOCK
    public var filterStatus : Bool = APIConstants.BOOL_MOCK
    public var isSubMenuPresent : Bool = APIConstants.BOOL_MOCK
    public var perPage : Int?
    public var isFilterSupported : Bool = APIConstants.BOOL_MOCK
    public var isFeedsRequired : Bool = APIConstants.BOOL_MOCK
    public var parenModule : ZCRMModuleDelegate?
    
    internal init( apiName : String, singularLabel : String, pluralLabel : String )
    {
        self.singularLabel = singularLabel
        self.pluralLabel = pluralLabel
        super.init( apiName : apiName )
	}
    
    func addAllowedProfile( profile : ZCRMProfileDelegate )
    {
        self.allowedProfiles?.append( profile )
    }
}
