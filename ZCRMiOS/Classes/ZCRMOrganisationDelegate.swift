//
//  ZCRMOrganisationDelegate.swift
//  Pods-ZCRMiOS_Tests
//
//  Created by Boopathy P on 18/09/18.
//

open class ZCRMOrganisationDelegate : ZCRMEntity
{
    func createNewUser( lastName : String, email : String, role : ZCRMRoleDelegate, profile : ZCRMProfileDelegate ) -> ZCRMUser
    {
        return ZCRMUser( lastName : lastName, emailId : email, role : role, profile : profile )
    }
    
    public func getAllUsers( completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllUsers( modifiedSince : nil, page : 1, perPage : 200 ) { ( result ) in
            completion( result )
        }
    }
    
    public func getAllUsers( modifiedSince : String, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllUsers( modifiedSince : modifiedSince, page : 1, perPage : 200 ) { ( result ) in
            completion( result )
        }
    }
    
    public func getAllActiveConfirmedUsers( completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllActiveConfirmedUsers( page : 1, perPage : 200 ) { ( result ) in
            completion( result )
        }
    }
    
    public func getAllActiveConfirmedUsers( page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllActiveConfirmedAdmins( page : page, perPage : perPage ) { ( result ) in
            completion( result )
        }
    }
    
    public func getAllAdminUsers( completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllAdminUsers( page : 1, perPage : 200 ) { ( result ) in
            completion( result )
        }
    }
    
    public func getAllAdminUsers( page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllAdminUsers( page : page, perPage : perPage ) { ( result ) in
            completion( result )
        }
    }
    
    public func getAllActiveUsers( completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllActiveUsers( page : 1, perPage : 200 ) { ( result ) in
            completion( result )
        }
    }
    
    public func getAllActiveUsers( page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllActiveUsers( page : page, perPage : perPage ) { ( result ) in
            completion( result )
        }
    }
    
    public func getAllInActiveUsers( completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllDeactiveUsers( page : 1, perPage : 200 ) { ( result ) in
            completion( result )
        }
    }
    
    public func getAllInActiveUsers( page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllDeactiveUsers( page : page, perPage : perPage ) { ( result ) in
            completion( result )
        }
    }
    
    public func getUser(userId : Int64, completion : @escaping( Result.DataResponse< ZCRMUser, APIResponse > ) -> () )
    {
        UserAPIHandler().getUser(userId: userId) { ( result ) in
            completion( result )
        }
    }
    
    public func getAllProfiles( completion : @escaping( Result.DataResponse< [ ZCRMProfile ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllProfiles() { ( result ) in
            completion( result )
        }
    }
    
    public func getProfile( profileId : Int64, completion : @escaping( Result.DataResponse< ZCRMProfile, APIResponse > ) -> () )
    {
        UserAPIHandler().getProfile( profileId : profileId ) { ( result ) in
            completion( result )
        }
    }
    
    public func getAllRoles( completion : @escaping( Result.DataResponse< [ ZCRMRole ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllRoles() { ( result ) in
            completion( result )
        }
    }
    
    public func getRole( roleId : Int64, completion : @escaping( Result.DataResponse< ZCRMRole, APIResponse > ) -> () )
    {
        UserAPIHandler().getRole( roleId : roleId ) { ( result ) in
            completion( result )
        }
    }
    
    public func searchUsers( withCriteria : String, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().searchUsers( criteria : withCriteria, page : 1, perPage : 200) { ( result ) in
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
