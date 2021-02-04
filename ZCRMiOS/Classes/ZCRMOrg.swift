//
//  User.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 09/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

public class ZCRMOrg : ZCRMOrgDelegate
{
    public var name : String?
    {
        didSet
        {
            if oldValue != name
            {
                upsertJSON.updateValue( name, forKey: OrgAPIHandler.ResponseJSONKeys.companyName)
            }
        }
    }
    public internal( set ) var id : Int64 = APIConstants.INT64_MOCK
    
    public var alias : String?
    {
        didSet
        {
            if oldValue != alias
            {
                upsertJSON.updateValue( alias, forKey: OrgAPIHandler.ResponseJSONKeys.alias)
            }
        }
    }
    public var primaryZUID : Int64 = APIConstants.INT64_MOCK
    {
        didSet
        {
            if oldValue != primaryZUID
            {
                upsertJSON.updateValue( primaryZUID, forKey: OrgAPIHandler.ResponseJSONKeys.primaryZUID)
            }
        }
    }
    public internal( set ) var zgid : Int64 = APIConstants.INT64_MOCK
    public internal( set ) var ziaPortalId : Int64?
    
    public internal( set ) var primaryEmail : String = APIConstants.STRING_MOCK
    public var website : String?
    {
        didSet
        {
            if oldValue != website
            {
                upsertJSON.updateValue( website, forKey: OrgAPIHandler.ResponseJSONKeys.website)
            }
        }
    }
    public var mobile : String?
    {
        didSet
        {
            if oldValue != mobile
            {
                upsertJSON.updateValue( mobile, forKey: OrgAPIHandler.ResponseJSONKeys.mobile)
            }
        }
    }
    public var phone : String?
    {
        didSet
        {
            if oldValue != phone
            {
                upsertJSON.updateValue( phone, forKey: OrgAPIHandler.ResponseJSONKeys.phone)
            }
        }
    }
    public var fax : String?
    {
        didSet
        {
            if oldValue != fax
            {
                upsertJSON.updateValue( fax, forKey: OrgAPIHandler.ResponseJSONKeys.fax)
            }
        }
    }
    public var employeeCount : String?
    {
        didSet
        {
            if oldValue != employeeCount
            {
                upsertJSON.updateValue( employeeCount, forKey: OrgAPIHandler.ResponseJSONKeys.employeeCount)
            }
        }
    }
    public var description : String?
    {
        didSet
        {
            if oldValue != description
            {
                upsertJSON.updateValue( description, forKey: OrgAPIHandler.ResponseJSONKeys.description)
            }
        }
    }
    public var timeZone : String?
    {
        didSet
        {
            if oldValue != timeZone
            {
                upsertJSON.updateValue( timeZone, forKey: OrgAPIHandler.ResponseJSONKeys.timeZone)
            }
        }
    }
    public internal( set ) var isoCode : String = APIConstants.STRING_MOCK
    public internal( set ) var currencyLocale : String = APIConstants.STRING_MOCK
    public internal( set ) var currencySymbol : String = APIConstants.STRING_MOCK
    public var street : String?
    {
        didSet
        {
            if oldValue != street
            {
                upsertJSON.updateValue( street, forKey: OrgAPIHandler.ResponseJSONKeys.street)
            }
        }
    }
    public var city : String?
    {
        didSet
        {
            if oldValue != city
            {
                upsertJSON.updateValue( city, forKey: OrgAPIHandler.ResponseJSONKeys.city)
            }
        }
    }
    public var state : String?
    {
        didSet
        {
            if oldValue != state
            {
                upsertJSON.updateValue( state, forKey: OrgAPIHandler.ResponseJSONKeys.state)
            }
        }
    }
    public var country : String?
    {
        didSet
        {
            if oldValue != country
            {
                upsertJSON.updateValue( country, forKey: OrgAPIHandler.ResponseJSONKeys.country)
            }
        }
    }
    public var zipcode : String?
    {
        didSet
        {
            if oldValue != zipcode
            {
                upsertJSON.updateValue( zipcode, forKey: OrgAPIHandler.ResponseJSONKeys.zip)
            }
        }
    }
    public var countryCode : String = APIConstants.STRING_MOCK
    {
        didSet
        {
            if oldValue != countryCode
            {
                upsertJSON.updateValue( countryCode, forKey: OrgAPIHandler.ResponseJSONKeys.countryCode)
            }
        }
    }
    
    public internal( set ) var logoId : String?
    public internal( set ) var currency : String = APIConstants.STRING_MOCK
    
    public internal( set ) var mcStatus : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var isGappsEnabled : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var isPrivacySettingsEnable : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var isTranslationEnabled : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var licenseDetails : LicenseDetails = LicenseDetails( licensePlan: APIConstants.STRING_MOCK )
    
    internal var upsertJSON : [ String : Any? ] = [ String : Any? ]()
    public struct LicenseDetails : Equatable
    {
        public internal( set ) var expiryDate : String?
        public internal( set ) var noOfUsersPurchased : Int = APIConstants.INT_MOCK
        public internal( set ) var trialType : String?
        public internal( set ) var isPaid : Bool = APIConstants.BOOL_MOCK
        public internal( set ) var licensePlan : String = APIConstants.STRING_MOCK
        var trialAction : String?
        
        init( licensePlan : String )
        {
            self.licensePlan = licensePlan
        }
        
