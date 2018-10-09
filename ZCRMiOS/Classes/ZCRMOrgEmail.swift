//
//  ZCRMOrgEmail.swift
//  ZCRMiOS
//
//  Created by Umashri R on 05/10/18.
//

open class ZCRMOrgEmail : ZCRMEntity
{
    var confirm : Bool = APIConstants.BOOL_MOCK
    var profiles : [ZCRMProfileDelegate] = [ZCRMProfileDelegate]()
    var id : Int64 = APIConstants.INT64_MOCK
    var name : String = APIConstants.STRING_MOCK
    var email : String = APIConstants.STRING_MOCK
    
    internal init( name : String, email : String, profiles : [ZCRMProfileDelegate] )
    {
        self.name = name
        self.email = email
        self.profiles = profiles
    }
    
    internal init( id : Int64 )
    {
        self.id = id
    }
    
    public func addProfile( profile : ZCRMProfileDelegate )
    {
        profiles.append(profile)
    }
    
    public func create( completion : @escaping( Result.DataResponse< ZCRMOrgEmail, APIResponse > ) -> () )
    {
        EmailAPIHandler(orgEmail: self).create { ( result ) in
            completion( result )
        }
    }
    
    public func confirm( code : String, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        EmailAPIHandler(orgEmail: self).confirm(code: code) { ( result ) in
            completion( result )
        }
    }
    
    public func resendConfirmationCode( completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        EmailAPIHandler(orgEmail: self).resendConfirmationCode { ( result ) in
            completion( result )
        }
    }
    
    public func delete( completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        EmailAPIHandler(orgEmail: self).delete(id: self.id) { ( result ) in
            completion(result)
        }
    }
}
