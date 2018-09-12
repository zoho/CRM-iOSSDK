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

    init(record : ZCRMRecord)
    {
        self.record = record
    }
    
	// MARK: - Handler Functions
	internal func getRecord( withPrivateFields : Bool, completion : @escaping( Result.DataResponse< ZCRMRecord, APIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.DATA )
        let urlPath = "/\(self.record.getModuleAPIName())/\(self.record.getId())"
		setUrlPath(urlPath : urlPath )
        if( withPrivateFields == true )
        {
            addRequestParam( param : RequestParamKeys.include, value : PRIVATE_FIELDS )
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
		
		setUrlPath(urlPath : "/\(self.record.getModuleAPIName())")
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
                let recordDetails : [String:Any] = respData.getDictionary(key: DETAILS)
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
		
		setUrlPath(urlPath : "/\(self.record.getModuleAPIName())/\( String( self.record.getId() ) )" )
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
                let recordDetails : [String:Any] = respData.getDictionary(key: DETAILS)
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
		setUrlPath(urlPath : "/\(self.record.getModuleAPIName())/\(self.record.getId())")
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
            convertData[RequestParamKeys.assignTo] = String(assignToUser.getId()!)
        }
        if let potential = newPotential
        {
            convertData[DEALS] = EntityAPIHandler(record: potential).getZCRMRecordAsJSON()
        }
        dataArray.append(convertData)
        reqBodyObj[getJSONRootKey()] = dataArray
        
        setUrlPath(urlPath : "/\(self.record.getModuleAPIName())/\( String( self.record.getId() ) )/actions/convert" )
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
                if ( respData.hasValue( forKey : ACCOUNTS ) )
                {
                    convertedDetails.updateValue( respData.optInt64(key: ACCOUNTS)! , forKey : ACCOUNTS )
                }
                if ( respData.hasValue( forKey : DEALS ) )
                {
                    convertedDetails.updateValue( respData.optInt64(key: DEALS)! , forKey : DEALS )
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
            setUrlPath(urlPath :"/\(self.record.getModuleAPIName())/\(String(self.record.getId()))/photo")
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
        setUrlPath(urlPath :"/\(self.record.getModuleAPIName())/\(String(self.record.getId()))/photo")
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
        setUrlPath(urlPath : "/\(self.record.getModuleAPIName())/\( String( self.record.getId() ) )/photo" )
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
        setUrlPath(urlPath : "/\( self.record.getModuleAPIName() )/\( String( self.record.getId() ) )/photo" )
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
        setUrlPath( urlPath : "/\(self.record.getModuleAPIName())/\(self.record.getId())/actions/follow" )
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
        setUrlPath( urlPath : "/\(self.record.getModuleAPIName())/\(self.record.getId())/actions/follow" )
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
        let recordIdString = String(record.getId())
        
        setUrlPath(urlPath: "/\(self.record.getModuleAPIName())/\(recordIdString)/actions/add_tags")
        setRequestMethod(requestMethod: .POST)
        var tagNamesString : String = String()
        for index in 0..<tags.count
        {
            if let name = tags[index].getName()
            {
                tagNamesString.append( name )
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
                let responseJSON = response.getResponseJSON()
                let respDataArray : [[String:Any]] = responseJSON.getArrayOfDictionaries(key: self.getJSONRootKey())
                let respData : [String:Any] = respDataArray[0]
                let tagDetails : [String] = respData.getDictionary(key: DETAILS).getArray(key: JSONRootKey.TAGS) as! [String]
                var tags : [ZCRMTag] = [ZCRMTag]()
                for tagDetail in tagDetails
                {
                    let singleTag : ZCRMTag = ZCRMTag( tagName: tagDetail )
                    tags.append(singleTag)
                }
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
        let recordIdString = String(record.getId())
        
        setUrlPath(urlPath: "/\(self.record.getModuleAPIName())/\(recordIdString)/actions/remove_tags")
        setRequestMethod(requestMethod: .POST)
        var tagNamesString : String = String()
        for index in 0..<tags.count
        {
            if let name = tags[index].getName()
            {
                tagNamesString.append( name )
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
        let priceDetail = ZCRMPriceBookPricing()
        priceDetail.setId(id : priceDetailDict.getInt64( key : ResponseJSONKeys.id ) )
        
        if let discount = priceDetailDict.optDouble(key : ResponseJSONKeys.discount){
            priceDetail.setDiscount(discount:discount)
        }
        
        if let fromRange = priceDetailDict.optDouble( key : ResponseJSONKeys.fromRange ),
           let toRange = priceDetailDict.optDouble(key : ResponseJSONKeys.toRange ){
            priceDetail.setRange(From: fromRange, To: toRange)
        }
        return priceDetail
    }
    
    
    internal func getZCRMRecordAsJSON() -> [String:Any?]
    {
        var recordJSON : [ String : Any? ] = [ String : Any? ]()
        let recordData : [ String : Any? ] = self.record.getData()
        if ( self.record.getOwner() != nil )
        {
            recordJSON[ ResponseJSONKeys.owner ] = self.record.getOwner()!.getId()
        }
        if ( self.record.getLayout() != nil )
        {
            recordJSON[ ResponseJSONKeys.layout ] = self.record.getLayout()?.getId()
        }
        for fieldApiName in recordData.keys
        {
            var value  = recordData[ fieldApiName ]
            if( recordData[ fieldApiName ] is ZCRMRecord )
            {
                value = ( value as? ZCRMRecord )?.getId()
            }
            if( recordData[ fieldApiName ] is ZCRMUser )
            {
                value = ( value as? ZCRMUser )?.getId()
            }
			if( recordData[ fieldApiName ] is [ZCRMSubformRecord]  && (recordData[fieldApiName] as! [ZCRMSubformRecord]).isEmpty == false)
			{
				var subformObj : [ [ String : Any? ] ] = [ [ String : Any? ] ]()
				for subform in recordData[ fieldApiName ] as! [ ZCRMSubformRecord ]
				{
					subformObj.append( subform.getAllValues() )
				}
			}
            recordJSON[ fieldApiName ] = value
        }
        if( self.record.getDataProcessingBasicDetails() != nil )
        {
            recordJSON[ ResponseJSONKeys.dataProcessingBasisDetails ] = self.getZCRMDataProcessingDetailsAsJSON(details: self.record.getDataProcessingBasicDetails()! )
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
        if let consnetThrough = details.getConsentThrough()
        {
            detailsJSON[ ResponseJSONKeys.consentThrough ] = consnetThrough
        }
        else
        {
            detailsJSON[ ResponseJSONKeys.consentThrough ] = nil
        }
        if let list = details.getConsentProcessThroughList()
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
        if let dataProcessing = details.getDataProcessingBasis()
        {
            detailsJSON[ ResponseJSONKeys.dataProcessingBasis ] = dataProcessing
        }
        else
        {
            detailsJSON[ ResponseJSONKeys.dataProcessingBasis ] = nil
        }
        if let date = details.getConsentDate()
        {
            detailsJSON[ ResponseJSONKeys.consentDate ] = date
        }
        else
        {
            detailsJSON[ ResponseJSONKeys.consentDate ] = nil
        }
        if let remarks = details.getConsentRemarks()
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
        if ( self.record.getTax().isEmpty )
        {
            return nil
        }
        var taxJSONArray : [ [ String : Any ] ] = [ [ String : Any ] ]()
        let allTax : [ ZCRMTax ] = self.record.getTax()
        for tax in allTax
        {
            taxJSONArray.append( self.getTaxAsJSON( tax : tax ) as Any as! [ String : Any ] )
        }
        return taxJSONArray
    }
    
    private func  getTaxAsJSON( tax : ZCRMTax ) -> [ String : Any? ]
    {
        var taxJSON : [ String : Any? ] = [ String : Any? ]()
        taxJSON[ ResponseJSONKeys.name ] = tax.getTaxName()
        if tax.getTaxPercentage() != nil {
            taxJSON[ ResponseJSONKeys.percentage ] = tax.getTaxPercentage()
        }
        if tax.getTaxValue() != nil  {
            taxJSON[ ResponseJSONKeys.value ] = tax.getTaxValue()
        }
        return taxJSON
    }
    
    private func getLineItemsAsJSONArray() -> [[String:Any]]?
    {
        if(self.record.getLineItems().isEmpty)
        {
            return nil
        }
        var allLineItems : [[String:Any]] = [[String:Any]]()
        let allLines : [ZCRMInventoryLineItem] = self.record.getLineItems()
        for lineItem in allLines
        {
            allLineItems.append(self.getZCRMInventoryLineItemAsJSON(invLineItem: lineItem) as Any as! [ String : Any ] )
        }
        return allLineItems
    }
    
    private func getPriceDetailsAsJSONArray() -> [ [ String : Any ] ]?
    {
        if( self.record.getPriceDetails().isEmpty )
        {
            return nil
        }
        var priceDetails : [ [ String : Any ] ] = [ [ String : Any ] ]()
        let allPriceDetails : [ ZCRMPriceBookPricing ] = self.record.getPriceDetails()
        for priceDetail in allPriceDetails
        {
            priceDetails.append( self.getZCRMPriceDetailAsJSON(priceDetail : priceDetail ) as Any as! [ String : Any ] )
        }
        return priceDetails
    }
    
    private func getParticipantsAsJSONArray() -> [ [ String : Any ] ]?
    {
        if( self.record.getParticipants().isEmpty)
        {
            return nil
        }
        var participantsDetails : [ [ String : Any ] ] = [ [ String : Any ] ]()
        let allParticipants : [ ZCRMEventParticipant ] = self.record.getParticipants()
        for participant in allParticipants
        {
            participantsDetails.append( self.getZCRMEventParticipantAsJSON( participant : participant ) as Any as! [ String : Any ] )
        }
        return participantsDetails
    }
    
    private func getZCRMEventParticipantAsJSON( participant : ZCRMEventParticipant ) -> [ String : Any? ]
    {
        var participantJSON : [ String : Any? ] = [ String : Any? ]()
        participantJSON[ ResponseJSONKeys.participant ] = participant.getId()
        participantJSON[ ResponseJSONKeys.type ] = participant.getType()
        participantJSON[ ResponseJSONKeys.name ] = participant.getName()
        participantJSON[ ConsentProcessThrough.EMAIL.rawValue ] = participant.getEmail()
        participantJSON[ ResponseJSONKeys.status ] = participant.getStatus()
        participantJSON[ ResponseJSONKeys.invited ] = participant.didInvite()
        return participantJSON
    }
    
    private func getZCRMPriceDetailAsJSON( priceDetail : ZCRMPriceBookPricing ) -> [ String : Any? ]
    {
        var priceDetailJSON : [ String : Any? ] = [ String : Any? ]()
        priceDetailJSON[ ResponseJSONKeys.id ] = priceDetail.getId()
        priceDetailJSON[ ResponseJSONKeys.discount ] = priceDetail.getDiscount()
        priceDetailJSON[ ResponseJSONKeys.toRange ] = priceDetail.getToRange()
        priceDetailJSON[ ResponseJSONKeys.fromRange ] = priceDetail.getFromRange()
        return priceDetailJSON
    }
    
    private func getZCRMInventoryLineItemAsJSON(invLineItem : ZCRMInventoryLineItem) -> [String:Any?]
    {
        var lineItem : [String:Any?] = [String:Any?]()
        if(invLineItem.getId() != nil)
        {
            lineItem[ResponseJSONKeys.id] = String(invLineItem.getId()!)
        }
        else
        {
            lineItem[ResponseJSONKeys.product] = String(invLineItem.getProduct().getId())
        }
        if(invLineItem.isDeleted())
        {
            lineItem[ResponseJSONKeys.delete] = true
        }
        else
        {
            lineItem[ResponseJSONKeys.productDescription] = invLineItem.getDescription()
            lineItem[ResponseJSONKeys.listPrice] = invLineItem.getListPrice()
            lineItem[ResponseJSONKeys.quantity] = invLineItem.getQuantity()
            if(invLineItem.getDiscountPercentage() == 0.0)
            {
                lineItem[ResponseJSONKeys.Discount] = invLineItem.getDiscount()
            }
            else
            {
                lineItem[ResponseJSONKeys.Discount] = String(invLineItem.getDiscountPercentage()) + "%"
            }
            var allTaxes : [[String:Any]] = [[String:Any]]()
            let lineTaxes : [ZCRMTax] = invLineItem.getLineTaxDetails()
            for lineTax in lineTaxes
            {
                var tax : [String:Any] = [String:Any]()
                tax[ResponseJSONKeys.name] = lineTax.getTaxName()
                tax[ResponseJSONKeys.percentage] = lineTax.getTaxPercentage()
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
                self.record.setId(recordId: Int64(value as! String)!)
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
                    let tax : ZCRMTax = ZCRMTax( taxName : taxJSON.getString( key : ResponseJSONKeys.name ) )
                    tax.setTaxValue( taxValue : taxJSON.optDouble( key : ResponseJSONKeys.value ) )
                    tax.setTaxPercentage( percentage : taxJSON.getDouble( key : ResponseJSONKeys.percentage ) )
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
                let createdByUser : ZCRMUser = ZCRMUser(userId: createdBy.getInt64(key: ResponseJSONKeys.id), userFullName: createdBy.getString(key: ResponseJSONKeys.name))
                self.record.setCreatedBy(createdBy: createdByUser)
            }
            else if(ResponseJSONKeys.modifiedBy == fieldAPIName)
            {
                let modifiedBy : [String:Any] = value as! [String : Any]
                let modifiedByUser : ZCRMUser = ZCRMUser(userId: modifiedBy.getInt64(key: ResponseJSONKeys.id), userFullName: modifiedBy.getString(key: ResponseJSONKeys.name))
                self.record.setModifiedBy(modifiedBy: modifiedByUser)
            }
            else if(ResponseJSONKeys.createdTime == fieldAPIName)
            {
                self.record.setCreatedTime(createdTime: value as! String)
            }
            else if(ResponseJSONKeys.modifiedTime == fieldAPIName)
            {
                self.record.setModifiedTime(modifiedTime: value as! String)
            }
            else if(ResponseJSONKeys.owner == fieldAPIName)
            {
                let ownerObj : [String:Any] = value as! [String : Any]
                let owner : ZCRMUser = ZCRMUser(userId: ownerObj.getInt64(key: ResponseJSONKeys.id), userFullName: ownerObj.getString(key: ResponseJSONKeys.name))
                self.record.setOwner(owner: owner)
            }
            else if(ResponseJSONKeys.layout == fieldAPIName)
            {
                if(recordDetails.hasValue(forKey: fieldAPIName))
                {
                    let layoutObj : [String:Any] = value  as! [String : Any]
                    let layout : ZCRMLayout = ZCRMLayout(layoutId: layoutObj.getInt64(key: ResponseJSONKeys.id))
                    layout.setName(name: layoutObj.getString(key: ResponseJSONKeys.name))
                    self.record.setLayout(layout: layout)
                }
                else
                {
                    self.record.setLayout(layout: nil)
                }
            }
            else if(ResponseJSONKeys.handler == fieldAPIName && recordDetails.hasValue(forKey: fieldAPIName))
            {
                let handlerObj : [String: Any] = value as! [String : Any]
                let handler : ZCRMUser = ZCRMUser(userId: handlerObj.getInt64(key: ResponseJSONKeys.id), userFullName: handlerObj.getString(key: ResponseJSONKeys.name))
                self.record.setValue(forField: fieldAPIName, value: handler)
            }
            else if(fieldAPIName.hasPrefix("$"))
            {
                var propertyName : String = fieldAPIName
                propertyName.remove(at: propertyName.startIndex)
    
                if propertyName.contains(ResponseJSONKeys.followers) , recordDetails.hasValue(forKey: ResponseJSONKeys.followers)
                {
                    var users : [ ZCRMUser ] = [ ZCRMUser ]()
                    let userDetails : [ [ String : Any ] ] = value as! [ [ String : Any ] ]
                    for userDetail in userDetails
                    {
                        let user : ZCRMUser = ZCRMUser( userId : userDetail.getInt64( key : ResponseJSONKeys.id ), userFullName : userDetail.getString( key : ResponseJSONKeys.name) )
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
                let lookupRecord : ZCRMRecord = ZCRMRecord( moduleAPIName : fieldAPIName, recordId : lookupDetails.getInt64( key : ResponseJSONKeys.id ) )
                lookupRecord.setLookupLabel( label : lookupDetails.optString( key : ResponseJSONKeys.name ) )
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
            zcrmSubform.setModifiedTime(modifiedTime: modifiedTime)
        }
        
        if subformDetails.hasValue(forKey: ResponseJSONKeys.createdTime){
            let createdTime = subformDetails.optString(key: ResponseJSONKeys.createdTime)!
            zcrmSubform.setCreatedTime(createdTime: createdTime)
        }
        
        if subformDetails.hasValue( forKey : ResponseJSONKeys.owner )
        {
            let ownerDict = subformDetails.getDictionary( key : ResponseJSONKeys.owner )
            let owner : ZCRMUser = ZCRMUser(userId: ownerDict.getInt64(key: ResponseJSONKeys.id),
                                            userFullName: ownerDict.getString(key: ResponseJSONKeys.name))
            zcrmSubform.setOwner(owner: owner)
        }
        
        return zcrmSubform
    }
    
    private func getZCRMDataProcessingBasicDetails( details : [ String : Any ] ) -> ZCRMDataProcessBasicDetails
    {
        let dataProcessingDetails : ZCRMDataProcessBasicDetails = ZCRMDataProcessBasicDetails()
        
        if( details.hasValue( forKey : ResponseJSONKeys.contactThroughEmail ) && details.getBoolean( key : ResponseJSONKeys.contactThroughEmail ) == true )
        {
            dataProcessingDetails.addConsentProcessThrough(consentProcessThrough: ConsentProcessThrough.EMAIL )
        }
        if( details.hasValue( forKey : ResponseJSONKeys.contactThroughSocial ) && details.getBoolean( key : ResponseJSONKeys.contactThroughSocial ) == true )
        {
            dataProcessingDetails.addConsentProcessThrough(consentProcessThrough: ConsentProcessThrough.SOCIAL )
        }
        if( details.hasValue( forKey : ResponseJSONKeys.contactThroughSurvey ) && details.getBoolean( key : ResponseJSONKeys.contactThroughSurvey ) == true )
        {
            dataProcessingDetails.addConsentProcessThrough(consentProcessThrough: ConsentProcessThrough.SURVEY )
        }
        if( details.hasValue( forKey : ResponseJSONKeys.contactThroughPhone ) && details.getBoolean( key : ResponseJSONKeys.contactThroughPhone ) == true )
        {
            dataProcessingDetails.addConsentProcessThrough(consentProcessThrough: ConsentProcessThrough.PHONE )
        }
        dataProcessingDetails.setModifiedTime( modifiedTime : details.getString(key: ResponseJSONKeys.modifiedTime ) )
        dataProcessingDetails.setCreatedTime( createdTime : details.getString( key : ResponseJSONKeys.createdTime ) )
        dataProcessingDetails.setConsentThrough( consentThrough : details.optString( key : ResponseJSONKeys.consentThrough ) )
        dataProcessingDetails.setDataProcessingBasis( dataProcessingBasis : ResponseJSONKeys.dataProcessingBasis )
        dataProcessingDetails.setLawfulReason( lawfulReason : details.optString( key : ResponseJSONKeys.lawfulReason ) )
        dataProcessingDetails.setMailSentTime( mailSentTime : details.optString( key : ResponseJSONKeys.mailSentTime ) )
        dataProcessingDetails.setConsentDate( date : details.optString( key : ResponseJSONKeys.consentDate ) )
        dataProcessingDetails.setId( id : details.getInt64( key : ResponseJSONKeys.id ) )
        dataProcessingDetails.setConsentRemarks( remarks : details.optString( key : ResponseJSONKeys.consentRemarks ) )
        dataProcessingDetails.setConsentEndsOn( endsOn : details.optString( key : ResponseJSONKeys.consentEndsOn ) )
        let ownerDetails : [ String : Any ] = details.getDictionary( key : ResponseJSONKeys.owner )
        let owner : ZCRMUser = ZCRMUser( userId : ownerDetails.getInt64( key : ResponseJSONKeys.id ), userFullName : ownerDetails.getString( key : ResponseJSONKeys.name ) )
        dataProcessingDetails.setOwner( owner : owner )
        let createdByDetails : [ String : Any ] = details.getDictionary( key : ResponseJSONKeys.createdBy )
        let createdBy : ZCRMUser = ZCRMUser( userId : createdByDetails.getInt64( key : ResponseJSONKeys.id ), userFullName : createdByDetails.getString( key : ResponseJSONKeys.name ) )
        dataProcessingDetails.setCreatedBy( createdBy : createdBy )
        let modifiedByDetails : [ String : Any ] = details.getDictionary( key : ResponseJSONKeys.modifiedBy )
        let modifiedBy : ZCRMUser = ZCRMUser( userId : modifiedByDetails.getInt64( key : ResponseJSONKeys.id ), userFullName : modifiedByDetails.getString( key : ResponseJSONKeys.name ) )
        dataProcessingDetails.setModifiedBy( modifiedBy : modifiedBy )
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
        let product : ZCRMRecord = ZCRMRecord(moduleAPIName: ResponseJSONKeys.products, recordId: productDetails.getInt64(key: ResponseJSONKeys.id))
        product.setLookupLabel(label: productDetails.getString(key: ResponseJSONKeys.name))
        let lineItem : ZCRMInventoryLineItem = ZCRMInventoryLineItem(lineItemId: lineItemDetails.getInt64(key: ResponseJSONKeys.id), product: product)
        lineItem.setDescription(description: lineItemDetails.optString(key: ResponseJSONKeys.productDescription))
        lineItem.setQuantity(quantity: lineItemDetails.optDouble(key: ResponseJSONKeys.quantity)!)
        lineItem.setListPrice(listPrice: lineItemDetails.optDouble(key: ResponseJSONKeys.listPrice)!)
        lineItem.setTotal(total: lineItemDetails.optDouble(key: ResponseJSONKeys.total)!)
        lineItem.setDiscount(discount: lineItemDetails.optDouble(key: ResponseJSONKeys.Discount)!)
        lineItem.setTotalAfterDiscount(totAftDisc: lineItemDetails.optDouble(key: ResponseJSONKeys.totalAfterDiscount)!)
        lineItem.setTaxValue(tax: lineItemDetails.optDouble(key: ResponseJSONKeys.tax)!)
        let allLineTaxes : [[String:Any]] = lineItemDetails.optArrayOfDictionaries(key: ResponseJSONKeys.lineTax)!
        for lineTaxDetails in allLineTaxes
        {
            lineItem.addLineTax(tax: self.getZCRMTax(taxDetails: lineTaxDetails))
        }
        lineItem.setNetTotal(netTotal: lineItemDetails.optDouble(key: ResponseJSONKeys.netTotal)!)
        return lineItem
    }
    
    private func getZCRMTax( taxDetails : [ String : Any ] ) -> ZCRMTax
    {
        let lineTax : ZCRMTax = ZCRMTax( taxName : taxDetails.getString( key: ResponseJSONKeys.name ) )
        lineTax.setTaxPercentage( percentage : taxDetails.getDouble( key : ResponseJSONKeys.percentage ) )
        lineTax.setTaxValue( taxValue : taxDetails.optDouble( key : ResponseJSONKeys.value )! )
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
        participant.setName( name : participantDetails.getString( key : ResponseJSONKeys.name ) )
        participant.setEmail( email : participantDetails.getString( key : ConsentProcessThrough.EMAIL.rawValue ) )
        participant.setStatus(status : participantDetails.getString( key : ResponseJSONKeys.status ) )
        participant.setInvited( invited : participantDetails.getBoolean( key : ResponseJSONKeys.invited ) )
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

