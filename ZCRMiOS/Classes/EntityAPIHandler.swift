//
//  EntityAPIHandler.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 16/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

internal class EntityAPIHandler : CommonAPIHandler
{
    internal var record : ZCRMRecord
    var recordDelegate : ZCRMRecordDelegate
    private var moduleFields : [ String : ZCRMField ]?
    private var subformModuleFields : [ String : [ String : ZCRMField ]?] = [ String : [ String : ZCRMField]]()
    internal let moduleFieldQueue = DispatchQueue( label : "com.zoho.crm.EntityAPIHandler.record.properties", qos : .utility, attributes : .concurrent )
    internal var requestHeaders : [ String : String ]?

    init(record : ZCRMRecord, requestHeaders : [ String : String ]? = nil)
    {
        self.record = record
        self.requestHeaders = requestHeaders
        self.recordDelegate = RECORD_DELEGATE_MOCK
    }
    
    init( recordDelegate : ZCRMRecordDelegate, requestHeaders : [ String : String ]? = nil )
    {
        self.recordDelegate = recordDelegate
        self.record = ZCRMRecord( moduleAPIName : self.recordDelegate.moduleAPIName )
        self.requestHeaders = requestHeaders
    }
    
    init(record : ZCRMRecord, moduleFields : [String:ZCRMField], requestHeaders : [ String : String ]? = nil)
    {
        self.record = record
        self.moduleFields = moduleFields
        self.requestHeaders = requestHeaders
        self.recordDelegate = RECORD_DELEGATE_MOCK
    }
    
    override func setModuleName() {
        self.requestedModule = recordDelegate.moduleAPIName
    }
    
	// MARK: - Handler Functions
    internal func isFieldsAPIRequestNeeded( recordDetails : [ String : Any? ] ) -> Bool
    {
        var isFieldsAPINeeded = false
        for ( _, value ) in recordDetails
        {
            if value is [ Any ] || value is [ String : Any ]
            {
                isFieldsAPINeeded = true
                break
            }
        }
        return isFieldsAPINeeded
    }
    
    internal func getRecord( withPrivateFields : Bool, completion : @escaping( ZCRMResult.DataResponse< ZCRMRecord, APIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.DATA )
        let urlPath = "\( self.record.moduleAPIName )/\( self.recordDelegate.id )"
        setUrlPath(urlPath : urlPath )
//        if ZCRMSDKClient.shared.isInternal
//        {
//            setAPIVersion("v2.2")
//        }
        if( withPrivateFields == true )
        {
            addRequestParam( param : RequestParamKeys.include, value : APIConstants.PRIVATE_FIELDS )
        }
        if let requestHeaders = requestHeaders
        {
            for ( key, value ) in requestHeaders
            {
                addRequestHeader(header: key, value: value)
            }
        }
		setRequestMethod(requestMethod : .get)
		let request : APIRequest = APIRequest(handler: self)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        var zcrmFields : [ ZCRMField ]?
        var apiResponse : APIResponse?
        var recordAPIError : Error?
        var fieldsAPIError : Error?
        var zcrmTags : [ ZCRMTag ]?
        var tagsAPIError : Error?
        let dispatchGroup : DispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        let moduleDelegate : ZCRMModuleDelegate = ZCRMModuleDelegate(apiName: record.moduleAPIName)
        ModuleAPIHandler(module: moduleDelegate, cacheFlavour: .urlVsResponse).getAllFields(modifiedSince: nil) { result in
            switch result
            {
            case .success(let fields, _) :
                zcrmFields = fields
            case .failure(let error) :
                fieldsAPIError = error
            }
            dispatchGroup.leave()
        }
        
        if ZCRMSDKClient.shared.orgLicensePlan != FREE_PLAN
        {
            dispatchGroup.enter()
            TagAPIHandler(module: moduleDelegate).getTags() { result in
                
                switch result
                {
                case .success(let tags, _) :
                    zcrmTags = tags
                case .failure(let error) :
                    tagsAPIError = error
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        request.getAPIResponse { ( resultType ) in
            switch resultType
            {
            case .success(let response) :
                apiResponse = response
            case .failure(let error) :
                recordAPIError = error
            }
            dispatchGroup.leave()
        }
        dispatchGroup.notify( queue : OperationQueue.current?.underlyingQueue ?? .global() ) {
            if let recordAPIError = recordAPIError
            {
                ZCRMLogger.logError( message : "\( recordAPIError )" )
                completion( .failure( typeCastToZCRMError( recordAPIError ) ) )
                return
            }
            else if let fieldsAPIError = fieldsAPIError
            {
                ZCRMLogger.logError( message : "\( fieldsAPIError )" )
                completion( .failure( typeCastToZCRMError( fieldsAPIError ) ) )
                return
            }
            else if let tagsAPIError = tagsAPIError {
                ZCRMLogger.logError(message: "\( tagsAPIError )")
            }
            
            if let fields = zcrmFields, let apiResponse = apiResponse, let recordDetails = ( apiResponse.responseJSON[ self.getJSONRootKey() ] as? [ [ String : Any ] ] )?.first
            {
                self.moduleFields = getFieldVsApinameJSON(fields: fields)
                self.getLatestFields(forRecord: recordDetails, fields: fields) { updatedFields, error in
                    if let error = error
                    {
                        completion( .failure( error ) )
                        return
                    }
                    self.getSubformFields(fields: updatedFields, recordDetails: recordDetails) { ( subformFieldDetails, error ) in
                        if let error = error
                        {
                            ZCRMLogger.logError( message : "\( error )" )
                            completion( .failure( typeCastToZCRMError( error ) ) )
                            return
                        }
                        EntityAPIHandler(record: self.record, moduleFields: getFieldVsApinameJSON(fields: updatedFields) ).setRecordProperties(recordDetails: recordDetails, subformFieldDetails: subformFieldDetails,tags:zcrmTags, completion: { ( recordResult ) in
                            switch recordResult
                            {
                            case .success(let record) :
                                record.upsertJSON = [:]
                                completion( .success( record, apiResponse ) )
                            case .failure(let error) :
                                ZCRMLogger.logError( message : "\( error )" )
                                completion( .failure( typeCastToZCRMError( error ) ) )
                            }
                        })
                    }
                }
            }
            else
            {
                ZCRMLogger.logError(message: "\(ZCRMErrorCode.mandatoryNotFound) : Record details must not be nil, \( APIConstants.DETAILS ) : -")
                completion( .failure( ZCRMError.processingError( code : ZCRMErrorCode.mandatoryNotFound, message : "Record details must not be nil", details : nil ) ) )
            }
        }
    }
    
    internal func getSubformFields( fields : [ ZCRMField ], recordDetails : [ String : Any ], completion : @escaping ( [ String : [ ZCRMField ] ], ZCRMError? ) -> () )
    {
        let dispatchGroup : DispatchGroup = DispatchGroup()
        let dispatchQueue : DispatchQueue = DispatchQueue(label: "com.zoho.crm.sdk.EntityAPIHandler.getSubformFields")
        var subformFieldDetails : [ String : [ ZCRMField ] ] = [:]
        var subformAPIerror : ZCRMError? = nil
        for field in fields
        {
            let fieldAPIName = field.apiName
            if field.dataType == FieldDataTypeConstants.subform, !( recordDetails[ fieldAPIName ] as? [ [ String : Any ] ] ?? [] ).isEmpty
            {
                let moduleDelegate = ZCRMModuleDelegate(apiName: fieldAPIName)
                dispatchGroup.enter()
                ModuleAPIHandler(module: moduleDelegate, cacheFlavour: .urlVsResponse).getAllFields( modifiedSince: nil) { result in
                    switch result
                    {
                    case .success(let fields, _) :
                        dispatchQueue.sync
                        {
                            subformFieldDetails.updateValue( fields, forKey: fieldAPIName)
                            dispatchGroup.leave()
                        }
                    case .failure(let error) :
                        subformAPIerror = error
                        dispatchGroup.leave()
                    }
                }
            }
        }
        dispatchGroup.notify( queue : OperationQueue.current?.underlyingQueue ?? .global() ) {
            completion( subformFieldDetails, subformAPIerror )
        }
    }
    
    private func makeRecordRequest( reqBody : [ String : Any? ], completion : @escaping ( ZCRMResult.DataResponse< ZCRMRecord, APIResponse > ) -> () )
    {
        let request : APIRequest = APIRequest(handler : self)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        var zcrmFields : [ ZCRMField ]?
        var apiResponse : APIResponse?
        var recordAPIError : Error?
        var fieldsAPIError : Error?
        let dispatchGroup : DispatchGroup = DispatchGroup()
        if isFieldsAPIRequestNeeded(recordDetails: reqBody)
        {
            dispatchGroup.enter()
            let moduleDelegate : ZCRMModuleDelegate = ZCRMModuleDelegate(apiName: record.moduleAPIName)
            ModuleAPIHandler(module: moduleDelegate, cacheFlavour: .urlVsResponse).getAllFields( modifiedSince: nil) { result in
                switch result
                {
                case .success(let fields, _) :
                    zcrmFields = fields
                case .failure(let error) :
                    fieldsAPIError = error
                }
                dispatchGroup.leave()
            }
        }
        dispatchGroup.enter()
        request.getAPIResponse { ( resultType ) in
            switch resultType
            {
            case .success(let response) :
                apiResponse = response
            case .failure(let error) :
                recordAPIError = error
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify( queue : OperationQueue.current?.underlyingQueue ?? .global() ) {
            if let recordAPIError = recordAPIError
            {
                ZCRMLogger.logError( message : "\( recordAPIError )" )
                completion( .failure( typeCastToZCRMError( recordAPIError ) ) )
                return
            }
            else if let fieldsAPIError = fieldsAPIError
            {
                ZCRMLogger.logError( message : "\( fieldsAPIError )" )
                completion( .failure( typeCastToZCRMError( fieldsAPIError ) ) )
                return
            }
            if let apiResponse = apiResponse, let recordDetails = apiResponse.getResponseJSON().optArrayOfDictionaries(key: self.getJSONRootKey())?.first?.optDictionary( key : APIConstants.DETAILS )
            {
                for ( key, value ) in self.record.upsertJSON
                {
                    if getFieldVsApinameJSON(fields: zcrmFields ?? [])[ key ]?.dataType != FieldDataTypeConstants.multiSelectLookup
                    {
                        self.record.data.updateValue( value, forKey : key )
                    }
                }
                self.getLatestFields(forRecord: recordDetails, fields: zcrmFields) { updatedFields, error in
                    if let error = error
                    {
                        completion( .failure( typeCastToZCRMError( error ) ) )
                        return
                    }
                    self.moduleFieldQueue.async {
                        let entityAPIHandler = EntityAPIHandler(record: self.record)
                        if !updatedFields.isEmpty
                        {
                            entityAPIHandler.moduleFields = getFieldVsApinameJSON(fields: updatedFields)
                        }
                        entityAPIHandler.setRecordProperties(recordDetails: recordDetails, completion: { ( recordResult ) in
                            switch recordResult
                            {
                            case .success(let record) :
                                apiResponse.setData(data: record)
                                self.record.upsertJSON = [ String : Any? ]()
                                self.record.isCreate = false
                                completion( .success( record, apiResponse ) )
                            case .failure(let error) :
                                ZCRMLogger.logError( message : "\( error )" )
                                completion( .failure( typeCastToZCRMError( error ) ) )
                            }
                        })
                    }
                }
            }
            else
            {
                ZCRMLogger.logError(message: "\(ZCRMErrorCode.mandatoryNotFound) : Record details must not be nil, \( APIConstants.DETAILS ) : -")
                completion( .failure( ZCRMError.processingError( code : ZCRMErrorCode.mandatoryNotFound, message : "Record details must not be nil", details : nil ) ) )
            }
        }
    }
    
    internal func createRecord( triggers : [ZCRMTrigger]?, completion : @escaping( ZCRMResult.DataResponse< ZCRMRecord, APIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.DATA )
        var reqBodyObj : [ String : Any? ] = [ String : Any? ]()
        var dataArray : [ [ String : Any? ] ] = [ [ String : Any? ] ]()
        let requestBody = self.getZCRMRecordAsJSON()
        dataArray.append( requestBody )
        reqBodyObj[ getJSONRootKey() ] = dataArray
        if let triggers = triggers
        {
            reqBodyObj[ APIConstants.TRIGGER ] = getTriggerArray(triggers: triggers)
        }
		
		setUrlPath(urlPath : "\(self.record.moduleAPIName)")
		setRequestMethod(requestMethod : .post)
		setRequestBody(requestBody : reqBodyObj)
        
        makeRecordRequest(reqBody: requestBody, completion: completion)
    }
    
    internal func updateRecord( triggers : [ZCRMTrigger]?, headers : [ String : String ]? = nil, completion : @escaping( ZCRMResult.DataResponse< ZCRMRecord, APIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.DATA )
        if self.record.isCreate
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.mandatoryNotFound) : RECORD ID must not be nil, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code : ZCRMErrorCode.mandatoryNotFound, message : "RECORD ID must not be nil", details : nil ) ) )
            return
        }
        var reqBodyObj : [ String : Any? ] = [ String : Any? ]()
        var dataArray : [ [ String : Any? ] ] = [ [ String : Any? ] ]()
        let requestBody = self.getZCRMRecordAsJSON()
        dataArray.append( requestBody )
        reqBodyObj[ getJSONRootKey() ] = dataArray
        if let triggers = triggers
        {
            reqBodyObj[ APIConstants.TRIGGER ] = getTriggerArray(triggers: triggers)
        }
        
        setUrlPath( urlPath : "\( self.record.moduleAPIName )/\( self.record.id )" )
        setRequestMethod( requestMethod : .patch )
        setRequestBody( requestBody : reqBodyObj )
        if let requestHeaders = headers
        {
            for ( key, value ) in requestHeaders
            {
                addRequestHeader(header: key, value: value)
            }
        }
        
        makeRecordRequest(reqBody: requestBody, completion: completion)
    }
    
