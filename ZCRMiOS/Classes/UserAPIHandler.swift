//
//  UserAPIHandler.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 08/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

internal class UserAPIHandler : CommonAPIHandler
{
    private func getUsers(type : String?, modifiedSince : String?, page : Int, perPage : Int, completion : @escaping( [ ZCRMUser ]?, BulkAPIResponse?, Error? ) -> () )
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
        request.getBulkAPIResponse { ( response, err ) in
            if let error = err
            {
                completion( nil, nil, error )
                return
            }
            if let bulkResponse = response
            {
                let responseJSON = bulkResponse.getResponseJSON()
                if responseJSON.isEmpty == false
                {
                    let usersList:[[String:Any]] = responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                    for user in usersList
                    {
                        allUsers.append(self.getZCRMUser(userDict: user))
                    }
                }
                bulkResponse.setData(data: allUsers)
                completion( allUsers, bulkResponse, nil )
            }
        }
    }
    
    internal func getAllProfiles( completion : @escaping( [ ZCRMProfile ]?, BulkAPIResponse?, Error? ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.PROFILES )
        var allProfiles : [ ZCRMProfile ] = [ ZCRMProfile ] ()
		setUrlPath(urlPath: "/settings/profiles" )
		setRequestMethod(requestMethod: .GET)
		let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
        request.getBulkAPIResponse { ( response, err ) in
            if let error = err
            {
                completion( nil, nil, error )
                return
            }
            if let bulkResponse = response
            {
                let responseJSON = bulkResponse.getResponseJSON()
                if responseJSON.isEmpty == false
                {
                    let profileList : [ [ String : Any ] ] = responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                    for profile in profileList
                    {
                        allProfiles.append( self.getZCRMProfile( profileDetails : profile ) )
                    }
                }
                bulkResponse.setData( data : allProfiles)
                completion( allProfiles, bulkResponse, nil )
            }
        }
    }
    
    internal func getAllRoles( completion : @escaping( [ ZCRMRole ]?, BulkAPIResponse?, Error? ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.ROLES )
        var allRoles : [ ZCRMRole ] = [ ZCRMRole ]()
		setUrlPath(urlPath:  "/settings/roles" )
		setRequestMethod(requestMethod: .GET)
		let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
        request.getBulkAPIResponse { ( response, err ) in
            if let error = err
            {
                completion( nil, nil, error )
                return
            }
            if let bulkResponse = response
            {
                let responseJSON = bulkResponse.getResponseJSON()
                if responseJSON.isEmpty == false
                {
                    let rolesList : [ [ String : Any ] ] = responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                    for role in rolesList
                    {
                        allRoles.append( self.getZCRMRole( roleDetails : role ) )
                    }
                }
                bulkResponse.setData( data : allRoles )
                completion( allRoles, bulkResponse, nil )
            }
        }
    }
    
    internal func getUser( userId : Int64?, completion : @escaping( ZCRMUser?, APIResponse?, Error? ) -> () )
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
        request.getAPIResponse { ( resp, err ) in
            if let error = err
            {
                completion( nil, nil, error )
                return
            }
            if let response = resp
            {
                let responseJSON = response.getResponseJSON()
                let usersList:[[String : Any]] = responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                let user = self.getZCRMUser(userDict: usersList[0])
                response.setData(data: user )
                completion( user, response, nil )
            }
        }
    }
    
    internal func addUser( user : ZCRMUser, completion : @escaping( ZCRMUser?, APIResponse?, Error? ) -> () )
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
        request.getAPIResponse { ( resp, err ) in
            if let error = err
            {
                completion( nil, nil, error )
                return
            }
            if let response = resp
            {
                let responseJSONArray  = response.getResponseJSON().getArrayOfDictionaries( key : self.getJSONRootKey() )
                let responseJSONData = responseJSONArray[ 0 ]
                let responseDetails : [ String : Any ] = responseJSONData[ DETAILS ] as! [ String : Any ]
                user.setId( id : Int64( responseDetails[ "id" ] as! String )! )
                response.setData( data : user )
                completion( user, response, nil )
            }
        }
    }
    
    internal func updateUser( user : ZCRMUser, completion : @escaping( APIResponse?, Error? ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.USERS )
        setRequestMethod( requestMethod : .PUT )
        setUrlPath( urlPath : "/users/\( user.getId()! )" )
        var reqBodyObj : [ String : [ [ String : Any ] ] ] = [ String : [ [ String : Any ] ] ]()
        var dataArray : [ [ String : Any ] ] = [ [ String : Any ] ]()
        dataArray.append( self.getZCRMUserAsJSON( user : user ) )
        reqBodyObj[ getJSONRootKey() ] = dataArray
        setRequestBody( requestBody : reqBodyObj )
        let request = APIRequest( handler : self )
        print( "Request : \( request.toString() )" )
        request.getAPIResponse { ( response, error ) in
            completion( response, error )
        }
    }
    
    internal func deleteUser( userId : Int64, completion : @escaping( APIResponse?, Error? ) -> () )
    {
        setRequestMethod( requestMethod : .DELETE )
        setUrlPath( urlPath : "/users/\( userId )" )
        let request = APIRequest( handler : self )
        request.getAPIResponse { ( response, error ) in
            completion( response, error )
        }
    }
    
    internal func searchUsers( criteria : String, page : Int, perPage : Int, completion : @escaping( [ ZCRMUser ]?, BulkAPIResponse?, Error? ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.USERS )
        setRequestMethod( requestMethod : .PUT )
        setUrlPath( urlPath : "/users" )
        addRequestParam( param : RequestParamKeys.filters, value : criteria )
        addRequestParam( param : "page", value : String( page ) )
        addRequestParam( param : "per_page", value : String( perPage ) )
        APIRequest( handler : self ).getBulkAPIResponse { ( response, err ) in
            if let error = err
            {
                completion( nil, nil, error )
                return
            }
            if let bulkResponse = response
            {
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
                }
                bulkResponse.setData( data : userList )
                completion( userList, bulkResponse, nil )
            }
        }
    }
    
    internal func getProfile( profileId : Int64, completion : @escaping( ZCRMProfile?, APIResponse?, Error? ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.PROFILES)
		setUrlPath(urlPath:  "/settings/profiles/\(profileId)" )
		setRequestMethod(requestMethod: .GET )
		let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
        request.getAPIResponse { ( resp, err ) in
            if let error = err
            {
                completion( nil, nil, error )
                return
            }
            if let response = resp
            {
                let responseJSON = response.getResponseJSON()
                let profileList : [ [ String : Any ] ] = responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                let profile = self.getZCRMProfile( profileDetails: profileList[ 0 ] )
                response.setData( data : profile )
                completion( profile, response, nil )
            }
        }
    }
    
    internal func getRole( roleId : Int64, completion : @escaping( ZCRMRole?, APIResponse?, Error? ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.ROLES )
		setUrlPath(urlPath: "/settings/roles/\(roleId)" )
		setRequestMethod(requestMethod: .GET )
		let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
        request.getAPIResponse { ( resp, err ) in
            if let error = err
            {
                completion( nil, nil, error )
                return
            }
            if let response = resp
            {
                let responseJSON = response.getResponseJSON()
                let rolesList : [ [ String : Any ] ] = responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                let role = self.getZCRMRole( roleDetails : rolesList[ 0 ] )
                response.setData( data : role )
                completion( role, response, nil )
            }
        }
    }
    
    internal func downloadPhoto( size : PhotoSize, completion : @escaping( FileAPIResponse?, Error? ) -> () )
    {
		setUrl(url: PHOTOURL )
		setRequestMethod(requestMethod: .GET )
		addRequestParam(param: RequestParamKeys.photoSize , value: size.rawValue )
		let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
        request.downloadFile { ( response, error ) in
            completion( response, error )
        }
    }
    
    internal func getCurrentUser( completion : @escaping( ZCRMUser?, APIResponse?, Error? ) -> () )
    {
        self.getUser( userId : nil) { ( user, response, error ) in
            completion( user, response, error )
        }
    }
    
    internal func getAllUsers( modifiedSince : String?, page : Int, perPage : Int, completion : @escaping( [ ZCRMUser ]?, BulkAPIResponse?, Error? ) -> () )
    {
        self.getUsers( type: nil, modifiedSince : modifiedSince, page : page, perPage : perPage) { ( users, response, error ) in
            completion( users, response, error )
        }
    }
    
    internal func getAllActiveUsers( page : Int, perPage : Int, completion : @escaping( [ ZCRMUser ]?, BulkAPIResponse?, Error? ) -> () )
    {
        self.getUsers( type : RequestParamValues.activeUsers, modifiedSince : nil, page : page, perPage : perPage) { ( users, response, error ) in
            completion( users, response, error )
        }
    }
    
    internal func getAllDeactiveUsers( page : Int, perPage : Int, completion : @escaping( [ ZCRMUser ]?, BulkAPIResponse?, Error? ) -> () )
    {
        self.getUsers( type : RequestParamValues.deactiveUsers, modifiedSince : nil, page : page, perPage : perPage) { ( users, response, error ) in
            completion( users, response, error )
        }
    }
    
    internal func getAllUnConfirmedUsers( page : Int, perPage : Int, completion : @escaping( [ ZCRMUser ]?, BulkAPIResponse?, Error? ) -> () )
    {
        self.getUsers( type : RequestParamValues.notConfirmedUsers, modifiedSince : nil, page : page, perPage : perPage) { ( users, response, error ) in
            completion( users, response, error )
        }
    }
    
    internal func getAllConfirmedUsers( page : Int, perPage : Int, completion : @escaping( [ ZCRMUser ]?, BulkAPIResponse?, Error? ) -> () )
    {
        self.getUsers( type : RequestParamValues.confirmedUsers, modifiedSince : nil, page : page, perPage : perPage) { ( users, response, error ) in
            completion( users, response, error )
        }
    }

    internal func getAllActiveConfirmedUsers( page : Int, perPage : Int, completion : @escaping( [ ZCRMUser ]?, BulkAPIResponse?, Error? ) -> () )
    {
        self.getUsers( type: RequestParamValues.activeConfirmedUsers, modifiedSince : nil, page : page, perPage : perPage) { ( users, response, error ) in
            completion( users, response, error )
        }
    }
    
    internal func getAllDeletedUsers( page : Int, perPage : Int, completion : @escaping( [ ZCRMUser ]?, BulkAPIResponse?, Error? ) -> () )
    {
        self.getUsers( type: RequestParamValues.deletedUsers, modifiedSince : nil, page : page, perPage : perPage) { ( users, response, error ) in
            completion( users, response, error )
        }
    }
    
    internal func getAllAdminUsers( page : Int, perPage : Int, completion : @escaping( [ ZCRMUser ]?, BulkAPIResponse?, Error? ) -> () )
    {
        self.getUsers( type: RequestParamValues.adminUsers, modifiedSince : nil, page : page, perPage : perPage) { ( users, response, error ) in
            completion( users, response, error )
        }
    }
    
    internal func getAllActiveConfirmedAdmins( page : Int, perPage : Int, completion : @escaping( [ ZCRMUser ]?, BulkAPIResponse?, Error? ) -> () )
    {
        self.getUsers( type: RequestParamValues.activeConfirmedAdmins, modifiedSince : nil, page : page, perPage : perPage) { ( users, response, error ) in
            completion( users, response, error )
        }
    }
	
	private func getZCRMUser(userDict : [String : Any]) -> ZCRMUser
	{
        let fullName : String = userDict.getString( key : ResponseParamKeys.fullName )
        let userId : Int64? = userDict.getInt64( key : ResponseParamKeys.id )
        let user = ZCRMUser(userId : userId!, userFullName : fullName)
        user.setFirstName(fName: userDict.optString(key: ResponseParamKeys.firstName))
        user.setLastName(lName: userDict.getString(key: ResponseParamKeys.lastName))
        user.setEmailId(email: userDict.getString(key: ResponseParamKeys.email))//
        user.setMobile(mobile: userDict.optString(key: ResponseParamKeys.mobile))
        user.setLanguage(language: userDict.optString(key: ResponseParamKeys.language))
        user.setStatus(status: userDict.optString(key: ResponseParamKeys.status))
        user.setZuId(zuId: userDict.optInt64(key: ResponseParamKeys.ZUID))
        if ( userDict.hasValue( forKey : ResponseParamKeys.profile ) )
        {
            let profileObj : [String : Any] = userDict.getDictionary(key: ResponseParamKeys.profile)
            let profile : ZCRMProfile = ZCRMProfile(profileId : profileObj.getInt64( key : ResponseParamKeys.id ), profileName : profileObj.getString( key : ResponseParamKeys.name ) )
            user.setProfile(profile: profile)
        }
        if ( userDict.hasValue( forKey : ResponseParamKeys.role ) )
        {
            let roleObj : [String : Any] = userDict.getDictionary(key: ResponseParamKeys.role)
            let role : ZCRMRole = ZCRMRole( roleId : roleObj.getInt64( key : ResponseParamKeys.id ), roleName : roleObj.getString( key : ResponseParamKeys.name ) )
            user.setRole( role : role )
        }
        user.setAlias( alias : userDict.optString( key : ResponseParamKeys.alias ) )
        user.setCity( city : userDict.optString( key : ResponseParamKeys.city ) )
        user.setIsConfirmed( confirm: userDict.optBoolean( key : ResponseParamKeys.confirm ) )
        user.setCountryLocale( countryLocale : userDict.optString(key : ResponseParamKeys.countryLocale ) )
        user.setDateFormat( format : userDict.optString( key : ResponseParamKeys.dateFormat ) )
        user.setDateOfBirth( dateOfBirth : userDict.optString( key : ResponseParamKeys.dob ) )
        user.setCountry( country : userDict.optString( key : ResponseParamKeys.country ) )
        user.setFax( fax : userDict.optString( key : ResponseParamKeys.fax ) )
        user.setLocale( locale : userDict.optString( key : ResponseParamKeys.locale ) )
        user.setNameFormat( format : userDict.optString( key : ResponseParamKeys.nameFormat ) )
        user.setPhone( phone : userDict.optString( key : ResponseParamKeys.phone ) )
        user.setWebsite( website : userDict.optString( key : ResponseParamKeys.website ) )
        user.setStreet( street : userDict.optString( key : ResponseParamKeys.street ) )
        user.setTimeZone( timeZone : userDict.optString( key : ResponseParamKeys.timeZone ) )
        user.setState( state : userDict.optString( key : ResponseParamKeys.state) )
        if( userDict.hasValue( forKey : ResponseParamKeys.CreatedBy))
        {
            let createdByObj : [String:Any] = userDict.getDictionary(key: ResponseParamKeys.CreatedBy)
            let createdBy : ZCRMUser = ZCRMUser(userId: createdByObj.getInt64( key : ResponseParamKeys.id ), userFullName: createdByObj.getString( key : ResponseParamKeys.name ) )
            user.setCreatedBy( createdBy : createdBy )
            user.setCreatedTime( createdTime : userDict.getString( key : ResponseParamKeys.CreatedTime) )
        }
        if( userDict.hasValue( forKey : ResponseParamKeys.ModifiedBy ) )
        {
            let modifiedByObj : [ String : Any ] = userDict.getDictionary( key : ResponseParamKeys.ModifiedBy)
            let modifiedBy : ZCRMUser = ZCRMUser( userId : modifiedByObj.getInt64( key : ResponseParamKeys.id), userFullName : modifiedByObj.getString( key : ResponseParamKeys.name ) )
            user.setModifiedBy( modifiedBy : modifiedBy )
            user.setModifiedTime( modifiedTime : userDict.getString( key : ResponseParamKeys.ModifiedTime ) )
        }
        if ( userDict.hasValue( forKey : ResponseParamKeys.ReportingTo ) )
        {
            let reportingObj : [ String : Any ] = userDict.getDictionary( key : ResponseParamKeys.ReportingTo )
            let reportingTo : ZCRMUser = ZCRMUser( userId : reportingObj.getInt64( key : ResponseParamKeys.id), userFullName : reportingObj.getString( key : ResponseParamKeys.name ) )
            user.setReportingTo( reportingTo : reportingTo )
        }
		return user
	}
    
    private func getZCRMRole( roleDetails : [ String : Any ] ) -> ZCRMRole
    {
        let roleName : String = roleDetails.getString( key : ResponseParamKeys.name )
        let id : Int64 = roleDetails.getInt64( key : ResponseParamKeys.id )
        let role = ZCRMRole( roleId : id, roleName : roleName )
        role.setLabel( label : roleDetails.getString( key : ResponseParamKeys.displayLabel ) )
        role.setAdminUser( isAdminUser : roleDetails.getBoolean( key : ResponseParamKeys.adminUser ) )
        if ( roleDetails.hasValue(forKey: ResponseParamKeys.reportingTo) )
        {
            let reportingToObj : [String : Any] = roleDetails.getDictionary( key : ResponseParamKeys.reportingTo )
            let reportingRole : ZCRMRole = ZCRMRole( roleId : reportingToObj.getInt64( key : ResponseParamKeys.id ), roleName : reportingToObj.getString( key : ResponseParamKeys.name ) )
            role.setReportingTo( reportingTo : reportingRole )
        }
        return role
    }
    
    private func getZCRMProfile( profileDetails : [ String : Any ] ) -> ZCRMProfile
    {
        let name : String = profileDetails.getString( key : ResponseParamKeys.name )
        let id : Int64 = profileDetails.getInt64( key : ResponseParamKeys.id )
        let profile = ZCRMProfile( profileId : id, profileName :  name )
        profile.setCategory( category : profileDetails.getBoolean( key : ResponseParamKeys.category ) )
        if ( profileDetails.hasValue( forKey : ResponseParamKeys.description ) )
        {
            profile.setDescription( description : profileDetails.getString( key : ResponseParamKeys.description ) )
        }
        if ( profileDetails.hasValue( forKey : ResponseParamKeys.modifiedBy ) )
        {
            let modifiedUserObj : [ String : Any ] = profileDetails.getDictionary( key : ResponseParamKeys.modifiedBy )
            let modifiedUser = ZCRMUser( userId : modifiedUserObj.getInt64( key : ResponseParamKeys.id ), userFullName : modifiedUserObj.getString( key : ResponseParamKeys.name ) )
            profile.setModifiedBy( modifiedBy : modifiedUser )
        }
        if ( profileDetails.hasValue( forKey : ResponseParamKeys.createdBy ) )
        {
            let createdUserObj : [ String : Any ] = profileDetails.getDictionary( key : ResponseParamKeys.createdBy )
            let createdUser = ZCRMUser( userId : createdUserObj.getInt64( key : ResponseParamKeys.id ), userFullName : createdUserObj.getString( key : ResponseParamKeys.name ) )
            profile.setCreatedBy( createdBy : createdUser )
        }
        if ( profileDetails.hasValue( forKey : ResponseParamKeys.modifiedTime ) )
        {
            let modifiedTime = profileDetails.getString( key : ResponseParamKeys.modifiedTime )
            profile.setModifiedTime( modifiedTime : modifiedTime )
        }
        if ( profileDetails.hasValue( forKey : ResponseParamKeys.createdTime ) )
        {
            let createdTime = profileDetails.getString( key : ResponseParamKeys.createdTime )
            profile.setCreatedTime( createdTime : createdTime )
        }
        return profile
    }
    
    private func getZCRMUserAsJSON( user : ZCRMUser ) -> [ String : Any ]
    {
        var userJSON : [ String : Any ] = [ String : Any ]()
        if let id = user.getId()
        {
             userJSON[ ResponseParamKeys.id ] = id
        }
        else
        {
             userJSON[ ResponseParamKeys.id ] = nil
        }
        if let firstName = user.getFirstName()
        {
            userJSON[ ResponseParamKeys.firstName ] = firstName
        }
        else
        {
            userJSON[ ResponseParamKeys.firstName ] = nil
        }
        if let lastName = user.getLastName()
        {
            userJSON[ ResponseParamKeys.lastName ] = lastName
        }
        else
        {
            userJSON[ ResponseParamKeys.lastName ] = nil
        }
        if let fullName = user.getFullName()
        {
            userJSON[ ResponseParamKeys.fullName ] = fullName
        }
        else
        {
            userJSON[ ResponseParamKeys.fullName ] = nil
        }
        if let alias = user.getAlias()
        {
            userJSON[ ResponseParamKeys.alias ] = alias
        }
        else
        {
            userJSON[ ResponseParamKeys.alias ] = nil
        }
        if let dob = user.getDateOfBirth()
        {
            userJSON[ ResponseParamKeys.dob ] = dob
        }
        else
        {
            userJSON[ ResponseParamKeys.dob ] = nil
        }
        if let mobile = user.getMobile()
        {
            userJSON[ ResponseParamKeys.mobile ] = mobile
        }
        else
        {
            userJSON[ ResponseParamKeys.mobile ] = nil
        }
        if let phone = user.getPhone()
        {
            userJSON[ ResponseParamKeys.phone ] = phone
        }
        else
        {
            userJSON[ ResponseParamKeys.phone ] = nil
        }
        if let fax = user.getFax()
        {
            userJSON[ ResponseParamKeys.fax ] = fax
        }
        else
        {
            userJSON[ ResponseParamKeys.fax ] = nil
        }
        if let email = user.getEmailId()
        {
            userJSON[ ResponseParamKeys.email ] = email
        }
        else
        {
            userJSON[ ResponseParamKeys.email ] = nil
        }
        if let zip = user.getZip()
        {
            userJSON[ ResponseParamKeys.zip ] = zip
        }
        else
        {
            userJSON[ ResponseParamKeys.zip ] = nil
        }
        if let country = user.getCountry()
        {
            userJSON[ ResponseParamKeys.country ] = country
        }
        else
        {
            userJSON[ ResponseParamKeys.country ] = nil
        }
        if let state = user.getState()
        {
            userJSON[ ResponseParamKeys.state ] = state
        }
        else
        {
            userJSON[ ResponseParamKeys.state ] = nil
        }
        if let city = user.getCity()
        {
            userJSON[ ResponseParamKeys.city ] = city
        }
        else
        {
            userJSON[ ResponseParamKeys.city ] = nil
        }
        if let street = user.getStreet()
        {
            userJSON[ ResponseParamKeys.street ] = street
        }
        else
        {
            userJSON[ ResponseParamKeys.street ] = nil
        }
        if let locale = user.getLocale()
        {
            userJSON[ ResponseParamKeys.locale ] = locale
        }
        else
        {
            userJSON[ ResponseParamKeys.locale ] = nil
        }
        if let countryLocale = user.getCountryLocale()
        {
            userJSON[ ResponseParamKeys.countryLocale ] = countryLocale
        }
        else
        {
            userJSON[ ResponseParamKeys.countryLocale ] = nil
        }
        if let nameFormat = user.getNameFormat()
        {
            userJSON[ ResponseParamKeys.nameFormat ] = nameFormat
        }
        else
        {
            userJSON[ ResponseParamKeys.nameFormat ] = nil
        }
        if let dateFormat = user.getDateFormat()
        {
            userJSON[ ResponseParamKeys.dateFormat ] = dateFormat
        }
        else
        {
            userJSON[ ResponseParamKeys.dateFormat ] = nil
        }
        if let timeFormat = user.getTimeFormat()
        {
            userJSON[ ResponseParamKeys.timeFormat ] = timeFormat
        }
        else
        {
            userJSON[ ResponseParamKeys.timeFormat ] = nil
        }
        if let timeZone = user.getTimeZone()
        {
            userJSON[ ResponseParamKeys.timeZone ] = timeZone
        }
        else
        {
            userJSON[ ResponseParamKeys.timeZone ] = nil
        }
        if let website = user.getWebsite()
        {
            userJSON[ ResponseParamKeys.website ] = website
        }
        else
        {
            userJSON[ ResponseParamKeys.website ] = nil
        }
        if let confirm = user.isConfirmedUser()
        {
            userJSON[ ResponseParamKeys.confirm ] = confirm
        }
        else
        {
            userJSON[ ResponseParamKeys.confirm ] = nil
        }
        if let status = user.getStatus()
        {
            userJSON[ ResponseParamKeys.status ] = status
        }
        else
        {
            userJSON[ ResponseParamKeys.status ] = nil
        }
        if let profile = user.getProfile()
        {
            userJSON[ ResponseParamKeys.profile ] = String( profile.getId() )
        }
        else
        {
            print( "User must have profile" )
        }
        if let role = user.getRole()
        {
            userJSON[ ResponseParamKeys.role ] = role.getId()
        }
        else
        {
            print( "User must have role" )
        }
        
        if user.getData() != nil
        {
            var userData : [ String : Any ] = user.getData()!

            for fieldAPIName in userData.keys
            {
                var value = userData[ fieldAPIName ]
                if( value != nil && value is ZCRMRecord )
                {
                    value = String( ( value as! ZCRMRecord ).getId() )
                }
                else if( value != nil && value is ZCRMUser )
                {
                    value = String( ( value as! ZCRMUser ).getId()! )
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
    
    struct ResponseParamKeys
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
