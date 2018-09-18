//
//  UserAPIHandler.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 08/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

internal class UserAPIHandler : CommonAPIHandler
{
    var user : ZCRMUser?
    
    internal init( user : ZCRMUser )
    {
        self.user = user
    }
    
    internal override init()
    { }
    
    private func getUsers(type : String?, modifiedSince : String?, page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.USERS )
        var allUsers : [ZCRMUser] = [ZCRMUser]()
		setUrlPath(urlPath: "/users" )
		setRequestMethod(requestMethod: .GET )
        if(type != nil)
        {
			addRequestParam(param: RequestParamKeys.type , value: type! )
        }
        if ( modifiedSince.notNilandEmpty)
        {
			addRequestHeader(header: "If-Modified-Since" , value: modifiedSince! )
        }
        addRequestParam( param : "page", value : String( page ) )
        addRequestParam( param : "per_page", value : String( perPage ) )
		let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
        
        request.getBulkAPIResponse { ( resultType ) in
            do{
                let bulkResponse = try resultType.resolve()
                let responseJSON = bulkResponse.getResponseJSON()
                if responseJSON.isEmpty == false
                {
                    let usersList:[[String:Any]] = responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                    for user in usersList
                    {
                        allUsers.append(self.getZCRMUser(userDict: user))
                    }
                    bulkResponse.setData(data: allUsers)
                    completion( .success( allUsers, bulkResponse ) )
                }
                else
                {
                    completion( .failure( ZCRMError.SDKError( code : ErrorCode.RESPONSE_NIL, message : ErrorMessage.RESPONSE_NIL_MSG ) ) )
                }
            }
            catch{
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }

    internal func getAllProfiles( completion : @escaping( Result.DataResponse< [ ZCRMProfile ], BulkAPIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.PROFILES )
        var allProfiles : [ ZCRMProfile ] = [ ZCRMProfile ] ()
		setUrlPath(urlPath: "/settings/profiles" )
		setRequestMethod(requestMethod: .GET)
		let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
        
        request.getBulkAPIResponse { ( resultType ) in
            do{
                let bulkResponse = try resultType.resolve()
                let responseJSON = bulkResponse.getResponseJSON()
                if responseJSON.isEmpty == false
                {
                    let profileList : [ [ String : Any ] ] = responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                    for profile in profileList
                    {
                        allProfiles.append( self.getZCRMProfile( profileDetails : profile ) )
                    }
                    bulkResponse.setData( data : allProfiles)
                    completion( .success( allProfiles, bulkResponse ) )
                }
                else
                {
                    completion( .failure( ZCRMError.SDKError( code : ErrorCode.RESPONSE_NIL, message : ErrorMessage.RESPONSE_NIL_MSG ) ) )
                }
            }
            catch{
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }

    internal func getAllRoles( completion : @escaping( Result.DataResponse< [ ZCRMRole ], BulkAPIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.ROLES )
        var allRoles : [ ZCRMRole ] = [ ZCRMRole ]()
		setUrlPath(urlPath:  "/settings/roles" )
		setRequestMethod(requestMethod: .GET)
		let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
        
        request.getBulkAPIResponse { ( resultType ) in
            do{
                let bulkResponse = try resultType.resolve()
                let responseJSON = bulkResponse.getResponseJSON()
                if responseJSON.isEmpty == false
                {
                    let rolesList : [ [ String : Any ] ] = responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                    for role in rolesList
                    {
                        allRoles.append( self.getZCRMRole( roleDetails : role ) )
                    }
                    bulkResponse.setData( data : allRoles )
                    completion( .success( allRoles, bulkResponse ) )
                }
                else
                {
                    completion( .failure( ZCRMError.SDKError( code : ErrorCode.RESPONSE_NIL, message : ErrorMessage.RESPONSE_NIL_MSG ) ) )
                }
            }
            catch{
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }

    internal func getUser( userId : Int64?, completion : @escaping( Result.DataResponse< ZCRMUser, APIResponse > ) -> () )
	{
        setJSONRootKey( key : JSONRootKey.USERS )
		setRequestMethod(requestMethod: .GET )
        if(userId != nil)
        {
			setUrlPath(urlPath: "/users/\(userId!)" )
        }
        else
        {
			setUrlPath(urlPath: "/users" )
			addRequestParam(param: RequestParamKeys.type , value:  RequestParamKeys.currentUser)
        }
		let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
        
        request.getAPIResponse { ( resultType ) in
            do{
                let response = try resultType.resolve()
                let responseJSON = response.getResponseJSON()
                let usersList:[[String : Any]] = responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                let user = self.getZCRMUser(userDict: usersList[0])
                response.setData(data: user )
                completion( .success( user, response ) )
            }
            catch{
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }

    internal func addUser( user : ZCRMUser, completion : @escaping( Result.DataResponse< ZCRMUser, APIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.USERS )
        setRequestMethod( requestMethod : .POST )
        setUrlPath( urlPath : "/users" )
        var reqBodyObj : [ String : [ [ String : Any ] ] ] = [ String : [ [ String : Any ] ] ]()
        var dataArray : [ [ String : Any ] ] = [ [ String : Any ] ]()
        dataArray.append( self.getZCRMUserAsJSON( user : user ) )
        reqBodyObj[JSONRootKey.USERS] = dataArray
        setRequestBody( requestBody : reqBodyObj )
        let request = APIRequest( handler : self )
        print( "Request : \( request.toString() )" )
        
        request.getAPIResponse { ( resultType ) in
            do{
                let response = try resultType.resolve()
                let responseJSONArray  = response.getResponseJSON().getArrayOfDictionaries( key : self.getJSONRootKey() )
                let responseJSONData = responseJSONArray[ 0 ]
                let responseDetails : [ String : Any ] = responseJSONData[ APIConstants.DETAILS ] as! [ String : Any ]
                user.id = responseDetails.getInt64( key : "id" )
                response.setData( data : user )
                completion( .success( user, response ) )
            }
            catch{
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }

    internal func updateUser( user : ZCRMUser, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.USERS )
        setRequestMethod( requestMethod : .PUT )
        setUrlPath( urlPath : "/users/\( user.id )" )
        var reqBodyObj : [ String : [ [ String : Any ] ] ] = [ String : [ [ String : Any ] ] ]()
        var dataArray : [ [ String : Any ] ] = [ [ String : Any ] ]()
        dataArray.append( self.getZCRMUserAsJSON( user : user ) )
        reqBodyObj[ getJSONRootKey() ] = dataArray
        setRequestBody( requestBody : reqBodyObj )
        let request = APIRequest( handler : self )
        print( "Request : \( request.toString() )" )
        
        request.getAPIResponse { ( resultType ) in
            do{
                let response = try resultType.resolve()
                completion( .success( response ) )
            }
            catch{
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }

    internal func deleteUser( userId : Int64, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        setRequestMethod( requestMethod : .DELETE )
        setUrlPath( urlPath : "/users/\( userId )" )
        let request = APIRequest( handler : self )
        
        request.getAPIResponse { ( resultType ) in
            do{
                let response = try resultType.resolve()
                completion( .success( response ) )
            }
            catch{
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }

    internal func searchUsers( criteria : String, page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.USERS )
        setRequestMethod( requestMethod : .PUT )
        setUrlPath( urlPath : "/users" )
        addRequestParam( param : RequestParamKeys.filters, value : criteria )
        addRequestParam( param : "page", value : String( page ) )
        addRequestParam( param : "per_page", value : String( perPage ) )
        
        APIRequest( handler : self ).getBulkAPIResponse { ( resultType ) in
            do{
                let bulkResponse = try resultType.resolve()
                let responseJSON = bulkResponse.getResponseJSON()
                var userList : [ ZCRMUser ] = [ ZCRMUser ]()
                if responseJSON.isEmpty == false
                {
                    let userDetailsList : [ [ String : Any ] ] = responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                    for userDetail in userDetailsList
                    {
                        let user : ZCRMUser = self.getZCRMUser( userDict : userDetail )
                        userList.append( user )
                    }
                    bulkResponse.setData( data : userList )
                    completion( .success( userList, bulkResponse ) )
                }
                else
                {
                    completion( .failure( ZCRMError.SDKError( code : ErrorCode.RESPONSE_NIL, message : ErrorMessage.RESPONSE_NIL_MSG ) ) )
                }
            }
            catch{
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }

    internal func getProfile( profileId : Int64, completion : @escaping( Result.DataResponse< ZCRMProfile, APIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.PROFILES)
		setUrlPath(urlPath:  "/settings/profiles/\(profileId)" )
		setRequestMethod(requestMethod: .GET )
		let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
        
        request.getAPIResponse { ( resultType ) in
            do{
                let response = try resultType.resolve()
                let responseJSON = response.getResponseJSON()
                let profileList : [ [ String : Any ] ] = responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                let profile = self.getZCRMProfile( profileDetails: profileList[ 0 ] )
                response.setData( data : profile )
                completion( .success( profile, response ) )
            }
            catch{
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }

    internal func getRole( roleId : Int64, completion : @escaping( Result.DataResponse< ZCRMRole, APIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.ROLES )
        setUrlPath(urlPath: "/settings/roles/\(roleId)" )
        setRequestMethod(requestMethod: .GET )
        let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
        
        request.getAPIResponse { ( resultType ) in
            do{
                let response = try resultType.resolve()
                let responseJSON = response.getResponseJSON()
                let rolesList : [ [ String : Any ] ] = responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                let role = self.getZCRMRole( roleDetails : rolesList[ 0 ] )
                response.setData( data : role )
                completion( .success( role, response ) )
            }
            catch{
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func downloadPhoto( size : PhotoSize?, completion : @escaping( Result.Response< FileAPIResponse > ) -> () )
    {
        if let user = self.user
        {
            let emailId = user.emailId
            if emailId != APIConstants.STRING_MOCK
            {
                let PHOTOURL : URL = URL( string : "https://profile.zoho.com/api/v1/user/\(emailId)/photo" )!
                setUrl(url: PHOTOURL )
                setRequestMethod(requestMethod: .GET )
                if let photoSize = size
                {
                    addRequestParam(param: RequestParamKeys.photoSize , value: photoSize.rawValue )
                }
                let request : APIRequest = APIRequest(handler: self)
                print( "Request : \( request.toString() )" )
                request.downloadFile { ( resultType ) in
                    do{
                        let response = try resultType.resolve()
                        completion( .success( response ) )
                    }
                    catch{
                        completion( .failure( typeCastToZCRMError( error ) ) )
                    }
                }
            }
        }
    }
    
    internal func uploadPhotoWithPath( photoViewPermission : XPhotoViewPermission, filePath : String, completion : @escaping(  Result.Response< APIResponse > ) -> () )
    {
        if let user = self.user
        {
            let emailId = user.emailId
            if emailId != APIConstants.STRING_MOCK
            {
                let PHOTOURL : URL = URL( string : "https://profile.zoho.com/api/v1/user/\(emailId)/photo" )!
                setUrl(url : PHOTOURL)
                setRequestMethod(requestMethod: .PUT)
                addRequestHeader(header: "X-PHOTO-VIEW-PERMISSION", value: String(photoViewPermission.rawValue))
                let request : APIRequest = APIRequest(handler: self)
                print( "Request : \(request.toString())" )
                request.uploadFile(filePath : filePath ) { ( resultType ) in
                    do{
                        let response = try resultType.resolve()
                        completion( .success( response ) )
                    }
                    catch{
                        completion( .failure( typeCastToZCRMError( error ) ) )
                    }
                }
            }
        }
    }
    
    internal func uploadPhotoWithData( photoViewPermission : XPhotoViewPermission, fileName : String, data : Data, completion : @escaping(   Result.Response< APIResponse > ) -> () )
    {
        if let user = self.user
        {
            let emailId = user.emailId
            if emailId != APIConstants.STRING_MOCK
            {
                let PHOTOURL : URL = URL( string : "https://profile.zoho.com/api/v1/user/\(emailId)/photo" )!
                setUrl(url : PHOTOURL)
                setRequestMethod(requestMethod: .PUT)
                addRequestHeader(header: "X-PHOTO-VIEW-PERMISSION", value: String(photoViewPermission.rawValue))
                let request : APIRequest = APIRequest(handler: self)
                print( "Request : \(request.toString())" )
                request.uploadFileWithData(fileName: fileName, data: data) { ( resultType ) in
                    do{
                        let response = try resultType.resolve()
                        completion( .success( response ) )
                    }
                    catch{
                        completion( .failure( typeCastToZCRMError( error ) ) )
                    }
                }
            }
        }
    }

    internal func getCurrentUser( completion : @escaping( Result.DataResponse< ZCRMUser, APIResponse > ) -> () )
    {
        self.getUser( userId : nil) { ( result ) in
            completion( result )
        }
    }
    
    internal func getAllUsers( modifiedSince : String?, page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        self.getUsers( type: nil, modifiedSince : modifiedSince, page : page, perPage : perPage) { ( result ) in
            completion( result )
        }
    }
    
    internal func getAllActiveUsers( page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        self.getUsers( type : RequestParamValues.activeUsers, modifiedSince : nil, page : page, perPage : perPage) { ( result ) in
            completion( result )
        }
    }
    
    internal func getAllDeactiveUsers( page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        self.getUsers( type : RequestParamValues.deactiveUsers, modifiedSince : nil, page : page, perPage : perPage) { ( result ) in
            completion( result )
        }
    }
    
    internal func getAllUnConfirmedUsers( page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        self.getUsers( type : RequestParamValues.notConfirmedUsers, modifiedSince : nil, page : page, perPage : perPage) { ( result ) in
            completion( result )
        }
    }
    
    internal func getAllConfirmedUsers( page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        self.getUsers( type : RequestParamValues.confirmedUsers, modifiedSince : nil, page : page, perPage : perPage) { ( result ) in
            completion( result )
        }
    }

    internal func getAllActiveConfirmedUsers( page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        self.getUsers( type: RequestParamValues.activeConfirmedUsers, modifiedSince : nil, page : page, perPage : perPage) { ( result ) in
            completion( result )
        }
    }
    
    internal func getAllDeletedUsers( page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        self.getUsers( type: RequestParamValues.deletedUsers, modifiedSince : nil, page : page, perPage : perPage) { ( result ) in
            completion( result )
        }
    }
    
    internal func getAllAdminUsers( page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        self.getUsers( type: RequestParamValues.adminUsers, modifiedSince : nil, page : page, perPage : perPage) { ( result ) in
            completion( result )
        }
    }
    
    internal func getAllActiveConfirmedAdmins( page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        self.getUsers( type: RequestParamValues.activeConfirmedAdmins, modifiedSince : nil, page : page, perPage : perPage) { ( result ) in
            completion( result )
        }
    }
	
	private func getZCRMUser(userDict : [String : Any]) -> ZCRMUser
	{
        let fullName : String = userDict.getString( key : ResponseJSONKeys.fullName )
        let userId : Int64? = userDict.getInt64( key : ResponseJSONKeys.id )
        var role : ZCRMRoleDelegate = ROLE_MOCK
        var profile : ZCRMProfileDelegate = PROFILE_MOCK
        let lastName = userDict.getString(key: ResponseJSONKeys.lastName)
        let email = userDict.getString(key: ResponseJSONKeys.email)
        if ( userDict.hasValue( forKey : ResponseJSONKeys.profile ) )
        {
            let profileObj : [String : Any] = userDict.getDictionary(key: ResponseJSONKeys.profile)
            profile = ZCRMProfileDelegate(profileId: profileObj.getInt64( key : ResponseJSONKeys.id ), profileName: profileObj.getString( key : ResponseJSONKeys.name ))
        }
        if ( userDict.hasValue( forKey : ResponseJSONKeys.role ) )
        {
            let roleObj : [String : Any] = userDict.getDictionary(key: ResponseJSONKeys.role)
            role = ZCRMRoleDelegate(roleId: roleObj.getInt64( key : ResponseJSONKeys.id ), roleName: roleObj.getString( key : ResponseJSONKeys.name ))
        }
        let user = ZCRMUser(lastName: lastName, emailId: email, role: role, profile: profile)
        user.id = userId ?? APIConstants.INT64_MOCK
        user.fullName = fullName
        user.firstName = userDict.optString(key: ResponseJSONKeys.firstName) ?? APIConstants.STRING_MOCK
        user.mobile = userDict.optString(key: ResponseJSONKeys.mobile) ?? APIConstants.STRING_MOCK
        user.language = userDict.optString(key: ResponseJSONKeys.language) ?? APIConstants.STRING_MOCK
        user.status = userDict.optString(key: ResponseJSONKeys.status) ?? APIConstants.STRING_MOCK
        user.zuId = userDict.optInt64(key: ResponseJSONKeys.ZUID) ?? APIConstants.INT64_MOCK
        
        user.alias = userDict.optString( key : ResponseJSONKeys.alias ) ?? APIConstants.STRING_MOCK
        user.city = userDict.optString( key : ResponseJSONKeys.city ) ?? APIConstants.STRING_MOCK
        user.confirm = userDict.optBoolean( key : ResponseJSONKeys.confirm ) ?? APIConstants.BOOL_MOCK
        user.countryLocale = userDict.optString(key : ResponseJSONKeys.countryLocale ) ?? APIConstants.STRING_MOCK
        user.dateFormat = userDict.optString( key : ResponseJSONKeys.dateFormat ) ?? APIConstants.STRING_MOCK
        user.dateOfBirth = userDict.optString( key : ResponseJSONKeys.dob ) ?? APIConstants.STRING_MOCK
        user.country = userDict.optString( key : ResponseJSONKeys.country ) ?? APIConstants.STRING_MOCK
        user.fax = userDict.optString( key : ResponseJSONKeys.fax ) ?? APIConstants.STRING_MOCK
        user.locale = userDict.optString( key : ResponseJSONKeys.locale ) ?? APIConstants.STRING_MOCK
        user.nameFormat = userDict.optString( key : ResponseJSONKeys.nameFormat ) ?? APIConstants.STRING_MOCK
        user.phone = userDict.optString( key : ResponseJSONKeys.phone ) ?? APIConstants.STRING_MOCK
        user.website = userDict.optString( key : ResponseJSONKeys.website ) ?? APIConstants.STRING_MOCK
        user.street = userDict.optString( key : ResponseJSONKeys.street ) ?? APIConstants.STRING_MOCK
        user.timeZone = userDict.optString( key : ResponseJSONKeys.timeZone ) ?? APIConstants.STRING_MOCK
        user.state = userDict.optString( key : ResponseJSONKeys.state) ?? APIConstants.STRING_MOCK
        if( userDict.hasValue( forKey : ResponseJSONKeys.CreatedBy))
        {
            let createdByObj : [String:Any] = userDict.getDictionary(key: ResponseJSONKeys.CreatedBy)
            user.createdBy = getUserDelegate(userJSON : createdByObj)
            user.createdTime = userDict.getString( key : ResponseJSONKeys.CreatedTime)
        }
        if( userDict.hasValue( forKey : ResponseJSONKeys.ModifiedBy ) )
        {
            let modifiedByObj : [ String : Any ] = userDict.getDictionary( key : ResponseJSONKeys.ModifiedBy)
            user.modifiedBy = getUserDelegate(userJSON : modifiedByObj)
            user.modifiedTime = userDict.getString( key : ResponseJSONKeys.ModifiedTime )
        }
        if ( userDict.hasValue( forKey : ResponseJSONKeys.ReportingTo ) )
        {
            let reportingObj : [ String : Any ] = userDict.getDictionary( key : ResponseJSONKeys.ReportingTo )
            user.reportingTo = getUserDelegate(userJSON : reportingObj)
        }
		return user
	}
    
    private func getZCRMRole( roleDetails : [ String : Any ] ) -> ZCRMRole
    {
        let role = ZCRMRole(name: roleDetails.getString( key : ResponseJSONKeys.name ))
        role.roleId = roleDetails.getInt64( key : ResponseJSONKeys.id )
        role.label = roleDetails.getString( key : ResponseJSONKeys.displayLabel )
        role.isAdminUser = roleDetails.getBoolean( key : ResponseJSONKeys.adminUser )
        if ( roleDetails.hasValue(forKey: ResponseJSONKeys.reportingTo) )
        {
            let reportingToObj : [String : Any] = roleDetails.getDictionary( key : ResponseJSONKeys.reportingTo )
            role.reportingTo = ZCRMRoleDelegate(roleId: reportingToObj.getInt64( key : ResponseJSONKeys.id ), roleName: reportingToObj.getString( key : ResponseJSONKeys.name ))
        }
        return role
    }
    
    private func getZCRMProfile( profileDetails : [ String : Any ] ) -> ZCRMProfile
    {
        let profile = ZCRMProfile(name: profileDetails.getString( key : ResponseJSONKeys.name ) )
        profile.profileId = profileDetails.getInt64( key : ResponseJSONKeys.id )
        profile.category = profileDetails.getBoolean( key : ResponseJSONKeys.category )
        if ( profileDetails.hasValue( forKey : ResponseJSONKeys.description ) )
        {
            profile.description = profileDetails.getString( key : ResponseJSONKeys.description )
        }
        if ( profileDetails.hasValue( forKey : ResponseJSONKeys.modifiedBy ) )
        {
            let modifiedUserObj : [ String : Any ] = profileDetails.getDictionary( key : ResponseJSONKeys.modifiedBy )
            profile.modifiedBy = getUserDelegate(userJSON : modifiedUserObj)
            profile.modifiedTime = profileDetails.getString( key : ResponseJSONKeys.modifiedTime )
        }
        if ( profileDetails.hasValue( forKey : ResponseJSONKeys.createdBy ) )
        {
            let createdUserObj : [ String : Any ] = profileDetails.getDictionary( key : ResponseJSONKeys.createdBy )
            profile.createdBy = getUserDelegate(userJSON : createdUserObj)
            profile.createdTime = profileDetails.getString( key : ResponseJSONKeys.createdTime )
        }
        return profile
    }
    
    private func getZCRMUserAsJSON( user : ZCRMUser ) -> [ String : Any ]
    {
        var userJSON : [ String : Any ] = [ String : Any ]()
        let id = user.id
        if id != APIConstants.INT64_MOCK
        {
             userJSON[ ResponseJSONKeys.id ] = id
        }
        else
        {
             userJSON[ ResponseJSONKeys.id ] = nil
        }
        let firstName = user.firstName
        if firstName != APIConstants.STRING_MOCK
        {
            userJSON[ ResponseJSONKeys.firstName ] = firstName
        }
        else
        {
            userJSON[ ResponseJSONKeys.firstName ] = nil
        }
        let lastName = user.lastName
        if lastName != APIConstants.STRING_MOCK
        {
            userJSON[ ResponseJSONKeys.lastName ] = lastName
        }
        else
        {
            userJSON[ ResponseJSONKeys.lastName ] = nil
        }
        let fullName = user.fullName
        if fullName != APIConstants.STRING_MOCK
        {
            userJSON[ ResponseJSONKeys.fullName ] = fullName
        }
        else
        {
            userJSON[ ResponseJSONKeys.fullName ] = nil
        }
        let alias = user.alias
        if alias != APIConstants.STRING_MOCK
        {
            userJSON[ ResponseJSONKeys.alias ] = alias
        }
        else
        {
            userJSON[ ResponseJSONKeys.alias ] = nil
        }
        let dob = user.dateOfBirth
        if dob != APIConstants.STRING_MOCK
        {
            userJSON[ ResponseJSONKeys.dob ] = dob
        }
        else
        {
            userJSON[ ResponseJSONKeys.dob ] = nil
        }
        let mobile = user.mobile
        if mobile != APIConstants.STRING_MOCK
        {
            userJSON[ ResponseJSONKeys.mobile ] = mobile
        }
        else
        {
            userJSON[ ResponseJSONKeys.mobile ] = nil
        }
        let phone = user.phone
        if phone != APIConstants.STRING_MOCK
        {
            userJSON[ ResponseJSONKeys.phone ] = phone
        }
        else
        {
            userJSON[ ResponseJSONKeys.phone ] = nil
        }
        let fax = user.fax
        if fax != APIConstants.STRING_MOCK
        {
            userJSON[ ResponseJSONKeys.fax ] = fax
        }
        else
        {
            userJSON[ ResponseJSONKeys.fax ] = nil
        }
        let email = user.emailId
        if email != APIConstants.STRING_MOCK
        {
            userJSON[ ResponseJSONKeys.email ] = email
        }
        else
        {
            userJSON[ ResponseJSONKeys.email ] = nil
        }
        let zip = user.zip
        if zip != APIConstants.INT64_MOCK
        {
            userJSON[ ResponseJSONKeys.zip ] = zip
        }
        else
        {
            userJSON[ ResponseJSONKeys.zip ] = nil
        }
        let country = user.country
        if country != APIConstants.STRING_MOCK
        {
            userJSON[ ResponseJSONKeys.country ] = country
        }
        else
        {
            userJSON[ ResponseJSONKeys.country ] = nil
        }
        let state = user.state
        if state != APIConstants.STRING_MOCK
        {
            userJSON[ ResponseJSONKeys.state ] = state
        }
        else
        {
            userJSON[ ResponseJSONKeys.state ] = nil
        }
        let city = user.city
        if city != APIConstants.STRING_MOCK
        {
            userJSON[ ResponseJSONKeys.city ] = city
        }
        else
        {
            userJSON[ ResponseJSONKeys.city ] = nil
        }
        let street = user.street
        if street != APIConstants.STRING_MOCK
        {
            userJSON[ ResponseJSONKeys.street ] = street
        }
        else
        {
            userJSON[ ResponseJSONKeys.street ] = nil
        }
        let locale = user.locale
        if locale != APIConstants.STRING_MOCK
        {
            userJSON[ ResponseJSONKeys.locale ] = locale
        }
        else
        {
            userJSON[ ResponseJSONKeys.locale ] = nil
        }
        let countryLocale = user.countryLocale
        if countryLocale != APIConstants.STRING_MOCK
        {
            userJSON[ ResponseJSONKeys.countryLocale ] = countryLocale
        }
        else
        {
            userJSON[ ResponseJSONKeys.countryLocale ] = nil
        }
        let nameFormat = user.nameFormat
        if nameFormat != APIConstants.STRING_MOCK
        {
            userJSON[ ResponseJSONKeys.nameFormat ] = nameFormat
        }
        else
        {
            userJSON[ ResponseJSONKeys.nameFormat ] = nil
        }
        let dateFormat = user.dateFormat
        if dateFormat != APIConstants.STRING_MOCK
        {
            userJSON[ ResponseJSONKeys.dateFormat ] = dateFormat
        }
        else
        {
            userJSON[ ResponseJSONKeys.dateFormat ] = nil
        }
        let timeFormat = user.timeFormat
        if timeFormat != APIConstants.STRING_MOCK
        {
            userJSON[ ResponseJSONKeys.timeFormat ] = timeFormat
        }
        else
        {
            userJSON[ ResponseJSONKeys.timeFormat ] = nil
        }
        let timeZone = user.timeZone
        if timeZone != APIConstants.STRING_MOCK
        {
            userJSON[ ResponseJSONKeys.timeZone ] = timeZone
        }
        else
        {
            userJSON[ ResponseJSONKeys.timeZone ] = nil
        }
        let website = user.website
        if website != APIConstants.STRING_MOCK
        {
            userJSON[ ResponseJSONKeys.website ] = website
        }
        else
        {
            userJSON[ ResponseJSONKeys.website ] = nil
        }
        let confirm = user.confirm
        userJSON[ ResponseJSONKeys.confirm ] = confirm
        let status = user.status
        if status != APIConstants.STRING_MOCK
        {
            userJSON[ ResponseJSONKeys.status ] = status
        }
        else
        {
            userJSON[ ResponseJSONKeys.status ] = nil
        }
        let profile = user.profile
        if profile.profileId != APIConstants.INT64_MOCK
        {
            userJSON[ ResponseJSONKeys.profile ] = String( profile.profileId )
        }
        else
        {
            print( "User must have profile" )
        }
        let role = user.role
        if role.roleId != APIConstants.INT64_MOCK
        {
            userJSON[ ResponseJSONKeys.role ] = role.roleId
        }
        else
        {
            print( "User must have role" )
        }
        
        if user.getData().isEmpty == false
        {
            var userData : [ String : Any ] = user.getData()

            for fieldAPIName in userData.keys
            {
                var value = userData[ fieldAPIName ]
                if( value != nil && value is ZCRMRecord )
                {
                    value = String( ( value as! ZCRMRecord ).recordId )
                }
                else if( value != nil && value is ZCRMUser )
                {
                    value = String( ( value as! ZCRMUser ).id )
                }
                else if( value != nil && value is [ [ String : Any ] ] )
                {
                    var valueDict = [ [ String : Any ] ]()
                    let valueList = ( value as! [ [ String : Any ] ] )
                    for valueDetail in valueList
                    {
                        valueDict.append( valueDetail )
                    }
                    value = valueDict
                }
                userJSON[ fieldAPIName ] = value
            }
        }
        
        return userJSON
    }
}

fileprivate extension UserAPIHandler
{
    struct RequestParamKeys
    {
        static let type = "type"
        static let currentUser = "CurrentUser"
        static let filters = "filters"
        static let photoSize = "photo_size"
    }
    
    struct RequestParamValues
    {
        static let activeUsers = "ActiveUsers"
        static let deactiveUsers = "DeactiveUsers"
        static let notConfirmedUsers = "NotConfirmedUsers"
        static let confirmedUsers = "ConfirmedUsers"
        static let activeConfirmedUsers = "ActiveConfirmedUsers"
        static let deletedUsers = "DeletedUsers"
        static let adminUsers = "AdminUsers"
        static let activeConfirmedAdmins = "ActiveConfirmedAdmins"
    }
    
    struct ResponseJSONKeys
    {
        static let fullName = "full_name"
        static let id = "id"
        static let name = "name"
        static let firstName = "first_name"
        static let lastName = "last_name"
        static let email = "email"
        static let mobile = "mobile"
        static let language = "language"
        static let status = "status"
        static let ZUID = "zuid"
        static let profile = "profile"
        static let role = "role"
        static let alias = "alias"
        static let city = "city"
        static let confirm = "confirm"
        static let countryLocale = "country_locale"
        static let dateFormat = "date_fromat"
        static let dob = "dob"
        static let country = "country"
        static let fax = "fax"
        static let locale = "locale"
        static let nameFormat = "name_format"
        static let phone = "phone"
        static let website = "website"
        static let street = "street"
        static let timeZone = "time_zone"
        static let state = "state"
        static let CreatedBy = "Created_By"
        static let CreatedTime = "Created_Time"
        static let ModifiedBy = "Modified_By"
        static let ModifiedTime = "Modified_Time"
        static let ReportingTo = "Reporting_To"
        
        static let displayLabel = "display_label"
        static let adminUser = "admin_user"
        static let reportingTo = "reporting_to"
        
        static let category = "category"
        static let description = "description"
        static let modifiedBy = "modified_by"
        static let createdBy = "created_by"
        static let modifiedTime = "modified_time"
        static let createdTime = "created_time"
        
        static let zip = "zip"
        static let timeFormat = "time_format"
    }
}
