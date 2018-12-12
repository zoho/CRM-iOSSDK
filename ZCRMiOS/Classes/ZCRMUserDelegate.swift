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
    
    internal init( id : Int64, name : String )
    {
        self.id = id
        self.name = name
    }
    
    public func update( userDetails : [String:Any], completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        UserAPIHandler(userDelegate: self).updateUser(userDetails: userDetails) { ( result ) in
            completion( result )
        }
    }
    
    public func delete( completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        UserAPIHandler().deleteUser( userId : self.id ) { ( result ) in
            completion( result )
        }
    }
    
    public func uploadProfilePhoto( filePath : String, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        UserAPIHandler(userDelegate: self).uploadPhotoWithPath(filePath: filePath) { ( result ) in
            completion( result )
        }
    }
    
    public func uploadProfilePhoto( fileName : String, fileContent : Data, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        UserAPIHandler(userDelegate: self).uploadPhotoWithData( fileName: fileName, data : fileContent ) { ( result ) in
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
