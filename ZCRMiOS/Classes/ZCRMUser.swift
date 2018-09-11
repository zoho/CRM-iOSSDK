//
//  ZCRMUser.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 11/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

public class ZCRMUser : ZCRMEntity
{
    private var id : Int64?
    private var zuId : Int64?
    
    private var fullName : String?
    private var firstName : String?
    private var lastName : String?
    private var alias : String?
    private var dateOfBirth : String?
    
    private var mobile : String?
    private var emailId : String?
    private var phone : String?
    private var fax : String?
    
    private var language : String?
    private var street : String?
    private var city : String?
    private var state : String?
    private var zip : Int64?
    private var country : String?
    private var locale : String?
    private var countryLocale : String?
    
    private var nameFormat : String?
    private var dateFormat : String?
    private var timeFormat : String?
    
    private var timeZone : String?
    private var website : String?
    private var confirm : Bool?
    private var status : String?
    private var role : ZCRMRole?
    private var profile : ZCRMProfile?
    
    private var createdBy : ZCRMUser?
    private var createdTime : String?
    private var modifiedBy : ZCRMUser?
    private var modifiedTime : String?
    private var reportingTo : ZCRMUser?
    
    private var fieldNameVsValue : [ String : Any ]?
    
    public init( userId : Int64 )
    {
        self.id = userId
    }
    
    public init(userId : Int64, userFullName : String) {
        self.id = userId
        self.fullName = userFullName
    }
    
    public init(){}
    
    public init( lastName : String, email : String, role : ZCRMRole, profile : ZCRMProfile )
    {
        self.role = role
        self.emailId = email
        self.lastName = lastName
        self.profile = profile
    }
    
    internal func setId( id : Int64 )
    {
        self.id = id
    }
    
    public func getId() -> Int64?
    {
        return self.id
    }
    
    internal func setFullName( name : String )
    {
        self.fullName = name
    }
    
    public func getFullName() -> String?
    {
        return self.fullName
    }
    
    internal func setZuId(zuId : Int64?)
    {
        self.zuId = zuId
    }
    
    public func getZuId() -> Int64?
    {
        return self.zuId
    }
    
    internal func setFirstName(fName : String?)
    {
        self.firstName = fName
    }
    
    public func getFirstName() -> String?
    {
        return self.firstName
    }
    
    internal func setLastName(lName : String)
    {
        self.lastName = lName
    }
    
    public func getLastName() -> String?
    {
        return self.lastName
    }
    
    internal func setLanguage(language : String?)
    {
        self.language = language
    }
    
    public func getLanguage() -> String?
    {
        return self.language
    }
    
    internal func setMobile(mobile : String?)
    {
        self.mobile = mobile
    }
    
    public func getMobile() -> String?
    {
        return self.mobile
    }
    
    internal func setEmailId(email : String)
    {
        self.emailId = email
    }
    
    public func getEmailId() -> String?
    {
        return self.emailId
    }
    
    internal func setStatus(status : String?)
    {
        self.status = status
    }
    
    public func getStatus() -> String?
    {
        return self.status
    }
    
    internal func setRole(role : ZCRMRole)
    {
        self.role = role
    }
    
    public func getRole() -> ZCRMRole?
    {
        return self.role
    }
    
    internal func setProfile(profile : ZCRMProfile)
    {
        self.profile = profile
    }
    
    public func getProfile() -> ZCRMProfile?
    {
        return self.profile
    }
    
    internal func setTimeZone( timeZone : String? )
    {
        self.timeZone = timeZone
    }
    
    public func getTimeZone() -> String?
    {
        return self.timeZone
    }
    
    internal func setStreet( street : String? )
    {
        self.street = street
    }
    
    public func getStreet() -> String?
    {
        return self.street
    }
    
    internal func setZip( zip : Int64? )
    {
        self.zip = zip
    }
    
    public func getZip() -> Int64?
    {
        return self.zip
    }
    
    internal func setCity( city : String? )
    {
        self.city = city
    }
    
    public func getCity() -> String?
    {
        return self.city
    }
    
    internal func setState( state : String? )
    {
        self.state = state
    }
    
    public func getState() -> String?
    {
        return self.state
    }
    
    internal func setCountry( country : String? )
    {
        self.country = country
    }
    
    public func getCountry() -> String?
    {
        return self.country
    }
    
    internal func setLocale( locale : String? )
    {
        self.locale = locale
    }
    
    public func getLocale() -> String?
    {
        return self.locale
    }
    
