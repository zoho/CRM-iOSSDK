//
//  ZCRMRecord.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 16/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

public protocol ZCRMEntity
{
    
}

open class ZCRMRecord : ZCRMRecordDelegate
{
    var fieldNameVsValue : [String:Any?] = [String:Any?]()
    var properties : [String:Any?] = [ String : Any? ]()
    var lookupLabel : String?
    var lineItems : [ZCRMInventoryLineItem] = [ZCRMInventoryLineItem]()
    var priceDetails : [ ZCRMPriceBookPricing ] = [ ZCRMPriceBookPricing ]()
    var participants : [ ZCRMEventParticipant ] = [ ZCRMEventParticipant ]()
    var tax : [ ZCRMTaxDelegate ] = [ ZCRMTaxDelegate ]()
    var owner : ZCRMUserDelegate = USER_NIL
    var createdBy : ZCRMUserDelegate = USER_NIL
    var modifiedBy : ZCRMUserDelegate = USER_NIL
    var createdTime : String = STRING_NIL
    var modifiedTime : String = STRING_NIL
    var layout : ZCRMLayoutDelegate = LAYOUT_NIL
    var tags : [ZCRMTag] = [ZCRMTag]()
    var dataProcessingBasicDetails : ZCRMDataProcessBasicDetails?
    
    /// Initialize the ZCRMRecord with the given module.
    ///
    /// - Parameter moduleAPIName: module whose associated ZCRMRecord to be initialized
    public init(moduleAPIName : String)
    {
        super.init( recordId : INT64_NIL, moduleAPIName : moduleAPIName )
    }
    
    /// Set the field value to the specified field name is mapped.
    ///
    /// - Parameters:
    ///   - forField: field name to which the field value is mapped
    ///   - value: the filed value to be mapped
    public func setValue(forField : String, value : Any?)
    {
        self.fieldNameVsValue[forField] = value
    }
    
    /// Returns the field value to which the specified field name is mapped
    ///
    /// - Parameter ofField: field name whose associated value is to be returned
    /// - Returns: the value to which specified field name is mapped
    /// - Throws: throws the ZCRMSDKError if the given field is not present in the ZCRMRecord
    public func getValue(ofField : String) throws -> Any?
    {
        if self.fieldNameVsValue.hasKey( forKey : ofField )
        {
            if( self.fieldNameVsValue.hasValue( forKey : ofField ) )
            {
                return self.fieldNameVsValue.optValue(key : ofField)
            }
            else
            {
                return nil
            }
        }
        else
        {
            throw ZCRMError.ProcessingError( code : ErrorCode.FIELD_NOT_FOUND, message : "The given field is not present in the record.")
        }
    }
    
    /// Returns the ZCRMRecord's fieldAPIName vs field value dictionary.
    ///
    /// - Returns: ZCRMRecord's fieldAPIName vs field value dictionary
    public func getData() -> [String:Any?]
    {
        return self.fieldNameVsValue
    }
    
    /// Set the properties of the ZCRMRecord.
    ///
    /// - Parameter properties: properties of the ZCRMRecord
    internal func setProperties( properties : [ String : Any? ] )
    {
        self.properties = properties
    }
    
    /// Set the value of the ZCRMRecord's property.
    ///
    /// - Parameters:
    ///   - ofProperty: property whose value is to be change.
    ///   - value: value of the ZCRMRecord's property
    internal func setValue(ofProperty : String, value : Any?)
    {
        self.properties[ofProperty] = value
    }
    
    /// Add ZCRMInventoryLineItem to the ZCRMRecord
    ///
    /// - Parameter newLineItem: line item to be added
    public func addLineItem(newLineItem : ZCRMInventoryLineItem)
    {
        self.lineItems.append( newLineItem )
    }
    
    internal func addTag( tag : ZCRMTag )
    {
        self.tags.append(tag)
    }
    
    /// Add ZCRMPriceBookPricing to the ZCRMRecord.
    ///
    /// - Parameter priceDetail: price detail to be added
    public func addPriceDetail( priceDetail : ZCRMPriceBookPricing )
    {
        self.priceDetails.append( priceDetail )
    }
    
    /// Add ZCRMEventParticipant to the ZCRMRecord
    ///
    /// - Parameter participant: participant to be added
    public func addParticipant( participant : ZCRMEventParticipant )
    {
        self.participants.append( participant )
    }
    
    /// Add ZCRMTax to the ZCRMRecord
    ///
    /// - Parameter tax: ZCRMTax to be added
    public func addTax( tax : ZCRMTaxDelegate )
    {
//        self.tax[ tax.getTaxName() ] = tax
        self.tax.append(tax)
    }
    
    /// Returns cloned ZCRMRecord
    ///
    /// - Returns: cloned ZCRMRecord
    /// - Throws: ZCRMError if falied to clone ZCRMRecord
    public func clone() throws -> ZCRMRecord
    {
        let cloneRecord = self
        cloneRecord.recordId = INT64_NIL
        cloneRecord.setProperties( properties : [ String : Any? ]() )
        return cloneRecord
    }
    
    /// Returns the API response of the ZCRMRecord creation.
    ///
    /// - Returns: API response of the ZCRMRecord creation
    /// - Throws: ZCRMSDKError if Entity ID of the record is not nil
    public func create( completion : @escaping( Result.DataResponse< ZCRMRecord, APIResponse > ) -> () )
    {
        if( recordId != INT64_NIL )
        {
            completion( .failure( ZCRMError.ProcessingError( code : ErrorCode.MANDATORY_NOT_FOUND, message : "Entity ID MUST be null for create operation." ) ) )
        }
        else
        {
            EntityAPIHandler(record: self).createRecord { ( result ) in
                completion( result )
            }
        }
    }
    
    /// Returns the API response of the ZCRMRecord update.
    ///
    /// - Returns: API response of the ZCRMRecord update
    /// - Throws: ZCRMSDKError if Entity ID of the record is nil
    public func update( completion : @escaping( Result.DataResponse< ZCRMRecord, APIResponse > ) -> () )
    {
        if(recordId == INT64_NIL)
        {
            completion( .failure( ZCRMError.ProcessingError( code : ErrorCode.MANDATORY_NOT_FOUND, message : "Entity ID MUST NOT be null for update operation." ) ) )
        }
        else
        {
            EntityAPIHandler(record: self).updateRecord { ( result ) in
                completion( result )
            }
        }
    }
}

