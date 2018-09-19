//
//  ZCRMCustomView.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 17/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

open class ZCRMCustomView : ZCRMEntity
{
    var moduleAPIName : String
    public var sysName : String?
    public var isDefault : Bool = APIConstants.BOOL_MOCK
    
    public var cvId : Int64 = APIConstants.INT64_MOCK
    public var cvName : String
    public var displayName : String = APIConstants.STRING_MOCK
    public var fields : [String] = [String]()
    public var favouriteSequence : Int = APIConstants.INT_MOCK
    public var sortByCol : String?
    public var sortOrder : SortOrder?
    public var category : String = APIConstants.STRING_MOCK
    public var isOffline : Bool = APIConstants.BOOL_MOCK
    public var isSystemDefined : Bool = APIConstants.BOOL_MOCK
	
    /// Initialise the instance of a custom view with the given custom view Id.
    ///
    /// - Parameters:
    ///   - cvName: custom view Name whose associated custom view is to be initialised
    ///   - moduleAPIName: module API name of a custom view is to be initialised
    init ( cvName : String, moduleAPIName : String )
    {
        self.cvName = cvName
        self.moduleAPIName = moduleAPIName
    }
    
    /// Returns List of all records of the CustomView(BulkAPIResponse).
    ///
    /// - Returns: List of all records of the CustomView
    /// - Throws: ZCRMSDKError if failed to get the records
    public func getRecords( includePrivateFields : Bool, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        ZCRMModuleDelegate( apiName : self.moduleAPIName ).getRecords( page : 1, per_page : 200 ){ ( result ) in
            completion( result )
        }
    }
    
    public func getRecordsWithPrivateFields( completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        ZCRMModuleDelegate( apiName : self.moduleAPIName ).getRecordsWithPrivateFields( page : 1, per_page : 200 ){ ( result ) in
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
        ZCRMModuleDelegate( apiName : self.moduleAPIName ).getRecords( page : page, per_page : perPage ){ ( result ) in
            completion( result )
        }
    }
    
    public func getRecordsWithPrivateFields( page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        ZCRMModuleDelegate( apiName : self.moduleAPIName ).getRecordsWithPrivateFields( page : page, per_page : perPage ){ ( result ) in
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
        ZCRMModuleDelegate( apiName : self.moduleAPIName ).getRecords( cvId : self.cvId, sortByField : sortByField, sortOrder : sortOrder) { ( result ) in
            completion( result )
        }
    }
    
    public func getRecordsWithPrivateFields( sortByField : String, sortOrder : SortOrder, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        ZCRMModuleDelegate( apiName : self.moduleAPIName ).getRecordsWithPrivateFields( cvId : self.cvId, sortByField : sortByField, sortOrder : sortOrder) { ( result ) in
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
        ZCRMModuleDelegate( apiName : self.moduleAPIName ).getRecords( cvId : self.cvId, sortByField : sortByField, sortOrder : sortOrder, page: startIndex, per_page: endIndex, modifiedSince : modifiedSince ){ ( result ) in
            completion( result )
        }
    }
    
    public func getRecordsWithPrivateFields( sortByField : String, sortOrder : SortOrder, startIndex : Int, endIndex : Int, modifiedSince : String, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        ZCRMModuleDelegate( apiName : self.moduleAPIName ).getRecords( cvId : self.cvId, sortByField : sortByField, sortOrder : sortOrder, page: startIndex, per_page: endIndex, modifiedSince : modifiedSince ){ ( result ) in
            completion( result )
        }
    }
    
    public func getRecords( kanbanView : String, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        ZCRMModuleDelegate( apiName : self.moduleAPIName ).getRecords(cvId: self.cvId, kanbanView: kanbanView) { ( result ) in
            completion( result )
        }
    }
    
    public func getRecords ( sortByField : String, sortOrder : SortOrder, kanbanView : String, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        ZCRMModuleDelegate( apiName : self.moduleAPIName ).getRecords( cvId : self.cvId, sortByField : sortByField, sortOrder : sortOrder, kanbanView : kanbanView ) { ( result ) in
            completion( result )
        }
    }
}
