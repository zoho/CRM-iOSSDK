//
//  User.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 09/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

public class ZCRMOrganisation : ZCRMEntity
{
	
	private var orgName : String?
    private var orgId : Int64?
    
    private var alias : String?
    private var primary_zuid : Int64?
    private var zgid : Int64?
    
    private var primary_email : String?
    private var website : String?
    private var mobile : String?
    private var phone : String?
    
    private var employee_count : String?
    private var description : String?
    
    private var time_zone : String?
    private var iso_code : String?
    private var currency_locale : String?
    private var currency_symbol : String?
    private var street : String?
    private var city : String?
    private var state : String?
    private var country : String?
    private var zipcode : String?
    private var country_code : String?
    
    private var mc_status : Bool?
    private var gapps_enabled : Bool?
    
    public init() {}
    
    internal func setCompanyName( companyName : String )
    {
        self.orgName = companyName
    }
    
    public func getCompanyName() -> String
    {
        return self.orgName!
    }
    
    internal func setAlias( alias : String )
    {
        self.alias = alias
    }
    
    public func getAlias() -> String?
    {
        return self.alias
    }
    
    internal func setOrgId( orgId : Int64 )
    {
        self.orgId = orgId
    }
    
    public func getOrgId() -> Int64?
    {
        return self.orgId
    }
    
    internal func setPrimaryZuid( zuid : Int64 )
    {
        self.primary_zuid = zuid
    }
    
    public func getPrimaryZuid() -> Int64?
    {
        return self.primary_zuid
    }
    
    internal func setZgid( zgid : Int64 )
    {
        self.zgid = zgid
    }
    
    public func getZgid() -> Int64?
    {
        return self.zgid
    }
    
    internal func setPrimaryEmail( email : String )
    {
        self.primary_email = email
    }
    
    public func getPrimaryEmail() -> String?
    {
        return self.primary_email
    }
    
    internal func setWebsite( website : String )
    {
        self.website = website
    }
    
    public func getWebsite() -> String?
    {
        return self.website
    }
    
    internal func setMobile( mobile : String )
    {
        self.mobile = mobile
    }
    
    public func getMobile() -> String?
    {
        return self.mobile
    }
    
    internal func setPhone( phone : String )
    {
        self.phone = phone
    }
    
    public func getPhone() -> String?
    {
        return self.phone
    }
    
    internal func setEmployeeCount( count : String )
    {
        self.employee_count = count
    }
    
    public func getEmployeeCount() -> String?
    {
        return self.employee_count
    }
    
    internal func setDescription( description : String )
    {
        self.description = description
    }
    
    public func getDescription() -> String?
    {
        return self.description
    }
    
    internal func setTimeZone( timeZone : String )
    {
        self.time_zone = timeZone
    }
    
    public func getTimeZone() -> String?
    {
        return self.time_zone
    }
    
    internal func setIsoCode( isoCode : String )
    {
        self.iso_code = isoCode
    }
    
    public func getIsoCode() -> String?
    {
        return self.iso_code
    }
    
    internal func setStreet( street : String )
    {
        self.street = street
    }
    
    public func getStreet() -> String?
    {
        return self.street
    }
    
    internal func setCity( city : String )
    {
        self.city = city
    }
    
    public func getCity() -> String?
    {
        return self.city
    }
    
    internal func setState( state : String )
    {
        self.state = state
    }
    
    public func getState() -> String?
    {
        return self.state
    }
    
    internal func setCountry( country : String )
    {
        self.country = country
    }
    
    public func getCountry() -> String?
    {
        return self.country
    }
    
    internal func setZipCode( zipCode : String )
    {
        self.zipcode = zipCode
    }
    
    public func getZipCode() -> String?
    {
        return self.zipcode
    }
    
    internal func setCountryCode( countryCode : String )
    {
        self.country_code = countryCode
    }
    
    public func getCountryCode() -> String?
    {
        return self.country_code
    }
    
    internal func setMcStatus( mcStatus : Bool )
    {
        self.mc_status = mcStatus
    }
    
    public func getMcStatus() -> Bool?
    {
        return self.mc_status
    }
    
    internal func setGappsEnabled( gappsEnabled : Bool )
    {
        self.gapps_enabled = gappsEnabled
    }
    
    public func getGappsEnabled() -> Bool?
    {
        return self.gapps_enabled
    }
    
    internal func setCurrencyLocale( currencyLocale : String )
    {
        self.currency_locale = currencyLocale
    }
    
    public func getCurrencyLocale() -> String?
    {
        return self.currency_locale
    }
    
    internal func setCurrencySymbol( currencySymbol : String )
    {
        self.currency_symbol = currencySymbol
    }
    
    public func getCurrencySymbol() -> String?
    {
        return self.currency_symbol
    }
	
    public func getAllUsers() throws -> BulkAPIResponse
    {
        return try UserAPIHandler().getAllUsers( modifiedSince : nil, page : 1, perPage : 200 )
    }

    public func getAllUsers( modifiedSince : String? ) throws -> BulkAPIResponse
    {
        return try UserAPIHandler().getAllUsers( modifiedSince : modifiedSince, page : 1, perPage : 200 )
    }

    public func getAllActiveConfirmedUsers() throws -> BulkAPIResponse
    {
        return try UserAPIHandler().getAllActiveConfirmedUsers( page : 1, perPage : 200 )
    }
    
    public func getAllActiveConfirmedUsers( page : Int, perPage : Int ) throws -> BulkAPIResponse
    {
        return try UserAPIHandler().getAllActiveConfirmedAdmins( page : page, perPage : perPage )
    }

    public func getAllAdminUsers() throws -> BulkAPIResponse
    {
        return try UserAPIHandler().getAllAdminUsers( page : 1, perPage : 200 )
    }
    
    public func getAllAdminUsers( page : Int, perPage : Int ) throws -> BulkAPIResponse
    {
        return try UserAPIHandler().getAllAdminUsers( page : page, perPage : perPage )
    }

    public func getAllActiveUsers() throws -> BulkAPIResponse
    {
        return try UserAPIHandler().getAllActiveUsers( page : 1, perPage : 200 )
    }
    
    public func getAllActiveUsers( page : Int, perPage : Int ) throws -> BulkAPIResponse
    {
        return try UserAPIHandler().getAllActiveUsers( page : page, perPage : perPage )
    }

    public func getAllInActiveUsers() throws -> BulkAPIResponse
    {
        return try UserAPIHandler().getAllDeactiveUsers( page : 1, perPage : 200 )
    }
    
    public func getAllInActiveUsers( page : Int, perPage : Int ) throws -> BulkAPIResponse
    {
        return try UserAPIHandler().getAllDeactiveUsers( page : page, perPage : perPage )
    }
	
	public func getUser(userId : Int64) throws -> APIResponse
	{
		return try UserAPIHandler().getUser(userId: userId)
	}
    
    public func getAllProfiles() throws -> BulkAPIResponse
    {
        return try UserAPIHandler().getAllProfiles()
    }
    
    public func getProfile( profileId : Int64 ) throws -> APIResponse
    {
        return try UserAPIHandler().getProfile( profileId : profileId )
    }
    
    public func getAllRoles() throws -> BulkAPIResponse
    {
        return try UserAPIHandler().getAllRoles()
    }
    
    public func getRole( roleId : Int64 ) throws -> APIResponse
    {
        return try UserAPIHandler().getRole( roleId : roleId )
    }
	
}


