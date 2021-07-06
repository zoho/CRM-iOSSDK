//
//  ZCRMUser.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 11/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

public class ZCRMUser : ZCRMUserDelegate
{
    public var lastName : String? {
        didSet
        {
            upsertJSON.updateValue(lastName, forKey: UserAPIHandler.ResponseJSONKeys.lastName)
        }
    }
    public var emailId : String{
        didSet
        {
            upsertJSON.updateValue(emailId, forKey: UserAPIHandler.ResponseJSONKeys.email)
        }
    }
    public var role : ZCRMRoleDelegate?{
        didSet
        {
            if let roleId = role?.id
            {
                upsertJSON.updateValue( String( roleId ), forKey : UserAPIHandler.ResponseJSONKeys.role )
            }
            else
            {
                upsertJSON.updateValue( nil, forKey : UserAPIHandler.ResponseJSONKeys.role )
            }
        }
    }
    public var profile : ZCRMProfileDelegate?{
        didSet
        {
            if let profileId = profile?.id
            {
                upsertJSON.updateValue( String( profileId ), forKey : UserAPIHandler.ResponseJSONKeys.profile )
            }
            else
            {
                upsertJSON.updateValue( nil, forKey : UserAPIHandler.ResponseJSONKeys.profile )
            }
            
        }
    }
    public internal( set ) var zuId : Int64?
    
    public var firstName : String?{
        didSet
        {
            upsertJSON.updateValue(firstName, forKey: UserAPIHandler.ResponseJSONKeys.firstName)
        }
    }
    public var alias : String?{
        didSet
        {
            upsertJSON.updateValue(alias, forKey: UserAPIHandler.ResponseJSONKeys.alias)
        }
    }
    public var dateOfBirth : String?{
        didSet
        {
            upsertJSON.updateValue(dateOfBirth, forKey: UserAPIHandler.ResponseJSONKeys.dob)
        }
    }
    
    public var mobile : String?{
        didSet
        {
            upsertJSON.updateValue(mobile, forKey: UserAPIHandler.ResponseJSONKeys.mobile)
        }
    }
    public var phone : String?{
        didSet
        {
            upsertJSON.updateValue(phone, forKey: UserAPIHandler.ResponseJSONKeys.phone)
        }
    }
    public var fax : String?{
        didSet
        {
            upsertJSON.updateValue(fax, forKey: UserAPIHandler.ResponseJSONKeys.fax)
        }
    }
    
    public var language : String?{
        didSet
        {
            upsertJSON.updateValue( language, forKey : UserAPIHandler.ResponseJSONKeys.language )
        }
    }
    public var street : String?{
        didSet
        {
            upsertJSON.updateValue(street, forKey: UserAPIHandler.ResponseJSONKeys.street)
        }
    }
    public var city : String?{
        didSet
        {
            upsertJSON.updateValue(city, forKey: UserAPIHandler.ResponseJSONKeys.city)
        }
    }
    public var state : String?{
        didSet
        {
            upsertJSON.updateValue(state, forKey: UserAPIHandler.ResponseJSONKeys.state)
        }
    }
    public var zip : Int64?{
        didSet
        {
            upsertJSON.updateValue(zip, forKey: UserAPIHandler.ResponseJSONKeys.zip)
        }
    }
    public var country : String?{
        didSet
        {
            upsertJSON.updateValue(country, forKey: UserAPIHandler.ResponseJSONKeys.country)
        }
    }
    public var locale : String?{
        didSet
        {
            upsertJSON.updateValue(locale, forKey: UserAPIHandler.ResponseJSONKeys.locale)
        }
    }
    public var countryLocale : String?{
        didSet
        {
            upsertJSON.updateValue(countryLocale, forKey: UserAPIHandler.ResponseJSONKeys.countryLocale)
        }
    }
    
    public var nameFormat : String?{
        didSet
        {
            upsertJSON.updateValue(nameFormat, forKey: UserAPIHandler.ResponseJSONKeys.nameFormat)
        }
    }
    public var dateFormat : String?{
        didSet
        {
            upsertJSON.updateValue(dateFormat, forKey: UserAPIHandler.ResponseJSONKeys.dateFormat)
        }
    }
    public var timeFormat : String?{
        didSet
        {
            upsertJSON.updateValue(timeFormat, forKey: UserAPIHandler.ResponseJSONKeys.timeFormat)
        }
    }
    
