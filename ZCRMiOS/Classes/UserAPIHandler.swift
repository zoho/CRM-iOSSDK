//
//  UserAPIHandler.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 08/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

internal class UserAPIHandler : CommonAPIHandler
{
    internal func getUsers(type : String?, modifiedSince : String?, page : Int, perPage : Int, completion : @escaping( BulkAPIResponse?, [ ZCRMUser ]?, Error? ) -> () )
    {
        setJSONRootKey( key : USERS )
        var allUsers : [ZCRMUser] = [ZCRMUser]()
		setUrlPath(urlPath: "/users" )
		setRequestMethod(requestMethod: .GET )
        if(type != nil)
        {
			addRequestParam(param: "type" , value: type! )
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
                completion( bulkResponse, allUsers, nil )
            }
        }
    }
    
    internal func getAllProfiles( completion : @escaping( BulkAPIResponse?, [ ZCRMProfile ]?, Error? ) -> () )
    {
        setJSONRootKey( key : PROFILES )
        var allProfiles : [ ZCRMProfile ] = [ ZCRMProfile ] ()
		setUrlPath(urlPath: "/settings/profiles" )
		setRequestMethod(requestMethod: .GET)
		let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
        request.getBulkAPIResponse { ( response, err ) in
            if let error = err
            {
                completion( nil, nil, error )
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
                completion( bulkResponse, allProfiles, nil )
            }
        }
    }
    
    internal func getAllRoles( completion : @escaping( BulkAPIResponse?, [ ZCRMRole ]?, Error? ) -> () )
    {
        setJSONRootKey( key : ROLES )
        var allRoles : [ ZCRMRole ] = [ ZCRMRole ]()
		setUrlPath(urlPath:  "/settings/roles" )
		setRequestMethod(requestMethod: .GET)
		let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
        request.getBulkAPIResponse { ( response, err ) in
            if let error = err
            {
                completion( nil, nil, error )
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
                completion( bulkResponse, allRoles, nil )
            }
        }
    }
    
    internal func getUser( userId : Int64?, completion : @escaping( APIResponse?, ZCRMUser?, Error? ) -> () )
	{
        setJSONRootKey( key : USERS )
		setRequestMethod(requestMethod: .GET )
        if(userId != nil)
        {
			setUrlPath(urlPath: "/users/\(userId!)" )
        }
        else
        {
			setUrlPath(urlPath: "/users" )
			addRequestParam(param: "type" , value:  "CurrentUser")
        }
		let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
        request.getAPIResponse { ( resp, err ) in
            if let error = err
            {
                completion( nil, nil, error )
            }
            if let response = resp
            {
                let responseJSON = response.getResponseJSON()
                let usersList:[[String : Any]] = responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                let user = self.getZCRMUser(userDict: usersList[0])
                response.setData(data: user )
                completion( response, user, nil )
            }
        }
    }
    
    internal func addUser( user : ZCRMUser, completion : @escaping( APIResponse?, ZCRMUser?, Error? ) -> () )
    {
        setJSONRootKey( key : USERS )
        setRequestMethod( requestMethod : .POST )
        setUrlPath( urlPath : "/users" )
        var reqBodyObj : [ String : [ [ String : Any ] ] ] = [ String : [ [ String : Any ] ] ]()
        var dataArray : [ [ String : Any ] ] = [ [ String : Any ] ]()
        dataArray.append( self.getZCRMUserAsJSON( user : user ) )
        reqBodyObj[ USERS ] = dataArray
        setRequestBody( requestBody : reqBodyObj )
        let request = APIRequest( handler : self )
        print( "Request : \( request.toString() )" )
        request.getAPIResponse { ( resp, err ) in
            if let error = err
            {
                completion( nil, nil, error )
            }
            if let response = resp
            {
                let responseJSONArray  = response.getResponseJSON().getArrayOfDictionaries( key : self.getJSONRootKey() )
                let responseJSONData = responseJSONArray[ 0 ]
                let responseDetails : [ String : Any ] = responseJSONData[ "details" ] as! [ String : Any ]
                user.setId( id : Int64( responseDetails[ "id" ] as! String )! )
                response.setData( data : user )
                completion( response, user, nil )
            }
        }
    }
    
    internal func updateUser( user : ZCRMUser, completion : @escaping( APIResponse?, Error? ) -> () )
    {
        setJSONRootKey( key : USERS )
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
    
    public func searchByCriteria( criteria : String, page : Int, perPage : Int, completion : @escaping( BulkAPIResponse?, [ ZCRMUser ]?, Error? ) -> () )
    {
        self.searchUsers( criteria : criteria, page : page, perPage : perPage) { ( response, users, error ) in
            completion( response, users, error )
        }
    }
    
    private func searchUsers( criteria : String, page : Int, perPage : Int, completion : @escaping( BulkAPIResponse?, [ ZCRMUser ]?, Error? ) -> () )
    {
        setJSONRootKey( key : USERS )
        setRequestMethod( requestMethod : .PUT )
        setUrlPath( urlPath : "/users" )
        addRequestParam( param : "filters", value : criteria )
        addRequestParam( param : "page", value : String( page ) )
        addRequestParam( param : "per_page", value : String( perPage ) )
        APIRequest( handler : self ).getBulkAPIResponse { ( response, err ) in
            if let error = err
            {
                completion( nil, nil, error )
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
                completion( bulkResponse, userList, nil )
            }
        }
    }
    
    internal func getProfile( profileId : Int64, completion : @escaping( APIResponse?, ZCRMProfile?, Error? ) -> () )
    {
        setJSONRootKey( key : PROFILES )
		setUrlPath(urlPath:  "/settings/profiles/\(profileId)" )
		setRequestMethod(requestMethod: .GET )
		let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
        request.getAPIResponse { ( resp, err ) in
            if let error = err
            {
                completion( nil, nil, error )
            }
            if let response = resp
            {
                let responseJSON = response.getResponseJSON()
                let profileList : [ [ String : Any ] ] = responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                let profile = self.getZCRMProfile( profileDetails: profileList[ 0 ] )
                response.setData( data : profile )
                completion( response, profile, nil )
            }
        }
    }
    
    internal func getRole( roleId : Int64, completion : @escaping( APIResponse?, ZCRMRole?, Error? ) -> () )
    {
        setJSONRootKey( key : ROLES )
		setUrlPath(urlPath: "/settings/roles/\(roleId)" )
		setRequestMethod(requestMethod: .GET )
		let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
        request.getAPIResponse { ( resp, err ) in
            if let error = err
            {
                completion( nil, nil, error )
            }
            if let response = resp
            {
                let responseJSON = response.getResponseJSON()
                let rolesList : [ [ String : Any ] ] = responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                let role = self.getZCRMRole( roleDetails : rolesList[ 0 ] )
                response.setData( data : role )
                completion( response, role, nil )
            }
        }
    }
    
    internal func downloadPhoto( size : PhotoSize, completion : @escaping( FileAPIResponse?, Error? ) -> () )
    {
		setUrl(url: PHOTOURL )
		setRequestMethod(requestMethod: .GET )
		addRequestParam(param: "photo_size" , value: size.rawValue )
		let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
        request.downloadFile { ( response, error ) in
            completion( response, error )
        }
    }
    
    internal func getCurrentUser( completion : @escaping( APIResponse?, ZCRMUser?, Error? ) -> () )
    {
        self.getUser( userId : nil) { ( response, user, error ) in
            completion( response, user, error )
        }
    }
    
    internal func getAllUsers( modifiedSince : String?, page : Int, perPage : Int, completion : @escaping( BulkAPIResponse?, [ ZCRMUser ]?, Error? ) -> () )
    {
        self.getUsers( type: nil, modifiedSince : modifiedSince, page : page, perPage : perPage) { ( response, users, error ) in
            completion( response, users, error )
        }
    }
    
    internal func getAllActiveUsers( page : Int, perPage : Int, completion : @escaping( BulkAPIResponse?, [ ZCRMUser ]?, Error? ) -> () )
    {
        self.getUsers( type : "ActiveUsers", modifiedSince : nil, page : page, perPage : perPage) { ( response, users, error ) in
            completion( response, users, error )
        }
    }
    
    internal func getAllDeactiveUsers( page : Int, perPage : Int, completion : @escaping( BulkAPIResponse?, [ ZCRMUser ]?, Error? ) -> () )
    {
        self.getUsers( type : "DeactiveUsers", modifiedSince : nil, page : page, perPage : perPage) { ( response, users, error ) in
            completion( response, users, error )
        }
    }
    
    internal func getAllUnConfirmedUsers( page : Int, perPage : Int, completion : @escaping( BulkAPIResponse?, [ ZCRMUser ]?, Error? ) -> () )
    {
        self.getUsers( type : "NotConfirmedUsers", modifiedSince : nil, page : page, perPage : perPage) { ( response, users, error ) in
            completion( response, users, error )
        }
    }
    
    internal func getAllConfirmedUsers( page : Int, perPage : Int, completion : @escaping( BulkAPIResponse?, [ ZCRMUser ]?, Error? ) -> () )
    {
        self.getUsers( type : "ConfirmedUsers", modifiedSince : nil, page : page, perPage : perPage) { ( response, users, error ) in
            completion( response, users, error )
        }
    }

    internal func getAllActiveConfirmedUsers( page : Int, perPage : Int, completion : @escaping( BulkAPIResponse?, [ ZCRMUser ]?, Error? ) -> () )
    {
        self.getUsers( type: "ActiveConfirmedUsers", modifiedSince : nil, page : page, perPage : perPage) { ( response, users, error ) in
            completion( response, users, error )
        }
    }
    
    internal func getAllDeletedUsers( page : Int, perPage : Int, completion : @escaping( BulkAPIResponse?, [ ZCRMUser ]?, Error? ) -> () )
    {
        self.getUsers( type: "DeletedUsers", modifiedSince : nil, page : page, perPage : perPage) { ( response, users, error ) in
            completion( response, users, error )
        }
    }
    
    internal func getAllAdminUsers( page : Int, perPage : Int, completion : @escaping( BulkAPIResponse?, [ ZCRMUser ]?, Error? ) -> () )
    {
        self.getUsers( type: "AdminUsers", modifiedSince : nil, page : page, perPage : perPage) { ( response, users, error ) in
            completion( response, users, error )
        }
    }
    
    internal func getAllActiveConfirmedAdmins( page : Int, perPage : Int, completion : @escaping( BulkAPIResponse?, [ ZCRMUser ]?, Error? ) -> () )
    {
        self.getUsers( type: "ActiveConfirmedAdmins", modifiedSince : nil, page : page, perPage : perPage) { ( response, users, error ) in
            completion( response, users, error )
        }
    }
	
	internal func getZCRMUser(userDict : [String : Any]) -> ZCRMUser
	{
        let fullName : String = userDict.getString( key : "full_name" )
        let userId : Int64? = userDict.getInt64( key : "id" )
        let user = ZCRMUser(userId : userId!, userFullName : fullName)
        user.setFirstName(fName: userDict.optString(key: "first_name"))
        user.setLastName(lName: userDict.getString(key: "last_name"))//
        user.setEmailId(email: userDict.getString(key: "email"))//
        user.setMobile(mobile: userDict.optString(key: "mobile"))
        user.setLanguage(language: userDict.optString(key: "language"))
        user.setStatus(status: userDict.optString(key: "status"))
        user.setZuId(zuId: userDict.optInt64(key: "zuid"))
        if ( userDict.hasValue( forKey : "profile" ) )
        {
            let profileObj : [String : Any] = userDict.getDictionary(key: "profile")
            let profile : ZCRMProfile = ZCRMProfile(profileId : profileObj.getInt64( key : "id" ), profileName : profileObj.getString( key : "name" ) )
            user.setProfile(profile: profile)
        }
        if ( userDict.hasValue( forKey : "role" ) )
        {
            let roleObj : [String : Any] = userDict.getDictionary(key: "role")
            let role : ZCRMRole = ZCRMRole( roleId : roleObj.getInt64( key : "id" ), roleName : roleObj.getString( key : "name" ) )
            user.setRole( role : role )
        }
        user.setAlias( alias : userDict.optString( key : "alias" ) )
        user.setCity( city : userDict.optString( key : "city" ) )
        user.setIsConfirmed( confirm: userDict.optBoolean( key : "confirm" ) )
        user.setCountryLocale( countryLocale : userDict.optString(key : "country_locale" ) )
        user.setDateFormat( format : userDict.optString( key : "date_fromat" ) )
        user.setDateOfBirth( dateOfBirth : userDict.optString( key : "dob" ) )
        user.setEmailId( email : userDict.optString( key : "email" )! )
        user.setCountry( country : userDict.optString( key : "country" ) )
        user.setFax( fax : userDict.optString( key : "fax" ) )
        user.setLocale( locale : userDict.optString( key : "locale" ) )
        user.setNameFormat( format : userDict.optString( key : "name_format" ) )
        user.setPhone( phone : userDict.optString( key : "phone" ) )
        user.setWebsite( website : userDict.optString( key : "website" ) )
        user.setStreet( street : userDict.optString( key : "street" ) )
        user.setTimeZone( timeZone : userDict.optString( key : "time_zone" ) )
        user.setState( state : userDict.optString( key : "state" ) )
        if( userDict.hasValue( forKey : "Created_By"))
        {
            let createdByObj : [String:Any] = userDict.getDictionary(key: "Created_By")
            let createdBy : ZCRMUser = ZCRMUser(userId: createdByObj.getInt64( key : "id" ), userFullName: createdByObj.getString( key : "name" ) )
            user.setCreatedBy( createdBy : createdBy )
            user.setCreatedTime( createdTime : userDict.getString( key : "Created_Time") )
        }
        if( userDict.hasValue( forKey : "Modified_By" ) )
        {
            let modifiedByObj : [ String : Any ] = userDict.getDictionary( key : "Modified_By")
            let modifiedBy : ZCRMUser = ZCRMUser( userId : modifiedByObj.getInt64( key : "id"), userFullName : modifiedByObj.getString( key : "name" ) )
            user.setModifiedBy( modifiedBy : modifiedBy )
            user.setModifiedTime( modifiedTime : userDict.getString( key : "Modified_Time" ) )
        }
        if ( userDict.hasValue( forKey : "Reporting_To" ) )
        {
            let reportingObj : [ String : Any ] = userDict.getDictionary( key : "Reporting_To" )
            let reportingTo : ZCRMUser = ZCRMUser( userId : reportingObj.getInt64( key : "id"), userFullName : reportingObj.getString( key : "name" ) )
            user.setReportingTo( reportingTo : reportingTo )
        }
		return user
	}
    
    internal func getZCRMRole( roleDetails : [ String : Any ] ) -> ZCRMRole
    {
        let roleName : String = roleDetails.getString( key : "name" )
        let id : Int64 = roleDetails.getInt64( key : "id" )
        let role = ZCRMRole( roleId : id, roleName : roleName )
        role.setLabel( label : roleDetails.getString( key : "display_label" ) )
        role.setAdminUser( isAdminUser : roleDetails.getBoolean( key : "admin_user" ) )
        if ( roleDetails.hasValue(forKey: "reporting_to") )
        {
            let reportingToObj : [String : Any] = roleDetails.getDictionary( key : "reporting_to" )
            let reportingRole : ZCRMRole = ZCRMRole( roleId : reportingToObj.getInt64( key : "id" ), roleName : reportingToObj.getString( key : "name" ) )
            role.setReportingTo( reportingTo : reportingRole )
        }
        return role
    }
    
    internal func getZCRMProfile( profileDetails : [ String : Any ] ) -> ZCRMProfile
    {
        let name : String = profileDetails.getString( key : "name" )
        let id : Int64 = profileDetails.getInt64( key : "id" )
        let profile = ZCRMProfile( profileId : id, profileName :  name )
        profile.setCategory( category : profileDetails.getBoolean( key : "category" ) )
        if ( profileDetails.hasValue( forKey : "description" ) )
        {
            profile.setDescription( description : profileDetails.getString( key : "description" ) )
        }
        if ( profileDetails.hasValue( forKey : "modified_by" ) )
        {
            let modifiedUserObj : [ String : Any ] = profileDetails.getDictionary( key : "modified_by" )
            let modifiedUser = ZCRMUser( userId : modifiedUserObj.getInt64( key : "id" ), userFullName : modifiedUserObj.getString( key : "name" ) )
            profile.setModifiedBy( modifiedBy : modifiedUser )
        }
        if ( profileDetails.hasValue( forKey : "created_by" ) )
        {
            let createdUserObj : [ String : Any ] = profileDetails.getDictionary( key : "created_by" )
            let createdUser = ZCRMUser( userId : createdUserObj.getInt64( key : "id" ), userFullName : createdUserObj.getString( key : "name" ) )
            profile.setCreatedBy( createdBy : createdUser )
        }
        if ( profileDetails.hasValue( forKey : "modified_time" ) )
        {
            let modifiedTime = profileDetails.getString( key : "modified_time" )
            profile.setModifiedTime( modifiedTime : modifiedTime )
        }
        if ( profileDetails.hasValue( forKey : "created_time" ) )
        {
            let createdTime = profileDetails.getString( key : "created_time" )
            profile.setCreatedTime( createdTime : createdTime )
        }
        return profile
    }
    
    internal func getZCRMUserAsJSON( user : ZCRMUser ) -> [ String : Any ]
    {
        var userJSON : [ String : Any ] = [ String : Any ]()
        if let id = user.getId()
        {
             userJSON[ "id" ] = id
        }
        else
        {
             userJSON[ "id" ] = nil
        }
        if let firstName = user.getFirstName()
        {
            userJSON[ "first_name" ] = firstName
        }
        else
        {
            userJSON[ "first_name" ] = nil
        }
        if let lastName = user.getLastName()
        {
            userJSON[ "last_name" ] = lastName
        }
        else
        {
            userJSON[ "last_name" ] = nil
        }
        if let fullName = user.getFullName()
        {
            userJSON[ "full_name" ] = fullName
        }
        else
        {
            userJSON[ "full_name" ] = nil
        }
        if let alias = user.getAlias()
        {
            userJSON[ "alias" ] = alias
        }
        else
        {
            userJSON[ "alias" ] = nil
        }
        if let dob = user.getDateOfBirth()
        {
            userJSON[ "dob" ] = dob
        }
        else
        {
            userJSON[ "dob" ] = nil
        }
        if let mobile = user.getMobile()
        {
            userJSON[ "mobile" ] = mobile
        }
        else
        {
            userJSON[ "mobile" ] = nil
        }
        if let phone = user.getPhone()
        {
            userJSON[ "phone" ] = phone
        }
        else
        {
            userJSON[ "phone" ] = nil
        }
        if let fax = user.getFax()
        {
            userJSON[ "fax" ] = fax
        }
        else
        {
            userJSON[ "fax" ] = nil
        }
        if let email = user.getEmailId()
        {
            userJSON[ "email" ] = email
        }
        else
        {
            userJSON[ "email" ] = nil
        }
        if let zip = user.getZip()
        {
            userJSON[ "zip" ] = zip
        }
        else
        {
            userJSON[ "zip" ] = nil
        }
        if let country = user.getCountry()
        {
            userJSON[ "country" ] = country
        }
        else
        {
            userJSON[ "country" ] = nil
        }
        if let state = user.getState()
        {
            userJSON[ "state" ] = state
        }
        else
        {
            userJSON[ "state" ] = nil
        }
        if let city = user.getCity()
        {
            userJSON[ "city" ] = city
        }
        else
        {
            userJSON[ "city" ] = nil
        }
        if let street = user.getStreet()
        {
            userJSON[ "street" ] = street
        }
        else
        {
            userJSON[ "street" ] = nil
        }
        if let locale = user.getLocale()
        {
            userJSON[ "locale" ] = locale
        }
        else
        {
            userJSON[ "locale" ] = nil
        }
        if let countryLocale = user.getCountryLocale()
        {
            userJSON[ "country_locale" ] = countryLocale
        }
        else
        {
            userJSON[ "country_locale" ] = nil
        }
        if let nameFormat = user.getNameFormat()
        {
            userJSON[ "name_format" ] = nameFormat
        }
        else
        {
            userJSON[ "name_format" ] = nil
        }
        if let dateFormat = user.getDateFormat()
        {
            userJSON[ "date_format" ] = dateFormat
        }
        else
        {
            userJSON[ "date_format" ] = nil
        }
        if let timeFormat = user.getTimeFormat()
        {
            userJSON[ "time_format" ] = timeFormat
        }
        else
        {
            userJSON[ "time_format" ] = nil
        }
        if let timeZone = user.getTimeZone()
        {
            userJSON[ "time_zone" ] = timeZone
        }
        else
        {
            userJSON[ "time_zone" ] = nil
        }
        if let website = user.getWebsite()
        {
            userJSON[ "website" ] = website
        }
        else
        {
            userJSON[ "website" ] = nil
        }
        if let confirm = user.isConfirmedUser()
        {
            userJSON[ "confirm" ] = confirm
        }
        else
        {
            userJSON[ "confirm" ] = nil
        }
        if let status = user.getStatus()
        {
            userJSON[ "status" ] = status
        }
        else
        {
            userJSON[ "status" ] = nil
        }
        if let profile = user.getProfile()
        {
            userJSON[ "profile" ] = String( profile.getId() )
        }
        else
        {
            print( "User must have role" )
        }
        if let role = user.getRole()
        {
            userJSON[ "role" ] = role.getId()
        }
        else
        {
            print( "User must have profile" )
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
