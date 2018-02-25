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

public class ZCRMRecord : ZCRMEntity
{
    private var id : Int64?
    private var moduleAPIName : String
    private var fieldNameVsValue : [String:Any?] = [String:Any?]()
    private var properties : [String:Any?] = [ String : Any? ]()
    private var lookupLabel : String?
    private var lineItems : [ZCRMInventoryLineItem] = [ZCRMInventoryLineItem]()
    private var priceDetails : [ ZCRMPriceBookPricing ] = [ ZCRMPriceBookPricing ]()
    private var participants : [ ZCRMEventParticipant ] = [ ZCRMEventParticipant ]()
    private var tax : [ String : ZCRMTax? ] = [ String : ZCRMTax ]()
    private var owner : ZCRMUser?
    private var createdBy : ZCRMUser?
    private var modifiedBy : ZCRMUser?
    private var createdTime : String?
    private var modifiedTime : String?
    private var layout : ZCRMLayout?
    
    /// Initialize the ZCRMRecord with the given module.
    ///
    /// - Parameter moduleAPIName: module whose associated ZCRMRecord to be initialized
    public init(moduleAPIName : String)
    {
        self.moduleAPIName = moduleAPIName
    }
    
    /// Initialize the ZCRMRecord with the given module and record id.
    ///
    /// - Parameters:
    ///   - moduleAPIName: module whose associated ZCRMRecord to be initialized
    ///   - recordId: record id whose associated ZCRMRecord to be initialized
    public init(moduleAPIName : String, recordId : Int64)
    {
        self.moduleAPIName = moduleAPIName
        self.id = recordId
    }
    
    /// Returns the module API name of the ZCRMRecord.
    ///
    /// - Returns: module API name of the record
    public func getModuleAPIName() -> String
    {
        return self.moduleAPIName
    }
    
    /// Set the id of the ZCRMRecord.
    ///
    /// - Parameter recordId: id of the ZCRMRecord
    internal func setId( recordId : Int64? )
    {
        self.id = recordId
    }
    
    /// Returns the id of the ZCRMRecord.
    ///
    /// - Returns: id of the ZCRMRecord
    public func getId() -> Int64
    {
        return self.id!
    }
    
    /// Set the lookup label of the ZCRMRecord.
    ///
    /// - Parameter label: lookup label of the ZCRMRecord
    internal func setLookupLabel(label : String)
    {
        self.lookupLabel = label
    }
    
    /// Returns the lookup label of the ZCRMRecord.
    ///
    /// - Returns: lookup label of the ZCRMRecord
    public func getLookupLabel() -> String?
    {
        return self.lookupLabel
    }
    
    /// Set the owner of the ZCRMRecord.
    ///
    /// - Parameter owner: owner of the ZCRMRecord
    public func setOwner(owner: ZCRMUser)
    {
        self.owner = owner
    }
    
    /// Returns the owner of the ZCRMRecord.
    ///
    /// - Returns: owner of the ZCRMRecord
    public func getOwner() -> ZCRMUser?
    {
        return self.owner
    }
    
    /// Set ZCRMUser who created the ZCRMRecord.
    ///
    /// - Parameter createdBy: ZCRMUser who created the ZCRMRecord
    internal func setCreatedBy(createdBy: ZCRMUser)
    {
        self.createdBy = createdBy
    }
    
    /// Returns the ZCRMUser who created the ZCRMRecord.
    ///
    /// - Returns: ZCRMUser who created the ZCRMRecord
    public func getCreatedBy() -> ZCRMUser?
    {
        return self.createdBy
    }
    
    /// Set ZCRMUser who recently modified the ZCRMRecord(last modification)
    ///
    /// - Parameter modifiedBy: ZCRMUser who recently modified the ZCRMRecord
    internal func setModifiedBy(modifiedBy: ZCRMUser)
    {
        self.modifiedBy = modifiedBy
    }
    
