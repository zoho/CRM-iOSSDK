//
//  ZCRMUser.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 11/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

public class ZCRMUser : ZCRMUserDelegate
{
    public var lastName : String
    public var emailId : String
    public var role : ZCRMRoleDelegate
    public var profile : ZCRMProfileDelegate
    public var zuId : Int64?
    
    public var fullName : String = APIConstants.STRING_MOCK
    public var firstName : String?
    public var alias : String?
    public var dateOfBirth : String?
    
    public var mobile : String?
    public var phone : String?
    public var fax : String?
    
    public var language : String = APIConstants.STRING_MOCK
    public var street : String?
    public var city : String?
    public var state : String?
    public var zip : Int64?
    public var country : String = APIConstants.STRING_MOCK
    public var locale : String = APIConstants.STRING_MOCK
    public var countryLocale : String = APIConstants.STRING_MOCK
    
    public var nameFormat : String = APIConstants.STRING_MOCK
    public var dateFormat : String = APIConstants.STRING_MOCK
    public var timeFormat : String = APIConstants.STRING_MOCK
    
    public var timeZone : String = APIConstants.STRING_MOCK
    public var website : String?
    public var confirm : Bool = APIConstants.BOOL_MOCK
    public var status : String = APIConstants.STRING_MOCK
    
    public var createdBy : ZCRMUserDelegate?
    public var createdTime : String?
    public var modifiedBy : ZCRMUserDelegate?
    public var modifiedTime : String?
    public var reportingTo : ZCRMUserDelegate = USER_MOCK
    
    public var fieldNameVsValue : [ String : Any ] = [ String : Any ]()
    
    internal init( lastName : String, emailId : String, role : ZCRMRoleDelegate, profile : ZCRMProfileDelegate )
    {
        self.lastName = lastName
        self.emailId = emailId
        self.role = role
        self.profile = profile
        super.init( id : APIConstants.INT64_MOCK, name : self.lastName )
    }
    
    public func setFieldValue( fieldAPIName : String, value : Any )
    {
        self.fieldNameVsValue[ fieldAPIName ] = value
    }
    
    public func getFieldValue( fieldAPIName : String ) throws -> Any?
    {
        if (self.fieldNameVsValue.hasKey( forKey : fieldAPIName ))
        {
            if( self.fieldNameVsValue.hasValue( forKey : fieldAPIName ) )
            {
                return self.fieldNameVsValue.optValue( key : fieldAPIName )
            }
            else
            {
                return nil
            }
        }
        else
        {
            throw ZCRMError.ProcessingError( code : ErrorCode.FIELD_NOT_FOUND, message : "The given field is not present in this user - \( fieldAPIName )" )
        }
    }
    
    public func getData() -> [ String : Any ]
    {
        return self.fieldNameVsValue
    }
    
    public func create( completion : @escaping( Result.DataResponse< ZCRMUser, APIResponse > ) -> () )
    {
        UserAPIHandler().addUser( user : self ) { ( result ) in
            completion( result )
        }
    }
    
    public func update( completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        UserAPIHandler().updateUser( user : self ) { ( result ) in
            completion( result )
        }
    }
    
    public func uploadProfilePhotoWithPath( filePath : String, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        UserAPIHandler(user: self).uploadPhotoWithPath(photoViewPermission: XPhotoViewPermission.zero, filePath: filePath) { ( result ) in
            completion( result )
        }
    }
    
    public func uploadProfilePhotoWithData( fileName : String, data : Data, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        UserAPIHandler(user: self).uploadPhotoWithData( photoViewPermission: XPhotoViewPermission.zero, fileName: fileName, data : data ) { ( result ) in
            completion( result )
        }
    }
    
    public func uploadProfilePhotoWithPath( photoViewPermission : XPhotoViewPermission, filePath : String, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        UserAPIHandler(user: self).uploadPhotoWithPath(photoViewPermission: photoViewPermission, filePath: filePath) { ( result ) in
            completion( result )
        }
    }
    
    public func uploadProfilePhotoWithData( photoViewPermission : XPhotoViewPermission, fileName : String, data : Data, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        UserAPIHandler(user: self).uploadPhotoWithData( photoViewPermission: photoViewPermission, fileName: fileName, data : data ) { ( result ) in
            completion( result )
        }
    }
}

