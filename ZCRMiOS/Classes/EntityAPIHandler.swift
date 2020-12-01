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

    init(record : ZCRMRecord)
    {
        self.record = record
        self.recordDelegate = RECORD_MOCK
    }
    
    init( recordDelegate : ZCRMRecordDelegate )
    {
        self.recordDelegate = recordDelegate
        self.record = ZCRMRecord( moduleAPIName : self.recordDelegate.moduleAPIName )
    }
    
    init(record : ZCRMRecord, moduleFields : [String:ZCRMField])
    {
        self.record = record
        self.moduleFields = moduleFields
        self.recordDelegate = RECORD_MOCK
    }
    
    override func setModuleName() {
        self.requestedModule = recordDelegate.moduleAPIName
    }
    
	// MARK: - Handler Functions
	internal func getRecord( withPrivateFields : Bool, completion : @escaping( ResultType.DataResponse< ZCRMRecord, APIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.DATA )
        let urlPath = "\( self.record.moduleAPIName )/\( self.recordDelegate.id )"
		setUrlPath(urlPath : urlPath )
        if( withPrivateFields == true )
        {
            addRequestParam( param : RequestParamKeys.include, value : APIConstants.PRIVATE_FIELDS )
        }
		setRequestMethod(requestMethod : .get)
		let request : APIRequest = APIRequest(handler: self)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        request.getAPIResponse { ( resultType ) in
            do
            {
                let response = try resultType.resolve()
                let responseJSON : [String:Any] = response.getResponseJSON()
                let responseDataArray : [ [ String : Any ] ] = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                self.moduleFieldQueue.async {
                    self.setRecordProperties(recordDetails: responseDataArray[0], completion: { ( recordResult ) in
                        do
                        {
                            let record = try recordResult.resolve()
                            response.setData(data: record)
                            self.record.upsertJSON = [ String : Any? ]()
                            completion( .success( record, response ))
                        }
                        catch
                        {
                            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                            completion( .failure( typeCastToZCRMError( error ) ) )
                        }
                    })
                }
            }
            catch
            {
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func createRecord( triggers : [Trigger]?, completion : @escaping( ResultType.DataResponse< ZCRMRecord, APIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.DATA )
        var reqBodyObj : [ String : Any? ] = [ String : Any? ]()
        var dataArray : [ [ String : Any? ] ] = [ [ String : Any? ] ]()
        dataArray.append( self.getZCRMRecordAsJSON() )
        reqBodyObj[ getJSONRootKey() ] = dataArray
        if let triggers = triggers
        {
            reqBodyObj[ APIConstants.TRIGGER ] = getTriggerArray(triggers: triggers)
        }
		
		setUrlPath(urlPath : "\(self.record.moduleAPIName)")
		setRequestMethod(requestMethod : .post)
		setRequestBody(requestBody : reqBodyObj)
		let request : APIRequest = APIRequest(handler : self)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
		
        request.getAPIResponse { ( resultType ) in
            do
            {
                let response = try resultType.resolve()
                let responseJSON : [String:Any] = response.getResponseJSON()
                let respDataArr : [ [ String : Any? ] ] = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                let respData : [String:Any?] = respDataArr[0]
                let recordDetails : [ String : Any ] = try respData.getDictionary( key : APIConstants.DETAILS )
                for ( key, value ) in self.record.upsertJSON
                {
                    self.record.data.updateValue( value, forKey : key )
                }
                self.moduleFieldQueue.async {
                    self.setRecordProperties(recordDetails: recordDetails, completion: { ( recordResult ) in
                        do
                        {
                            let record = try recordResult.resolve()
                            response.setData(data: record)
                            self.record.upsertJSON = [ String : Any? ]()
                            self.record.isCreate = false
                            completion( .success( record, response ) )
                        }
                        catch
                        {
                            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                            completion( .failure( typeCastToZCRMError( error ) ) )
                        }
                    })
                }
            }
            catch
            {
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func updateRecord( triggers : [Trigger]?, completion : @escaping( ResultType.DataResponse< ZCRMRecord, APIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.DATA )
        if self.record.isCreate
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : RECORD ID must not be nil, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code : ErrorCode.mandatoryNotFound, message : "RECORD ID must not be nil", details : nil ) ) )
            return
        }
        var reqBodyObj : [ String : Any? ] = [ String : Any? ]()
        var dataArray : [ [ String : Any? ] ] = [ [ String : Any? ] ]()
        dataArray.append( self.getZCRMRecordAsJSON() )
        reqBodyObj[ getJSONRootKey() ] = dataArray
        if let triggers = triggers
        {
            reqBodyObj[ APIConstants.TRIGGER ] = getTriggerArray(triggers: triggers)
        }
		
		setUrlPath( urlPath : "\( self.record.moduleAPIName )/\( self.record.id )" )
		setRequestMethod( requestMethod : .patch )
		setRequestBody( requestBody : reqBodyObj )
		let request : APIRequest = APIRequest( handler : self)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        
        request.getAPIResponse { ( resultType ) in
            do{
                let response = try resultType.resolve()
                let responseJSON : [String:Any] = response.getResponseJSON()
                let respDataArr : [ [ String :Any? ] ] = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                let respData : [String:Any?] = respDataArr[0]
                let recordDetails : [ String : Any ] = try respData.getDictionary( key : APIConstants.DETAILS )
                for ( key, value ) in self.record.upsertJSON
                {
                    self.record.data.updateValue( value, forKey : key )
                }
                self.moduleFieldQueue.async {
                    self.setRecordProperties(recordDetails: recordDetails, completion: { ( recordResult ) in
                        do
                        {
                            let record = try recordResult.resolve()
                            response.setData(data: record)
                            self.record.upsertJSON = [ String : Any? ]()
                            completion( .success( record, response ) )
                        }
                        catch
                        {
                            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                            completion( .failure( typeCastToZCRMError( error ) ) )
                        }
                    })
                }
            }
            catch{
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func deleteRecord( completion : @escaping( ResultType.Response< APIResponse > ) -> () )
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
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }

    internal func convertRecord( newPotential : ZCRMRecord?, assignTo : ZCRMUser?, completion : @escaping( ResultType.DataResponse< [ String : Int64 ], APIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.DATA )
        var reqBodyObj : [ String : [ [ String : Any? ] ] ] = [ String : [ [ String : Any? ] ] ]()
        var dataArray : [ [ String : Any? ] ] = [ [ String : Any? ] ]()
        var convertData : [ String : Any? ] = [ String : Any? ]()
        if let assignToUser = assignTo
        {
            convertData[RequestParamKeys.assignTo] = String(assignToUser.id)
        }
        if let potential = newPotential
        {
            convertData[DefaultModuleAPINames.DEALS] = EntityAPIHandler(record: potential).getZCRMRecordAsJSON()
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
                if ( respData.hasValue( forKey : DefaultModuleAPINames.ACCOUNTS ) )
                {
                    convertedDetails.updateValue( try respData.getInt64( key : DefaultModuleAPINames.ACCOUNTS ) , forKey : DefaultModuleAPINames.ACCOUNTS )
                }
                if ( respData.hasValue( forKey : DefaultModuleAPINames.DEALS ) )
                {
                    convertedDetails.updateValue( try respData.getInt64( key : DefaultModuleAPINames.DEALS ) , forKey : DefaultModuleAPINames.DEALS )
                }
                convertedDetails.updateValue( try respData.getInt64( key : DefaultModuleAPINames.CONTACTS ) , forKey : DefaultModuleAPINames.CONTACTS )
                completion( .success( convertedDetails, response ) )
            }
            catch{
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func buildUploadPhotoRequest(filePath : String?, fileName : String?, fileData : Data?) throws {
        do
        {
            try fileDetailCheck( filePath : filePath, fileData : fileData, maxFileSize: MaxFileSize.entityImageAttachment )
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
    
    internal func uploadPhoto( filePath : String?, fileName : String?, fileData : Data?, completion : @escaping( ResultType.Response< APIResponse > )->Void )
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
                        ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
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
                        ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                        completion( .failure( typeCastToZCRMError( error ) ) )
                    }
                }
            }
        } catch {
            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
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
            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
            fileUploadDelegate.didFail( fileRefId : fileRefId, typeCastToZCRMError( error ) )
            return
        }
        
    }
    
    internal func downloadPhoto( completion : @escaping( ResultType.Response< FileAPIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.NIL )
        setUrlPath( urlPath : "\( self.recordDelegate.moduleAPIName )/\( self.recordDelegate.id )/\( URLPathConstants.photo )" )
        setRequestMethod(requestMethod : .get )
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
    
    internal func downloadPhoto( fileDownloadDelegate : ZCRMFileDownloadDelegate )
    {
        setJSONRootKey( key : JSONRootKey.NIL )
        setUrlPath( urlPath : "\( self.recordDelegate.moduleAPIName )/\( self.recordDelegate.id )/\( URLPathConstants.photo )" )
        setRequestMethod(requestMethod : .get )
        
        let request : FileAPIRequest = FileAPIRequest(handler: self, fileDownloadDelegate: fileDownloadDelegate)
        ZCRMLogger.logDebug(message: "Request : \(request.toString())")
        request.downloadFile( fileRefId: String( self.recordDelegate.id ) )
    }

    internal func deletePhoto( completion : @escaping( ResultType.Response< APIResponse > ) -> () )
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
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    // TODO : Add response object as List of Tags when overwrite false case is fixed
    internal func addTags( tags : [ String ], overWrite : Bool?, completion : @escaping( ResultType.DataResponse< ZCRMRecord, APIResponse > ) -> () )
    {
        setJSONRootKey(key: JSONRootKey.DATA)
        
        setUrlPath( urlPath : "\( self.recordDelegate.moduleAPIName )/\( recordDelegate.id )/\( URLPathConstants.actions )/\( URLPathConstants.addTags )" )
        setRequestMethod(requestMethod: .post)
        addRequestParam(param: RequestParamKeys.tagNames, value: tags.joined(separator: ",") )
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
                    self.record.tags = [ String ]()
                    for tag in tags
                    {
                        self.record.tags?.append( tag )
                    }
                }
                else if let tags = try tagDetails.getArrayOfDictionaries(key: JSONRootKey.TAGS) as? [ [ String : String ] ]
                {
                    self.record.tags = [ String ]()
                    for tag in tags
                    {
                        self.record.tags?.append( try tag.getString(key: ResponseJSONKeys.name) )
                    }
                }
                completion( .success( self.record, response ) )
            }
            catch{
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func removeTags( tags : [ String ], completion : @escaping( ResultType.DataResponse< ZCRMRecord, APIResponse > ) -> () )
    {
        setJSONRootKey(key: JSONRootKey.DATA)
        
        setUrlPath( urlPath : "\( self.recordDelegate.moduleAPIName )/\( recordDelegate.id )/\( URLPathConstants.actions )/\( URLPathConstants.removeTags )" )
        setRequestMethod(requestMethod: .post)
        addRequestParam(param: RequestParamKeys.tagNames, value: tags.joined(separator: ","))
        
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
                    self.record.tags = [ String ]()
                    for tag in tags
                    {
                        self.record.tags?.append( tag )
                    }
                }
                else if let tags = try tagDetails.getArrayOfDictionaries(key: JSONRootKey.TAGS) as? [ [ String : String ] ]
                {
                    self.record.tags = [ String ]()
                    for tag in tags
                    {
                        self.record.tags?.append( try tag.getString(key: ResponseJSONKeys.name) )
                    }
                }
                completion( .success( self.record, response ) )
            }
            catch{
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
	
	// MARK: - Utility Functions
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
        if self.record.id != APIConstants.INT64_MOCK
        {
            recordJSON.updateValue( record.id, forKey : ResponseJSONKeys.id )
        }
        for ( key, value ) in self.record.upsertJSON
        {
            if key == ResponseJSONKeys.owner, value is ZCRMUserDelegate, let owner = value as? ZCRMUserDelegate
            {
                recordJSON.updateValue(owner.id, forKey: ResponseJSONKeys.owner)
            }
            else if key == ResponseJSONKeys.layout
            {
                if value == nil
                {
                    recordJSON.updateValue( nil, forKey : ResponseJSONKeys.layout )
                }
                else if value is ZCRMLayout, let layout = value as? ZCRMLayout
                {
                    recordJSON.updateValue( layout.id, forKey : ResponseJSONKeys.layout )
                }
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
            }
            else if key == ResponseJSONKeys.productDetails
            {
                if value == nil
                {
                    recordJSON.updateValue( nil, forKey : ResponseJSONKeys.productDetails )
                }
                else if value is [ ZCRMInventoryLineItem ], let lineItems = value as? [ ZCRMInventoryLineItem ]
                {
                    recordJSON.updateValue(self.getLineItemsAsJSONArray(lineItems: lineItems), forKey: ResponseJSONKeys.productDetails)
                }
            }
            else if key == ResponseJSONKeys.dollarLineTax
            {
                if value == nil
                {
                    recordJSON.updateValue( nil, forKey : ResponseJSONKeys.dollarLineTax )
                }
                else if value is [ ZCRMTax ], let tax = value as? [ ZCRMLineTax ]
                {
                    recordJSON.updateValue( self.getLineTaxAsJSONArray( lineTaxes : tax ), forKey : ResponseJSONKeys.dollarLineTax )
                }
            }
            else if key == ResponseJSONKeys.tax
            {
                if value == nil
                {
                    recordJSON.updateValue( nil, forKey : ResponseJSONKeys.tax )
                }
                else if let taxes = value as? [ ZCRMTaxDelegate ]
                {
                    recordJSON.updateValue( self.getTaxAsJSONArray( taxes : taxes ), forKey : ResponseJSONKeys.tax )
                }
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
            }
            else
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
                else if value is [ ZCRMRecordDelegate ], let record = value as? [ ZCRMRecordDelegate ]
                {
                    recordJSON.updateValue( self.getZCRMRecordIdsAsArray( record ), forKey : key )
                }
                else if value is [ ZCRMSubformRecord ], let subformRecords = value as? [ ZCRMSubformRecord ]
                {
                    recordJSON.updateValue(self.getAllZCRMSubformRecordAsJSONArray(apiName: key, subformRecords: subformRecords), forKey: key)
                }
                else
                {
                    recordJSON.updateValue( value, forKey : key )
                }
            }
        }
        return recordJSON
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
                if( list.contains( CommunicationPreferences.email ) )
                {
                    detailsJSON.updateValue( true, forKey : ResponseJSONKeys.contactThroughEmail )
                }
                else
                {
                    detailsJSON.updateValue( false, forKey : ResponseJSONKeys.contactThroughEmail )
                }
                if( list.contains( CommunicationPreferences.survey ) )
                {
                    detailsJSON.updateValue( true, forKey : ResponseJSONKeys.contactThroughSurvey )
                }
                else
                {
                    detailsJSON.updateValue( false, forKey : ResponseJSONKeys.contactThroughSurvey )
                }
                if( list.contains( CommunicationPreferences.phone ) )
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
    
    private func getTaxAsJSONArray( taxes : [ ZCRMTaxDelegate ] ) -> [ String ]
    {
        var taxNames : [ String ] = [ String ]()
        for tax in taxes
        {
            taxNames.append( tax.name )
        }
        return taxNames
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
        if participant.type == EventParticipantType.user, let user = participant.participant.getUser()
        {
            participantJSON.updateValue( "\( user.id )", forKey : ResponseJSONKeys.participant )
        }
        else if participant.type == EventParticipantType.contact, let record = participant.participant.getRecord()
        {
            participantJSON.updateValue( "\( record.id )", forKey : ResponseJSONKeys.participant )
        }
        else if participant.type == EventParticipantType.lead, let record = participant.participant.getRecord()
        {
            participantJSON.updateValue( "\( record.id )", forKey : ResponseJSONKeys.participant )
        }
        else if participant.type == EventParticipantType.email, let email = participant.participant.getEmail()
        {
            participantJSON.updateValue( email, forKey : ResponseJSONKeys.participant )
        }
        participantJSON.updateValue( participant.email, forKey : CommunicationPreferences.email.rawValue )
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
        lineItem.updateValue( String( invLineItem.product.id ), forKey : ResponseJSONKeys.product )
        if invLineItem.id != APIConstants.INT64_MOCK
        {
            lineItem.updateValue( invLineItem.id, forKey : ResponseJSONKeys.id )
        }
        if let description = invLineItem.description
        {
            lineItem.updateValue( description, forKey : ResponseJSONKeys.productDescription )
        }
        lineItem.updateValue( invLineItem.listPrice, forKey : ResponseJSONKeys.listPrice )
        lineItem.updateValue( invLineItem.quantity, forKey : ResponseJSONKeys.quantity )
        lineItem.updateValue( invLineItem.discountPercentage, forKey : ResponseJSONKeys.Discount )
        var allTaxes : [ [ String : Any? ] ] = [ [ String : Any? ] ]()
        let lineTaxes : [ ZCRMLineTax] = invLineItem.lineTaxes
        for lineTax in lineTaxes
        {
            var tax : [ String : Any? ] = [ String : Any? ]()
            tax.updateValue( lineTax.name, forKey : ResponseJSONKeys.name )
            tax.updateValue( lineTax.percentage, forKey : ResponseJSONKeys.percentage )
            allTaxes.append( tax )
        }
        if !allTaxes.isEmpty
        {
            lineItem.updateValue( allTaxes, forKey : ResponseJSONKeys.lineTax )
        }
        if let priceBookId = invLineItem.priceBookId
        {
            lineItem.updateValue( priceBookId, forKey: ResponseJSONKeys.priceBookId )
        }
        lineItem.updateValue( invLineItem.quantityInStock, forKey: ResponseJSONKeys.quantityInStock)
        return lineItem
    }
    
    internal func setRecordProperties(recordDetails : [String:Any], completion : @escaping( ResultType.Data< ZCRMRecord > ) -> ())
    {
        var setRecordError : Error?
        let dispatchGroup : DispatchGroup = DispatchGroup()
        let dispatchQueue : DispatchQueue = DispatchQueue(label: "com.zoho.crm.sdk.EntityAPIHandler.setRecordProperties")
        var lookups : [ String : Any? ] = [ String : Any? ]()
        var subforms : [ String : [ ZCRMSubformRecord ] ] = [ String : [ ZCRMSubformRecord ] ]()
        self.record.isCreate = false
        do
        {
            for (fieldAPIName, value) in recordDetails
            {
                if let error = setRecordError
                {
                    throw error
                }
                if(ResponseJSONKeys.id == fieldAPIName), let idStr = value as? String, let id = Int64( idStr )
                {
                    self.record.id = id
                    self.record.isCreate = false
                    self.record.data.updateValue( self.record.id, forKey : ResponseJSONKeys.id )
                }
                else if(ResponseJSONKeys.productDetails == fieldAPIName) && ( self.record.moduleAPIName == DefaultModuleAPINames.SALES_ORDERS || self.record.moduleAPIName == DefaultModuleAPINames.PURCHASE_ORDERS || self.record.moduleAPIName == DefaultModuleAPINames.INVOICES || self.record.moduleAPIName == DefaultModuleAPINames.QUOTES ), let lineItems = value as? [[ String : Any ]]
                {
                    try self.setInventoryLineItems(lineItems: lineItems)
                    self.record.data.updateValue( lineItems, forKey : ResponseJSONKeys.productDetails )
                }
                else if( ResponseJSONKeys.pricingDetails == fieldAPIName ) && (self.record.moduleAPIName == DefaultModuleAPINames.PRICE_BOOKS), let priceDetails = value as? [[ String: Any ]]
                {
                    try self.setPriceDetails( priceDetails : priceDetails )
                    self.record.data.updateValue( self.record.priceDetails, forKey : ResponseJSONKeys.pricingDetails )
                }
                else if( ResponseJSONKeys.participants == fieldAPIName ) && (self.record.moduleAPIName == DefaultModuleAPINames.EVENTS)
                {
                    if recordDetails.hasValue( forKey : ResponseJSONKeys.participants ), let participantsArray = value as? [ [ String : Any ] ]
                    {
                        try self.setParticipants( participantsArray : participantsArray )
                        self.record.data.updateValue( self.record.participants, forKey : ResponseJSONKeys.participants )
                    }
                    else
                    {
                        ZCRMLogger.logDebug(message: "Type of participants should be array of dictionaries")
                    }
                }
                else if( ResponseJSONKeys.dollarLineTax == fieldAPIName ) && ( self.record.moduleAPIName == DefaultModuleAPINames.SALES_ORDERS || self.record.moduleAPIName == DefaultModuleAPINames.PURCHASE_ORDERS || self.record.moduleAPIName == DefaultModuleAPINames.INVOICES || self.record.moduleAPIName == DefaultModuleAPINames.QUOTES ), let taxesDetails = value as? [[ String : Any ]]
                {
                    for taxJSON in taxesDetails
                    {
                        let tax : ZCRMLineTax = try ZCRMLineTax( name : taxJSON.getString( key : ResponseJSONKeys.name ), percentage : taxJSON.getDouble( key : ResponseJSONKeys.percentage ) )
                        tax.value = try taxJSON.getDouble( key : ResponseJSONKeys.value )
                        try self.record.addLineTax( lineTax : tax )
                    }
                    self.record.data.updateValue( self.record.lineTaxes, forKey : ResponseJSONKeys.dollarLineTax )
                }
                else if( ResponseJSONKeys.tax == fieldAPIName && value is [ String ] ), let taxNames = value as? [ String ]
                {
                    for taxName in taxNames
                    {
                        try self.record.addTax( tax : ZCRMTaxDelegate( name : taxName ) )
                    }
                    self.record.data.updateValue( self.record.taxes, forKey : ResponseJSONKeys.tax )
                }
                else if( ResponseJSONKeys.tax == fieldAPIName && value is [[ String : Any ]] ), let taxDetails = value as? [[ String : Any ]]
                {
                    for tax in taxDetails
                    {
                        try self.record.addTax( tax : ZCRMTaxDelegate( name : tax.getString(key: ResponseJSONKeys.value) ) )
                    }
                    self.record.data.updateValue( self.record.taxes, forKey : ResponseJSONKeys.tax )
                }
                else if ( ResponseJSONKeys.tag == fieldAPIName ), let tagsDetails = value as? [[ String : Any ]]
                {
                    if self.record.tags == nil
                    {
                        self.record.tags = [ String ]()
                    }
                    for tagJSON in tagsDetails
                    {
                        self.record.tags?.append( try tagJSON.getString( key : ResponseJSONKeys.name ) )
                    }
                    self.record.data.updateValue( self.record.tags, forKey : ResponseJSONKeys.tag )
                }
                else if(ResponseJSONKeys.createdBy == fieldAPIName), let createdBy = value as? [ String : Any ]
                {
                    self.record.createdBy = try getUserDelegate(userJSON : createdBy)
                    self.record.data.updateValue( self.record.createdBy, forKey : ResponseJSONKeys.createdBy )
                }
                else if(ResponseJSONKeys.modifiedBy == fieldAPIName), let modifiedBy : [String:Any] = value as? [String : Any]
                {
                    self.record.modifiedBy = try getUserDelegate(userJSON : modifiedBy)
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
                else if( ResponseJSONKeys.activityType == fieldAPIName ), let activityType = value as? String
                {
                    self.record.moduleAPIName = activityType
                    self.record.data.updateValue(self.record.moduleAPIName, forKey: ResponseJSONKeys.activityType)
                }
                else if(ResponseJSONKeys.owner == fieldAPIName), let ownerObj : [String:Any] = value as? [String : Any]
                {
                    self.record.owner = try getUserDelegate(userJSON : ownerObj)
                    self.record.data.updateValue( self.record.owner, forKey : ResponseJSONKeys.owner )
                }
                else if ResponseJSONKeys.dataProcessingBasisDetails == fieldAPIName, let dataProcessingDetails = value as? [String:Any]
                {
                    let dataProcessingBasisDetails : ZCRMDataProcessBasisDetails = try self.getZCRMDataProcessingBasisDetails(details: dataProcessingDetails)
                    self.record.dataProcessingBasisDetails = dataProcessingBasisDetails
                    self.record.data.updateValue( self.record.dataProcessingBasisDetails, forKey : ResponseJSONKeys.dataProcessingBasisDetails )
                }
                else if(ResponseJSONKeys.layout == fieldAPIName)
                {
                    if(recordDetails.hasValue(forKey: fieldAPIName)), let layoutObj : [String:Any] = value  as? [String : Any]
                    {
                        let layout : ZCRMLayoutDelegate = ZCRMLayoutDelegate( id : try layoutObj.getInt64( key : ResponseJSONKeys.id ), name : try layoutObj.getString( key : ResponseJSONKeys.name ) )
                        self.record.layout = layout
                        self.record.data.updateValue( layout, forKey : ResponseJSONKeys.layout )
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
                        self.record.properties.updateValue(users, forKey: propertyName)
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
                else if( value is [ String : Any ] )
                {
                    dispatchGroup.enter()
                    self.getModuleFields(recordDetails: recordDetails, fieldAPIName: fieldAPIName, cacheFlavour: CacheFlavour.urlVsResponse) { ( lookup, error ) in

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
                else if let subformRecordsDetails = value as? [[ String : Any]], !subformRecordsDetails.isEmpty
                {
                    dispatchGroup.enter()
                    self.makeFieldAPIRequest(fieldApiName: fieldAPIName) { ( isSubformRecord, error ) in
                        if let err = error
                        {
                            completion( .failure( typeCastToZCRMError( err ) ))
                        }
                        if isSubformRecord
                        {
                            if self.record.subformRecord == nil
                            {
                                self.record.subformRecord = [ String : [ ZCRMSubformRecord ] ]()
                            }
                            dispatchGroup.enter()
                            self.getAllZCRMSubformRecords(apiName: fieldAPIName, subforms: subformRecordsDetails, completion: { ( subformRecord, error ) in
                                if let err = error
                                {
                                    setRecordError = err
                                }
                                if let subformRecord = subformRecord
                                {
                                    subforms.updateValue( subformRecord, forKey : fieldAPIName )
                                }
                                dispatchGroup.leave()
                            })
                            dispatchGroup.leave()
                        }
                        else
                        {
                            self.record.data.updateValue(value, forKey: fieldAPIName)
                            dispatchGroup.leave()
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
                    self.record.data.updateValue( value, forKey : key )
                }
                for ( key, value ) in subforms
                {
                    dispatchQueue.sync {
                        self.record.subformRecord?.updateValue( value, forKey : key )
                        self.record.data.updateValue( value, forKey : key )
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
    
    private func makeFieldAPIRequest( fieldApiName : String, completion : @escaping ( Bool, Error? ) -> Void )
    {
        if self.moduleFields == nil
        {
            moduleFieldQueue.sync {
                ModuleAPIHandler( module : ZCRMModuleDelegate( apiName :  self.record.moduleAPIName ), cacheFlavour : .urlVsResponse ).getAllFields( modifiedSince : nil ) { ( result ) in
                    do
                    {
                        let resp = try result.resolve()
                        self.moduleFields = getFieldVsApinameMap(fields: resp.data)
                        
                        self.isSubform( fieldApiName ) { ( isSubformRecord, error ) in
                            completion( isSubformRecord, error )
                        }
                    }
                    catch
                    {
                        ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
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
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.moduleFieldNotFound) : Subform module field - the \( fieldAPIName ) has not found.")
                completion( false, ZCRMError.inValidError(code: ErrorCode.moduleFieldNotFound, message: "Subform module field - the \( fieldAPIName ) has not found.", details: nil) )
            }
        }
        else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.invalidData) : Module fields is not available")
            completion( false, ZCRMError.inValidError(code: ErrorCode.invalidData, message: "Module fields is not available", details: nil) )
        }
    }
    
    private func getModuleFields( recordDetails : [ String : Any ], fieldAPIName : String, cacheFlavour : CacheFlavour, completion : @escaping ( Any?, Error? ) -> () )
    {
        if self.moduleFields == nil
        {
            ModuleAPIHandler( module : ZCRMModuleDelegate( apiName :  self.record.moduleAPIName ), cacheFlavour : .urlVsResponse ).getAllFields( modifiedSince : nil ) { ( result ) in
                do
                {
                    let resp = try result.resolve()
                    self.moduleFields = getFieldVsApinameMap(fields: resp.data)
                    self.setLookup( recordDetails : recordDetails, fieldAPIName : fieldAPIName, cacheFlavour : cacheFlavour ) { ( lookup, error ) in
                        completion( lookup, error )
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
            self.setLookup( recordDetails : recordDetails, fieldAPIName : fieldAPIName, cacheFlavour : cacheFlavour ) { ( lookup, error ) in
                completion( lookup, error )
            }
        }
    }
    
    private func setLookup( recordDetails : [ String : Any ], fieldAPIName : String, cacheFlavour : CacheFlavour, completion : @escaping ( Any?, Error? ) -> () )
    {
        if let lookupDetails = recordDetails.optDictionary(key: fieldAPIName)
        {
            do
            {
                if fieldAPIName == ResponseJSONKeys.whatId
                {
                    let lookupRecord : ZCRMRecordDelegate = ZCRMRecordDelegate( id : try lookupDetails.getInt64( key : ResponseJSONKeys.id ), moduleAPIName : try recordDetails.getString( key : ResponseJSONKeys.seModule ) )
                    lookupRecord.label = lookupDetails.optString( key : ResponseJSONKeys.name )
                    completion( lookupRecord, nil )
                }
                else
                {
                    if let moduleFields = self.moduleFields
                    {
                        if let field = moduleFields[ fieldAPIName ]
                        {
                            if field.dataType == FieldDataTypeConstants.userLookup
                            {
                                let lookupUser : ZCRMUserDelegate = try getUserDelegate(userJSON: lookupDetails)
                                completion( lookupUser, nil )
                            }
                            else if field.dataType == FieldDataTypeConstants.ownerLookup
                            {
                                let lookupUser : ZCRMUserDelegate = try getUserDelegate(userJSON: lookupDetails)
                                completion( lookupUser, nil )
                            }
                            else
                            {
                                if let apiName = field.lookup?[ ResponseJSONKeys.module ] as? String
                                {
                                    let lookupRecord : ZCRMRecordDelegate = ZCRMRecordDelegate( id : try lookupDetails.getInt64( key : ResponseJSONKeys.id ), moduleAPIName : apiName )
                                    lookupRecord.label = lookupDetails.optString( key : ResponseJSONKeys.name )
                                    completion( lookupRecord, nil )
                                }
                                else
                                {
                                    ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.moduleFieldNotFound) : Lookup module field not found, \( APIConstants.DETAILS ) : -")
                                    completion( nil, ZCRMError.inValidError(code: ErrorCode.moduleFieldNotFound, message: "Lookup module field not found", details: nil) )
                                }
                            }
                        }
                        else
                        {
                            if cacheFlavour != CacheFlavour.noCache
                            {
                                self.moduleFields = nil
                                getModuleFields(recordDetails: recordDetails, fieldAPIName: fieldAPIName, cacheFlavour: CacheFlavour.noCache) { ( lookup, error ) in
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
                                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.moduleFieldNotFound) : Lookup module field not found, \( APIConstants.DETAILS ) : -")
                                completion( nil, ZCRMError.inValidError(code: ErrorCode.moduleFieldNotFound, message: "Lookup module field not found", details: nil) )
                            }
                        }
                    }
                    else
                    {
                        ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.moduleFieldNotFound) : Lookup module field not found, \( APIConstants.DETAILS ) : -")
                        completion( nil, ZCRMError.inValidError(code: ErrorCode.moduleFieldNotFound, message: "Lookup module field not found", details: nil) )
                    }
                }
            }
            catch
            {
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( nil, error )
            }
        }
    }
	
    private func getAllZCRMSubformRecords( apiName : String , subforms : [[ String : Any]], completion : @escaping( [ZCRMSubformRecord]?, Error? ) -> () )
    {
        var zcrmSubformRecords : [ZCRMSubformRecord] = [ZCRMSubformRecord]()
        var unOrderedZCRMSubformRecords : [Int : ZCRMSubformRecord] = [Int : ZCRMSubformRecord]()
        var subformRecErr : Error?
        let dispatchQueue : DispatchQueue = DispatchQueue(label: "com.zoho.crm.sdk.EntityAPIHandler.getAllZCRMSubformRecords")
        let dispatchGroup : DispatchGroup = DispatchGroup()
        ModuleAPIHandler( module : ZCRMModuleDelegate( apiName : apiName ), cacheFlavour : .urlVsResponse ).getAllFields( modifiedSince : nil ) { ( result ) in
            do
            {
                let resp = try result.resolve()
                self.subformModuleFields.updateValue(getFieldVsApinameMap(fields: resp.data), forKey: apiName)
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
                    zcrmSubform.owner = try getUserDelegate(userJSON : ownerObj)
                    zcrmSubform.setValue( ofFieldAPIName : ResponseJSONKeys.owner, value : ownerObj )
                }
                else if(ResponseJSONKeys.createdBy == fieldAPIName), let createdBy = value as? [String : Any]
                {
                    zcrmSubform.createdBy = try getUserDelegate(userJSON : createdBy)
                    zcrmSubform.setValue( ofFieldAPIName : ResponseJSONKeys.createdBy, value : zcrmSubform.createdBy )
                }
                else if(ResponseJSONKeys.modifiedBy == fieldAPIName), let modifiedBy = value as? [String : Any]
                {
                    zcrmSubform.modifiedBy = try getUserDelegate(userJSON : modifiedBy)
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

    private func getSubformModuleFields( recordDetails : [ String : Any ], fieldAPIName : String, apiName : String, cacheFlavour : CacheFlavour, completion : @escaping ( ZCRMRecordDelegate?, Error? ) -> () )
    {
        if self.subformModuleFields[ apiName ] == nil
        {
            ModuleAPIHandler( module : ZCRMModuleDelegate( apiName : apiName ), cacheFlavour : .urlVsResponse ).getAllFields( modifiedSince : nil ) { ( result ) in
                do
                {
                    let resp = try result.resolve()
                    self.subformModuleFields.updateValue(getFieldVsApinameMap(fields: resp.data), forKey: apiName)
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
    
    private func setSubformRecordLookup( recordDetails : [ String : Any ], fieldAPIName : String, apiName : String, cacheFlavour : CacheFlavour, completion : @escaping ( ZCRMRecordDelegate?, Error? ) -> () )
    {
        if let lookupDetails = recordDetails.optDictionary(key: fieldAPIName)
        {
            do
            {
                if let apiDict = self.subformModuleFields[ apiName ]
                {
                    if let field = apiDict?[ fieldAPIName ]
                    {
                        if let moduleAPIName = field.lookup?[ ResponseJSONKeys.module ] as? String
                        {
                            let lookupRecord : ZCRMRecordDelegate = ZCRMRecordDelegate( id : try lookupDetails.getInt64( key : ResponseJSONKeys.id ), moduleAPIName : moduleAPIName )
                            lookupRecord.label = lookupDetails.optString( key : ResponseJSONKeys.name )
                            completion( lookupRecord, nil )
                        }
                        else
                        {
                            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.moduleFieldNotFound) : Lookup module field not found, \( APIConstants.DETAILS ) : -")
                            completion( nil, ZCRMError.inValidError(code: ErrorCode.moduleFieldNotFound, message: "Lookup module field not found", details: nil) )
                        }
                    }
                    else
                    {
                        ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.moduleFieldNotFound) : Lookup Field API Name not found")
                        completion( nil, ZCRMError.inValidError(code: ErrorCode.moduleFieldNotFound, message: "Lookup Field API Name not found", details: nil) )
                    }
                }
                else
                {
                    if cacheFlavour != CacheFlavour.noCache
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
                        ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.moduleFieldNotFound) : Lookup module field not found")
                        completion( nil, ZCRMError.inValidError(code: ErrorCode.moduleFieldNotFound, message: "Lookup module field not found", details: nil) )
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
        var communicationPreferencesList : [ CommunicationPreferences ] = [ CommunicationPreferences ]()
        if try( details.hasValue( forKey : ResponseJSONKeys.contactThroughEmail ) && details.getBoolean( key : ResponseJSONKeys.contactThroughEmail ) == true )
        {
            communicationPreferencesList.append( CommunicationPreferences.email )
        }
        if try( details.hasValue( forKey : ResponseJSONKeys.contactThroughSurvey ) && details.getBoolean( key : ResponseJSONKeys.contactThroughSurvey ) == true )
        {
            communicationPreferencesList.append( CommunicationPreferences.survey )
        }
        if try( details.hasValue( forKey : ResponseJSONKeys.contactThroughPhone ) && details.getBoolean( key : ResponseJSONKeys.contactThroughPhone ) == true )
        {
            communicationPreferencesList.append( CommunicationPreferences.phone )
        }
        let dataProcessingDetails : ZCRMDataProcessBasisDetails = ZCRMDataProcessBasisDetails( id : try details.getInt64( key : ResponseJSONKeys.id ), dataProcessingBasis : try details.getString( key : ResponseJSONKeys.dataProcessingBasis ), communicationPreferences : communicationPreferencesList )
        if let consent = details.optString( key : ResponseJSONKeys.consentThrough ), let consentThrough = try dataProcessingDetails.parseConsentFromAPI(consentAPIString: consent) {
            dataProcessingDetails.consentThrough = consentThrough
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
        let productDetails : [ String : Any ] = try lineItemDetails.getDictionary( key : ResponseJSONKeys.product )
        let product : ZCRMRecord = ZCRMRecord(moduleAPIName: ResponseJSONKeys.products)
        product.id = try productDetails.getInt64( key : ResponseJSONKeys.id )
        product.label = try productDetails.getString( key : ResponseJSONKeys.name )
        let lineItem : ZCRMInventoryLineItem = ZCRMInventoryLineItem( id : try lineItemDetails.getInt64( key : ResponseJSONKeys.id ) )
        lineItem.product = product
        if let productCode = lineItemDetails.optString(key: ResponseJSONKeys.productCode)
        {
            lineItem.product.data.updateValue( productCode, forKey: ResponseJSONKeys.productCode)
        }
        lineItem.description = lineItemDetails.optString(key: ResponseJSONKeys.productDescription)
        lineItem.quantity = try lineItemDetails.getDouble( key : ResponseJSONKeys.quantity )
        lineItem.listPrice = try lineItemDetails.getDouble( key : ResponseJSONKeys.listPrice )
        lineItem.total = try lineItemDetails.getDouble( key : ResponseJSONKeys.total )
        lineItem.discount = try lineItemDetails.getDouble( key : ResponseJSONKeys.Discount )
        lineItem.totalAfterDiscount = try lineItemDetails.getDouble( key : ResponseJSONKeys.totalAfterDiscount )
        lineItem.tax = try lineItemDetails.getDouble( key : ResponseJSONKeys.tax )
        if lineItemDetails.hasValue(forKey: ResponseJSONKeys.lineTax)
        {
            let allLineTaxes : [ [ String : Any ] ] = try lineItemDetails.getArrayOfDictionaries( key : ResponseJSONKeys.lineTax )
            for lineTaxDetails in allLineTaxes
            {
                lineItem.addLineTax( tax : try self.getZCRMLineTax( taxDetails : lineTaxDetails ) )
            }
        }
        lineItem.netTotal = try lineItemDetails.getDouble( key : ResponseJSONKeys.netTotal )
        lineItem.priceBookId = lineItemDetails.optInt64( key: ResponseJSONKeys.priceBookId )
        lineItem.quantityInStock = try lineItemDetails.getDouble( key: ResponseJSONKeys.quantityInStock )
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
        guard let eventType = EventParticipantType(rawValue: type) else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.invalidData) : Event type seems to be invalid, \( APIConstants.DETAILS ) : -")
            throw ZCRMError.inValidError( code : ErrorCode.invalidData, message : "Event type seems to be invalid", details : nil )
        }
        var eventParticipant : EventParticipant!
        switch eventType
        {
            case .email :
                let email =  try participantDetails.getString( key : ResponseJSONKeys.participant )
                eventParticipant = EventParticipant.email( email )
                break
            
            case .user :
                let user = ZCRMUserDelegate( id : try participantDetails.getString( key : ResponseJSONKeys.participant ), name : try participantDetails.getString( key : ResponseJSONKeys.name ) )
                eventParticipant = EventParticipant.user( user )
                break
            
            case .contact :
                let entity = ZCRMRecordDelegate( id : try participantDetails.getInt64( key : ResponseJSONKeys.participant ), moduleAPIName : DefaultModuleAPINames.CONTACTS )
                entity.label = try participantDetails.getString( key : ResponseJSONKeys.name )
                eventParticipant = EventParticipant.record(entity)
                break
            
            case .lead :
                let entity = ZCRMRecordDelegate( id : try participantDetails.getInt64( key : ResponseJSONKeys.participant ), moduleAPIName : DefaultModuleAPINames.LEADS )
                entity.label = try participantDetails.getString( key : ResponseJSONKeys.name )
                eventParticipant = EventParticipant.record(entity)
                break
        }
        let participant : ZCRMEventParticipant = ZCRMEventParticipant(type : eventType, id : id, participant : eventParticipant )
        participant.status = try participantDetails.getString( key : ResponseJSONKeys.status )
        participant.isInvited = try participantDetails.getBoolean( key : ResponseJSONKeys.invited )
        if participantDetails.hasValue(forKey: CommunicationPreferences.email.rawValue)
        {
            participant.email = try participantDetails.getString( key : CommunicationPreferences.email.rawValue )
        }
        return participant
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
        static let products = "Products"
        static let delete = "delete"
        static let productDescription = "product_description"
        static let listPrice = "list_price"
        static let quantity = "quantity"
        static let lineTax = "line_tax"
        static let total = "total"
        static let totalAfterDiscount = "total_after_discount"
        static let netTotal = "net_total"
        static let priceBookId = "book"
        static let quantityInStock = "quantity_in_stock"
        static let productCode = "Product_Code"
        
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
    }
}

extension RequestParamKeys
{
    static let include = "include"
    static let assignTo = "assign_to"
    static let tagNames = "tag_names"
    static let overWrite = "over_write"
    static let filter = "filter"
}
