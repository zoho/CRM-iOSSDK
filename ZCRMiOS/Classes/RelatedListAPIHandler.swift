//
//  RelatedListAPIHandler.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 18/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

internal class RelatedListAPIHandler : CommonAPIHandler
{
    private var parentRecord : ZCRMRecordDelegate
    internal var relatedList : ZCRMModuleRelation?
    private var junctionRecord : ZCRMJunctionRecord?
    private var noteAttachment : ZCRMNote?
    
    private init( parentRecord : ZCRMRecordDelegate, relatedList : ZCRMModuleRelation?, junctionRecord : ZCRMJunctionRecord?)
    {
        self.parentRecord = parentRecord
        self.relatedList = relatedList
        self.junctionRecord = junctionRecord
    }
    
    init( parentRecord : ZCRMRecordDelegate, relatedList : ZCRMModuleRelation )
    {
        self.parentRecord = parentRecord
        self.relatedList = relatedList
    }
    
    init( parentRecord : ZCRMRecordDelegate, junctionRecord : ZCRMJunctionRecord )
    {
        self.parentRecord = parentRecord
        self.junctionRecord = junctionRecord
    }
    
    init( parentRecord : ZCRMRecordDelegate )
    {
        self.parentRecord = parentRecord
    }

    override func setModuleName() {
        self.requestedModule = parentRecord.moduleAPIName
    }
    
