//
//  UserAPIHandler.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 08/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

internal class UserAPIHandler : CommonAPIHandler
{
    let cache : CacheFlavour
    private var userDelegate : ZCRMUserDelegate?
    
    internal init( userDelegate : ZCRMUserDelegate )
    {
        self.cache = CacheFlavour.noCache
        self.userDelegate = userDelegate
    }
    
    internal init( userDelegate : ZCRMUserDelegate, cacheFlavour : CacheFlavour )
    {
        self.cache = cacheFlavour
        self.userDelegate = userDelegate
    }
    
    internal init( cacheFlavour : CacheFlavour )
    {
        self.cache = cacheFlavour
    }
    
    internal override init()
    {
        self.cache = CacheFlavour.noCache
    }
    
    internal func getUsers( ofType : UserTypes?, modifiedSince : String?, page : Int?, perPage : Int?, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.USERS )
        var allUsers : [ZCRMUser] = [ZCRMUser]()
        setUrlPath(urlPath: "\( URLPathConstants.users )" )
        setRequestMethod(requestMethod: .get )
        if let type = ofType
        {
            addRequestParam(param: RequestParamKeys.type , value: type.rawValue )
        }
        if ( modifiedSince.notNilandEmpty)
        {
            addRequestHeader(header: RequestParamKeys.ifModifiedSince , value: modifiedSince! )
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
                        ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.responseNil) : \(ErrorMessage.responseJSONNilMsg), \( APIConstants.DETAILS ) : -")
                        completion( .failure( ZCRMError.sdkError( code : ErrorCode.responseNil, message : ErrorMessage.responseJSONNilMsg, details : nil ) ) )
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
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func getAllProfiles( completion : @escaping( Result.DataResponse< [ ZCRMProfile ], BulkAPIResponse > ) -> () )
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
                        ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.responseNil) : \(ErrorMessage.responseJSONNilMsg), \( APIConstants.DETAILS ) : -")
                        completion( .failure( ZCRMError.sdkError( code : ErrorCode.responseNil, message : ErrorMessage.responseJSONNilMsg, details : nil ) ) )
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
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func getAllRoles( completion : @escaping( Result.DataResponse< [ ZCRMRole ], BulkAPIResponse > ) -> () )
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
                        ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.responseNil) : \(ErrorMessage.responseJSONNilMsg), \( APIConstants.DETAILS ) : -")
                        completion( .failure( ZCRMError.sdkError( code : ErrorCode.responseNil, message : ErrorMessage.responseJSONNilMsg, details : nil ) ) )
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
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func getUser( userId : Int64?, completion : @escaping( Result.DataResponse< ZCRMUser, APIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.USERS )
        setRequestMethod(requestMethod: .get )
        if let userId = userId
        {
            setUrlPath(urlPath: "\( URLPathConstants.users )/\(userId)" )
        }
        else
        {
            setUrlPath(urlPath: "\( URLPathConstants.users )" )
            addRequestParam(param: RequestParamKeys.type , value:  RequestParamKeys.currentUser)
        }
        let request : APIRequest = APIRequest(handler: self, cacheFlavour: self.cache)
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
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func addUser( user : ZCRMUser, completion : @escaping( Result.DataResponse< ZCRMUser, APIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.USERS )
        setRequestMethod( requestMethod : .post )
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
                response.setData( data : user )
                completion( .success( user, response ) )
            }
            catch{
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func updateUser( user : ZCRMUser, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.USERS )
        setRequestMethod( requestMethod : .patch )
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
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func deleteUser( userId : Int64, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.USERS )
        setRequestMethod( requestMethod : .delete )
        setUrlPath( urlPath : "\( URLPathConstants.users )/\( userId )" )
        let request = APIRequest( handler : self )
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getAPIResponse { ( resultType ) in
            do{
                let response = try resultType.resolve()
                completion( .success( response ) )
            }
            catch{
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func searchUsers(ofType : UserTypes?, criteria : String, page : Int?, perPage : Int?, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.USERS )
        setRequestMethod( requestMethod : .get )
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
                        ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.responseNil) : \(ErrorMessage.responseJSONNilMsg), \( APIConstants.DETAILS ) : -")
                        completion( .failure( ZCRMError.sdkError( code : ErrorCode.responseNil, message : ErrorMessage.responseJSONNilMsg, details : nil ) ) )
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
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func getProfile( profileId : Int64, completion : @escaping( Result.DataResponse< ZCRMProfile, APIResponse > ) -> () )
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
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func getRole( roleId : Int64, completion : @escaping( Result.DataResponse< ZCRMRole, APIResponse > ) -> () )
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
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func downloadPhoto( size : PhotoSize?, completion : @escaping( Result.Response< FileAPIResponse > ) -> () )
    {
        if let userDelegate = self.userDelegate
        {
            setJSONRootKey( key : JSONRootKey.NIL )
            setUrlPath(urlPath: "\( URLPathConstants.users )/\(userDelegate.id)/\( URLPathConstants.photo )")
            setRequestMethod(requestMethod: .get)
            if let photoSize = size
            {
                addRequestParam(param: RequestParamKeys.photoSize , value: photoSize.rawValue )
            }
            let request : FileAPIRequest = FileAPIRequest(handler: self)
            ZCRMLogger.logDebug(message: "Request : \(request.toString())")
            
            request.downloadFile { ( resultType ) in
                do
                {
                    let response = try resultType.resolve()
                    completion( .success( response ) )
                }
                catch
                {
                    ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
        }
        else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : USER ID must not be nil, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code : ErrorCode.mandatoryNotFound, message : "USER ID must not be nil", details : nil ) ) )
        }
    }
    
    internal func downloadPhoto( size : PhotoSize?, fileDownloadDelegate : ZCRMFileDownloadDelegate ) throws
    {
        if let userDelegate = self.userDelegate
        {
            setJSONRootKey( key : JSONRootKey.NIL )
            setUrlPath(urlPath: "\( URLPathConstants.users )/\(userDelegate.id)/\( URLPathConstants.photo )")
            setRequestMethod(requestMethod: .get)
            if let photoSize = size
            {
                addRequestParam(param: RequestParamKeys.photoSize , value: photoSize.rawValue )
            }
            let request : FileAPIRequest = FileAPIRequest(handler: self, fileDownloadDelegate: fileDownloadDelegate, "\( userDelegate.id )")
            ZCRMLogger.logDebug(message: "Request : \(request.toString())")
            request.downloadFile()
        }
        else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : USER ID must not be nil, \( APIConstants.DETAILS ) : -")
            throw ZCRMError.processingError( code : ErrorCode.mandatoryNotFound, message : "USER ID must not be nil", details : nil )
        }
    }
    
    internal func uploadPhoto( filePath : String?, fileName : String?, fileData : Data?, completion : @escaping(  Result.Response< APIResponse > ) -> () )
    {
        if let userDelegate = self.userDelegate
        {
            do
            {
                try fileDetailCheck( filePath : filePath, fileData : fileData, maxFileSize: MaxFileSize.profilePhoto )
                try imageTypeValidation( filePath )
            }
            catch
            {
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
                return
            }
            setJSONRootKey( key : JSONRootKey.NIL )
            setUrlPath(urlPath: "\( URLPathConstants.users )/\(userDelegate.id)/\( URLPathConstants.photo )")
            setRequestMethod(requestMethod: .post)
            let request : FileAPIRequest = FileAPIRequest(handler: self)
            ZCRMLogger.logDebug(message: "Request : \(request.toString())")
            
            if let filePath = filePath
            {
                request.uploadFile( filePath : filePath, entity : nil ) { ( resultType ) in
                    do
                    {
                        let response = try resultType.resolve()
                        completion( .success( response ) )
                    }
                    catch
                    {
                        ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                        completion( .failure( typeCastToZCRMError( error ) ) )
                    }
                }
            }
            else if let fileName = fileName, let fileData = fileData
            {
                request.uploadFile( fileName : fileName, entity : nil, fileData : fileData ){ ( resultType ) in
                    do
                    {
                        let response = try resultType.resolve()
                        completion( .success( response ) )
                    }
                    catch
                    {
                        ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                        completion( .failure( typeCastToZCRMError( error ) ) )
                    }
                }
            }
        }
        else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : USER ID must not be nil, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code : ErrorCode.mandatoryNotFound, message : "USER ID must not be nil", details : nil ) ) )
        }
    }
    
    internal func uploadPhoto(fileRefId : String, filePath : String?, fileName : String?, fileData : Data?, fileUploadDelegate : ZCRMFileUploadDelegate )
    {
        if let userDelegate = self.userDelegate
        {
            do
            {
                try fileDetailCheck( filePath : filePath, fileData : fileData, maxFileSize: MaxFileSize.profilePhoto )
                try imageTypeValidation( filePath )
            }
            catch
            {
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                fileUploadDelegate.didFail( fileRefId : fileRefId, typeCastToZCRMError( error ) )
                return
            }
            setJSONRootKey( key : JSONRootKey.NIL )
            setUrlPath(urlPath: "\( URLPathConstants.users )/\(userDelegate.id)/\( URLPathConstants.photo )")
            setRequestMethod(requestMethod: .post)
            let request : FileAPIRequest = FileAPIRequest( handler : self, fileUploadDelegate : fileUploadDelegate , fileRefId: fileRefId)
            ZCRMLogger.logDebug(message: "Request : \(request.toString())")
            
            request.uploadFile(fileRefId: fileRefId, filePath: filePath, fileName: fileName, fileData: fileData, entity: nil) { _,_ in }
        }
        else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : USER ID must not be nil, \( APIConstants.DETAILS ) : -")
            fileUploadDelegate.didFail( fileRefId : fileRefId, ZCRMError.processingError( code : ErrorCode.mandatoryNotFound, message : "USER ID must not be nil", details : nil ) )
        }
    }

    internal func getCurrentUser( completion : @escaping( Result.DataResponse< ZCRMUser, APIResponse > ) -> () )
    {
        setIsCacheable(true)
        self.getUser( userId : nil) { ( result ) in
            completion( result )
        }
    }
    
    internal func getAllUsers( modifiedSince : String?, page : Int?, perPage : Int?, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        self.getUsers( ofType: nil, modifiedSince : modifiedSince, page : page, perPage : perPage) { ( result ) in
            completion( result )
        }
    }
    
    internal func getAllActiveUsers( page : Int?, perPage : Int?, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        self.getUsers( ofType : .activeUsers, modifiedSince : nil, page : page, perPage : perPage) { ( result ) in
            completion( result )
        }
    }
    
    internal func getAllDeactiveUsers( page : Int?, perPage : Int?, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        self.getUsers( ofType : .deactiveUsers, modifiedSince : nil, page : page, perPage : perPage) { ( result ) in
            completion( result )
        }
    }
    
    internal func getAllUnConfirmedUsers( page : Int?, perPage : Int?, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        self.getUsers( ofType : .notConfirmedUsers, modifiedSince : nil, page : page, perPage : perPage) { ( result ) in
            completion( result )
        }
    }
    
    internal func getAllConfirmedUsers( page : Int?, perPage : Int?, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        self.getUsers( ofType : .confirmedUsers, modifiedSince : nil, page : page, perPage : perPage) { ( result ) in
            completion( result )
        }
    }

    internal func getAllActiveConfirmedUsers( page : Int?, perPage : Int?, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        self.getUsers( ofType: .activeConfirmedUsers, modifiedSince : nil, page : page, perPage : perPage) { ( result ) in
            completion( result )
        }
    }
    
    internal func getAllDeletedUsers( page : Int?, perPage : Int?, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        self.getUsers( ofType: .deletedUsers, modifiedSince : nil, page : page, perPage : perPage) { ( result ) in
            completion( result )
        }
    }
    
    internal func getAllAdminUsers( page : Int?, perPage : Int?, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
    {
        self.getUsers( ofType: .adminUsers, modifiedSince : nil, page : page, perPage : perPage) { ( result ) in
            completion( result )
        }
    }
    
    internal func getAllActiveConfirmedAdmins( page : Int?, perPage : Int?, completion : @escaping( Result.DataResponse< [ ZCRMUser ], BulkAPIResponse > ) -> () )
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
        profile.category = try profileDetails.getBoolean( key : ResponseJSONKeys.category )
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
        return profile
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
    
    struct URLPathConstants {
        static let users = "users"
        static let settings = "settings"
        static let profiles = "profiles"
        static let roles = "roles"
        static let photo = "photo"
        static let search = "search"
        static let features = "features"
        static let __internal = "__internal"
    }
}

extension RequestParamKeys
{
    static let currentUser = "CurrentUser"
    static let photoSize = "photo_size"
}