    internal func deleteRecord( completion : @escaping( ZCRMResult.Response< APIResponse > ) -> () )
    {
		setUrlPath( urlPath : "\( self.recordDelegate.moduleAPIName )/\( self.recordDelegate.id )" )
		setRequestMethod(requestMethod : .delete )
		let request : APIRequest = APIRequest(handler : self )
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

    internal func convertRecord( newPotential : ZCRMRecord?, assignTo : ZCRMUser?, completion : @escaping( ZCRMResult.DataResponse< [ String : Int64 ], APIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.DATA )
        var reqBodyObj : [ String : [ [ String : Any? ] ] ] = [ String : [ [ String : Any? ] ] ]()
        var dataArray : [ [ String : Any? ] ] = [ [ String : Any? ] ]()
        var convertData : [ String : Any? ] = [ String : Any? ]()
        if let assignToUser = assignTo
        {
            if (ZCRMSDKClient.shared.apiVersion < APIConstants.API_VERSION_V4)
            {
                convertData[RequestParamKeys.assignTo] = String(assignToUser.id)
            }
            else
            {
                var idDictionary = [String: String]()
                idDictionary[ResponseJSONKeys.id] = String(assignToUser.id)
                convertData[RequestParamKeys.assignTo] = idDictionary
            }
        }
        if let potential = newPotential
        {
            convertData[ZCRMDefaultModuleAPINames.DEALS] = EntityAPIHandler(record: potential).getZCRMRecordAsJSON()
        }
        dataArray.append(convertData)
        reqBodyObj[getJSONRootKey()] = dataArray
        
        setUrlPath( urlPath : "\( self.record.moduleAPIName )/\( self.recordDelegate.id )/\( URLPathConstants.actions )/\( URLPathConstants.convert )" )
        setRequestMethod(requestMethod : .post )
        setRequestBody(requestBody : reqBodyObj )
        let request : APIRequest = APIRequest(handler : self)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getAPIResponse { ( resultType ) in
            do{
                let response = try resultType.resolve()
                let responseJSON : [String:Any] = response.getResponseJSON()
                let respDataArr : [ [ String : Any ] ] = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey())
                let respData : [String:Any] = respDataArr[0]
                var convertedDetails : [String:Int64] = [String:Int64]()
                if ( !respData.hasKey(forKey: "details") )
                {
                    if ( respData.hasValue( forKey : ZCRMDefaultModuleAPINames.ACCOUNTS ) )
                    {
                        convertedDetails.updateValue( try respData.getInt64( key : ZCRMDefaultModuleAPINames.ACCOUNTS ) , forKey : ZCRMDefaultModuleAPINames.ACCOUNTS )
                    }
                    if ( respData.hasValue( forKey : ZCRMDefaultModuleAPINames.DEALS ) )
                    {
                        convertedDetails.updateValue( try respData.getInt64( key : ZCRMDefaultModuleAPINames.DEALS ) , forKey : ZCRMDefaultModuleAPINames.DEALS )
                    }
                    convertedDetails.updateValue( try respData.getInt64( key : ZCRMDefaultModuleAPINames.CONTACTS ) , forKey : ZCRMDefaultModuleAPINames.CONTACTS )
                }
                else
                {
                    let detailsJson = try respData.getDictionary(key: "details")
                    if ( detailsJson.hasValue( forKey : ZCRMDefaultModuleAPINames.ACCOUNTS ) )
                    {
                        let accountsJson = try detailsJson.getDictionary(key: ZCRMDefaultModuleAPINames.ACCOUNTS)
                        convertedDetails.updateValue( try accountsJson.getInt64( key : ResponseJSONKeys.id ) , forKey : ZCRMDefaultModuleAPINames.ACCOUNTS )
                    }
                    if ( detailsJson.hasValue( forKey : ZCRMDefaultModuleAPINames.DEALS ) )
                    {
                        let dealsJson = try detailsJson.getDictionary(key: ZCRMDefaultModuleAPINames.DEALS)
                        convertedDetails.updateValue( try dealsJson.getInt64( key : ResponseJSONKeys.id ) , forKey : ZCRMDefaultModuleAPINames.DEALS )
                    }
                    let contactsJson = try detailsJson.getDictionary(key: ZCRMDefaultModuleAPINames.CONTACTS)
                    convertedDetails.updateValue( try contactsJson.getInt64( key : ResponseJSONKeys.id ) , forKey : ZCRMDefaultModuleAPINames.CONTACTS )
                }
                completion( .success( convertedDetails, response ) )
            }
            catch{
                ZCRMLogger.logError( message : "\( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func buildUploadPhotoRequest(filePath : String?, fileName : String?, fileData : Data?) throws {
        do
        {
            try fileDetailsCheck( filePath : filePath, fileData : fileData, maxFileSize: .entityImageAttachment )
            try imageTypeValidation( filePath )
        }
        catch
        {
            throw error
        }
        
        setJSONRootKey( key : JSONRootKey.NIL )
        setUrlPath( urlPath :"\( self.recordDelegate.moduleAPIName )/\( self.recordDelegate.id )/\( URLPathConstants.photo )" )
        setRequestMethod(requestMethod : .post )
    }
    
    internal func uploadPhoto( filePath : String?, fileName : String?, fileData : Data?, completion : @escaping( ZCRMResult.Response< APIResponse > )->Void )
    {
        do {
            try buildUploadPhotoRequest(filePath: filePath, fileName: fileName, fileData: fileData)
            let request : FileAPIRequest = FileAPIRequest(handler: self)
            ZCRMLogger.logDebug(message: "Request : \(request.toString())")
            if let filePath = filePath
            {
                request.uploadFile( filePath : filePath, entity : nil) { ( resultType ) in
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
            else if let fileName = fileName, let fileData = fileData
            {
                request.uploadFile( fileName : fileName, entity : nil, fileData : fileData ) { ( resultType ) in
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
        } catch {
            ZCRMLogger.logError( message : "\( error )" )
            completion( .failure(typeCastToZCRMError( error )))
        }
    }
    
    internal func uploadPhoto( fileRefId : String, filePath : String?, fileName : String?, fileData : Data?,  fileUploadDelegate : ZCRMFileUploadDelegate )
    {
        do
        {
            try buildUploadPhotoRequest(filePath: filePath, fileName: fileName, fileData: fileData)
            let request : FileAPIRequest = FileAPIRequest( handler : self, fileUploadDelegate : fileUploadDelegate)
            ZCRMLogger.logDebug(message: "Request : \(request.toString())")
            
            request.uploadFile(fileRefId: fileRefId, filePath: filePath, fileName: fileName, fileData: fileData, entity: nil) { _,_ in }
        }
        catch
        {
            ZCRMLogger.logError( message : "\( error )" )
            fileUploadDelegate.didFail( fileRefId : fileRefId, typeCastToZCRMError( error ) )
            return
        }
        
    }
    
    internal func downloadPhoto( withHeaders : [ String : String ]? = nil, completion : @escaping( ZCRMResult.Response< FileAPIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.NIL )
        setUrlPath( urlPath : "\( self.recordDelegate.moduleAPIName )/\( self.recordDelegate.id )/\( URLPathConstants.photo )" )
        setRequestMethod(requestMethod : .get )
        if let requestHeaders = withHeaders
        {
            for ( key, value ) in requestHeaders
            {
                addRequestHeader(header: key, value: value)
            }
        }
        let request : FileAPIRequest = FileAPIRequest(handler: self)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.downloadFile { ( resultType ) in
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
    
    internal func downloadPhoto( withHeaders: [ String : String ]? = nil, fileDownloadDelegate : ZCRMFileDownloadDelegate )
    {
        setJSONRootKey( key : JSONRootKey.NIL )
        setUrlPath( urlPath : "\( self.recordDelegate.moduleAPIName )/\( self.recordDelegate.id )/\( URLPathConstants.photo )" )
        setRequestMethod(requestMethod : .get )
        if let requestHeaders = withHeaders
        {
            for ( key, value ) in requestHeaders
            {
                addRequestHeader(header: key, value: value)
            }
        }
        
        let request : FileAPIRequest = FileAPIRequest(handler: self, fileDownloadDelegate: fileDownloadDelegate)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        request.downloadFile( fileRefId: String( self.recordDelegate.id ) )
    }

    internal func deletePhoto( completion : @escaping( ZCRMResult.Response< APIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.NIL )
        setUrlPath( urlPath : "\( self.recordDelegate.moduleAPIName )/\( self.recordDelegate.id )/\( URLPathConstants.photo )" )
        setRequestMethod(requestMethod : .delete )
        let request : APIRequest = APIRequest(handler : self )
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
    
    // TODO : Add response object as List of Tags when overwrite false case is fixed
    internal func addTags( tags : [ String ], overWrite : Bool?, completion : @escaping( ZCRMResult.DataResponse< ZCRMRecord, APIResponse > ) -> () )
    {
        setJSONRootKey(key: JSONRootKey.DATA)
        let moduleAPIName = self.recordDelegate.moduleAPIName
        setUrlPath( urlPath : "\( moduleAPIName )/\( recordDelegate.id )/\( URLPathConstants.actions )/\( URLPathConstants.addTags )" )
        setRequestMethod(requestMethod: .post)
        if ZCRMSDKClient.shared.apiVersion <= "v2.1"
        {
            addRequestParam(param: RequestParamKeys.tagNames, value: tags.joined(separator: ",") )
        }
        else
        {
            setRequestBody(requestBody: [ JSONRootKey.TAGS : tags.map{ [ ResponseJSONKeys.name : $0 ] } ])
        }
        if let overWrite = overWrite
        {
            addRequestParam( param : RequestParamKeys.overWrite, value : String( overWrite ) )
        }
        
        let request : APIRequest = APIRequest(handler: self)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getAPIResponse { ( resultType ) in
            do{
                let response = try resultType.resolve()
                let responseJSON : [ String : Any ] = response.getResponseJSON()
                let respDataArr : [ [ String : Any ] ] = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                let tagDetails = try respDataArr[ 0 ].getDictionary( key : APIConstants.DETAILS )
                if let tags = try tagDetails.getArray( key : JSONRootKey.TAGS ) as? [ String ]
                {
                    self.record.tags = [ ZCRMTagDelegate ]()
                    for tag in tags
                    {
                        let tagDelegate = ZCRMTagDelegate(name: tag)
                        self.record.tags?.append( tagDelegate )
                    }
                }
                else
                {
                    let tags = try tagDetails.getArrayOfDictionaries(key: JSONRootKey.TAGS)
                    self.record.tags = [ ZCRMTagDelegate ]()
                    for tag in tags
                    {
                        let tagDelegate = ZCRMTagDelegate(name: try tag.getString(key: ResponseJSONKeys.name))
                        tagDelegate.colorCode = tag.optString(key: ResponseJSONKeys.colorCode)
                        self.record.tags?.append( tagDelegate )
                    }
                }
                self.record.id = self.recordDelegate.id
                completion( .success( self.record, response ) )
            }
            catch{
                ZCRMLogger.logError( message : "\( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func addTags( tags : [ ZCRMTagDelegate ], overWrite : Bool?, completion : @escaping( ZCRMResult.DataResponse< ZCRMRecord, APIResponse > ) -> () )
    {
        setJSONRootKey(key: JSONRootKey.DATA)
        setUrlPath( urlPath : "\( record.moduleAPIName )/\( record.id )/\( URLPathConstants.actions )/\( URLPathConstants.addTags )" )
        setRequestMethod(requestMethod: .post)
        if ZCRMSDKClient.shared.apiVersion <= "v2.1"
        {
            addRequestParam(param: RequestParamKeys.tagNames, value: tags.map{ $0.name }.joined(separator: ",") )
        }
        else
        {
            setRequestBody(requestBody: [ JSONRootKey.TAGS : tags.map{ [ ResponseJSONKeys.name : $0.name, ResponseJSONKeys.colorCode : $0.colorCode ] } ])
        }
        if let overWrite = overWrite
        {
            addRequestParam( param : RequestParamKeys.overWrite, value : String( overWrite ) )
        }
        
        let request : APIRequest = APIRequest(handler: self)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getAPIResponse() { result in
            switch result
            {
            case .success(let response) :
                guard let recordDetails = ( response.responseJSON[ self.getJSONRootKey() ] as? [ [ String : Any ] ] )?.first else
                {
                    ZCRMLogger.logError(message: "\(ZCRMErrorCode.mandatoryNotFound) : Record details must not be nil, \( APIConstants.DETAILS ) : -")
                    completion( .failure( ZCRMError.processingError( code : ZCRMErrorCode.mandatoryNotFound, message : "Record details must not be nil", details : nil ) ) )
                    return
                }
                do
                {
                    var existingTags : [ ZCRMTagDelegate ] = self.record.tags ?? []
                    let existingTagNames : [ String ] = existingTags.map{ $0.name }
                    let tagDetails = try recordDetails.getDictionary( key : APIConstants.DETAILS )
                    var tagNames : [ String ] = []
                    if let tagsInResponse = try tagDetails.getArray( key : JSONRootKey.TAGS ) as? [ String ]
                    {
                        tagNames = tagsInResponse
                    }
                    else
                    {
                        tagNames = try tagDetails.getArrayOfDictionaries(key: JSONRootKey.TAGS).map{ try $0.getString(key: ResponseJSONKeys.name) }
                    }
                    for tag in tags
                    {
                        if !existingTagNames.contains( tag.name) && tagNames.contains( tag.name )
                        {
                            existingTags.append( tag )
                        }
                    }
                    self.record.tags = existingTags
                    completion( .success( self.record, response ) )
                }
                catch
                {
                    ZCRMLogger.logError( message : "\( error )" )
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            case .failure(let error) :
                ZCRMLogger.logError( message : "\( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func removeTags( tags removableTags: [ String ], completion : @escaping( ZCRMResult.DataResponse< ZCRMRecord, APIResponse > ) -> () )
    {
        setJSONRootKey(key: JSONRootKey.DATA)
        setUrlPath( urlPath : "\( record.moduleAPIName )/\( record.id )/\( URLPathConstants.actions )/\( URLPathConstants.removeTags )" )
        setRequestMethod(requestMethod: .post)
        if ZCRMSDKClient.shared.apiVersion <= "v2.1"
        {
            addRequestParam(param: RequestParamKeys.tagNames, value: removableTags.joined(separator: ","))
        }
        else
        {
            setRequestBody(requestBody: [ JSONRootKey.TAGS : removableTags.map{ [ ResponseJSONKeys.name : $0 ] } ])
        }
        
        let request : APIRequest = APIRequest(handler: self)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getAPIResponse() { result in
            switch result
            {
            case .success(let response) :
                guard let recordDetails = response.responseJSON.optArrayOfDictionaries(key: self.getJSONRootKey())?.first else
                {
                    ZCRMLogger.logError(message: "\(ZCRMErrorCode.mandatoryNotFound) : Record details must not be nil, \( APIConstants.DETAILS ) : -")
                    completion( .failure( ZCRMError.processingError( code : ZCRMErrorCode.mandatoryNotFound, message : "Record details must not be nil", details : nil ) ) )
                    return
                }
                do
                {
                    let tagDetails = try recordDetails.getDictionary( key : APIConstants.DETAILS )
                    var updatedTags : [ ZCRMTagDelegate ] = []
                    if let tags : [ String ] = tagDetails.optValue( key : JSONRootKey.TAGS )
                    {
                        for tag in self.record.tags ?? []
                        {
                            if !removableTags.contains( tag.name ) && tags.contains( tag.name )
                            {
                                updatedTags.append( tag )
                            }
                        }
                    }
                    else if let tags : [ [ String : String ] ] = tagDetails.optValue(key: JSONRootKey.TAGS)
                    {
                        let tagNames = try tags.map{ try $0.getString(key: ResponseJSONKeys.name) }
                        for tag in self.record.tags ?? []
                        {
                            if !removableTags.contains( tag.name ) && tagNames.contains( tag.name )
                            {
                                updatedTags.append( tag )
                            }
                        }
                    }
                    self.record.tags = updatedTags
                    completion( .success( self.record, response ) )
                }
                catch
                {
                    ZCRMLogger.logError( message : "\( error )" )
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            case .failure(let error) :
                ZCRMLogger.logError( message : "\( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func getBlueprintStateDetails( completion : @escaping ( ZCRMResult.DataResponse< ZCRMBlueprintState, APIResponse > ) -> () )
    {
        setUrlPath(urlPath: "\( record.moduleAPIName )/\( record.id )/\( URLPathConstants.actions )/\( URLPathConstants.blueprint )")
        setRequestMethod(requestMethod: .get)
        setJSONRootKey(key: JSONRootKey.BLUEPRINT)
        
        let request : APIRequest = APIRequest(handler: self)
        ZCRMLogger.logDebug(message: "\(request.toString())")
        
        request.getAPIResponse() { result in
            switch result
            {
            case .success(let response) :
                do
                {
                    let responseJSON = response.getResponseJSON()
                    let blueprintDetails = try responseJSON.getDictionary(key: self.getJSONRootKey())
                    let blueprint = try self.getBlueprintStateDetails(fromJSON: blueprintDetails)
                    completion( .success( blueprint, response) )
                }
                catch
                {
                    ZCRMLogger.logError( message : "\( error )" )
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            case .failure(let error) :
                ZCRMLogger.logError( message : "\( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func applyStateTransition( transition : ZCRMBlueprintState.Transition, completion : @escaping ( ZCRMResult.Response< APIResponse > ) -> () )
    {
        setUrlPath(urlPath: "\( record.moduleAPIName )/\( record.id )/\( URLPathConstants.actions )/\( URLPathConstants.blueprint )")
        setRequestMethod(requestMethod: .patch)
        setJSONRootKey(key: JSONRootKey.BLUEPRINT)
        do
        {
            setRequestBody(requestBody: try getUpdateBlueprintStateDetails( transition ))
        }
        catch
        {
            ZCRMLogger.logError( message : "\( error )" )
            completion( .failure( typeCastToZCRMError( error ) ) )
            return
        }
        
        let request : APIRequest = APIRequest(handler: self)
        ZCRMLogger.logDebug(message: "\(request.toString())")
        
        request.getAPIResponse() { result in
            switch result
            {
            case .success(let response) :
                completion( .success( response ) )
            case .failure(let error) :
                ZCRMLogger.logError( message : "\( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
	
	// MARK: - Utility Functions
    
    private func getBlueprintStateDetails( fromJSON : [ String : Any ] ) throws -> ZCRMBlueprintState
    {
        let processInfo = try fromJSON.getDictionary(key: ResponseJSONKeys.processInfo)
        let currentState = try processInfo.getString(key: ResponseJSONKeys.currentState)
        let isContinuous = try processInfo.getBoolean(key: ResponseJSONKeys.isContinuous)
        
        var blueprint = ZCRMBlueprintState(currentState: currentState, isContinuous: isContinuous)
        if let escalationDetails = processInfo.optDictionary(key: ResponseJSONKeys.escalation)
        {
            guard let days = try Int( escalationDetails.getString(key: ResponseJSONKeys.days) ) else
            {
                ZCRMLogger.logError(message: "\(ZCRMErrorCode.typeCastError) : \( ResponseJSONKeys.days ) - Expected type -> INT, \( APIConstants.DETAILS ) : -")
                throw ZCRMError.processingError( code : ZCRMErrorCode.typeCastError, message : "\( ResponseJSONKeys.days ) - Expected type -> INT", details : nil )
            }
            let status = try escalationDetails.getString(key: ResponseJSONKeys.status)
            blueprint.escalation = ZCRMBlueprintState.EscalationDetails(days: days, status: status)
        }
        if let transitionDetails = fromJSON.optArrayOfDictionaries(key: ResponseJSONKeys.transitions)
        {
            blueprint.transitionDetails = try getTransitionStateDetailsList( transitionDetails, isContinuous : isContinuous )
        }
        return blueprint
    }
    
    private func getTransitionStateDetailsList( _ transitions : [[ String : Any ]], isContinuous : Bool ) throws -> [ ZCRMBlueprintState.Transition ]
    {
        var transitionDetails : [ ZCRMBlueprintState.Transition ] = []
        
        for transition in transitions
        {
            let id = try transition.getInt64(key: ResponseJSONKeys.id)
            let isCriteriaMatched = try transition.getBoolean(key: ResponseJSONKeys.criteriaMatched)
            let name = try transition.getString(key: ResponseJSONKeys.name)
            let nextFieldValue = try transition.getString(key: ResponseJSONKeys.nextFieldValue )
            let fields = try ModuleAPIHandler(module: ZCRMModuleDelegate(apiName: record.moduleAPIName), cacheFlavour: .urlVsResponse).getAllFieldDelegates(fieldsList: transition.getArrayOfDictionaries(key: ResponseJSONKeys.fields))
            let data = try parseBlueprintData(fromJSON: transition.optDictionary(key: ResponseJSONKeys.data) ?? [:], fieldDetails: fields )
            let partialSavePercentage = try transition.getDouble(key: ResponseJSONKeys.percentPartialSave)
            let type = try ZCRMBlueprintState.TransitionType(rawValue: transition.getString(key: ResponseJSONKeys.type)) ?? .manual
            
            let blueprintTransition = ZCRMBlueprintState.Transition(id: id, name: name, nextFieldValue: nextFieldValue, type: type, data: data, partialSavePercentage: partialSavePercentage, fields: fields)
            blueprintTransition.isCriteriaMatched = isCriteriaMatched
            blueprintTransition.criteriaMessage = transition.optString(key: ResponseJSONKeys.criteriaMessage)
            if isContinuous
            {
                blueprintTransition.nextTransition = try getNextStateTransitions( transition.getArrayOfDictionaries(key: ResponseJSONKeys.nextTransitions) )
            }
            blueprintTransition.autoTransitionTime = transition.optString(key: ResponseJSONKeys.executionTime)
            transitionDetails.append( blueprintTransition )
        }
        return transitionDetails
    }
    
    internal func parseBlueprintData( fromJSON : [ String : Any ], fieldDetails : [ ZCRMFieldDelegate ] ) throws -> [ String : Any ]
    {
        var updateDataDetails : [ String : Any ] = fromJSON
        let fieldDelegateVsAPIName = getFieldDelegateVsApinameJSON(fieldDelegates: fieldDetails)
        for ( key, value ) in updateDataDetails
        {
            if let value = value as? [ String : Any ]
            {
                if fieldDelegateVsAPIName[ key ]?.dataType == FieldDataTypeConstants.userLookup || fieldDelegateVsAPIName[ key ]?.dataType == FieldDataTypeConstants.ownerLookup
                {
                    let userDelegate = try ZCRMUserDelegate(id: value.optValue(key: ResponseJSONKeys.id) ?? value.getInt64(key: ResponseJSONKeys.id), name: value.getString(key: ResponseJSONKeys.name))
                    userDelegate.data = value
                    updateDataDetails.updateValue( userDelegate, forKey: key)
                }
                else if fieldDelegateVsAPIName[ key ]?.dataType == FieldDataTypeConstants.lookup, let lookupModule = fieldDelegateVsAPIName[ key ]?.lookupModule
                {
                    let lookupRecord : ZCRMRecordDelegate = try EntityAPIHandler.getRecordDelegate(moduleAPIName: lookupModule, recordJSON: value)
                    updateDataDetails.updateValue( lookupRecord, forKey: key)
                }
                else
                {
                    try updateDataDetails.updateValue( parseBlueprintData(fromJSON: value, fieldDetails: fieldDetails), forKey: key )
                }
            }
            else if let value = value as? [ Any ]
            {
                try updateDataDetails.updateValue( parseBlueprintData(fromArray: value, fieldDetails: fieldDetails), forKey: key )
            }
            else if fieldDelegateVsAPIName[ key ]?.dataType == FieldDataTypeConstants.multiSelectPicklist
            {
                if let picklistValues = value as? String
                {
                    updateDataDetails.updateValue(picklistValues.split(separator: ";").map{ "\( $0 )" }, forKey: key)
                }
            }
        }
        return updateDataDetails
    }
    
    internal func parseBlueprintData( fromArray : [ Any ], fieldDetails : [ ZCRMFieldDelegate ] ) throws -> [ Any ]
    {
        var dataArray : [ Any ] = []
        for value in fromArray
        {
            if let value = value as? [ Any ]
            {
                try dataArray.append( parseBlueprintData(fromArray: value, fieldDetails: fieldDetails) )
            }
            else if let value = value as? [ String : Any ]
            {
                try dataArray.append( parseBlueprintData(fromJSON: value, fieldDetails: fieldDetails) )
            }
            else
            {
                dataArray.append( value )
            }
        }
        return dataArray
    }
    
    private func getModuleRelation( _ relatedDetails : [ String : Any ] ) throws -> ZCRMModuleRelationDelegate
    {
        let moduleRelation = ZCRMModuleRelationDelegate()
        
        moduleRelation.id = try relatedDetails.getInt64(key: ResponseJSONKeys.id)
        moduleRelation.apiName = try relatedDetails.getString( key : ResponseJSONKeys.apiName )
        moduleRelation.label = try relatedDetails.getString( key : ResponseJSONKeys.displayLabel )
        return moduleRelation
    }
    
    private func getNextStateTransitions( _ nextTransitionsJSON : [[ String : Any ]]) throws -> [ ZCRMBlueprintState.TransitionDelegate ]
    {
        var nextTransitions : [ ZCRMBlueprintState.TransitionDelegate ] = []
        for transition in nextTransitionsJSON
        {
            let id = try transition.getInt64(key: ResponseJSONKeys.id)
            let name = try transition.getString(key: ResponseJSONKeys.name)
            let type = try ZCRMBlueprintState.TransitionType(rawValue: transition.getString(key: ResponseJSONKeys.type) ) ?? .manual
            let isCriteriaMatched = transition.optBoolean(key: ResponseJSONKeys.criteriaMatched)
            
            let nextTransition = ZCRMBlueprintState.TransitionDelegate(id: id, name: name, type: type)
            nextTransition.isCriteriaMatched = isCriteriaMatched
            nextTransitions.append( nextTransition )
        }
        return nextTransitions
    }
    
    /**
      To move a record from one state of the blueprint flow to another
     
     - File attachment Ids passed in data has to be in format
       ~~~
       "$file_id" : [ "ep1991d3c77488213463db334f5be88f3ed2a", "ep1991d3c77488213463db334f5be88f3ed2b" ]
       ~~~
       So modified the transition data to match the format specified.
     
     - Checklist data has to be passed without title. So passed only the checklist items in request.
     
     - parameter transitionDetails : Details of the transition to which the record has to be moved
     
     - Throws: When data type mismatch occurs in transition data
     */
    private func getUpdateBlueprintStateDetails( _ transitionDetails : ZCRMBlueprintState.Transition ) throws -> [ String : Any ]
    {
        var fieldDataType : [ String : String ] = [:]
        _ = transitionDetails.fields.map {
            fieldDataType.updateValue( $0.dataType, forKey: $0.apiName)
        }
        var requestBody : [ String : Any? ] = [:]
        requestBody.updateValue( transitionDetails.id, forKey: ResponseJSONKeys.transitionId)
        var data : [ String : Any ] = [:]
        var attachmentsList : [ [ String : Any ] ] = []
        for ( key, value ) in transitionDetails.data
        {
            if key == ZCRMDefaultModuleAPINames.ATTACHMENTS, let attachments = value as? [[ String : Any ]]
            {
                var fileIds : [ String ] = []
                for attachment in attachments
                {
                    if let fileId = attachment.optString(key: ResponseJSONKeys.fileId)
                    {
                        fileIds.append( fileId )
                    }
                    else if let attachmentIds = attachment.optArray(key: ResponseJSONKeys.fileId) as? [ String ]
                    {
                        fileIds += attachmentIds
                    }
                    else
                    {
                        attachmentsList.append( attachment )
                    }
                }
                attachmentsList.append( [ ResponseJSONKeys.fileId : fileIds ] )
                data.updateValue( attachmentsList, forKey: key)
            }
            else if key == ResponseJSONKeys.checkLists
            {
                let items : [ [ String : Any ] ] = try ( value as? [ String : Any ] ?? [:] ).getArrayOfDictionaries(key: ResponseJSONKeys.items)
                data.updateValue( items, forKey: ResponseJSONKeys.checkLists)
            }
            else if let userDelegate = value as? ZCRMUserDelegate
            {
                data.updateValue( userDelegate.id, forKey: key)
            }
            else if let recordDelegate = value as? ZCRMRecordDelegate
            {
                data.updateValue( recordDelegate.id, forKey: key)
            }
            else if let value = value as? [ Any ], let dataType = fieldDataType[ key ], dataType != FieldDataTypeConstants.multiSelectPicklist
            {
                if !value.isEmpty
                {
                    data.updateValue( value, forKey: key)
                }
            }
            else if let value = value as? [ String : Any ]
            {
                if !value.isEmpty
                {
                    data.updateValue( value, forKey: key)
                }
            }
            else
            {
                data.updateValue( value, forKey: key)
            }
        }
        requestBody.updateValue( data, forKey: ResponseJSONKeys.data)
        return [ getJSONRootKey() : [ requestBody ] ]
    }
    
	private func setPriceDetails(priceDetails priceDetailsArrayOfJSON : [[ String : Any]]) throws
    {
        for priceDetailJSON in priceDetailsArrayOfJSON {
            let ZCRMPriceBookPricing = try getZCRMPriceDetail(From: priceDetailJSON)
             record.addPriceDetail(priceDetail: ZCRMPriceBookPricing)
        }
    }
    
    private func getZCRMPriceDetail(From priceDetailDict : [ String : Any ] ) throws -> ZCRMPriceBookPricing
    {
        let priceDetail = ZCRMPriceBookPricing( id : try priceDetailDict.getInt64( key : ResponseJSONKeys.id ) )
        
        if let discount = priceDetailDict.optDouble(key : ResponseJSONKeys.discount){
            priceDetail.discount = discount
        }
        
        if let fromRange = priceDetailDict.optDouble( key : ResponseJSONKeys.fromRange ),
           let toRange = priceDetailDict.optDouble(key : ResponseJSONKeys.toRange ){
            priceDetail.fromRange = fromRange
            priceDetail.toRange = toRange
        }
        return priceDetail
    }
    
    internal func getZCRMRecordAsJSON() -> [ String : Any? ]
    {
        var recordJSON : [ String : Any? ] = [ String : Any? ]()
        var updateJSON : [ String : Any? ] = self.record.upsertJSON
        
        if self.record.id != APIConstants.INT64_MOCK
        {
            recordJSON.updateValue( record.id, forKey : ResponseJSONKeys.id )
        }
        for ( key, value ) in updateJSON
        {
            if key == ResponseJSONKeys.owner, value is ZCRMUserDelegate, let owner = value as? ZCRMUserDelegate
            {
                recordJSON.updateValue(owner.id, forKey: ResponseJSONKeys.owner)
                updateJSON.removeValue(forKey: ResponseJSONKeys.owner)
            }
            else if key == ResponseJSONKeys.layout
            {
                if value == nil
                {
                    recordJSON.updateValue( nil, forKey : ResponseJSONKeys.layout )
                }
                else if value is ZCRMLayoutDelegate, let layout = value as? ZCRMLayoutDelegate
                {
                    recordJSON.updateValue( layout.id, forKey : ResponseJSONKeys.layout )
                }
                updateJSON.removeValue(forKey: ResponseJSONKeys.layout)
            }
            else if key == ResponseJSONKeys.dataProcessingBasisDetails
            {
                if value == nil
                {
                    recordJSON.updateValue( nil, forKey : ResponseJSONKeys.dataProcessingBasisDetails )
                }
                else if value is ZCRMDataProcessBasisDetails, let dataProcessingBasisDetails = value as? ZCRMDataProcessBasisDetails
                {
                    recordJSON.updateValue(self.getZCRMDataProcessingDetailsAsJSON(details: dataProcessingBasisDetails), forKey: ResponseJSONKeys.dataProcessingBasisDetails)
                }
                updateJSON.removeValue(forKey: ResponseJSONKeys.dataProcessingBasis)
            }
            else if key == ResponseJSONKeys.productDetails
            {
                var productDetailsKey : String = String()
                if ZCRMSDKClient.shared.apiVersion == APIConstants.API_VERSION_V2
                {
                    productDetailsKey = key
                }
                else
                {
                    switch self.record.moduleAPIName
                    {
                    case ZCRMDefaultModuleAPINames.INVOICES : productDetailsKey = ResponseJSONKeys.invoicedItems
                    case ZCRMDefaultModuleAPINames.QUOTES : productDetailsKey = ResponseJSONKeys.quotedItems
                    case ZCRMDefaultModuleAPINames.SALES_ORDERS : productDetailsKey = ResponseJSONKeys.orderedItems
                    default : productDetailsKey = ResponseJSONKeys.purchaseItems
                    }
                }
                if value == nil
                {
                    recordJSON.updateValue( nil, forKey : productDetailsKey )
                }
                else if value is [ ZCRMInventoryLineItem ], let lineItems = value as? [ ZCRMInventoryLineItem ]
                {
                    recordJSON.removeValue(forKey: ResponseJSONKeys.productDetails)
                    recordJSON.updateValue(self.getLineItemsAsJSONArray(lineItems: lineItems), forKey: productDetailsKey)
                }
                updateJSON.removeValue(forKey: ResponseJSONKeys.productDetails)
            }
            else if key == ResponseJSONKeys.dollarLineTax
            {
                if value == nil
                {
                    recordJSON.updateValue( nil, forKey : ResponseJSONKeys.dollarLineTax )
                }
                else if value is [ ZCRMLineTax ], let tax = value as? [ ZCRMLineTax ]
                {
                    recordJSON.updateValue( self.getLineTaxAsJSONArray( lineTaxes : tax ), forKey : ResponseJSONKeys.dollarLineTax )
                }
                updateJSON.removeValue(forKey: ResponseJSONKeys.dollarLineTax)
            }
            else if key == ResponseJSONKeys.tax
            {
                if value == nil
                {
                    recordJSON.updateValue( nil, forKey : ResponseJSONKeys.tax )
                }
                else if let taxes = value as? [ ZCRMTaxDelegate ]
                {
                    if let headers = ZCRMSDKClient.shared.requestHeaders, headers.hasKey(forKey: X_ZOHO_SERVICE)
                    {
                        recordJSON.updateValue( self.getTaxAsJSONArray( taxes : taxes ), forKey : ResponseJSONKeys.tax )
                    }
                    else
                    {
                        recordJSON.updateValue( taxes.map{ $0.displayName }, forKey: ResponseJSONKeys.tax)
                    }
                }
                updateJSON.removeValue(forKey: ResponseJSONKeys.tax)
            }
            else if key == ResponseJSONKeys.participants
            {
                if value == nil
                {
                    recordJSON.updateValue( nil, forKey : ResponseJSONKeys.participants )
                }
                else if value is [ ZCRMEventParticipant ], let participants = value as? [ ZCRMEventParticipant ]
                {
                    recordJSON.updateValue(self.getParticipantsAsJSONArray(participants: participants), forKey: ResponseJSONKeys.participants)
                }
                updateJSON.removeValue(forKey: ResponseJSONKeys.participants)
            }
            else if key == ResponseJSONKeys.pricingDetails
            {
                if value == nil
                {
                    recordJSON.updateValue( nil, forKey : ResponseJSONKeys.pricingDetails )
                }
                else if value is [ ZCRMPriceBookPricing ], let pricingDetails = value as? [ ZCRMPriceBookPricing ]
                {
                    recordJSON.updateValue(self.getPriceDetailsAsJSONArray(price: pricingDetails), forKey: ResponseJSONKeys.pricingDetails )
                }
                updateJSON.removeValue(forKey: ResponseJSONKeys.pricingDetails)
            }
            else if key == ResponseJSONKeys.tag
            {
                if value == nil
                {
                    recordJSON.updateValue( nil, forKey : ResponseJSONKeys.pricingDetails )
                }
                else if value is [ ZCRMTag ], let tags = value as? [ ZCRMTag ]
                {
                    recordJSON.updateValue(self.getTagAsJSONArray(tag: tags), forKey: ResponseJSONKeys.tag)
                }
                updateJSON.removeValue(forKey: ResponseJSONKeys.tag)
            }
            else
            {
                recordJSON.merge( parseAdditionalKeys(fromUpsertJSON: updateJSON), uniquingKeysWith: {(_, new) in new })
            }
        }
        return recordJSON
    }
    
    private func parseAdditionalKeys( fromUpsertJSON upsertJSON : [ String : Any? ] ) -> [ String : Any? ]
    {
        var recordJSON : [ String : Any? ] = upsertJSON
        for ( key, value ) in upsertJSON
        {
            if value == nil
            {
                recordJSON.updateValue( nil, forKey : key )
            }
            else if value is ZCRMUserDelegate, let user = value as? ZCRMUserDelegate
            {
               recordJSON.updateValue(user.id, forKey: key)
            }
            else if value is ZCRMRecordDelegate, let record = value as? ZCRMRecordDelegate
            {
                recordJSON.updateValue( record.id, forKey : key )
            }
            else if value is ZCRMLayoutDelegate, let layout = value as? ZCRMLayoutDelegate
            {
                recordJSON.updateValue( layout.id, forKey : key )
            }
            else if value is [ ZCRMRecordDelegate ], let record = value as? [ ZCRMRecordDelegate ]
            {
                recordJSON.updateValue( self.getZCRMRecordIdsAsArray( record ), forKey : key )
            }
            else if value is [ ZCRMSubformRecord ], let subformRecords = value as? [ ZCRMSubformRecord ]
            {
                recordJSON.updateValue(self.getAllZCRMSubformRecordAsJSONArray(apiName: key, subformRecords: subformRecords), forKey: key)
            }
            else if let value = value as? [ Any ]
            {
                if !value.isEmpty
                {
                    recordJSON.updateValue( parseAdditionalKeys( fromArray : value ), forKey: key )
                }
            }
            else if let value = value as? [ String : Any ]
            {
                recordJSON.updateValue( parseAdditionalKeys( fromUpsertJSON: value ), forKey: key )
            }
            else
            {
                recordJSON.updateValue( value, forKey : key )
            }
        }
        return recordJSON
    }
    
    private func parseAdditionalKeys( fromArray arrayValues : [ Any? ] ) -> [ Any? ]
    {
        var dataArray : [ Any? ] = []
        for value in arrayValues
        {
            if let value = value as? [ Any ]
            {
                dataArray.append( parseAdditionalKeys( fromArray : value ) )
            }
            else if let value = value as? [ String : Any ]
            {
                dataArray.append( parseAdditionalKeys( fromUpsertJSON: value ) )
            }
            else
            {
                dataArray.append( value )
            }
        }
        return dataArray
    }
    
    internal func share( details : [ ZCRMRecord.SharedDetails ], completion : @escaping ( ZCRMResult.Response< BulkAPIResponse > ) -> () )
    {
        setJSONRootKey(key: JSONRootKey.SHARE)
        setUrlPath(urlPath: "\( record.moduleAPIName )/\( record.id )/\( URLPathConstants.actions )/\( URLPathConstants.share )")
        setRequestMethod(requestMethod: .post)
        
        var dataArray : [[ String : Any ]] = []
        for detail in details
        {
            var shareDetails : [ String : Any ] = [:]
            shareDetails[ ResponseJSONKeys.user ] = [ ResponseJSONKeys.id : detail.user.id ]
            shareDetails[ ResponseJSONKeys.permission ] = detail.permission.rawValue
            shareDetails[ ResponseJSONKeys.shareRelatedRecords ] = detail.isSharedWithRelatedRecords
            dataArray.append( shareDetails )
        }
        setRequestBody(requestBody: [ JSONRootKey.SHARE : dataArray ])
        
        let request : APIRequest = APIRequest(handler: self)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getBulkAPIResponse() { result in
            switch result
            {
            case .success(let response) :
                completion( .success( response ) )
            case .failure(let error) :
                ZCRMLogger.logError( message : "\( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func updateShare( details : [ ZCRMRecord.SharedDetails ], completion : @escaping ( ZCRMResult.Response< BulkAPIResponse > ) -> () )
    {
        setJSONRootKey(key: JSONRootKey.SHARE)
        setUrlPath(urlPath: "\( record.moduleAPIName )/\( record.id )/\( URLPathConstants.actions )/\( URLPathConstants.share )")
        setRequestMethod(requestMethod: .put)
        
        var dataArray : [[ String : Any ]] = []
        for detail in details
        {
            var shareDetails : [ String : Any ] = [:]
            shareDetails[ ResponseJSONKeys.user ] = [ ResponseJSONKeys.id : detail.user.id ]
            shareDetails[ ResponseJSONKeys.permission ] = detail.permission.rawValue
            shareDetails[ ResponseJSONKeys.shareRelatedRecords ] = detail.isSharedWithRelatedRecords
            dataArray.append( shareDetails )
        }
        setRequestBody(requestBody: [ JSONRootKey.SHARE : dataArray ])
        
        let request : APIRequest = APIRequest(handler: self)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getBulkAPIResponse() { result in
            switch result
            {
            case .success(let response) :
                completion( .success( response ) )
            case .failure(let error) :
                ZCRMLogger.logError( message : "\( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func revokeShare( completion : @escaping ( ZCRMResult.Response< APIResponse >) -> () )
    {
        setJSONRootKey(key: JSONRootKey.SHARE)
        setUrlPath(urlPath: "\( record.moduleAPIName )/\( record.id )/\( URLPathConstants.actions )/\( URLPathConstants.share )")
        setRequestMethod(requestMethod: .delete)
        
        let request : APIRequest = APIRequest(handler: self)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getAPIResponse() { result in
            switch result
            {
            case .success(let response) :
                completion( .success( response ) )
            case .failure(let error) :
                ZCRMLogger.logError( message : "\( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func getShareableUsers( completion : @escaping ( ZCRMResult.DataResponse< [ ZCRMUserDelegate ], BulkAPIResponse > ) -> () )
    {
        setJSONRootKey(key: JSONRootKey.SHAREABLE_USER)
        setUrlPath(urlPath: "\( record.moduleAPIName )/\( record.id )/\( URLPathConstants.actions )/\( URLPathConstants.share )")
        addRequestParam(param: RequestParamKeys.view, value: "manage")
        setRequestMethod(requestMethod: .get)
        setAPIVersion( "v2" )
        
        let request : APIRequest = APIRequest(handler: self)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getBulkAPIResponse() { result in
            switch result
            {
            case .success(let bulkResponse) :
                do
                {
                    var shareableUserDetails : [ ZCRMUserDelegate ] = []
                    let responseJSON : [ String : Any ] = bulkResponse.getResponseJSON()
                    if responseJSON.isEmpty == true
                    {
                        ZCRMLogger.logError(message: "\(ZCRMErrorCode.responseNil) : \(ZCRMErrorMessage.responseJSONNilMsg), \( APIConstants.DETAILS ) : -")
                        completion( .failure( ZCRMError.processingError( code: ZCRMErrorCode.responseNil, message: ZCRMErrorMessage.responseJSONNilMsg, details : nil ) ) )
                        return
                    }
                    let userDetails : [ [ String : Any ] ] = try responseJSON.getArrayOfDictionaries(key: self.getJSONRootKey())
                    if !userDetails.isEmpty
                    {
                        for userDetail in userDetails
                        {
                            let user : ZCRMUserDelegate = try ZCRMUserDelegate(id: userDetail.getInt64(key: ResponseJSONKeys.id), name: userDetail.getString(key: ResponseJSONKeys.fullName))
                            user.data = userDetail
                            shareableUserDetails.append( user )
                        }
                    }
                    completion( .success( shareableUserDetails, bulkResponse) )
                }
                catch
                {
                    ZCRMLogger.logError( message : "\( error )" )
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            case .failure(let error) :
                ZCRMLogger.logError( message : "\( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func getSharedRecordDetails( completion : @escaping ( ZCRMResult.DataResponse< [ ZCRMRecord.SharedDetails ], BulkAPIResponse > ) -> () )
    {
        setJSONRootKey(key: JSONRootKey.SHARE)
        setUrlPath(urlPath: "\( record.moduleAPIName )/\( record.id )/\( URLPathConstants.actions )/\( URLPathConstants.share )")
        addRequestParam(param: RequestParamKeys.view, value: "summary")
        setRequestMethod(requestMethod: .get)
        
        let request : APIRequest = APIRequest(handler: self)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        var zcrmSharedRecordDetails : [ ZCRMRecord.SharedDetails ] = []
        request.getBulkAPIResponse() { result in
            switch result
            {
            case .success(let bulkResponse) :
                do
                {
                    let responseJSON : [ String : Any ] = bulkResponse.getResponseJSON()
                    if responseJSON.isEmpty == true
                    {
                        ZCRMLogger.logError(message: "\(ZCRMErrorCode.responseNil) : \(ZCRMErrorMessage.responseJSONNilMsg), \( APIConstants.DETAILS ) : -")
                        completion( .failure( ZCRMError.processingError( code: ZCRMErrorCode.responseNil, message: ZCRMErrorMessage.responseJSONNilMsg, details : nil ) ) )
                        return
                    }
                    let recordDetails : [ [ String : Any ] ] = try responseJSON.getArrayOfDictionaries(key: self.getJSONRootKey())
                    if !recordDetails.isEmpty
                    {
                        for recordDetail in recordDetails
                        {
                            try zcrmSharedRecordDetails.append( self.getSharedRecordDetails(fromJSON: recordDetail) )
                        }
                    }
                    bulkResponse.setData(data: zcrmSharedRecordDetails)
                    completion( .success( zcrmSharedRecordDetails, bulkResponse) )
                }
                catch
                {
                    ZCRMLogger.logError( message : "\( error )" )
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            case .failure(let error) :
                ZCRMLogger.logError( message : "\( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    private func getSharedRecordDetails( fromJSON json : [ String : Any ]) throws -> ZCRMRecord.SharedDetails
    {
        let userJSON = try json.getDictionary(key: ResponseJSONKeys.user)
        let user = try ZCRMUserDelegate(id: userJSON.getInt64(key: ResponseJSONKeys.id), name: userJSON.getString(key: ResponseJSONKeys.fullName))
        user.data = userJSON
        
        let permission = try ZCRMAccessPermission.getType(rawValue: json.getString(key: ResponseJSONKeys.permission))
        let isSharedWithRelatedRecords = try json.getBoolean(key: ResponseJSONKeys.shareRelatedRecords)
        
        var zcrmSharedRecord : ZCRMRecord.SharedDetails = ZCRMRecord.SharedDetails(user: user, permission: permission, isSharedWithRelatedRecords: isSharedWithRelatedRecords)
        
        let sharedthrough = try json.getDictionary(key: ResponseJSONKeys.sharedThrough)
        let module = try sharedthrough.getDictionary(key: ResponseJSONKeys.module)
        zcrmSharedRecord.module = try module.getString(key: ResponseJSONKeys.name)
        
        zcrmSharedRecord.sharedTime = try json.getString(key: ResponseJSONKeys.sharedTime)
        
        let sharedBy = try json.getDictionary(key: ResponseJSONKeys.sharedBy)
        zcrmSharedRecord.sharedBy = try ZCRMUserDelegate(id: sharedBy.getInt64(key: ResponseJSONKeys.id), name: sharedBy.getString(key: ResponseJSONKeys.fullName))
        zcrmSharedRecord.sharedBy.data = sharedBy
        
        return zcrmSharedRecord
    }
    
    private func getZCRMRecordIdsAsArray( _ recordDelegates : [ ZCRMRecordDelegate ] ) -> [ Int64 ]
    {
        var idArray : [ Int64 ] = [ Int64 ]()
        for recordDelegate in recordDelegates
        {
            idArray.append( recordDelegate.id )
        }
        return idArray
    }
    
    private func getZCRMSubformRecordAsJSON( subformRecord : ZCRMSubformRecord ) -> [ String : Any? ]
    {
        var detailsJSON : [ String : Any? ] = [ String : Any? ]()
        let recordData : [ String : Any? ] = subformRecord.data
        if subformRecord.id != APIConstants.INT64_MOCK
        {
            detailsJSON.updateValue( subformRecord.id, forKey : ResponseJSONKeys.id )
        }
        for ( key, value ) in recordData
        {
            if let record = value as? ZCRMRecordDelegate
            {
                detailsJSON.updateValue( record.id, forKey : key )
            }
            else if let user = value as? ZCRMUserDelegate
            {
                detailsJSON.updateValue( user.id, forKey : key )
            }
            else
            {
                detailsJSON.updateValue( value, forKey : key )
            }
        }
        return detailsJSON
    }
    
    private func getAllZCRMSubformRecordAsJSONArray( apiName : String, subformRecords : [ ZCRMSubformRecord ] ) -> [ [ String : Any? ] ]
    {
        var allSubformRecordsDetails : [ [ String : Any? ] ] = [ [ String : Any? ] ]()
        for subformRecord in subformRecords
        {
            allSubformRecordsDetails.append(self.getZCRMSubformRecordAsJSON(subformRecord: subformRecord))
        }
        return allSubformRecordsDetails
    }
    
    private func getZCRMDataProcessingDetailsAsJSON( details : ZCRMDataProcessBasisDetails ) -> [ String : Any? ]
    {
        var detailsJSON : [ String : Any? ] = [ String : Any? ]()
        if details.id != APIConstants.INT64_MOCK
        {
            detailsJSON.updateValue( details.id, forKey : ResponseJSONKeys.id )
        }
        if let consentThrough = details.consentThrough
        {
            detailsJSON.updateValue( consentThrough, forKey : ResponseJSONKeys.consentThrough )
        }
        if let list = details.communicationPreferences {
            if !list.isEmpty
            {
                if( list.contains( ZCRMCommunicationPreferences.email ) )
                {
                    detailsJSON.updateValue( true, forKey : ResponseJSONKeys.contactThroughEmail )
                }
                else
                {
                    detailsJSON.updateValue( false, forKey : ResponseJSONKeys.contactThroughEmail )
                }
                if( list.contains( ZCRMCommunicationPreferences.survey ) )
                {
                    detailsJSON.updateValue( true, forKey : ResponseJSONKeys.contactThroughSurvey )
                }
                else
                {
                    detailsJSON.updateValue( false, forKey : ResponseJSONKeys.contactThroughSurvey )
                }
                if( list.contains( ZCRMCommunicationPreferences.phone ) )
                {
                    detailsJSON.updateValue( true, forKey : ResponseJSONKeys.contactThroughPhone )
                }
                else
                {
                    detailsJSON.updateValue( false, forKey : ResponseJSONKeys.contactThroughPhone )
                }
            }
        }
        detailsJSON.updateValue( details.dataProcessingBasis, forKey : ResponseJSONKeys.dataProcessingBasis )
        if let date = details.consentDate
        {
            detailsJSON.updateValue( date, forKey : ResponseJSONKeys.consentDate )
        }
        if let remarks = details.consentRemarks
        {
            detailsJSON.updateValue( remarks, forKey : ResponseJSONKeys.consentRemarks )
        }
        else
        {
            detailsJSON.updateValue( nil, forKey : ResponseJSONKeys.consentRemarks )
        }
        return detailsJSON
    }
    
    private func getTaxAsJSONArray( taxes : [ ZCRMTaxDelegate ] ) -> [[ String : Any? ]]
    {
        var taxArray : [[ String : Any? ]] = [[ String : Any? ]]()
        for tax in taxes
        {
            var taxJSON : [ String : Any? ] = [ String : Any? ]()
            taxJSON.updateValue( tax.id, forKey: ResponseJSONKeys.id )
            taxJSON.updateValue( tax.displayName, forKey: ResponseJSONKeys.value)
            taxArray.append( taxJSON )
        }
        return taxArray
    }
    
    private func getLineTaxAsJSONArray( lineTaxes : [ ZCRMLineTax ] ) -> [ [ String : Any ] ]?
    {
        guard let tax = self.record.lineTaxes else
        {
            return nil
        }
        var taxJSONArray : [ [ String : Any ] ] = [ [ String : Any ] ]()
        let allTax : [ ZCRMLineTax ] = tax
        for tax in allTax
        {
            taxJSONArray.append( self.getLineTaxAsJSON( tax : tax ) )
        }
        return taxJSONArray
    }
    
    private func  getLineTaxAsJSON( tax : ZCRMLineTax ) -> [ String : Any ]
    {
        var taxJSON : [ String : Any ] = [ String : Any ]()
        taxJSON[ ResponseJSONKeys.name ] = tax.name
        taxJSON[ ResponseJSONKeys.percentage ] = tax.percentage
        if tax.isValueSet
        {
            taxJSON[ ResponseJSONKeys.value ] = tax.value
        }
        return taxJSON
    }
    
    private func getTagAsJSONArray( tag : [ ZCRMTag ] ) -> [ [ String : Any? ] ]
    {
        var tagJSONArray : [ [ String : Any? ] ] = [ [ String : Any? ] ]()
        let allTag : [ ZCRMTag ] = tag
        for tag in allTag
        {
            tagJSONArray.append( self.getTagAsJSON( tag : tag ) )
        }
        return tagJSONArray
    }
    
    private func  getTagAsJSON( tag : ZCRMTag ) -> [ String : Any? ]
    {
        var tagJSON : [ String : Any? ] = [ String : Any? ]()
        tagJSON.updateValue( tag.name, forKey : ResponseJSONKeys.name )
        tagJSON.updateValue( tag.id, forKey : ResponseJSONKeys.id )
        return tagJSON
    }
    
    private func getLineItemsAsJSONArray( lineItems : [ ZCRMInventoryLineItem ] ) -> [ [ String : Any? ] ]
    {
        var allLineItems : [ [ String : Any? ] ] = [ [ String : Any? ] ]()
        let allLines : [ZCRMInventoryLineItem] = lineItems
        for lineItem in allLines
        {
            allLineItems.append(self.getZCRMInventoryLineItemAsJSON(invLineItem: lineItem) )
        }
        return allLineItems
    }
    
    private func getPriceDetailsAsJSONArray( price : [ ZCRMPriceBookPricing ] ) -> [ [ String : Any? ] ]
    {
        var priceDetails : [ [ String : Any? ] ] = [ [ String : Any? ] ]()
        let allPriceDetails : [ ZCRMPriceBookPricing ] = price
        for priceDetail in allPriceDetails
        {
            priceDetails.append( self.getZCRMPriceDetailAsJSON( priceDetail : priceDetail ) )
        }
        return priceDetails
    }
    
    private func getParticipantsAsJSONArray( participants : [ ZCRMEventParticipant ] ) -> [ [ String : Any? ] ]
    {
        var participantsDetails : [ [ String : Any? ] ] = [ [ String : Any? ] ]()
        for participant in participants
        {
            participantsDetails.append( self.getZCRMEventParticipantAsJSON( participant : participant ) )
        }
        return participantsDetails
    }
    
    private func getZCRMEventParticipantAsJSON( participant : ZCRMEventParticipant ) -> [ String : Any? ]
    {
        var participantJSON : [ String : Any? ] = [ String : Any? ]()
        participantJSON[ ResponseJSONKeys.type ] = participant.type.rawValue
        if participant.type == .user, let user = participant.getUser()
        {
            participantJSON.updateValue( "\( user.id )", forKey : ResponseJSONKeys.participant )
        }
        else if participant.type == .contact, let record = participant.getRecord()
        {
            participantJSON.updateValue( "\( record.id )", forKey : ResponseJSONKeys.participant )
        }
        else if participant.type == .lead, let record = participant.getRecord()
        {
            participantJSON.updateValue( "\( record.id )", forKey : ResponseJSONKeys.participant )
        }
        else if participant.type == .email, let email = participant.getEmail()
        {
            if ZCRMSDKClient.shared.apiVersion < APIConstants.API_VERSION_V4
            {
                participantJSON.updateValue( email, forKey : ResponseJSONKeys.participant )
            }
            else
            {
                participantJSON.updateValue( email, forKey : ResponseJSONKeys.Email )
            }
        }
        participantJSON.updateValue( participant.isInvited, forKey : ResponseJSONKeys.invited )
        return participantJSON
    }
    
    private func getZCRMPriceDetailAsJSON( priceDetail : ZCRMPriceBookPricing ) -> [ String : Any? ]
    {
        var priceDetailJSON : [ String : Any? ] = [ String : Any? ]()
        if priceDetail.id != APIConstants.INT64_MOCK
        {
            priceDetailJSON.updateValue( priceDetail.id, forKey : ResponseJSONKeys.id )
        }
        priceDetailJSON.updateValue( priceDetail.discount, forKey : ResponseJSONKeys.discount )
        priceDetailJSON.updateValue( priceDetail.toRange, forKey : ResponseJSONKeys.toRange )
        priceDetailJSON.updateValue( priceDetail.fromRange, forKey : ResponseJSONKeys.fromRange )
        return priceDetailJSON
    }
    
    private func getZCRMInventoryLineItemAsJSON(invLineItem : ZCRMInventoryLineItem) -> [String:Any?]
    {
        var lineItem : [String:Any?] = [String:Any?]()
        if invLineItem.id != APIConstants.INT64_MOCK
        {
            lineItem.updateValue( invLineItem.id, forKey : ResponseJSONKeys.id )
        }
        var allTaxes : [ [ String : Any? ] ] = [ [ String : Any? ] ]()
        let lineTaxes : [ ZCRMLineTax] = invLineItem.lineTaxes
        for lineTax in lineTaxes
        {
            var tax : [ String : Any? ] = [ String : Any? ]()
            tax.updateValue( lineTax.name, forKey : ResponseJSONKeys.name )
            tax.updateValue( lineTax.percentage, forKey : ResponseJSONKeys.percentage )
            allTaxes.append( tax )
        }
        if ZCRMSDKClient.shared.apiVersion == APIConstants.API_VERSION_V2
        {
            lineItem.updateValue( invLineItem.quantity, forKey : ResponseJSONKeys.quantity )
            lineItem.updateValue( String( invLineItem.product.id ), forKey : ResponseJSONKeys.product )
            if invLineItem.listPrice != APIConstants.DOUBLE_MOCK
            {
                lineItem.updateValue( invLineItem.listPrice, forKey : ResponseJSONKeys.listPrice )
            }
            if let description = invLineItem.description
            {
                lineItem.updateValue( description, forKey : ResponseJSONKeys.productDescription )
            }
            if !allTaxes.isEmpty
            {
                lineItem.updateValue( allTaxes, forKey : ResponseJSONKeys.lineTax )
            }
        }
        else
        {
            lineItem.updateValue( invLineItem.quantity, forKey : ResponseJSONKeys._quantity )
            lineItem.updateValue( String( invLineItem.product.id ), forKey : ResponseJSONKeys.productName )
            if invLineItem.listPrice != APIConstants.DOUBLE_MOCK
            {
                lineItem.updateValue( invLineItem.listPrice, forKey : ResponseJSONKeys._listPrice )
            }
            if let description = invLineItem.description
            {
                lineItem.updateValue( description, forKey : ResponseJSONKeys.description )
            }
            if !allTaxes.isEmpty
            {
                lineItem.updateValue( allTaxes, forKey : ResponseJSONKeys._lineTax )
            }
        }
        if let discountPercentage = invLineItem.discountPercentage
        {
            lineItem.updateValue( discountPercentage, forKey : ResponseJSONKeys.Discount )
        }
        if let priceBookId = invLineItem.priceBookId
        {
            lineItem.updateValue( priceBookId, forKey: ResponseJSONKeys.priceBookId )
        }
        if invLineItem.quantity != APIConstants.DOUBLE_MOCK
        {
            lineItem.updateValue( invLineItem.quantityInStock, forKey: ResponseJSONKeys.quantityInStock)
        }
        return lineItem
    }
    
    internal func getLatestFields( forRecord recordDetails : [ String:Any ], fields : [ ZCRMField ]?, completion : @escaping ( [ ZCRMField ], ZCRMError? ) -> () )
    {
        guard let fields = fields else
        {
            completion( [], nil )
            return
        }
        let fieldVsApinameMap = getFieldVsApinameJSON(fields: fields)
        var isAllFieldsAvailable = true
        for (fieldAPIName, _) in recordDetails
        {
            if !fieldAPIName.hasPrefix("$") && fieldAPIName != ResponseJSONKeys.id && ( fieldVsApinameMap[ fieldAPIName ] == nil )
            {
                isAllFieldsAvailable = false
                break
            }
        }
        if !isAllFieldsAvailable
        {
            ModuleAPIHandler(module: ZCRMModuleDelegate(apiName: self.record.moduleAPIName), cacheFlavour: .noCache).getAllFields(modifiedSince: nil) { fieldsResponse in
                switch fieldsResponse
                {
                case .success(let updatedFields, _) :
                    completion( updatedFields, nil )
                case .failure(let error) :
                    ZCRMLogger.logError( message : "\( error )" )
                    completion( fields, error )
                }
            }
        }
        else
        {
            completion( fields, nil )
        }
    }
    
    internal func setRecordProperties(recordDetails : [String:Any], subformFieldDetails : [ String : [ ZCRMField ] ]? = nil, tags : [ ZCRMTag ]? = nil, completion : @escaping( ZCRMResult.Data< ZCRMRecord > ) -> ())
    {
        var setRecordError : Error?
        let dispatchGroup : DispatchGroup = DispatchGroup()
        let dispatchQueue : DispatchQueue = DispatchQueue(label: "com.zoho.crm.sdk.EntityAPIHandler.setRecordProperties")
        var lookups : [ String : Any? ] = [ String : Any? ]()
        var subforms : [ String : [ ZCRMSubformRecord ] ] = [ String : [ ZCRMSubformRecord ] ]()
        self.record.isCreate = false
        do
        {
            if let id = recordDetails.optInt64(key: ResponseJSONKeys.id)
            {
                self.record.id = id
                self.record.isCreate = false
                self.record.data.updateValue( self.record.id, forKey : ResponseJSONKeys.id )
            }
            for (fieldAPIName, value) in recordDetails
            {
                if let error = setRecordError
                {
                    throw error
                }
                else if(ResponseJSONKeys.productDetails == fieldAPIName || ResponseJSONKeys.invoicedItems == fieldAPIName || ResponseJSONKeys.quotedItems == fieldAPIName || ResponseJSONKeys.orderedItems == fieldAPIName || ResponseJSONKeys.purchaseItems == fieldAPIName) && APIConstants.lineItemModules.contains( self.record.moduleAPIName ), let lineItems = value as? [[ String : Any ]]
                {
                    try self.setInventoryLineItems(lineItems: lineItems)
                    self.record.data.updateValue( self.record.lineItems?.copy(), forKey : ResponseJSONKeys.productDetails )
                }
                else if( ResponseJSONKeys.pricingDetails == fieldAPIName ) && (self.record.moduleAPIName == ZCRMDefaultModuleAPINames.PRICE_BOOKS), let priceDetails = value as? [[ String: Any ]]
                {
                    try self.setPriceDetails( priceDetails : priceDetails )
                    self.record.data.updateValue( self.record.priceDetails?.copy(), forKey : ResponseJSONKeys.pricingDetails )
                }
                else if( ResponseJSONKeys.participants == fieldAPIName ) && (self.record.moduleAPIName == ZCRMDefaultModuleAPINames.EVENTS)
                {
                    if recordDetails.hasValue( forKey : ResponseJSONKeys.participants ), let participantsArray = value as? [ [ String : Any ] ]
                    {
                        try self.setParticipants( participantsArray : participantsArray )
                        self.record.data.updateValue( self.record.participants?.copy(), forKey : ResponseJSONKeys.participants )
                    }
                    else
                    {
                        ZCRMLogger.logDebug(message: "Type of participants should be array of dictionaries")
                    }
                }
                else if( ResponseJSONKeys.dollarLineTax == fieldAPIName ) && ( self.record.moduleAPIName == ZCRMDefaultModuleAPINames.SALES_ORDERS || self.record.moduleAPIName == ZCRMDefaultModuleAPINames.PURCHASE_ORDERS || self.record.moduleAPIName == ZCRMDefaultModuleAPINames.INVOICES || self.record.moduleAPIName == ZCRMDefaultModuleAPINames.QUOTES ), let taxesDetails = value as? [[ String : Any ]]
                {
                    var lineTaxes : [ ZCRMLineTax ] = []
                    for taxJSON in taxesDetails
                    {
                        let tax : ZCRMLineTax = try ZCRMLineTax( name : taxJSON.getString( key : ResponseJSONKeys.name ), percentage : taxJSON.getDouble( key : ResponseJSONKeys.percentage ) )
                        tax.value = try taxJSON.getDouble( key : ResponseJSONKeys.value )
                        lineTaxes.append( tax )
                    }
                    self.record.lineTaxes = lineTaxes
                    self.record.data.updateValue( self.record.lineTaxes?.copy(), forKey : ResponseJSONKeys.dollarLineTax )
                }
                else if( ResponseJSONKeys.tax == fieldAPIName && value is [ String ] ), let taxNames = value as? [ String ]
                {
                    var taxes : [ ZCRMTaxDelegate ] = []
                    for taxName in taxNames
                    {
                        taxes.append( ZCRMTaxDelegate( displayName : taxName ) )
                    }
                    self.record.taxes = taxes
                    self.record.data.updateValue( self.record.taxes?.copy(), forKey : ResponseJSONKeys.tax )
                }
                else if( ResponseJSONKeys.tax == fieldAPIName && value is [[ String : Any ]] ), let taxDetails = value as? [[ String : Any ]]
                {
                    if self.record.taxes == nil
                    {
                        self.record.taxes = []
                    }
                    for tax in taxDetails
                    {
                        let tempTax = try ZCRMTaxDelegate( displayName : tax.getString(key: ResponseJSONKeys.value) )
                        tempTax.id = tax.optInt64(key: ResponseJSONKeys.id )
                        self.record.taxes?.append( tempTax )
                    }
                    self.record.data.updateValue( self.record.taxes?.copy(), forKey : ResponseJSONKeys.tax )
                }
                else if ( ResponseJSONKeys.tag == fieldAPIName ), let tagsDetails = value as? [[ String : Any ]]
                {
                    let colorCodeMapping : [ String : String? ] = tags?.reduce( into : [  String : String?  ]() ) {
                                            $0[ $1.name ] = $1.colorCode
                                        } ?? [:]

                    if self.record.tags == nil
                    {
                        self.record.tags = [ ZCRMTagDelegate ]()
                    }
                    for tagJSON in tagsDetails
                    {
                        let tagDelegate = ZCRMTagDelegate(name: try tagJSON.getString( key : ResponseJSONKeys.name ))
                        tagDelegate.colorCode = colorCodeMapping.optString(key: tagDelegate.name) ?? tagJSON.optString(key: ResponseJSONKeys.colorCode)
                        self.record.tags?.append( tagDelegate )
                    }
                    self.record.data.updateValue( self.record.tags?.copy(), forKey : ResponseJSONKeys.tag )
                }
                else if(ResponseJSONKeys.createdBy == fieldAPIName), let createdByJSON = value as? [ String : Any ]
                {
                    let createdBy = try getUserDelegate(userJSON : createdByJSON)
                    self.record.createdBy = createdBy
                    self.record.data.updateValue( self.record.createdBy, forKey : ResponseJSONKeys.createdBy )
                }
                else if(ResponseJSONKeys.modifiedBy == fieldAPIName), let modifiedByJSON : [String:Any] = value as? [String : Any]
                {
                    let modifiedBy = try getUserDelegate(userJSON : modifiedByJSON )
                    self.record.modifiedBy = modifiedBy
                    self.record.data.updateValue( self.record.modifiedBy, forKey : ResponseJSONKeys.modifiedBy )
                }
                else if(ResponseJSONKeys.createdTime == fieldAPIName), let createdTime = value as? String
                {
                    self.record.createdTime = createdTime
                    self.record.data.updateValue(self.record.createdTime, forKey: ResponseJSONKeys.createdTime)
                }
                else if(ResponseJSONKeys.modifiedTime == fieldAPIName), let modifiedTime = value as? String
                {
                    self.record.modifiedTime = modifiedTime
                    self.record.data.updateValue(self.record.modifiedTime, forKey: ResponseJSONKeys.modifiedTime)
                }
                else if self.record.moduleAPIName == ZCRMDefaultModuleAPINames.ACTIVITIES, ( ResponseJSONKeys.activityType == fieldAPIName ), let activityType = value as? String
                {
                    self.record.moduleAPIName = activityType
                    self.record.data.updateValue(self.record.moduleAPIName, forKey: ResponseJSONKeys.activityType)
                }
                else if(ResponseJSONKeys.owner == fieldAPIName), let ownerObj : [String:Any] = value as? [String : Any]
                {
                    let owner = try getUserDelegate(userJSON : ownerObj)
                    self.record.owner = owner
                    self.record.data.updateValue( self.record.owner.copy(), forKey : ResponseJSONKeys.owner )
                }
                else if ResponseJSONKeys.dataProcessingBasisDetails == fieldAPIName, let dataProcessingDetails = value as? [String:Any]
                {
                    let dataProcessingBasisDetails : ZCRMDataProcessBasisDetails = try self.getZCRMDataProcessingBasisDetails(details: dataProcessingDetails)
                    self.record.dataProcessingBasisDetails = dataProcessingBasisDetails
                    self.record.data.updateValue( self.record.dataProcessingBasisDetails?.copy(), forKey : ResponseJSONKeys.dataProcessingBasisDetails )
                }
                else if(ResponseJSONKeys.layout == fieldAPIName)
                {
                    if(recordDetails.hasValue(forKey: fieldAPIName)), let layoutObj : [String:Any] = value  as? [String : Any]
                    {
                        let layout : ZCRMLayoutDelegate = ZCRMLayoutDelegate( id : try layoutObj.getInt64( key : ResponseJSONKeys.id ), name : try layoutObj.getString( key : ResponseJSONKeys.name ) )
                        self.record.layout = layout
                        self.record.data.updateValue( layout.copy(), forKey : ResponseJSONKeys.layout )
                    }
                }
                else if(ResponseJSONKeys.handler == fieldAPIName && recordDetails.hasValue(forKey: fieldAPIName)), let handlerObj : [String: Any] = value as? [String : Any]
                {
                    let handler : ZCRMUserDelegate = try getUserDelegate( userJSON : handlerObj )
                    self.record.data.updateValue(handler, forKey: fieldAPIName)
                }
                else if(fieldAPIName.hasPrefix("$"))
                {
                    var propertyName : String = fieldAPIName
                    propertyName.remove(at: propertyName.startIndex)
                    if propertyName.contains(ResponseJSONKeys.followers), recordDetails.hasValue( forKey : fieldAPIName ), let usersDetails = value as? [ [ String : Any ] ]
                    {
                        var users : [ ZCRMUserDelegate ] = [ ZCRMUserDelegate ]()
                        for userDetails in usersDetails
                        {
                            let user : ZCRMUserDelegate = try getUserDelegate( userJSON : userDetails )
                            users.append( user )
                        }
                        self.record.properties.updateValue(users.copy(), forKey: propertyName)
                    }
                    else
                    {
                        self.record.properties.updateValue(value, forKey: propertyName)
                    }
                }
                else if( ResponseJSONKeys.remindAt == fieldAPIName && recordDetails.hasValue( forKey : fieldAPIName ) && value is [String:Any] )
                {
                    let alarmDetails = try recordDetails.getDictionary( key : fieldAPIName )
                    self.record.data.updateValue( try alarmDetails.getString( key : ResponseJSONKeys.ALARM ), forKey : ResponseJSONKeys.remindAt )
                }
                else if( ResponseJSONKeys.recurringActivity == fieldAPIName && recordDetails.hasValue( forKey : fieldAPIName ) && value is [String:Any] )
                {
                    let recurringActivity = try recordDetails.getDictionary( key : fieldAPIName )
                    self.record.data.updateValue( try recurringActivity.getString( key : ResponseJSONKeys.RRULE ), forKey : ResponseJSONKeys.recurringActivity )
                }
                else if let fieldDetails = moduleFields?[ fieldAPIName ], fieldDetails.dataType == FieldDataTypeConstants.fileUpload
                {
                    if let value = value as? [ [ String : Any ] ]
                    {
                        try self.record.fileUploads.updateValue( getUploadFileDetails(fromArray: value, fieldAPIName: fieldAPIName, parentRecord: record), forKey: fieldAPIName)
                    }
                    else
                    {
                        self.record.fileUploads.updateValue( [], forKey: fieldAPIName)
                    }
                    self.record.data.updateValue( self.record.fileUploads, forKey: ResponseJSONKeys.fileUploadFields)
                }
                else if( value is [ String : Any ] )
                {
                    dispatchGroup.enter()
                    self.getModuleFields(recordDetails: recordDetails, fieldAPIName: fieldAPIName, cacheFlavour: ZCRMCacheFlavour.urlVsResponse) { ( lookup, error ) in

                        if let err = error
                        {
                            setRecordError = err
                            dispatchGroup.leave()
                        }
                        else if let lookup = lookup
                        {
                            dispatchQueue.sync {
                                lookups.updateValue( lookup, forKey : fieldAPIName )
                                dispatchGroup.leave()
                            }
                        } else {
                            dispatchGroup.leave()
                        }
                    }
                }
                else if let value = value as? [[ String : Any]], !value.isEmpty
                {
                    if let subformFields = subformFieldDetails?[ fieldAPIName ]
                    {
                        if self.record.subformRecord == nil
                        {
                            self.record.subformRecord = [ String : [ ZCRMSubformRecord ] ]()
                        }
                        dispatchGroup.enter()
                        self.getZCRMSubformRecords(subformName: fieldAPIName, subforms: value, fieldDetails: subformFields, completion: { ( subformRecord, error ) in
                            if let err = error
                            {
                                setRecordError = err
                            }
                            if let subformRecord = subformRecord
                            {
                                _ = dispatchQueue.sync {
                                    subforms.updateValue( subformRecord, forKey : fieldAPIName )
                                }
                            }
                            dispatchGroup.leave()
                        })
                    }
                    else if let fieldDetails = moduleFields?[ fieldAPIName ], fieldDetails.dataType == FieldDataTypeConstants.multiSelectLookup
                    {
                        guard let multiSelectLookup = fieldDetails.multiSelectLookup else
                        {
                            ZCRMLogger.logError(message: "\(ZCRMErrorCode.insufficientData) : Failed to get multiselect lookup details.")
                            throw ZCRMError.inValidError(code: ZCRMErrorCode.insufficientData, message: "Failed to get multiselect lookup details.", details: nil)
                        }
                        let connectedLookupApiname = try multiSelectLookup.getString(key: ResponseJSONKeys.connectedLookupApiname)
                        let connectedModule = try multiSelectLookup.getString(key: ResponseJSONKeys.connectedModule)
                        var upsertJSONRecords = self.record.upsertJSON.optArrayOfDictionaries(key: fieldAPIName) ?? []
                        var dataJSONRecords = self.record.data[ fieldAPIName ] as? [[ String : Any ]] ?? []
                        if value.count == upsertJSONRecords.count
                        {
                            for ( index, record ) in value.enumerated()
                            {
                                try upsertJSONRecords[ index ].updateValue( record.getInt64(key: RequestParamKeys.id), forKey: RequestParamKeys.id)
                            }
                            self.record.upsertJSON.updateValue( upsertJSONRecords, forKey: fieldAPIName)
                        }
                        else if upsertJSONRecords.isEmpty
                        {
                            upsertJSONRecords = value
                        }
                        var updatedRecords : [[ String : Any ]] = []
                        
                        var isRecordFound : Bool = false
                        for var upsertJSONRecord in upsertJSONRecords
                        {
                            for ( index, dataJSONRecord ) in dataJSONRecords.enumerated()
                            {
                                if ( ( dataJSONRecord.optInt64(key: RequestParamKeys.id) == upsertJSONRecord[RequestParamKeys.id] as? Int64 ) && upsertJSONRecord.hasKey(forKey: RequestParamKeys._delete) ) || !dataJSONRecord.hasKey(forKey: RequestParamKeys.id)
                                {
                                    dataJSONRecords.remove(at: index)
                                    isRecordFound = true
                                    break
                                }
                            }
                            if !isRecordFound
                            {
                                if let recordDetails = upsertJSONRecord.optDictionary(key: connectedLookupApiname)
                                {
                                    let recordDelegate = try ZCRMRecordDelegate(id: recordDetails.getInt64(key: ResponseJSONKeys.id), moduleAPIName: connectedModule)
                                    recordDelegate.label = recordDetails.optString(key: ResponseJSONKeys.name)
                                    recordDelegate.data = recordDetails

                                    upsertJSONRecord.updateValue( recordDelegate, forKey: connectedLookupApiname)
                                }
                                updatedRecords.append( upsertJSONRecord )
                            }
                            isRecordFound = false
                        }
                        self.record.data.updateValue( dataJSONRecords + updatedRecords, forKey: fieldAPIName )
                    }
                    else
                    {
                        dispatchGroup.enter()
                        self.makeFieldAPIRequest(fieldApiName: fieldAPIName) { ( isSubformRecord, error ) in
                            if let err = error
                            {
                                setRecordError = err
                            }
                            if isSubformRecord
                            {
                                if self.record.subformRecord == nil
                                {
                                    self.record.subformRecord = [ String : [ ZCRMSubformRecord ] ]()
                                }
                                self.getAllZCRMSubformRecords(apiName: fieldAPIName, subforms: value, completion: { ( subformRecord, error ) in
                                    if let err = error
                                    {
                                        setRecordError = err
                                    }
                                    if let subformRecord = subformRecord
                                    {
                                        _ = dispatchQueue.sync {
                                            subforms.updateValue( subformRecord, forKey : fieldAPIName )
                                        }
                                    }
                                    dispatchGroup.leave()
                                })
                            }
                            else
                            {
                                self.record.data.updateValue(value, forKey: fieldAPIName)
                                dispatchGroup.leave()
                            }
                        }
                    }
                }
                else
                {
                    self.record.data.updateValue(value, forKey: fieldAPIName)
                }
            }
            dispatchGroup.notify( queue : OperationQueue.current?.underlyingQueue ?? .global() )
            {
                if let error = setRecordError
                {
                    completion( .failure( typeCastToZCRMError( error ) ) )
                    return
                }
                for ( key, value ) in lookups
                {
                    if let value = value as? ZCRMUserDelegate
                    {
                        self.record.data.updateValue( value.copy(), forKey : key )
                    }
                    else if let value = value as? ZCRMRecordDelegate
                    {
                        self.record.data.updateValue( value.copy(), forKey : key )
                    }
                    else
                    {
                        self.record.data.updateValue( value, forKey : key )
                    }
                }
                for ( key, value ) in subforms
                {
                    dispatchQueue.sync {
                        self.record.subformRecord?.updateValue( value, forKey : key )
                        self.record.data.updateValue( value.copy(), forKey : key )
                    }
                }
                completion( .success( self.record ) )
            }
        }
        catch
        {
            completion( .failure( typeCastToZCRMError( error ) ) )
        }
    }
    
    private func getUploadFileDetails( fromArray : [ [ String : Any ] ], fieldAPIName : String, parentRecord : ZCRMRecord ) throws -> [ ZCRMRecord.UploadFieldFile ]
    {
        var files : [ ZCRMRecord.UploadFieldFile ] = record.fileUploads[ fieldAPIName ] ?? []
        
        for fileDetails in fromArray
        {
            if let id = fileDetails.optInt64(key: ResponseJSONKeys.attachmentId)
            {
                let id = id
                let name = try fileDetails.getString(key: ResponseJSONKeys.fileName)
                let size = try Int( fileDetails.getString(key: ResponseJSONKeys.originalSizeByte) ) ?? 0
                
                let fileServerId = fileDetails.optString(key: ResponseJSONKeys.uploadFileId)
                
                var attachment = ZCRMRecord.UploadFieldFile(fieldAPIName: fieldAPIName)
                attachment.fileServerId = fileServerId
                attachment.name = name
                attachment.id = id
                attachment.size = size
                attachment.parentRecord = parentRecord
                
                files.append( attachment )
            }
            else
            {
                var attachmentIds : [ Int64 ] = []
                if let ids = fileDetails.optString(key: ResponseJSONKeys.attachmentId)
                {
                    attachmentIds = ids.trimmingCharacters(in: CharacterSet(charactersIn: "[]")).replacingOccurrences(of: " ", with: "").split(separator: ",").map{ Int64( $0 ) ?? APIConstants.INT64_MOCK }
                }
                else
                {
                    attachmentIds = try ( fileDetails.getArray(key: ResponseJSONKeys.attachmentId) as? [ String ] ?? [] ).map{ Int64( $0 ) ?? APIConstants.INT64_MOCK }
                }
                let encrypted_Id = fileDetails.optString(key: ResponseJSONKeys.encryptedId)
                for attachmentId in attachmentIds
                {
                    for ( index, updatedFile ) in ( record.fileUploads[ fieldAPIName ] ?? [] ).enumerated()
                    {
                        if updatedFile.fileServerId == encrypted_Id
                        {
                            if record.fileUploads[ fieldAPIName ]?[ index ].id == nil
                            {
                                record.fileUploads[ fieldAPIName ]?[ index ].id = attachmentId
                                break
                            }
                        }
                    }
                }
                files = record.fileUploads[ fieldAPIName ] ?? []
            }
        }
        return files
    }
    
    internal func downloadFileUploadFieldFile( withAttachmentID : Int64, completion : @escaping ( ZCRMResult.Response< FileAPIResponse > ) -> () )
    {
        setUrlPath(urlPath: "\( recordDelegate.moduleAPIName )/\( recordDelegate.id )/\( URLPathConstants.actions )/\( URLPathConstants.downloadFieldsAttachment )")
        setRequestMethod(requestMethod: .get)
        addRequestParam(param: RequestParamKeys.fieldsAttachmentId, value: "\( withAttachmentID )")
        
        let request : FileAPIRequest = FileAPIRequest( handler : self )
        ZCRMLogger.logDebug( message : "Request : \( request.toString() )" )
        
        request.downloadFile() { result in
            switch result
            {
            case .success(let fileAPIResponse) :
                completion( .success( fileAPIResponse ) )
            case .failure(let error) :
                ZCRMLogger.logError( message : "\( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func downloadFileUploadFieldFile( withAttachmentID : Int64, fileDownloadDelegate : ZCRMFileDownloadDelegate )
    {
        setUrlPath(urlPath: "\( recordDelegate.moduleAPIName )/\( recordDelegate.id )/\( URLPathConstants.actions )/\( URLPathConstants.downloadFieldsAttachment )")
        setRequestMethod(requestMethod: .get)
        addRequestParam(param: RequestParamKeys.fieldsAttachmentId, value: "\( withAttachmentID )")
        
        let request : FileAPIRequest = FileAPIRequest( handler : self, fileDownloadDelegate: fileDownloadDelegate )
        ZCRMLogger.logDebug( message : "Request : \( request.toString() )" )
        
        request.downloadFile( fileRefId: String( withAttachmentID ) )
    }
    
    private func makeFieldAPIRequest( fieldApiName : String, completion : @escaping ( Bool, Error? ) -> Void )
    {
        if self.moduleFields == nil
        {
            moduleFieldQueue.sync {
                ModuleAPIHandler( module : ZCRMModuleDelegate( apiName :  self.record.moduleAPIName ), cacheFlavour : .urlVsResponse, requestHeaders : requestHeaders ).getAllFields( modifiedSince : nil ) { ( result ) in
                    switch result
                    {
                    case .success(let fields, _) :
                        self.moduleFields = getFieldVsApinameJSON(fields: fields)
                        
                        self.isSubform( fieldApiName ) { ( isSubformRecord, error ) in
                            completion( isSubformRecord, error )
                        }
                    case .failure(let error) :
                        ZCRMLogger.logError( message : "\( error )" )
                        completion( false, error )
                    }
                }
            }
        }
        else
        {
            self.isSubform( fieldApiName ) { ( isSubformRecord, error ) in
                completion( isSubformRecord, error )
            }
        }
    }
    
    internal func isSubform(_ fieldAPIName : String, _ completion : ( Bool, Error?) -> Void )
    {
        if let moduleFields = self.moduleFields
        {
            if let fields = moduleFields[ fieldAPIName ]
            {
                if fields.dataType == FieldDataTypeConstants.subform
                {
                    completion( true, nil)
                }
                else
                {
                    completion( false, nil)
                }
            }
            else
            {
                ZCRMLogger.logError(message: "\(ZCRMErrorCode.moduleFieldNotFound) : Subform module field - the \( fieldAPIName ) has not found.")
                completion( false, ZCRMError.inValidError(code: ZCRMErrorCode.moduleFieldNotFound, message: "Subform module field - the \( fieldAPIName ) has not found.", details: nil) )
            }
        }
        else
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.invalidData) : Module fields is not available")
            completion( false, ZCRMError.inValidError(code: ZCRMErrorCode.invalidData, message: "Module fields is not available", details: nil) )
        }
    }
    
    private func getModuleFields( recordDetails : [ String : Any ], fieldAPIName : String, cacheFlavour : ZCRMCacheFlavour, completion : @escaping ( Any?, Error? ) -> () )
    {
        if self.moduleFields == nil
        {
            ModuleAPIHandler( module : ZCRMModuleDelegate( apiName :  self.record.moduleAPIName ), cacheFlavour : .urlVsResponse, requestHeaders : requestHeaders ).getAllFields( modifiedSince : nil ) { ( result ) in
                switch result
                {
                case .success(let fields, _) :
                    self.moduleFields = getFieldVsApinameJSON(fields: fields)
                    self.setLookup( recordDetails : recordDetails, fieldAPIName : fieldAPIName, cacheFlavour : cacheFlavour ) { ( lookup, error ) in
                        completion( lookup, error )
                    }
                case .failure(let error) :
                    completion( nil, error )
                }
            }
        }
        else
        {
            self.setLookup( recordDetails : recordDetails, fieldAPIName : fieldAPIName, cacheFlavour : cacheFlavour ) { ( lookup, error ) in
                completion( lookup, error )
            }
        }
    }
    
    private func setLookup( recordDetails : [ String : Any ], fieldAPIName : String, cacheFlavour : ZCRMCacheFlavour, completion : @escaping ( Any?, Error? ) -> () )
    {
        if let lookupDetails = recordDetails.optDictionary(key: fieldAPIName)
        {
            do
            {
                if fieldAPIName == ResponseJSONKeys.whatId
                {
                    let lookupRecord : ZCRMRecordDelegate = try EntityAPIHandler.getRecordDelegate(moduleAPIName: recordDetails.getString( key : ResponseJSONKeys.seModule ), recordJSON: lookupDetails)
                    completion( lookupRecord, nil )
                }
                else
                {
                    if let moduleFields = self.moduleFields
                    {
                        if let field = moduleFields[ fieldAPIName ]
                        {
                            if field.dataType == FieldDataTypeConstants.userLookup || field.dataType == FieldDataTypeConstants.ownerLookup
                            {
                                let lookupUser : ZCRMUserDelegate = try getUserDelegate(userJSON: lookupDetails)
                                completion( lookupUser, nil )
                            }
                            else if field.dataType == FieldDataTypeConstants.multiModuleLookup
                            {
                                let moduleAPIName = try lookupDetails.getDictionary(key: "module").getString(key: "api_name")
                                let lookupRecord : ZCRMRecordDelegate = try EntityAPIHandler.getRecordDelegate(moduleAPIName: moduleAPIName, recordJSON: lookupDetails)
                                completion( lookupRecord, nil )
                            }
                            else
                            {
                                if let apiName = field.lookupModule
                                {
                                    let lookupRecord : ZCRMRecordDelegate = try EntityAPIHandler.getRecordDelegate(moduleAPIName: apiName, recordJSON: lookupDetails)
                                    completion( lookupRecord, nil )
                                }
                                else
                                {
                                    ZCRMLogger.logError(message: "\(ZCRMErrorCode.moduleFieldNotFound) : Lookup module field not found, \( APIConstants.DETAILS ) : -")
                                    completion( nil, ZCRMError.inValidError(code: ZCRMErrorCode.moduleFieldNotFound, message: "Lookup module field not found", details: nil) )
                                }
                            }
                        }
                        else
                        {
                            if cacheFlavour != ZCRMCacheFlavour.noCache
                            {
                                self.moduleFields = nil
                                getModuleFields(recordDetails: recordDetails, fieldAPIName: fieldAPIName, cacheFlavour: ZCRMCacheFlavour.noCache) { ( lookup, error ) in
                                    if let err = error
                                    {
                                        completion( nil, err )
                                    }
                                    if let lookup = lookup
                                    {
                                        completion( lookup, nil )
                                    }
                                }
                            }
                            else
                            {
                                ZCRMLogger.logError(message: "\(ZCRMErrorCode.moduleFieldNotFound) : Lookup module field not found, \( APIConstants.DETAILS ) : -")
                                completion( nil, ZCRMError.inValidError(code: ZCRMErrorCode.moduleFieldNotFound, message: "Lookup module field not found", details: nil) )
                            }
                        }
                    }
                    else
                    {
                        ZCRMLogger.logError(message: "\(ZCRMErrorCode.moduleFieldNotFound) : Lookup module field not found, \( APIConstants.DETAILS ) : -")
                        completion( nil, ZCRMError.inValidError(code: ZCRMErrorCode.moduleFieldNotFound, message: "Lookup module field not found", details: nil) )
                    }
                }
            }
            catch
            {
                ZCRMLogger.logError( message : "\( error )" )
                completion( nil, error )
            }
        }
    }
    
    func getZCRMSubformRecords( subformName : String , subforms : [[ String : Any]], fieldDetails : [ ZCRMField ] , completion : @escaping( [ZCRMSubformRecord]?, Error? ) -> () )
    {
        var zcrmSubformRecords : [ZCRMSubformRecord] = [ZCRMSubformRecord]()
        var unOrderedZCRMSubformRecords : [Int : ZCRMSubformRecord] = [Int : ZCRMSubformRecord]()
        var subformRecErr : Error?
        subformModuleFields.updateValue( getFieldVsApinameJSON(fields: fieldDetails), forKey: subformName)
        let dispatchQueue : DispatchQueue = DispatchQueue(label: "com.zoho.crm.sdk.EntityAPIHandler.getZCRMSubformRecords")
        let dispatchGroup : DispatchGroup = DispatchGroup()

        for index in 0..<subforms.count {
            dispatchGroup.enter()
            self.getZCRMSubformRecord( apiName : subformName, subformDetails : subforms[ index ]) { ( subformRecord, error ) in
                if let error = error {
                    subformRecErr = error
                    dispatchGroup.leave()
                }
                else {
                    dispatchQueue.sync {
                        unOrderedZCRMSubformRecords[ index ] = subformRecord
                        dispatchGroup.leave()
                    }
                }
            }
        }
        dispatchGroup.notify( queue : OperationQueue.current?.underlyingQueue ?? .global() ) {
            for subform in unOrderedZCRMSubformRecords.sorted(by: { $0.key < $1.key }) {
                zcrmSubformRecords.append( subform.value )
            }
            if let error = subformRecErr
            {
                completion( nil, error )
                return
            }
            completion( zcrmSubformRecords, nil )
        }
    }

    
    private func getAllZCRMSubformRecords( apiName : String , subforms : [[ String : Any]], completion : @escaping( [ZCRMSubformRecord]?, Error? ) -> () )
    {
        var zcrmSubformRecords : [ZCRMSubformRecord] = [ZCRMSubformRecord]()
        var unOrderedZCRMSubformRecords : [Int : ZCRMSubformRecord] = [Int : ZCRMSubformRecord]()
        var subformRecErr : Error?
        let dispatchQueue : DispatchQueue = DispatchQueue(label: "com.zoho.crm.sdk.EntityAPIHandler.getAllZCRMSubformRecords")
        let dispatchGroup : DispatchGroup = DispatchGroup()
        ModuleAPIHandler( module : ZCRMModuleDelegate( apiName : apiName ), cacheFlavour : .urlVsResponse, requestHeaders : requestHeaders ).getAllFields( modifiedSince : nil ) { ( result ) in
            do
            {
                let resp = try result.resolve()
                self.subformModuleFields.updateValue(getFieldVsApinameJSON(fields: resp.data), forKey: apiName)
            } catch {
                let error = typeCastToZCRMError( error )
                if error.ZCRMErrordetails?.code != "INVALID_MODULE" {
                    ZCRMLogger.logError(message: error.description)
                    completion( nil, error )
                }
            }
            
            for index in 0..<subforms.count {
                dispatchGroup.enter()
                self.getZCRMSubformRecord( apiName : apiName, subformDetails : subforms[ index ]) { ( subformRecord, error ) in
                    if let error = error {
                        subformRecErr = error
                        dispatchGroup.leave()
                    } else {
                        dispatchQueue.sync {
                            unOrderedZCRMSubformRecords[ index ] = subformRecord
                            dispatchGroup.leave()
                        }
                    }
                }
            }
            dispatchGroup.notify( queue : OperationQueue.current?.underlyingQueue ?? .global() ) {
                for subform in unOrderedZCRMSubformRecords.sorted(by: { $0.key < $1.key }) {
                    zcrmSubformRecords.append( subform.value )
                }
                if let error = subformRecErr
                {
                    completion( nil, error )
                    return
                }
                completion( zcrmSubformRecords, nil )
            }
        }
    }
	
    private func getZCRMSubformRecord(apiName:String, subformDetails:[String:Any], completion : @escaping( ZCRMSubformRecord?, Error? ) -> ())
    {
        var subformRecErr : Error?
        let dispatchGroup : DispatchGroup = DispatchGroup()
        do
        {
            let zcrmSubform : ZCRMSubformRecord = ZCRMSubformRecord( name : apiName, id : try subformDetails.getInt64( key : ResponseJSONKeys.id ) )
            for ( fieldAPIName, value ) in subformDetails
            {
                if let error = subformRecErr
                {
                    throw error
                }
                if(ResponseJSONKeys.createdTime == fieldAPIName), let createdTime = value as? String
                {
                    zcrmSubform.createdTime = createdTime
                    zcrmSubform.setValue( ofFieldAPIName : ResponseJSONKeys.createdTime, value : createdTime )
                }
                else if(ResponseJSONKeys.modifiedTime == fieldAPIName), let modifiedTime = value as? String
                {
                    zcrmSubform.modifiedTime = modifiedTime
                    zcrmSubform.setValue( ofFieldAPIName : ResponseJSONKeys.modifiedTime, value : modifiedTime )
                }
                else if(ResponseJSONKeys.owner == fieldAPIName), let ownerObj = value as? [String : Any]
                {
                    let owner = try getUserDelegate(userJSON : ownerObj)
                    zcrmSubform.owner = owner
                    zcrmSubform.setValue( ofFieldAPIName : ResponseJSONKeys.owner, value : zcrmSubform.owner )
                }
                else if(ResponseJSONKeys.createdBy == fieldAPIName), let createdByJSON = value as? [String : Any]
                {
                    let createdBy = try getUserDelegate(userJSON : createdByJSON)
                    zcrmSubform.createdBy = createdBy
                    zcrmSubform.setValue( ofFieldAPIName : ResponseJSONKeys.createdBy, value : zcrmSubform.createdBy )
                }
                else if(ResponseJSONKeys.modifiedBy == fieldAPIName), let modifiedByJSON = value as? [String : Any]
                {
                    let modifiedBy = try getUserDelegate(userJSON: modifiedByJSON)
                    zcrmSubform.modifiedBy = modifiedBy
                    zcrmSubform.setValue( ofFieldAPIName : ResponseJSONKeys.modifiedBy, value : zcrmSubform.modifiedBy )
                }
                else if(fieldAPIName.hasPrefix("$"))
                {
                    var propertyName : String = fieldAPIName
                    propertyName.remove(at: propertyName.startIndex)
                    zcrmSubform.setValue( ofFieldAPIName : propertyName, value : value )
                }
                else if( ResponseJSONKeys.remindAt == fieldAPIName && subformDetails.hasValue( forKey : fieldAPIName ) && value is [String:Any] )
                {
                    let alarmDetails = try subformDetails.getDictionary( key : fieldAPIName )
                    zcrmSubform.setValue( ofFieldAPIName : ResponseJSONKeys.remindAt, value : try alarmDetails.getString( key : ResponseJSONKeys.ALARM ) )
                }
                else if( ResponseJSONKeys.recurringActivity == fieldAPIName && subformDetails.hasValue( forKey : fieldAPIName ) && value is [String:Any] )
                {
                    let recurringActivity = try subformDetails.getDictionary( key : fieldAPIName )
                    zcrmSubform.setValue( ofFieldAPIName : ResponseJSONKeys.recurringActivity, value : try recurringActivity.getString( key : ResponseJSONKeys.RRULE ) )
                }
                else if( value is [ String : Any ] )
                {
                    dispatchGroup.enter()
                    if self.subformModuleFields[ apiName ] == nil {
                        self.getSubformModuleFields(recordDetails: subformDetails, fieldAPIName: fieldAPIName, apiName: apiName, cacheFlavour: .urlVsResponse) { ( lookup , error ) in
                            if let err = error
                            {
                                subformRecErr = err
                            }
                            else if let lookup = lookup
                            {
                                zcrmSubform.setValue( ofFieldAPIName : fieldAPIName, value : lookup )
                            }
                            dispatchGroup.leave()
                        }
                    }
                    else
                    {
                        self.setSubformRecordLookup( recordDetails : subformDetails, fieldAPIName : fieldAPIName, apiName : apiName, cacheFlavour : .urlVsResponse ) { ( record , error ) in
                            zcrmSubform.setValue( ofFieldAPIName : fieldAPIName, value : record )
                            dispatchGroup.leave()
                        }
                    }
                }
                else
                {
                    zcrmSubform.setValue( ofFieldAPIName : fieldAPIName, value : value )
                }
            }
            dispatchGroup.notify( queue : OperationQueue.current?.underlyingQueue ?? .global() ) {
                if let error = subformRecErr
                {
                    completion( nil, error )
                    return
                }
                completion( zcrmSubform, nil )
            }
        }
        catch
        {
            completion( nil, error )
        }
    }

    private func getSubformModuleFields( recordDetails : [ String : Any ], fieldAPIName : String, apiName : String, cacheFlavour : ZCRMCacheFlavour, completion : @escaping ( ZCRMRecordDelegate?, Error? ) -> () )
    {
        if self.subformModuleFields[ apiName ] == nil
        {
            ModuleAPIHandler( module : ZCRMModuleDelegate( apiName : apiName ), cacheFlavour : .urlVsResponse, requestHeaders : requestHeaders ).getAllFields( modifiedSince : nil ) { ( result ) in
                do
                {
                    let resp = try result.resolve()
                    self.subformModuleFields.updateValue(getFieldVsApinameJSON(fields: resp.data), forKey: apiName)
                    self.setSubformRecordLookup( recordDetails : recordDetails, fieldAPIName : fieldAPIName, apiName : apiName, cacheFlavour : cacheFlavour ) { ( record , error ) in
                        completion( record, error )
                    }
                }
                catch
                {
                    completion( nil, error )
                }
            }
        }
        else
        {
            self.setSubformRecordLookup( recordDetails : recordDetails, fieldAPIName : fieldAPIName, apiName : apiName, cacheFlavour : cacheFlavour ) { ( record  , error ) in
                completion( record, error )
            }
        }
    }
    
    private func setSubformRecordLookup( recordDetails : [ String : Any ], fieldAPIName : String, apiName : String, cacheFlavour : ZCRMCacheFlavour, completion : @escaping ( ZCRMRecordDelegate?, Error? ) -> () )
    {
        if let lookupDetails = recordDetails.optDictionary(key: fieldAPIName)
        {
            do
            {
                if let apiDict = self.subformModuleFields[ apiName ]
                {
                    if let field = apiDict?[ fieldAPIName ]
                    {
                        if let moduleAPIName = field.lookupModule
                        {
                            let lookupRecord = try EntityAPIHandler.getRecordDelegate(moduleAPIName: moduleAPIName, recordJSON: lookupDetails)
                            completion( lookupRecord, nil )
                        }
                        else
                        {
                            ZCRMLogger.logError(message: "\(ZCRMErrorCode.moduleFieldNotFound) : Lookup module field not found, \( APIConstants.DETAILS ) : -")
                            completion( nil, ZCRMError.inValidError(code: ZCRMErrorCode.moduleFieldNotFound, message: "Lookup module field not found", details: nil) )
                        }
                    }
                    else
                    {
                        ZCRMLogger.logError(message: "\(ZCRMErrorCode.moduleFieldNotFound) : Lookup Field API Name not found")
                        completion( nil, ZCRMError.inValidError(code: ZCRMErrorCode.moduleFieldNotFound, message: "Lookup Field API Name not found", details: nil) )
                    }
                }
                else
                {
                    if cacheFlavour != ZCRMCacheFlavour.noCache
                    {
                        self.getSubformModuleFields(recordDetails: recordDetails, fieldAPIName: fieldAPIName, apiName: apiName, cacheFlavour: .noCache) { ( lookup, error) in
                            if let err = error
                            {
                                completion( nil, err )
                            }
                            if let lookup = lookup
                            {
                                completion( lookup, nil )
                            }
                        }
                    }
                    else
                    {
                        ZCRMLogger.logError(message: "\(ZCRMErrorCode.moduleFieldNotFound) : Lookup module field not found")
                        completion( nil, ZCRMError.inValidError(code: ZCRMErrorCode.moduleFieldNotFound, message: "Lookup module field not found", details: nil) )
                    }
                }
            }
            catch
            {
                completion( nil, error )
            }
        }
    }
    
    private func getZCRMDataProcessingBasisDetails( details : [ String : Any ] ) throws -> ZCRMDataProcessBasisDetails
    {
        var communicationPreferencesList : [ ZCRMCommunicationPreferences ] = [ ZCRMCommunicationPreferences ]()
        if try( details.hasValue( forKey : ResponseJSONKeys.contactThroughEmail ) && details.getBoolean( key : ResponseJSONKeys.contactThroughEmail ) == true )
        {
            communicationPreferencesList.append( ZCRMCommunicationPreferences.email )
        }
        if try( details.hasValue( forKey : ResponseJSONKeys.contactThroughSurvey ) && details.getBoolean( key : ResponseJSONKeys.contactThroughSurvey ) == true )
        {
            communicationPreferencesList.append( ZCRMCommunicationPreferences.survey )
        }
        if try( details.hasValue( forKey : ResponseJSONKeys.contactThroughPhone ) && details.getBoolean( key : ResponseJSONKeys.contactThroughPhone ) == true )
        {
            communicationPreferencesList.append( ZCRMCommunicationPreferences.phone )
        }
        let dataProcessingDetails : ZCRMDataProcessBasisDetails = ZCRMDataProcessBasisDetails( id : try details.getInt64( key : ResponseJSONKeys.id ), dataProcessingBasis : try details.getString( key : ResponseJSONKeys.dataProcessingBasis ), communicationPreferences : communicationPreferencesList )
        if let consent = details.optString( key : ResponseJSONKeys.consentThrough ) {
            dataProcessingDetails.consentThrough = consent
        }
        dataProcessingDetails.consentDate = details.optString( key : ResponseJSONKeys.consentDate )
        dataProcessingDetails.modifiedTime = try details.getString( key : ResponseJSONKeys.modifiedTime )
        dataProcessingDetails.createdTime = try details.getString( key : ResponseJSONKeys.createdTime )
        dataProcessingDetails.lawfulReason = details.optString( key : ResponseJSONKeys.lawfulReason )
        dataProcessingDetails.mailSentTime = details.optString( key : ResponseJSONKeys.mailSentTime )
        dataProcessingDetails.consentRemarks = details.optString( key : ResponseJSONKeys.consentRemarks )
        dataProcessingDetails.consentEndsOn = details.optString( key : ResponseJSONKeys.consentEndsOn )
        let ownerDetails : [ String : Any ] = try details.getDictionary( key : ResponseJSONKeys.owner )
        let owner : ZCRMUserDelegate = try getUserDelegate( userJSON : ownerDetails )
        dataProcessingDetails.owner = owner
        let createdByDetails : [ String : Any ] = try details.getDictionary( key : ResponseJSONKeys.createdBy )
        let createdBy : ZCRMUserDelegate = try getUserDelegate( userJSON : createdByDetails )
        dataProcessingDetails.createdBy = createdBy
        let modifiedByDetails : [ String : Any ] = try details.getDictionary( key : ResponseJSONKeys.modifiedBy )
        let modifiedBy : ZCRMUserDelegate = try getUserDelegate( userJSON : modifiedByDetails )
        dataProcessingDetails.modifiedBy = modifiedBy
        return dataProcessingDetails
    }
    
    private func setInventoryLineItems(lineItems : [[String:Any]]) throws
    {
        for lineItem in lineItems
        {
            try self.record.addLineItem(newLineItem: getZCRMInventoryLineItem(lineItemDetails: lineItem))
        }
    }
    
    private func getZCRMInventoryLineItem(lineItemDetails : [String:Any]) throws -> ZCRMInventoryLineItem
    {
        let productDetails : [ String : Any ] = try lineItemDetails.optDictionary( key : ResponseJSONKeys.product ) ?? lineItemDetails.getDictionary(key: ResponseJSONKeys.productName)

        let lineItem : ZCRMInventoryLineItem = ZCRMInventoryLineItem( id : try lineItemDetails.getInt64( key : ResponseJSONKeys.id ) )
        lineItem.product = try EntityAPIHandler.getRecordDelegate(moduleAPIName: ResponseJSONKeys.products, recordJSON: productDetails)
        lineItem.discount = try lineItemDetails.getDouble( key : ResponseJSONKeys.Discount )
        lineItem.tax = try lineItemDetails.getDouble( key : ResponseJSONKeys.tax )
        
        lineItem.quantity = try lineItemDetails.optDouble( key : ResponseJSONKeys.quantity ) ?? lineItemDetails.getDouble( key : ResponseJSONKeys._quantity )
        lineItem.listPrice = try lineItemDetails.optDouble( key : ResponseJSONKeys.listPrice ) ?? lineItemDetails.getDouble( key : ResponseJSONKeys._listPrice )
        lineItem.total = try lineItemDetails.optDouble( key : ResponseJSONKeys.total ) ?? lineItemDetails.getDouble( key : ResponseJSONKeys._total )
        lineItem.totalAfterDiscount = try lineItemDetails.optDouble( key : ResponseJSONKeys.totalAfterDiscount ) ?? lineItemDetails.getDouble( key : ResponseJSONKeys._totalAfterDiscount )
        lineItem.netTotal = try lineItemDetails.optDouble( key : ResponseJSONKeys.netTotal ) ?? lineItemDetails.getDouble( key : ResponseJSONKeys._netTotal )
        lineItem.unitPrice = lineItemDetails.optDouble(key: ResponseJSONKeys.unitPrice)
        if lineItemDetails.hasValue(forKey: ResponseJSONKeys.lineTax) || lineItemDetails.hasValue(forKey: ResponseJSONKeys._lineTax)
        {
            let allLineTaxes : [ [ String : Any ] ] = try lineItemDetails.optArrayOfDictionaries( key : ResponseJSONKeys.lineTax ) ?? lineItemDetails.getArrayOfDictionaries( key : ResponseJSONKeys._lineTax )
            for lineTaxDetails in allLineTaxes
            {
                lineItem.addLineTax( tax : try self.getZCRMLineTax( taxDetails : lineTaxDetails ) )
            }
        }

        if let productCode = lineItemDetails.optString(key: ResponseJSONKeys.productCode)
        {
            lineItem.product.data.updateValue( productCode, forKey: ResponseJSONKeys.productCode)
        }
        lineItem.description = lineItemDetails.optString(key: ResponseJSONKeys.productDescription) ?? lineItemDetails.optString(key: ResponseJSONKeys.description)

        lineItem.priceBookId = try lineItemDetails.optInt64( key: ResponseJSONKeys.priceBookId ) ?? lineItemDetails.optDictionary(key: ResponseJSONKeys.priceBookName)?.getInt64(key: ResponseJSONKeys.id)
        lineItem.quantityInStock = lineItemDetails.optDouble( key: ResponseJSONKeys.quantityInStock )
        return lineItem
    }
    
    private func getZCRMTax( taxDetails : [ String : Any ] ) throws -> ZCRMTax
    {
        let lineTax : ZCRMTax = ZCRMTax( name : try taxDetails.getString( key: ResponseJSONKeys.name ), percentage : try taxDetails.getDouble( key : ResponseJSONKeys.value ) )
        return lineTax
    }
    
    private func getZCRMLineTax( taxDetails : [ String : Any ] ) throws -> ZCRMLineTax
    {
        let lineTax : ZCRMLineTax = ZCRMLineTax( name : try taxDetails.getString( key : ResponseJSONKeys.name ), percentage : try taxDetails.getDouble( key : ResponseJSONKeys.percentage ) )
        lineTax.value = try taxDetails.getDouble( key : ResponseJSONKeys.value )
        return lineTax
    }
    
    private func setParticipants( participantsArray : [ [ String : Any ]  ] ) throws
    {
        for participantJSON in participantsArray
        {
            let participant : ZCRMEventParticipant = try self.getZCRMParticipant( participantDetails : participantJSON )
            self.record.addParticipant( participant : participant )
        }
    }
    
    private func getZCRMParticipant( participantDetails : [ String : Any ] ) throws -> ZCRMEventParticipant
    {
        let id : Int64 = try participantDetails.getInt64( key : ResponseJSONKeys.id )
        let type : String = try participantDetails.getString( key : ResponseJSONKeys.type )
        typealias EventParticipantType = ZCRMEventParticipant.`Type`
        guard let eventType = EventParticipantType(rawValue: type) else
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.invalidData) : Event type seems to be invalid, \( APIConstants.DETAILS ) : -")
            throw ZCRMError.inValidError( code : ZCRMErrorCode.invalidData, message : "Event type seems to be invalid", details : nil )
        }
        let participant : ZCRMEventParticipant = ZCRMEventParticipant(type : eventType, id : id)
        switch eventType
        {
            case .email :
                let email =  try participantDetails.getString( key : ResponseJSONKeys.participant )
                participant.participantEmailId = email
                break
            
            case .user :
                let user = ZCRMUserDelegate( id : try participantDetails.getInt64( key : ResponseJSONKeys.participant ), name : try participantDetails.getString( key : ResponseJSONKeys.name ) )
                user.data.updateValue( user.id, forKey: ResponseJSONKeys.participant)
                user.data.updateValue( user.name, forKey: ResponseJSONKeys.name)
                if let firstName = participantDetails.optString(key: ResponseJSONKeys.firstName)
                {
                    user.data.updateValue( firstName, forKey: ResponseJSONKeys.firstName)
                }
                if let lastName = participantDetails.optString(key: ResponseJSONKeys.lastName)
                {
                    user.data.updateValue( lastName, forKey: ResponseJSONKeys.lastName)
                }
                if let email = participantDetails.optString(key: ZCRMCommunicationPreferences.email.rawValue)
                {
                    user.data.updateValue( email, forKey: ZCRMCommunicationPreferences.email.rawValue)
                }
                participant.userParticipant = user
                break
            
            case .contact :
                let entity = ZCRMRecordDelegate( id : try participantDetails.getInt64( key : ResponseJSONKeys.participant ), moduleAPIName : ZCRMDefaultModuleAPINames.CONTACTS )
                entity.label = try participantDetails.getString( key : ResponseJSONKeys.name )
                entity.data.updateValue( entity.id, forKey: ResponseJSONKeys.participant)
                entity.data.updateValue( entity.moduleAPIName, forKey: ResponseJSONKeys.module)
                entity.data.updateValue( entity.label, forKey: ResponseJSONKeys.name )
                if let firstName = participantDetails.optString(key: ResponseJSONKeys.firstName)
                {
                    entity.data.updateValue( firstName, forKey: ResponseJSONKeys.firstName)
                }
                if let lastName = participantDetails.optString(key: ResponseJSONKeys.lastName)
                {
                    entity.data.updateValue( lastName, forKey: ResponseJSONKeys.lastName)
                }
                if let email = participantDetails.optString(key: ZCRMCommunicationPreferences.email.rawValue)
                {
                    entity.data.updateValue( email, forKey: ZCRMCommunicationPreferences.email.rawValue)
                }
                if participantDetails.hasValue(forKey: ResponseJSONKeys.accountName)
                {
                    let accountDetails = try EntityAPIHandler.getRecordDelegate(moduleAPIName: ZCRMDefaultModuleAPINames.ACCOUNTS, recordJSON: participantDetails.getDictionary(key: ResponseJSONKeys.accountName))
                    entity.data.updateValue( accountDetails, forKey: ResponseJSONKeys.accountName )
                }
                participant.contactParticipant = entity
                break
            
            case .lead :
                let entity = ZCRMRecordDelegate( id : try participantDetails.getInt64( key : ResponseJSONKeys.participant ), moduleAPIName : ZCRMDefaultModuleAPINames.LEADS )
                entity.label = try participantDetails.getString( key : ResponseJSONKeys.name )
                entity.data.updateValue( entity.id, forKey: ResponseJSONKeys.participant)
                entity.data.updateValue( entity.moduleAPIName, forKey: ResponseJSONKeys.module)
                entity.data.updateValue( entity.label, forKey: ResponseJSONKeys.name )
                if let firstName = participantDetails.optString(key: ResponseJSONKeys.firstName)
                {
                    entity.data.updateValue( firstName, forKey: ResponseJSONKeys.firstName)
                }
                if let lastName = participantDetails.optString(key: ResponseJSONKeys.lastName)
                {
                    entity.data.updateValue( lastName, forKey: ResponseJSONKeys.lastName)
                }
                if let email = participantDetails.optString(key: ZCRMCommunicationPreferences.email.rawValue)
                {
                    entity.data.updateValue( email, forKey: ZCRMCommunicationPreferences.email.rawValue)
                }
                if let company = participantDetails.optString(key: ResponseJSONKeys.company)
                {
                    entity.data.updateValue( company, forKey: ResponseJSONKeys.company )
                }
                participant.leadParticipant = entity
                break
        }
        participant.status = try participantDetails.getString( key : ResponseJSONKeys.status )
        participant.isInvited = try participantDetails.getBoolean( key : ResponseJSONKeys.invited )
        return participant
    }
    
    internal static func getRecordDelegate( moduleAPIName : String, recordJSON : [ String : Any ] ) throws -> ZCRMRecordDelegate
    {
        let record : ZCRMRecordDelegate = ZCRMRecordDelegate(id: try recordJSON.getInt64( key : "id" ), moduleAPIName: moduleAPIName)
        record.label = recordJSON.optString(key: "name")
        for ( key, value ) in recordJSON
        {
            record.data.updateValue( value, forKey: key)
        }
        record.data.updateValue( record.moduleAPIName, forKey: "module_name" )
        return record
    }
}

internal extension EntityAPIHandler
{
    static func isAPISupportedFromV2_1() -> Bool
    {
        return ZCRMSDKClient.shared.apiVersion >= "v2.1"
    }
}

internal extension EntityAPIHandler
{
    struct ResponseJSONKeys
    {
        static let id = "id"
        static let name = "name"
        static let createdBy = "Created_By"
        static let modifiedBy = "Modified_By"
        static let modifiedTime = "Modified_Time"
        static let createdTime = "Created_Time"
        static let owner = "Owner"
        static let tax = "Tax"
        static let discount = "discount"
        static let Discount = "Discount"
        static let percentage = "percentage"
        static let participants = "Participants"
        static let pricingDetails = "Pricing_Details"
        static let productDetails = "Product_Details"
        static let invoicedItems = "Invoiced_Items"
        static let quotedItems = "Quoted_Items"
        static let orderedItems = "Ordered_Items"
        static let purchaseItems = "Purchase_Items"
        static let value = "value"
        static let sendNotification = "$send_notification"
        
        static let toRange = "to_range"
        static let fromRange = "from_range"
        
        static let layout = "Layout"
        static let dataProcessingBasisDetails = "Data_Processing_Basis_Details"

        static let consentThrough = "Consent_Through"
        static let contactThroughEmail = "Contact_Through_Email"
        static let contactThroughSocial = "Contact_Through_Social"
        static let contactThroughSurvey = "Contact_Through_Survey"
        static let contactThroughPhone = "Contact_Through_Phone"
        static let dataProcessingBasis = "Data_Processing_Basis"
        static let consentDate = "Consent_Date"
        static let consentRemarks = "Consent_Remarks"
        static let lawfulReason = "Lawful_Reason"
        static let mailSentTime = "Mail_Sent_Time"
        static let consentEndsOn = "Consent_EndsOn"
        
        static let participant = "participant"
        static let type = "type"
        static let status = "status"
        static let invited = "invited"
        
        static let product = "product"
        static let productName = "Product_Name"
        static let products = "Products"
        static let delete = "delete"
        static let productDescription = "product_description"
        static let description = "Description"
        static let listPrice = "list_price"
        static let _listPrice = "List_Price"
        static let quantity = "quantity"
        static let _quantity = "Quantity"
        static let lineTax = "line_tax"
        static let _lineTax = "Line_Tax"
        static let total = "total"
        static let _total = "Total"
        static let totalAfterDiscount = "total_after_discount"
        static let _totalAfterDiscount = "Total_After_Discount"
        static let netTotal = "net_total"
        static let _netTotal = "Net_Total"
        static let priceBookId = "book"
        static let priceBookName = "Price_Book_Name"
        static let quantityInStock = "quantity_in_stock"
        static let productCode = "Product_Code"
        static let unitPrice = "unit_price"
        
        static let dollarLineTax = "$line_tax"
        static let handler = "Handler"
        static let followers = "followers"
        static let remindAt = "Remind_At"
        static let ALARM = "ALARM"
        static let recurringActivity = "Recurring_Activity"
        static let RRULE = "RRULE"
        
        static let activityType = "Activity_Type"
        
        static let action = "action"
        static let auditedTime = "audited_time"
        static let doneBy = "done_by"
        static let automationDetails = "automation_details"
        static let record = "record"
        static let module = "module"
        static let source = "source"
        static let fieldHistory = "field_history"
        static let fieldLabel = "field_label"
        static let dataType = "data_type"
        static let old = "old"
        static let new = "new"
        static let rule = "rule"
        static let relatedRecord = "related_record"
        static let tag = "Tag"
        
        static let activitiesStats = "activities_stats"
        static let dealsStats = "deals_stats"
        static let revenue = "revenue"
        static let amount = "amount"
        static let stage = "stage"
        static let forecastCategory = "forecast_category"
        static let Stage = "Stage"
        static let count = "count"
        static let seModule = "$se_module"
        static let whatId = "What_Id"
        
        static let latitude = "Latitude"
        static let longitude = "Longitude"
        static let checkInTime = "Check_In_Time"
        static let checkInAddress = "Check_In_Address"
        static let checkInSubLocality = "Check_In_Sub_Locality"
        static let checkInCity = "Check_In_City"
        static let checkInState = "Check_In_State"
        static let checkInCountry = "Check_In_Country"
        static let zipCode = "ZIP_code"
        static let checkInComment = "Check_In_Comment"
        
        static let firstName = "First_Name"
        static let lastName = "Last_Name"
        static let company = "Company"
        static let accountName = "Account_Name"
        
        static let shareRelatedRecords = "share_related_records"
        static let sharedThrough = "shared_through"
        static let sharedTime = "shared_time"
        static let permission = "permission"
        static let sharedBy = "shared_by"
        static let user = "user"
        static let fullName = "full_name"
        static let zuid = "zuid"
        static let entityName = "entity_name"
        
        static let processInfo = "process_info"
        static let currentState = "field_value"
        static let isContinuous = "is_continuous"
        static let escalation = "escalation"
        static let days = "days"
        static let transitions = "transitions"
        static let data = "data"
        static let percentPartialSave = "percent_partial_save"
        static let criteriaMatched = "criteria_matched"
        static let fields = "fields"
        static let displayLabel = "display_label"
        static let isMandatory = "mandatory"
        static let pickListValues = "pick_list_values"
        static let displayValue = "display_value"
        static let sequenceNumber = "sequence_number"
        static let maps = "maps"
        static let actualValue = "actual_value"
        static let relatedDetails = "related_details"
        static let apiName = "api_name"
        static let criteria = "criteria"
        static let field = "field"
        static let comparator = "comparator"
        static let systemMandatory = "system_mandatory"
        static let transitionSequence = "transition_sequence"
        static let criteriaMessage = "criteria_message"
        static let nextTransitions = "next_transitions"
        static let transitionId = "transition_id"
        static let executionTime = "execution_time"
        static let nextFieldValue = "next_field_value"
        
        static let fileId = "$file_id"
        static let checkLists = "CheckLists"
        static let items = "items"
        
        static let colorCode = "color_code"
        
        static let attachmentId = "attachment_Id"
        static let deleteAttachmentId = "attachment_id"
        static let fileName = "file_Name"
        static let originalSizeByte = "original_Size_Byte"
        static let uploadFileId = "file_Id"
        static let fileUploadFields = "fileUploadFields"
        static let encryptedId = "encrypted_Id"
        
        static let connectedLookupApiname = "connectedlookup_apiname"
        static let connectedModule = "connected_module"
    }
    
    struct URLPathConstants {
        static let actions = "actions"
        static let convert = "convert"
        static let reschedule = "reschedule"
        static let complete = "complete"
        static let cancel = "cancel"
        static let photo = "photo"
        static let follow = "follow"
        static let __internal = "__internal"
        static let ignite = "ignite"
        static let detailviewStats = "detailview_stats"
        static let addTags = "add_tags"
        static let removeTags = "remove_tags"
        static let share = "share"
        static let blueprint = "blueprint"
        static let downloadFieldsAttachment = "download_fields_attachment"
    }
}

extension RequestParamKeys
{
    static let include = "include"
    static let assignTo = "assign_to"
    static let tagNames = "tag_names"
    static let overWrite = "over_write"
    static let filter = "filter"
    static let includeInnerDetails = "include_inner_details"
    static let fieldHistoryDataType = "field_history.data_type"
    static let fieldsAttachmentId = "fields_attachment_id"
    static let _delete = "_delete"
}
