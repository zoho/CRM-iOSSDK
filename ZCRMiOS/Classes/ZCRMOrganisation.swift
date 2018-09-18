//
//  User.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 09/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

public class ZCRMOrganisation : ZCRMEntity
{
	public var orgName : String = APIConstants.STRING_MOCK
    public var orgId : Int64?
    
    public var alias : String?
    public var primary_zuid : Int64 = APIConstants.INT64_MOCK
    public var zgid : Int64 = APIConstants.INT64_MOCK
    
    public var primary_email : String = APIConstants.STRING_MOCK
    public var website : String?
    public var mobile : String?
    public var phone : String?
    public var fax : String?
    
    public var employee_count : String?
    public var description : String?
    
    public var time_zone : String?
    public var iso_code : String?
    public var currency_locale : String?
    public var currency_symbol : String?
    public var street : String?
    public var city : String?
    public var state : String?
    public var country : String?
    public var zipcode : String?
    public var country_code : String?
    
    public var mc_status : Bool = APIConstants.BOOL_MOCK
    public var gapps_enabled : Bool = APIConstants.BOOL_MOCK
    public var privacySettingsEnable : Bool = APIConstants.BOOL_MOCK
    
    public init() {}
}


