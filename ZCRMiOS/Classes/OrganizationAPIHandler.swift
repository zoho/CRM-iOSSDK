//
//  OrganizationAPIHandler.swift
//  ZCRMiOS
//
//  Created by Boopathy P on 30/08/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

import Foundation

internal class OrganizationAPIHandler : CommonAPIHandler
{
	override init() {

	}
    
    internal func getOrganizationDetails( completion : @escaping( ZCRMOrganisation?, APIResponse?, Error? ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.ORG )
		setUrlPath(urlPath:  "/org" )
		setRequestMethod(requestMethod: .GET)
        let request : APIRequest = APIRequest(handler: self )
        print( "Request : \( request.toString() )" )
        request.getAPIResponse { ( resp, err ) in
            if let error = err
            {
                completion( nil, nil, error )
                return
            }
            if let response = resp
            {
                let responseJSON : [ String :  Any ] = response.responseJSON
                let orgArray = responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                let org = self.getZCRMOrganization( orgDetails : orgArray[ 0 ] )
                response.setData( data : org )
                completion( org, response, nil )
            }
        }
    }
    
    // check optional property in organization API
    private func getZCRMOrganization( orgDetails : [ String : Any ] ) -> ZCRMOrganisation
    {
        let organization : ZCRMOrganisation = ZCRMOrganisation()
        if( orgDetails.hasValue( forKey : ResponseParamKeys.id ) )
        {
            organization.setOrgId( orgId : orgDetails.getInt64( key : ResponseParamKeys.id ) )
        }
        if( orgDetails.hasValue( forKey : ResponseParamKeys.fax ) )
        {
            organization.setFax( fax : orgDetails.getString( key : ResponseParamKeys.fax ) )
        }
        if( orgDetails.hasValue( forKey : ResponseParamKeys.companyName ) )
        {
            organization.setCompanyName( companyName : orgDetails.getString( key : ResponseParamKeys.companyName ) )
        }
        if( orgDetails.hasValue( forKey : ResponseParamKeys.alias ) )
        {
            organization.setAlias( alias : orgDetails.getString( key : ResponseParamKeys.alias) )
        }
        if( orgDetails.hasValue( forKey : ResponseParamKeys.primaryZUID ) )
        {
            organization.setPrimaryZuid( zuid : orgDetails.getInt64( key : ResponseParamKeys.primaryZUID ) )
        }
        if( orgDetails.hasValue( forKey : ResponseParamKeys.ZGID ) )
        {
            organization.setZgid( zgid : orgDetails.getInt64( key : ResponseParamKeys.ZGID ) )
        }
        if( orgDetails.hasValue( forKey : ResponseParamKeys.phone ) )
        {
            organization.setPhone( phone : orgDetails.getString( key : ResponseParamKeys.phone ) )
        }
        if( orgDetails.hasValue( forKey : ResponseParamKeys.mobile ) )
        {
            organization.setMobile( mobile : orgDetails.getString( key : ResponseParamKeys.mobile ) )
        }
        if( orgDetails.hasValue( forKey : ResponseParamKeys.website ) )
        {
            organization.setWebsite( website : orgDetails.getString( key : ResponseParamKeys.website ) )
        }
        if( orgDetails.hasValue( forKey : ResponseParamKeys.primaryEmail ) )
        {
            organization.setPrimaryEmail( email : orgDetails.getString( key : ResponseParamKeys.primaryEmail ) )
        }
        if( orgDetails.hasValue( forKey : ResponseParamKeys.employeeCount ) )
        {
            organization.setEmployeeCount( count : orgDetails.getString( key : ResponseParamKeys.employeeCount ) )
        }
        if( orgDetails.hasValue( forKey : ResponseParamKeys.description ) )
        {
            organization.setDescription( description : orgDetails.getString( key : ResponseParamKeys.description ) )
        }
        if( orgDetails.hasValue( forKey : ResponseParamKeys.timeZone ) )
        {
            organization.setTimeZone( timeZone : orgDetails.getString( key : ResponseParamKeys.timeZone ) )
        }
        if( orgDetails.hasValue( forKey : ResponseParamKeys.ISOCode ) )
        {
            organization.setIsoCode( isoCode : orgDetails.getString( key : ResponseParamKeys.ISOCode ) )
        }
        if( orgDetails.hasValue( forKey : ResponseParamKeys.currencyLocale ) )
        {
            organization.setCurrencyLocale( currencyLocale : orgDetails.getString( key : ResponseParamKeys.currencyLocale ) )
        }
        if( orgDetails.hasValue( forKey : ResponseParamKeys.currencySymbol ) )
        {
            organization.setCurrencySymbol( currencySymbol : orgDetails.getString( key : ResponseParamKeys.currencySymbol ) )
        }
        if( orgDetails.hasValue( forKey : ResponseParamKeys.street ) )
        {
            organization.setStreet( street : orgDetails.getString( key : ResponseParamKeys.street ) )
        }
        if( orgDetails.hasValue( forKey : ResponseParamKeys.city ) )
        {
            organization.setCity( city : orgDetails.getString( key : ResponseParamKeys.city ) )
        }
        if( orgDetails.hasValue( forKey : ResponseParamKeys.state ) )
        {
            organization.setState( state : orgDetails.getString( key : ResponseParamKeys.state ) )
        }
        if( orgDetails.hasValue( forKey : ResponseParamKeys.country ) )
        {
            organization.setCountry( country : orgDetails.getString( key : ResponseParamKeys.country ) )
        }
        if( orgDetails.hasValue( forKey : ResponseParamKeys.countryCode ) )
        {
            organization.setCountryCode( countryCode : orgDetails.getString( key : ResponseParamKeys.countryCode ) )
        }
        if( orgDetails.hasValue( forKey : ResponseParamKeys.zip ) )
        {
            organization.setZipCode( zipCode : orgDetails.getString( key : ResponseParamKeys.zip ) )
        }
        if( orgDetails.hasValue( forKey : ResponseParamKeys.mcStatus ) )
        {
            organization.setMcStatus( mcStatus : orgDetails.getBoolean( key : ResponseParamKeys.mcStatus ) )
        }
        if( orgDetails.hasValue( forKey : ResponseParamKeys.gappsEnabled ) )
        {
            organization.setGappsEnabled( gappsEnabled : orgDetails.getBoolean( key : ResponseParamKeys.gappsEnabled ) )
        }
        if( orgDetails.hasValue( forKey : ResponseParamKeys.privacySettings ) )
        {
            organization.setPrivacySettingsEnabled( privacyEnabled : orgDetails.getBoolean( key : ResponseParamKeys.privacySettings ) )
        }
        return organization
    }
}

extension OrganizationAPIHandler
{
    internal struct ResponseParamKeys
    {
        static let id = "id"
        static let fax = "fax"
        static let companyName = "company_name"
        static let alias = "alias"
        static let primaryZUID = "primary_zuid"
        static let ZGID = "zgid"
        static let phone = "phone"
        static let mobile = "mobile"
        static let website = "website"
        static let primaryEmail = "primary_email"
        static let employeeCount = "employee_count"
        static let description = "description"
        static let timeZone = "time_zone"
        static let ISOCode = "iso_code"
        static let currencyLocale = "currency_locale"
        static let currencySymbol = "currency_symbol"
        static let street = "street"
        static let city = "city"
        static let state = "state"
        static let country = "country"
        static let countryCode = "country_code"
        static let zip = "zip"
        static let mcStatus = "mc_status"
        static let gappsEnabled = "gapps_enabled"
        static let privacySettings = "privacy_settings"
    }
}