    /// Returns the ZCRMUser who recently modified the ZCRMRecord(last modification)
    ///
    /// - Returns: ZCRMUser who recently modified the ZCRMRecord
    public func getModifiedBy() -> ZCRMUser?
    {
        return self.modifiedBy
    }
    /// Set created time of the ZCRMRecord.
    ///
    /// - Parameter modifiedBy: the time at which the ZCRMRecord is created
    internal func setCreatedTime(createdTime: String)
    {
        self.createdTime = createdTime
    }
    
    /// Returns created time of the ZCRMRecord.
    ///
    /// - Returns: the time at which the ZCRMRecord is created
    public func getCreatedTime() -> String?
    {
        return self.createdTime
    }
    
    /// Set modified time of the ZCRMRecord(last modification time).
    ///
    /// - Parameter modifiedTime: the time at which the ZCRMRecord is modified
    internal func setModifiedTime(modifiedTime: String)
    {
        self.modifiedTime = modifiedTime
    }
    
    /// Returns the modified time of the ZCRMRecord(last modification time).
    ///
    /// - Returns: the time at which the ZCRMRecord is modified
    public func getModifiedTime() -> String?
    {
        return self.modifiedTime
    }
    
    /// Set the ZCRMLayout of the ZCRMRecord.
    ///
    /// - Parameter layout: ZCRMLayout of the ZCRMRecord
    public func setLayout(layout: ZCRMLayout?)
    {
        self.layout = layout
    }
    
