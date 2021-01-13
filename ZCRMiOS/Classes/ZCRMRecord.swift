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
    enum CodingKeys: String, CodingKey
    {
        case isCreate
        case upsertJSON
        case data
        case lineItems
        case priceDetails
        case participants
        case subformRecord
        case taxes
        case lineTaxes
        case tags
        case dataProcessingBasisDetails
        case layout
        case owner
        case isOwnerSet
        case createdBy
        case modifiedBy
        case createdTime
        case modifiedTime
        
        case offlineOwner
        case offlineCreatedBy
        case offlineModifiedBy
        case offlineCreatedTime
        case offlineModifiedTime
    }
    
    private struct CustomCodingKeys: CodingKey
    {
        var stringValue: String
        init?(stringValue: String)
        {
            self.stringValue = stringValue
        }
        var intValue: Int?
        init?(intValue: Int)
        {
            return nil
        }
    }
    
    required public init(from decoder: Decoder) throws {
        
        try super.init(from: decoder)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try! values.decodeIfPresent(Bool.self, forKey: .isCreate)
        {
            isCreate = value
        }
        lineItems = try! values.decodeIfPresent([ ZCRMInventoryLineItem ].self, forKey: .lineItems)
        priceDetails = try! values.decodeIfPresent([ ZCRMPriceBookPricing ].self, forKey: .priceDetails)
        participants = try! values.decodeIfPresent([ ZCRMEventParticipant ].self, forKey: .participants)
        subformRecord = try! values.decodeIfPresent([String:[ZCRMSubformRecord]].self, forKey: .subformRecord)
        taxes = try! values.decodeIfPresent([ ZCRMTaxDelegate ].self, forKey: .taxes)
        lineTaxes = try! values.decodeIfPresent([ ZCRMLineTax ].self, forKey: .lineTaxes)
        tags = try! values.decodeIfPresent([String].self, forKey: .tags)
        dataProcessingBasisDetails = try! values.decodeIfPresent(ZCRMDataProcessBasisDetails.self, forKey: .dataProcessingBasisDetails)
        layout = try! values.decodeIfPresent(ZCRMLayoutDelegate.self, forKey: .layout)
        if let value = try! values.decodeIfPresent(ZCRMUserDelegate.self, forKey: .owner)
        {
            owner = value
        }
        if let value = try! values.decodeIfPresent(Bool.self, forKey: .isOwnerSet)
        {
            isOwnerSet = value
        }
        
        createdBy = try! values.decodeIfPresent(ZCRMUserDelegate.self, forKey: .createdBy)
        modifiedBy = try! values.decodeIfPresent(ZCRMUserDelegate.self, forKey: .modifiedBy)
        createdTime = try! values.decodeIfPresent(String.self, forKey: .createdTime)
        modifiedTime = try! values.decodeIfPresent(String.self, forKey: .modifiedTime)
        
        if let value = try! values.decodeIfPresent(ZCRMUser.self, forKey: .offlineOwner)
        {
            offlineOwner = value
        }
        if let value = try! values.decodeIfPresent(ZCRMUser.self, forKey: .offlineCreatedBy)
        {
            offlineCreatedBy = value
        }
        if let value = try! values.decodeIfPresent(ZCRMUser.self, forKey: .offlineModifiedBy)
        {
            offlineModifiedBy = value
        }
        if let value = try! values.decodeIfPresent(String.self, forKey: .offlineCreatedTime)
        {
            offlineCreatedTime = value
        }
        if let value = try! values.decodeIfPresent(String.self, forKey: .offlineModifiedTime)
        {
            offlineModifiedTime = value
        }
        
        do
        {
            let dynamicValues = try values.nestedContainer(keyedBy: CustomCodingKeys.self, forKey: .upsertJSON)
            for key in dynamicValues.allKeys
            {
                if let customKey = key.intValue
                {
                    upsertJSON[String(customKey)] = try dynamicValues.decode(JSONValue.self, forKey: key)
                }
                else
                {
                    upsertJSON[key.stringValue] = try dynamicValues.decode(JSONValue.self, forKey: key)
                }
            }
            
            let dataValues = try values.nestedContainer(keyedBy: CustomCodingKeys.self, forKey: .data)
            for key in dataValues.allKeys
            {
                if let customKey = key.intValue
                {
                    data[String(customKey)] = try dataValues.decode(JSONValue.self, forKey: key)
                }
                else
                {
                    if key.stringValue == "Product_Details"
                    {
                        let lineTems = try! dataValues.decodeIfPresent(JSONValue.self, forKey: key)
                        lineItems = lineTems?.value as? [ZCRMInventoryLineItem]
                    }
                    else
                    {
                        data[key.stringValue] = try dataValues.decode(JSONValue.self, forKey: key)
                    }
                }
            }
        }
        catch
        {
            ZCRMLogger.logError(message: error.description)
        }
    }
    
    open override func encode( to encoder : Encoder ) throws
    {
        try super.encode(to: encoder)
        
        var container = encoder.container( keyedBy : CodingKeys.self )
        
        try self.offlineOwner?.encode(to: encoder)
        try! container.encodeIfPresent(self.offlineOwner as? ZCRMUserDelegate, forKey: .offlineOwner)
        try! container.encodeIfPresent(self.offlineCreatedBy as? ZCRMUserDelegate, forKey: .offlineCreatedBy)
        try! container.encodeIfPresent(self.offlineModifiedBy as? ZCRMUserDelegate, forKey: .offlineModifiedBy)
        try! container.encodeIfPresent(self.offlineCreatedTime, forKey: .offlineCreatedTime)
        try! container.encodeIfPresent(self.offlineModifiedTime, forKey: .offlineModifiedTime)
        
        var customContainer = encoder.container(keyedBy: CustomCodingKeys.self)
        for (key, jsonValue) in data
        {
            if let customKey = CustomCodingKeys(stringValue: key), let value = jsonValue
            {
                try customContainer.encodeIfPresent( value, forKey : customKey )
            }
        }
        
        for (key, jsonValue) in upsertJSON
        {
            if let customKey = CustomCodingKeys(stringValue: key), let value = jsonValue
            {
                try customContainer.encodeIfPresent( value, forKey : customKey )
            }
        }
        
        var upsertJSONContainer = customContainer.nestedContainer(keyedBy: CustomCodingKeys.self, forKey: CustomCodingKeys(stringValue: "upsertJSON")!)
        for (key, jsonValue) in upsertJSON
        {
            if let customKey = CustomCodingKeys(stringValue: key), let value = jsonValue
            {
                try upsertJSONContainer.encodeIfPresent( value, forKey : customKey )
            }
        }
        
        var dataContainer = customContainer.nestedContainer(keyedBy: CustomCodingKeys.self, forKey: CustomCodingKeys(stringValue: "data")!)
        for (key, jsonValue) in data
        {
            if let customKey = CustomCodingKeys(stringValue: key), let value = jsonValue
            {
                try dataContainer.encodeIfPresent( value, forKey : customKey )
            }
        }
    }
    
    internal var isCreate : Bool = APIConstants.BOOL_MOCK
    internal var upsertJSON : [ String : JSONValue? ] = [ String : JSONValue? ]()
    
    public var lineItems : [ZCRMInventoryLineItem]?{
        didSet
        {
            upsertJSON.updateValue( JSONValue(value: lineItems), forKey: EntityAPIHandler.ResponseJSONKeys.productDetails)
        }
    }
    public var priceDetails : [ ZCRMPriceBookPricing ]?{
        didSet
        {
            upsertJSON.updateValue( JSONValue(value: priceDetails), forKey: EntityAPIHandler.ResponseJSONKeys.pricingDetails)
        }
    }
    public var participants : [ ZCRMEventParticipant ]?{
        didSet
        {
            upsertJSON.updateValue( JSONValue(value: participants), forKey: EntityAPIHandler.ResponseJSONKeys.participants)
        }
    }
    public var subformRecord : [String:[ZCRMSubformRecord]]?{
        didSet
        {
            if let subformRecord = subformRecord
            {
                for ( key, value ) in subformRecord
                {
                    upsertJSON.updateValue( JSONValue(value: value), forKey: key)
                }
            }
        }
    }
    public var taxes : [ ZCRMTaxDelegate ]?{
        didSet
        {
            upsertJSON.updateValue( JSONValue(value: taxes), forKey : EntityAPIHandler.ResponseJSONKeys.tax )
        }
    }
    public var lineTaxes : [ ZCRMLineTax ]?{
        didSet
        {
            upsertJSON.updateValue( JSONValue(value: lineTaxes), forKey : EntityAPIHandler.ResponseJSONKeys.dollarLineTax )
        }
    }
    public var tags : [ String ]?{
        didSet
        {
            upsertJSON.updateValue( JSONValue(value: tags), forKey: EntityAPIHandler.ResponseJSONKeys.tag)
        }
    }
    public var dataProcessingBasisDetails : ZCRMDataProcessBasisDetails?{
        didSet
        {
            upsertJSON.updateValue( JSONValue(value: dataProcessingBasisDetails), forKey: EntityAPIHandler.ResponseJSONKeys.dataProcessingBasisDetails)
        }
    }
    public var layout : ZCRMLayoutDelegate?{
        didSet
        {
            upsertJSON.updateValue( JSONValue(value: layout), forKey: EntityAPIHandler.ResponseJSONKeys.layout)
        }
    }
    public var owner : ZCRMUserDelegate = USER_MOCK{
        didSet
        {
            self.isOwnerSet = true
            upsertJSON.updateValue( JSONValue(value: owner), forKey: EntityAPIHandler.ResponseJSONKeys.owner)
        }
    }
    internal var isOwnerSet : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var createdBy : ZCRMUserDelegate?
    public internal( set ) var modifiedBy : ZCRMUserDelegate?
    public internal( set ) var createdTime : String?
    public internal( set ) var modifiedTime : String?
    
    
    /// Initialize the ZCRMRecord with the given module.
    ///
    /// - Parameter moduleAPIName: module whose associated ZCRMRecord to be initialized
    internal init(moduleAPIName : String)
    {
        super.init( id : APIConstants.STRING_MOCK, moduleAPIName : moduleAPIName )
        self.isCreate = true
    }
    
    public func resetModifiedValues()
    {
        if self.upsertJSON.hasValue(forKey: EntityAPIHandler.ResponseJSONKeys.productDetails)
        {
            self.lineItems = self.data[ EntityAPIHandler.ResponseJSONKeys.productDetails ]??.value as? [ ZCRMInventoryLineItem ]
        }
        if self.upsertJSON.hasValue(forKey: EntityAPIHandler.ResponseJSONKeys.pricingDetails)
        {
            self.priceDetails = self.data[ EntityAPIHandler.ResponseJSONKeys.pricingDetails ]??.value as? [ ZCRMPriceBookPricing ]
        }
        if self.upsertJSON.hasValue(forKey: EntityAPIHandler.ResponseJSONKeys.participants)
        {
            self.participants = self.data[ EntityAPIHandler.ResponseJSONKeys.participants ]??.value as? [ ZCRMEventParticipant ]
        }
        if self.upsertJSON.hasValue(forKey: EntityAPIHandler.ResponseJSONKeys.tax)
        {
            self.taxes = self.data[ EntityAPIHandler.ResponseJSONKeys.tax ]??.value as? [ ZCRMTaxDelegate ]
        }
        if self.upsertJSON.hasValue(forKey: EntityAPIHandler.ResponseJSONKeys.lineTax)
        {
            self.lineTaxes = self.data[ EntityAPIHandler.ResponseJSONKeys.lineTax ]??.value as? [ ZCRMLineTax ]
        }
        if self.upsertJSON.hasValue(forKey: EntityAPIHandler.ResponseJSONKeys.tag)
        {
            self.tags = self.data[ EntityAPIHandler.ResponseJSONKeys.tag ]??.value as? [ String ]
        }
        if self.upsertJSON.hasValue(forKey: EntityAPIHandler.ResponseJSONKeys.dataProcessingBasisDetails)
        {
            self.dataProcessingBasisDetails = self.data[ EntityAPIHandler.ResponseJSONKeys.dataProcessingBasisDetails ]??.value as? ZCRMDataProcessBasisDetails
        }
        if self.upsertJSON.hasValue(forKey: EntityAPIHandler.ResponseJSONKeys.layout)
        {
            self.layout = self.data[ EntityAPIHandler.ResponseJSONKeys.layout ]??.value as? ZCRMLayoutDelegate
        }
        if self.upsertJSON.hasValue(forKey: EntityAPIHandler.ResponseJSONKeys.owner)
        {
            if let owner = self.data[ EntityAPIHandler.ResponseJSONKeys.owner ]??.value as? ZCRMUserDelegate
            {
                self.owner = owner
            }
        }
        self.subformRecord = [ String : [ ZCRMSubformRecord ] ]()
        for ( key, value ) in self.data
        {
            if let value = value?.value, let subformRec = value as? [ ZCRMSubformRecord ], self.upsertJSON.hasValue(forKey: key)
            {
                self.subformRecord?[ key ] = subformRec
            }
        }
        self.upsertJSON = [ String : JSONValue ]()
    }
    
    /// Set the field value to the specified field name is mapped.
    ///
    /// - Parameters:
    ///   - ofFieldAPIName: field name to which the field value is mapped
    ///   - value: the field value to be mapped
    public func setValue( ofFieldAPIName : String, value : Any? )
    {
        self.upsertJSON.updateValue( JSONValue(value: value), forKey : ofFieldAPIName )
    }
    
    /**
    To Set The Participants For An Event  And To Set Whether They Should Get Notified Or Not
    
    - parameters:
       - participantsArray : Array Of ZCRMEventParticipants
       - sendNotification : A Boolean To Set whether The Participant Should Get Notified About The Event Details Or Not
    */
    public func setParticipants( participantsArray : [ ZCRMEventParticipant ], sendNotification : Bool)
    {
        self.participants = participantsArray
        self.upsertJSON.updateValue( JSONValue(value: sendNotification), forKey: EntityAPIHandler.ResponseJSONKeys.sendNotification )
    }
    
    /**
      Returns the field value to which the specified field name is mapped
     
     - Parameter ofFieldAPIName: Field name whose associated value is to be returned
     - Returns: The value to which specified field name is mapped
     - Throws: The ZCRMSDKError if the given field is not present in the ZCRMRecord
     */
    override public func getValue( ofFieldAPIName : String ) throws -> Any?
    {
        if self.upsertJSON.hasKey( forKey : ofFieldAPIName )
        {
            return self.upsertJSON.optValue( key : ofFieldAPIName )
        }
        else if self.data.hasKey( forKey : ofFieldAPIName )
        {
            return self.data.optValue( key : ofFieldAPIName )
        }
        else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.fieldNotFound) : The given field is not present in the record. Field Name -> \( ofFieldAPIName )")
            throw ZCRMError.processingError( code : ErrorCode.fieldNotFound, message : "The given field is not present in the record. Field Name -> \( ofFieldAPIName )", details : nil )
        }
    }
    
    public func getInt( ofFieldAPIName : String ) throws -> Int?
    {
        return try self.getValue( ofFieldAPIName : ofFieldAPIName ) as? Int
    }
    
    public func getInt64( ofFieldAPIName : String ) throws -> Int64?
    {
        return try self.getValue( ofFieldAPIName : ofFieldAPIName ) as? Int64
    }
    
    public func getDouble( ofFieldAPIName : String ) throws -> Double?
    {
        return try self.getValue( ofFieldAPIName : ofFieldAPIName ) as? Double
    }
    
    public func getBoolean( ofFieldAPIName : String ) throws -> Bool?
    {
        return try self.getValue( ofFieldAPIName : ofFieldAPIName ) as? Bool
    }
    
    public func getString( ofFieldAPIName : String ) throws -> String?
    {
        return try self.getValue( ofFieldAPIName : ofFieldAPIName ) as? String
    }
    
    public func getZCRMRecordDelegate( ofFieldAPIName : String ) throws -> ZCRMRecordDelegate?
    {
        return try self.getValue( ofFieldAPIName : ofFieldAPIName ) as? ZCRMRecordDelegate
    }
    
    public func getZCRMUserDelegate( ofFieldAPIName : String ) throws -> ZCRMUserDelegate?
    {
        return try self.getValue( ofFieldAPIName : ofFieldAPIName ) as? ZCRMUserDelegate
    }
    
    /**
      Returns the ZCRMRecord's fieldAPIName vs field value dictionary
     
     - Returns: ZCRMRecord's fieldAPIName vs field value dictionary
     */
    override public func getData() -> [ String : JSONValue? ]
    {
        var data : [ String : JSONValue? ] = [ String : JSONValue? ]()
        data = self.data
        for ( key, value ) in self.upsertJSON
        {
            data.updateValue( JSONValue(value: value), forKey : key )
        }
        return data
    }
    
    /// Add ZCRMInventoryLineItem to the ZCRMRecord
    ///
    /// - Parameter newLineItem: line item to be added
    public func addLineItem(newLineItem : ZCRMInventoryLineItem)
    {
        if self.lineItems == nil
        {
            self.lineItems = [ZCRMInventoryLineItem]()
        }
        self.lineItems?.append( newLineItem )
    }
    
    /// Add ZCRMPriceBookPricing to the ZCRMRecord.
    ///
    /// - Parameter priceDetail: price detail to be added
    public func addPriceDetail( priceDetail : ZCRMPriceBookPricing )
    {
        if self.priceDetails == nil
        {
            self.priceDetails = [ ZCRMPriceBookPricing ]()
        }
        self.priceDetails?.append( priceDetail )
    }
    
    /// Add ZCRMEventParticipant to the ZCRMRecord
    ///
    /// - Parameter participant: participant to be added
    public func addParticipant( participant : ZCRMEventParticipant )
    {
        if self.participants == nil
        {
            self.participants = [ ZCRMEventParticipant ]()
        }
        self.participants?.append( participant )
    }
    
    /// Add ZCRMTax to the ZCRMRecord
    ///
    /// - Parameter tax: ZCRMTax to be added
    public func addTax( tax : ZCRMTaxDelegate ) throws
    {
        if self.moduleAPIName == DefaultModuleAPINames.PRODUCTS
        {
            if self.taxes == nil
            {
                self.taxes = [ ZCRMTaxDelegate ]()
            }
            self.taxes?.append( tax )
        }
        else
        {
            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \(ErrorCode.invalidOperation) : This feature is not supported for this module" )
            throw ZCRMError.inValidError( code : ErrorCode.invalidOperation , message : "This feature is not supported for this module", details : nil )
        }
    }
    
    /// Add ZCRMTax to the ZCRMRecord
    ///
    /// - Parameter tax: ZCRMTax to be added
    public func addLineTax( lineTax : ZCRMLineTax ) throws
    {
        if self.moduleAPIName == DefaultModuleAPINames.QUOTES || self.moduleAPIName == DefaultModuleAPINames.PURCHASE_ORDERS || self.moduleAPIName == DefaultModuleAPINames.INVOICES || self.moduleAPIName == DefaultModuleAPINames.SALES_ORDERS
        {
            if self.lineTaxes == nil
            {
                self.lineTaxes = [ ZCRMLineTax ]()
            }
            self.lineTaxes?.append( lineTax )
        }
        else
        {
            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \(ErrorCode.invalidOperation) : This feature is not supported for this module" )
            throw ZCRMError.inValidError( code : ErrorCode.invalidOperation , message : "This feature is not supported for this module", details : nil )
        }
    }
    
    public struct ZCRMCheckIn
    {
        public internal( set ) var latitude : Double
        public internal( set ) var longitude : Double
        public var time : String
        public var subLocality : String?
        public var comment : String?
        public var city : String?
        public var state : String?
        public var country : String?
        public var zipCode : String?
        public var address : String?
        
        public init( latitude : Double, longitude : Double, checkInTime : String )
        {
            self.latitude = latitude
            self.longitude = longitude
            self.time = checkInTime
        }
    }
    
    /// Returns cloned ZCRMRecord
    ///
    /// - Returns: cloned ZCRMRecord
    /// - Throws: ZCRMError if falied to clone ZCRMRecord
    public func clone() throws -> ZCRMRecord
    {
        guard let cloneRecord = self.copy() as? ZCRMRecord else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.internalError) : Unable to clone the record")
            throw ZCRMError.inValidError( code : ErrorCode.internalError, message : "Unable to clone the record", details : nil )
        }
        cloneRecord.id = APIConstants.STRING_MOCK
        return cloneRecord
    }
    
    /// Returns the API response of the ZCRMRecord creation.
    ///
    /// - Returns: API response of the ZCRMRecord creation
    /// - Throws: ZCRMSDKError if Entity ID of the record is not nil
    public func create( completion : @escaping( ResultType.DataResponse< ZCRMRecord, APIResponse > ) -> () )
    {
        if !self.isCreate
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.invalidData) : Entity ID MUST be nil for create operation")
            completion( .failure( ZCRMError.processingError( code : ErrorCode.invalidData, message : "Entity ID MUST be nil for create operation.", details : nil  ) ) )
        }
        else
        {
            EntityAPIHandler(record: self).createRecord( triggers : nil ) { ( result ) in
                completion( result )
            }
        }
    }
    
    public func create( triggers : [Trigger], completion : @escaping( ResultType.DataResponse< ZCRMRecord, APIResponse > ) -> () )
    {
        if !self.isCreate
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.invalidData) : Entity ID MUST be nil for create operation")
            completion( .failure( ZCRMError.processingError( code : ErrorCode.invalidData, message : "Entity ID MUST be nil for create operation.", details : nil ) ) )
        }
        else
        {
            EntityAPIHandler(record: self).createRecord( triggers : triggers ) { ( result ) in
                completion( result )
            }
        }
    }
    
    /// Returns the API response of the ZCRMRecord update.
    ///
    /// - Returns: API response of the ZCRMRecord update
    /// - Throws: ZCRMSDKError if Entity ID of the record is nil
    public func update( completion : @escaping( ResultType.DataResponse< ZCRMRecord, APIResponse > ) -> () )
    {
        if self.isCreate
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : Entity ID MUST NOT be nil for update operation")
            completion( .failure( ZCRMError.processingError( code : ErrorCode.mandatoryNotFound, message : "Entity ID MUST NOT be nil for update operation.", details : nil ) ) )
        }
        else
        {
            EntityAPIHandler(record: self).updateRecord( triggers : nil ) { ( result ) in
                completion( result )
            }
        }
    }
    
    public func update( triggers : [Trigger], completion : @escaping( ResultType.DataResponse< ZCRMRecord, APIResponse > ) -> () )
    {
        if self.isCreate
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : Entity ID MUST NOT be nil for update operation")
            completion( .failure( ZCRMError.processingError( code : ErrorCode.mandatoryNotFound, message : "Entity ID MUST NOT be nil for update operation.", details : nil ) ) )
        }
        else
        {
            EntityAPIHandler(record: self).updateRecord( triggers : triggers ) { ( result ) in
                completion( result )
            }
        }
    }
    
    public func checkIn( checkIn : ZCRMCheckIn, completion : @escaping( ResultType.DataResponse< ZCRMRecord, APIResponse > ) -> () )
    {
        do
        {
            try self.createCheckIn( checkIn : checkIn )
            if self.isCreate
            {
                EntityAPIHandler( record : self ).createRecord( triggers : nil ) { ( result ) in
                    completion( result )
                }
            }
            else
            {
                EntityAPIHandler( record : self ).updateRecord( triggers : nil ) { ( result ) in
                    completion( result )
                }
            }
        }
        catch
        {
            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
            completion( .failure( typeCastToZCRMError( error ) ) )
        }
    }
    
    public func checkIn( checkIn : ZCRMCheckIn, triggers : [ Trigger ], completion : @escaping( ResultType.DataResponse< ZCRMRecord, APIResponse > ) -> () )
    {
        do
        {
            try self.createCheckIn( checkIn : checkIn )
            if self.isCreate
            {
                EntityAPIHandler( record : self ).createRecord( triggers : triggers ) { ( result ) in
                    completion( result )
                }
            }
            else
            {
                EntityAPIHandler( record : self ).updateRecord( triggers : triggers ) { ( result ) in
                    completion( result )
                }
            }
        }
        catch
        {
            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
            completion( .failure( typeCastToZCRMError( error ) ) )
        }
    }
    
    public func undoCheckIn( completion : @escaping( ResultType.DataResponse< ZCRMRecord, APIResponse > ) -> () )
    {
        do
        {
            try undoCheckIn()
            EntityAPIHandler( record : self ).updateRecord( triggers : nil ) { ( result ) in
                completion( result )
            }
        }
        catch
        {
            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
            completion( .failure( typeCastToZCRMError( error ) ) )
        }
    }
    
    public func undoCheckIn( triggers : [ Trigger ], completion : @escaping( ResultType.DataResponse< ZCRMRecord, APIResponse > ) -> () )
    {
        do
        {
            try undoCheckIn()
            EntityAPIHandler( record : self ).updateRecord( triggers : triggers ) { ( result ) in
                completion( result )
            }
        }
        catch
        {
            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
            completion( .failure( typeCastToZCRMError( error ) ) )
        }
    }
    
    private func createCheckIn( checkIn : ZCRMCheckIn ) throws
    {
        if self.moduleAPIName != DefaultModuleAPINames.EVENTS
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.notSupported) : Check In is not supported for this module")
            throw ZCRMError.inValidError(code: ErrorCode.notSupported, message: "Check In is not supported for this module", details: nil)
        }
        else
        {
            self.upsertJSON.updateValue( JSONValue(value: checkIn.latitude), forKey : EntityAPIHandler.ResponseJSONKeys.latitude )
            self.upsertJSON.updateValue( JSONValue(value: checkIn.longitude), forKey : EntityAPIHandler.ResponseJSONKeys.longitude )
            self.upsertJSON.updateValue( JSONValue(value: checkIn.time), forKey : EntityAPIHandler.ResponseJSONKeys.checkInTime )
            if let sublocality = checkIn.subLocality
            {
                self.upsertJSON.updateValue( JSONValue(value: sublocality), forKey : EntityAPIHandler.ResponseJSONKeys.checkInSubLocality )
            }
            if let comment = checkIn.comment
            {
                self.upsertJSON.updateValue( JSONValue(value: comment), forKey : EntityAPIHandler.ResponseJSONKeys.checkInComment )
            }
            if let city = checkIn.city
            {
                self.upsertJSON.updateValue( JSONValue(value: city), forKey : EntityAPIHandler.ResponseJSONKeys.checkInCity )
            }
            if let state = checkIn.state
            {
                self.upsertJSON.updateValue( JSONValue(value: state), forKey : EntityAPIHandler.ResponseJSONKeys.checkInState )
            }
            if let country = checkIn.country
            {
                self.upsertJSON.updateValue( JSONValue(value: country), forKey : EntityAPIHandler.ResponseJSONKeys.checkInCountry )
            }
            if let zipCode = checkIn.zipCode
            {
                self.upsertJSON.updateValue( JSONValue(value: zipCode), forKey : EntityAPIHandler.ResponseJSONKeys.zipCode )
            }
            if let address = checkIn.address
            {
                self.upsertJSON.updateValue( JSONValue(value: address), forKey : EntityAPIHandler.ResponseJSONKeys.checkInAddress )
            }
        }
    }
    
    public func getCheckInDetails() throws -> ZCRMCheckIn
    {
        if self.moduleAPIName != DefaultModuleAPINames.EVENTS
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.notSupported) : Check In is not supported for this module")
            throw ZCRMError.inValidError(code: ErrorCode.notSupported, message: "Check In is not supported for this module", details: nil)
        }
        else
        {
            if let latitude = try self.getValue( ofFieldAPIName : EntityAPIHandler.ResponseJSONKeys.latitude ) as? Double, let longitude = try self.getValue( ofFieldAPIName : EntityAPIHandler.ResponseJSONKeys.longitude ) as? Double, let time = try self.getValue( ofFieldAPIName : EntityAPIHandler.ResponseJSONKeys.checkInTime ) as? String
            {
                var checkIn : ZCRMCheckIn
                checkIn = ZCRMCheckIn( latitude : latitude, longitude : longitude, checkInTime : time )
                checkIn.subLocality = try self.getString( ofFieldAPIName : EntityAPIHandler.ResponseJSONKeys.checkInSubLocality )
                checkIn.comment = try self.getString( ofFieldAPIName : EntityAPIHandler.ResponseJSONKeys.checkInComment )
                checkIn.city = try self.getString( ofFieldAPIName : EntityAPIHandler.ResponseJSONKeys.checkInCity )
                checkIn.state = try self.getString( ofFieldAPIName : EntityAPIHandler.ResponseJSONKeys.checkInState )
                checkIn.country = try self.getString( ofFieldAPIName : EntityAPIHandler.ResponseJSONKeys.checkInCountry )
                checkIn.zipCode = try self.getString( ofFieldAPIName : EntityAPIHandler.ResponseJSONKeys.zipCode )
                checkIn.address = try self.getString( ofFieldAPIName : EntityAPIHandler.ResponseJSONKeys.checkInAddress )
                return checkIn
            }
            else
            {
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.invalidOperation) : This record does not contain a ZCRMCheckIn")
                throw ZCRMError.inValidError(code: ErrorCode.invalidOperation, message: "This record does not contain a ZCRMCheckIn", details: nil)
            }
        }
    }
    
    private func undoCheckIn() throws
    {
        if self.moduleAPIName != DefaultModuleAPINames.EVENTS
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.notSupported) : Check In is not supported for this module")
            throw ZCRMError.inValidError(code: ErrorCode.notSupported, message: "Check In is not supported for this module", details: nil)
        }
        else
        {
            if self.isCreate
            {
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.invalidOperation) : You haven't checked into the event")
                throw ZCRMError.inValidError(code: ErrorCode.invalidOperation, message: "You haven't checked into the event", details: nil)
            }
            else
            {
                self.upsertJSON.updateValue( nil, forKey : EntityAPIHandler.ResponseJSONKeys.latitude )
                self.upsertJSON.updateValue( nil, forKey : EntityAPIHandler.ResponseJSONKeys.longitude )
                self.upsertJSON.updateValue( nil, forKey : EntityAPIHandler.ResponseJSONKeys.checkInSubLocality )
                self.upsertJSON.updateValue( nil, forKey : EntityAPIHandler.ResponseJSONKeys.checkInComment )
                self.upsertJSON.updateValue( nil, forKey : EntityAPIHandler.ResponseJSONKeys.checkInCity )
                self.upsertJSON.updateValue( nil, forKey : EntityAPIHandler.ResponseJSONKeys.checkInState )
                self.upsertJSON.updateValue( nil, forKey : EntityAPIHandler.ResponseJSONKeys.checkInCountry )
                self.upsertJSON.updateValue( nil, forKey : EntityAPIHandler.ResponseJSONKeys.zipCode )
                self.upsertJSON.updateValue( nil, forKey : EntityAPIHandler.ResponseJSONKeys.checkInAddress )
            }
        }
    }
}

