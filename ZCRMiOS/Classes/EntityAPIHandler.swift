//
//  EntityAPIHandler.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 16/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

internal class EntityAPIHandler : CommonAPIHandler
{
    private var record : ZCRMRecord
    private var recordDelegate : ZCRMRecordDelegate

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
    
	// MARK: - Handler Functions
	internal func getRecord( withPrivateFields : Bool, completion : @escaping( Result.DataResponse< ZCRMRecord, APIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.DATA )
        let urlPath = "/\(self.record.moduleAPIName)/\(self.record.recordId)"
		setUrlPath(urlPath : urlPath )
        if( withPrivateFields == true )
        {
            addRequestParam( param : RequestParamKeys.include, value : APIConstants.PRIVATE_FIELDS )
        }
		setRequestMethod(requestMethod : .GET)
		let request : APIRequest = APIRequest(handler: self)
		
        print( "Request : \( request.toString() )" )
   
        request.getAPIResponse { ( resultType ) in
            do
            {
                let response = try resultType.resolve()
                let responseJSON : [String:Any] = response.getResponseJSON()
                let responseDataArray : [[String:Any]] = responseJSON.getArrayOfDictionaries(key: self.getJSONRootKey())
                self.setRecordProperties(recordDetails: responseDataArray[0])
                response.setData(data: self.record)
                completion( .success( self.record, response ))
            }
            catch
            {
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func createRecord( completion : @escaping( Result.DataResponse< ZCRMRecord, APIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.DATA )
        var reqBodyObj : [String:[[String:Any]]] = [String:[[String:Any]]]()
        var dataArray : [[String:Any]] = [[String:Any]]()
        dataArray.append(self.getZCRMRecordAsJSON() as Any as! [ String : Any ] )
        reqBodyObj[ getJSONRootKey() ] = dataArray
		
		setUrlPath(urlPath : "/\(self.record.moduleAPIName)")
		setRequestMethod(requestMethod : .POST)
		setRequestBody(requestBody : reqBodyObj)
		let request : APIRequest = APIRequest(handler : self)
        print( "Request : \( request.toString() )" )
		
        request.getAPIResponse { ( resultType ) in
            do
            {
                let response = try resultType.resolve()
                let responseJSON : [String:Any] = response.getResponseJSON()
                let respDataArr : [[String:Any?]] = responseJSON.getArrayOfDictionaries(key: self.getJSONRootKey())
                let respData : [String:Any?] = respDataArr[0]
                let recordDetails : [String:Any] = respData.getDictionary(key: APIConstants.DETAILS)
                self.setRecordProperties(recordDetails: recordDetails)
                response.setData(data: self.record)
                completion( .success( self.record, response ) )
            }
            catch
            {
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func updateRecord( completion : @escaping( Result.DataResponse< ZCRMRecord, APIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.DATA )
        var reqBodyObj : [String:[[String:Any]]] = [String:[[String:Any]]]()
        var dataArray : [[String:Any]] = [[String:Any]]()
        dataArray.append(self.getZCRMRecordAsJSON() as Any as! [ String : Any ])
        reqBodyObj[ getJSONRootKey() ] = dataArray
		
		setUrlPath(urlPath : "/\(self.record.moduleAPIName)/\( String( self.record.recordId ) )" )
		setRequestMethod( requestMethod : .PUT )
		setRequestBody( requestBody : reqBodyObj )
		let request : APIRequest = APIRequest( handler : self)
        print( "Request : \( request.toString() )" )
        
        request.getAPIResponse { ( resultType ) in
            do{
                let response = try resultType.resolve()
                let responseJSON : [String:Any] = response.getResponseJSON()
                let respDataArr : [[String:Any?]] = responseJSON.getArrayOfDictionaries(key: self.getJSONRootKey())
                let respData : [String:Any?] = respDataArr[0]
                let recordDetails : [String:Any] = respData.getDictionary(key: APIConstants.DETAILS)
                self.setRecordProperties(recordDetails: recordDetails)
                response.setData(data: self.record)
                completion( .success( self.record, response ) )
            }
            catch{
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func deleteRecord( completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
		setUrlPath(urlPath : "/\(self.record.moduleAPIName)/\(self.recordDelegate.recordId)")
		setRequestMethod(requestMethod : .DELETE )
		let request : APIRequest = APIRequest(handler : self )
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

    internal func convertRecord( newPotential : ZCRMRecord?, assignTo : ZCRMUser?, completion : @escaping( Result.DataResponse< [ String : Int64 ], APIResponse > ) -> () )
    {
        var reqBodyObj : [String:[[String:Any]]] = [String:[[String:Any]]]()
        var dataArray : [[String:Any]] = [[String:Any]]()
        var convertData : [String:Any] = [String:Any]()
        if let assignToUser = assignTo
        {
            convertData[RequestParamKeys.assignTo] = String(assignToUser.id)
        }
        if let potential = newPotential
        {
            convertData[APIConstants.DEALS] = EntityAPIHandler(record: potential).getZCRMRecordAsJSON()
        }
        dataArray.append(convertData)
        reqBodyObj[getJSONRootKey()] = dataArray
        
        setUrlPath(urlPath : "/\(self.record.moduleAPIName)/\( String( self.recordDelegate.recordId ) )/actions/convert" )
        setRequestMethod(requestMethod : .POST )
        setRequestBody(requestBody : reqBodyObj )
        let request : APIRequest = APIRequest(handler : self)
        print( "Request : \( request.toString() )" )
        
        request.getAPIResponse { ( resultType ) in
            do{
                let response = try resultType.resolve()
                let responseJSON : [String:Any] = response.getResponseJSON()
                let respDataArr : [[String:Any]] = responseJSON.getArrayOfDictionaries(key: self.getJSONRootKey())
                let respData : [String:Any] = respDataArr[0]
                var convertedDetails : [String:Int64] = [String:Int64]()
                if ( respData.hasValue( forKey : APIConstants.ACCOUNTS ) )
                {
                    convertedDetails.updateValue( respData.optInt64(key: APIConstants.ACCOUNTS)! , forKey : APIConstants.ACCOUNTS )
                }
                if ( respData.hasValue( forKey : APIConstants.DEALS ) )
                {
                    convertedDetails.updateValue( respData.optInt64(key: APIConstants.DEALS)! , forKey : APIConstants.DEALS )
                }
                convertedDetails.updateValue( respData.optInt64(key: "Contacts")! , forKey : "Contacts" )
                completion( .success( convertedDetails, response ) )
            }
            catch{
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func uploadPhotoWithPath(filePath : String,completion: @escaping(Result.Response< APIResponse > )->Void)
    {
        do
        {
            try fileDetailCheck(filePath:filePath)
            guard UIImage(contentsOfFile: filePath) != nil else {
                completion( .failure( ZCRMError.ProcessingError( code : ErrorCode.INVALID_FILE_TYPE, message : ErrorMessage.INVALID_FILE_TYPE_MSG ) ) )
                return
            }
            setUrlPath(urlPath :"/\(self.recordDelegate.moduleAPIName)/\(String(self.recordDelegate.recordId))/photo")
            setRequestMethod(requestMethod : .POST )
            let request : APIRequest = APIRequest(handler : self )
            print( "Request : \( request.toString() )" )
            request.uploadFile( filePath : filePath) { ( resultType ) in
                do{
                    let response = try resultType.resolve()
                    completion( .success( response ) )
                }
                catch{
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
        }
        catch
        {
            completion( .failure( typeCastToZCRMError( error ) ) )
        }
    }
    
    internal func uploadPhotoWithData( fileName : String, data : Data, completion: @escaping(Result.Response< APIResponse > )->Void)
    {
        setUrlPath(urlPath :"/\(self.recordDelegate.moduleAPIName)/\(String(self.recordDelegate.recordId))/photo")
        setRequestMethod(requestMethod : .POST )
        let request : APIRequest = APIRequest(handler : self )
        
        print( "Request : \( request.toString() )" )
        
        request.uploadFileWithData(fileName : fileName, data: data) { ( resultType ) in
            do{
                let response = try resultType.resolve()
                completion( .success( response ) )
            }
            catch{
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func downloadPhoto( completion : @escaping( Result.Response< FileAPIResponse > ) -> () )
    {
        setUrlPath(urlPath : "/\(self.recordDelegate.moduleAPIName)/\( String( self.recordDelegate.recordId ) )/photo" )
        setRequestMethod(requestMethod : .GET )
        let request : APIRequest = APIRequest(handler : self )
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

    internal func deletePhoto( completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        setUrlPath(urlPath : "/\( self.recordDelegate.moduleAPIName)/\( String( self.recordDelegate.recordId ) )/photo" )
        setRequestMethod(requestMethod : .DELETE )
        let request : APIRequest = APIRequest(handler : self )
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

    internal func follow( completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.DATA )
        setUrlPath( urlPath : "/\(self.recordDelegate.moduleAPIName)/\(self.recordDelegate.recordId)/actions/follow" )
        setRequestMethod( requestMethod : .PUT )
        let request : APIRequest = APIRequest( handler : self )
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
    
    internal func unfollow( completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.DATA )
        setUrlPath( urlPath : "/\(self.recordDelegate.moduleAPIName)/\(self.recordDelegate.recordId)/actions/follow" )
        setRequestMethod( requestMethod : .DELETE )
        let request : APIRequest = APIRequest( handler : self )
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
    
    // TODO : Add response object as List of Tags when overwrite false case is fixed
    internal func addTags( tags : [ZCRMTag], overWrite : Bool?, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        setJSONRootKey(key: JSONRootKey.DATA)
        let recordIdString = String(recordDelegate.recordId)
        
        setUrlPath(urlPath: "/\(self.recordDelegate.moduleAPIName)/\(recordIdString)/actions/add_tags")
        setRequestMethod(requestMethod: .POST)
        var tagNamesString : String = String()
        for index in 0..<tags.count
        {
            if tags[index].tagName != APIConstants.STRING_MOCK
            {
                tagNamesString.append( tags[index].tagName )
                if ( index != ( tags.count - 1 ) )
                {
                    tagNamesString.append(",")
                }
            }
        }
        addRequestParam(param: RequestParamKeys.tagNames, value: tagNamesString)
        if overWrite != nil
        {
            addRequestParam(param: RequestParamKeys.overWrite, value: String(overWrite!))
        }
        
        let request : APIRequest = APIRequest(handler: self)
        print("Request : \(request.toString())")
        
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
    
    internal func removeTags( tags : [ZCRMTag], completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        setJSONRootKey(key: JSONRootKey.DATA)
        let recordIdString = String(recordDelegate.recordId)
        
        setUrlPath(urlPath: "/\(self.recordDelegate.moduleAPIName)/\(recordIdString)/actions/remove_tags")
        setRequestMethod(requestMethod: .POST)
        var tagNamesString : String = String()
        for index in 0..<tags.count
        {
            if tags[index].tagName != APIConstants.STRING_MOCK
            {
                tagNamesString.append( tags[index].tagName )
                if ( index != ( tags.count - 1 ) )
                {
                    tagNamesString.append(",")
                }
            }
        }
        addRequestParam(param: RequestParamKeys.tagNames, value: tagNamesString)
        
        let request : APIRequest = APIRequest(handler: self)
        print("Request : \(request.toString())")
        
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
	
	// MARK: - Utility Functions
	private func setPriceDetails(priceDetails priceDetailsArrayOfJSON : [[ String : Any]]) {
        for priceDetailJSON in priceDetailsArrayOfJSON {
            let ZCRMPriceBookPricing = try! getZCRMPriceDetail(From: priceDetailJSON)
             record.addPriceDetail(priceDetail: ZCRMPriceBookPricing)
        }
    }
    
    private func getZCRMPriceDetail(From priceDetailDict : [ String : Any ] ) throws -> ZCRMPriceBookPricing
    {
        let priceDetail = ZCRMPriceBookPricing(id: priceDetailDict.getInt64( key : ResponseJSONKeys.id ) )
        
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
    
    
    internal func getZCRMRecordAsJSON() -> [String:Any?]
    {
        var recordJSON : [ String : Any? ] = [ String : Any? ]()
        let recordData : [ String : Any? ] = self.record.getData()
        if ( self.record.owner.id != APIConstants.INT64_MOCK )
        {
            recordJSON[ ResponseJSONKeys.owner ] = self.record.owner.id
        }
        if ( self.record.layout.layoutId != LAYOUT_NIL.layoutId )
        {
            recordJSON[ ResponseJSONKeys.layout ] = self.record.layout.layoutId
        }
        for fieldApiName in recordData.keys
        {
            var value  = recordData[ fieldApiName ]
            if( recordData[ fieldApiName ] is ZCRMRecord )
            {
                value = ( value as? ZCRMRecord )?.recordId
            }
            if( recordData[ fieldApiName ] is ZCRMUserDelegate )
            {
                value = ( value as? ZCRMUserDelegate )?.id
            }
			if( recordData[ fieldApiName ] is [ZCRMSubformRecord]  && (recordData[fieldApiName] as! [ZCRMSubformRecord]).isEmpty == false)
			{
				var subformObj : [ [ String : Any? ] ] = [ [ String : Any? ] ]()
				for subform in recordData[ fieldApiName ] as! [ ZCRMSubformRecord ]
				{
					subformObj.append( subform.fieldNameVsValue )
				}
			}
            recordJSON[ fieldApiName ] = value
        }
        if( self.record.dataProcessingBasicDetails != nil )
        {
            recordJSON[ ResponseJSONKeys.dataProcessingBasisDetails ] = self.getZCRMDataProcessingDetailsAsJSON(details: self.record.dataProcessingBasicDetails! )
        }
        recordJSON[ ResponseJSONKeys.productDetails ] = self.getLineItemsAsJSONArray()
        recordJSON[ ResponseJSONKeys.tax ] = self.getTaxAsJSONArray()
        recordJSON[ ResponseJSONKeys.participants ] = self.getParticipantsAsJSONArray()
        recordJSON[ ResponseJSONKeys.pricingDetails ] = self.getPriceDetailsAsJSONArray()
        return recordJSON
    }
    
    private func getZCRMDataProcessingDetailsAsJSON( details : ZCRMDataProcessBasicDetails ) -> [ String : Any? ]
    {
        var detailsJSON : [ String : Any? ] = [ String : Any? ]()
        let consnetThrough = details.consentThrough
        if consnetThrough != APIConstants.STRING_MOCK
        {
            detailsJSON[ ResponseJSONKeys.consentThrough ] = consnetThrough
        }
        else
        {
            detailsJSON[ ResponseJSONKeys.consentThrough ] = nil
        }
        let list = details.consentProcessThroughList
        if list.isEmpty == false
        {
            if( list.contains( ConsentProcessThrough.EMAIL.rawValue ) )
            {
                detailsJSON[ ResponseJSONKeys.contactThroughEmail ] = true
            }
            if( list.contains( ConsentProcessThrough.SOCIAL.rawValue ) )
            {
                detailsJSON[ ResponseJSONKeys.contactThroughSocial ] = true
            }
            if( list.contains( ConsentProcessThrough.SURVEY.rawValue ) )
            {
                detailsJSON[ ResponseJSONKeys.contactThroughSurvey ] = true
            }
            if( list.contains( ConsentProcessThrough.PHONE.rawValue ) )
            {
                detailsJSON[ ResponseJSONKeys.contactThroughPhone ] = true
            }
        }
        let dataProcessing = details.dataProcessingBasis
        if dataProcessing != APIConstants.STRING_MOCK
        {
            detailsJSON[ ResponseJSONKeys.dataProcessingBasis ] = dataProcessing
        }
        else
        {
            detailsJSON[ ResponseJSONKeys.dataProcessingBasis ] = nil
        }
        let date = details.consentDate
        if date != APIConstants.STRING_MOCK
        {
            detailsJSON[ ResponseJSONKeys.consentDate ] = date
        }
        else
        {
            detailsJSON[ ResponseJSONKeys.consentDate ] = nil
        }
        if let remarks = details.consentRemarks
        {
            detailsJSON[ ResponseJSONKeys.consentRemarks ] = remarks
        }
        else
        {
            detailsJSON[ ResponseJSONKeys.consentRemarks ] = nil
        }
        return detailsJSON
    }
    
    private func getTaxAsJSONArray() -> [ [ String : Any ] ]?
    {
        if ( self.record.tax.isEmpty )
        {
            return nil
        }
        var taxJSONArray : [ [ String : Any ] ] = [ [ String : Any ] ]()
        let allTax : [ ZCRMTax ] = self.record.tax
        for tax in allTax
        {
            taxJSONArray.append( self.getTaxAsJSON( tax : tax ) as Any as! [ String : Any ] )
        }
        return taxJSONArray
    }
    
    private func  getTaxAsJSON( tax : ZCRMTax ) -> [ String : Any? ]
    {
        var taxJSON : [ String : Any? ] = [ String : Any? ]()
        taxJSON[ ResponseJSONKeys.name ] = tax.taxName
        taxJSON[ ResponseJSONKeys.percentage ] = tax.percentage
        taxJSON[ ResponseJSONKeys.value ] = tax.value
        return taxJSON
    }
    
    private func getLineItemsAsJSONArray() -> [[String:Any]]?
    {
        if(self.record.lineItems.isEmpty)
        {
            return nil
        }
        var allLineItems : [[String:Any]] = [[String:Any]]()
        let allLines : [ZCRMInventoryLineItem] = self.record.lineItems
        for lineItem in allLines
        {
            allLineItems.append(self.getZCRMInventoryLineItemAsJSON(invLineItem: lineItem) as Any as! [ String : Any ] )
        }
        return allLineItems
    }
    
    private func getPriceDetailsAsJSONArray() -> [ [ String : Any ] ]?
    {
        if( self.record.priceDetails.isEmpty )
        {
            return nil
        }
        var priceDetails : [ [ String : Any ] ] = [ [ String : Any ] ]()
        let allPriceDetails : [ ZCRMPriceBookPricing ] = self.record.priceDetails
        for priceDetail in allPriceDetails
        {
            priceDetails.append( self.getZCRMPriceDetailAsJSON(priceDetail : priceDetail ) as Any as! [ String : Any ] )
        }
        return priceDetails
    }
    
    private func getParticipantsAsJSONArray() -> [ [ String : Any ] ]?
    {
        if( self.record.participants.isEmpty)
        {
            return nil
        }
        var participantsDetails : [ [ String : Any ] ] = [ [ String : Any ] ]()
        let allParticipants : [ ZCRMEventParticipant ] = self.record.participants
        for participant in allParticipants
        {
            participantsDetails.append( self.getZCRMEventParticipantAsJSON( participant : participant ) as Any as! [ String : Any ] )
        }
        return participantsDetails
    }
    
    private func getZCRMEventParticipantAsJSON( participant : ZCRMEventParticipant ) -> [ String : Any? ]
    {
        var participantJSON : [ String : Any? ] = [ String : Any? ]()
        participantJSON[ ResponseJSONKeys.participant ] = participant.id
        participantJSON[ ResponseJSONKeys.type ] = participant.type
        participantJSON[ ResponseJSONKeys.name ] = participant.name
        participantJSON[ ConsentProcessThrough.EMAIL.rawValue ] = participant.email
        participantJSON[ ResponseJSONKeys.status ] = participant.status
        participantJSON[ ResponseJSONKeys.invited ] = participant.isInvited
        return participantJSON
    }
    
    private func getZCRMPriceDetailAsJSON( priceDetail : ZCRMPriceBookPricing ) -> [ String : Any? ]
    {
        var priceDetailJSON : [ String : Any? ] = [ String : Any? ]()
        priceDetailJSON[ ResponseJSONKeys.id ] = priceDetail.id
        priceDetailJSON[ ResponseJSONKeys.discount ] = priceDetail.discount
        priceDetailJSON[ ResponseJSONKeys.toRange ] = priceDetail.toRange
        priceDetailJSON[ ResponseJSONKeys.fromRange ] = priceDetail.fromRange
        return priceDetailJSON
    }
    
    private func getZCRMInventoryLineItemAsJSON(invLineItem : ZCRMInventoryLineItem) -> [String:Any?]
    {
        var lineItem : [String:Any?] = [String:Any?]()
        if(invLineItem.id != APIConstants.INT64_MOCK)
        {
            lineItem[ResponseJSONKeys.id] = String(invLineItem.id)
        }
        else
        {
            lineItem[ResponseJSONKeys.product] = String(invLineItem.product.recordId)
        }
        if(invLineItem.deleteFlag)
        {
            lineItem[ResponseJSONKeys.delete] = true
        }
        else
        {
            lineItem[ResponseJSONKeys.productDescription] = invLineItem.description
            lineItem[ResponseJSONKeys.listPrice] = invLineItem.listPrice
            lineItem[ResponseJSONKeys.quantity] = invLineItem.quantity
            if(invLineItem.discountPercentage == 0.0)
            {
                lineItem[ResponseJSONKeys.Discount] = invLineItem.discount
            }
            else
            {
                lineItem[ResponseJSONKeys.Discount] = String(invLineItem.discountPercentage) + "%"
            }
            var allTaxes : [[String:Any]] = [[String:Any]]()
            let lineTaxes : [ ZCRMTax] = invLineItem.lineTaxes
            for lineTax in lineTaxes
            {
                var tax : [String:Any] = [String:Any]()
                tax[ResponseJSONKeys.name] = lineTax.taxName
                tax[ResponseJSONKeys.percentage] = lineTax.percentage
                allTaxes.append(tax)
            }
            if(!allTaxes.isEmpty)
            {
                lineItem[ResponseJSONKeys.lineTax] = allTaxes
            }
        }
        return lineItem
    }
    
    internal func setRecordProperties(recordDetails : [String:Any])
    {
        for (fieldAPIName, value) in recordDetails
        {
            if(ResponseJSONKeys.id == fieldAPIName)
            {
                self.record.recordId = Int64(value as! String)!
            }
            else if(ResponseJSONKeys.productDetails == fieldAPIName)
            {
                self.setInventoryLineItems(lineItems: value as! [[String:Any]])
            }
            else if( ResponseJSONKeys.pricingDetails == fieldAPIName )
            {
                self.setPriceDetails( priceDetails : value as! [ [ String : Any ] ] )
            }
            else if( ResponseJSONKeys.participants == fieldAPIName )
            {
                self.setParticipants( participantsArray : value as! [ [ String : Any ] ] )
            }
            else if( ResponseJSONKeys.dollarLineTax == fieldAPIName )
            {
                let taxesDetails : [ [ String : Any ] ] = value as! [ [ String : Any ] ]
                for taxJSON in taxesDetails
                {
                    let tax : ZCRMTax = ZCRMTax(taxName: taxJSON.getString( key : ResponseJSONKeys.name ), percentage: taxJSON.getDouble( key : ResponseJSONKeys.value ), value: taxJSON.getDouble( key : ResponseJSONKeys.percentage ))
                    self.record.addTax( tax : tax )
                }
            }
            else if( ResponseJSONKeys.tax == fieldAPIName && value is [ String ] )
            {
                let taxNames : [ String ] = value as! [ String ]
                for taxName in taxNames
                {
                    self.record.addTax( tax : ZCRMTax( taxName : taxName ) )
                }
            }
            else if(ResponseJSONKeys.createdBy == fieldAPIName)
            {
                let createdBy : [String:Any] = value as! [String : Any]
                self.record.createdBy = getUserDelegate(userJSON : createdBy)
            }
            else if(ResponseJSONKeys.modifiedBy == fieldAPIName)
            {
                let modifiedBy : [String:Any] = value as! [String : Any]
                self.record.modifiedBy = getUserDelegate(userJSON : modifiedBy)
            }
            else if(ResponseJSONKeys.createdTime == fieldAPIName)
            {
                self.record.createdTime = value as! String
            }
            else if(ResponseJSONKeys.modifiedTime == fieldAPIName)
            {
                self.record.modifiedTime = value as! String
            }
            else if(ResponseJSONKeys.owner == fieldAPIName)
            {
                let ownerObj : [String:Any] = value as! [String : Any]
                self.record.createdBy = getUserDelegate(userJSON : ownerObj)
            }
            else if(ResponseJSONKeys.layout == fieldAPIName)
            {
                if(recordDetails.hasValue(forKey: fieldAPIName))
                {
                    let layoutObj : [String:Any] = value  as! [String : Any]
                    let layout : ZCRMLayoutDelegate = ZCRMLayoutDelegate(layoutId : layoutObj.getInt64(key: ResponseJSONKeys.id), layoutName : layoutObj.getString(key: ResponseJSONKeys.name))
                    self.record.layout = layout
                }
            }
            else if(ResponseJSONKeys.handler == fieldAPIName && recordDetails.hasValue(forKey: fieldAPIName))
            {
                let handlerObj : [String: Any] = value as! [String : Any]
                let handler : ZCRMUserDelegate = ZCRMUserDelegate(id: handlerObj.getInt64(key: ResponseJSONKeys.id), name: handlerObj.getString(key: ResponseJSONKeys.name))
                self.record.setValue(forField: fieldAPIName, value: handler)
            }
            else if(fieldAPIName.hasPrefix("$"))
            {
                var propertyName : String = fieldAPIName
                propertyName.remove(at: propertyName.startIndex)
                if propertyName.contains(ResponseJSONKeys.followers), recordDetails.hasValue( forKey : fieldAPIName )
                {
                    var users : [ ZCRMUserDelegate ] = [ ZCRMUserDelegate ]()
                    let userDetails : [ [ String : Any ] ] = value as! [ [ String : Any ] ]
                    for userDetail in userDetails
                    {
                        let user : ZCRMUserDelegate = ZCRMUserDelegate( id : userDetail.getInt64( key : ResponseJSONKeys.id ), name : userDetail.getString( key : ResponseJSONKeys.name) )
                        users.append( user )
                    }
                    self.record.setValue( ofProperty : propertyName, value : users )
                }
                else
                {
                    self.record.setValue(ofProperty: propertyName, value: value)
                }
            }
            else if( ResponseJSONKeys.remindAt == fieldAPIName && recordDetails.hasValue( forKey : fieldAPIName ) )
            {
                let alarmDetails = recordDetails.getDictionary( key : fieldAPIName )
                self.record.setValue( forField : ResponseJSONKeys.ALARM, value : alarmDetails.getString( key : ResponseJSONKeys.ALARM ) )
            }
            else if( ResponseJSONKeys.recurringActivity == fieldAPIName && recordDetails.hasValue( forKey : fieldAPIName ) )
            {
                let recurringActivity = recordDetails.getDictionary( key : fieldAPIName )
                self.record.setValue( forField : ResponseJSONKeys.RRULE, value : recurringActivity.getString( key : ResponseJSONKeys.RRULE ) )
            }
            else if( value is [ String : Any ] )
            {
                let lookupDetails : [ String : Any ] = value as! [ String : Any ]
                let lookupRecord : ZCRMRecord = ZCRMRecord(moduleAPIName: fieldAPIName)
                lookupRecord.recordId = lookupDetails.getInt64( key : ResponseJSONKeys.id )
                lookupRecord.lookupLabel = lookupDetails.optString( key : ResponseJSONKeys.name )
                self.record.setValue( forField : fieldAPIName, value : lookupRecord )
            }
			else if( value is [[ String : Any ]] )
			{
				self.record.setValue(forField: fieldAPIName , value: self.getAllZCRMSubformRecords(apiName: fieldAPIName , subforms: value as! [[ String : Any]] ))
			}
            else
            {
                self.record.setValue(forField: fieldAPIName, value: value)
            }
        }
    }
	
	private func getAllZCRMSubformRecords( apiName : String , subforms : [[ String : Any]] ) -> [ZCRMSubformRecord]
	{
		var zcrmSubformRecords : [ZCRMSubformRecord] = [ZCRMSubformRecord]()
		for subform in subforms
		{
			zcrmSubformRecords.append( self.getZCRMSubformRecord(apiName: apiName , subformDetails: subform ))
		}
		return zcrmSubformRecords
	}
	
    private func getZCRMSubformRecord(apiName:String,subformDetails:[String:Any]) -> ZCRMSubformRecord
    {
        let zcrmSubform : ZCRMSubformRecord = ZCRMSubformRecord(apiName : apiName, id: subformDetails.getInt64(key: ResponseJSONKeys.id ))
        if subformDetails.hasValue(forKey: ResponseJSONKeys.modifiedTime){
            let modifiedTime = subformDetails.optString(key: ResponseJSONKeys.modifiedTime)!
            zcrmSubform.modifiedTime = modifiedTime
        }
        
        if subformDetails.hasValue(forKey: ResponseJSONKeys.createdTime){
            let createdTime = subformDetails.optString(key: ResponseJSONKeys.createdTime)!
            zcrmSubform.createdTime = createdTime
        }
        
        if subformDetails.hasValue( forKey : ResponseJSONKeys.owner )
        {
            let ownerDict = subformDetails.getDictionary( key : ResponseJSONKeys.owner )
            let owner : ZCRMUserDelegate = ZCRMUserDelegate(id: ownerDict.getInt64(key: ResponseJSONKeys.id),
                                            name: ownerDict.getString(key: ResponseJSONKeys.name))
            zcrmSubform.owner = owner
        }
        
        return zcrmSubform
    }
    
    private func getZCRMDataProcessingBasicDetails( details : [ String : Any ] ) -> ZCRMDataProcessBasicDetails
    {
        var consentProcessThroughList : [ String ] = [ String ]()
        if( details.hasValue( forKey : ResponseJSONKeys.contactThroughEmail ) && details.getBoolean( key : ResponseJSONKeys.contactThroughEmail ) == true )
        {
            consentProcessThroughList.append( ConsentProcessThrough.EMAIL.rawValue )
        }
        if( details.hasValue( forKey : ResponseJSONKeys.contactThroughSocial ) && details.getBoolean( key : ResponseJSONKeys.contactThroughSocial ) == true )
        {
            consentProcessThroughList.append( ConsentProcessThrough.SOCIAL.rawValue )
        }
        if( details.hasValue( forKey : ResponseJSONKeys.contactThroughSurvey ) && details.getBoolean( key : ResponseJSONKeys.contactThroughSurvey ) == true )
        {
            consentProcessThroughList.append( ConsentProcessThrough.SURVEY.rawValue )
        }
        if( details.hasValue( forKey : ResponseJSONKeys.contactThroughPhone ) && details.getBoolean( key : ResponseJSONKeys.contactThroughPhone ) == true )
        {
            consentProcessThroughList.append( ConsentProcessThrough.PHONE.rawValue )
        }
        let dataProcessingDetails : ZCRMDataProcessBasicDetails = ZCRMDataProcessBasicDetails(id: details.getInt64( key : ResponseJSONKeys.id ), dataProcessingBasis: details.getString(key: ResponseJSONKeys.dataProcessingBasis), consentThrough: details.getString( key : ResponseJSONKeys.consentThrough ), consentDate: details.getString( key : ResponseJSONKeys.consentDate ) , consentProcessThroughList: consentProcessThroughList )
        
        
        dataProcessingDetails.modifiedTime = details.getString(key: ResponseJSONKeys.modifiedTime )
        dataProcessingDetails.createdTime = details.getString( key : ResponseJSONKeys.createdTime )
        dataProcessingDetails.lawfulReason = details.optString( key : ResponseJSONKeys.lawfulReason )
        dataProcessingDetails.mailSentTime = details.optString( key : ResponseJSONKeys.mailSentTime )
        dataProcessingDetails.consentRemarks = details.optString( key : ResponseJSONKeys.consentRemarks )
        dataProcessingDetails.consentEndsOn = details.optString( key : ResponseJSONKeys.consentEndsOn )
        let ownerDetails : [ String : Any ] = details.getDictionary( key : ResponseJSONKeys.owner )
        let owner : ZCRMUserDelegate = ZCRMUserDelegate( id : ownerDetails.getInt64( key : ResponseJSONKeys.id ), name : ownerDetails.getString( key : ResponseJSONKeys.name ) )
        dataProcessingDetails.owner = owner
        let createdByDetails : [ String : Any ] = details.getDictionary( key : ResponseJSONKeys.createdBy )
        let createdBy : ZCRMUserDelegate = ZCRMUserDelegate( id : createdByDetails.getInt64( key : ResponseJSONKeys.id ), name : createdByDetails.getString( key : ResponseJSONKeys.name ) )
        dataProcessingDetails.createdBy = createdBy
        let modifiedByDetails : [ String : Any ] = details.getDictionary( key : ResponseJSONKeys.modifiedBy )
        let modifiedBy : ZCRMUserDelegate = ZCRMUserDelegate( id : modifiedByDetails.getInt64( key : ResponseJSONKeys.id ), name : modifiedByDetails.getString( key : ResponseJSONKeys.name ) )
        dataProcessingDetails.modifiedBy = modifiedBy
        return dataProcessingDetails
    }
	
    private func setTaxDetails( taxDetails : [ [ String : Any ] ] )
    {
        for taxDetail in taxDetails
        {
            self.record.addTax( tax : self.getZCRMTax( taxDetails: taxDetail ) )
        }
    }
    
    private func setInventoryLineItems(lineItems : [[String:Any]])
    {
        for lineItem in lineItems
        {
            self.record.addLineItem(newLineItem: getZCRMInventoryLineItem(lineItemDetails: lineItem))
        }
    }
    
    private func getZCRMInventoryLineItem(lineItemDetails : [String:Any]) -> ZCRMInventoryLineItem
    {
        let productDetails : [String:Any] = lineItemDetails.getDictionary(key: ResponseJSONKeys.product)
        let product : ZCRMRecord = ZCRMRecord(moduleAPIName: ResponseJSONKeys.products)
        product.recordId = productDetails.getInt64(key: ResponseJSONKeys.id)
        product.lookupLabel = productDetails.getString(key: ResponseJSONKeys.name)
        let lineItem : ZCRMInventoryLineItem = ZCRMInventoryLineItem(lineItemId: lineItemDetails.getInt64(key: ResponseJSONKeys.id) )
        lineItem.product = product
        lineItem.description = lineItemDetails.optString(key: ResponseJSONKeys.productDescription)
        lineItem.quantity = lineItemDetails.optDouble(key: ResponseJSONKeys.quantity) ?? APIConstants.DOUBLE_MOCK
        lineItem.listPrice = lineItemDetails.optDouble(key: ResponseJSONKeys.listPrice) ?? APIConstants.DOUBLE_MOCK
        lineItem.total = lineItemDetails.optDouble(key: ResponseJSONKeys.total) ?? APIConstants.DOUBLE_MOCK
        lineItem.discount = lineItemDetails.optDouble(key: ResponseJSONKeys.Discount) ?? APIConstants.DOUBLE_MOCK
        lineItem.totalAfterDiscount = lineItemDetails.optDouble(key: ResponseJSONKeys.totalAfterDiscount) ?? APIConstants.DOUBLE_MOCK
        lineItem.tax = lineItemDetails.optDouble(key: ResponseJSONKeys.tax) ?? APIConstants.DOUBLE_MOCK
        let allLineTaxes : [[String:Any]] = lineItemDetails.optArrayOfDictionaries(key: ResponseJSONKeys.lineTax)!
        for lineTaxDetails in allLineTaxes
        {
            lineItem.addLineTax(tax: self.getZCRMTax(taxDetails: lineTaxDetails))
        }
        lineItem.netTotal = lineItemDetails.optDouble(key: ResponseJSONKeys.netTotal) ?? APIConstants.DOUBLE_MOCK
        return lineItem
    }
    
    private func getZCRMTax( taxDetails : [ String : Any ] ) -> ZCRMTax
    {
        let lineTax : ZCRMTax = ZCRMTax(taxName: taxDetails.getString( key: ResponseJSONKeys.name ), percentage: taxDetails.getDouble( key : ResponseJSONKeys.percentage ), value: taxDetails.getDouble( key : ResponseJSONKeys.value ))
        return lineTax
    }
    
    private func setParticipants( participantsArray : [ [ String : Any ]  ] )
    {
        for participantJSON in participantsArray
        {
            let participant : ZCRMEventParticipant = self.getZCRMParticipant( participantDetails : participantJSON )
            self.record.addParticipant( participant : participant )
        }
    }
    
    private func getZCRMParticipant( participantDetails : [ String : Any ] ) -> ZCRMEventParticipant
    {
        let id : Int64 = participantDetails.getInt64( key : ResponseJSONKeys.participant )
        let type : String = participantDetails.getString( key : ResponseJSONKeys.type )
        let participant : ZCRMEventParticipant = ZCRMEventParticipant(type : type, id : id )
        participant.name = participantDetails.getString( key : ResponseJSONKeys.name )
        participant.email =  participantDetails.getString( key : ConsentProcessThrough.EMAIL.rawValue )
        participant.status = participantDetails.getString( key : ResponseJSONKeys.status )
        participant.isInvited = participantDetails.getBoolean( key : ResponseJSONKeys.invited ) 
        return participant
    }
}

fileprivate extension EntityAPIHandler
{
    struct RequestParamKeys
    {
        static let include = "include"
        static let assignTo = "assign_to"
        static let tagNames = "tag_names"
        static let overWrite = "over_write"
    }
    struct  ResponseJSONKeys
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
        
        static let dollarLineTax = "$line_tax"
        static let handler = "Handler"
        static let followers = "followers"
        static let remindAt = "Remind_At"
        static let ALARM = "ALARM"
        static let recurringActivity = "Recurring_Activity"
        static let RRULE = "RRULE"
    }
}

