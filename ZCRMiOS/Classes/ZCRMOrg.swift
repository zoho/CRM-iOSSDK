//
//  User.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 09/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

public class ZCRMOrg : ZCRMOrgDelegate
{
    public internal( set ) var name : String = APIConstants.STRING_MOCK
    public internal( set ) var id : Int64 = APIConstants.INT64_MOCK
    
    public internal( set ) var alias : String?
    public internal( set ) var primaryZUID : Int64 = APIConstants.INT64_MOCK
    public internal( set ) var zgid : Int64 = APIConstants.INT64_MOCK
    public internal( set ) var ziaPortalId : Int64?
    
    public internal( set ) var primaryEmail : String = APIConstants.STRING_MOCK
    public internal( set ) var website : String?
    public internal( set ) var mobile : String?
    public internal( set ) var phone : String?
    public internal( set ) var fax : String?
    
    public internal( set ) var employeeCount : String?
    public internal( set ) var description : String?
    
    public internal( set ) var timeZone : String?
    public internal( set ) var isoCode : String?
    public internal( set ) var currencyLocale : String?
    public internal( set ) var currencySymbol : String?
    public internal( set ) var street : String?
    public internal( set ) var city : String?
    public internal( set ) var state : String?
    public internal( set ) var country : String?
    public internal( set ) var zipcode : String?
    public internal( set ) var countryCode : String?
    
    public internal( set ) var logoId : String?
    public internal( set ) var currency : String?
    
    public internal( set ) var mcStatus : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var isGappsEnabled : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var isPrivacySettingsEnable : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var licenseDetails : LicenseDetails?
    
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
    
    public func getCurrencies( completion : @escaping( Result.DataResponse< [ ZCRMCurrency ], BulkAPIResponse > ) -> () )
    {
        OrgAPIHandler( cacheFlavour : .urlVsResponse ).getCurrencies { ( result ) in
            completion( result )
        }
    }
    
    public func getCurrenciesFromServer( completion : @escaping( Result.DataResponse< [ ZCRMCurrency ], BulkAPIResponse > ) -> () )
    {
        OrgAPIHandler( cacheFlavour : .noCache ).getCurrencies { ( result ) in
            completion( result )
        }
    }
    
    public func getBaseCurrency( completion : @escaping( Result.Data< ZCRMCurrency > ) -> () )
    {
        if self.mcStatus
        {
            OrgAPIHandler(cacheFlavour: .noCache).getBaseCurrency { ( result ) in
                completion( result )
            }
        }
        else
        {
            if let currency = self.currency, let symbol = self.currencySymbol, let isoCode = self.isoCode
            {
                let currency = ZCRMCurrency( name : currency, symbol : symbol, isoCode : isoCode )
                currency.isBase = true
                completion( .success( currency ) )
            }
            else
            {
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( ErrorCode.insufficientData ) : BASE CURRENCY not found" )
                completion( .failure( ZCRMError.processingError( code : ErrorCode.insufficientData, message : "BASE CURRENCY not found", details : nil) ) )
            }
        }
    }
}

extension ZCRMOrg : Equatable
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
            lhs.licenseDetails == rhs.licenseDetails
        
        return equals
    }
}


