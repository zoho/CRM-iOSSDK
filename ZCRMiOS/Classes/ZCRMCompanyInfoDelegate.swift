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
        let tax = ZCRMTax( name : name, percentage : percentage )
        tax.operationType = ZCRMTax.OperationType.create
        return tax
    }
    
    public func getTaxDelegate( displayName : String ) -> ZCRMTaxDelegate
    {
        return ZCRMTaxDelegate(displayName: displayName)
    }
    
    //This method is used to convert ZCRMUserTypes to ZCRMUser.Category and it will be removed when the deprecated me†hods are removed
    
    private func getUserType( _ type : ZCRMUserTypes ) -> ZCRMUser.Category
    {
        switch type
        {
            
        case .allUsers:
            return .allUsers
        case .activeUsers:
            return .activeUsers
        case .deactiveUsers:
            return .deactiveUsers
        case .notConfirmedUsers:
            return .notConfirmedUsers
        case .confirmedUsers:
            return .confirmedUsers
        case .activeConfirmedUsers:
            return .activeConfirmedUsers
        case .deletedUsers:
            return .deletedUsers
        case .adminUsers:
            return .adminUsers
        case .activeConfirmedAdmins:
            return .activeConfirmedAdmins
        }
    }
    
    @available(*, deprecated,message: "use getUsers method with GetUserParams instead")
    public func getUsers( ofType : ZCRMUserTypes, completion : @escaping ( ZCRMResult.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        var userParam: GETUserParams = ZCRMQuery.getUserParams
        userParam.type = getUserType(ofType)
        UserAPIHandler().getUsers(userParam, requestHeaders: nil, completion: completion)
        
    }
    
    @available(*, deprecated,message: "use getUser method with GetUserParams instead")
    public func getUsers( completion : @escaping( ZCRMResult.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        var userParam: GETUserParams = ZCRMQuery.getUserParams
        userParam.type = .allUsers
        UserAPIHandler().getUsers(userParam, requestHeaders: nil, completion: completion)
    }
    
    @available(*, deprecated, message: "use getUser method with GetUserParams instead")
    public func getUsers( withParams : GETRequestParams, completion : @escaping ( ZCRMResult.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> Void)
    {
        var userParam: GETUserParams = ZCRMQuery.getUserParams
        userParam.type = .allUsers
        userParam.modifiedSince = withParams.modifiedSince
        userParam.perPage = withParams.perPage
        userParam.page = withParams.page
        UserAPIHandler().getUsers(userParam, requestHeaders: nil, completion: completion)
    }
    @available(*, deprecated, message: "use getuser method with GetUserParams instead")
    public func getUsers( ofType : ZCRMUserTypes, withParams : GETRequestParams, completion : @escaping ( ZCRMResult.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> Void)
    {
        var userParam: GETUserParams = ZCRMQuery.getUserParams
        userParam.type = getUserType(ofType)
        userParam.modifiedSince = withParams.modifiedSince
        userParam.perPage = withParams.perPage
        userParam.page = withParams.page
        UserAPIHandler().getUsers(userParam, requestHeaders: nil, completion: completion)
    }
    @available(*, deprecated, message: "use getUser method with GetUserParams and requestHeaders instead")
    public func getUsers( withParams : GETRequestParams, requestHeaders : [ String : String ],completion : @escaping ( ZCRMResult.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> Void)
    {
        var userParam: GETUserParams = ZCRMQuery.getUserParams
        userParam.type = .allUsers
        userParam.modifiedSince = withParams.modifiedSince
        userParam.perPage = withParams.perPage
        userParam.page = withParams.page
        UserAPIHandler().getUsers(userParam, requestHeaders: requestHeaders, completion: completion)
    }
    @available(*, deprecated, message: "use getUser method with GetUserParams and requestHeaders instead")
    public func getUsers( ofType : ZCRMUserTypes, withParams : GETRequestParams, requestHeaders : [ String : String ], completion : @escaping ( ZCRMResult.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> Void)
    {
        var userParam: GETUserParams = ZCRMQuery.getUserParams
        userParam.type = getUserType(ofType)
        userParam.modifiedSince = withParams.modifiedSince
        userParam.perPage = withParams.perPage
        userParam.page = withParams.page
        UserAPIHandler().getUsers(userParam, requestHeaders: requestHeaders, completion: completion)
    }
    
    /**
     To get the users according to the userType.
     
     - Parameters:
        - withParams : The params of the user required for the request
        - completion :
          - Success : Returns the response
          - Failure : ZCRMError
     */
    
    public func getUsers(withParams: GETUserParams, completion: @escaping ( ZCRMResult.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> Void)
    {
        UserAPIHandler().getUsers(withParams, requestHeaders: nil, completion: completion)
    }
    
    /**
     To get the users according to the userType and requestHeaders
     
     - Parameters:
          - withParams : The params of the user required for the request
          - requestHeaders : The headers required for making the request
          - completion :
             - Success : Returns the response
             - Failure : ZCRMError
     */
    
    public func getUsers( withParams: GETUserParams, requestHeaders: [String: String], completion : @escaping ( ZCRMResult.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> Void){
        UserAPIHandler().getUsers(withParams, requestHeaders: requestHeaders, completion: completion)
    }
    
    public func uploadPhoto( filePath : String, completion : @escaping( ZCRMResult.Response< APIResponse > ) -> () )
    {
        OrgAPIHandler().uploadPhoto(filePath: filePath, fileName: nil, fileData: nil) { response in
            completion( response )
        }
    }
    
    public func uploadPhoto( fileName : String, fileData : Data, completion : @escaping( ZCRMResult.Response< APIResponse > ) -> () )
    {
        OrgAPIHandler().uploadPhoto(filePath: nil, fileName: fileName, fileData: fileData) { response in
            completion( response )
        }
    }
    
    public func uploadPhoto( fileRefId : String, filePath : String, fileUploadDelegate : ZCRMFileUploadDelegate )
    {
        OrgAPIHandler().uploadPhoto(fileRefId: fileRefId, filePath: filePath, fileName: nil, fileData: nil, fileUploadDelegate: fileUploadDelegate)
    }
    
    public func uploadPhoto( fileRefId : String, fileName : String, fileData : Data, fileUploadDelegate : ZCRMFileUploadDelegate )
    {
        OrgAPIHandler().uploadPhoto(fileRefId: fileRefId, filePath: nil, fileName: fileName, fileData: fileData, fileUploadDelegate: fileUploadDelegate)
    }
    
    public func downloadPhoto( completion : @escaping ( ZCRMResult.Response< FileAPIResponse > ) -> () )
    {
        OrgAPIHandler().downloadPhoto( withOrgID : nil ) { result in
            completion( result )
        }
    }
    
    public func downloadPhoto( withOrgID id : Int64, completion : @escaping ( ZCRMResult.Response< FileAPIResponse > ) -> () )
    {
        OrgAPIHandler().downloadPhoto( withOrgID : id ) { result in
            completion( result )
        }
    }
    
    public func downloadPhoto( fileRefId : String, fileDownloadDelegate : ZCRMFileDownloadDelegate )
    {
        OrgAPIHandler().downloadPhoto(fileRefId: fileRefId, withOrgID: nil, fileDownloadDelegate: fileDownloadDelegate)
    }
    
    public func downloadPhoto( fileRefId : String, withOrgID id : Int64, fileDownloadDelegate : ZCRMFileDownloadDelegate )
    {
        OrgAPIHandler().downloadPhoto(fileRefId: fileRefId, withOrgID: id, fileDownloadDelegate: fileDownloadDelegate)
    }
    
    public func deletePhoto( completion : @escaping( ZCRMResult.Response< APIResponse > ) -> () )
    {
        OrgAPIHandler().deletePhoto( withOrgID: nil ){ response in
            completion( response ) }
    }
    
    public func deletePhoto( withOrgID id : Int64, completion : @escaping( ZCRMResult.Response< APIResponse > ) -> () )
    {
        OrgAPIHandler().deletePhoto( withOrgID: id ){ response in
            completion( response ) }
    }
    
    public func getUser( id : Int64, completion : @escaping( ZCRMResult.DataResponse< ZCRMUser, APIResponse > ) -> () )
    {
        UserAPIHandler().getUser( userId : id ) { ( result ) in
            completion( result )
        }
    }
    
    public func getProfiles( completion : @escaping( ZCRMResult.DataResponse< [ ZCRMProfile ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllProfiles() { ( result ) in
            completion( result )
        }
    }
    
    public func getProfile( id : Int64, completion : @escaping( ZCRMResult.DataResponse< ZCRMProfile, APIResponse > ) -> () )
    {
        UserAPIHandler().getProfile( profileId : id ) { ( result ) in
            completion( result )
        }
    }
    
    public func getRoles( completion : @escaping( ZCRMResult.DataResponse< [ ZCRMRole ], BulkAPIResponse > ) -> () )
    {
        UserAPIHandler().getAllRoles() { ( result ) in
            completion( result )
        }
    }
    
    public func getRole( id : Int64, completion : @escaping( ZCRMResult.DataResponse< ZCRMRole, APIResponse > ) -> () )
    {
        UserAPIHandler().getRole( roleId : id ) { ( result ) in
            completion( result )
        }
    }
    
    public func searchUsers( withCriteria : ZCRMQuery.ZCRMCriteria, completion : @escaping( ZCRMResult.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        guard let recordQuery = withCriteria.recordQuery else {
            ZCRMLogger.logError( message : "\( ZCRMErrorCode.internalError) : Criteria cannot be constructed" )
            completion( .failure( ZCRMError.processingError( code : ZCRMErrorCode.internalError, message : "Criteria cannot be constructed", details : nil ) ) )
            return
        }
        UserAPIHandler().searchUsers( ofType : nil, criteria : recordQuery, page : nil, perPage : nil ) { ( result ) in
            completion( result )
           
        }
    }
    
    @available(*, deprecated, message: "Use searchUsers ofType ZCRMUser.Category instead")
    public func searchUsers(ofType : ZCRMUserTypes, withCriteria : ZCRMQuery.ZCRMCriteria, completion : @escaping( ZCRMResult.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        guard let recordQuery = withCriteria.recordQuery else {
            ZCRMLogger.logError( message : "\( ZCRMErrorCode.internalError) : Criteria cannot be constructed" )
            completion( .failure( ZCRMError.processingError( code : ZCRMErrorCode.internalError, message : "Criteria cannot be constructed", details : nil ) ) )
            return
        }
        UserAPIHandler().searchUsers(ofType : getUserType(ofType), criteria : recordQuery, page : nil, perPage: nil) { ( result ) in
            completion( result )
        }
    }
    
    public func searchUsers( withCriteria : ZCRMQuery.ZCRMCriteria, page : Int, perPage : Int, completion : @escaping( ZCRMResult.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        guard let recordQuery = withCriteria.recordQuery else {
            ZCRMLogger.logError( message : "\( ZCRMErrorCode.internalError) : Criteria cannot be constructed" )
            completion( .failure( ZCRMError.processingError( code : ZCRMErrorCode.internalError, message : "Criteria cannot be constructed", details : nil ) ) )
            return
        }
        UserAPIHandler().searchUsers( ofType : nil, criteria : recordQuery, page : page, perPage : perPage) { ( result ) in
            completion( result )
        }
    }
    @available(*, deprecated, message: "Use searchUsers ofType ZCRMUser.Category instead")
    public func searchUsers(ofType : ZCRMUserTypes, withCriteria : ZCRMQuery.ZCRMCriteria, page : Int, perPage : Int, completion : @escaping( ZCRMResult.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        guard let recordQuery = withCriteria.recordQuery else {
            ZCRMLogger.logError( message : "\( ZCRMErrorCode.internalError) : Criteria cannot be constructed" )
            completion( .failure( ZCRMError.processingError( code : ZCRMErrorCode.internalError, message : "Criteria cannot be constructed", details : nil ) ) )
            return
        }
        UserAPIHandler().searchUsers(ofType : getUserType(ofType), criteria : recordQuery, page : page, perPage : perPage) { ( result ) in
            completion( result )
        }
    }
    public func searchUsers(ofType : ZCRMUser.Category?, withCriteria : ZCRMQuery.ZCRMCriteria, page : Int, perPage : Int, completion : @escaping( ZCRMResult.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        guard let recordQuery = withCriteria.recordQuery else {
            ZCRMLogger.logError( message : "\( ZCRMErrorCode.internalError) : Criteria cannot be constructed" )
            completion( .failure( ZCRMError.processingError( code : ZCRMErrorCode.internalError, message : "Criteria cannot be constructed", details : nil ) ) )
            return
        }
        UserAPIHandler().searchUsers(ofType : ofType, criteria : recordQuery, page : page, perPage : perPage) { ( result ) in
            completion( result )
        }
    }
}