    internal func getRecords( recordParams : ZCRMQuery.GetRecordParams, completion : @escaping( CRMResultType.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        if let relatedList = self.relatedList
        {
            if let moduleName = relatedList.module
            {
                setUrlPath(urlPath:  "\( parentRecord.moduleAPIName )/\( parentRecord.id )/\(relatedList.apiName)" )
                setRequestMethod(requestMethod: .get )
                if let page = recordParams.page
                {
                    addRequestParam( param :  RequestParamKeys.page, value : String( page ) )
                }
                if let perPage = recordParams.perPage
                {
                    addRequestParam( param : RequestParamKeys.perPage, value : String( perPage ) )
                }
                if recordParams.sortBy.notNilandEmpty
                {
                    addRequestParam( param : RequestParamKeys.sortBy, value : recordParams.sortBy! )
                }
                if let sortOrder = recordParams.sortOrder
                {
                    addRequestParam( param : RequestParamKeys.sortOrder, value : sortOrder.rawValue )
                }
                if ( recordParams.modifiedSince.notNilandEmpty ), let modifiedSince = recordParams.modifiedSince
                {
                    addRequestHeader( header : RequestParamKeys.ifModifiedSince, value : modifiedSince )
                }
                let request : APIRequest = APIRequest(handler: self)
                ZCRMLogger.logDebug(message: "Request : \(request.toString())")
                var zcrmFields : [ZCRMField]?
                var bulkResponse : BulkAPIResponse?
                var err : Error?
                let dispatchGroup : DispatchGroup = DispatchGroup()
                
                dispatchGroup.enter()
                ModuleAPIHandler(module: ZCRMModuleDelegate(apiName: moduleName), cacheFlavour: .urlVsResponse).getAllFields( modifiedSince : nil ) { ( result ) in
                    do
                    {
                        let resp = try result.resolve()
                        zcrmFields = resp.data
                        dispatchGroup.leave()
                    }
                    catch
                    {
                        err = error
                        dispatchGroup.leave()
                    }
                }
                
                dispatchGroup.enter()
                request.getBulkAPIResponse { ( resultType ) in
                    do
                    {
                        let response = try resultType.resolve()
                        bulkResponse = response
                        dispatchGroup.leave()
                    }
                    catch
                    {
                        err = error
                        dispatchGroup.leave()
                    }
                }
                
                dispatchGroup.notify( queue : OperationQueue.current?.underlyingQueue ?? .global() ) {
                    if let fields = zcrmFields, let response = bulkResponse
                    {
                        MassEntityAPIHandler(module: ZCRMModuleDelegate(apiName: moduleName)).getZCRMRecords(fields: fields, bulkResponse: response, completion: { ( records, error ) in
                            if let err = error
                            {
                                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( err )" )
                                completion( .failure( typeCastToZCRMError( err ) ) )
                                return
                            }
                            if let records = records
                            {
                                response.setData(data: records)
                                completion( .success( records, response ) )
                                return
                            }
                        })
                    }
                    else if let error = err
                    {
                        ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                        completion( .failure( typeCastToZCRMError( error ) ) )
                    }
                    else
                    {
                        ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : FIELDS must not be nil, \( APIConstants.DETAILS ) : -")
                        completion( .failure( ZCRMError.processingError( code : ErrorCode.mandatoryNotFound, message : "FIELDS must not be nil", details : nil ) ) )
                    }
                }
            }
            else
            {
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.notSupported) : SDK does not support this module, \( APIConstants.DETAILS ) : -")
                completion( .failure( ZCRMError.processingError( code : ErrorCode.notSupported, message : "SDK does not support this module", details : nil ) ) )
            }
        }
        else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : RELATED LIST must not be nil, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code : ErrorCode.mandatoryNotFound, message : "RELATED LIST must not be nil", details : nil ) ) )
        }
    }
    
    internal func getNotes( withParams : GETEntityRequestParams, completion : @escaping( CRMResultType.DataResponse< [ ZCRMNote ], BulkAPIResponse > ) -> () )
    {
        if let relatedList = self.relatedList
        {
            var notes : [ ZCRMNote ] = [ ZCRMNote ]()
            setUrlPath( urlPath :  "\( parentRecord.moduleAPIName )/\( parentRecord.id )/\( relatedList.apiName )" )
            setRequestMethod( requestMethod : .get )
            if let page = withParams.page
            {
               addRequestParam( param :  RequestParamKeys.page, value : String( page ))
            }
            if let perPage = withParams.perPage
            {
                addRequestParam( param : RequestParamKeys.perPage, value : String( perPage ))
            }
            if let sortBy = withParams.sortBy
            {
                addRequestParam( param : RequestParamKeys.sortBy, value : sortBy )
            }
            if let sortOrder = withParams.sortOrder
            {
                addRequestParam( param : RequestParamKeys.sortOrder, value : sortOrder.rawValue )
            }
            if withParams.modifiedSince.notNilandEmpty, let modifiedSince = withParams.modifiedSince
            {
                addRequestHeader( header : RequestParamKeys.ifModifiedSince , value : modifiedSince )
            }
            if let fields = withParams.fields
            {
                addRequestParam(param: RequestParamKeys.fields, value: fields.joined(separator: ","))
            }
            let request : APIRequest = APIRequest( handler : self )
            ZCRMLogger.logDebug( message : "Request : \( request.toString() )" )
            
            request.getBulkAPIResponse { ( resultType ) in
                do{
                    let bulkResponse = try resultType.resolve()
                    let responseJSON = bulkResponse.getResponseJSON()
                    if responseJSON.isEmpty == false
                    {
                        let notesList:[ [ String : Any ] ] = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                        if notesList.isEmpty == true
                        {
                            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( ErrorCode.responseNil ) : \( ErrorMessage.responseJSONNilMsg ), \( APIConstants.DETAILS ) : -" )
                            completion( .failure( ZCRMError.sdkError( code : ErrorCode.responseNil, message : ErrorMessage.responseJSONNilMsg, details : nil ) ) )
                            return
                        }
                        for noteDetails in notesList
                        {
                            if ( noteDetails.hasValue( forKey : ResponseJSONKeys.noteContent ) )
                            {
                                try notes.append( self.getZCRMNote( noteDetails : noteDetails, note : ZCRMNote( content : noteDetails.getString( key : ResponseJSONKeys.noteContent ) ) ) )
                            }
                            else
                            {
                                try notes.append( self.getZCRMNote( noteDetails : noteDetails, note : ZCRMNote( content : nil, title : try noteDetails.getString( key : ResponseJSONKeys.noteTitle ) ) ) )
                            }
                        }
                    }
                    bulkResponse.setData( data : notes )
                    completion( .success( notes, bulkResponse ) )
                }
                catch{
                    ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
        }
        else
        {
            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( ErrorCode.mandatoryNotFound ) : RELATED LIST must not be nil, \( APIConstants.DETAILS ) : -" )
            completion( .failure( ZCRMError.processingError( code : ErrorCode.mandatoryNotFound, message : "RELATED LIST must not be nil", details : nil ) ) )
        }
    }
    
    internal func getNote( noteId : Int64, completion : @escaping( CRMResultType.DataResponse< ZCRMNote, APIResponse > ) -> () )
    {
        if let relatedList = self.relatedList
        {
            setUrlPath( urlPath :  "\( parentRecord.moduleAPIName )/\( parentRecord.id )/\( relatedList.apiName )/\( noteId )" )
            setRequestMethod(requestMethod: .get)
            let request : APIRequest = APIRequest(handler: self)
            ZCRMLogger.logDebug(message: "Request : \(request.toString())")
            
            request.getAPIResponse { ( resultType ) in
                do
                {
                    let response = try resultType.resolve()
                    let responseJSON : [String:Any] = response.getResponseJSON()
                    let responseDataArray : [ [ String : Any ] ] = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                    var note : ZCRMNote
                    if ( responseDataArray[0].hasValue(forKey: ResponseJSONKeys.noteContent))
                    {
                        note = ZCRMNote( content : try responseDataArray[ 0 ].getString( key : ResponseJSONKeys.noteContent ) )
                    }
                    else
                    {
                        note = ZCRMNote( content : nil, title : try responseDataArray[ 0 ].getString( key : ResponseJSONKeys.noteTitle ) )
                    }
                    note = try self.getZCRMNote(noteDetails: responseDataArray[0], note: note)
                    response.setData(data: note)
                    completion( .success( note, response ) )
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
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : RELATED LIST must not be nil, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code : ErrorCode.mandatoryNotFound, message : "RELATED LIST must not be nil", details : nil ) ) )
        }
    }
    
    internal func getAttachments( withParams : GETEntityRequestParams, completion : @escaping( CRMResultType.DataResponse< [ ZCRMAttachment ], BulkAPIResponse > ) -> () )
    {
        if let relatedList = self.relatedList
        {
            var attachments : [ZCRMAttachment] = [ZCRMAttachment]()
            setUrlPath( urlPath :  "\( parentRecord.moduleAPIName )/\( parentRecord.id )/\( relatedList.apiName )" )
            setRequestMethod(requestMethod: .get )
            if let page = withParams.page
            {
                addRequestParam( param :  RequestParamKeys.page, value : String( page ) )
            }
            if let perPage = withParams.perPage
            {
                addRequestParam( param : RequestParamKeys.perPage, value : String( perPage ) )
            }
            if withParams.modifiedSince.notNilandEmpty, let modifiedSince = withParams.modifiedSince
            {
                addRequestHeader( header : RequestParamKeys.ifModifiedSince, value : modifiedSince )
            }
            if let fields = withParams.fields
            {
                addRequestParam( param : RequestParamKeys.fields, value : fields.joined(separator: ",") )
            }
            if let sortBy = withParams.sortBy
            {
                addRequestParam(param: RequestParamKeys.sortBy, value: sortBy)
            }
            if let sortOrder = withParams.sortOrder
            {
                addRequestParam(param: RequestParamKeys.sortOrder, value: sortOrder.rawValue)
            }
            let request : APIRequest = APIRequest(handler: self)
            ZCRMLogger.logDebug(message: "Request : \(request.toString())")
            
            request.getBulkAPIResponse { ( resultType ) in
                do{
                    let bulkResponse = try resultType.resolve()
                    let responseJSON = bulkResponse.getResponseJSON()
                    if responseJSON.isEmpty == false
                    {
                        let attachmentsList : [ [ String : Any ] ] = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                        if attachmentsList.isEmpty == true
                        {
                            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.responseNil) : \(ErrorMessage.responseJSONNilMsg), \( APIConstants.DETAILS ) : -")
                            completion( .failure( ZCRMError.sdkError( code : ErrorCode.responseNil, message : ErrorMessage.responseJSONNilMsg, details : nil ) ) )
                            return
                        }
                        for attachmentDetails in attachmentsList
                        {
                            try attachments.append(self.getZCRMAttachment(attachmentDetails: attachmentDetails))
                        }
                    }
                    bulkResponse.setData(data: attachments)
                    completion( .success( attachments, bulkResponse ) )
                }
                catch{
                    ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
        }
        else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : RELATED LIST must not be nil, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code : ErrorCode.mandatoryNotFound, message : "RELATED LIST must not be nil", details : nil ) ) )
        }
    }

    internal func uploadLinkAsAttachment( attachmentURL : String, completion : @escaping( CRMResultType.DataResponse< ZCRMAttachment, APIResponse > ) -> () )
    {
        if let relatedList = self.relatedList
        {
            setUrlPath( urlPath : "\( parentRecord.moduleAPIName )/\( parentRecord.id )/\( relatedList.apiName )" )
            addRequestParam( param :  RequestParamKeys.attachmentURL, value : attachmentURL )
            setRequestMethod(requestMethod: .post )
            let request : FileAPIRequest = FileAPIRequest(handler: self)
            ZCRMLogger.logDebug(message: "Request : \(request.toString())")
            
            request.uploadLink { ( resultType ) in
                do{
                    let response = try resultType.resolve()
                    let responseJSON = response.getResponseJSON()
                    let responseJSONArray : [ [ String : Any ] ]  = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                    let details = try responseJSONArray[ 0 ].getDictionary( key : APIConstants.DETAILS )
                    let attachment = try self.getZCRMAttachment(attachmentDetails: details)
                    response.setData( data : attachment )
                    completion( .success( attachment, response ) )
                }
                catch{
                    ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
        }
        else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : RELATED LIST must not be nil, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code : ErrorCode.mandatoryNotFound, message : "RELATED LIST must not be nil", details : nil ) ) )
        }
    }

    internal func downloadAttachment( attachmentId : Int64, completion : @escaping( CRMResultType.Response< FileAPIResponse > ) -> () )
    {
        if let relatedList = self.relatedList
        {
            setJSONRootKey( key : JSONRootKey.NIL )
            setUrlPath( urlPath :  "\( parentRecord.moduleAPIName )/\( parentRecord.id )/\( relatedList.apiName )/\( attachmentId )" )
            setRequestMethod(requestMethod: .get )
            let request : FileAPIRequest = FileAPIRequest(handler: self)
            ZCRMLogger.logDebug(message: "Request : \(request.toString())")
            
            request.downloadFile { ( resultType ) in
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
        else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : RELATED LIST must not be nil, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code : ErrorCode.mandatoryNotFound, message : "RELATED LIST must not be nil", details : nil ) ) )
        }
    }
    
    internal func downloadAttachment( attachmentId : Int64, fileDownloadDelegate : ZCRMFileDownloadDelegate ) throws
    {
        if let relatedList = self.relatedList
        {
            setJSONRootKey( key : JSONRootKey.NIL )
            setUrlPath( urlPath :  "\( parentRecord.moduleAPIName )/\( parentRecord.id )/\( relatedList.apiName )/\( attachmentId )" )
            setRequestMethod(requestMethod: .get )
            let request : FileAPIRequest = FileAPIRequest(handler: self, fileDownloadDelegate: fileDownloadDelegate)
            ZCRMLogger.logDebug(message: "Request : \(request.toString())")
            request.downloadFile( fileRefId: String( attachmentId ) )
        }
        else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : RELATED LIST must not be nil, \( APIConstants.DETAILS ) : -")
            throw ZCRMError.processingError( code : ErrorCode.mandatoryNotFound, message : "RELATED LIST must not be nil", details : nil )
        }
    }

    internal func deleteAttachment( attachmentId : Int64, completion : @escaping( CRMResultType.Response< APIResponse > ) -> () )
    {
        if let relatedList = self.relatedList
        {
            setJSONRootKey( key : JSONRootKey.NIL )
            setUrlPath( urlPath : "\( parentRecord.moduleAPIName )/\( parentRecord.id )/\( relatedList.apiName )/\( attachmentId )" )
            setRequestMethod(requestMethod: .delete )
            let request : APIRequest = APIRequest(handler: self)
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
        else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : RELATED LIST must not be nil, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code : ErrorCode.mandatoryNotFound, message : "RELATED LIST must not be nil", details : nil ) ) )
        }
    }

    internal func addNote( note : ZCRMNote, completion : @escaping( CRMResultType.DataResponse< ZCRMNote, APIResponse > ) -> () )
    {
        if let relatedList = self.relatedList
        {
            var reqBodyObj : [ String : [ [ String : Any? ] ] ] = [ String : [ [ String : Any? ] ] ]()
            var dataArray : [ [ String : Any? ] ] = [ [ String : Any? ] ]()
            dataArray.append( self.getZCRMNoteAsJSON(note: note) )
            reqBodyObj[getJSONRootKey()] = dataArray
            
            setUrlPath( urlPath : "\( parentRecord.moduleAPIName )/\( parentRecord.id )/\( relatedList.apiName )" )
            setRequestMethod(requestMethod: .post )
            setRequestBody(requestBody: reqBodyObj )
            let request : APIRequest = APIRequest(handler: self)
            ZCRMLogger.logDebug(message: "Request : \(request.toString())")
            
            request.getAPIResponse { ( resultType ) in
                do{
                    let response = try resultType.resolve()
                    let responseJSON = response.getResponseJSON()
                    let respDataArr : [ [ String : Any? ] ] = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                    let respData : [String:Any?] = respDataArr[0]
                    let recordDetails : [ String : Any ] = try respData.getDictionary( key : APIConstants.DETAILS )
                    let note = try self.getZCRMNote(noteDetails: recordDetails, note: note)
                    response.setData(data: note )
                    completion( .success( note, response ) )
                }
                catch{
                    ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
        }
        else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : RELATED LIST must not be nil, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code : ErrorCode.mandatoryNotFound, message : "RELATED LIST must not be nil", details : nil ) ) )
        }
    }
    
    internal func updateNote( note : ZCRMNote, completion : @escaping( CRMResultType.DataResponse< ZCRMNote, APIResponse > ) -> () )
    {
        if let relatedList = self.relatedList
        {
            if note.isCreate
            {
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : NOTE ID must not be nil, \( APIConstants.DETAILS ) : -")
                completion( .failure( ZCRMError.processingError( code : ErrorCode.mandatoryNotFound, message : "NOTE ID must not be nil", details : nil ) ) )
                return
            }
            else
            {
                let noteId : String = String( note.id )
                var reqBodyObj : [ String : [ [ String : Any? ] ] ] = [ String : [ [ String : Any? ] ] ]()
                var dataArray : [ [ String : Any? ] ] = [ [ String : Any? ] ]()
                dataArray.append(self.getZCRMNoteAsJSON(note: note))
                reqBodyObj[getJSONRootKey()] = dataArray
                
                setUrlPath( urlPath : "\( parentRecord.moduleAPIName )/\( parentRecord.id )/\( relatedList.apiName )/\( noteId )")
                setRequestMethod(requestMethod: .patch )
                setRequestBody(requestBody: reqBodyObj)
                let request : APIRequest = APIRequest(handler: self)
                ZCRMLogger.logDebug(message: "Request : \(request.toString())")
                
                request.getAPIResponse { ( resultType ) in
                    do{
                        let response = try resultType.resolve()
                        let responseJSON = response.getResponseJSON()
                        let respDataArr : [ [ String : Any? ] ] = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                        let respData : [String:Any?] = respDataArr[0]
                        let recordDetails : [ String : Any ] = try respData.getDictionary( key : APIConstants.DETAILS )
                        let updatedNote = try self.getZCRMNote(noteDetails: recordDetails, note: note)
                        response.setData(data: updatedNote )
                        completion( .success( updatedNote, response ) )
                    }
                    catch{
                        ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                        completion( .failure( typeCastToZCRMError( error ) ) )
                    }
                }
            }
        }
        else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : RELATED LIST must not be nil, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code : ErrorCode.mandatoryNotFound, message : "RELATED LIST must not be nil", details : nil ) ) )
        }
    }
    
    internal func deleteNote( noteId : Int64, completion : @escaping( CRMResultType.Response< APIResponse > ) -> () )
    {
        if let relatedList = self.relatedList
        {
            setJSONRootKey( key : JSONRootKey.NIL )
            setUrlPath( urlPath :  "\( parentRecord.moduleAPIName )/\( parentRecord.id )/\( relatedList.apiName )/\( noteId )" )
            setRequestMethod(requestMethod: .delete )
            let request : APIRequest = APIRequest(handler: self)
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
        else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : RELATED LIST must not be nil, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code : ErrorCode.mandatoryNotFound, message : "RELATED LIST must not be nil", details : nil ) ) )
        }
    }
    
    private func getZCRMAttachment(attachmentDetails : [String:Any?]) throws -> ZCRMAttachment
    {
        let attachment : ZCRMAttachment = ZCRMAttachment( parentRecord : parentRecord )
        attachment.id = try attachmentDetails.getInt64(key: ResponseJSONKeys.id)
        if let fileName : String = attachmentDetails.optString( key : ResponseJSONKeys.fileName )
        {
            attachment.fileName = fileName
            attachment.fileExtension = fileName.pathExtension()
        }
        if(attachmentDetails.hasValue(forKey: ResponseJSONKeys.Size))
        {
            attachment.fileSize = try attachmentDetails.getInt64( key : ResponseJSONKeys.Size )
        }
        if ( attachmentDetails.hasValue( forKey : ResponseJSONKeys.createdBy ) )
        {
            let createdByDetails : [ String : Any ] = try attachmentDetails.getDictionary( key : ResponseJSONKeys.createdBy )
            attachment.createdBy = try getUserDelegate(userJSON : createdByDetails)
            attachment.createdTime = try attachmentDetails.getString( key : ResponseJSONKeys.createdTime )
        }
        if(attachmentDetails.hasValue(forKey: ResponseJSONKeys.modifiedBy))
        {
            let modifiedByDetails : [ String : Any ] = try attachmentDetails.getDictionary( key : ResponseJSONKeys.modifiedBy )
            attachment.modifiedBy = try getUserDelegate(userJSON : modifiedByDetails)
            attachment.modifiedTime = try attachmentDetails.getString( key : ResponseJSONKeys.modifiedTime )
        }
        if(attachmentDetails.hasValue(forKey: ResponseJSONKeys.owner))
        {
            let ownerDetails : [ String : Any ] = try attachmentDetails.getDictionary( key : ResponseJSONKeys.owner )
            attachment.owner = try getUserDelegate(userJSON : ownerDetails)
        }
        else if attachmentDetails.hasValue(forKey: ResponseJSONKeys.createdBy)
        {
            let ownerDetails : [String:Any] = try attachmentDetails.getDictionary(key: ResponseJSONKeys.createdBy)
            attachment.owner = try getUserDelegate(userJSON: ownerDetails)
        }
        if( attachmentDetails.hasValue(forKey: ResponseJSONKeys.editable))
        {
            attachment.isEditable = try attachmentDetails.getBoolean( key : ResponseJSONKeys.editable )
        }
        if( attachmentDetails.hasValue(forKey: ResponseJSONKeys.type))
        {
            attachment.type = try attachmentDetails.getString( key : ResponseJSONKeys.type )
        }
        if( attachmentDetails.hasValue(forKey: ResponseJSONKeys.linkURL) )
        {
            attachment.linkURL = try attachmentDetails.getString( key : ResponseJSONKeys.linkURL )
        }
        if(attachmentDetails.hasValue(forKey: ResponseJSONKeys.parentId))
        {
            let parentRecordList : [ String : Any ] = try attachmentDetails.getDictionary(key: ResponseJSONKeys.parentId)
            if let seModule = attachmentDetails.optString( key : ResponseJSONKeys.seModule )
            {
                attachment.parentRecord = ZCRMRecordDelegate( id : try parentRecordList.getString( key : ResponseJSONKeys.id ), moduleAPIName : seModule )
                if parentRecordList.hasValue(forKey: ResponseJSONKeys.name)
                {
                    attachment.parentRecord.label = try parentRecordList.getString( key : ResponseJSONKeys.name )
                }
            }
            else
            {
                attachment.parentRecord = ZCRMRecordDelegate( id : try parentRecordList.getString( key : ResponseJSONKeys.id ), moduleAPIName : parentRecord.moduleAPIName )
                if parentRecordList.hasValue(forKey: ResponseJSONKeys.name)
                {
                    attachment.parentRecord.label = try parentRecordList.getString( key : ResponseJSONKeys.name )
                }
            }
        }
        return attachment
    }
    
    internal func getZCRMNote(noteDetails : [String:Any?], note : ZCRMNote) throws -> ZCRMNote
    {
        note.isCreate = false
        note.id = try noteDetails.getString( key : ResponseJSONKeys.id )
        if ( noteDetails.hasValue( forKey : ResponseJSONKeys.noteContent ) )
        {
            note.content = noteDetails.optString( key : ResponseJSONKeys.noteContent )
        }
        if ( noteDetails.hasValue( forKey : ResponseJSONKeys.noteTitle ) )
        {
            note.title = noteDetails.optString( key : ResponseJSONKeys.noteTitle )
        }
        if ( noteDetails.hasValue( forKey : ResponseJSONKeys.createdBy ) )
        {
            let createdByDetails : [ String : Any ] = try noteDetails.getDictionary( key : ResponseJSONKeys.createdBy )
            note.createdBy = try getUserDelegate(userJSON : createdByDetails)
            note.createdTime = try noteDetails.getString( key : ResponseJSONKeys.createdTime )
        }
        if ( noteDetails.hasValue( forKey : ResponseJSONKeys.modifiedBy ) )
        {
            let modifiedByDetails : [ String : Any ] = try noteDetails.getDictionary( key : ResponseJSONKeys.modifiedBy )
            note.modifiedBy = try getUserDelegate(userJSON : modifiedByDetails)
            note.modifiedTime = try noteDetails.getString( key : ResponseJSONKeys.modifiedTime )
        }
        if( noteDetails.hasValue( forKey: ResponseJSONKeys.owner ) )
        {
            let ownerDetails : [ String : Any ] = try noteDetails.getDictionary( key : ResponseJSONKeys.owner )
            note.owner = try getUserDelegate(userJSON : ownerDetails)
        }
        else
        {
            let ownerDetails : [String:Any] = try noteDetails.getDictionary(key: ResponseJSONKeys.createdBy)
            note.owner = try getUserDelegate(userJSON : ownerDetails)
        }
        if(noteDetails.hasValue(forKey: ResponseJSONKeys.attachments))
        {
            let attachmentsList : [ [ String : Any? ] ] = try noteDetails.getArrayOfDictionaries( key : ResponseJSONKeys.attachments )
            for attachmentDetails in attachmentsList
            {
                try note.addAttachment(attachment: self.getZCRMAttachment(attachmentDetails: attachmentDetails))
            }
        }
        if(noteDetails.hasValue(forKey: ResponseJSONKeys.parentId))
        {
            let parentRecordList : [ String : Any ] = try noteDetails.getDictionary(key: ResponseJSONKeys.parentId)
            if let seModule = noteDetails.optString( key : ResponseJSONKeys.seModule )
            {
                note.parentRecord = ZCRMRecordDelegate( id : try parentRecordList.getString( key : ResponseJSONKeys.id ), moduleAPIName : seModule )
                if parentRecordList.hasValue(forKey: ResponseJSONKeys.name)
                {
                    note.parentRecord.label = try parentRecordList.getString( key : ResponseJSONKeys.name )
                }
            }
            else
            {
                note.parentRecord = ZCRMRecordDelegate( id : try parentRecordList.getString( key : ResponseJSONKeys.id ), moduleAPIName : parentRecord.moduleAPIName )
                if parentRecordList.hasValue(forKey: ResponseJSONKeys.name)
                {
                    note.parentRecord.label = try parentRecordList.getString( key : ResponseJSONKeys.name )
                }
            }
        }
        if noteDetails.hasValue(forKey: ResponseJSONKeys.voiceNote)
        {
            note.isVoiceNote = try noteDetails.getBoolean( key : ResponseJSONKeys.voiceNote )
            if noteDetails.hasValue(forKey: ResponseJSONKeys.size)
            {
                note.size = try noteDetails.getInt64( key : ResponseJSONKeys.size )
            }
        }
        if noteDetails.hasValue(forKey: ResponseJSONKeys.editable)
        {
            note.isEditable = try noteDetails.getBoolean( key : ResponseJSONKeys.editable )
        }
        return note
    }
    
    internal func getZCRMNoteAsJSON(note : ZCRMNote) -> [ String : Any? ]
    {
        var noteJSON : [ String : Any? ] = [ String : Any? ]()
        noteJSON.updateValue( note.title, forKey : ResponseJSONKeys.noteTitle )
        noteJSON.updateValue( note.content, forKey : ResponseJSONKeys.noteContent )
        noteJSON.updateValue( note.parentRecord.id, forKey : ResponseJSONKeys.parentId )
        noteJSON.updateValue( note.parentRecord.moduleAPIName, forKey : ResponseJSONKeys.seModule )
        return noteJSON
    }

    internal func addRelation( completion : @escaping( CRMResultType.Response< APIResponse > ) -> () )
    {
        if let junctionRecord = self.junctionRecord
        {
            var reqBodyObj : [ String : [ [ String : Any? ] ] ] = [ String : [ [ String : Any? ] ] ]()
            var dataArray : [ [ String : Any? ] ] = [ [ String : Any? ] ]()
            dataArray.append( junctionRecord.relatedDetails )
            reqBodyObj[getJSONRootKey()] = dataArray
            
            setUrlPath( urlPath : "\( parentRecord.moduleAPIName )/\( parentRecord.id )/\( junctionRecord.apiName )/\( junctionRecord.id )" )
            setRequestMethod(requestMethod: .patch )
            setRequestBody(requestBody: reqBodyObj )
            let request : APIRequest = APIRequest(handler: self)
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
        else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : JUNCTION RECORD must not be nil, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code : ErrorCode.mandatoryNotFound, message : "JUNCTION RECORD must not be nil", details : nil ) ) )
        }
    }
    
    internal func addRelations( junctionRecords : [ ZCRMJunctionRecord ], completion : @escaping( CRMResultType.Response< BulkAPIResponse > ) -> () )
    {
        var reqBodyObj : [ String : [ [ String : Any? ] ] ] = [ String : [ [ String : Any? ] ] ]()
        let dataArray : [ [ String : Any? ] ] = self.getRelationsDetailsAsJSON( junctionRecords : junctionRecords )
        reqBodyObj[ getJSONRootKey() ] = dataArray
        
        setUrlPath( urlPath : "\( parentRecord.moduleAPIName )/\( parentRecord.id )/\( junctionRecords[ 0 ].apiName )" )
        setRequestMethod( requestMethod : .patch )
        setRequestBody( requestBody : reqBodyObj )
        let request : APIRequest = APIRequest(handler: self)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getBulkAPIResponse { ( resultType ) in
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

    internal func deleteRelation( completion : @escaping( CRMResultType.Response< APIResponse > ) -> () )
    {
        if let junctionRecord = self.junctionRecord
        {
            setUrlPath( urlPath: "\( parentRecord.moduleAPIName )/\( parentRecord.id )/\( junctionRecord.apiName )/\( junctionRecord.id )" )
            setRequestMethod(requestMethod: .delete )
            let request : APIRequest = APIRequest(handler: self)
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
        else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : JUNCTION RECORD must not be nil, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code : ErrorCode.mandatoryNotFound, message : "JUNCTION RECORD must not be nil", details : nil ) ) )
        }
    }
    
    internal func deleteRelations( junctionRecords : [ ZCRMJunctionRecord ], completion : @escaping( CRMResultType.Response< BulkAPIResponse > ) -> () )
    {
        setUrlPath( urlPath : "\( parentRecord.moduleAPIName )/\( parentRecord.id )/\( junctionRecords[ 0 ].apiName )" )
        setRequestMethod(requestMethod: .delete )
        addRequestParam(param: RequestParamKeys.ids, value: junctionRecords.map{ String( $0.id ) }.joined(separator: ","))
        let request : APIRequest = APIRequest(handler: self)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getBulkAPIResponse { ( resultType ) in
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
    
    private func getRelationsDetailsAsJSON( junctionRecords : [ ZCRMJunctionRecord ] ) -> [ [ String : Any? ] ]
    {
        var relatedDetailsJSON : [ [ String : Any? ] ] = [ [ String : Any? ] ]()
        for junctionRecord in junctionRecords
        {
            var recordJSON : [ String : Any? ] = [ String : Any? ]()
            recordJSON.updateValue( junctionRecord.id, forKey : ResponseJSONKeys.id )
            if !junctionRecord.relatedDetails.isEmpty
            {
                for ( key, value ) in junctionRecord.relatedDetails
                {
                    recordJSON.updateValue( value, forKey : key )
                }
            }
            relatedDetailsJSON.append( recordJSON )
        }
        return relatedDetailsJSON
    }
    
    internal override func getJSONRootKey() -> String
    {
        return JSONRootKey.DATA
    }
    
}

extension RelatedListAPIHandler
{
    internal func buildFileUploadAttachmentRequest(filePath : String?, fileName : String?, fileData : Data?, note : ZCRMNote?) throws {
        if let relatedList = self.relatedList
        {
            do
            {
                if let note = note
                {
                    self.noteAttachment = note
                    try notesAttachmentLimitCheck( note : note, filePath: filePath, fileData: fileData )
                }
                else
                {
                    try fileDetailCheck( filePath : filePath, fileData : fileData, maxFileSize: MaxFileSize.attachment)
                }
            }
            catch
            {
                throw error
            }
            setUrlPath( urlPath : "\( self.parentRecord.moduleAPIName )/\( self.parentRecord.id )/\( relatedList.apiName )" )
            setRequestMethod(requestMethod: .post )
        } else {
            throw ZCRMError.processingError( code : ErrorCode.mandatoryNotFound, message : "RELATED LIST must not be nil", details : nil )
        }
    }
    
    internal func uploadAttachment( filePath : String?, fileName : String?, fileData : Data?, note : ZCRMNote?, completion : @escaping(CRMResultType.DataResponse< ZCRMAttachment, APIResponse > ) -> () )
    {
        do {
            try buildFileUploadAttachmentRequest(filePath: filePath, fileName: fileName, fileData: fileData, note: note)
            let request : FileAPIRequest = FileAPIRequest(handler: self)
            ZCRMLogger.logDebug(message: "Request : \(request.toString())")
            
            if let filePath = filePath
            {
                request.uploadFile( filePath : filePath, entity : nil, completion : { ( resultType ) in
                    do{
                        let response = try resultType.resolve()
                        let attachment = try self.getAttachmentFrom( response : response )
                        response.setData( data : attachment )
                        if let noteAttachment = self.noteAttachment
                        {
                            noteAttachment.addAttachment( attachment : attachment )
                        }
                        attachment.fileName = filePath.lastPathComponent(withExtension: true)
                        attachment.fileExtension = filePath.pathExtension()
                        attachment.fileSize = getFileSize(filePath: filePath)
                        completion( .success( attachment, response ) )
                    }
                    catch{
                        ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                        completion( .failure( typeCastToZCRMError( error ) ) )
                    }
                })
            }
            else if let fileName = fileName, let fileData = fileData
            {
                request.uploadFile( fileName : fileName, entity : nil, fileData : fileData, completion : { ( resultType ) in
                    do{
                        let response = try resultType.resolve()
                        let attachment = try self.getAttachmentFrom( response : response )
                        response.setData( data : attachment )
                        if let noteAttachment = self.noteAttachment
                        {
                            noteAttachment.addAttachment( attachment : attachment )
                        }
                        attachment.fileName = fileName
                        attachment.fileExtension = fileName.pathExtension()
                        attachment.fileSize = Int64( fileData.count )
                        completion( .success( attachment, response ) )
                    }
                    catch{
                        ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                        completion( .failure( typeCastToZCRMError( error ) ) )
                    }
                })
            }
        } catch {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \( error )")
            completion( .failure( typeCastToZCRMError( error ) ) )
        }
    }
    
    internal func uploadAttachment( fileRefId : String, filePath : String?, fileName : String?, fileData : Data?, note : ZCRMNote?, attachmentUploadDelegate : ZCRMAttachmentUploadDelegate)
    {
        do {
            try buildFileUploadAttachmentRequest(filePath: filePath, fileName: fileName, fileData: fileData, note: note)
            let request : FileAPIRequest = FileAPIRequest( handler : self, fileUploadDelegate : attachmentUploadDelegate)
            ZCRMLogger.logDebug(message: "Request : \(request.toString())")
            
            var relatedListAPIHandler : RelatedListAPIHandler? = self
            
            request.uploadFile(fileRefId: fileRefId, filePath: filePath, fileName: fileName, fileData: fileData, entity: nil) { result, response in
                if result {
                    guard let response = response else {
                        relatedListAPIHandler = nil
                        return
                    }
                    relatedListAPIHandler?.setAttachment( fileRefId : fileRefId, filePath: filePath, fileName: fileName, fileData: fileData, apiResponse : response , attachmentUploadDelegate)
                    relatedListAPIHandler = nil
                } else {
                    relatedListAPIHandler = nil
                }
            }
        } catch {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \( error )")
            attachmentUploadDelegate.didFail( fileRefId: fileRefId, typeCastToZCRMError( error ) )
        }
    }
    
    func setAttachment( fileRefId : String, filePath : String?, fileName : String?, fileData : Data?, apiResponse : APIResponse, _ attachmentUploadDelegate : ZCRMAttachmentUploadDelegate )
    {
        do
        {
            let attachment = try self.getAttachmentFrom( response : apiResponse )
            apiResponse.setData( data : attachment )
            
            if let filePath = filePath
            {
                attachment.fileSize = getFileSize(filePath: filePath)
                attachment.fileName = filePath.lastPathComponent(withExtension: true)
                attachment.fileExtension = filePath.pathExtension()
            }
            else if let fileName = fileName, let fileData = fileData
            {
                attachment.fileSize = Int64( fileData.count )
                attachment.fileName = fileName
                attachment.fileExtension = fileName.pathExtension()
            }
            
            if let note = self.noteAttachment
            {
                note.addAttachment( attachment : attachment )
            }
            attachmentUploadDelegate.getZCRMAttachment( fileRefId: fileRefId, attachment )
        }
        catch
        {
            attachmentUploadDelegate.didFail( fileRefId : fileRefId, typeCastToZCRMError( error ) )
        }
    }
    
    private func getAttachmentFrom( response : APIResponse ) throws -> ZCRMAttachment
    {
        let responseJSON = response.getResponseJSON()
        let respDataArr : [ [ String : Any? ] ] = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
        let respData : [String:Any?] = respDataArr[0]
        let recordDetails : [ String : Any ] = try respData.getDictionary( key : APIConstants.DETAILS )
        let attachment = try self.getZCRMAttachment(attachmentDetails: recordDetails)
        return attachment
    }
}

extension RelatedListAPIHandler
{
    internal struct ResponseJSONKeys
    {
        static let id = "id"
        static let name = "name"
        static let fileName = "File_Name"
        static let Size = "Size"
        static let createdBy = "Created_By"
        static let createdTime = "Created_Time"
        static let modifiedBy = "Modified_By"
        static let modifiedTime = "Modified_Time"
        static let owner = "Owner"
        static let editable = "$editable"
        static let type = "$type"
        static let linkURL = "$link_url"
        static let size = "$size"
        
        static let noteTitle = "Note_Title"
        static let noteContent = "Note_Content"
        static let attachments = "$attachments"
        static let parentId = "Parent_Id"
        static let seModule = "$se_module"
        static let voiceNote = "$voice_note"
        static let content = "content"
        static let module = "module"
    }
    
    struct URLPathConstants {
        static let voiceNotes = "Voice_Notes"
    }
}

public protocol ZCRMAttachmentUploadDelegate : ZCRMFileUploadDelegate
{
    func getZCRMAttachment( fileRefId : String, _ attachment : ZCRMAttachment )
}

extension RequestParamKeys
{
    static let attachmentURL : String = "attachmentUrl"
}
