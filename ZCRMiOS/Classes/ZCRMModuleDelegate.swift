//
//  ZCRMModuleDelegate.swift
//  Pods-ZCRMiOS_Tests
//
//  Created by Boopathy P on 15/09/18.
//

import Foundation

open class ZCRMModuleDelegate : ZCRMEntity
{
    public var apiName : String
    
    init( apiName : String )
    {
        self.apiName = apiName
    }
    
    public func newRecord() -> ZCRMRecord
    {
        return ZCRMRecord( moduleAPIName : apiName )
    }
    
    public func getRecordDelegate( id : Int64 ) -> ZCRMRecordDelegate
    {
        return ZCRMRecordDelegate( id : id, moduleAPIName : apiName )
    }

    public func newSubFormRecord( subFormName : String ) -> ZCRMSubformRecord
    {
        return ZCRMSubformRecord( name : subFormName )
    }
    
    public func newTag( name : String ) -> ZCRMTag
    {
        let tag = ZCRMTag( name : name, moduleAPIName : self.apiName )
        tag.isCreate = true
        return tag
    }
    
    /// Returns related list to the module.
    ///
    /// - Returns: related list to the module.
    public func getRelatedLists( completion : @escaping( Result.DataResponse< [ ZCRMModuleRelation ], BulkAPIResponse > ) -> () )
    {
        ModuleAPIHandler( module : self, cacheFlavour : .urlVsResponse ).getAllRelatedLists { ( result ) in
            completion( result )
        }
    }
    
    public func getRelatedListsFromServer( completion : @escaping( Result.DataResponse< [ ZCRMModuleRelation ], BulkAPIResponse > ) -> () )
    {
        ModuleAPIHandler( module : self, cacheFlavour : .noCache ).getAllRelatedLists { ( result ) in
            completion( result )
        }
    }
    
    public func getRelatedList( id : Int64, completion : @escaping( Result.DataResponse< ZCRMModuleRelation, APIResponse > ) -> () )
    {
        ModuleAPIHandler( module: self, cacheFlavour: .urlVsResponse ).getRelatedList(id: id) { ( result ) in
            completion( result )
        }
    }
    