    /// Returns the ZCRMLayout of the ZCRMRecord.
    ///
    /// - Returns: ZCRMLayout of the ZCRMRecord.
    public func getLayout() -> ZCRMLayout?
    {
        return self.layout
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
            throw ZCRMSDKError.ProcessingError("The given field is not present in the record.")
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
    
    /// Returns the value of the ZCRMRecord's property
    ///
    /// - Parameter ofProperty: property whose value is to be returned
    /// - Returns: the value of the requested property
    public func getValue(ofProperty: String) -> Any?
    {
        return self.properties.optValue(key: ofProperty)
    }
    
    /// Returns all the properties of the ZCRMRecord as dictionary.
    ///
    /// - Returns: all the properties of the ZCRMRecord
    public func getAllProperties() -> [String:Any?]
    {
        return self.properties
    }
    
    /// Add ZCRMInventoryLineItem to the ZCRMRecord
    ///
    /// - Parameter newLineItem: line item to be added
    public func addLineItem(newLineItem : ZCRMInventoryLineItem)
    {
        self.lineItems.append( newLineItem )
    }
    
    /// Returns all the ZCRMInventoryLineItem of the ZCRMRecord
    ///
    /// - Returns: All ZCRMInventoryLineItem of the ZCRMRecord
    public func getLineItems() -> [ZCRMInventoryLineItem]
    {
        return self.lineItems
    }
    
    /// Returns the API response of the ZCRMRecord creation.
    ///
    /// - Returns: API response of the ZCRMRecord creation
    /// - Throws: ZCRMSDKError if Entity ID of the record is not nil
    public func create() throws -> APIResponse
    {
        if(self.id != nil)
        {
            throw ZCRMSDKError.ProcessingError("Entity ID MUST be null for create operation.")
        }
        return try EntityAPIHandler(record: self).createRecord()
    }
    
    /// Returns the API response of the ZCRMRecord update.
    ///
    /// - Returns: API response of the ZCRMRecord update
    /// - Throws: ZCRMSDKError if Entity ID of the record is nil
    public func update() throws -> APIResponse
    {
        if(self.id == nil)
        {
            throw ZCRMSDKError.ProcessingError("Entity ID MUST NOT be null for update operation.")
        }
        return try EntityAPIHandler(record: self).updateRecord()
    }
    
    /// Returns the API response of the ZCRMRecord delete.
    ///
    /// - Returns: API response of the ZCRMRecord delete
    /// - Throws: ZCRMSDKError if Entity ID of the record is nil
    public func delete() throws -> APIResponse
    {
        if(self.id == nil)
        {
            throw ZCRMSDKError.ProcessingError("Entity ID MUST NOT be null for delete operation.")
        }
        return try EntityAPIHandler(record: self).deleteRecord()
    }
    
    /// Convert the ZCRMRecord(Leads to Contacts) and Returns dictionary containing deal, contact and account vs its ID of the converted ZCRMecord.
    ///
    /// - Returns: dictionary containing deal, contact and account vs its ID of the converted ZCRMRecord
    /// - Throws: ZCRMSDKError if the ZCRMRecord is not convertible
    public func convert() throws -> [String:Int64]
    {
        return try self.convert(newPotential: nil, assignTo: nil)
    }
    
    /// Convert the ZCRMRecord(Leads to Contacts and create new Potential) and Returns dictionary containing deal, contact and account vs its ID of the converted ZCRMRecord.
    ///
    /// - Parameter newPotential: New ZCRMRecord(Potential) to be created
    /// - Returns: dictionary containing deal, contact and account vs its ID of the converted ZCRMRecord
    /// - Throws: ZCRMSDKError if the ZCRMRecord is not convertible
    public func convert( newPotential : ZCRMRecord ) throws -> [ String : Int64 ]
    {
        return try self.convert( newPotential: newPotential, assignTo: nil)
    }
    
    /// Convert the ZCRMRecord(Leads to Contacts and create new Potential) with assignee and Returns map containing deal, contact and account vs its ID of the converted ZCRMRecord.
    ///
    /// - Parameters:
    ///   - newPotential: New ZCRMRecord(Potential) to be created
    ///   - assignTo: assignee for the converted ZCRMRecord
    /// - Returns: dictionary containing deal, contact and account vs its ID of the converted ZCRMRecord
    /// - Throws: ZCRMSDKError if the ZCRMRecord is not convertible
    public func convert(newPotential: ZCRMRecord!, assignTo: ZCRMUser!) throws -> [String:Int64]
    {
        return try EntityAPIHandler(record: self).convertRecord(newPotential: newPotential, assignTo: assignTo)
    }
    
    public func uploadPhoto( filePath : String ) throws -> APIResponse
    {
        return try EntityAPIHandler( record : self ).uploadPhoto( filePath : filePath )
    }
    
    public func downloadPhoto() throws -> FileAPIResponse
    {
        return try EntityAPIHandler(record: self).downloadPhoto()
    }
    
    public func deletePhoto() throws -> APIResponse
    {
        return try EntityAPIHandler( record : self ).deletePhoto()
    }
    
    /// Return related list records of the ZCRMRecord(BulkAPIResponse).
    ///
    /// - Parameter relatedListAPIName: related list name to be returned
    /// - Returns: records of the related list of the ZCRMRecord
    /// - Throws: ZCRMSDKError if failed to get related list of the ZCRMRecord
    public func getRelatedListRecords(relatedListAPIName : String) throws -> BulkAPIResponse
    {
        return try self.getRelatedListRecords(relatedListAPIName: relatedListAPIName, page: 1, per_page: 20)
    }
    
    /// Return related list records of the ZCRMRecord of a requested page number with records of per_page count(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - relatedListAPIName: related list name to be returned
    ///   - page: page number of the related list
    ///   - per_page: number of records to be given for a single page
    /// - Returns: related list records of the ZCRMRecord of a requested page number with records of per_page count
    /// - Throws: ZCRMSDKError if failed to get related list of the ZCRMRecord
    public func getRelatedListRecords(relatedListAPIName : String, page : Int, per_page : Int) throws -> BulkAPIResponse
    {
        return try self.getRelatedListRecords( relatedListAPIName : relatedListAPIName, sortByField : nil, sortOrder : nil, page : page, per_page : per_page, modifiedSince : nil )
    }
    
    /// related list records of the ZCRMRecord, before returning the list of records gets sorted with the given field and sort order(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - relatedListAPIName: related list name to be returned
    ///   - sortByField: field by which the records get sorted
    ///   - sortOrder: sort order (asc, desc)
    /// - Returns: sorted list records of the ZCRMRecord
    /// - Throws: ZCRMSDKError if failed to get related list of the ZCRMRecord
    public func getRelatedListRecords( relatedListAPIName : String, sortByField : String, sortOrder : SortOrder ) throws -> BulkAPIResponse
    {
        return try self.getRelatedListRecords( relatedListAPIName : relatedListAPIName, sortByField : sortByField, sortOrder : sortOrder, page : 1, per_page : 20, modifiedSince : nil )
    }
    
    /// related list records of the ZCRMRecord of a requested page number with records of per_page count, before returning the list of records gets sorted with the given field and sort order(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - relatedListAPIName: related list name to be returned
    ///   - sortByField: field by which the records get sorted
    ///   - sortOrder: sort order (asc, desc)
    ///   - page: page number of the related list
    ///   - per_page: number of records to be given for a single page
    ///   - modifiedSince: modified time
    /// - Returns: sorted list of records of the ZCRMRecord of a requested page number with records of per_page count
    /// - Throws: ZCRMSDKError if failed to get related list of the ZCRMRecord
    public func getRelatedListRecords( relatedListAPIName : String, sortByField : String?, sortOrder : SortOrder?, page : Int, per_page : Int, modifiedSince : String? ) throws -> BulkAPIResponse
    {
        return try ZCRMModuleRelation(relatedListAPIName: relatedListAPIName, parentModuleAPIName: self.getModuleAPIName()).getRelatedRecords( ofParentRecord : self, page : page, per_page : per_page, sortByField : sortByField, sortOrder : sortOrder, modifiedSince : modifiedSince )
    }
    
    /// To add a new Note to the ZCRMRecord
    ///
    /// - Parameter note: ZCRMNote to be added
    /// - Returns: APIResponse of the note addition
    /// - Throws: ZCRMSDKError if Note id is not nil
    public func addNote(note: ZCRMNote) throws -> APIResponse
    {
        if( note.getId() != nil )
        {
            throw ZCRMSDKError.ProcessingError( "Note ID must be nil for create operation." )
        }
        return try ZCRMModuleRelation(relatedListAPIName: "Notes", parentModuleAPIName: self.moduleAPIName).addNote(note: note, toRecord: self)
    }
    
    /// To update a Note of the ZCRMRecord
    ///
    /// - Parameter note: ZCRMNote to be updated
    /// - Returns: APIResponse of the note update
    /// - Throws: ZCRMSDKError if Note id is nil
    public func updateNote(note: ZCRMNote) throws -> APIResponse
    {
        if( note.getId() == nil )
        {
            throw ZCRMSDKError.ProcessingError( "Note ID must not be nil for update operation." )
        }
        return try ZCRMModuleRelation(relatedListAPIName: "Notes", parentModuleAPIName: self.moduleAPIName).updateNote(note: note, ofRecord: self)
    }
    
    /// To delete a Note of the ZCRMRecord
    ///
    /// - Parameter note: ZCRMNote to be deleted
    /// - Returns: APIResponse of the note deletion
    /// - Throws: ZCRMSDKError if Note id is nil
    public func deleteNote(note: ZCRMNote) throws -> APIResponse
    {
        if( note.getId() == nil )
        {
            throw ZCRMSDKError.ProcessingError( "Note ID must not be nil for delete operation." )
        }
        return try ZCRMModuleRelation(relatedListAPIName: "Notes", parentModuleAPIName: self.moduleAPIName).deleteNote(note: note, ofRecord: self)
    }
    
    /// Returns list of notes of the ZCRMRecord(BulkAPIResponse).
    ///
    /// - Returns: list of notes of the ZCRMRecord
    /// - Throws: ZCRMSDKError if failed to get notes of the ZCRMRecord
    public func getNotes() throws -> BulkAPIResponse
    {
        return try self.getNotes( page : 0, per_page : 20 )
    }
    
    /// Returns list of notes of the ZCRMRecord of a requested page number with notes of per_page count(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - page: page number of the notes
    ///   - per_page: number of notes to be given for a single page
    /// - Returns: list of notes of the ZCRMRecord of a requested page number with records of per_page count
    /// - Throws: ZCRMSDKError if failed to get notes of the ZCRMRecord
    public func getNotes( page : Int, per_page : Int ) throws -> BulkAPIResponse
    {
        return try self.getNotes( page : page, per_page : per_page, sortByField : nil, sortOrder : nil, modifiedSince : nil )
    }
    
    /// Returns list of notes of the ZCRMRecord, before returning the list of notes gets sorted with the given field and sort order(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - sortByField: field by which the notes get sorted
    ///   - sortOrder: sort order (asc, desc)
    /// - Returns: sorted list of notes of the ZCRMRecord
    /// - Throws: ZCRMSDKError if failed to get notes of the ZCRMRecord
    public func getNotes( sortByField : String, sortOrder : SortOrder ) throws -> BulkAPIResponse
    {
        return try self.getNotes( page : 0, per_page : 20, sortByField : sortByField, sortOrder : sortOrder, modifiedSince : nil )
    }
    
    /// Related list opf notes of the ZCRMRecord of a requested page number with notes of per_page count, before returning the list of notes gets sorted with the given field and sort order(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - page: page number of the notes
    ///   - per_page: number of notes to be given for a single page
    ///   - sortByField: field by which the notes get sorted
    ///   - sortOrder: sort order (asc, desc)
    ///   - modifiedSince: modified timesorted list of notes of the ZCRMRecord of a requested page number with records of per_page count
    /// - Returns: <#return value description#>
    /// - Throws: ZCRMSDKError if failed to get notes of the ZCRMRecord
    public func getNotes(page : Int, per_page : Int, sortByField : String?, sortOrder : SortOrder?, modifiedSince : String? ) throws -> BulkAPIResponse
    {
        return try ZCRMModuleRelation(relatedListAPIName: "Notes", parentModuleAPIName: self.getModuleAPIName()).getNotes(ofParentRecord: self, page: page, per_page: per_page, sortByField: sortByField, sortOrder: sortOrder, modifiedSince: modifiedSince )
    }
    
    /// To get list of all attachments of the ZCRMRecord(BulkAPIResponse).
    ///
    /// - Returns: list of all attachments of the ZCRMRecord
    /// - Throws: ZCRMSDKError if failed to get the list of attachments
    public func getAttachments() throws -> BulkAPIResponse
    {
        return try self.getAttachments(page: 0, per_page: 20, modifiedSince : nil )
    }
    
    /// To get list of all attachments of the ZCRMRecord of a requested page number with attachments of per_page count(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - page: page number of the attachments
    ///   - per_page: number of attachments to be given for a single page
    ///   - modifiedSince: modified time
    /// - Returns: list of all attachments of the ZCRMRecord of a requested page number with records of per_page count
    /// - Throws: ZCRMSDKError if failed to get the list of attachments
    public func getAttachments(page : Int, per_page : Int, modifiedSince : String?) throws -> BulkAPIResponse
    {
        return try ZCRMModuleRelation(relatedListAPIName: "Attachments", parentModuleAPIName: self.getModuleAPIName()).getAttachments(ofParentRecord: self, page: page, per_page: per_page, modifiedSince : modifiedSince)
    }
    
    /// To download a Attachment from the ZCRMRecord, it returns file as data, then it can be converted to a file.
    ///
    /// - Parameter attachmentId: Id of the attachment to be downloaded
    /// - Returns: FileAPIResponse containing the data of the file downloaded.
    /// - Throws: ZCRMSDKError if failed to download the attachment
    public func downloadAttachment(attachmentId: Int64) throws -> FileAPIResponse
    {
        return try ZCRMModuleRelation(relatedListAPIName: "Attachments", parentModuleAPIName: self.getModuleAPIName()).downloadAttachment(ofParentRecord: self, attachmentId: attachmentId)
    }
    
    public func deleteAttachment( attachmentId : Int64 ) throws -> APIResponse
    {
        return try ZCRMModuleRelation( relatedListAPIName : "Attachments", parentModuleAPIName : self.getModuleAPIName() ).deleteAttachment( ofParentRecord : self, attachmentId :  attachmentId )
    }
    
    /// To upload a Attachment to the ZCRMRecord.
    ///
    /// - Parameter filePath: file path of the attachment
    /// - Returns: APIResponse of the attachment upload
    /// - Throws: ZCRMSDKError if failed to upload the attachment
    public func uploadAttachment( filePath : String ) throws -> APIResponse
    {
        return try ZCRMModuleRelation( relatedListAPIName : "Attachments", parentModuleAPIName : self.getModuleAPIName() ).uploadAttachment( ofParentRecord : self, filePath : filePath )
    }
    
    /// To upload a Attachment from attachmentUrl to the ZCRMRecord.
    ///
    /// - Parameter attachmentURL: URL of the attachment
    /// - Returns: APIResponse of the attachment upload
    /// - Throws: ZCRMSDKError if failed to upload the attachment
    public func uploadLinkAsAttachment( attachmentURL : String ) throws -> APIResponse
    {
        return try ZCRMModuleRelation( relatedListAPIName : "Attachments", parentModuleAPIName : self.getModuleAPIName() ).uploadLinkAsAttachment( ofParentRecord : self, attachmentURL : attachmentURL )
    }
    
    /// Returns all the price details(ZCRMPriceBookPricing) of the ZCRMRecord.
    ///
    /// - Returns: list of price details(ZCRMPriceBookPricing) of the ZCRMRecord
    public func getPriceDetails() -> [ ZCRMPriceBookPricing ]
    {
        return self.priceDetails
    }
    
    /// Add ZCRMPriceBookPricing to the ZCRMRecord.
    ///
    /// - Parameter priceDetail: price detail to be added
    public func addPriceDetail( priceDetail : ZCRMPriceBookPricing )
    {
        self.priceDetails.append( priceDetail )
    }
    
    /// Returns all the participants of the ZCRMRecord
    ///
    /// - Returns: list of participants of the ZCRMRecord
    public func getParticipants() -> [ ZCRMEventParticipant ]
    {
        return self.participants
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
    public func addTax( tax : ZCRMTax )
    {
        self.tax[ tax.getTaxName() ] = tax
    }
    
    /// Returns all the ZCRMTax of the ZCRMRecord
    ///
    /// - Returns: list of ZCRMTax of the ZCRMRecord
    public func getTax() -> [ ZCRMTax ]
    {
        return Array( self.tax.values ) as! [ ZCRMTax ]
    }
    
    /// To add the association between ZCRMRecords.
    ///
    /// - Parameter junctionRecord: ZCRMJuctionRecord to assiciate with the ZCRMRecord
    /// - Returns: APIResponsed of added relation
    /// - Throws: ZCRMError if failed to add relation
    public func addRelation( junctionRecord : ZCRMJunctionRecord ) throws -> APIResponse
    {
        return try ZCRMModuleRelation( parentRecord : self, junctionRecord : junctionRecord ).addRelation()
    }
    
    /// To delete the association between ZCRMRecords.
    ///
    /// - Parameter junctionRecord: ZCRMJunctionRecord to be delete.
    /// - Returns: APIResponse of the delete relation
    /// - Throws: ZCRMError if failed to delete the relation
    public func deleteRelation( junctionRecord : ZCRMJunctionRecord ) throws -> APIResponse
    {
        return try ZCRMModuleRelation( parentRecord : self, junctionRecord : junctionRecord ).deleteRelation()
    }
    
    /// Returns cloned ZCRMRecord
    ///
    /// - Returns: cloned ZCRMRecord
    /// - Throws: ZCRMError if falied to clone ZCRMRecord
    public func clone() throws -> ZCRMRecord
    {
        let cloneRecord = self
        cloneRecord.setId( recordId : nil )
        cloneRecord.setProperties( properties : [ String : Any? ]() )
        return cloneRecord
    }
}