    public var timeZone : String?{
        didSet
        {
            upsertJSON.updateValue(timeZone, forKey: UserAPIHandler.ResponseJSONKeys.timeZone)
        }
    }
    public var website : String?{
        didSet
        {
            upsertJSON.updateValue(website, forKey: UserAPIHandler.ResponseJSONKeys.website)
        }
    }
    public internal( set ) var isConfirmed : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var status : String = APIConstants.STRING_MOCK
    
    public internal( set ) var createdBy : ZCRMUserDelegate?
    public internal( set ) var createdTime : String?
    public internal( set ) var modifiedBy : ZCRMUserDelegate?
    public internal( set ) var modifiedTime : String?
    public internal( set ) var reportingTo : ZCRMUserDelegate?
    public internal( set ) var sortOrderPreference : String?
    
    internal var isCreate : Bool = APIConstants.BOOL_MOCK
    
    internal init( emailId : String, role : ZCRMRoleDelegate, profile : ZCRMProfileDelegate )
    {
        self.emailId = emailId
        self.role = role
        self.profile = profile
        self.isCreate = true
        super.init( id : APIConstants.INT64_MOCK, name : APIConstants.STRING_MOCK )
        upsertJSON.updateValue(emailId, forKey: UserAPIHandler.ResponseJSONKeys.email)
        upsertJSON.updateValue(String( role.id ), forKey: UserAPIHandler.ResponseJSONKeys.role)
        upsertJSON.updateValue(String( profile.id ), forKey: UserAPIHandler.ResponseJSONKeys.profile)
    }
    
    internal init( emailId : String )
    {
        self.emailId = emailId
        super.init(id: APIConstants.INT64_MOCK, name: APIConstants.STRING_MOCK)
    }
    
