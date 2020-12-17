//
//  ZCRMOrgDelegate.swift
//  Pods-ZCRMiOS_Tests
//
//  Created by Boopathy P on 18/09/18.
//

open class ZCRMOrgDelegate : ZCRMEntity
{
    internal init() {}
    
    public func newUser( lastName : String, email : String, role : ZCRMRoleDelegate, profile : ZCRMProfileDelegate ) -> ZCRMUser
    {
        let user = ZCRMUser(emailId: email, role: role, profile: profile)
        user.lastName = lastName
        return user
    }
    
    public func getUserDelegate( id : String, name : String ) -> ZCRMUserDelegate
    {
        return ZCRMUserDelegate(id: id, name: name)
    }
    
    public func getProfileDelegate( id : Int64, name : String ) -> ZCRMProfileDelegate
    {
        return ZCRMProfileDelegate( id : id, name : name )
    }
    
    public func getProfileDelegate( id : Int64, name : String, isDefault : Bool ) -> ZCRMProfileDelegate
    {
        return ZCRMProfileDelegate( id : id, name : name, isDefault : isDefault )
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
    
    public func getUsers( ofType : UserTypes, completion : @escaping ( ResultType.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getUsers(ofType: ofType, ZCRMQuery.getRequestParams) { result in
            completion( result )
        }
    }
    
    @available(*, deprecated, message: "Use getUsers( ofType :, withParams : GETRequestParams, completion :) method instead")
    public func getUsers( ofType : UserTypes, page : Int, perPage : Int, completion : @escaping( ResultType.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getUsers(ofType: ofType, modifiedSince: nil, page: page, perPage: perPage) { result in
            completion( result )
        }
    }
    
    public func getUsers( completion : @escaping( ResultType.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getUsers(ofType: .allUsers, ZCRMQuery.getRequestParams) { result in
            completion( result )
        }
    }
    
    public func getUsers( withParams : GETRequestParams, completion : @escaping ( ResultType.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> Void)
    {
        UserAPIHandler().getUsers( ofType : .allUsers, withParams) { result in
            completion( result )
        }
    }
    
    public func getUsers( ofType : UserTypes, withParams : GETRequestParams, completion : @escaping ( ResultType.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> Void)
    {
        UserAPIHandler().getUsers( ofType : ofType, withParams) { result in
            completion( result )
        }
    }
    
    @available(*, deprecated, message: "Use getUsers( withParams : GETRequestParams, completion :) method instead")
    public func getUsers( modifiedSince : String, completion : @escaping( ResultType.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getUsers( ofType: .allUsers, modifiedSince: modifiedSince, page: nil, perPage: nil) { result in
            completion( result )
        }
    }
    
    @available(*, deprecated, message: "Use getUsers( withParams : GETRequestParams, completion :) method instead")
    public func getUsers( page : Int, perPage : Int, completion : @escaping( ResultType.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getUsers( ofType : .allUsers, modifiedSince : nil, page : page, perPage : perPage ) { ( result ) in
            completion( result )
        }
    }
    
    @available(*, deprecated, message: "Use getUsers(  withParams : GETRequestParams, completion :) method instead")
    public func getUsers( page : Int, perPage : Int, modifiedSince : String, completion : @escaping( ResultType.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getUsers( ofType : .allUsers, modifiedSince : modifiedSince, page : page, perPage : perPage ) { ( result ) in
            completion( result )
        }
    }
    
    public func uploadPhoto( filePath : String, completion : @escaping( ResultType.Response< APIResponse > ) -> () )
    {
        OrgAPIHandler().uploadPhoto(filePath: filePath, fileName: nil, fileData: nil) { response in
            completion( response )
        }
    }
    
    public func uploadPhoto( fileName : String, fileData : Data, completion : @escaping( ResultType.Response< APIResponse > ) -> () )
    {
        OrgAPIHandler().uploadPhoto(filePath: nil, fileName: fileName, fileData: fileData) { response in
            completion( response )
        }
    }
    
    public func downloadPhoto( completion : @escaping ( ResultType.Response< FileAPIResponse > ) -> () )
    {
        OrgAPIHandler().downloadPhoto( withOrgID : nil ) { result in
            completion( result )
        }
    }
    
    public func downloadPhoto( withOrgID id : Int64, completion : @escaping ( ResultType.Response< FileAPIResponse > ) -> () )
    {
        OrgAPIHandler().downloadPhoto( withOrgID : id ) { result in
            completion( result )
        }
    }
    
    @available(*, deprecated, message: "Use getUsers( ofType :, completion :) method instead")
    public func getActiveConfirmedUsers( completion : @escaping( ResultType.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllActiveConfirmedUsers( page : nil, perPage : nil ) { ( result ) in
            completion( result )
        }
    }
    
    @available(*, deprecated, message: "Use getUsers( ofType :, withParams : GETRequestParams, completion :) method instead")
    public func getActiveConfirmedUsers( page : Int, perPage : Int, completion : @escaping( ResultType.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllActiveConfirmedAdmins( page : page, perPage : perPage ) { ( result ) in
            completion( result )
        }
    }
    
    @available(*, deprecated, message: "Use getUsers( ofType :, completion :) method instead")
    public func getAdminUsers( completion : @escaping( ResultType.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllAdminUsers( page : nil, perPage : nil ) { ( result ) in
            completion( result )
        }
    }
    
    @available(*, deprecated, message: "Use getUsers( ofType :, withParams : GETRequestParams, completion :) method instead")
    public func getAdminUsers( page : Int, perPage : Int, completion : @escaping( ResultType.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllAdminUsers( page : page, perPage : perPage ) { ( result ) in
            completion( result )
        }
    }
    
    @available(*, deprecated, message: "Use getUsers( ofType :, completion :) method instead")
    public func getActiveUsers( completion : @escaping( ResultType.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllActiveUsers( page : nil, perPage : nil ) { ( result ) in
            completion( result )
        }
    }
    
    @available(*, deprecated, message: "Use getUsers( ofType :, withParams : GETRequestParams, completion :) method instead")
    public func getActiveUsers( page : Int, perPage : Int, completion : @escaping( ResultType.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllActiveUsers( page : page, perPage : perPage ) { ( result ) in
            completion( result )
        }
    }
    
    @available(*, deprecated, message: "Use getUsers( ofType :, completion :) method instead")
    public func getInActiveUsers( completion : @escaping( ResultType.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllDeactiveUsers( page : nil, perPage : nil ) { ( result ) in
            completion( result )
        }
    }
    
    @available(*, deprecated, message: "Use getUsers( ofType :, withParams : GETRequestParams, completion :) method instead")
    public func getInActiveUsers( page : Int, perPage : Int, completion : @escaping( ResultType.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllDeactiveUsers( page : page, perPage : perPage ) { ( result ) in
            completion( result )
        }
    }
    
    public func getUser( id : String, completion : @escaping( ResultType.DataResponse< ZCRMUser, APIResponse > ) -> () )
    {
        UserAPIHandler().getUser( userId : id ) { ( result ) in
            completion( result )
        }
    }
    
    public func getProfiles( completion : @escaping( ResultType.DataResponse< [ ZCRMProfile ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllProfiles() { ( result ) in
            completion( result )
        }
    }
    
    public func getProfile( id : Int64, completion : @escaping( ResultType.DataResponse< ZCRMProfile, APIResponse > ) -> () )
    {
        UserAPIHandler().getProfile( profileId : id ) { ( result ) in
            completion( result )
        }
    }
    
    public func getRoles( completion : @escaping( ResultType.DataResponse< [ ZCRMRole ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllRoles() { ( result ) in
            completion( result )
        }
    }
    
    public func getRole( id : Int64, completion : @escaping( ResultType.DataResponse< ZCRMRole, APIResponse > ) -> () )
    {
        UserAPIHandler().getRole( roleId : id ) { ( result ) in
            completion( result )
        }
    }
    
    @available(*, deprecated, message: "Use the method searchUsers -> withCriteria of type ZCRMQuery.ZCRMCriteria" )
    public func searchUsers( withCriteria : String, completion : @escaping( ResultType.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().searchUsers( ofType: nil, criteria : withCriteria, page : nil, perPage : nil ) { ( result ) in
            completion( result )
        }
    }
    
    public func searchUsers( withCriteria : ZCRMQuery.ZCRMCriteria, completion : @escaping( ResultType.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        guard let recordQuery = withCriteria.recordQuery else {
            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( ErrorCode.internalError) : Criteria cannot be constructed" )
            completion( .failure( ZCRMError.processingError( code : ErrorCode.internalError, message : "Criteria cannot be constructed", details : nil ) ) )
            return
        }
        UserAPIHandler().searchUsers( ofType : nil, criteria : recordQuery, page : nil, perPage : nil ) { ( result ) in
            completion( result )
        }
    }
    
    public func searchUsers(ofType : UserTypes, withCriteria : ZCRMQuery.ZCRMCriteria, completion : @escaping( ResultType.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        guard let recordQuery = withCriteria.recordQuery else {
            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( ErrorCode.internalError) : Criteria cannot be constructed" )
            completion( .failure( ZCRMError.processingError( code : ErrorCode.internalError, message : "Criteria cannot be constructed", details : nil ) ) )
            return
        }
        UserAPIHandler().searchUsers(ofType : ofType, criteria : recordQuery, page : nil, perPage: nil) { ( result ) in
            completion( result )
        }
    }
    
    @available(*, deprecated, message: "Use the method searchUsers -> withCriteria of type ZCRMQuery.ZCRMCriteria, page : Int, perPage : Int" )
    public func searchUsers( withCriteria : String, page : Int, perPage : Int, completion : @escaping( ResultType.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().searchUsers( ofType: nil, criteria : withCriteria, page : page, perPage : perPage) { ( result ) in
            completion( result )
        }
    }
    
    public func searchUsers( withCriteria : ZCRMQuery.ZCRMCriteria, page : Int, perPage : Int, completion : @escaping( ResultType.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        guard let recordQuery = withCriteria.recordQuery else {
            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( ErrorCode.internalError) : Criteria cannot be constructed" )
            completion( .failure( ZCRMError.processingError( code : ErrorCode.internalError, message : "Criteria cannot be constructed", details : nil ) ) )
            return
        }
        UserAPIHandler().searchUsers( ofType : nil, criteria : recordQuery, page : page, perPage : perPage) { ( result ) in
            completion( result )
        }
    }
    
    public func searchUsers(ofType : UserTypes, withCriteria : ZCRMQuery.ZCRMCriteria, page : Int, perPage : Int, completion : @escaping( ResultType.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        guard let recordQuery = withCriteria.recordQuery else {
            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( ErrorCode.internalError) : Criteria cannot be constructed" )
            completion( .failure( ZCRMError.processingError( code : ErrorCode.internalError, message : "Criteria cannot be constructed", details : nil ) ) )
            return
        }
        UserAPIHandler().searchUsers(ofType : ofType, criteria : recordQuery, page : page, perPage : perPage) { ( result ) in
            completion( result )
        }
    }
}
