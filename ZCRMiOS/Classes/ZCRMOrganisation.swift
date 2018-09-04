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
    private var fax : String?
    
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
    private var privacySettingsEnable : Bool?
    
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
    
    internal func setFax( fax : String? )
    {
        self.fax = fax
    }
    
    public func getFax() -> String?
    {
        return self.fax
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
    
    internal func setPrivacySettingsEnabled( privacyEnabled : Bool )
    {
        self.privacySettingsEnable = privacyEnabled
    }
    
    public func getPrivacySettingsEnabled() -> Bool
    {
        if privacySettingsEnable == nil {
            self.privacySettingsEnable = false
        }
        return self.privacySettingsEnable!
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
	
    public func getAllUsers( completion : @escaping( [ ZCRMUser ]?, BulkAPIResponse?, Error? ) -> () )
    {
        UserAPIHandler().getAllUsers( modifiedSince : nil, page : 1, perPage : 200 ) { ( users, response, error ) in
            completion( users, response, error )
        }
    }

    public func getAllUsers( modifiedSince : String, completion : @escaping( [ ZCRMUser ]?, BulkAPIResponse?, Error? ) -> () )
    {
        UserAPIHandler().getAllUsers( modifiedSince : modifiedSince, page : 1, perPage : 200 ) { ( users, response, error ) in
            completion( users, response, error )
        }
    }

    public func getAllActiveConfirmedUsers( completion : @escaping( [ ZCRMUser ]?, BulkAPIResponse?, Error? ) -> () )
    {
        UserAPIHandler().getAllActiveConfirmedUsers( page : 1, perPage : 200 ) { ( users, response, error ) in
            completion( users, response, error )
        }
    }
    
    public func getAllActiveConfirmedUsers( page : Int, perPage : Int, completion : @escaping( [ ZCRMUser ]?, BulkAPIResponse?, Error? ) -> () )
    {
        UserAPIHandler().getAllActiveConfirmedAdmins( page : page, perPage : perPage ) { ( users, response, error ) in
            completion( users, response, error )
        }
    }

    public func getAllAdminUsers( completion : @escaping( [ ZCRMUser ]?, BulkAPIResponse?, Error? ) -> () )
    {
        UserAPIHandler().getAllAdminUsers( page : 1, perPage : 200 ) { ( users, response, error ) in
            completion( users, response, error )
        }
    }
    
    public func getAllAdminUsers( page : Int, perPage : Int, completion : @escaping( [ ZCRMUser ]?, BulkAPIResponse?, Error? ) -> () )
    {
        UserAPIHandler().getAllAdminUsers( page : page, perPage : perPage ) { ( users, response, error ) in
            completion( users, response, error )
        }
    }

    public func getAllActiveUsers( completion : @escaping( [ ZCRMUser ]?, BulkAPIResponse?, Error? ) -> () )
    {
        UserAPIHandler().getAllActiveUsers( page : 1, perPage : 200 ) { ( users, response, error ) in
            completion( users, response, error )
        }
    }
    
    public func getAllActiveUsers( page : Int, perPage : Int, completion : @escaping( [ ZCRMUser ]?, BulkAPIResponse?, Error? ) -> () )
    {
        UserAPIHandler().getAllActiveUsers( page : page, perPage : perPage ) { ( users, response, error ) in
            completion( users, response, error )
        }
    }

    public func getAllInActiveUsers( completion : @escaping( [ ZCRMUser ]?, BulkAPIResponse?, Error? ) -> () )
    {
        UserAPIHandler().getAllDeactiveUsers( page : 1, perPage : 200 ) { ( users, response, error ) in
            completion( users, response, error )
        }
    }
    
    public func getAllInActiveUsers( page : Int, perPage : Int, completion : @escaping( [ ZCRMUser ]?, BulkAPIResponse?, Error? ) -> () )
    {
        UserAPIHandler().getAllDeactiveUsers( page : page, perPage : perPage ) { ( users, response, error ) in
            completion( users, response, error )
        }
    }
	
    public func getUser(userId : Int64, completion : @escaping( ZCRMUser?, APIResponse?, Error? ) -> () )
	{
        UserAPIHandler().getUser(userId: userId) { ( user, response, error ) in
            completion( user, response, error )
        }
	}
    
    public func getAllProfiles( completion : @escaping( [ ZCRMProfile ]?, BulkAPIResponse?, Error? ) -> () )
    {
        UserAPIHandler().getAllProfiles() { ( profiles, response, error ) in
            completion( profiles, response, error )
        }
    }
    
    public func getProfile( profileId : Int64, completion : @escaping( ZCRMProfile?, APIResponse?, Error? ) -> () )
    {
        UserAPIHandler().getProfile( profileId : profileId ) { ( profile, response, error ) in
            completion( profile, response, error )
        }
    }
    
    public func getAllRoles( completion : @escaping( [ ZCRMRole ]?, BulkAPIResponse?, Error? ) -> () )
    {
        UserAPIHandler().getAllRoles() { ( roles, response, error ) in
            completion( roles, response, error )
        }
    }
    
    public func getRole( roleId : Int64, completion : @escaping( ZCRMRole?, APIResponse?, Error? ) -> () )
    {
        UserAPIHandler().getRole( roleId : roleId ) { ( role, response, error ) in
            completion( role, response, error )
        }
    }
    
    public func searchUserByCriteria( criteria : String, completion : @escaping( [ ZCRMUser ]?, BulkAPIResponse?, Error? ) -> () )
    {
        UserAPIHandler().searchUsers( criteria : criteria, page : 1, perPage : 200) { ( response, users, error ) in
            completion( response, users, error )
        }
    }
    
    public func searchUserByCriteria( criteria : String, page : Int, perPage : Int, completion : @escaping( [ ZCRMUser ]?, BulkAPIResponse?, Error? ) -> () )
    {
        UserAPIHandler().searchUsers( criteria : criteria, page : page, perPage : perPage) { ( response, users, error ) in
            completion( response, users, error )
        }
    }
	
}


