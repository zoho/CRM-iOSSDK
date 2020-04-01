//
//  ZCRMUserDelegate.swift
//  ZCRMiOS
//
//  Created by Boopathy P on 16/09/18.
//

open class ZCRMUserDelegate : ZCRMEntity
{
    public internal( set ) var id : Int64
    public var name : String
    
    internal init( id : Int64, name : String )
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
    
    public func uploadProfilePhoto( filePath : String, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        UserAPIHandler( userDelegate : self ).uploadPhoto(filePath: filePath, fileName: nil, fileData: nil) { ( result ) in
            completion( result )
        }
    }
    
    public func uploadProfilePhoto( fileRefId : String, filePath : String, fileUploadDelegate : ZCRMFileUploadDelegate )
    {
        UserAPIHandler( userDelegate : self ).uploadPhoto(fileRefId : fileRefId, filePath: filePath, fileName: nil, fileData: nil, fileUploadDelegate: fileUploadDelegate)
    }
    
    public func uploadProfilePhoto( fileName : String, fileData : Data, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        UserAPIHandler( userDelegate : self ).uploadPhoto(filePath: nil, fileName: fileName, fileData: fileData) { ( result ) in
            completion( result )
        }
    }
    
    public func uploadProfilePhoto( fileRefId : String, fileName : String, fileData : Data, fileUploadDelegate : ZCRMFileUploadDelegate )
    {
        UserAPIHandler( userDelegate : self ).uploadPhoto( fileRefId : fileRefId, filePath : nil, fileName : fileName, fileData : fileData, fileUploadDelegate : fileUploadDelegate )
    }
    
    public func downloadProfilePhoto( completion : @escaping( Result.Response< FileAPIResponse > ) -> () )
    {
        UserAPIHandler(userDelegate: self).downloadPhoto( size : nil ) { ( result ) in
            completion( result )
        }
    }
    
    public func downloadProfilePhoto( fileDownloadDelegate : ZCRMFileDownloadDelegate ) throws
    {
        try UserAPIHandler(userDelegate: self).downloadPhoto(size: nil, fileDownloadDelegate: fileDownloadDelegate)
    }
    
    public func downloadProfilePhoto( size : PhotoSize, completion : @escaping( Result.Response< FileAPIResponse > ) -> () )
    {
        UserAPIHandler(userDelegate: self).downloadPhoto( size : size ) { ( result ) in
            completion( result )
        }
    }
    
    public func downloadProfilePhoto( size : PhotoSize, fileDownloadDelegate : ZCRMFileDownloadDelegate ) throws
    {
        try UserAPIHandler(userDelegate: self).downloadPhoto(size: size, fileDownloadDelegate: fileDownloadDelegate)
    }
}

extension ZCRMUserDelegate : Equatable
{
    public static func == (lhs: ZCRMUserDelegate, rhs: ZCRMUserDelegate) -> Bool {
        let equals : Bool = lhs.id == rhs.id &&
            lhs.name == rhs.name
        return equals
    }
}

let USER_MOCK : ZCRMUserDelegate = ZCRMUserDelegate( id : APIConstants.INT64_MOCK, name : APIConstants.STRING_MOCK )
