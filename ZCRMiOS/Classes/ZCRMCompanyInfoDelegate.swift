//
//  ZCRMCompanyInfoDelegate.swift
//  ZCRMiOS
//
//  Created by gowtham-pt2177 on 08/10/20.
//

open class ZCRMCompanyInfoDelegate : ZCRMEntity
{
    internal init() {}
    
    public func newUser( lastName : String, email : String, role : ZCRMRoleDelegate, profile : ZCRMProfileDelegate ) -> ZCRMUser
    {
        let user = ZCRMUser(emailId: email, role: role, profile: profile)
        user.lastName = lastName
        return user
    }
    
    public func getUserDelegate( id : Int64, name : String ) -> ZCRMUserDelegate
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
    
    public func getTaxDelegate( displayName : String ) -> ZCRMTaxDelegate
    {
        return ZCRMTaxDelegate(displayName: displayName)
    }
    
    public func getUsers( ofType : UserTypes, completion : @escaping ( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getUsers(ofType: ofType, ZCRMQuery.getRequestParams) { result in
            completion( result )
        }
    }
    
    public func getUsers( completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getUsers(ofType: .allUsers, ZCRMQuery.getRequestParams) { result in
            completion( result )
        }
    }
    
    public func getUsers( withParams : GETRequestParams, completion : @escaping ( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> Void)
    {
        UserAPIHandler().getUsers( ofType : .allUsers, withParams) { result in
            completion( result )
        }
    }
    
    public func getUsers( ofType : UserTypes, withParams : GETRequestParams, completion : @escaping ( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> Void)
    {
        UserAPIHandler().getUsers( ofType : ofType, withParams) { result in
            completion( result )
        }
    }
    
    public func uploadPhoto( filePath : String, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        OrgAPIHandler().uploadPhoto(filePath: filePath, fileName: nil, fileData: nil) { response in
            completion( response )
        }
    }
    
    public func uploadPhoto( fileName : String, fileData : Data, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        OrgAPIHandler().uploadPhoto(filePath: nil, fileName: fileName, fileData: fileData) { response in
            completion( response )
        }
    }
    
    public func downloadPhoto( completion : @escaping ( Result.Response< FileAPIResponse > ) -> () )
    {
        OrgAPIHandler().downloadPhoto( withOrgID : nil ) { result in
            completion( result )
        }
    }
    
    public func downloadPhoto( withOrgID id : Int64, completion : @escaping ( Result.Response< FileAPIResponse > ) -> () )
    {
        OrgAPIHandler().downloadPhoto( withOrgID : id ) { result in
            completion( result )
        }
    }
    
    public func getUser( id : Int64, completion : @escaping( Result.DataResponse< ZCRMUser, APIResponse > ) -> () )
    {
        UserAPIHandler().getUser( userId : id ) { ( result ) in
            completion( result )
        }
    }
    
    public func getProfiles( completion : @escaping( Result.DataResponse< [ ZCRMProfile ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllProfiles() { ( result ) in
            completion( result )
        }
    }
    
    public func getProfile( id : Int64, completion : @escaping( Result.DataResponse< ZCRMProfile, APIResponse > ) -> () )
    {
        UserAPIHandler().getProfile( profileId : id ) { ( result ) in
            completion( result )
        }
    }
    
    public func getRoles( completion : @escaping( Result.DataResponse< [ ZCRMRole ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllRoles() { ( result ) in
            completion( result )
        }
    }
    
    public func getRole( id : Int64, completion : @escaping( Result.DataResponse< ZCRMRole, APIResponse > ) -> () )
    {
        UserAPIHandler().getRole( roleId : id ) { ( result ) in
            completion( result )
        }
    }
    
    public func searchUsers( withCriteria : ZCRMQuery.ZCRMCriteria, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
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
    
    public func searchUsers(ofType : UserTypes, withCriteria : ZCRMQuery.ZCRMCriteria, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
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
    
    public func searchUsers( withCriteria : ZCRMQuery.ZCRMCriteria, page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
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
    
    public func searchUsers(ofType : UserTypes, withCriteria : ZCRMQuery.ZCRMCriteria, page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
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