    internal func setCountryLocale( countryLocale : String? )
    {
        self.countryLocale = countryLocale
    }
    
    public func getCountryLocale() -> String?
    {
        return self.countryLocale
    }
    
    internal func setWebsite( website : String? )
    {
        self.website = website
    }
    
    public func getWebsite() -> String?
    {
        return self.website
    }
    
    internal func setFax( fax : String? )
    {
        self.fax = fax
    }
    
    public func getFax() -> String?
    {
        return self.fax
    }
    
    internal func setPhone( phone : String? )
    {
        self.phone = phone
    }
    
    public func getPhone() -> String?
    {
        return self.phone
    }
    
    internal func setNameFormat( format : String? )
    {
        self.nameFormat = format
    }
    
    public func getNameFormat() -> String?
    {
        return self.nameFormat
    }
    
    internal func setDateFormat( format : String? )
    {
        self.dateFormat = format
    }
    
    public func getDateFormat() -> String?
    {
        return self.dateFormat
    }
    
    internal func setTimeFormat( format : String? )
    {
        self.timeFormat = format
    }
    
    public func getTimeFormat() -> String?
    {
        return self.timeFormat
    }
    
    internal func setDateOfBirth( dateOfBirth : String? )
    {
        self.dateOfBirth = dateOfBirth
    }
    
    public func getDateOfBirth() -> String?
    {
        return self.dateOfBirth
    }
    
    internal func setAlias( alias : String? )
    {
        self.alias = alias
    }
    
    public func getAlias() -> String?
    {
        return self.alias
    }
    
    internal func setIsConfirmed( confirm : Bool? )
    {
        self.confirm = confirm
    }
    
    public func isConfirmedUser() -> Bool?
    {
        return self.confirm
    }
    
    internal func setReportingTo( reportingTo : ZCRMUser? )
    {
        self.reportingTo = reportingTo
    }
    
    public func getReportingTo() -> ZCRMUser?
    {
        return self.reportingTo
    }
    
    internal func setCreatedBy( createdBy : ZCRMUser )
    {
        self.createdBy = createdBy
    }
    
    public func getCreatedBy() -> ZCRMUser?
    {
        return self.createdBy
    }
    
    internal func setCreatedTime( createdTime : String )
    {
        self.createdTime = createdTime
    }
    
    public func getCreatedTime() -> String?
    {
        return self.createdTime
    }
    
    internal func setModifiedBy( modifiedBy : ZCRMUser )
    {
        self.modifiedBy = modifiedBy
    }
    
    public func getModifiedBy() -> ZCRMUser?
    {
        return self.modifiedBy
    }
    
    internal func setModifiedTime( modifiedTime : String )
    {
        self.modifiedTime = modifiedTime
    }
    
    public func getModifiedTime() -> String?
    {
        return self.modifiedTime
    }
    
    internal func setFieldValue( fieldAPIName : String, value : Any )
    {
        if self.fieldNameVsValue == nil
        {
            self.fieldNameVsValue = [ String : Any ]()
        }
        self.fieldNameVsValue![ fieldAPIName ] = value
    }
    
    public func getFieldValue( fieldAPIName : String ) throws -> Any?
    {
        if (self.fieldNameVsValue?.hasKey( forKey : fieldAPIName ))!
        {
            if( self.fieldNameVsValue?.hasValue( forKey : fieldAPIName ) )!
            {
                return self.fieldNameVsValue?.optValue( key : fieldAPIName )
            }
            else
            {
                return nil
            }
        }
        else
        {
            throw ZCRMSDKError.ProcessingError( "The given field is not present in this user - \( fieldAPIName )" )
        }
    }
    
    public func getData() -> [ String : Any ]?
    {
        return self.fieldNameVsValue
    }
    
    public func create() throws -> APIResponse
    {
        return try UserAPIHandler().addUser( user : self )
    }
    
    public func update() throws -> APIResponse
    {
        return try UserAPIHandler().updateUser( user : self )
    }
    
    public func delete() throws -> APIResponse
    {
        return try UserAPIHandler().deleteUser( userId : self.getId()! )
    }
    
    public func downloadProfilePhoto() throws -> FileAPIResponse
    {
        return try UserAPIHandler().downloadPhoto( size : PhotoSize.ORIGINAL )
    }
    
    public func downloadProfilePhoto( size : PhotoSize ) throws -> FileAPIResponse
    {
        return try UserAPIHandler().downloadPhoto( size : size )
    }
}

