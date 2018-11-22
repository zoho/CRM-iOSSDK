//
//  ZCRMUserDelegate.swift
//  ZCRMiOS
//
//  Created by Boopathy P on 16/09/18.
//

open class ZCRMUserDelegate : ZCRMEntity
{
    public var id : Int64
    public var name : String
    
    public init( id : Int64, name : String )
    {
        self.id = id
        self.name = name
    }
    
    public func delete( completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        UserAPIHandler().deleteUser( userId : self.id ) { ( result ) in
            completion( result )
        }
    }
    
    public func update( userDetails : [ String : Any ], completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        UserAPIHandler(userDelegate: self).updateUser(userDetails: userDetails) { ( result ) in
            completion( result )
        }
    }
    
    public func uploadProfilePhotoWithPath( filePath : String, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        UserAPIHandler(userDelegate: self).uploadPhotoWithPath(photoViewPermission: XPhotoViewPermission.zero, filePath: filePath) { ( result ) in
            completion( result )
        }
    }
    
    public func uploadProfilePhotoWithData( fileName : String, data : Data, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        UserAPIHandler(userDelegate: self).uploadPhotoWithData( photoViewPermission: XPhotoViewPermission.zero, fileName: fileName, data : data ) { ( result ) in
            completion( result )
        }
    }
    
    public func uploadProfilePhotoWithPath( photoViewPermission : XPhotoViewPermission, filePath : String, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        UserAPIHandler(userDelegate: self).uploadPhotoWithPath(photoViewPermission: photoViewPermission, filePath: filePath) { ( result ) in
            completion( result )
        }
    }
    
    public func uploadProfilePhotoWithData( photoViewPermission : XPhotoViewPermission, fileName : String, data : Data, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        UserAPIHandler(userDelegate: self).uploadPhotoWithData( photoViewPermission: photoViewPermission, fileName: fileName, data : data ) { ( result ) in
            completion( result )
        }
    }
    
    public func downloadProfilePhoto( completion : @escaping( Result.Response< FileAPIResponse > ) -> () )
    {
        UserAPIHandler(userDelegate: self).downloadPhoto( size : PhotoSize.ORIGINAL ) { ( result ) in
            completion( result )
        }
    }
    
    public func downloadProfilePhoto( size : PhotoSize, completion : @escaping( Result.Response< FileAPIResponse > ) -> () )
    {
        UserAPIHandler(userDelegate: self).downloadPhoto( size : size ) { ( result ) in
            completion( result )
        }
    }
}

let USER_MOCK : ZCRMUserDelegate = ZCRMUserDelegate( id : APIConstants.INT64_MOCK, name : APIConstants.STRING_MOCK )
