//
//  ZCRMOrgEmail.swift
//  ZCRMiOS
//
//  Created by Umashri R on 05/10/18.
//

internal class ZCRMOrgEmail : ZCRMEntity
{
    public var isConfirmed : Bool = APIConstants.BOOL_MOCK
    public var accessibleProfiles : [ZCRMProfileDelegate] = [ZCRMProfileDelegate]()
    public internal( set ) var id : Int64 = APIConstants.INT64_MOCK
    public var name : String = APIConstants.STRING_MOCK
    public var email : String = APIConstants.STRING_MOCK
    public var isCreate : Bool = APIConstants.BOOL_MOCK
    
    internal init( name : String, email : String, accessibleProfiles : [ZCRMProfileDelegate] )
    {
        self.name = name
        self.email = email
        self.accessibleProfiles = accessibleProfiles
    }
    
    internal init( id : Int64 )
    {
        self.id = id
    }
    
    public func addAccessibleProfile( profile : ZCRMProfileDelegate )
    {
        accessibleProfiles.append(profile)
    }
    
    public func create( completion : @escaping( Result.DataResponse< ZCRMOrgEmail, APIResponse > ) -> () )
    {
        EmailAPIHandler(orgEmail: self).createOrgEmail { ( result ) in
            self.isCreate = false
            completion( result )
        }
    }
    
    public func confirmation( withCode : String, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        EmailAPIHandler(orgEmail: self).confirmation(withCode: withCode) { ( result ) in
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

extension ZCRMOrgEmail : Equatable
{
    public static func == (lhs: ZCRMOrgEmail, rhs: ZCRMOrgEmail) -> Bool {
        let equals : Bool = lhs.isConfirmed == rhs.isConfirmed  &&
            lhs.accessibleProfiles == rhs.accessibleProfiles &&
            lhs.id == rhs.id &&
            lhs.email == rhs.email &&
            lhs.name == rhs.name
        return equals
    }
}
