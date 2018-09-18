//
//  ZCRMModuleDelegate.swift
//  Pods-ZCRMiOS_Tests
//
//  Created by Boopathy P on 15/09/18.
//

import Foundation

open class ZCRMModuleDelegate : ZCRMEntity
{
    var apiName : String
    
    init( apiName : String )
    {
        self.apiName = apiName
    }
    
    func newRecord() -> ZCRMRecord
    {
        return ZCRMRecord( moduleAPIName : apiName )
    }
    
    func getRecordDelegate( id : Int64 ) -> ZCRMRecordDelegate
    {
        return ZCRMRecordDelegate( recordId : id, moduleAPIName : apiName )
    }
    
    func newSubFormRecord( subFormName : String ) -> ZCRMSubformRecord
    {
        return ZCRMSubformRecord( apiName : subFormName )
    }
    
    /// Returns related list to the module.
    ///
    /// - Returns: related list to the module.
    public func getAllRelatedLists( completion : @escaping( Result.DataResponse< [ ZCRMModuleRelation ], BulkAPIResponse > ) -> () )
    {
        ModuleAPIHandler( module : self ).getAllRelatedLists { ( result ) in
            completion( result )
        }
    }
    
    /// Returns all the layouts of the module(BulkAPIResponse).
    ///
    /// - Returns: all the layouts of the module
    /// - Throws: ZCRMSDKError if failed to get all layouts
    public func getAllLayouts( completion : @escaping( Result.DataResponse< [ ZCRMLayout ], BulkAPIResponse > ) -> () )
    {
        ModuleAPIHandler(module: self).getAllLayouts( modifiedSince : nil) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns all the layouts of the module with the given modified since time(BulkAPIResponse).
    ///
    /// - Parameter modifiedSince: modified time
    /// - Returns: all the layouts of the module with the given modified since time
    /// - Throws: ZCRMSDKError if failed to get all layouts
    public func getAllLayouts( modifiedSince : String, completion : @escaping( Result.DataResponse< [ ZCRMLayout ], BulkAPIResponse > ) -> () )
    {
        ModuleAPIHandler(module: self).getAllLayouts( modifiedSince : modifiedSince) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns a layout with given layout id
    ///
    /// - Parameter layoutId: layout id
    /// - Returns: layout with given layout id
    /// - Throws: ZCRMSDKError if failed to get a layout
    public func getLayout( layoutId : Int64, completion : @escaping( Result.DataResponse< ZCRMLayout, APIResponse > ) -> () )
    {
        ModuleAPIHandler( module : self ).getLayout( layoutId : layoutId) { ( result ) in
            completion( result )
        }
    }
    
    public func getAllFields( completion : @escaping( Result.DataResponse< [ ZCRMField ], BulkAPIResponse > ) -> () )
    {
        ModuleAPIHandler( module : self ).getAllFields( modifiedSince : nil) { ( result ) in
            completion( result )
        }
    }
    
    ///  Returns list of ZCRMFields of the module(BulkAPIResponse).
    ///
    /// - Parameter modifiedSince: modified time
    /// - Returns: list of ZCRMFields of the module
    /// - Throws: ZCRMSDKError if failed to get all fields
    public func getAllFields( modifiedSince : String, completion : @escaping( Result.DataResponse< [ ZCRMField ], BulkAPIResponse > ) -> () )
    {
        ModuleAPIHandler( module : self ).getAllFields( modifiedSince : modifiedSince) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns the custom views of the module(BulkAPIResponse).
    ///
    /// - Returns: custom views of the module
    /// - Throws: ZCRMSDKError if failed to get the custom views
    public func getAllCustomViews( completion : @escaping( Result.DataResponse< [ ZCRMCustomView ], BulkAPIResponse > ) -> () )
    {
        ModuleAPIHandler(module: self).getAllCustomViews( modifiedSince : nil) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns the custom views of the module(BulkAPIResponse) modified after the given time.
    ///
    /// - Parameter modifiedSince: modified time
    /// - Returns: custom views of the module
    /// - Throws: ZCRMSDKError if failed to get the custom views
    public func getAllCustomViews( modifiedSince : String, completion : @escaping( Result.DataResponse< [ ZCRMCustomView ], BulkAPIResponse > ) -> () )
    {
        ModuleAPIHandler(module: self).getAllCustomViews( modifiedSince : modifiedSince ) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns custom view with the given cvID of the module(APIResponse).
    ///
    /// - Parameter cvId: Id of the custom view to be returned
    /// - Returns: custom view with the given cvID of the module
    /// - Throws: ZCRMSDKError if failed to get the custom view
    public func getCustomView( cvId : Int64, completion : @escaping( Result.DataResponse< ZCRMCustomView, APIResponse > ) -> () )
    {
        ModuleAPIHandler( module : self ).getCustomView( cvId : cvId) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns ZCRMRecord with the given ID of the module(APIResponse).
    ///
    /// - Parameter recordId: Id of the record to be returned
    /// - Returns: ZCRMRecord with the given ID of the module
    /// - Throws: ZCRMSDKError if failed to get the record
    public func getRecord( recordId : Int64, completion : @escaping( Result.DataResponse< ZCRMRecord, APIResponse > ) -> () )
    {
        let record : ZCRMRecordDelegate = ZCRMRecordDelegate(recordId: recordId, moduleAPIName: self.apiName )
        EntityAPIHandler(recordDelegate: record).getRecord( withPrivateFields : false, completion : { ( result ) in
            completion( result )
        } )
    }
    
    public func getRecordWithPrivateFields( recordId : Int64, completion : @escaping( Result.DataResponse< ZCRMRecord, APIResponse > ) -> () )
    {
        let record : ZCRMRecordDelegate = ZCRMRecordDelegate(recordId: recordId, moduleAPIName: self.apiName)
        EntityAPIHandler(recordDelegate: record).getRecord( withPrivateFields : true, completion : { ( result ) in
            completion( result )
        } )
    }
    
    /// Returns List of all records of the module(BulkAPIResponse).
    ///
    /// - Returns: List of all records of the module
    /// - Throws: ZCRMSDKError if failed to get the records
    public func getRecords( completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler(module: self).getRecords( cvId : nil, fields : nil , sortByField : nil, sortOrder : nil, converted : nil , approved : nil, page : 1, per_page : 100, modifiedSince : nil, includePrivateFields : false, kanbanView : nil, completion : { ( result ) in
            completion( result )
        } )
    }
    
    public func getRecordsWithPrivateFields( completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler(module: self).getRecords( cvId : nil, fields : nil , sortByField : nil, sortOrder : nil, converted : nil , approved : nil, page : 1, per_page : 100, modifiedSince : nil, includePrivateFields : true, kanbanView : nil, completion : { ( result ) in
            completion( result )
        } )
    }
    
    /// Returns list of all records of the module of a requested page number with records of per_page count(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - page: page number of the module
    ///   - per_page: number of records to be given for a single page.
    /// - Returns: list of all records of the module of a requested page number with records of per_page count
    /// - Throws: ZCRMSDKError if failed to get the records
    public func getRecords(page : Int, per_page : Int, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> ())
    {
        MassEntityAPIHandler(module: self).getRecords( cvId : nil, fields : nil , sortByField : nil, sortOrder : nil, converted : nil , approved : nil, page : page, per_page : per_page, modifiedSince : nil, includePrivateFields : false, kanbanView : nil, completion : { ( result ) in
            completion( result )
        } )
    }
    
    public func getRecordsWithPrivateFields(page : Int, per_page : Int, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> ())
    {
        MassEntityAPIHandler(module: self).getRecords( cvId : nil, fields : nil , sortByField : nil, sortOrder : nil, converted : nil , approved : nil, page : page, per_page : per_page, modifiedSince : nil, includePrivateFields : true, kanbanView : nil, completion : { ( result ) in
            completion( result )
        } )
    }
    
    public func getRecords( sortByField : String, sortOrder : SortOrder, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler(module: self).getRecords(cvId: nil, fields: nil, sortByField: sortByField, sortOrder: sortOrder, converted: nil, approved: nil, page: 1, per_page: 100, modifiedSince: nil, includePrivateFields: false, kanbanView: nil) { ( result ) in
            completion( result )
        }
    }
    
    public func getRecordsWithPrivateFields( sortByField : String, sortOrder : SortOrder, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler(module: self).getRecords(cvId: nil, fields: nil, sortByField: sortByField, sortOrder: sortOrder, converted: nil, approved: nil, page: 1, per_page: 100, modifiedSince: nil, includePrivateFields: true, kanbanView: nil) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns List of all records of the module with the given cvID(BulkAPIResponse).
    ///
    /// - Parameter cvId: custom view ID
    /// - Returns: List of all records of the module with the given cvID
    /// - Throws: ZCRMSDKError if failed to get the records
    public func getRecords(cvId : Int64, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler(module: self).getRecords( cvId : cvId, fields : nil , sortByField : nil, sortOrder : nil, converted : nil , approved : nil, page : 1, per_page : 100, modifiedSince : nil, includePrivateFields : false, kanbanView : nil, completion : { ( result ) in
            completion( result )
        } )
    }
    
    public func getRecordsWithPrivateFields(cvId : Int64, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler(module: self).getRecords( cvId : cvId, fields : nil , sortByField : nil, sortOrder : nil, converted : nil , approved : nil, page : 1, per_page : 100, modifiedSince : nil, includePrivateFields : true, kanbanView : nil, completion : { ( result ) in
            completion( result )
        } )
    }
    
    /// Returns list of all records of the module of a requested page number with records of per_page count(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - cvId: custom view ID
    ///   - page: page number of the module
    ///   - per_page: number of records to be given for a single page.
    /// - Returns: list of all records of the module of a requested page number with records of per_page count
    /// - Throws: ZCRMSDKError if failed to get the records
    public func getRecords(cvId : Int64, page : Int, per_page : Int, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> ())
    {
        MassEntityAPIHandler(module: self).getRecords( cvId : cvId, fields : nil , sortByField : nil, sortOrder : nil, converted : nil , approved : nil, page : page, per_page : per_page, modifiedSince : nil, includePrivateFields : false, kanbanView : nil, completion : { ( result ) in
            completion( result )
        } )
    }
    
    public func getRecordsWithPrivateFields(cvId : Int64, page : Int, per_page : Int, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> ())
    {
        MassEntityAPIHandler(module: self).getRecords( cvId : cvId, fields : nil , sortByField : nil, sortOrder : nil, converted : nil , approved : nil, page : page, per_page : per_page, modifiedSince : nil, includePrivateFields : true, kanbanView : nil, completion : { ( result ) in
            completion( result )
        } )
    }
    
    /// Returns list of all records of the module, before returning the list of records gets sorted with the given field and sort order(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - cvId: custom view ID
    ///   - sortByField: field by which the records get sorted
    ///   - sortOrder: sort order (asc, desc)
    /// - Returns: sorted list of records of the module
    /// - Throws: ZCRMSDKError if failed to get the records
    public func getRecords(cvId : Int64, sortByField : String, sortOrder : SortOrder, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> ())
    {
        MassEntityAPIHandler(module: self).getRecords( cvId : cvId, fields : nil , sortByField : sortByField, sortOrder : sortOrder, converted : nil , approved : nil, page : 1, per_page : 100, modifiedSince : nil, includePrivateFields : false, kanbanView : nil, completion : { ( result ) in
            completion( result )
        } )
    }
    
    public func getRecordsWithPrivateFields(cvId : Int64, sortByField : String, sortOrder : SortOrder, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> ())
    {
        MassEntityAPIHandler(module: self).getRecords( cvId : cvId, fields : nil , sortByField : sortByField, sortOrder : sortOrder, converted : nil , approved : nil, page : 1, per_page : 100, modifiedSince : nil, includePrivateFields : true, kanbanView : nil, completion : { ( result ) in
            completion( result )
        } )
    }
    
    /// Returns list of all records of the module of a requested page number with records of per_page count, before returning the list of records gets sorted with the given field and sort order(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - cvId: custom view ID
    ///   - sortByField: field by which the records get sorted
    ///   - sortOrder: sort order (asc, desc)
    ///   - page: page number of the module
    ///   - per_page: page number of the module
    ///   - modifiedSince: modified time
    /// - Returns: sorted list of records of the module of a requested page number with records of per_page count
    /// - Throws: ZCRMSDKError if failed to get the records
    public func getRecords(cvId : Int64, sortByField : String, sortOrder : SortOrder, page : Int, per_page : Int, modifiedSince : String, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler(module: self).getRecords( cvId : cvId, fields : nil , sortByField : sortByField, sortOrder : sortOrder, converted : nil , approved : nil, page : page, per_page : per_page, modifiedSince : modifiedSince, includePrivateFields : false, kanbanView : nil, completion : { ( result ) in
            completion( result )
        } )
    }
    
    public func getRecordsWithPrivateFields(cvId : Int64, sortByField : String, sortOrder : SortOrder, page : Int, per_page : Int, modifiedSince : String, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler(module: self).getRecords( cvId : cvId, fields : nil , sortByField : sortByField, sortOrder : sortOrder, converted : nil , approved : nil, page : page, per_page : per_page, modifiedSince : modifiedSince, includePrivateFields : true, kanbanView : nil, completion : { ( result ) in
            completion( result )
        } )
    }
    
    /// Returns list of all records of the module which matches the requested params, before returning the list of records gets sorted with the given field and sort order(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - cvId: custom view ID
    ///   - fields : field apiNames
    ///   - sortByField: field by which the records get sorted
    ///   - sortOrder: sort order (asc, desc)
    ///   - converted: specifies converted type or not
    ///   - approved: specifies approved type or not
    ///   - page: page number of the module
    ///   - per_page: page number of the module
    ///   - modifiedSince: modified time
    /// - Returns: sorted list of records of the module  matches the requested params
    /// - Throws: ZCRMSDKError if failed to get the records
    public func getRecords( cvId : Int64?, fields : [String]? , sortByField : String? , sortOrder : SortOrder? , converted : Bool? , approved : Bool? , page : Int , per_page : Int , modifiedSince : String?, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler(module: self).getRecords( cvId : cvId, fields : fields , sortByField : sortByField, sortOrder : sortOrder, converted : converted , approved : approved, page : page, per_page : per_page, modifiedSince : modifiedSince, includePrivateFields : false, kanbanView : nil, completion : { ( result ) in
            completion( result )
        } )
    }
    
    public func getRecordsWithPrivateFields( cvId : Int64?, fields : [String]? , sortByField : String? , sortOrder : SortOrder? , converted : Bool? , approved : Bool? , page : Int , per_page : Int , modifiedSince : String?, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).getRecords( cvId : cvId, fields : fields , sortByField : sortByField, sortOrder : sortOrder, converted : converted , approved : approved, page : page, per_page : per_page, modifiedSince : modifiedSince, includePrivateFields : true, kanbanView : nil, completion : { ( result ) in
            completion( result )
        } )
    }
    
    public func getRecords( cvId : Int64, kanbanView : String, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).getRecords( cvId : cvId, fields : nil, sortByField : nil, sortOrder : nil, converted : nil, approved : nil, page : 1, per_page : 100, modifiedSince : nil, includePrivateFields : false, kanbanView : kanbanView ) { ( result ) in
            completion( result )
        }
    }
    
    public func getRecords( cvId : Int64, sortByField : String?, sortOrder : SortOrder?, kanbanView : String?, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).getRecords( cvId : cvId, fields : nil, sortByField : sortByField, sortOrder : sortOrder, converted : nil, approved : nil, page : 1, per_page : 100, modifiedSince : nil, includePrivateFields : false, kanbanView : kanbanView ) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns list of all approved records of the module which matches the requested params, before returning the list of records gets sorted with the given field and sort order(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - cvId: custom view ID
    ///   - fields : field apiNames
    ///   - sortByField: field by which the records get sorted
    ///   - sortOrder: sort order (asc, desc)
    ///   - page: page number of the module
    ///   - per_page: page number of the module
    /// - Returns: sorted list of records of the module matches the requested params
    /// - Throws: ZCRMSDKError if failed to get the records
    public func getApprovedRecords( cvId : Int64? , fields : [String]? , sortByField : String? , sortOrder : SortOrder? , page : Int , per_page : Int, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler(module: self).getRecords( cvId : cvId, fields : fields , sortByField : sortByField, sortOrder : sortOrder, converted : nil , approved : true, page : page, per_page : per_page, modifiedSince : nil, includePrivateFields : false, kanbanView : nil, completion : { ( result ) in
            completion( result )
        } )
    }
    
    public func getApprovedRecordsWithPrivateFields( cvId : Int64? , fields : [String]? , sortByField : String? , sortOrder : SortOrder? , page : Int , per_page : Int, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler(module: self).getRecords( cvId : cvId, fields : fields , sortByField : sortByField, sortOrder : sortOrder, converted : nil , approved : true, page : page, per_page : per_page, modifiedSince : nil, includePrivateFields : true, kanbanView : nil, completion : { ( result ) in
            completion( result )
        } )
    }
    
    /// Returns list of all unapproved records of the module which matches the requested params, before returning the list of records gets sorted with the given field and sort order(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - cvId: custom view ID
    ///   - fields : field apiNames
    ///   - sortByField: field by which the records get sorted
    ///   - sortOrder: sort order (asc, desc)
    ///   - page: page number of the module
    ///   - per_page: page number of the module
    /// - Returns: sorted list of records of the module matches the requested params
    /// - Throws: ZCRMSDKError if failed to get the records
    public func getUnApprovedRecords( cvId : Int64? , fields : [String]? , sortByField : String? , sortOrder : SortOrder? , page : Int , per_page : Int, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler(module: self).getRecords( cvId : cvId, fields : fields , sortByField : sortByField, sortOrder : sortOrder, converted : nil , approved : false, page : page, per_page : per_page, modifiedSince : nil, includePrivateFields : false, kanbanView : nil, completion : { ( result ) in
            completion( result )
        } )
    }
    
    public func getUnApprovedRecordsWithPrivateFields( cvId : Int64? , fields : [String]? , sortByField : String? , sortOrder : SortOrder? , page : Int , per_page : Int, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler(module: self).getRecords( cvId : cvId, fields : fields , sortByField : sortByField, sortOrder : sortOrder, converted : nil , approved : false, page : page, per_page : per_page, modifiedSince : nil, includePrivateFields : true, kanbanView : nil, completion : { ( result ) in
            completion( result )
        } )
    }
    
    /// Returns list of all converted records of the module which matches the requested params, before returning the list of records gets sorted with the given field and sort order(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - fields : field apiNames
    ///   - sortByField: field by which the records get sorted
    ///   - sortOrder: sort order (asc, desc)
    ///   - page: page number of the module
    ///   - per_page: page number of the module
    /// - Returns: sorted list of records of the module matches the requested params
    /// - Throws: ZCRMSDKError if failed to get the records
    public func getConvertedRecords(cvId : Int64? , fields : [String]? , sortByField : String? , sortOrder : SortOrder? , page : Int , per_page : Int, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> ())
    {
        MassEntityAPIHandler(module: self).getRecords( cvId : cvId, fields : fields , sortByField : sortByField, sortOrder : sortOrder, converted : true , approved : nil, page : page, per_page : per_page, modifiedSince : nil, includePrivateFields : false, kanbanView : nil, completion : { ( result ) in
            completion( result )
        } )
    }
    
    public func getConvertedRecordsWithPrivateFields(cvId : Int64? , fields : [String]? , sortByField : String? , sortOrder : SortOrder? , page : Int , per_page : Int, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> ())
    {
        MassEntityAPIHandler(module: self).getRecords( cvId : cvId, fields : fields , sortByField : sortByField, sortOrder : sortOrder, converted : true , approved : nil, page : page, per_page : per_page, modifiedSince : nil, includePrivateFields : true, kanbanView : nil, completion : { ( result ) in
            completion( result )
        } )
    }
    
    /// Returns list of all unconverted records of the module which matches the requested params, before returning the list of records gets sorted with the given field and sort order(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - cvId: custom view ID
    ///   - fields : fields apiNames
    ///   - sortByField: field by which the records get sorted
    ///   - sortOrder: sort order (asc, desc)
    ///   - page: page number of the module
    ///   - per_page: page number of the module
    /// - Returns: sorted list of records of the module matches the requested params
    /// - Throws: ZCRMSDKError if failed to get the records
    public func getUnConvertedRecords(cvId : Int64? , fields : [String]? , sortByField : String? , sortOrder : SortOrder? , page : Int , per_page : Int, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> ())
    {
        MassEntityAPIHandler(module: self).getRecords( cvId : cvId, fields : fields , sortByField : sortByField, sortOrder : sortOrder, converted : false, approved : nil, page : page, per_page : per_page, modifiedSince : nil, includePrivateFields : false, kanbanView : nil, completion : { ( result ) in
            completion( result )
        } )
    }
    
    public func getUnConvertedRecordsWithPrivateFields(cvId : Int64? , fields : [String]? , sortByField : String? , sortOrder : SortOrder? , page : Int , per_page : Int, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> ())
    {
        MassEntityAPIHandler(module: self).getRecords( cvId : cvId, fields : fields , sortByField : sortByField, sortOrder : sortOrder, converted : false, approved : nil, page : page, per_page : per_page, modifiedSince : nil, includePrivateFields : true, kanbanView : nil, completion : { ( result ) in
            completion( result )
        } )
    }
    
    /// Returns list of all approved records of the module which the given fields.
    ///
    /// - Parameters:
    ///   - fields : fields apiNames
    /// - Returns: sorted list of records of the module matches the given fields
    /// - Throws: ZCRMSDKError if failed to get the records
    public func getRecordByFields( fields : [String], completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler(module: self).getRecords( cvId : nil, fields : fields , sortByField : nil, sortOrder : nil, converted : nil , approved : nil, page : 1, per_page : 100, modifiedSince : nil, includePrivateFields : false, kanbanView : nil, completion : { ( result ) in
            completion( result )
        } )
    }
    
    public func getRecordByFieldsWithPrivateFields( fields : [String], completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler(module: self).getRecords( cvId : nil, fields : fields , sortByField : nil, sortOrder : nil, converted : nil , approved : nil, page : 1, per_page : 100, modifiedSince : nil, includePrivateFields : true, kanbanView : nil, completion : { ( result ) in
            completion( result )
        } )
    }
    
    /// Returns List of all deleted records of the module(BulkAPIResponse).
    ///
    /// - Returns: List of all deleted records of the module
    /// - Throws: ZCRMSDKError if failed to get the records
    public func getDeletedRecords( completion : @escaping( Result.DataResponse< [ ZCRMTrashRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).getDeletedRecords(modifiedSince: nil, page: 1, perPage: 100) { ( result ) in
            completion( result )
        }
    }
    
    public func getDeletedRecords( modifiedSince : String, completion : @escaping( Result.DataResponse< [ ZCRMTrashRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).getDeletedRecords(modifiedSince: modifiedSince, page: 1, perPage: 100) { ( result ) in
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
        MassEntityAPIHandler( module : self ).getRecycleBinRecords { ( result ) in
            completion( result )
        }
    }
    
    /// Returns List of permanently deleted records of the module(BulkAPIResponse).
    ///
    /// - Returns: List of permanently records of the module
    /// - Throws: ZCRMSDKError if failed to get the records
    public func getPermanentlyDeletedRecords( completion : @escaping( Result.DataResponse< [ ZCRMTrashRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).getPermanentlyDeletedRecords { ( result ) in
            completion( result )
        }
    }
    
    /// Returns list of records which contains the given search text as substring(BulkAPIResponse).
    ///
    /// - Parameter searchText: text to be searched
    /// - Returns: list of records which contains the given search text as substring
    /// - Throws: ZCRMSDKError if failed to get the records
    public func searchRecords(searchText: String, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler(module: self).searchByText( searchText: searchText, page: 1, perPage: 200 ) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns list of records of the module which contains the given search text as substring, with requested page number with records of per_page count(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - searchText: text to be searched
    ///   - page: page number of the module
    ///   - per_page: number of records to be given for a single page.
    /// - Returns: list of records of the module which contains the given search text as substring, with requested page number with records of per_page count
    /// - Throws: ZCRMSDKError if failed to get the records
    public func searchRecords(searchText: String, page: Int, per_page: Int, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> ())
    {
        MassEntityAPIHandler(module: self).searchByText( searchText: searchText, page: page, perPage: per_page) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns list of records which satisfies the given criteria(BulkAPIResponse).
    ///
    /// - Parameter criteria: criteria to be searched
    /// - Returns: list of records which satisfies the given criteria
    /// - Throws: ZCRMSDKError if failed to get the records
    public func searchByCriteria( criteria : String, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).searchByCriteria( searchCriteria : criteria, page : 1, perPage : 200) { ( result ) in
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
    public func searchByCriteria( criteria : String, page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).searchByCriteria( searchCriteria : criteria, page : page, perPage : perPage) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns list of records of the module which satisfies the given value(BulkAPIResponse).
    ///
    /// - Parameter searchValue: value to be searched
    /// - Returns: list of records of the module which satisfies the given value
    /// - Throws: ZCRMSDKError if failed to get the records
    public func searchByPhone( searchValue : String, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).searchByPhone( searchValue : searchValue, page : 1, perPage : 200 ) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns list of records of the module which satisfies the given value, with requested page number with records of per_page count(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - searchValue: value to be searched
    ///   - page: page number of the module
    ///   - perPage: number of records to be given for a single page
    /// - Returns: list of records of the module which satisfies the given value, with requested page number with records of per_page count
    /// - Throws: ZCRMSDKError if failed to get the records
    public func searchByPhone( searchValue : String, page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).searchByPhone( searchValue : searchValue, page : page, perPage : perPage) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns list of records of the module which satisfies the given value(BulkAPIResponse).
    ///
    /// - Parameter searchValue: value to be searched
    /// - Returns: list of records of the module which satisfies the given value
    /// - Throws: ZCRMSDKError if failed to get the records
    public func searchByEmail( searchValue : String, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).searchByEmail( searchValue : searchValue, page : 1, perPage : 200 ) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns list of records of the module which satisfies the given value, with requested page number with records of per_page count(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - searchValue: value to be searched
    ///   - page: page number of the module
    ///   - perPage: number of records to be given for a single page
    /// - Returns: list of records of the module which satisfies the given value, with requested page number with records of per_page count
    /// - Throws: ZCRMSDKError if failed to get the records
    public func searchByEmail( searchValue : String, page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).searchByEmail( searchValue : searchValue, page : page, perPage : perPage) { ( result ) in
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
        MassEntityAPIHandler(module: self).createRecords( records: records) { ( result ) in
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
        MassEntityAPIHandler(module: self).updateRecords( ids: recordIds, fieldAPIName: fieldAPIName, value: value) { ( result ) in
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
        MassEntityAPIHandler( module : self ).upsertRecords( records : records) { ( result ) in
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
        TagAPIHandler(module: self).createTags(tags: tags, completion: { ( result ) in
            completion( result )
        } )
    }
    
    public func updateTags(tags : [ZCRMTag], completion : @escaping ( Result.DataResponse< [ ZCRMTag ], BulkAPIResponse > ) -> () )
    {
        TagAPIHandler(module: self).updateTags(tags: tags, completion: { ( result ) in
            completion( result )
        } )
    }
    
    public func addTags( recordIds : [Int64], tags : [ZCRMTag], completion : @escaping( Result.Response< BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler(module: self).addTags(recordIds: recordIds, tags: tags, overWrite: nil) { ( result ) in
            completion( result )
        }
    }
    
    public func addTags( recordIds : [Int64], tags : [ZCRMTag], overWrite : Bool?, completion : @escaping( Result.Response< BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler(module: self).addTags(recordIds: recordIds, tags: tags, overWrite: overWrite) { ( result ) in
            completion( result )
        }
    }
    
    public func removeTags( recordIds: [Int64], tags : [ZCRMTag], completion : @escaping( Result.Response< BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler(module: self).removeTags(recordIds: recordIds, tags: tags) { ( result ) in
            completion( result )
        }
    }
    
    public func getDealStages( completion : @escaping( Result.DataResponse< [ ZCRMStage ], BulkAPIResponse > ) -> () )
    {
        if self.apiName == "Deals"
        {
            ModuleAPIHandler( module: self ).getStages { ( result ) in
                completion( result )
            }
        }
        else
        {
            completion( .failure( ZCRMError.InValidError(code : ErrorCode.INVALID_DATA, message : "Module is invalid" ) ) )
        }
    }
    
}
