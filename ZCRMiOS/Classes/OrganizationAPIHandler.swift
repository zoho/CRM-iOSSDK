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
    
    internal func getOrganizationDetails() throws -> APIResponse
    {
		setUrlPath(urlPath:  "/org" )
		setRequestMethod(requestMethod: .GET)
        let request : APIRequest = APIRequest(handler: self )
        print( "Request : \( request.toString() )" )
        let response : APIResponse = try request.getAPIResponse()
        let responseJSON : [ String :  Any ] = response.responseJSON
        let orgArray = responseJSON.getArrayOfDictionaries( key : "org" )
        response.setData( data : self.getZCRMOrganization( orgDetails : orgArray[ 0 ] ) )
        return response
    }
    
    private func getZCRMOrganization( orgDetails : [ String : Any ] ) -> ZCRMOrganisation
    {
        let organization : ZCRMOrganisation = ZCRMOrganisation()
        if( orgDetails.hasValue( forKey : "id" ) )
        {
            organization.setOrgId( orgId : orgDetails.getInt64( key : "id" ) )
        }
        if( orgDetails.hasValue( forKey : "company_name" ) )
        {
            organization.setCompanyName( companyName : orgDetails.getString( key : "company_name" ) )
        }
        if( orgDetails.hasValue( forKey : "alias" ) )
        {
            organization.setAlias( alias : orgDetails.getString( key : "alias") )
        }
        if( orgDetails.hasValue( forKey : "primary_zuid" ) )
        {
            organization.setPrimaryZuid( zuid : orgDetails.getInt64( key : "primary_zuid" ) )
        }
        if( orgDetails.hasValue( forKey : "zgid" ) )
        {
            organization.setZgid( zgid : orgDetails.getInt64( key : "zgid" ) )
        }
        if( orgDetails.hasValue( forKey : "phone" ) )
        {
            organization.setPhone( phone : orgDetails.getString( key : "phone" ) )
        }
        if( orgDetails.hasValue( forKey : "mobile" ) )
        {
            organization.setMobile( mobile : orgDetails.getString( key : "mobile" ) )
        }
        if( orgDetails.hasValue( forKey : "website" ) )
        {
            organization.setWebsite( website : orgDetails.getString( key : "website" ) )
        }
        if( orgDetails.hasValue( forKey : "primary_email" ) )
        {
            organization.setPrimaryEmail( email : orgDetails.getString( key : "primary_email" ) )
        }
        if( orgDetails.hasValue( forKey : "employee_count" ) )
        {
            organization.setEmployeeCount( count : orgDetails.getString( key : "employee_count" ) )
        }
        if( orgDetails.hasValue( forKey : "description" ) )
        {
            organization.setDescription( description : orgDetails.getString( key : "description" ) )
        }
        if( orgDetails.hasValue( forKey : "time_zone" ) )
        {
            organization.setTimeZone( timeZone : orgDetails.getString( key : "time_zone" ) )
        }
        if( orgDetails.hasValue( forKey : "iso_code" ) )
        {
            organization.setIsoCode( isoCode : orgDetails.getString( key : "iso_code" ) )
        }
        if( orgDetails.hasValue( forKey : "currency_locale" ) )
        {
            organization.setCurrencyLocale( currencyLocale : orgDetails.getString( key : "currency_locale" ) )
        }
        if( orgDetails.hasValue( forKey : "currency_symbol" ) )
        {
            organization.setCurrencySymbol( currencySymbol : orgDetails.getString( key : "currency_symbol" ) )
        }
        if( orgDetails.hasValue( forKey : "street" ) )
        {
            organization.setStreet( street : orgDetails.getString( key : "street" ) )
        }
        if( orgDetails.hasValue( forKey : "city" ) )
        {
            organization.setCity( city : orgDetails.getString( key : "city" ) )
        }
        if( orgDetails.hasValue( forKey : "state" ) )
        {
            organization.setState( state : orgDetails.getString( key : "state" ) )
        }
        if( orgDetails.hasValue( forKey : "country" ) )
        {
            organization.setCountry( country : orgDetails.getString( key : "country" ) )
        }
        if( orgDetails.hasValue( forKey : "country_code" ) )
        {
            organization.setCountryCode( countryCode : orgDetails.getString( key : "country_code" ) )
        }
        if( orgDetails.hasValue( forKey : "zip" ) )
        {
            organization.setZipCode( zipCode : orgDetails.getString( key : "zip" ) )
        }
        if( orgDetails.hasValue( forKey : "mc_status" ) )
        {
            organization.setMcStatus( mcStatus : orgDetails.getBoolean( key : "mc_status" ) )
        }
        if( orgDetails.hasValue( forKey : "gapps_enabled" ) )
        {
            organization.setGappsEnabled( gappsEnabled : orgDetails.getBoolean( key : "gapps_enabled" ) )
        }
        return organization
    }
}


