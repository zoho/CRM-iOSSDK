//
//  UserAPIHandler.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 08/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

internal class UserAPIHandler : CommonAPIHandler
{
    let cache : ZCRMCacheFlavour
    internal var userDelegate : ZCRMUserDelegate?
    internal var user : ZCRMUser?
    
    internal init( userDelegate : ZCRMUserDelegate )
    {
        self.cache = .noCache
        self.userDelegate = userDelegate
    }
    
    internal init( user : ZCRMUser )
    {
        self.cache = .noCache
        self.user = user
    }
    
    internal init( userDelegate : ZCRMUserDelegate, cacheFlavour : ZCRMCacheFlavour )
    {
        self.cache = cacheFlavour
        self.userDelegate = userDelegate
    }
    
    internal init( cacheFlavour : ZCRMCacheFlavour )
    {
        self.cache = cacheFlavour
    }
    
    internal override init()
    {
        self.cache = .noCache
    }
    
    internal func getUsers( _ params : GETUserParams, requestHeaders: [ String : String ]? = nil, completion : @escaping ( ZCRMResult.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> Void )
    {
        setJSONRootKey( key : JSONRootKey.USERS )
        var allUsers : [ZCRMUser] = [ZCRMUser]()
        setUrlPath(urlPath: "\( URLPathConstants.users )" )
        setRequestMethod(requestMethod: .get )
        setAPIVersion("v4")
        
        if let type = params.type
        {
            addRequestParam(param: RequestParamKeys.type , value: type.rawValue )
            if type == .parentRoleUsers || type == .childRoleUsers{
                if let roleId = params.roleId
                {
                    addRequestParam(param: RequestParamKeys.roleId , value: String( roleId ))
                } else {
                    ZCRMLogger.logError(message: "\(ZCRMErrorCode.mandatoryNotFound) : Role id cannot be null for GET user type \( type )")
                    completion(.failure(ZCRMError.inValidError(code: ZCRMErrorCode.mandatoryNotFound, message: "Role id cannot be null for GET user type \(type)", details: nil)))
                    return
                }
                
            }
        }
        
        if params.modifiedSince.notNilandEmpty, let modifiedSince = params.modifiedSince
        {
            addRequestHeader(header: RequestParamKeys.ifModifiedSince , value: modifiedSince )
        }
        if let page = params.page
        {
            addRequestParam( param : RequestParamKeys.page, value : String( page ) )
        }
        if let perPage = params.perPage
        {
            addRequestParam( param : RequestParamKeys.perPage, value : String( perPage ) )
        }
        
        for ( key, value ) in requestHeaders ?? [:]
        {
            addRequestHeader(header: key, value: value)
        }
        let request : APIRequest = APIRequest(handler: self)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getBulkAPIResponse { ( resultType ) in
            do{
                let bulkResponse = try resultType.resolve()
                let responseJSON = bulkResponse.getResponseJSON()
                if responseJSON.isEmpty == false
                {
                    let usersList:[ [ String : Any ] ] = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                    if usersList.isEmpty == true
                    {
                        ZCRMLogger.logError(message: "\(ZCRMErrorCode.responseNil) : \(ZCRMErrorMessage.responseJSONNilMsg), \( APIConstants.DETAILS ) : -")
                        completion( .failure( ZCRMError.sdkError( code : ZCRMErrorCode.responseNil, message : ZCRMErrorMessage.responseJSONNilMsg, details : nil ) ) )
                        return
                    }
                    for userList in usersList
                    {
                        let user = try self.getZCRMUser( userDict : userList )
                        user.upsertJSON = [ String : Any? ]()
                        allUsers.append( user )
                    }
                }
                bulkResponse.setData(data: allUsers)
                completion( .success( allUsers, bulkResponse ) )
            }
            catch{
                ZCRMLogger.logError( message : "\( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func getUsers( ofType : ZCRMUserTypes?, modifiedSince : String?, page : Int?, perPage : Int?, completion : @escaping( ZCRMResult.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.USERS )
        var allUsers : [ZCRMUser] = [ZCRMUser]()
        setUrlPath(urlPath: "\( URLPathConstants.users )" )
        setRequestMethod(requestMethod: .get )
        setAPIVersion("v4")
        if let type = ofType
        {
            addRequestParam(param: RequestParamKeys.type , value: type.rawValue )
        }
        if ( modifiedSince.notNilandEmpty), let modifiedSince = modifiedSince
        {
            addRequestHeader(header: RequestParamKeys.ifModifiedSince , value: modifiedSince )
        }
        if let page = page
        {
            addRequestParam( param : RequestParamKeys.page, value : String( page ) )
        }
        if let perPage = perPage
        {
            addRequestParam( param : RequestParamKeys.perPage, value : String( perPage ) )
        }
        let request : APIRequest = APIRequest(handler: self)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getBulkAPIResponse { ( resultType ) in
            do{
                let bulkResponse = try resultType.resolve()
                let responseJSON = bulkResponse.getResponseJSON()
                if responseJSON.isEmpty == false
                {
                    let usersList:[ [ String : Any ] ] = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                    if usersList.isEmpty == true
                    {
                        ZCRMLogger.logError(message: "\(ZCRMErrorCode.responseNil) : \(ZCRMErrorMessage.responseJSONNilMsg), \( APIConstants.DETAILS ) : -")
                        completion( .failure( ZCRMError.sdkError( code : ZCRMErrorCode.responseNil, message : ZCRMErrorMessage.responseJSONNilMsg, details : nil ) ) )
                        return
                    }
                    for userList in usersList
                    {
                        let user = try self.getZCRMUser( userDict : userList )
                        user.upsertJSON = [ String : Any? ]()
                        allUsers.append( user )
                    }
                }
                bulkResponse.setData(data: allUsers)
                completion( .success( allUsers, bulkResponse ) )
            }
            catch{
                ZCRMLogger.logError( message : "\( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func getAllProfiles( completion : @escaping( ZCRMResult.DataResponse< [ ZCRMProfile ], BulkAPIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.PROFILES )
        var allProfiles : [ ZCRMProfile ] = [ ZCRMProfile ] ()
        setUrlPath(urlPath: "\( URLPathConstants.settings )/\( URLPathConstants.profiles )" )
        setRequestMethod(requestMethod: .get)
        let request : APIRequest = APIRequest(handler: self)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getBulkAPIResponse { ( resultType ) in
            do{
                let bulkResponse = try resultType.resolve()
                let responseJSON = bulkResponse.getResponseJSON()
                if responseJSON.isEmpty == false
                {
                    let profileList : [ [ String : Any ] ] = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                    if profileList.isEmpty == true
                    {
                        ZCRMLogger.logError(message: "\(ZCRMErrorCode.responseNil) : \(ZCRMErrorMessage.responseJSONNilMsg), \( APIConstants.DETAILS ) : -")
                        completion( .failure( ZCRMError.sdkError( code : ZCRMErrorCode.responseNil, message : ZCRMErrorMessage.responseJSONNilMsg, details : nil ) ) )
                        return
                    }
                    for profile in profileList
                    {
                        allProfiles.append( try self.getZCRMProfile( profileDetails : profile ) )
                    }
                }
                bulkResponse.setData( data : allProfiles)
                completion( .success( allProfiles, bulkResponse ) )
            }
            catch{
                ZCRMLogger.logError( message : "\( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func getAllRoles( completion : @escaping( ZCRMResult.DataResponse< [ ZCRMRole ], BulkAPIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.ROLES )
        var allRoles : [ ZCRMRole ] = [ ZCRMRole ]()
        setUrlPath(urlPath:  "\( URLPathConstants.settings )/\( URLPathConstants.roles )" )
        setRequestMethod(requestMethod: .get)
        let request : APIRequest = APIRequest(handler: self)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getBulkAPIResponse { ( resultType ) in
            do{
                let bulkResponse = try resultType.resolve()
                let responseJSON = bulkResponse.getResponseJSON()
                if responseJSON.isEmpty == false
                {
                    let rolesList : [ [ String : Any ] ] = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                    if rolesList.isEmpty == true
                    {
                        ZCRMLogger.logError(message: "\(ZCRMErrorCode.responseNil) : \(ZCRMErrorMessage.responseJSONNilMsg), \( APIConstants.DETAILS ) : -")
                        completion( .failure( ZCRMError.sdkError( code : ZCRMErrorCode.responseNil, message : ZCRMErrorMessage.responseJSONNilMsg, details : nil ) ) )
                        return
                    }
                    for role in rolesList
                    {
                        allRoles.append( try self.getZCRMRole( roleDetails : role ) )
                    }
                }
                bulkResponse.setData( data : allRoles )
                completion( .success( allRoles, bulkResponse ) )
            }
            catch{
                ZCRMLogger.logError( message : "\( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func getUser( userId : Int64?, completion : @escaping( ZCRMResult.DataResponse< ZCRMUser, APIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.USERS )
        setRequestMethod(requestMethod: .get )
        setAPIVersion("v4")
        if let userId = userId
        {
            setUrlPath(urlPath: "\( URLPathConstants.users )/\(userId)" )
        }
        else
        {
            setUrlPath(urlPath: "\( URLPathConstants.users )" )
            addRequestParam(param: RequestParamKeys.type , value:  RequestParamKeys.currentUser)
        }
        let request : APIRequest = APIRequest(handler: self, cacheFlavour: self.cache, dbType: .userData)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getAPIResponse { ( resultType ) in
            do{
                let response = try resultType.resolve()
                let responseJSON = response.getResponseJSON()
                let usersList:[ [ String : Any ] ] = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                let user = try self.getZCRMUser(userDict: usersList[0])
                user.upsertJSON = [ String : Any? ]()
                response.setData( data : user )
                completion( .success( user, response ) )
            }
            catch{
                ZCRMLogger.logError( message : "\( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func addUser( user : ZCRMUser, completion : @escaping( ZCRMResult.DataResponse< ZCRMUser, APIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.USERS )
        setRequestMethod( requestMethod : .post )
        setAPIVersion("v4")
        setUrlPath( urlPath : "\( URLPathConstants.users )" )
        var reqBodyObj : [ String : [ [ String : Any? ] ] ] = [ String : [ [ String : Any? ] ] ]()
        var dataArray : [ [ String : Any? ] ] = [ [ String : Any? ] ]()
        dataArray.append(user.upsertJSON)
        reqBodyObj[JSONRootKey.USERS] = dataArray
        setRequestBody( requestBody : reqBodyObj )
        let request = APIRequest( handler : self )
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getAPIResponse { ( resultType ) in
            do{
                let response = try resultType.resolve()
                let responseJSON = response.getResponseJSON()
                let responseJSONArray  = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                let responseJSONData = responseJSONArray[ 0 ]
                let responseDetails : [ String : Any ] = try responseJSONData.getDictionary( key : APIConstants.DETAILS )
                user.id = try responseDetails.getInt64( key : ResponseJSONKeys.id )
                user.data.updateValue( user.id, forKey : ResponseJSONKeys.id )
                for ( key, value ) in user.upsertJSON
                {
                    user.data.updateValue( value, forKey : key )
                }
                user.upsertJSON = [ String : Any? ]()
                user.isCreate = false
                response.setData( data : user )
                completion( .success( user, response ) )
            }
            catch{
                ZCRMLogger.logError( message : "\( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func updateUser( user : ZCRMUser, completion : @escaping( ZCRMResult.Response< APIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.USERS )
        setRequestMethod( requestMethod : .patch )
        setAPIVersion("v4")
        setUrlPath( urlPath : "\( URLPathConstants.users )/\( user.id )" )
        var reqBodyObj : [ String : [ [ String : Any? ] ] ] = [ String : [ [ String : Any? ] ] ]()
        var dataArray : [ [ String : Any? ] ] = [ [ String : Any? ] ]()
        dataArray.append(user.upsertJSON)
        reqBodyObj[ getJSONRootKey() ] = dataArray
        setRequestBody( requestBody : reqBodyObj )
        let request = APIRequest( handler : self )
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getAPIResponse { ( resultType ) in
            do{
                let response = try resultType.resolve()
                for ( key, value ) in user.upsertJSON
                {
                    user.data.updateValue( value, forKey : key )
                }
                user.upsertJSON = [ String : Any? ]()
                completion( .success( response ) )
            }
            catch{
                ZCRMLogger.logError( message : "\( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func deleteUser( userId : Int64, completion : @escaping( ZCRMResult.Response< APIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.USERS )
        setRequestMethod( requestMethod : .delete )
        setAPIVersion("v4")
        setUrlPath( urlPath : "\( URLPathConstants.users )/\( userId )" )
        let request = APIRequest( handler : self )
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getAPIResponse { ( resultType ) in
            do{
                let response = try resultType.resolve()
                completion( .success( response ) )
            }
            catch{
                ZCRMLogger.logError( message : "\( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func searchUsers(ofType :  ZCRMUser.Category?, criteria : String, page : Int?, perPage : Int?, completion : @escaping( ZCRMResult.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.USERS )
        setRequestMethod( requestMethod : .get )
        setAPIVersion("v4")
        setUrlPath( urlPath : "\( URLPathConstants.users )/\( URLPathConstants.search )" )
        addRequestParam( param : RequestParamKeys.criteria, value : criteria )
        if let type = ofType
        {
            addRequestParam( param : RequestParamKeys.type, value : type.rawValue )
        }
        if let page = page
        {
            addRequestParam( param : RequestParamKeys.page, value : String( page ) )
        }
        if let perPage = perPage
        {
            addRequestParam( param : RequestParamKeys.perPage, value : String( perPage ) )
        }
        let request : APIRequest = APIRequest(handler: self)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getBulkAPIResponse { ( resultType ) in
            do{
                let bulkResponse = try resultType.resolve()
                let responseJSON = bulkResponse.getResponseJSON()
                var userList : [ ZCRMUser ] = [ ZCRMUser ]()
                if responseJSON.isEmpty == false
                {
                    let userDetailsList : [ [ String : Any ] ] = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                    if userDetailsList.isEmpty == true
                    {
                        ZCRMLogger.logError(message: "\(ZCRMErrorCode.responseNil) : \(ZCRMErrorMessage.responseJSONNilMsg), \( APIConstants.DETAILS ) : -")
                        completion( .failure( ZCRMError.sdkError( code : ZCRMErrorCode.responseNil, message : ZCRMErrorMessage.responseJSONNilMsg, details : nil ) ) )
                        return
                    }
                    for userDetail in userDetailsList
                    {
                        let user : ZCRMUser = try self.getZCRMUser( userDict : userDetail )
                        userList.append( user )
                    }
                }
                bulkResponse.setData( data : userList )
                completion( .success( userList, bulkResponse ) )
            }
            catch{
                ZCRMLogger.logError( message : "\( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func getProfile( profileId : Int64, completion : @escaping( ZCRMResult.DataResponse< ZCRMProfile, APIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.PROFILES)
        setUrlPath(urlPath:  "\( URLPathConstants.settings )/\( URLPathConstants.profiles )/\(profileId)" )
        setRequestMethod(requestMethod: .get )
        let request : APIRequest = APIRequest(handler: self)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getAPIResponse { ( resultType ) in
            do{
                let response = try resultType.resolve()
                let responseJSON = response.getResponseJSON()
                let profileList : [ [ String : Any ] ] = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                let profile = try self.getZCRMProfile( profileDetails: profileList[ 0 ] )
                response.setData( data : profile )
                completion( .success( profile, response ) )
            }
            catch{
                ZCRMLogger.logError( message : "\( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func getRole( roleId : Int64, completion : @escaping( ZCRMResult.DataResponse< ZCRMRole, APIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.ROLES )
        setUrlPath(urlPath: "\( URLPathConstants.settings )/\( URLPathConstants.roles )/\(roleId)" )
        setRequestMethod(requestMethod: .get )
        let request : APIRequest = APIRequest(handler: self)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getAPIResponse { ( resultType ) in
            do{
                let response = try resultType.resolve()
                let responseJSON = response.getResponseJSON()
                let rolesList : [ [ String : Any ] ] = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                let role = try self.getZCRMRole( roleDetails : rolesList[ 0 ] )
                response.setData( data : role )
                completion( .success( role, response ) )
            }
            catch{
                ZCRMLogger.logError( message : "\( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func getCurrentUser( completion : @escaping( ZCRMResult.DataResponse< ZCRMUser, APIResponse > ) -> () )
    {
        setIsForceCacheable( true )
        self.getUser( userId : nil) { ( result ) in
            completion( result )
        }
    }
    
    internal func getAllActiveUsers( page : Int?, perPage : Int?, completion : @escaping( ZCRMResult.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        self.getUsers( ofType : .activeUsers, modifiedSince : nil, page : page, perPage : perPage) { ( result ) in
            completion( result )
        }
    }
    
    internal func getAllDeactiveUsers( page : Int?, perPage : Int?, completion : @escaping( ZCRMResult.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        self.getUsers( ofType : .deactiveUsers, modifiedSince : nil, page : page, perPage : perPage) { ( result ) in
            completion( result )
        }
    }
    
    internal func getAllActiveConfirmedUsers( page : Int?, perPage : Int?, completion : @escaping( ZCRMResult.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        self.getUsers( ofType: .activeConfirmedUsers, modifiedSince : nil, page : page, perPage : perPage) { ( result ) in
            completion( result )
        }
    }
    
    internal func getAllAdminUsers( page : Int?, perPage : Int?, completion : @escaping( ZCRMResult.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        self.getUsers( ofType: .adminUsers, modifiedSince : nil, page : page, perPage : perPage) { ( result ) in
            completion( result )
        }
    }
    
    internal func getAllActiveConfirmedAdmins( page : Int?, perPage : Int?, completion : @escaping( ZCRMResult.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        self.getUsers( ofType: .activeConfirmedAdmins, modifiedSince : nil, page : page, perPage : perPage) { ( result ) in
            completion( result )
        }
    }
    
    private func getZCRMUser(userDict : [String : Any]) throws -> ZCRMUser
    {
        let email = try userDict.getString( key : ResponseJSONKeys.email )
        let user = ZCRMUser( emailId : email )
        user.data.updateValue( email, forKey : ResponseJSONKeys.email )
        user.id = try userDict.getInt64( key : ResponseJSONKeys.id )
        user.data.updateValue( user.id, forKey : ResponseJSONKeys.id )
        user.name = try userDict.getString( key : ResponseJSONKeys.fullName )
        user.data.updateValue( user.name, forKey : ResponseJSONKeys.fullName )
        if userDict.hasValue( forKey : ResponseJSONKeys.signature )
        {
            user.signature = try userDict.getString(key: ResponseJSONKeys.signature)
        }
        if ( userDict.hasValue( forKey : ResponseJSONKeys.profile ) )
        {
            let profileObj : [ String : Any ] = try userDict.getDictionary( key : ResponseJSONKeys.profile )
            let profile = ZCRMProfileDelegate( id : try profileObj.getInt64( key : ResponseJSONKeys.id ), name : try profileObj.getString( key : ResponseJSONKeys.name ) )
            user.profile = profile
            user.data.updateValue( profile, forKey : ResponseJSONKeys.profile )
        }
        if ( userDict.hasValue( forKey : ResponseJSONKeys.role ) )
        {
            let roleObj : [ String : Any ] = try userDict.getDictionary( key : ResponseJSONKeys.role )
            let role  = ZCRMRoleDelegate( id : try roleObj.getInt64( key : ResponseJSONKeys.id ), name : try roleObj.getString( key : ResponseJSONKeys.name ) )
            user.role = role
            user.data.updateValue( role, forKey : ResponseJSONKeys.role )
        }
        if let lastName = userDict.optString( key : ResponseJSONKeys.lastName )
        {
            user.lastName = lastName
            user.data.updateValue( lastName, forKey : ResponseJSONKeys.lastName )
        }
        if let firstName = userDict.optString( key : ResponseJSONKeys.firstName )
        {
            user.firstName = firstName
            user.data.updateValue( firstName, forKey : ResponseJSONKeys.firstName )
        }
        if let mobile = userDict.optString( key : ResponseJSONKeys.mobile )
        {
            user.mobile = mobile
            user.data.updateValue( mobile, forKey : ResponseJSONKeys.mobile )
        }
        if let language = userDict.optString( key : ResponseJSONKeys.language )
        {
            user.language = language
            user.data.updateValue( language, forKey : ResponseJSONKeys.language )
        }
        user.status = try userDict.getString( key : ResponseJSONKeys.status )
        user.data.updateValue( user.status, forKey : ResponseJSONKeys.status )
        if let zuId = userDict.optInt64( key : ResponseJSONKeys.ZUID )
        {
            user.zuId = zuId
            user.data.updateValue( zuId, forKey : ResponseJSONKeys.ZUID )
        }
        if let alias = userDict.optString( key : ResponseJSONKeys.alias )
        {
            user.alias = userDict.optString( key : ResponseJSONKeys.alias )
            user.data.updateValue( alias, forKey : ResponseJSONKeys.alias )
        }
        if let city = userDict.optString( key : ResponseJSONKeys.city )
        {
            user.city = city
            user.data.updateValue( city, forKey : ResponseJSONKeys.city)
        }
        user.isConfirmed = try userDict.getBoolean( key : ResponseJSONKeys.confirm )
        user.data.updateValue( user.isConfirmed, forKey : ResponseJSONKeys.confirm )
        if let countryLocale = userDict.optString( key :  ResponseJSONKeys.countryLocale )
        {
            user.countryLocale = countryLocale
            user.data.updateValue( countryLocale, forKey : ResponseJSONKeys.countryLocale )
        }
        if let dateFormat = userDict.optString( key : ResponseJSONKeys.dateFormat )
        {
            user.dateFormat = dateFormat
            user.data.updateValue( dateFormat, forKey : ResponseJSONKeys.dateFormat )
        }
        if let dob = userDict.optString( key : ResponseJSONKeys.dob )
        {
            user.dateOfBirth = userDict.optString( key : ResponseJSONKeys.dob )
            user.data.updateValue( dob, forKey : ResponseJSONKeys.dob )
        }
        if let zip = userDict.optInt64( key : ResponseJSONKeys.zip )
        {
            user.zip = zip
            user.data.updateValue( zip, forKey : ResponseJSONKeys.zip )
        }
        if let timeFormat = userDict.optString( key : ResponseJSONKeys.timeFormat )
        {
            user.timeFormat = timeFormat
            user.data.updateValue( timeFormat, forKey : ResponseJSONKeys.timeFormat )
        }
        if let country = userDict.optString( key : ResponseJSONKeys.country )
        {
            user.country = country
            user.data.updateValue( country, forKey : ResponseJSONKeys.country )
        }
        if let fax = userDict.optString( key : ResponseJSONKeys.fax )
        {
            user.fax = fax
            user.data.updateValue( fax, forKey : ResponseJSONKeys.fax )
        }
        if let locale = userDict.optString( key : ResponseJSONKeys.locale )
        {
            user.locale = locale
            user.data.updateValue( locale, forKey : ResponseJSONKeys.locale )
        }
        if let nameFormat = userDict.optString( key : ResponseJSONKeys.nameFormat )
        {
            user.nameFormat = nameFormat
            user.data.updateValue( nameFormat, forKey : ResponseJSONKeys.nameFormat )
        }
        if let phone = userDict.optString( key : ResponseJSONKeys.phone )
        {
            user.phone = phone
            user.data.updateValue( phone, forKey : ResponseJSONKeys.phone )
        }
        if let website = userDict.optString( key : ResponseJSONKeys.website )
        {
            user.website = website
            user.data.updateValue( website, forKey : ResponseJSONKeys.website )
        }
        if let street = userDict.optString( key : ResponseJSONKeys.street )
        {
            user.street = street
            user.data.updateValue( street, forKey : ResponseJSONKeys.street )
        }
        if let timeZone = userDict.optString( key : ResponseJSONKeys.timeZone )
        {
            user.timeZone = timeZone
            user.data.updateValue( timeZone, forKey : ResponseJSONKeys.timeZone )
        }
        if let state = userDict.optString( key : ResponseJSONKeys.state )
        {
            user.state = state
            user.data.updateValue( state, forKey : ResponseJSONKeys.state )
        }
        if( userDict.hasValue( forKey : ResponseJSONKeys.createdBy ) )
        {
            let createdByObj : [ String :Any ] = try userDict.getDictionary( key : ResponseJSONKeys.createdBy )
            user.createdBy = try getUserDelegate( userJSON : createdByObj )
            user.data.updateValue( user.createdBy, forKey : ResponseJSONKeys.createdBy )
            user.createdTime = try userDict.getString( key : ResponseJSONKeys.createdTime )
            user.data.updateValue( user.createdTime, forKey : ResponseJSONKeys.createdTime )
        }
        if( userDict.hasValue( forKey : ResponseJSONKeys.ModifiedBy ) )
        {
            let modifiedByObj : [ String : Any ] = try userDict.getDictionary( key : ResponseJSONKeys.ModifiedBy )
            user.modifiedBy = try getUserDelegate( userJSON : modifiedByObj )
            user.data.updateValue( user.modifiedBy, forKey : ResponseJSONKeys.ModifiedBy )
            user.modifiedTime = try userDict.getString( key : ResponseJSONKeys.ModifiedTime )
            user.data.updateValue( user.modifiedTime, forKey : ResponseJSONKeys.ModifiedTime )
        }
        if ( userDict.hasValue( forKey : ResponseJSONKeys.ReportingTo ) )
        {
            let reportingObj : [ String : Any ] = try userDict.getDictionary( key : ResponseJSONKeys.ReportingTo )
            user.reportingTo = try getUserDelegate( userJSON : reportingObj )
            user.data.updateValue( user.reportingTo, forKey : ResponseJSONKeys.ReportingTo )
        }
        if ( userDict.hasValue(forKey: ResponseJSONKeys.sortOrderPreference) )
        {
            user.sortOrderPreference = try userDict.getString(key: ResponseJSONKeys.sortOrderPreference )
        }
        user.isCreate = false
        return user
    }
    
    private func getZCRMRole( roleDetails : [ String : Any ] ) throws -> ZCRMRole
    {
        let role = ZCRMRole( name : try roleDetails.getString( key : ResponseJSONKeys.name ) )
        role.id = try roleDetails.getInt64( key : ResponseJSONKeys.id )
        role.label = try roleDetails.getString( key : ResponseJSONKeys.displayLabel )
        role.isAdminUser = try roleDetails.getBoolean( key : ResponseJSONKeys.adminUser )
        if ( roleDetails.hasValue(forKey: ResponseJSONKeys.reportingTo) )
        {
            let reportingToObj : [ String : Any ] = try roleDetails.getDictionary( key : ResponseJSONKeys.reportingTo )
            role.reportingTo = ZCRMRoleDelegate( id : try reportingToObj.getInt64( key : ResponseJSONKeys.id ), name : try reportingToObj.getString( key : ResponseJSONKeys.name ) )
        }
        return role
    }
    
    private func getZCRMProfile( profileDetails : [ String : Any ] ) throws -> ZCRMProfile
    {
        let profile = ZCRMProfile( name : try profileDetails.getString( key : ResponseJSONKeys.name ) )
        profile.id = try profileDetails.getInt64( key : ResponseJSONKeys.id )
        profile.category = try profileDetails.optBoolean( key : ResponseJSONKeys.category ) ?? profileDetails.getBoolean(key: ResponseJSONKeys.custom)
        profile.displayName = try profileDetails.getString(key: ResponseJSONKeys.displayLabel)
        if ( profileDetails.hasValue( forKey : ResponseJSONKeys.description ) )
        {
            profile.description = try profileDetails.getString( key : ResponseJSONKeys.description )
        }
        if ( profileDetails.hasValue( forKey : ResponseJSONKeys.modifiedBy ) )
        {
            let modifiedUserObj : [ String : Any ] = try profileDetails.getDictionary( key : ResponseJSONKeys.modifiedBy )
            profile.modifiedBy = try getUserDelegate(userJSON : modifiedUserObj)
            profile.modifiedTime = try profileDetails.getString( key : ResponseJSONKeys.modifiedTime )
        }
        if ( profileDetails.hasValue( forKey : ResponseJSONKeys.createdBy ) )
        {
            let createdUserObj : [ String : Any ] = try profileDetails.getDictionary( key : ResponseJSONKeys.createdBy )
            profile.createdBy = try getUserDelegate(userJSON : createdUserObj)
            profile.createdTime = try profileDetails.getString( key : ResponseJSONKeys.createdTime )
        }
        var profilePermissionDetails : [ Int64 : ZCRMProfile.Permission ] = [:]
        if profileDetails.hasValue(forKey: ResponseJSONKeys.permissionsDetails)
        {
            profilePermissionDetails = try getPermissionsDetails(fromArray: profileDetails.getArrayOfDictionaries(key: ResponseJSONKeys.permissionsDetails) )
        }
        if profileDetails.hasValue(forKey: ResponseJSONKeys.sections)
        {
            profile.permissionSections = try getPermissionSectionsDetails(fromArray: profileDetails.getArrayOfDictionaries(key: ResponseJSONKeys.sections), profilePermissionDetails)
        }
        return profile
    }
    
    private func getPermissionsDetails( fromArray permissionDetails : [ [ String : Any ] ] ) throws -> [ Int64 : ZCRMProfile.Permission ]
    {
        var permissions : [ Int64 : ZCRMProfile.Permission ] = [:]
        for permission in permissionDetails
        {
            let displayName = try permission.getString(key: ResponseJSONKeys.displayLabel)
            let name = try permission.getString(key: ResponseJSONKeys.name)
            let isEnabled = try permission.getBoolean(key: ResponseJSONKeys.enabled)
            let moduleAPIName = permission.optString(key: ResponseJSONKeys.module)
            var permissionDetail = ZCRMProfile.Permission(displayName: displayName, name: name, isEnabled: isEnabled, moduleAPIName: moduleAPIName)
            permissionDetail.id = permission.optInt64(key: ResponseJSONKeys.id)
            if let permissionDetailId = permissionDetail.id
            {
                permissions.updateValue( permissionDetail, forKey: permissionDetailId)
            }
        }
        return permissions
    }
    
    private func getPermissionSectionsDetails( fromArray sectionDetails : [[ String : Any ]], _ profilePermissions : [ Int64 : ZCRMProfile.Permission ]) throws -> [ ZCRMProfile.PermissionSection ]
    {
        var sections : [ ZCRMProfile.PermissionSection ] = []
        for section in sectionDetails
        {
            let name = try section.getString(key: ResponseJSONKeys.name)
            var categoryDetails : [ ZCRMProfile.PermissionSection.Category ] = []
            let categories = try section.getArrayOfDictionaries(key: ResponseJSONKeys.categories)
            for categoryJSON in categories
            {
                let name = try categoryJSON.getString(key: ResponseJSONKeys.name)
                let displayName = try categoryJSON.getString(key: ResponseJSONKeys.displayLabel)
                let permissionDetails = try categoryJSON.getArray(key: ResponseJSONKeys.permissionsDetails)
                var permissionIds : [ Int64 ] = []
                if !permissionDetails.isEmpty
                {
                    guard let permissions = permissionDetails as? [ String ] else
                    {
                        ZCRMLogger.logError(message: "\(ZCRMErrorCode.typeCastError) : Section.Category.permissionsDetails - Expected type -> ARRAY< Int64 >, \( APIConstants.DETAILS ) : -")
                        throw ZCRMError.processingError( code : ZCRMErrorCode.typeCastError, message : "Section.Category.permissionsDetails - Expected type -> ARRAY< Int64 >", details : nil )
                    }
                    let permissionIdsArray : [ Int64 ] = permissions.compactMap( { Int64( $0 ) } )
                    if permissionIdsArray.count != permissions.count
                    {
                        ZCRMLogger.logError(message: "\(ZCRMErrorCode.typeCastError) : Section.Category.permissionsDetails - Expected type -> Int64, \( APIConstants.DETAILS ) : -")
                        throw ZCRMError.processingError( code : ZCRMErrorCode.typeCastError, message : "Section.Category.permissionsDetails - Expected type -> Int64", details : nil )
                    }
                    permissionIds = permissionIdsArray
                }
                
                let moduleAPIName = categoryJSON.optString(key: ResponseJSONKeys.module)
                let permissionsDetails : [ ZCRMProfile.Permission ] = try permissionIds.map( {
                    do
                    {
                        return try profilePermissions.getValue(key: $0)
                    }
                    catch
                    {
                        throw error
                    }
                } )
                categoryDetails.append( ZCRMProfile.PermissionSection.Category(displayName: displayName, permissions: permissionsDetails, name: name, moduleAPIName: moduleAPIName) )
            }
            sections.append( ZCRMProfile.PermissionSection(name: name, categories: categoryDetails) )
        }
        return sections
    }
}

internal extension UserAPIHandler
{
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
        static let dateFormat = "date_format"
        static let dob = "dob"
        static let country = "country"
        static let fax = "fax"
        static let locale = "locale"
        static let nameFormat = "name_format__s"
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
        static let sortOrderPreference = "sort_order_preference__s"
        
        static let displayLabel = "display_label"
        static let adminUser = "admin_user"
        static let reportingTo = "reporting_to"
        
        static let category = "category"
        static let custom = "custom"
        static let description = "description"
        static let modifiedBy = "modified_by"
        static let createdBy = "created_by"
        static let modifiedTime = "modified_time"
        static let createdTime = "created_time"
        
        static let zip = "zip"
        static let timeFormat = "time_format"
        
        static let permissionsDetails = "permissions_details"
        static let sections = "sections"
        static let module = "module"
        static let enabled = "enabled"
        static let categories = "categories"
        static let signature = "signature"
    }
    
    struct URLPathConstants {
        static let users = "users"
        static let user = "user"
        static let settings = "settings"
        static let profiles = "profiles"
        static let roles = "roles"
        static let search = "search"
        static let features = "features"
        static let __internal = "__internal"
    }
}

extension RequestParamKeys
{
    static let currentUser = "CurrentUser"
}