        public static func == ( lhs : LicenseDetails, rhs : LicenseDetails ) -> Bool
        {
            let equals : Bool = lhs.expiryDate == rhs.expiryDate &&
                lhs.noOfUsersPurchased == rhs.noOfUsersPurchased &&
                lhs.trialType == rhs.trialType &&
                lhs.isPaid == rhs.isPaid &&
                lhs.licensePlan == rhs.licensePlan &&
                lhs.trialAction == rhs.trialAction
            return equals
        }
    }
    
    public func update( completion : @escaping( CRMResultType.DataResponse< ZCRMOrg, APIResponse > ) -> () )
    {
        OrgAPIHandler( cacheFlavour: .noCache ).update( self ) { result in
            completion( result )
        }
    }
    
    public func getCurrencies( completion : @escaping( CRMResultType.DataResponse< [ ZCRMCurrency ], BulkAPIResponse > ) -> () )
    {
        OrgAPIHandler( cacheFlavour : .urlVsResponse ).getCurrencies { ( result ) in
            completion( result )
        }
    }
    
    public func getCurrenciesFromServer( completion : @escaping( CRMResultType.DataResponse< [ ZCRMCurrency ], BulkAPIResponse > ) -> () )
    {
        OrgAPIHandler( cacheFlavour : .noCache ).getCurrencies { ( result ) in
            completion( result )
        }
    }
    
    public func getCurrency( byId id : Int64, completion : @escaping( CRMResultType.DataResponse< ZCRMCurrency, APIResponse > ) -> () )
    {
        OrgAPIHandler( cacheFlavour : .urlVsResponse ).getCurrency( byId : id ) { ( result ) in
            completion( result )
        }
    }
    
    public func getCurrencyFromServer( byId id : Int64, completion : @escaping( CRMResultType.DataResponse< ZCRMCurrency, APIResponse > ) -> () )
    {
        OrgAPIHandler( cacheFlavour : .noCache ).getCurrency( byId : id ) { ( result ) in
            completion( result )
        }
    }
    
    public func newCurrency( name : String, symbol : String, isoCode : String, exchangeRate : Double, format : ZCRMCurrency.Format) -> ZCRMCurrency
    {
        let currency = ZCRMCurrency( name: name, symbol: symbol, isoCode: isoCode )
        currency.exchangeRate = exchangeRate
        currency.format = format
        return currency
    }
    
    public func addCurrencies( _ currencies : [ ZCRMCurrency ], completion : @escaping ( CRMResultType.DataResponse< [ ZCRMCurrency ], BulkAPIResponse > ) -> ())
    {
        OrgAPIHandler().addCurrencies( currencies ) { result in
            completion( result )
        }
    }
    
    public func updateCurrencies( _ currencies : [ ZCRMCurrency ], completion : @escaping ( CRMResultType.DataResponse< [ ZCRMCurrency ], BulkAPIResponse > ) -> ())
    {
        OrgAPIHandler().updateCurrencies( currencies ) { result in
            completion( result )
        }
    }
    
    public func enableMultiCurrency( _ currency : ZCRMCurrency, completion : @escaping ( CRMResultType.DataResponse< ZCRMCurrency, APIResponse >) -> () )
    {
        OrgAPIHandler().enableMultiCurrency( currency ) { result in
            completion( result )
        }
    }
    
    public func getBaseCurrency( completion : @escaping( CRMResultType.Data< ZCRMCurrency > ) -> () )
    {
        if self.mcStatus
        {
            OrgAPIHandler(cacheFlavour: .noCache).getBaseCurrency { ( result ) in
                completion( result )
            }
        }
        else
        {
            let currency = ZCRMCurrency( name : self.currency, symbol : currencySymbol, isoCode : isoCode )
            currency.isBase = true
            completion( .success( currency ) )
        }
    }
}

extension ZCRMOrg : Hashable
{
    public static func == (lhs: ZCRMOrg, rhs: ZCRMOrg) -> Bool {
        let equals : Bool = lhs.name == rhs.name &&
            lhs.id == rhs.id &&
            lhs.alias == rhs.alias &&
            lhs.primaryZUID == rhs.primaryZUID &&
            lhs.zgid == rhs.zgid &&
            lhs.primaryEmail == rhs.primaryEmail &&
            lhs.website == rhs.website &&
            lhs.mobile == rhs.mobile &&
            lhs.phone == rhs.phone &&
            lhs.fax == rhs.fax &&
            lhs.employeeCount == rhs.employeeCount &&
            lhs.description == rhs.description &&
            lhs.timeZone == rhs.timeZone &&
            lhs.isoCode == rhs.isoCode &&
            lhs.currencyLocale == rhs.currencyLocale &&
            lhs.currencySymbol == rhs.currencySymbol &&
            lhs.street == rhs.street &&
            lhs.city == rhs.city &&
            lhs.state == rhs.state &&
            lhs.country == rhs.country &&
            lhs.zipcode == rhs.zipcode &&
            lhs.countryCode == rhs.countryCode &&
            lhs.mcStatus == rhs.mcStatus &&
            lhs.isGappsEnabled == rhs.isGappsEnabled &&
            lhs.isPrivacySettingsEnable == rhs.isPrivacySettingsEnable &&
            lhs.isTranslationEnabled == rhs.isTranslationEnabled &&
            lhs.licenseDetails == rhs.licenseDetails
        
        return equals
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine( id )
        hasher.combine( zgid )
    }
}



