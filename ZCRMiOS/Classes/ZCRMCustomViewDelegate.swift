//
//  ZCRMCustomViewDelegate.swift
//  ZCRMiOS
//
//  Created by Umashri R on 12/09/18.
//

open class ZCRMCustomViewDelegate : ZCRMEntity
{
    var cvId : Int64
    var moduleAPIName : String
    
    init( cvId : Int64, moduleAPIName : String )
    {
        self.cvId = cvId
        self.moduleAPIName = moduleAPIName
    }
    
    /// Returns List of all records of the CustomView(BulkAPIResponse).
    ///
    /// - Returns: List of all records of the CustomView
    /// - Throws: ZCRMSDKError if failed to get the records
    public func getRecords( includePrivateFields : Bool, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        ZCRMModule( moduleAPIName : self.moduleAPIName ).getRecords( page : 1, per_page : 200 ){ ( result ) in
            completion( result )
        }
    }

    public func getRecordsWithPrivateFields( completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        ZCRMModule( moduleAPIName : self.moduleAPIName ).getRecordsWithPrivateFields( page : 1, per_page : 200 ){ ( result ) in
            completion( result )
        }
    }
    
    /// Returns list of all records of the CustomView of a requested page number with records of per_page count(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - page:  page number of the CustomView
    ///   - perPage: no of records to be given for a single page.
    /// - Returns: list of all records of the CustomView of a requested page number with records of per_page count
    /// - Throws: ZCRMSDKError if failed to get the records
    public func getRecords( page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        ZCRMModule( moduleAPIName : self.moduleAPIName ).getRecords( page : page, per_page : perPage ){ ( result ) in
            completion( result )
        }
    }
    
    public func getRecordsWithPrivateFields( page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        ZCRMModule( moduleAPIName : self.moduleAPIName ).getRecordsWithPrivateFields( page : page, per_page : perPage ){ ( result ) in
            completion( result )
        }
    }
    
    /// Returns list of all records of the CustomView, before returning the list of records gets sorted with the given field and sort order(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - sortByField: field by which the records get sorted
    ///   - sortOrder: sort order (asc, desc)
    /// - Returns: sorted list of records of the CustomView
    /// - Throws: ZCRMSDKError if failed to get the records
    public func getRecords( sortByField : String, sortOrder : SortOrder, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        ZCRMModule( moduleAPIName : self.moduleAPIName ).getRecords( cvId : self.cvId, sortByField : sortByField, sortOrder : sortOrder) { ( result ) in
            completion( result )
        }
    }
    
    public func getRecordsWithPrivateFields( sortByField : String, sortOrder : SortOrder, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        ZCRMModule( moduleAPIName : self.moduleAPIName ).getRecordsWithPrivateFields( cvId : self.cvId, sortByField : sortByField, sortOrder : sortOrder) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns list of all records of the CustomView of a requested page number with records of per_page count, before returning the list of records gets sorted with the given field and sort order(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - sortByField: field by which the records get sorted
    ///   - sortOrder: sort order (asc, desc)
    ///   - startIndex: records start index
    ///   - endIndex: records end index
    ///   - modifiedSince: modified time
    /// - Returns: sorted list of records of the CustomView
    /// - Throws: ZCRMSDKError if failed to get the records
    public func getRecords( sortByField : String, sortOrder : SortOrder, startIndex : Int, endIndex : Int, modifiedSince : String, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        ZCRMModule( moduleAPIName : self.moduleAPIName ).getRecords( cvId : self.cvId, sortByField : sortByField, sortOrder : sortOrder, page: startIndex, per_page: endIndex, modifiedSince : modifiedSince ){ ( result ) in
            completion( result )
        }
    }
    
    public func getRecordsWithPrivateFields( sortByField : String, sortOrder : SortOrder, startIndex : Int, endIndex : Int, modifiedSince : String, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        ZCRMModule( moduleAPIName : self.moduleAPIName ).getRecords( cvId : self.cvId, sortByField : sortByField, sortOrder : sortOrder, page: startIndex, per_page: endIndex, modifiedSince : modifiedSince ){ ( result ) in
            completion( result )
        }
    }

    public func getRecords( kanbanView : String, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        ZCRMModule( moduleAPIName : self.moduleAPIName ).getRecords(cvId: self.cvId, kanbanView: kanbanView) { ( result ) in
            completion( result )
        }
    }
    
    public func getRecords ( sortByField : String, sortOrder : SortOrder, kanbanView : String, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        ZCRMModule( moduleAPIName : self.moduleAPIName ).getRecords( cvId : self.cvId, sortByField : sortByField, sortOrder : sortOrder, kanbanView : kanbanView ) { ( result ) in
            completion( result )
        }
    }
}
var CUSTOM_VIEW_NIL : ZCRMCustomViewDelegate = ZCRMCustomViewDelegate(cvId: INT64_NIL, moduleAPIName: STRING_NIL)