    public func getRelatedListFromServer( id : Int64, completion : @escaping( Result.DataResponse< ZCRMModuleRelation, APIResponse > ) -> () )
    {
        ModuleAPIHandler( module: self, cacheFlavour: .noCache ).getRelatedList(id: id) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns all the layouts of the module(BulkAPIResponse).
    ///
    /// - Returns: all the layouts of the module
    /// - Throws: ZCRMSDKError if failed to get all layouts
    public func getLayouts( completion : @escaping( Result.DataResponse< [ ZCRMLayout ], BulkAPIResponse > ) -> () )
    {
        ModuleAPIHandler(module: self, cacheFlavour: .urlVsResponse).getAllLayouts( modifiedSince : nil) { ( result ) in
            completion( result )
        }
    }
    
    public func getLayoutsFromServer( completion : @escaping( Result.DataResponse< [ ZCRMLayout ], BulkAPIResponse > ) -> () )
    {
        ModuleAPIHandler(module: self, cacheFlavour: .noCache).getAllLayouts( modifiedSince : nil) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns a layout with given layout id
    ///
    /// - Parameter layoutId: layout id
    /// - Returns: layout with given layout id
    /// - Throws: ZCRMSDKError if failed to get a layout
    public func getLayout( id : Int64, completion : @escaping( Result.DataResponse< ZCRMLayout, APIResponse > ) -> () )
    {
        ModuleAPIHandler( module : self, cacheFlavour : .urlVsResponse ).getLayout( layoutId : id ) { ( result ) in
            completion( result )
        }
    }
    
    public func getLayoutFromServer( id : Int64, completion : @escaping( Result.DataResponse< ZCRMLayout, APIResponse > ) -> () )
    {
        ModuleAPIHandler( module : self, cacheFlavour : .noCache ).getLayout( layoutId : id ) { ( result ) in
            completion( result )
        }
    }
    
    ///  Returns list of ZCRMFields of the module(BulkAPIResponse).
    ///
    /// - Returns: list of ZCRMFields of the module
    /// - Throws: ZCRMSDKError if failed to get all fields
    public func getFields( completion : @escaping( Result.DataResponse< [ ZCRMField ], BulkAPIResponse > ) -> () )
    {
        ModuleAPIHandler( module : self, cacheFlavour : .urlVsResponse ).getAllFields( modifiedSince : nil ) { ( result ) in
            completion( result )
        }
    }
    
    public func getFieldsFromServer( completion : @escaping( Result.DataResponse< [ ZCRMField ], BulkAPIResponse > ) -> () )
    {
        ModuleAPIHandler( module : self, cacheFlavour : .noCache ).getAllFields( modifiedSince : nil ) { ( result ) in
            completion( result )
        }
    }
    
    public func getField( id : Int64, completion : @escaping( Result.DataResponse< ZCRMField, APIResponse > ) -> () )
    {
        ModuleAPIHandler(module: self, cacheFlavour: .urlVsResponse).getField(fieldId: id) { ( result ) in
            completion( result )
        }
    }
    
    public func getFieldFromServer( id : Int64, completion : @escaping( Result.DataResponse< ZCRMField, APIResponse > ) -> () )
    {
        ModuleAPIHandler(module: self, cacheFlavour: .noCache).getField(fieldId: id) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns the custom views of the module(BulkAPIResponse).
    ///
    /// - Returns: custom views of the module
    /// - Throws: ZCRMSDKError if failed to get the custom views
    public func getCustomViews( completion : @escaping( Result.DataResponse< [ ZCRMCustomView ], BulkAPIResponse > ) -> () )
    {
        ModuleAPIHandler(module: self, cacheFlavour: .urlVsResponse).getAllCustomViews( modifiedSince : nil) { ( result ) in
            completion( result )
        }
    }
    
    public func getCustomViewsFromServer( completion : @escaping( Result.DataResponse< [ ZCRMCustomView ], BulkAPIResponse > ) -> () )
    {
        ModuleAPIHandler(module: self, cacheFlavour: .noCache).getAllCustomViews( modifiedSince : nil) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns custom view with the given cvID of the module(APIResponse).
    ///
    /// - Parameter cvId: Id of the custom view to be returned
    /// - Returns: custom view with the given cvID of the module
    /// - Throws: ZCRMSDKError if failed to get the custom view
    public func getCustomView( id : Int64, completion : @escaping( Result.DataResponse< ZCRMCustomView, APIResponse > ) -> () )
    {
        ModuleAPIHandler( module : self, cacheFlavour : .urlVsResponse ).getCustomView( cvId : id ) { ( result ) in
            completion( result )
        }
    }
    
    public func getCustomViewFromServer( id : Int64, completion : @escaping( Result.DataResponse< ZCRMCustomView, APIResponse > ) -> () )
    {
        ModuleAPIHandler( module : self, cacheFlavour : .noCache ).getCustomView( cvId : id ) { ( result ) in
            completion( result )
        }
    }
    
    public func getActivitiesCVs( completion: @escaping( Result.DataResponse< [ ZCRMCustomView ], BulkAPIResponse > ) -> () )
    {
        do
        {
            try  activitiesCVModuleCheck(module: self.apiName)
            ModuleAPIHandler(module: self, cacheFlavour: .urlVsResponse).getActivitiesCVs { ( result ) in
                completion( result )
            }
        }
        catch
        {
            completion( .failure( typeCastToZCRMError( error ) ) )
        }
    }
    
    public func getActivitiesCVsFromServer( completion: @escaping( Result.DataResponse< [ ZCRMCustomView ], BulkAPIResponse > ) -> () )
    {
        do
        {
            try  activitiesCVModuleCheck(module: self.apiName)
            ModuleAPIHandler(module: self, cacheFlavour: .noCache).getActivitiesCVs { ( result ) in
                completion( result )
            }
        }
        catch
        {
            completion( .failure( typeCastToZCRMError( error ) ) )
        }
    }
    
    /// Returns ZCRMRecord with the given ID of the module(APIResponse).
    ///
    /// - Parameter recordId: Id of the record to be returned
    /// - Returns: ZCRMRecord with the given ID of the module
    /// - Throws: ZCRMSDKError if failed to get the record
    public func getRecord( id : Int64, completion : @escaping( Result.DataResponse< ZCRMRecord, APIResponse > ) -> () )
    {
        EntityAPIHandler( recordDelegate : ZCRMRecordDelegate( id : id, moduleAPIName : self.apiName ) ).getRecord( withPrivateFields : false, completion : { ( result ) in
            completion( result )
        } )
    }
    
    public func getRecordWithPrivateFields( id : Int64, completion : @escaping( Result.DataResponse< ZCRMRecord, APIResponse > ) -> () )
    {
        EntityAPIHandler( recordDelegate : ZCRMRecordDelegate( id : id, moduleAPIName : self.apiName ) ).getRecord( withPrivateFields : true, completion : { ( result ) in
            completion( result )
        } )
    }
    
    public func getRecords( recordParams : ZCRMQuery.GetRecordParams, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).getRecords( cvId : nil, filterId : nil, recordParams : recordParams ) { ( result ) in
            completion( result )
        }
    }
    
    public func getRecords( cvId : Int64, recordParams : ZCRMQuery.GetRecordParams, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).getRecords( cvId : cvId, filterId : nil, recordParams : recordParams ) { ( result ) in
            completion( result )
        }
    }
    
    public func getRecords( cvId : Int64, filterId : Int64, recordParams : ZCRMQuery.GetRecordParams, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).getRecords( cvId : cvId, filterId : filterId, recordParams : recordParams ) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns List of all deleted records of the module(BulkAPIResponse).
    ///
    /// - Returns: List of all deleted records of the module
    /// - Throws: ZCRMSDKError if failed to get the records
    public func getDeletedRecords( completion : @escaping( Result.DataResponse< [ ZCRMTrashRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).getDeletedRecords( modifiedSince : nil, page : nil, perPage : nil ) { ( result ) in
            completion( result )
        }
    }
    
    public func getDeletedRecords( modifiedSince : String, completion : @escaping( Result.DataResponse< [ ZCRMTrashRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).getDeletedRecords( modifiedSince : modifiedSince, page : nil, perPage : nil ) { ( result ) in
            completion( result )
        }
    }
    
    public func getDeletedRecords( page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMTrashRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).getDeletedRecords(modifiedSince: nil, page: page, perPage: perPage) { ( result ) in
            completion( result )
        }
    }
    
    public func getDeletedRecords( modifiedSince : String, page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMTrashRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).getDeletedRecords(modifiedSince: modifiedSince, page: page, perPage: perPage) { ( result ) in
            completion( result )
        }
    }
    
    
    /// Returns List of recycle bin records of the module(BulkAPIResponse).
    ///
    /// - Returns: List of recycle bin records of the module
    /// - Throws: ZCRMSDKError if failed to get the records
    public func getRecycleBinRecords( completion : @escaping( Result.DataResponse< [ ZCRMTrashRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).getRecycleBinRecords( modifiedSince : nil, page : nil, perPage : nil ) { ( result ) in
            completion( result )
        }
    }
    
    public func getRecycleBinRecords( modifiedSince : String, completion : @escaping( Result.DataResponse< [ ZCRMTrashRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).getRecycleBinRecords( modifiedSince : modifiedSince, page : nil, perPage : nil ) { ( result ) in
            completion( result )
        }
    }
    
    public func getRecycleBinRecords( page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMTrashRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).getRecycleBinRecords(modifiedSince: nil, page: page, perPage: perPage) { ( result ) in
            completion( result )
        }
    }
    
    public func getRecycleBinRecords( modifiedSince : String, page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMTrashRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).getRecycleBinRecords(modifiedSince: modifiedSince, page: page, perPage: perPage) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns List of permanently deleted records of the module(BulkAPIResponse).
    ///
    /// - Returns: List of permanently records of the module
    /// - Throws: ZCRMSDKError if failed to get the records
    public func getPermanentlyDeletedRecords( completion : @escaping( Result.DataResponse< [ ZCRMTrashRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).getPermanentlyDeletedRecords( modifiedSince : nil, page : nil, perPage : nil ) { ( result ) in
            completion( result )
        }
    }
    
    public func getPermanentlyDeletedRecords( modifiedSince : String, completion : @escaping( Result.DataResponse< [ ZCRMTrashRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).getPermanentlyDeletedRecords( modifiedSince : modifiedSince, page : nil, perPage : nil ) { ( result ) in
            completion( result )
        }
    }
    
    public func getPermanentlyDeletedRecords( page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMTrashRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).getPermanentlyDeletedRecords(modifiedSince: nil, page: page, perPage: perPage) { ( result ) in
            completion( result )
        }
    }
    
    public func getPermanentlyDeletedRecords( modifiedSince : String, page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMTrashRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).getPermanentlyDeletedRecords(modifiedSince: modifiedSince, page: page, perPage: perPage) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns list of records which contains the given search text as substring(BulkAPIResponse).
    ///
    /// - Parameter text: text to be searched
    /// - Returns: list of records which contains the given search text as substring
    /// - Throws: ZCRMSDKError if failed to get the records
    public func searchBy( text : String, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).searchByText( searchText : text, page : nil, perPage : nil ) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns list of records of the module which contains the given search text as substring, with requested page number with records of per_page count(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - text: text to be searched
    ///   - page: page number of the module
    ///   - per_page: number of records to be given for a single page.
    /// - Returns: list of records of the module which contains the given search text as substring, with requested page number with records of per_page count
    /// - Throws: ZCRMSDKError if failed to get the records
    public func searchBy( text : String, page : Int, per_page : Int, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).searchByText( searchText : text, page : page, perPage : per_page ) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns list of records which satisfies the given criteria(BulkAPIResponse).
    ///
    /// - Parameter criteria: criteria to be searched
    /// - Returns: list of records which satisfies the given criteria
    /// - Throws: ZCRMSDKError if failed to get the records
    public func searchBy( criteria : ZCRMQuery.ZCRMCriteria, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).searchByCriteria( searchCriteria : criteria, page : nil, perPage : nil ) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns list of records of the module which satisfies the given criteria, with requested page number with records of per_page count(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - criteria: criteria to be searched
    ///   - page: page number of the module
    ///   - perPage: number of records to be given for a single page
    /// - Returns: list of records of the module which satisfies the given criteria, with requested page number with records of per_page count
    /// - Throws: ZCRMSDKError if failed to get the records
    public func searchBy( criteria : ZCRMQuery.ZCRMCriteria, page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).searchByCriteria( searchCriteria : criteria, page : page, perPage : perPage) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns list of records of the module which satisfies the given value(BulkAPIResponse).
    ///
    /// - Parameter phone: Phone number to be searched
    /// - Returns: list of records of the module which satisfies the given value
    /// - Throws: ZCRMSDKError if failed to get the records
    public func searchBy( phone : String, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).searchByPhone( searchValue : phone, page : nil, perPage : nil ) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns list of records of the module which satisfies the given value, with requested page number with records of per_page count(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - phone: Phone number to be searched
    ///   - page: page number of the module
    ///   - perPage: number of records to be given for a single page
    /// - Returns: list of records of the module which satisfies the given value, with requested page number with records of per_page count
    /// - Throws: ZCRMSDKError if failed to get the records
    public func searchBy( phone : String, page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).searchByPhone( searchValue : phone, page : page, perPage : perPage) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns list of records of the module which satisfies the given value(BulkAPIResponse).
    ///
    /// - Parameter email: email to be searched
    /// - Returns: list of records of the module which satisfies the given value
    /// - Throws: ZCRMSDKError if failed to get the records
    public func searchBy( email : String, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).searchByEmail( searchValue : email, page : nil, perPage : nil ) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns list of records of the module which satisfies the given value, with requested page number with records of per_page count(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - email: email to be searched
    ///   - page: page number of the module
    ///   - perPage: number of records to be given for a single page
    /// - Returns: list of records of the module which satisfies the given value, with requested page number with records of per_page count
    /// - Throws: ZCRMSDKError if failed to get the records
    public func searchBy( email : String, page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).searchByEmail( searchValue : email, page : page, perPage : perPage) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns the mass create results of the set of records of the module(BulkAPIResponse).
    ///
    /// - Parameter records: list of ZCRMRecord objects to be created
    /// - Returns: mass create response of the records
    /// - Throws: ZCRMSDKError if failed to create records
    public func createRecords(records: [ZCRMRecord], completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> ())
    {
        MassEntityAPIHandler(module: self).createRecords( triggers: nil, records: records) { ( result ) in
            completion( result )
        }
    }
    
    public func createRecords(triggers : [Trigger], records: [ZCRMRecord], completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> ())
    {
        MassEntityAPIHandler(module: self).createRecords( triggers: triggers, records: records) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns the mass update results of the set of records of the module(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - recordIds: id's of the record to be updated
    ///   - fieldAPIName: fieldAPIName to which the field value is updated
    ///   - value: field value to be updated
    /// - Returns: mass update response of the records
    /// - Throws: ZCRMSDKError if failed to update records
    public func updateRecords(recordIds: [Int64], fieldAPIName: String, value: Any?, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> ())
    {
        MassEntityAPIHandler(module: self).updateRecords( triggers: nil, ids: recordIds, fieldAPIName: fieldAPIName, value: value) { ( result ) in
            completion( result )
        }
    }
    
    public func updateRecords(triggers : [Trigger], recordIds: [Int64], fieldAPIName: String, value: Any?, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> ())
    {
        MassEntityAPIHandler(module: self).updateRecords( triggers : triggers, ids: recordIds, fieldAPIName: fieldAPIName, value: value) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns the upsert results of the set of records of the module(BulkAPIResponse).
    ///
    /// - Parameter records: list of ZCRMRecord objects to be upserted
    /// - Returns: upsert response of the records
    /// - Throws: ZCRMSDKError if failed to upsert records
    public func upsertRecords( records : [ ZCRMRecord ], completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).upsertRecords( triggers: nil, records : records) { ( result ) in
            completion( result )
        }
    }
    
    public func upsertRecords( triggers : [Trigger],  records : [ ZCRMRecord ], completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).upsertRecords( triggers: triggers, records : records) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns the mass delete results of the set of records of the module(BulkAPIResponse).
    ///
    /// - Parameter recordIds: id's of the record to be deleted
    /// - Returns: mass delete response of the record
    /// - Throws: ZCRMSDKError if failed to delete records
    public func deleteRecords(recordIds: [Int64], completion : @escaping( Result.Response< BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler(module: self).deleteRecords( ids : recordIds) { ( result ) in
            completion( result )
        }
    }
    
    public func getTags( completion : @escaping ( Result.DataResponse< [ ZCRMTag ], BulkAPIResponse > ) -> () )
    {
        TagAPIHandler(module: self).getTags(completion: { ( result ) in
            completion( result )
        } )
    }
    
    public func createTags( tags : [ZCRMTag], completion : @escaping ( Result.DataResponse< [ ZCRMTag ], BulkAPIResponse > ) -> () )
    {
        for tag in tags
        {
            if !tag.isCreate
            {
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.invalidData) : TAG ID should be nil, \( APIConstants.DETAILS ) : -")
                completion( .failure( ZCRMError.inValidError( code : ErrorCode.invalidData, message : "TAG ID should be nil", details : nil ) ) )
                return
            }
        }
        TagAPIHandler(module: self).createTags(tags: tags, completion: { ( result ) in
            completion( result )
        } )
    }
    
    public func updateTags(tags : [ZCRMTag], completion : @escaping ( Result.DataResponse< [ ZCRMTag ], BulkAPIResponse > ) -> () )
    {
        for tag in tags
        {
            if tag.isCreate
            {
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.invalidData) : TAG ID and NAME should be nil, \( APIConstants.DETAILS ) : -")
                completion( .failure( ZCRMError.inValidError( code : ErrorCode.invalidData, message : "TAG ID and NAME must not be nil", details : nil ) ) )
                return
            }
        }
        TagAPIHandler(module: self).updateTags(tags: tags, completion: { ( result ) in
            completion( result )
        } )
    }
    
    public func addTags( records : [ ZCRMRecord ], tags : [ String ], completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).addTags( records : records, tags : tags, overWrite : nil ) { ( result ) in
            completion( result )
        }
    }
    
    public func addTags( records : [ ZCRMRecord ], tags : [ String ], overWrite : Bool?, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).addTags( records : records, tags : tags, overWrite : overWrite ) { ( result ) in
            completion( result )
        }
    }
    
    public func removeTags( records : [ ZCRMRecord ], tags : [ String ], completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).removeTags( records : records, tags : tags ) { ( result ) in
            completion( result )
        }
    }
    
    public func rescheduleCalls( records : [ ZCRMRecord ], completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        do
        {
            try callsModuleCheck(module: self.apiName)
            MassEntityAPIHandler(module: self).rescheduleCalls(records: records, triggers: nil) { ( result ) in
                completion( result )
            }
        }
        catch
        {
            completion( .failure( typeCastToZCRMError( error ) ) )
        }
    }
    
    public func rescheduleCalls( records : [ ZCRMRecord ], triggers : [Trigger], completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        do
        {
            try callsModuleCheck(module: self.apiName)
            MassEntityAPIHandler(module: self).rescheduleCalls(records: records, triggers: triggers) { ( result ) in
                completion( result )
            }
        }
        catch
        {
            completion( .failure( typeCastToZCRMError( error ) ) )
        }
    }
    
    public func cancelCalls( records : [ ZCRMRecord ], completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        do
        {
            try callsModuleCheck(module: self.apiName)
            MassEntityAPIHandler(module: self).cancelCalls(records: records, triggers: nil) { ( result ) in
                completion( result )
            }
        }
        catch
        {
            completion( .failure( typeCastToZCRMError( error ) ) )
        }
    }
    
    public func cancelCalls( records : [ ZCRMRecord ], triggers : [ Trigger ], completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        do
        {
            try callsModuleCheck(module: self.apiName)
            MassEntityAPIHandler(module: self).cancelCalls(records: records, triggers: triggers) { ( result ) in
                completion( result )
            }
        }
        catch
        {
            completion( .failure( typeCastToZCRMError( error ) ) )
        }
    }
}

extension ZCRMModuleDelegate : Equatable
{
    public static func == (lhs: ZCRMModuleDelegate, rhs: ZCRMModuleDelegate) -> Bool {
        let equals : Bool = lhs.apiName == rhs.apiName
        return equals
    }
}
