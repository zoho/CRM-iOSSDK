//
//  UserAPIHandler.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 08/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

internal class UserAPIHandler
{
    internal func getUsers(type : String?, modifiedSince : String? ) throws -> BulkAPIResponse
    {
        var allUsers : [ZCRMUser] = [ZCRMUser]()
        let request : APIRequest = APIRequest(urlPath: "/users", reqMethod: RequestMethod.GET)
        if(type != nil)
        {
            request.addParam(paramName: "type", paramVal: type!)
        }
        if ( modifiedSince != nil )
        {
            request.addHeader( headerName : "If-Modified-Since", headerVal : modifiedSince! )
        }
        print( "Request : \( request.toString() )" )
        let response = try request.getBulkAPIResponse()
        let responseJSON = response.getResponseJSON()
        if responseJSON.isEmpty == false
        {
            let usersList:[[String:Any]] = responseJSON.getArrayOfDictionaries( key : "users" )
            for user in usersList
            {
                allUsers.append(self.getZCRMUser(userMap: user))
            }
        }
        response.setData(data: allUsers)
        return response
    }
    
    internal func getAllProfiles() throws -> BulkAPIResponse
    {
        var allProfiles : [ ZCRMProfile ] = [ ZCRMProfile ] ()
        let request : APIRequest = APIRequest( urlPath : "/settings/profiles", reqMethod : RequestMethod.GET )
        print( "Request : \( request.toString() )" )
        let response = try request.getBulkAPIResponse()
        let responseJSON = response.getResponseJSON()
        if responseJSON.isEmpty == false
        {
            let profileList : [ [ String : Any ] ] = responseJSON.getArrayOfDictionaries( key : "profiles" )
            for profile in profileList
            {
                allProfiles.append( self.getZCRMProfile( profileDetails : profile ) )
            }
        }
        response.setData( data : allProfiles )
        return response
    }
    
    internal func getAllRoles() throws -> BulkAPIResponse
    {
        var allRoles : [ ZCRMRole ] = [ ZCRMRole ]()
        let request = APIRequest( urlPath : "/settings/roles", reqMethod : RequestMethod.GET )
        print( "Request : \( request.toString() )" )
        let response = try request.getBulkAPIResponse()
        let responseJSON = response.getResponseJSON()
        if responseJSON.isEmpty == false
        {
            let rolesList : [ [ String : Any ] ] = responseJSON.getArrayOfDictionaries( key : "roles" )
            for role in rolesList
            {
                allRoles.append( self.getZCRMRole( roleDetails : role ) )
            }
        }
        response.setData( data : allRoles )
        return response
    }
    
	internal func getUser(userId : Int64?) throws -> APIResponse
	{
		var request : APIRequest
        if(userId != nil)
        {
            request = APIRequest(urlPath: "/users/\(userId!)", reqMethod: RequestMethod.GET)
        }
        else
        {
            request = APIRequest(urlPath: "/users", reqMethod: RequestMethod.GET)
            request.addParam(paramName: "type", paramVal: "CurrentUser")
        }
        print( "Request : \( request.toString() )" )
        let response = try request.getAPIResponse()
		let responseJSON = response.getResponseJSON()
		let usersList:[[String : Any]] = responseJSON.getArrayOfDictionaries( key : "users" )
		response.setData(data: self.getZCRMUser(userMap: usersList[0]))
        return response
    }
    
    internal func getProfile( profileId : Int64 ) throws -> APIResponse
    {
        let request = APIRequest( urlPath : "/settings/profiles/\(profileId)", reqMethod : RequestMethod.GET )
        print( "Request : \( request.toString() )" )
        let response = try request.getAPIResponse()
        let responseJSON = response.getResponseJSON()
        let profileList : [ [ String : Any ] ] = responseJSON.getArrayOfDictionaries( key : "profiles" )
        response.setData( data : self.getZCRMProfile(profileDetails: profileList[ 0 ] ) )
        return response
    }
    
    internal func getRole( roleId : Int64 ) throws -> APIResponse
    {
        let request = APIRequest( urlPath : "/settings/roles/\(roleId)", reqMethod : RequestMethod.GET )
        print( "Request : \( request.toString() )" )
        let response = try request.getAPIResponse()
        let responseJSON = response.getResponseJSON()
        let rolesList : [ [ String : Any ] ] = responseJSON.getArrayOfDictionaries( key : "roles" )
        response.setData( data : self.getZCRMRole( roleDetails : rolesList[ 0 ] ) )
        return response
    }
    
