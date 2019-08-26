//
//  ZCRMOrgDelegate.swift
//  Pods-ZCRMiOS_Tests
//
//  Created by Boopathy P on 18/09/18.
//

open class ZCRMOrgDelegate : ZCRMEntity
{
    public static let shared = ZCRMOrgDelegate()
    
    internal init() {}
    
    @available(*, deprecated, message: "Use the method 'newUser'" )
    public func createNewUser( lastName : String, email : String, role : ZCRMRoleDelegate, profile : ZCRMProfileDelegate ) -> ZCRMUser
    {
        return ZCRMUser( lastName : lastName, emailId : email, role : role, profile : profile )
    }
    
    public func newUser( lastName : String, email : String, role : ZCRMRoleDelegate, profile : ZCRMProfileDelegate ) -> ZCRMUser
    {
        return ZCRMUser( lastName : lastName, emailId : email, role : role, profile : profile )
    }
    
    public func getUserDelegate( id : Int64, name : String ) -> ZCRMUserDelegate
    {
        return ZCRMUserDelegate(id: id, name: name)
    }
    
    @available(*, deprecated, message: "Use the method 'getProfileDelegate' with params id and name" )
    public func getProfileDelegate(profileId: Int64, profileName: String) -> ZCRMProfileDelegate
    {
        return ZCRMProfileDelegate( id : profileId, name : profileName )
    }
    
    public func getProfileDelegate( id : Int64, name : String ) -> ZCRMProfileDelegate
    {
        return ZCRMProfileDelegate( id : id, name : name )
    }
    
    @available(*, deprecated, message: "Use the method 'getProfileDelegate' with params id and name" )
    public func getProfileDelegate(profileId: Int64, profileName: String, isDefault: Bool) -> ZCRMProfileDelegate
    {
        return ZCRMProfileDelegate( id : profileId, name : profileName, isDefault : isDefault )
    }
    
    public func getProfileDelegate( id : Int64, name : String, isDefault : Bool ) -> ZCRMProfileDelegate
    {
        return ZCRMProfileDelegate( id : id, name : name, isDefault : isDefault )
    }
    
    @available(*, deprecated, message: "Use the method 'getRoleDelegate' with params id and name" )
    public func getRoleDelegate(roleId: Int64, roleName: String) -> ZCRMRoleDelegate
    {
        return ZCRMRoleDelegate( id : roleId, name : roleName )
    }
    
    public func getRoleDelegate( id : Int64, name : String ) -> ZCRMRoleDelegate
    {
        return ZCRMRoleDelegate( id : id, name : name )
    }
    
    public func newTax( name : String, percentage : Double ) -> ZCRMTax
    {
        return ZCRMTax( name : name, percentage : percentage )
    }
    
    public func getTaxDelegate( name : String ) -> ZCRMTaxDelegate
    {
        return ZCRMTaxDelegate(name: name)
    }
    
    @available(*, deprecated, message: "Use the method 'getUsers'" )
    public func getAllUsers( completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllUsers( modifiedSince : nil, page : nil, perPage : nil ) { ( result ) in
            completion( result )
        }
    }
    
    public func getUsers( completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllUsers( modifiedSince : nil, page : nil, perPage : nil ) { ( result ) in
            completion( result )
        }
    }
    
    @available(*, deprecated, message: "Use the method 'getUsers'" )
    public func getAllUsers( modifiedSince : String, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllUsers( modifiedSince : modifiedSince, page : nil, perPage : nil ) { ( result ) in
            completion( result )
        }
    }
    
    public func getUsers( modifiedSince : String, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllUsers( modifiedSince : modifiedSince, page : nil, perPage : nil ) { ( result ) in
            completion( result )
        }
    }
    
    @available(*, deprecated, message: "Use the method 'getUsers'" )
    public func getAllUsers( page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllUsers( modifiedSince : nil, page : page, perPage : perPage ) { ( result ) in
            completion( result )
        }
    }
    
    public func getUsers( page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllUsers( modifiedSince : nil, page : page, perPage : perPage ) { ( result ) in
            completion( result )
        }
    }
    
    @available(*, deprecated, message: "Use the method 'getUsers'" )
    public func getAllUsers( page : Int, perPage : Int, modifiedSince : String, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllUsers( modifiedSince : modifiedSince, page : page, perPage : perPage ) { ( result ) in
            completion( result )
        }
    }
    
    public func getUsers( page : Int, perPage : Int, modifiedSince : String, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllUsers( modifiedSince : modifiedSince, page : page, perPage : perPage ) { ( result ) in
            completion( result )
        }
    }
    
    @available(*, deprecated, message: "Use the method 'getActiveConfirmedUsers'" )
    public func getAllActiveConfirmedUsers( completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllActiveConfirmedUsers( page : nil, perPage : nil ) { ( result ) in
            completion( result )
        }
    }
    
    public func getActiveConfirmedUsers( completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllActiveConfirmedUsers( page : nil, perPage : nil ) { ( result ) in
            completion( result )
        }
    }
    
    @available(*, deprecated, message: "Use the method 'getActiveConfirmedUsers'" )
    public func getAllActiveConfirmedUsers( page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllActiveConfirmedAdmins( page : page, perPage : perPage ) { ( result ) in
            completion( result )
        }
    }
    