    public func resetModifiedValues()
    {
        if self.upsertJSON.hasValue( forKey : UserAPIHandler.ResponseJSONKeys.lastName ), let lastName = self.data[ UserAPIHandler.ResponseJSONKeys.lastName ] as? String
        {
            self.lastName = lastName
        }
        if self.upsertJSON.hasValue( forKey : UserAPIHandler.ResponseJSONKeys.email ), let email = self.data[ UserAPIHandler.ResponseJSONKeys.email ] as? String
        {
            self.emailId = email
        }
        if self.upsertJSON.hasValue( forKey : UserAPIHandler.ResponseJSONKeys.role )
        {
            self.role = self.data[ UserAPIHandler.ResponseJSONKeys.role ] as? ZCRMRoleDelegate
        }
        if self.upsertJSON.hasValue( forKey : UserAPIHandler.ResponseJSONKeys.profile )
        {
            self.profile = self.data[ UserAPIHandler.ResponseJSONKeys.profile ] as? ZCRMProfileDelegate
        }
        if self.upsertJSON.hasValue( forKey : UserAPIHandler.ResponseJSONKeys.firstName )
        {
            self.firstName = self.data[ UserAPIHandler.ResponseJSONKeys.firstName ] as? String
            
        }
        if self.upsertJSON.hasValue( forKey : UserAPIHandler.ResponseJSONKeys.alias )
        {
            self.alias = self.data[ UserAPIHandler.ResponseJSONKeys.alias ] as? String
        }
        if self.upsertJSON.hasValue( forKey : UserAPIHandler.ResponseJSONKeys.dob )
        {
            self.dateOfBirth = self.data[ UserAPIHandler.ResponseJSONKeys.dob ] as? String
        }
        if self.upsertJSON.hasValue( forKey : UserAPIHandler.ResponseJSONKeys.mobile )
        {
            self.mobile = self.data[ UserAPIHandler.ResponseJSONKeys.mobile ] as? String
        }
        if self.upsertJSON.hasValue( forKey : UserAPIHandler.ResponseJSONKeys.phone )
        {
            self.phone = self.data[ UserAPIHandler.ResponseJSONKeys.phone ] as? String
        }
        if self.upsertJSON.hasValue( forKey : UserAPIHandler.ResponseJSONKeys.fax )
        {
            self.fax = self.data[ UserAPIHandler.ResponseJSONKeys.fax ] as? String
        }
        if self.upsertJSON.hasValue( forKey : UserAPIHandler.ResponseJSONKeys.street )
        {
            self.street = self.data[ UserAPIHandler.ResponseJSONKeys.street ] as? String
        }
        if self.upsertJSON.hasValue( forKey : UserAPIHandler.ResponseJSONKeys.city )
        {
            self.city = self.data[ UserAPIHandler.ResponseJSONKeys.city ] as? String
        }
        if self.upsertJSON.hasValue( forKey : UserAPIHandler.ResponseJSONKeys.state )
        {
            self.state = self.data[ UserAPIHandler.ResponseJSONKeys.state ] as? String
        }
        if self.upsertJSON.hasValue( forKey : UserAPIHandler.ResponseJSONKeys.zip )
        {
            self.zip = self.data[ UserAPIHandler.ResponseJSONKeys.zip ] as? Int64
        }
        if self.upsertJSON.hasValue( forKey : UserAPIHandler.ResponseJSONKeys.country )
        {
            self.country = self.data[ UserAPIHandler.ResponseJSONKeys.country ] as? String
        }
        if self.upsertJSON.hasValue( forKey : UserAPIHandler.ResponseJSONKeys.locale )
        {
            self.locale = self.data[ UserAPIHandler.ResponseJSONKeys.locale ] as? String
        }
        if self.upsertJSON.hasValue( forKey : UserAPIHandler.ResponseJSONKeys.countryLocale )
        {
            self.countryLocale = self.data[ UserAPIHandler.ResponseJSONKeys.countryLocale ] as? String
        }
        if self.upsertJSON.hasValue( forKey : UserAPIHandler.ResponseJSONKeys.nameFormat )
        {
            self.nameFormat = self.data[ UserAPIHandler.ResponseJSONKeys.nameFormat ] as? String
        }
        if self.upsertJSON.hasValue( forKey : UserAPIHandler.ResponseJSONKeys.dateFormat )
        {
            self.dateFormat = self.data[ UserAPIHandler.ResponseJSONKeys.dateFormat ] as? String
        }
        if self.upsertJSON.hasValue( forKey : UserAPIHandler.ResponseJSONKeys.timeFormat )
        {
            self.timeFormat = self.data[ UserAPIHandler.ResponseJSONKeys.timeFormat ] as? String
        }
        if self.upsertJSON.hasValue( forKey : UserAPIHandler.ResponseJSONKeys.timeZone )
        {
            self.timeZone = self.data[ UserAPIHandler.ResponseJSONKeys.timeZone ] as? String
        }
        if self.upsertJSON.hasValue( forKey : UserAPIHandler.ResponseJSONKeys.website )
        {
            self.website = self.data[ UserAPIHandler.ResponseJSONKeys.website ] as? String
        }
        self.upsertJSON = [ String : Any? ]()
    }
    
    public func setValue( ofFieldAPIName : String, value : Any? )
    {
        self.upsertJSON.updateValue( value, forKey : ofFieldAPIName )
    }
    
    public func getValue( ofFieldAPIName : String ) throws -> Any?
    {
        if self.upsertJSON.hasValue( forKey : ofFieldAPIName )
        {
            return self.upsertJSON.optValue( key : ofFieldAPIName )
        }
        else if ( self.data.hasKey( forKey : ofFieldAPIName ) )
        {
            return self.data.optValue( key : ofFieldAPIName )
        }
        else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.fieldNotFound) : The given field is not present in this user - \( ofFieldAPIName ), \( APIConstants.DETAILS ) : -")
            throw ZCRMError.processingError( code : ErrorCode.fieldNotFound, message : "The given field is not present in this user - \( ofFieldAPIName )", details : nil )
        }
    }
    
    public func getData() -> [ String : Any? ]
    {
        var data : [ String : Any? ] = [ String : Any? ]()
        data = self.data
        for ( key, value ) in self.upsertJSON
        {
            data.updateValue( value, forKey : key )
        }
        return data
    }
    
    public func create( completion : @escaping( Result.DataResponse< ZCRMUser, APIResponse > ) -> () )
    {
        UserAPIHandler().addUser( user : self ) { ( result ) in
            self.isCreate = false
            completion( result )
        }
    }
    
    public func update( completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        UserAPIHandler().updateUser( user : self ) { ( result ) in
            completion( result )
        }
    }
}

