//
//  ZCRMUser.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 11/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

public class ZCRMUser : ZCRMUserDelegate
{
    var lastName : String
    var emailId : String
    var role : ZCRMRoleDelegate
    var profile : ZCRMProfileDelegate
    var zuId : Int64 = APIConstants.INT64_MOCK
    
    public var fullName : String = APIConstants.STRING_MOCK
    public var firstName : String = APIConstants.STRING_MOCK
    public var alias : String = APIConstants.STRING_MOCK
    public var dateOfBirth : String = APIConstants.STRING_MOCK
    
    public var mobile : String = APIConstants.STRING_MOCK
    public var phone : String = APIConstants.STRING_MOCK
    public var fax : String = APIConstants.STRING_MOCK
    
    public var language : String = APIConstants.STRING_MOCK
    public var street : String = APIConstants.STRING_MOCK
    public var city : String = APIConstants.STRING_MOCK
    public var state : String = APIConstants.STRING_MOCK
    public var zip : Int64 = APIConstants.INT64_MOCK
    public var country : String = APIConstants.STRING_MOCK
    public var locale : String = APIConstants.STRING_MOCK
    public var countryLocale : String = APIConstants.STRING_MOCK
    
    public var nameFormat : String = APIConstants.STRING_MOCK
    public var dateFormat : String = APIConstants.STRING_MOCK
    public var timeFormat : String = APIConstants.STRING_MOCK
    
    public var timeZone : String = APIConstants.STRING_MOCK
    public var website : String = APIConstants.STRING_MOCK
    public var confirm : Bool = APIConstants.BOOL_MOCK
    public var status : String = APIConstants.STRING_MOCK
    
    public var createdBy : ZCRMUserDelegate = USER_MOCK
    public var createdTime : String = APIConstants.STRING_MOCK
    public var modifiedBy : ZCRMUserDelegate = USER_MOCK
    public var modifiedTime : String = APIConstants.STRING_MOCK
    public var reportingTo : ZCRMUserDelegate = USER_MOCK
    
    public var fieldNameVsValue : [ String : Any ] = [ String : Any ]()
    
    init( lastName : String, emailId : String, role : ZCRMRoleDelegate, profile : ZCRMProfileDelegate )
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

