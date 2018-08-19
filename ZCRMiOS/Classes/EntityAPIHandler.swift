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
	
    internal func getRecord( withPrivateFields : Bool, completion : @escaping( ZCRMRecord?, APIResponse?, Error? ) -> () )
    {
        setJSONRootKey( key : DATA )
        let urlPath = "/\(self.record.getModuleAPIName())/\(self.record.getId())"
		setUrlPath(urlPath : urlPath )
        if( withPrivateFields == true )
        {
            addRequestParam( param : "include", value : PRIVATE_FIELDS )
        }
		setRequestMethod(requestMethod : .GET)
		let request : APIRequest = APIRequest(handler: self)
		
        print( "Request : \( request.toString() )" )
        request.getAPIResponse { ( resp, err ) in
            if let error = err
            {
                completion( nil, nil, error )
            }
            if let response = resp
            {
                let responseJSON : [String:Any] = response.getResponseJSON()
                let responseDataArray : [[String:Any]] = responseJSON.getArrayOfDictionaries(key: self.getJSONRootKey())
                self.setRecordProperties(recordDetails: responseDataArray[0])
                response.setData(data: self.record)
                completion( self.record, response, nil )
            }
        }
    }
    
    internal func createRecord( completion : @escaping( ZCRMRecord?, APIResponse?, Error? ) -> () )
    {
        setJSONRootKey( key : DATA )
        var reqBodyObj : [String:[[String:Any]]] = [String:[[String:Any]]]()
        var dataArray : [[String:Any]] = [[String:Any]]()
        dataArray.append(self.getZCRMRecordAsJSON() as Any as! [ String : Any ] )
        reqBodyObj[ getJSONRootKey() ] = dataArray
		
		setUrlPath(urlPath : "/\(self.record.getModuleAPIName())")
		setRequestMethod(requestMethod : .POST)
		setRequestBody(requestBody : reqBodyObj)
		let request : APIRequest = APIRequest(handler : self)
        print( "Request : \( request.toString() )" )
		
        request.getAPIResponse { ( resp, err ) in
            if let error = err
            {
                completion( nil, nil, error )
            }
            if let response = resp
            {
                let responseJSON : [String:Any] = response.getResponseJSON()
                let respDataArr : [[String:Any?]] = responseJSON.getArrayOfDictionaries(key: self.getJSONRootKey())
                let respData : [String:Any?] = respDataArr[0]
                let recordDetails : [String:Any] = respData.getDictionary(key: "details")
                self.setRecordProperties(recordDetails: recordDetails)
                response.setData(data: self.record)
                completion( self.record, response, nil )
            }
        }
    }
    
    internal func updateRecord( completion : @escaping( ZCRMRecord?, APIResponse?, Error? ) -> () )
    {
        setJSONRootKey( key : DATA )
        var reqBodyObj : [String:[[String:Any]]] = [String:[[String:Any]]]()
        var dataArray : [[String:Any]] = [[String:Any]]()
        dataArray.append(self.getZCRMRecordAsJSON() as Any as! [ String : Any ])
        reqBodyObj[ getJSONRootKey() ] = dataArray
		
		setUrlPath(urlPath : "/\(self.record.getModuleAPIName())/\( String( self.record.getId() ) )" )
		setRequestMethod( requestMethod : .PUT )
		setRequestBody( requestBody : reqBodyObj )
		let request : APIRequest = APIRequest( handler : self)
        print( "Request : \( request.toString() )" )

        request.getAPIResponse { ( resp, err ) in
            if let error = err
            {
                completion( nil, nil, error )
            }
            if let response = resp
            {
                let responseJSON : [String:Any] = response.getResponseJSON()
                let respDataArr : [[String:Any?]] = responseJSON.getArrayOfDictionaries(key: self.getJSONRootKey())
                let respData : [String:Any?] = respDataArr[0]
                let recordDetails : [String:Any] = respData.getDictionary(key: "details")
                self.setRecordProperties(recordDetails: recordDetails)
                response.setData(data: self.record)
                completion( self.record, response, nil )
            }
        }
    }
    
    internal func deleteRecord( completion : @escaping( APIResponse?, Error? ) -> () )
    {
		
		setUrlPath(urlPath : "/\(self.record.getModuleAPIName())/\(self.record.getId())")
		setRequestMethod(requestMethod : .DELETE )
		
		let request : APIRequest = APIRequest(handler : self )
        print( "Request : \( request.toString() )" )
		
        request.getAPIResponse { ( response, error ) in
            completion( response, error )
        }
    }
    
    internal func convertRecord( newPotential : ZCRMRecord?, assignTo : ZCRMUser?, completion : @escaping( [ String : Int64 ]?, Error? ) -> () )
    {

        var reqBodyObj : [String:[[String:Any]]] = [String:[[String:Any]]]()
        var dataArray : [[String:Any]] = [[String:Any]]()
        var convertData : [String:Any] = [String:Any]()
        if let assignToUser = assignTo
        {
            convertData["assign_to"] = String(assignToUser.getId()!)
        }
        if let potential = newPotential
        {
            convertData["Deals"] = EntityAPIHandler(record: potential).getZCRMRecordAsJSON()
        }
        dataArray.append(convertData)
        reqBodyObj[getJSONRootKey()] = dataArray
		
		setUrlPath(urlPath : "/\(self.record.getModuleAPIName())/\( String( self.record.getId() ) )/actions/convert" )
		setRequestMethod(requestMethod : .POST )
		setRequestBody(requestBody : reqBodyObj )
		let request : APIRequest = APIRequest(handler : self)
        print( "Request : \( request.toString() )" )
        
        request.getAPIResponse { ( resp, err ) in
            if let error = err
            {
                completion( nil, error )
            }
            if let response = resp
            {
                let responseJSON : [String:Any] = response.getResponseJSON()
                let respDataArr : [[String:Any]] = responseJSON.getArrayOfDictionaries(key: self.getJSONRootKey())
                let respData : [String:Any] = respDataArr[0]
                var convertedDetails : [String:Int64] = [String:Int64]()
                if ( respData.hasValue( forKey : "Accounts" ) )
                {
                    convertedDetails.updateValue( respData.optInt64(key: "Accounts")! , forKey : "Accounts" )
                }
                if ( respData.hasValue( forKey : "Deals" ) )
                {
                    convertedDetails.updateValue( respData.optInt64(key: "Deals")! , forKey : "Deals" )
                }
                convertedDetails.updateValue( respData.optInt64(key: "Contacts")! , forKey : "Contacts" )
                completion( convertedDetails, nil )
            }
        }
    }
    
    internal func uploadPhoto( filePath : String, completion : @escaping( APIResponse?, Error? ) -> () )
    {
        do
        {
            try fileDetailCheck( filePath : filePath )
            
            setUrlPath(urlPath :  "/\( self.record.getModuleAPIName() )/\( String( self.record.getId() ) )/photo" )
            setRequestMethod(requestMethod : .POST )
            let request : APIRequest = APIRequest(handler : self )
            print( "Request : \( request.toString() )" )
            
            request.uploadFile( filePath : filePath) { ( response, error ) in
                completion( response, error )
            }
        }
        catch
        {
            completion( nil, ZCRMError.ProcessingError( error.localizedDescription ) )
        }
    }
    
    internal func downloadPhoto( completion : @escaping( FileAPIResponse?, Error? ) -> () )
    {
        setUrlPath(urlPath : "/\(self.record.getModuleAPIName())/\( String( self.record.getId() ) )/photo" )
        setRequestMethod(requestMethod : .GET )
        let request : APIRequest = APIRequest(handler : self )
        print( "Request : \( request.toString() )" )
        
        request.downloadFile { ( response, error ) in
            completion( response, error )
        }
    }
    
    internal func deletePhoto( completion : @escaping( APIResponse?, Error? ) -> () )
    {
        setUrlPath(urlPath : "/\( self.record.getModuleAPIName() )/\( String( self.record.getId() ) )/photo" )
        setRequestMethod(requestMethod : .DELETE )
        let request : APIRequest = APIRequest(handler : self )
        print( "Request : \( request.toString() )" )
        
        request.getAPIResponse { ( response, error ) in
            completion( response, error )
        }
    }
	
	// MARK: - Utility Functions
	
    private func setPriceDetails( priceDetails : [ [ String : Any ] ] )
    {
        for index in ( 0..<priceDetails.count )
        {
            let priceDetailDict : Dictionary< String, Any > = priceDetails[ index ]
            try! self.record.addPriceDetail( priceDetail : self.getZCRMPriceDetail( priceDetailDict : priceDetailDict ) )
        }
    }
    
    internal func getZCRMPriceDetail( priceDetailDict : [ String : Any ] ) throws -> ZCRMPriceBookPricing
    {
        let priceDetail = ZCRMPriceBookPricing()
        priceDetail.setId(id : priceDetailDict.getInt64( key : "id" ) )
        priceDetail.setDiscount( discount : priceDetailDict.optDouble( key : "discount" ) )
        priceDetail.setToRange( toRange : priceDetailDict.optDouble( key : "to_range" ) )
        priceDetail.setFromRange( fromRange : priceDetailDict.optDouble(key : "from_range" ) )
        return priceDetail
    }
    
    internal func getZCRMRecordAsJSON() -> [String:Any?]
    {
        var recordJSON : [ String : Any? ] = [ String : Any? ]()
        let recordData : [ String : Any? ] = self.record.getData()
        if ( self.record.getOwner() != nil )
        {
            recordJSON[ "Owner" ] = self.record.getOwner()!.getId()
        }
        if ( self.record.getLayout() != nil )
        {
            recordJSON[ "Layout" ] = self.record.getLayout()?.getId()
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
            recordJSON[ "Data_Processing_Basis_Details" ] = self.getZCRMDataProcessingDetailsAsJSON(details: self.record.getDataProcessingBasicDetails()! )
        }
        recordJSON[ "Product_Details" ] = self.getLineItemsAsJSONArray()
        recordJSON[ "Tax" ] = self.getTaxAsJSONArray()
        recordJSON[ "Participants" ] = self.getParticipantsAsJSONArray()
        recordJSON[ "Pricing_Details" ] = self.getPriceDetailsAsJSONArray()
        return recordJSON
    }
    
    internal func getZCRMDataProcessingDetailsAsJSON( details : ZCRMDataProcessBasicDetails ) -> [ String : Any? ]
    {
        var detailsJSON : [ String : Any? ] = [ String : Any? ]()
        if let consnetThrough = details.getConsentThrough()
        {
            detailsJSON[ "Consent_Through" ] = consnetThrough
        }
        else
        {
            detailsJSON[ "Consent_Through" ] = nil
        }
        if let list = details.getConsentProcessThroughList()
        {
            if( list.contains( "Email" ) )
            {
                detailsJSON[ "Contact_Through_Email" ] = true
            }
            if( list.contains( "Social" ) )
            {
                detailsJSON[ "Contact_Through_Social" ] = true
            }
            if( list.contains( "Survey" ) )
            {
                detailsJSON[ "Contact_Through_Survey" ] = true
            }
            if( list.contains( "Phone" ) )
            {
                detailsJSON[ "Contact_Through_Phone" ] = true
            }
        }
        if let dataProcessing = details.getDataProcessingBasis()
        {
            detailsJSON[ "Data_Processing_Basis" ] = dataProcessing
        }
        else
        {
            detailsJSON[ "Data_Processing_Basis" ] = nil
        }
        if let date = details.getConsentDate()
        {
            detailsJSON[ "Consent_Date" ] = date
        }
        else
        {
            detailsJSON[ "Consent_Date" ] = nil
        }
        if let remarks = details.getConsentRemarks()
        {
            detailsJSON[ "Consent_Remarks" ] = remarks
        }
        else
        {
            detailsJSON[ "Consent_Remarks" ] = nil
        }
        return detailsJSON
    }
    
    internal func getTaxAsJSONArray() -> [ [ String : Any ] ]?
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
    
    internal func  getTaxAsJSON( tax : ZCRMTax ) -> [ String : Any? ]
    {
        var taxJSON : [ String : Any? ] = [ String : Any? ]()
        taxJSON[ "name" ] = tax.getTaxName()
        if tax.getTaxPercentage() != nil {
            taxJSON[ "percentage" ] = tax.getTaxPercentage()
        }
        if tax.getTaxValue() != nil  {
            taxJSON[ "value" ] = tax.getTaxValue()
        }
        return taxJSON
    }
    
    internal func getLineItemsAsJSONArray() -> [[String:Any]]?
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
    
    internal func getPriceDetailsAsJSONArray() -> [ [ String : Any ] ]?
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
    
    internal func getParticipantsAsJSONArray() -> [ [ String : Any ] ]?
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
    
    internal func getZCRMEventParticipantAsJSON( participant : ZCRMEventParticipant ) -> [ String : Any? ]
    {
        var participantJSON : [ String : Any? ] = [ String : Any? ]()
        participantJSON[ "participant" ] = participant.getId()
        participantJSON[ "type" ] = participant.getType()
        participantJSON[ "name" ] = participant.getName()
        participantJSON[ "Email" ] = participant.getEmail()
        participantJSON[ "status" ] = participant.getStatus()
        participantJSON[ "invited" ] = participant.didInvite()
        return participantJSON
    }
    
    internal func getZCRMPriceDetailAsJSON( priceDetail : ZCRMPriceBookPricing ) -> [ String : Any? ]
    {
        var priceDetailJSON : [ String : Any? ] = [ String : Any? ]()
        priceDetailJSON[ "id" ] = priceDetail.getId()
        priceDetailJSON[ "discount" ] = priceDetail.getDiscount()
        priceDetailJSON[ "to_range" ] = priceDetail.getToRange()
        priceDetailJSON[ "from_range" ] = priceDetail.getFromRange()
        return priceDetailJSON
    }
    
    internal func getZCRMInventoryLineItemAsJSON(invLineItem : ZCRMInventoryLineItem) -> [String:Any?]
    {
        var lineItem : [String:Any?] = [String:Any?]()
        if(invLineItem.getId() != nil)
        {
            lineItem["id"] = String(invLineItem.getId()!)
        }
        else
        {
            lineItem["product"] = String(invLineItem.getProduct().getId())
        }
        if(invLineItem.isDeleted())
        {
            lineItem["delete"] = true
        }
        else
        {
            lineItem["product_description"] = invLineItem.getDescription()
            lineItem["list_price"] = invLineItem.getListPrice()
            lineItem["quantity"] = invLineItem.getQuantity()
            if(invLineItem.getDiscountPercentage() == 0.0)
            {
                lineItem["Discount"] = invLineItem.getDiscount()
            }
            else
            {
                lineItem["Discount"] = String(invLineItem.getDiscountPercentage()) + "%"
            }
            var allTaxes : [[String:Any]] = [[String:Any]]()
            let lineTaxes : [ZCRMTax] = invLineItem.getLineTaxDetails()
            for lineTax in lineTaxes
            {
                var tax : [String:Any] = [String:Any]()
                tax["name"] = lineTax.getTaxName()
                tax["percentage"] = lineTax.getTaxPercentage()
                allTaxes.append(tax)
            }
            if(!allTaxes.isEmpty)
            {
                lineItem["line_tax"] = allTaxes
            }
        }
        return lineItem
    }
    
    internal func setRecordProperties(recordDetails : [String:Any])
    {
        for (fieldAPIName, value) in recordDetails
        {
            if("id" == fieldAPIName)
            {
                self.record.setId(recordId: Int64(value as! String)!)
            }
            else if("Product_Details" == fieldAPIName)
            {
                self.setInventoryLineItems(lineItems: value as! [[String:Any]])
            }
            else if( "Pricing_Details" == fieldAPIName )
            {
                self.setPriceDetails( priceDetails : value as! [ [ String : Any ] ] )
            }
            else if( "Participants" == fieldAPIName )
            {
                self.setParticipants( participantsArray : value as! [ [ String : Any ] ] )
            }
            else if( "$line_tax" == fieldAPIName )
            {
                let taxesDetails : [ [ String : Any ] ] = value as! [ [ String : Any ] ]
                for taxJSON in taxesDetails
                {
                    let tax : ZCRMTax = ZCRMTax( taxName : taxJSON.getString( key : "name" ) )
                    tax.setTaxValue( taxValue : taxJSON.optDouble( key : "value" ) )
                    tax.setTaxPercentage( percentage : taxJSON.getDouble( key : "percentage" ) )
                    self.record.addTax( tax : tax )
                }
            }
            else if( "Tax" == fieldAPIName && value is [ String ] )
            {
                let taxNames : [ String ] = value as! [ String ]
                for taxName in taxNames
                {
                    self.record.addTax( tax : ZCRMTax( taxName : taxName ) )
                }
            }
            else if("Created_By" == fieldAPIName)
            {
                let createdBy : [String:Any] = value as! [String : Any]
                let createdByUser : ZCRMUser = ZCRMUser(userId: createdBy.getInt64(key: "id"), userFullName: createdBy.getString(key: "name"))
                self.record.setCreatedBy(createdBy: createdByUser)
            }
            else if("Modified_By" == fieldAPIName)
            {
                let modifiedBy : [String:Any] = value as! [String : Any]
                let modifiedByUser : ZCRMUser = ZCRMUser(userId: modifiedBy.getInt64(key: "id"), userFullName: modifiedBy.getString(key: "name"))
                self.record.setModifiedBy(modifiedBy: modifiedByUser)
            }
            else if("Created_Time" == fieldAPIName)
            {
                self.record.setCreatedTime(createdTime: value as! String)
            }
            else if("Modified_Time" == fieldAPIName)
            {
                self.record.setModifiedTime(modifiedTime: value as! String)
            }
            else if("Owner" == fieldAPIName)
            {
                let ownerObj : [String:Any] = value as! [String : Any]
                let owner : ZCRMUser = ZCRMUser(userId: ownerObj.getInt64(key: "id"), userFullName: ownerObj.getString(key: "name"))
                self.record.setOwner(owner: owner)
            }
            else if("Layout" == fieldAPIName)
            {
                if(recordDetails.hasValue(forKey: fieldAPIName))
                {
                    let layoutObj : [String:Any] = value  as! [String : Any]
                    let layout : ZCRMLayout = ZCRMLayout(layoutId: layoutObj.getInt64(key: "id"))
                    layout.setName(name: layoutObj.getString(key: "name"))
                    self.record.setLayout(layout: layout)
                }
                else
                {
                    self.record.setLayout(layout: nil)
                }
            }
            else if("Handler" == fieldAPIName && recordDetails.hasValue(forKey: fieldAPIName))
            {
                let handlerObj : [String: Any] = value as! [String : Any]
                let handler : ZCRMUser = ZCRMUser(userId: handlerObj.getInt64(key: "id"), userFullName: handlerObj.getString(key: "name"))
                self.record.setValue(forField: fieldAPIName, value: handler)
            }
            else if(fieldAPIName.hasPrefix("$"))
            {
                var propertyName : String = fieldAPIName
                propertyName.remove(at: propertyName.startIndex)
                self.record.setValue(ofProperty: propertyName, value: value)
            }
            else if( "Remind_At" == fieldAPIName && recordDetails.hasValue( forKey : fieldAPIName ) )
            {
                let alarmDetails = recordDetails.getDictionary( key : fieldAPIName )
                self.record.setValue( forField : "ALARM", value : alarmDetails.getString( key : "ALARM" ) )
            }
            else if( "Recurring_Activity" == fieldAPIName && recordDetails.hasValue( forKey : fieldAPIName ) )
            {
                let recurringActivity = recordDetails.getDictionary( key : fieldAPIName )
                self.record.setValue( forField : "RRULE", value : recurringActivity.getString( key : "RRULE" ) )
            }
            else if( value is [ String : Any ] )
            {
                let lookupDetails : [ String : Any ] = value as! [ String : Any ]
                let lookupRecord : ZCRMRecord = ZCRMRecord( moduleAPIName : fieldAPIName, recordId : lookupDetails.getInt64( key : "id" ) )
                lookupRecord.setLookupLabel( label : lookupDetails.optString( key : "name" ) )
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
	
	internal func getAllZCRMSubformRecords( apiName : String , subforms : [[ String : Any]] ) -> [ZCRMSubformRecord]
	{
		var zcrmSubformRecords : [ZCRMSubformRecord] = [ZCRMSubformRecord]()
		for subform in subforms
		{
			zcrmSubformRecords.append( self.getZCRMSubformRecord(apiName: apiName , subformDetails: subform ))
		}
		return zcrmSubformRecords
	}
	
	internal func getZCRMSubformRecord( apiName : String , subformDetails : [ String : Any ] ) -> ZCRMSubformRecord
	{
		let zcrmSubform : ZCRMSubformRecord = ZCRMSubformRecord(apiName : apiName, id: subformDetails.getInt64(key: "id" ))
		zcrmSubform.setModifiedTime(modifiedTime: subformDetails.getString(key: "Modified_Time" ) )
		zcrmSubform.setCreatedTime(createdTime: subformDetails.getString(key: "Created_Time" ) )
		let ownerDetails : [ String : Any ] = subformDetails.getDictionary(key: "Owner")
		let owner : ZCRMUser = ZCRMUser(userId: ownerDetails.getInt64(key: "id"), userFullName: ownerDetails.getString(key: "name"))
		zcrmSubform.setOwner(owner: owner)
		return zcrmSubform
	}
    
    internal func getZCRMDataProcessingBasicDetails( details : [ String : Any ] ) -> ZCRMDataProcessBasicDetails
    {
        let dataProcessingDetails : ZCRMDataProcessBasicDetails = ZCRMDataProcessBasicDetails()
        
        if( details.hasValue( forKey : "Contact_Through_Email" ) && details.getBoolean( key : "Contact_Through_Email" ) == true )
        {
            dataProcessingDetails.addConsentProcessThrough(consentProcessThrough: ConsentProcessThrough.EMAIL )
        }
        if( details.hasValue( forKey : "Contact_Through_Social" ) && details.getBoolean( key : "Contact_Through_Social" ) == true )
        {
            dataProcessingDetails.addConsentProcessThrough(consentProcessThrough: ConsentProcessThrough.SOCIAL )
        }
        if( details.hasValue( forKey : "Contact_Through_Survey" ) && details.getBoolean( key : "Contact_Through_Survey" ) == true )
        {
            dataProcessingDetails.addConsentProcessThrough(consentProcessThrough: ConsentProcessThrough.SURVEY )
        }
        if( details.hasValue( forKey : "Contact_Through_Phone" ) && details.getBoolean( key : "Contact_Through_Phone" ) == true )
        {
            dataProcessingDetails.addConsentProcessThrough(consentProcessThrough: ConsentProcessThrough.PHONE )
        }
        dataProcessingDetails.setModifiedTime( modifiedTime : details.getString(key: "Modified_Time" ) )
        dataProcessingDetails.setCreatedTime( createdTime : details.getString( key : "Created_Time" ) )
        dataProcessingDetails.setConsentThrough( consentThrough : details.optString( key : "Consent_Through" ) )
        dataProcessingDetails.setDataProcessingBasis( dataProcessingBasis : "Data_Processing_Basis" )
        dataProcessingDetails.setLawfulReason( lawfulReason : details.optString( key : "Lawful_Reason" ) )
        dataProcessingDetails.setMailSentTime( mailSentTime : details.optString( key : "Mail_Sent_Time" ) )
        dataProcessingDetails.setConsentDate( date : details.optString( key : "Consent_Date" ) )
        dataProcessingDetails.setId( id : details.getInt64( key : "id" ) )
        dataProcessingDetails.setConsentRemarks( remarks : details.optString( key : "Consent_Remarks" ) )
        dataProcessingDetails.setConsentEndsOn( endsOn : details.optString( key : "Consent_EndsOn" ) )
        let ownerDetails : [ String : Any ] = details.getDictionary( key : "Owner" )
        let owner : ZCRMUser = ZCRMUser( userId : ownerDetails.getInt64( key : "id" ), userFullName : ownerDetails.getString( key : "name" ) )
        dataProcessingDetails.setOwner( owner : owner )
        let createdByDetails : [ String : Any ] = details.getDictionary( key : "Created_By" )
        let createdBy : ZCRMUser = ZCRMUser( userId : createdByDetails.getInt64( key : "id" ), userFullName : createdByDetails.getString( key : "name" ) )
        dataProcessingDetails.setCreatedBy( createdBy : createdBy )
        let modifiedByDetails : [ String : Any ] = details.getDictionary( key : "Modified_By" )
        let modifiedBy : ZCRMUser = ZCRMUser( userId : modifiedByDetails.getInt64( key : "id" ), userFullName : modifiedByDetails.getString( key : "name" ) )
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
        let productDetails : [String:Any] = lineItemDetails.getDictionary(key: "product")
        let product : ZCRMRecord = ZCRMRecord(moduleAPIName: "Products", recordId: productDetails.getInt64(key: "id"))
        product.setLookupLabel(label: productDetails.getString(key: "name"))
        let lineItem : ZCRMInventoryLineItem = ZCRMInventoryLineItem(lineItemId: lineItemDetails.getInt64(key: "id"), product: product)
        lineItem.setDescription(description: lineItemDetails.optString(key: "product_description"))
        lineItem.setQuantity(quantity: lineItemDetails.optDouble(key: "quantity")!)
        lineItem.setListPrice(listPrice: lineItemDetails.optDouble(key: "list_price")!)
        lineItem.setTotal(total: lineItemDetails.optDouble(key: "total")!)
        lineItem.setDiscount(discount: lineItemDetails.optDouble(key: "Discount")!)
        lineItem.setTotalAfterDiscount(totAftDisc: lineItemDetails.optDouble(key: "total_after_discount")!)
        lineItem.setTaxValue(tax: lineItemDetails.optDouble(key: "Tax")!)
        let allLineTaxes : [[String:Any]] = lineItemDetails.optArrayOfDictionaries(key: "line_tax")!
        for lineTaxDetails in allLineTaxes
        {
            lineItem.addLineTax(tax: self.getZCRMTax(taxDetails: lineTaxDetails))
        }
        lineItem.setNetTotal(netTotal: lineItemDetails.optDouble(key: "net_total")!)
        return lineItem
    }
    
    private func getZCRMTax( taxDetails : [ String : Any ] ) -> ZCRMTax
    {
        let lineTax : ZCRMTax = ZCRMTax( taxName : taxDetails.getString( key: "name" ) )
        lineTax.setTaxPercentage( percentage : taxDetails.getDouble( key : "percentage" ) )
        lineTax.setTaxValue( taxValue : taxDetails.optDouble( key : "value" )! )
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
    
    internal func getZCRMParticipant( participantDetails : [ String : Any ] ) -> ZCRMEventParticipant
    {
        let id : Int64 = participantDetails.getInt64( key : "participant" )
        let type : String = participantDetails.getString( key : "type" )
        let participant : ZCRMEventParticipant = ZCRMEventParticipant(type : type, id : id )
        participant.setName( name : participantDetails.getString( key : "name" ) )
        participant.setEmail( email : participantDetails.getString( key : "Email" ) )
        participant.setStatus(status : participantDetails.getString( key : "status" ) )
        participant.setInvited( invited : participantDetails.getBoolean( key : "invited" ) )
        return participant
    }
    
    internal func addTags( tags : [ZCRMTag], overWrite : Bool?, completion : @escaping( [ZCRMTag]?, APIResponse?, Error? ) -> () )
    {
        setJSONRootKey(key: DATA)
        var reqBodyObj : [String:[[String:Any]]] = [String:[[String:Any]]]()
        let dataArray : [[String:Any]] = [[String:Any]]()
        let recordIdString = String(record.getId())
        reqBodyObj[getJSONRootKey()] = dataArray
        
        setUrlPath(urlPath: "/\(self.record.getModuleAPIName())/\(recordIdString)/actions/add_tags")
        setRequestMethod(requestMethod: .POST)
        var tagNamesString : String = String()
        for tag in tags
        {
            if let name = tag.getName()
            {
                tagNamesString.append( name )
                tagNamesString.append(",")
            }
        }
        if tagNamesString.startIndex != tagNamesString.endIndex
        {
            tagNamesString.removeLast()
        }
        addRequestParam(param: "tag_names", value: tagNamesString)
        if overWrite != nil
        {
            addRequestParam(param: "over_write", value: String(overWrite!))
        }
        setRequestBody(requestBody: reqBodyObj)
        
        let request : APIRequest = APIRequest(handler: self)
        print("Request : \(request.toString())")
        
        request.getAPIResponse { ( resp, err ) in
            if let error = err
            {
                completion( nil, nil, error )
            }
            if let response = resp
            {
                let responseJSON = response.getResponseJSON()
                let respDataArray : [[String:Any]] = responseJSON.getArrayOfDictionaries(key: self.getJSONRootKey())
                let respData : [String:Any] = respDataArray[0]
                let tagDetails : [String] = respData.getDictionary(key: DETAILS).getArray(key: TAGS) as! [String]
                var tags : [ZCRMTag] = [ZCRMTag]()
                for tagDetail in tagDetails
                {
                    let singleTag : ZCRMTag = ZCRMTag( tagName: tagDetail )
                    tags.append(singleTag)
                }
                completion( tags, response, nil )
            }
        }
    }
    
    internal func removeTags( tags : [ZCRMTag], completion : @escaping( [ZCRMTag]?, APIResponse?, Error? ) -> () )
    {
        setJSONRootKey(key: DATA)
        var reqBodyObj : [String:[[String:Any]]] = [String:[[String:Any]]]()
        let dataArray : [[String:Any]] = [[String:Any]]()
        let recordIdString = String(record.getId())
        reqBodyObj[getJSONRootKey()] = dataArray
        
        setUrlPath(urlPath: "/\(self.record.getModuleAPIName())/\(recordIdString)/actions/remove_tags")
        setRequestMethod(requestMethod: .POST)
        var tagNamesString : String = String()
        for tag in tags
        {
            if let name = tag.getName()
            {
                tagNamesString.append( name )
                tagNamesString.append(",")
            }
        }
        if tagNamesString.startIndex != tagNamesString.endIndex
        {
            tagNamesString.removeLast()
        }
        addRequestParam(param: "tag_names", value: tagNamesString)
        setRequestBody(requestBody: reqBodyObj)
        
        let request : APIRequest = APIRequest(handler: self)
        print("Request : \(request.toString())")
        
        request.getAPIResponse { ( resp, err ) in
            if let error = err
            {
                completion( nil, nil, error )
            }
            if let response = resp
            {
                let responseJSON = response.getResponseJSON()
                let respDataArray : [[String:Any]] = responseJSON.optArrayOfDictionaries(key: self.getJSONRootKey())!
                let respData : [String:Any] = respDataArray[0]
                let tagDetails : [String] = respData.getDictionary(key: DETAILS).getArray(key: TAGS) as! [String]
                var tags : [ZCRMTag] = [ZCRMTag]()
                for tagDetail in tagDetails
                {
                    let singleTag : ZCRMTag = ZCRMTag( tagName: tagDetail )
                    tags.append(singleTag)
                }
                completion( tags, response, nil )
            }
                
        }
    }
    
}

