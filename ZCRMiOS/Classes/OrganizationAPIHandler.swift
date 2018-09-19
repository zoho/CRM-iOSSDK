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

    internal func getOrganizationDetails( completion : @escaping( Result.DataResponse< ZCRMOrganisation, APIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.ORG )
		setUrlPath(urlPath:  "/org" )
		setRequestMethod(requestMethod: .GET)
        let request : APIRequest = APIRequest(handler: self )
        print( "Request : \( request.toString() )" )
        
        request.getAPIResponse { ( resultType ) in
            do{
                let response = try resultType.resolve()
                let responseJSON : [ String :  Any ] = response.responseJSON
                let orgArray = responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                let org = self.getZCRMOrganization( orgDetails : orgArray[ 0 ] )
                response.setData( data : org )
                completion( .success( org, response ) )
            }
            catch{
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    // check optional property in organization API
    private func getZCRMOrganization( orgDetails : [ String : Any ] ) -> ZCRMOrganisation
    {
        let organization : ZCRMOrganisation = ZCRMOrganisation()
        if( orgDetails.hasValue( forKey : ResponseJSONKeys.id ) )
        {
            organization.orgId = orgDetails.getInt64( key : ResponseJSONKeys.id )
        }
        if( orgDetails.hasValue( forKey : ResponseJSONKeys.fax ) )
        {
            organization.fax = orgDetails.getString( key : ResponseJSONKeys.fax )
        }
        if( orgDetails.hasValue( forKey : ResponseJSONKeys.companyName ) )
        {
            organization.orgName = orgDetails.getString( key : ResponseJSONKeys.companyName )
        }
        if( orgDetails.hasValue( forKey : ResponseJSONKeys.alias ) )
        {
            organization.alias = orgDetails.getString( key : ResponseJSONKeys.alias)
        }
        if( orgDetails.hasValue( forKey : ResponseJSONKeys.primaryZUID ) )
        {
            organization.primary_zuid = orgDetails.getInt64( key : ResponseJSONKeys.primaryZUID )
        }
        if( orgDetails.hasValue( forKey : ResponseJSONKeys.ZGID ) )
        {
            organization.zgid = orgDetails.getInt64( key : ResponseJSONKeys.ZGID )
        }
        if( orgDetails.hasValue( forKey : ResponseJSONKeys.phone ) )
        {
            organization.phone = orgDetails.getString( key : ResponseJSONKeys.phone )
        }
        if( orgDetails.hasValue( forKey : ResponseJSONKeys.mobile ) )
        {
            organization.mobile = orgDetails.getString( key : ResponseJSONKeys.mobile )
        }
        if( orgDetails.hasValue( forKey : ResponseJSONKeys.website ) )
        {
            organization.website = orgDetails.getString( key : ResponseJSONKeys.website )
        }
        if( orgDetails.hasValue( forKey : ResponseJSONKeys.primaryEmail ) )
        {
            organization.primary_email = orgDetails.getString( key : ResponseJSONKeys.primaryEmail )
        }
        if( orgDetails.hasValue( forKey : ResponseJSONKeys.employeeCount ) )
        {
            organization.employee_count = orgDetails.getString( key : ResponseJSONKeys.employeeCount )
        }
        if( orgDetails.hasValue( forKey : ResponseJSONKeys.description ) )
        {
            organization.description = orgDetails.getString( key : ResponseJSONKeys.description )
        }
        if( orgDetails.hasValue( forKey : ResponseJSONKeys.timeZone ) )
        {
            organization.time_zone = orgDetails.getString( key : ResponseJSONKeys.timeZone )
        }
        if( orgDetails.hasValue( forKey : ResponseJSONKeys.ISOCode ) )
        {
            organization.iso_code = orgDetails.getString( key : ResponseJSONKeys.ISOCode )
        }
        if( orgDetails.hasValue( forKey : ResponseJSONKeys.currencyLocale ) )
        {
            organization.currency_locale = orgDetails.getString( key : ResponseJSONKeys.currencyLocale )
        }
        if( orgDetails.hasValue( forKey : ResponseJSONKeys.currencySymbol ) )
        {
            organization.currency_symbol = orgDetails.getString( key : ResponseJSONKeys.currencySymbol )
        }
        if( orgDetails.hasValue( forKey : ResponseJSONKeys.street ) )
        {
            organization.street = orgDetails.getString( key : ResponseJSONKeys.street )
        }
        if( orgDetails.hasValue( forKey : ResponseJSONKeys.city ) )
        {
            organization.city = orgDetails.getString( key : ResponseJSONKeys.city )
        }
        if( orgDetails.hasValue( forKey : ResponseJSONKeys.state ) )
        {
            organization.state = orgDetails.getString( key : ResponseJSONKeys.state )
        }
        if( orgDetails.hasValue( forKey : ResponseJSONKeys.country ) )
        {
            organization.country = orgDetails.getString( key : ResponseJSONKeys.country )
        }
        if( orgDetails.hasValue( forKey : ResponseJSONKeys.countryCode ) )
        {
            organization.country_code = orgDetails.getString( key : ResponseJSONKeys.countryCode )
        }
        if( orgDetails.hasValue( forKey : ResponseJSONKeys.zip ) )
        {
            organization.zipcode = orgDetails.getString( key : ResponseJSONKeys.zip )
        }
        if( orgDetails.hasValue( forKey : ResponseJSONKeys.mcStatus ) )
        {
            organization.mc_status = orgDetails.getBoolean( key : ResponseJSONKeys.mcStatus )
        }
        if( orgDetails.hasValue( forKey : ResponseJSONKeys.gappsEnabled ) )
        {
            organization.gapps_enabled = orgDetails.getBoolean( key : ResponseJSONKeys.gappsEnabled )
        }
        if( orgDetails.hasValue( forKey : ResponseJSONKeys.privacySettings ) )
        {
            organization.privacySettingsEnable = orgDetails.getBoolean( key : ResponseJSONKeys.privacySettings )
        }
        return organization
    }
}

fileprivate extension OrganizationAPIHandler
{
    struct ResponseJSONKeys
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

