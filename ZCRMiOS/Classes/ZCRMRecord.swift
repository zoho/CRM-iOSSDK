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
    internal var isCreate : Bool = APIConstants.BOOL_MOCK
    internal var upsertJSON : [ String : Any? ] = [ String : Any? ]()
    
    public var lineItems : [ZCRMInventoryLineItem]?{
        didSet
        {
            upsertJSON.updateValue(lineItems, forKey: EntityAPIHandler.ResponseJSONKeys.productDetails)
        }
    }
    public var priceDetails : [ ZCRMPriceBookPricing ]?{
        didSet
        {
            upsertJSON.updateValue(priceDetails, forKey: EntityAPIHandler.ResponseJSONKeys.pricingDetails)
        }
    }
    public var participants : [ ZCRMEventParticipant ]?{
        didSet
        {
            upsertJSON.updateValue(participants, forKey: EntityAPIHandler.ResponseJSONKeys.participants)
        }
    }
    public var subformRecord : [String:[ZCRMSubformRecord]]?{
        didSet
        {
            if let subformRecord = subformRecord
            {
                for ( key, value ) in subformRecord
                {
                    upsertJSON.updateValue(value, forKey: key)
                }
            }
        }
    }
    public var taxes : [ ZCRMTaxDelegate ]?{
        didSet
        {
            upsertJSON.updateValue( taxes, forKey : EntityAPIHandler.ResponseJSONKeys.tax )
        }
    }
    public var lineTaxes : [ ZCRMLineTax ]?{
        didSet
        {
            upsertJSON.updateValue( lineTaxes, forKey : EntityAPIHandler.ResponseJSONKeys.dollarLineTax )
        }
    }
    public var tags : [ String ]?{
        didSet
        {
            upsertJSON.updateValue(tags, forKey: EntityAPIHandler.ResponseJSONKeys.tag)
        }
    }
    public var dataProcessingBasisDetails : ZCRMDataProcessBasisDetails?{
        didSet
        {
            upsertJSON.updateValue(dataProcessingBasisDetails, forKey: EntityAPIHandler.ResponseJSONKeys.dataProcessingBasisDetails)
        }
    }
    public var layout : ZCRMLayoutDelegate?{
        didSet
        {
            upsertJSON.updateValue(layout, forKey: EntityAPIHandler.ResponseJSONKeys.layout)
        }
    }
    public var owner : ZCRMUserDelegate = USER_MOCK{
        didSet
        {
            self.isOwnerSet = true
            upsertJSON.updateValue(owner, forKey: EntityAPIHandler.ResponseJSONKeys.owner)
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
        super.init( id : APIConstants.INT64_MOCK, moduleAPIName : moduleAPIName )
        self.isCreate = true
    }
    
    public func resetModifiedValues()
    {
        if self.upsertJSON.hasValue(forKey: EntityAPIHandler.ResponseJSONKeys.productDetails)
        {
            self.lineItems = self.data[ EntityAPIHandler.ResponseJSONKeys.productDetails ] as? [ ZCRMInventoryLineItem ]
        }
        if self.upsertJSON.hasValue(forKey: EntityAPIHandler.ResponseJSONKeys.pricingDetails)
        {
            self.priceDetails = self.data[ EntityAPIHandler.ResponseJSONKeys.pricingDetails ] as? [ ZCRMPriceBookPricing ]
        }
        if self.upsertJSON.hasValue(forKey: EntityAPIHandler.ResponseJSONKeys.participants)
        {
            self.participants = self.data[ EntityAPIHandler.ResponseJSONKeys.participants ] as? [ ZCRMEventParticipant ]
        }
        if self.upsertJSON.hasValue(forKey: EntityAPIHandler.ResponseJSONKeys.tax)
        {
            self.taxes = self.data[ EntityAPIHandler.ResponseJSONKeys.tax ] as? [ ZCRMTaxDelegate ]
        }
        if self.upsertJSON.hasValue(forKey: EntityAPIHandler.ResponseJSONKeys.lineTax)
        {
            self.lineTaxes = self.data[ EntityAPIHandler.ResponseJSONKeys.lineTax ] as? [ ZCRMLineTax ]
        }
        if self.upsertJSON.hasValue(forKey: EntityAPIHandler.ResponseJSONKeys.tag)
        {
            self.tags = self.data[ EntityAPIHandler.ResponseJSONKeys.tag ] as? [ String ]
        }
        if self.upsertJSON.hasValue(forKey: EntityAPIHandler.ResponseJSONKeys.dataProcessingBasisDetails)
        {
            self.dataProcessingBasisDetails = self.data[ EntityAPIHandler.ResponseJSONKeys.dataProcessingBasisDetails ] as? ZCRMDataProcessBasisDetails
        }
        if self.upsertJSON.hasValue(forKey: EntityAPIHandler.ResponseJSONKeys.layout)
        {
            self.layout = self.data[ EntityAPIHandler.ResponseJSONKeys.layout ] as? ZCRMLayoutDelegate
        }
        if self.upsertJSON.hasValue(forKey: EntityAPIHandler.ResponseJSONKeys.owner)
        {
            if let owner = self.data[ EntityAPIHandler.ResponseJSONKeys.owner ] as? ZCRMUserDelegate
            {
                self.owner = owner
            }
        }
        self.subformRecord = [ String : [ ZCRMSubformRecord ] ]()
        for ( key, value ) in self.data
        {
            if let subformRec = value as? [ ZCRMSubformRecord ], self.upsertJSON.hasValue(forKey: key)
            {
                self.subformRecord?[ key ] = subformRec
            }
        }
        self.upsertJSON = [ String : Any ]()
    }
    
    /// Set the field value to the specified field name is mapped.
    ///
    /// - Parameters:
    ///   - ofFieldAPIName: field name to which the field value is mapped
    ///   - value: the field value to be mapped
    public func setValue( ofFieldAPIName : String, value : Any? )
    {
        self.upsertJSON.updateValue( value, forKey : ofFieldAPIName )
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
        self.upsertJSON.updateValue( sendNotification, forKey: EntityAPIHandler.ResponseJSONKeys.sendNotification )
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
    override public func getData() -> [ String : Any? ]
    {
        var data : [ String : Any? ] = [ String : Any? ]()
        data = self.data
        for ( key, value ) in self.upsertJSON
        {
            data.updateValue( value, forKey : key )
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
        cloneRecord.id = APIConstants.INT64_MOCK
        return cloneRecord
    }
    
    /// Returns the API response of the ZCRMRecord creation.
    ///
    /// - Returns: API response of the ZCRMRecord creation
    /// - Throws: ZCRMSDKError if Entity ID of the record is not nil
    public func create( completion : @escaping( Result.DataResponse< ZCRMRecord, APIResponse > ) -> () )
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
    
    public func create( triggers : [Trigger], completion : @escaping( Result.DataResponse< ZCRMRecord, APIResponse > ) -> () )
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
    public func update( completion : @escaping( Result.DataResponse< ZCRMRecord, APIResponse > ) -> () )
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
    
    public func update( triggers : [Trigger], completion : @escaping( Result.DataResponse< ZCRMRecord, APIResponse > ) -> () )
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
    
    public func checkIn( checkIn : ZCRMCheckIn, completion : @escaping( Result.DataResponse< ZCRMRecord, APIResponse > ) -> () )
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
    
    public func checkIn( checkIn : ZCRMCheckIn, triggers : [ Trigger ], completion : @escaping( Result.DataResponse< ZCRMRecord, APIResponse > ) -> () )
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
    
    public func undoCheckIn( completion : @escaping( Result.DataResponse< ZCRMRecord, APIResponse > ) -> () )
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
    
    public func undoCheckIn( triggers : [ Trigger ], completion : @escaping( Result.DataResponse< ZCRMRecord, APIResponse > ) -> () )
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
            self.upsertJSON.updateValue( checkIn.latitude, forKey : EntityAPIHandler.ResponseJSONKeys.latitude )
            self.upsertJSON.updateValue( checkIn.longitude, forKey : EntityAPIHandler.ResponseJSONKeys.longitude )
            self.upsertJSON.updateValue( checkIn.time, forKey : EntityAPIHandler.ResponseJSONKeys.checkInTime )
            if let sublocality = checkIn.subLocality
            {
                self.upsertJSON.updateValue( sublocality, forKey : EntityAPIHandler.ResponseJSONKeys.checkInSubLocality )
            }
            if let comment = checkIn.comment
            {
                self.upsertJSON.updateValue( comment, forKey : EntityAPIHandler.ResponseJSONKeys.checkInComment )
            }
            if let city = checkIn.city
            {
                self.upsertJSON.updateValue( city, forKey : EntityAPIHandler.ResponseJSONKeys.checkInCity )
            }
            if let state = checkIn.state
            {
                self.upsertJSON.updateValue( state, forKey : EntityAPIHandler.ResponseJSONKeys.checkInState )
            }
            if let country = checkIn.country
            {
                self.upsertJSON.updateValue( country, forKey : EntityAPIHandler.ResponseJSONKeys.checkInCountry )
            }
            if let zipCode = checkIn.zipCode
            {
                self.upsertJSON.updateValue( zipCode, forKey : EntityAPIHandler.ResponseJSONKeys.zipCode )
            }
            if let address = checkIn.address
            {
                self.upsertJSON.updateValue( address, forKey : EntityAPIHandler.ResponseJSONKeys.checkInAddress )
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
