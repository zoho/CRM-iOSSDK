//
//  ZCRMUserDelegate.swift
//  ZCRMiOS
//
//  Created by Boopathy P on 16/09/18.
//

open class ZCRMUserDelegate : ZCRMEntity
{
    var id : Int64
    var name : String
    
    init( id : Int64, name : String )
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
    
    public func downloadProfilePhoto( completion : @escaping( Result.Response< FileAPIResponse > ) -> () )
    {
        UserAPIHandler().downloadPhoto( size : PhotoSize.ORIGINAL ) { ( result ) in
            completion( result )
        }
    }
    
    public func downloadProfilePhoto( size : PhotoSize, completion : @escaping( Result.Response< FileAPIResponse > ) -> () )
    {
        UserAPIHandler().downloadPhoto( size : size ) { ( result ) in
            completion( result )
        }
    }
}

let USER_MOCK : ZCRMUserDelegate = ZCRMUserDelegate( id : APIConstants.INT64_MOCK, name : APIConstants.STRING_MOCK )