    internal func downloadPhoto( size : PhotoSize? ) throws -> FileAPIResponse
    {
        let request : APIRequest = APIRequest( url : PHOTOURL, reqMethod : RequestMethod.GET )
        if( size != nil )
        {
            request.addParam( paramName : "photo_size", paramVal : size!.rawValue )
        }
        print( "Request : \( request.toString() )" )
        return try request.downloadFile()
    }
    
    internal func getCurrentUser() throws -> APIResponse
    {
        return try getUser(userId: nil)
    }
    
    internal func getAllUsers( modifiedSince : String? ) throws -> BulkAPIResponse
    {
        return try getUsers(type: nil, modifiedSince : modifiedSince )
    }
    
    internal func getAllActiveUsers() throws -> BulkAPIResponse
    {
        return try getUsers( type : "ActiveUsers", modifiedSince : nil )
    }
    
    internal func getAllDeactiveUsers() throws -> BulkAPIResponse
    {
        return try getUsers( type : "DeactiveUsers", modifiedSince : nil )
    }
    
    internal func getAllUnConfirmedUsers() throws -> BulkAPIResponse
    {
        return try getUsers( type : "NotConfirmedUsers", modifiedSince : nil )
    }
    
    internal func getAllConfirmedUsers() throws -> BulkAPIResponse
    {
        return try getUsers( type : "ConfirmedUsers", modifiedSince : nil )
    }

    internal func getAllActiveConfirmedUsers() throws -> BulkAPIResponse
    {
        return try getUsers(type: "ActiveConfirmedUsers", modifiedSince : nil )
    }
    
    internal func getAllDeletedUsers() throws -> BulkAPIResponse
    {
        return try getUsers(type: "DeletedUsers", modifiedSince : nil )
    }
    
    internal func getAllAdminUsers() throws -> BulkAPIResponse
    {
        return try getUsers(type: "AdminUsers", modifiedSince : nil )
    }
    
    internal func getAllActiveConfirmedAdmins() throws -> BulkAPIResponse
    {
        return try getUsers(type: "ActiveConfirmedAdmins", modifiedSince : nil )
    }
	
	internal func getZCRMUser(userMap : [String : Any]) -> ZCRMUser
	{
        let fullName : String = userMap.getString( key : "full_name" )
        let userId : Int64? = userMap.getInt64( key : "id" )
        let user = ZCRMUser(userId : userId!, userFullName : fullName)
        user.setFirstName(fName: userMap.optString(key: "first_name"))
        user.setLastName(lName: userMap.getString(key: "last_name"))//
        user.setEmailId(email: userMap.getString(key: "email"))//
        user.setMobile(mobile: userMap.optString(key: "mobile"))
        user.setLanguage(language: userMap.optString(key: "language"))
        user.setStatus(status: userMap.optString(key: "status"))
        user.setZuId(zuId: userMap.optInt64(key: "zuid"))
        if ( userMap.hasValue( forKey : "profile" ) )
        {
            let profileObj : [String : Any] = userMap.getDictionary(key: "profile")
            let profile : ZCRMProfile = ZCRMProfile(profileId : profileObj.getInt64( key : "id" ), profileName : profileObj.getString( key : "name" ) )
            user.setProfile(profile: profile)
        }
        if ( userMap.hasValue( forKey : "role" ) )
        {
            let roleObj : [String : Any] = userMap.getDictionary(key: "role")
            let role : ZCRMRole = ZCRMRole( roleId : roleObj.getInt64( key : "id" ), roleName : roleObj.getString( key : "name" ) )
            user.setRole( role : role )
        }
        user.setAlias( alias : userMap.optString( key : "alias" ) )
        user.setCity( city : userMap.optString( key : "city" ) )
        user.setIsConfirmed( confirm: userMap.optBoolean( key : "confirm" ) )
        user.setCountryLocale( countryLocale : userMap.optString(key : "country_locale" ) )
        user.setDateFormat( format : userMap.optString( key : "date_fromat" ) )
        user.setDateOfBirth( dateOfBirth : userMap.optString( key : "dob" ) )
        user.setEmailId( email : userMap.optString( key : "email" ) )
        user.setCountry( country : userMap.optString( key : "country" ) )
        user.setFax( fax : userMap.optString( key : "fax" ) )
        user.setLocale( locale : userMap.optString( key : "locale" ) )
        user.setNameFormat( format : userMap.optString( key : "name_format" ) )
        user.setPhone( phone : userMap.optString( key : "phone" ) )
        user.setWebsite( website : userMap.optString( key : "website" ) )
        user.setStreet( street : userMap.optString( key : "street" ) )
        user.setTimeZone( timeZone : userMap.optString( key : "time_zone" ) )
        user.setState( state : userMap.optString( key : "state" ) )
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
}