    public func getActiveConfirmedUsers( page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllActiveConfirmedAdmins( page : page, perPage : perPage ) { ( result ) in
            completion( result )
        }
    }
    
    @available(*, deprecated, message: "Use the method 'getAdminUsers'" )
    public func getAllAdminUsers( completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllAdminUsers( page : nil, perPage : nil ) { ( result ) in
            completion( result )
        }
    }
    
    public func getAdminUsers( completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllAdminUsers( page : nil, perPage : nil ) { ( result ) in
            completion( result )
        }
    }
    
    @available(*, deprecated, message: "Use the method 'getAdminUsers'" )
    public func getAllAdminUsers( page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllAdminUsers( page : page, perPage : perPage ) { ( result ) in
            completion( result )
        }
    }
    
    public func getAdminUsers( page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllAdminUsers( page : page, perPage : perPage ) { ( result ) in
            completion( result )
        }
    }
    
    @available(*, deprecated, message: "Use the method 'getActiveUsers'" )
    public func getAllActiveUsers( completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllActiveUsers( page : nil, perPage : nil ) { ( result ) in
            completion( result )
        }
    }
    
    public func getActiveUsers( completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllActiveUsers( page : nil, perPage : nil ) { ( result ) in
            completion( result )
        }
    }
    
    @available(*, deprecated, message: "Use the method 'getActiveUsers'" )
    public func getAllActiveUsers( page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllActiveUsers( page : page, perPage : perPage ) { ( result ) in
            completion( result )
        }
    }
    
    public func getActiveUsers( page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllActiveUsers( page : page, perPage : perPage ) { ( result ) in
            completion( result )
        }
    }
    
    @available(*, deprecated, message: "Use the method 'getInActiveUsers'" )
    public func getAllInActiveUsers( completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllDeactiveUsers( page : nil, perPage : nil ) { ( result ) in
            completion( result )
        }
    }
    
    public func getInActiveUsers( completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllDeactiveUsers( page : nil, perPage : nil ) { ( result ) in
            completion( result )
        }
    }
    
    @available(*, deprecated, message: "Use the method 'getInActiveUsers'" )
    public func getAllInActiveUsers( page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllDeactiveUsers( page : page, perPage : perPage ) { ( result ) in
            completion( result )
        }
    }
    
    public func getInActiveUsers( page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllDeactiveUsers( page : page, perPage : perPage ) { ( result ) in
            completion( result )
        }
    }
    
    @available(*, deprecated, message: "Use the method 'getUser' with params id" )
    public func getUser(userId : Int64, completion : @escaping( Result.DataResponse< ZCRMUser, APIResponse > ) -> () )
    {
        UserAPIHandler().getUser(userId: userId) { ( result ) in
            completion( result )
        }
    }
    
    public func getUser( id : Int64, completion : @escaping( Result.DataResponse< ZCRMUser, APIResponse > ) -> () )
    {
        UserAPIHandler().getUser( userId : id ) { ( result ) in
            completion( result )
        }
    }
    
    @available(*, deprecated, message: "Use the method 'getProfiles'" )
    public func getAllProfiles( completion : @escaping( Result.DataResponse< [ ZCRMProfile ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllProfiles() { ( result ) in
            completion( result )
        }
    }
    
    public func getProfiles( completion : @escaping( Result.DataResponse< [ ZCRMProfile ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllProfiles() { ( result ) in
            completion( result )
        }
    }
    
    @available(*, deprecated, message: "Use the method 'getProfile' with params id" )
    public func getProfile( profileId : Int64, completion : @escaping( Result.DataResponse< ZCRMProfile, APIResponse > ) -> () )
    {
        UserAPIHandler().getProfile( profileId : profileId ) { ( result ) in
            completion( result )
        }
    }
    
    public func getProfile( id : Int64, completion : @escaping( Result.DataResponse< ZCRMProfile, APIResponse > ) -> () )
    {
        UserAPIHandler().getProfile( profileId : id ) { ( result ) in
            completion( result )
        }
    }
    
    @available(*, deprecated, message: "Use the method 'getRoles'" )
    public func getAllRoles( completion : @escaping( Result.DataResponse< [ ZCRMRole ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllRoles() { ( result ) in
            completion( result )
        }
    }
    
    public func getRoles( completion : @escaping( Result.DataResponse< [ ZCRMRole ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllRoles() { ( result ) in
            completion( result )
        }
    }
    
    @available(*, deprecated, message: "Use the method 'getRole' with params id" )
    public func getRole( roleId : Int64, completion : @escaping( Result.DataResponse< ZCRMRole, APIResponse > ) -> () )
    {
        UserAPIHandler().getRole( roleId : roleId ) { ( result ) in
            completion( result )
        }
    }
    
    public func getRole( id : Int64, completion : @escaping( Result.DataResponse< ZCRMRole, APIResponse > ) -> () )
    {
        UserAPIHandler().getRole( roleId : id ) { ( result ) in
            completion( result )
        }
    }
    
    public func searchUsers( withCriteria : String, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().searchUsers( criteria : withCriteria, page : nil, perPage : nil ) { ( result ) in
            completion( result )
        }
    }
    
    public func searchUsers( withCriteria : String, page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().searchUsers( criteria : withCriteria, page : page, perPage : perPage) { ( result ) in
            completion( result )
        }
    }
}