extension ZCRMUser : NSCopying
{
    public func copy( with zone : NSZone? = nil ) -> Any
    {
        let copy = ZCRMUser( emailId : self.emailId )
        copy.lastName = self.lastName
        copy.role = self.role
        copy.profile = self.profile
        copy.zuId = self.zuId
        copy.firstName = self.firstName
        copy.alias = self.alias
        copy.dateOfBirth = self.dateOfBirth
        copy.mobile = self.mobile
        copy.phone = self.phone
        copy.fax = self.fax
        copy.language = self.language
        copy.street = self.street
        copy.city = self.city
        copy.state = self.state
        copy.zip = self.zip
        copy.country = self.country
        copy.locale = self.locale
        copy.countryLocale = self.countryLocale
        copy.nameFormat = self.nameFormat
        copy.dateFormat = self.dateFormat
        copy.timeFormat = self.timeFormat
        copy.timeZone = self.timeZone
        copy.website = self.website
        copy.isConfirmed = self.isConfirmed
        copy.status = self.status
        copy.createdBy = self.createdBy
        copy.createdTime = self.createdTime
        copy.modifiedBy = self.modifiedBy
        copy.modifiedTime = self.modifiedTime
        copy.reportingTo = self.reportingTo
        copy.data = self.data
        copy.isCreate = self.isCreate
        copy.upsertJSON = self.upsertJSON
        copy.sortOrderPreference = self.sortOrderPreference
        return copy
    }
    
    public static func == (lhs: ZCRMUser, rhs: ZCRMUser) -> Bool {
        if lhs.data.count == rhs.data.count {
            for ( key, value ) in lhs.data
            {
                if rhs.data.hasKey( forKey : key )
                {
                    if !isEqual( lhs : value, rhs : rhs.data[ key ] as Any? )
                    {
                        return false
                    }
                }
                else
                {
                    return false
                }
            }
        }
        else
        {
            return false
        }
        let equals : Bool = lhs.lastName == rhs.lastName &&
            lhs.emailId == rhs.emailId &&
            lhs.role == rhs.role &&
            lhs.profile == rhs.profile &&
            lhs.zuId == rhs.zuId &&
            lhs.firstName == rhs.firstName &&
            lhs.alias == rhs.alias &&
            lhs.dateOfBirth == rhs.dateOfBirth &&
            lhs.mobile == rhs.mobile &&
            lhs.phone == rhs.phone &&
            lhs.fax == rhs.fax &&
            lhs.language == rhs.language &&
            lhs.street == rhs.street &&
            lhs.city == rhs.city &&
            lhs.state == rhs.state &&
            lhs.zip == rhs.zip &&
            lhs.country == rhs.country &&
            lhs.locale == rhs.locale &&
            lhs.countryLocale == rhs.countryLocale &&
            lhs.nameFormat == rhs.nameFormat &&
            lhs.dateFormat == rhs.dateFormat &&
            lhs.timeFormat == rhs.timeFormat &&
            lhs.timeZone == rhs.timeZone &&
            lhs.website == rhs.website &&
            lhs.isConfirmed == rhs.isConfirmed &&
            lhs.status == rhs.status &&
            lhs.createdBy == rhs.createdBy &&
            lhs.createdTime == rhs.createdTime &&
            lhs.modifiedBy == rhs.modifiedBy &&
            lhs.modifiedTime == rhs.modifiedTime &&
            lhs.reportingTo == rhs.reportingTo &&
            lhs.sortOrderPreference == rhs.sortOrderPreference
        return equals
    }
}

