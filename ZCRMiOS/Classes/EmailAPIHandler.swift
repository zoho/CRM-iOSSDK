//
//  EmailAPIHandler.swift
//  ZCRMiOS
//
//  Created by Umashri R on 05/10/18.
//

internal class EmailAPIHandler : CommonAPIHandler
{
    var orgEmail : ZCRMOrgEmail?
    
    init( orgEmail : ZCRMOrgEmail )
    {
        self.orgEmail = orgEmail
    }
    
    override init()
    { }
    
    internal func create( completion : @escaping( Result.DataResponse< ZCRMOrgEmail, APIResponse > ) -> () )
    {
        if let orgEmail = self.orgEmail
        {
            setJSONRootKey(key: JSONRootKey.ORG_EMAILS)
            var reqBodyObj : [String:[[String:Any]]] = [String:[[String:Any]]]()
            var dataArray : [[String:Any]] = [[String:Any]]()
            do
            {
                dataArray.append(try self.getZCRMOrgEmailAsJSON(orgEmail: orgEmail))
            }
            catch
            {
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
            reqBodyObj[getJSONRootKey()] = dataArray
            
            setUrlPath(urlPath: "/\(APIConstants.SETTINGS)/\(APIConstants.EMAILS)/\(APIConstants.ORG_EMAILS)")
            setRequestMethod(requestMethod: .POST)
            setRequestBody(requestBody: reqBodyObj)
            
            let request : APIRequest = APIRequest(handler: self)
            print( "Request : \(request.toString())" )
            
            request.getAPIResponse { ( resultType ) in
                do{
                    let response = try resultType.resolve()
                    let responseJSONArray  = response.getResponseJSON().getArrayOfDictionaries( key : self.getJSONRootKey() )
                    let responseJSONData = responseJSONArray[0]
                    let responseDetails : [ String : Any ] = responseJSONData[ APIConstants.DETAILS ] as! [ String : Any ]
                    let createdMail = try self.getZCRMOrgEmail(orgEmail: orgEmail, orgEmailDetails: responseDetails)
                    response.setData( data : createdMail )
                    completion( .success( createdMail, response ) )
                }
                catch{
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
        }
        else
        {
            completion( .failure( ZCRMError.ProcessingError( code: ErrorCode.MANDATORY_NOT_FOUND, message: "OrgEmail MUST NOT be nil" ) ) )
        }
    }
    
    //MARK:- To confirm the email id given
    internal func updateConfirmationStatus( code : String, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        if let orgEmail = self.orgEmail
        {
            if orgEmail.id != APIConstants.INT64_MOCK
            {
                setJSONRootKey(key: JSONRootKey.ORG_EMAILS)
                setUrlPath(urlPath: "/\(APIConstants.SETTINGS)/\(APIConstants.EMAILS)/\(APIConstants.ORG_EMAILS)/\(String(orgEmail.id))/actions/confirm")
                addRequestParam(param: RequestParamKeys.code, value: code)
                setRequestMethod(requestMethod: .POST)
                let request : APIRequest = APIRequest(handler: self)
                print( "Request : \(request.toString())" )
                
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
            else
            {
                completion( .failure( ZCRMError.ProcessingError( code: ErrorCode.MANDATORY_NOT_FOUND, message: "OrgEmail ID MUST NOT be nil" ) ) )
            }
        }
        else
        {
            completion( .failure( ZCRMError.ProcessingError( code: ErrorCode.MANDATORY_NOT_FOUND, message: "OrgEmail MUST NOT be nil" ) ) )
        }
    }
    
    internal func resendConfirmationCode( completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        if let orgEmail = self.orgEmail
        {
            if orgEmail.id != APIConstants.INT64_MOCK
            {
                setJSONRootKey(key: JSONRootKey.ORG_EMAILS)
                setUrlPath(urlPath: "/\(APIConstants.SETTINGS)/\(APIConstants.EMAILS)/\(APIConstants.ORG_EMAILS)/\(String(orgEmail.id))/actions/resend_confirm_email")
                setRequestMethod(requestMethod: .POST)
                let request : APIRequest = APIRequest(handler: self)
                print( "Request : \(request.toString())" )
                
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
            else
            {
                completion( .failure( ZCRMError.ProcessingError( code: ErrorCode.MANDATORY_NOT_FOUND, message: "OrgEmail ID MUST NOT be nil" ) ) )
            }
        }
        else
        {
            completion( .failure( ZCRMError.ProcessingError( code: ErrorCode.MANDATORY_NOT_FOUND, message: "OrgEmail MUST NOT be nil" ) ) )
        }
    }
    
    internal func getOrgEmail( id : Int64, completion : @escaping( Result.DataResponse< ZCRMOrgEmail, APIResponse > ) -> () )
    {
        setJSONRootKey(key: JSONRootKey.ORG_EMAILS)
        setUrlPath(urlPath: "/\(APIConstants.SETTINGS)/\(APIConstants.EMAILS)/\(APIConstants.ORG_EMAILS)/\(String(id))")
        setRequestMethod(requestMethod: .GET)
        let request : APIRequest = APIRequest(handler: self)
        print( "Request : \(request.toString())" )
        
        request.getAPIResponse { ( resultType ) in
            do
            {
                let response = try resultType.resolve()
                let responseJSON = response.getResponseJSON()
                let orgEmailList:[[String : Any]] = responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                var orgEmail : ZCRMOrgEmail = ZCRMOrgEmail(id: orgEmailList[0].getInt64(key: ResponseJSONKeys.id))
                orgEmail = try self.getZCRMOrgEmail(orgEmail: orgEmail, orgEmailDetails: orgEmailList[0])
                response.setData(data: orgEmail )
                completion( .success( orgEmail, response ) )
            }
            catch
            {
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func getOrgEmails( completion : @escaping( Result.DataResponse< [ ZCRMOrgEmail ], BulkAPIResponse > ) -> () )
    {
        var orgEmails : [ZCRMOrgEmail] = [ZCRMOrgEmail]()
        setJSONRootKey(key: JSONRootKey.ORG_EMAILS)
        setUrlPath(urlPath: "/\(APIConstants.SETTINGS)/\(APIConstants.EMAILS)/\(APIConstants.ORG_EMAILS)")
        setRequestMethod(requestMethod: .GET)
        let request : APIRequest = APIRequest(handler: self)
        print( "Request : \(request.toString())" )
        
        request.getBulkAPIResponse { ( resultType ) in
            do{
                let bulkResponse = try resultType.resolve()
                let responseJSON = bulkResponse.getResponseJSON()
                if responseJSON.isEmpty == false
                {
                    let orgEmailsList:[[String:Any]] = responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                    for orgEmailList in orgEmailsList
                    {
                        let orgEmail = ZCRMOrgEmail(id: orgEmailList.getInt64(key: ResponseJSONKeys.id))
                        orgEmails.append( try self.getZCRMOrgEmail(orgEmail: orgEmail, orgEmailDetails: orgEmailList))
                    }
                    bulkResponse.setData(data: orgEmails)
                    completion( .success( orgEmails, bulkResponse ) )
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
    
    internal func delete( id : Int64, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        setJSONRootKey(key: JSONRootKey.ORG_EMAILS)
        setUrlPath(urlPath: "/\(APIConstants.SETTINGS)/\(APIConstants.EMAILS)/\(APIConstants.ORG_EMAILS)/\(String(id))" )
        setRequestMethod(requestMethod: .DELETE )
        let request : APIRequest = APIRequest(handler: self)
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
    
    private func getZCRMOrgEmail(orgEmail : ZCRMOrgEmail, orgEmailDetails : [String : Any]) throws -> ZCRMOrgEmail
    {
        if orgEmailDetails.hasValue( forKey : ResponseJSONKeys.id ) == false
        {
            throw ZCRMError.InValidError( code : ErrorCode.VALUE_NIL, message : "\( ResponseJSONKeys.id ) is must not be nil" )
        }
        orgEmail.id = orgEmailDetails.getInt64(key: ResponseJSONKeys.id)
        if orgEmailDetails.hasValue(forKey: ResponseJSONKeys.confirm)
        {
            orgEmail.confirm = orgEmailDetails.getBoolean(key: ResponseJSONKeys.confirm)
        }
        if orgEmailDetails.hasValue(forKey: ResponseJSONKeys.displayName)
        {
            orgEmail.name = orgEmailDetails.getString(key: ResponseJSONKeys.displayName)
        }
        
        if orgEmailDetails.hasValue(forKey: ResponseJSONKeys.email)
        {
            orgEmail.email = orgEmailDetails.getString(key: ResponseJSONKeys.email)
        }
        if orgEmailDetails.hasValue(forKey: ResponseJSONKeys.profiles)
        {
            let profilesDet : [[String:Any]] = orgEmailDetails.getArrayOfDictionaries(key: ResponseJSONKeys.profiles)
            for profileDet in profilesDet
            {
                var profile : ZCRMProfileDelegate
                profile = ZCRMProfileDelegate(profileId: profileDet.getInt64(key: ResponseJSONKeys.id), profileName: profileDet.getString(key: ResponseJSONKeys.name))
                orgEmail.addProfile(profile: profile)
            }
        }
        return orgEmail
    }
    
    private func getZCRMOrgEmailAsJSON( orgEmail : ZCRMOrgEmail ) throws -> [String:Any]
    {
        var orgEmailDetails : [String:Any] = [String:Any]()
        var profilesDetails : [[String:Any]] = [[String:Any]]()
        if orgEmail.name == APIConstants.STRING_MOCK
        {
            throw ZCRMError.InValidError( code : ErrorCode.VALUE_NIL, message : "\( ResponseJSONKeys.displayName ) is must not be nil" )
        }
        orgEmailDetails[ ResponseJSONKeys.displayName ] = orgEmail.name
        if orgEmail.email == APIConstants.STRING_MOCK
        {
            throw ZCRMError.InValidError( code : ErrorCode.VALUE_NIL, message : "\( ResponseJSONKeys.email ) is must not be nil" )
        }
        orgEmailDetails[ ResponseJSONKeys.email ] = orgEmail.email
        if orgEmail.profiles.isEmpty != true
        {
            throw ZCRMError.InValidError( code : ErrorCode.VALUE_NIL, message : "\( ResponseJSONKeys.profiles ) is must not be nil" )
        }
        for profile in orgEmail.profiles
        {
            var profileDetails : [String:Any] = [String:Any]()
            profileDetails[ResponseJSONKeys.id] = profile.profileId
            profilesDetails.append(profileDetails)
        }
        orgEmailDetails[ ResponseJSONKeys.profiles ] = profilesDetails
        return orgEmailDetails
    }
}

extension EmailAPIHandler
{
    struct RequestParamKeys
    {
        static let code = "code"
    }
    struct ResponseJSONKeys
    {
        static let id = "id"
        static let displayName = "display_name"
        static let email = "email"
        static let profiles = "profiles"
        static let name = "name"
        static let confirm = "confirm"
    }
}