extension ZCRMRecord : NSCopying
{
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy : ZCRMRecord = ZCRMRecord(moduleAPIName: self.moduleAPIName)
        copy.data = self.data
        copy.lineItems = self.lineItems
        copy.priceDetails = self.priceDetails
        copy.participants = self.participants
        copy.subformRecord = self.subformRecord
        copy.taxes = self.taxes
        copy.lineTaxes = self.lineTaxes
        copy.tags = self.tags
        copy.dataProcessingBasisDetails = self.dataProcessingBasisDetails
        copy.layout = self.layout
        copy.owner = self.owner
        copy.upsertJSON = self.upsertJSON
        copy.id = self.id
        copy.isCreate = self.isCreate
        return copy
    }
    
    public static func == (lhs: ZCRMRecord, rhs: ZCRMRecord) -> Bool {
        if lhs.data.count == rhs.data.count {
            for ( key, value ) in lhs.data
            {
                if rhs.data.hasKey( forKey : key )
                {
                    if !isEqual( lhs : value, rhs : rhs.data[ key ] as Any? )
                    {
                        return false
                    }
                }
                else
                {
                    return false
                }
            }
        }
        else
        {
            return false
        }
        if lhs.properties.count == rhs.properties.count {
            for ( key, value ) in lhs.properties
            {
                if rhs.properties.hasKey( forKey : key )
                {
                    if !isEqual( lhs : value, rhs : rhs.properties[ key ] as Any? )
                    {
                        return false
                    }
                }
                else
                {
                    return false
                }
            }
        }
        else
        {
            return false
        }
        let equals : Bool =
            lhs.lineItems == rhs.lineItems &&
            lhs.priceDetails == rhs.priceDetails &&
            lhs.participants == rhs.participants &&
            lhs.subformRecord == rhs.subformRecord &&
            lhs.lineTaxes == rhs.lineTaxes &&
            lhs.taxes == rhs.taxes &&
            lhs.tags == rhs.tags &&
            lhs.dataProcessingBasisDetails == rhs.dataProcessingBasisDetails &&
            lhs.layout == rhs.layout &&
            lhs.owner == rhs.owner &&
            lhs.createdBy == rhs.createdBy &&
            lhs.createdTime == rhs.createdTime &&
            lhs.modifiedBy == rhs.modifiedBy &&
            lhs.modifiedTime == rhs.modifiedTime
        return equals
    }
    
}
