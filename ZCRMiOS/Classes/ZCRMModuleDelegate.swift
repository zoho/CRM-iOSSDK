//
//  ZCRMModuleDelegate.swift
//  Pods-ZCRMiOS_Tests
//
//  Created by Boopathy P on 15/09/18.
//

import Foundation
import ZCacheiOS

open class ZCRMModuleDelegate : ZCRMEntity, ZCacheModule
{
    public var apiName : String
    
    public var id: String
    
    public var isApiSupported: Bool
    
    public func getLayoutFromServer<T>(id: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    {
        ModuleAPIHandler(module: self, cacheFlavour: .noCache).getLayout(layoutId: id)
        {
            ( result ) in
            switch result
            {
            case .success(let layout, _):
                do
                {
                    completion(.success(layout as! T))
                }
            case .failure(let error):
                do
                {
                    let code = error.ZCRMErrordetails?.code
                    let message = error.ZCRMErrordetails?.code
                
                    completion(.failure(ZCacheError.processingError(code: code ?? ErrorCode.internalError, message: message ?? ErrorMessage.responseNilMsg, details: nil)))
                }
            }
        }
    }
    
    public func getLayoutsFromServer<T>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {
        ModuleAPIHandler(module: self, cacheFlavour: .noCache).getAllLayouts(modifiedSince: nil)
        {
            ( result ) in
            switch result
            {
            case .success(let layouts, _):
                do
                {
                    completion(.success(layouts as! [T]))
                }
            case .failure(let error):
                do
                {
                    let code = error.ZCRMErrordetails?.code
                    let message = error.ZCRMErrordetails?.code
                
                    completion(.failure(ZCacheError.processingError(code: code ?? ErrorCode.internalError, message: message ?? ErrorMessage.responseNilMsg, details: nil)))
                }
            }
        }
    }
    
    public func getLayoutsFromServer<T>(modifiedSince: String, completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {
        ModuleAPIHandler(module: self, cacheFlavour: .noCache).getAllLayouts(modifiedSince: modifiedSince)
        {
            ( result ) in
            switch result
            {
            case .success(let layouts, _):
                do
                {
                    completion(.success(layouts as! [T]))
                }
            case .failure(let error):
                do
                {
                    let code = error.ZCRMErrordetails?.code
                    let message = error.ZCRMErrordetails?.code
                
                    completion(.failure(ZCacheError.processingError(code: code ?? ErrorCode.internalError, message: message ?? ErrorMessage.responseNilMsg, details: nil)))
                }
            }
        }
    }
    
    public func getFieldFromServer<T>(id: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    {
        ModuleAPIHandler(module: self, cacheFlavour: .noCache).getField(fieldId: id)
        {
            ( result ) in
            switch result
            {
            case .success(let field, _):
                do
                {
                    completion(.success(field as! T))
                }
            case .failure(let error):
                do
                {
                    let code = error.ZCRMErrordetails?.code
                    let message = error.ZCRMErrordetails?.code
                
                    completion(.failure(ZCacheError.processingError(code: code ?? ErrorCode.internalError, message: message ?? ErrorMessage.responseNilMsg, details: nil)))
                }
            }
        }
    }
    
    public func getFieldsFromServer<T>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {
        ModuleAPIHandler(module: self, cacheFlavour: .noCache).getAllFields(modifiedSince: nil)
        {
            ( result ) in
            switch result
            {
            case .success(let fields, _):
                do
                {
                    completion(.success(fields as! [T]))
                }
            case .failure(let error):
                do
                {
                    let code = error.ZCRMErrordetails?.code
                    let message = error.ZCRMErrordetails?.code
                
                    completion(.failure(ZCacheError.processingError(code: code ?? ErrorCode.internalError, message: message ?? ErrorMessage.responseNilMsg, details: nil)))
                }
            }
        }
    }
    
    public func getFieldsFromServer<T>(modifiedSince: String, completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {
        ModuleAPIHandler(module: self, cacheFlavour: .noCache).getAllFields(modifiedSince: modifiedSince)
        {
            ( result ) in
            switch result
            {
            case .success(let fields, _):
                do
                {
                    completion(.success(fields as! [T]))
                }
            case .failure(let error):
                do
                {
                    let code = error.ZCRMErrordetails?.code
                    let message = error.ZCRMErrordetails?.code
                
                    completion(.failure(ZCacheError.processingError(code: code ?? ErrorCode.internalError, message: message ?? ErrorMessage.responseNilMsg, details: nil)))
                }
            }
        }
    }
    
    public func execute<T>(query: String, completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {
        
    }
    
    public func getRecordFromServer<T>(id: String, completion: @escaping ((DataResponseCallback<ZCacheResponse, T>) -> Void))
    {
        EntityAPIHandler( recordDelegate : ZCRMRecordDelegate( id : id, moduleAPIName : self.apiName ) ).getRecord( withPrivateFields : false )
        {
            result in
            switch result
            {
            case .success(let record, _):
                do
                {
                    completion(.fromServer(info: nil, data: record as? T))
                }
            case .failure(let error):
                do
                {
                    completion(.failure(error: ZCacheError.invalidError(code: ErrorCode.invalidData, message: error.description, details: nil)))
                }
            }
        }
    }
    
    public func createRecord<T>(record: T, completion: @escaping ((DataResponseCallback<ZCacheResponse, T>) -> Void))
    {
        
    }
    
    public func updateRecord<T>(record: T, completion: @escaping ((DataResponseCallback<ZCacheResponse, T>) -> Void))
    {
        
    }
    
    public func deleteRecord(id: String, completion: @escaping ((DataResponseCallback<ZCacheResponse, String>) -> Void))
    {
        
    }
    
    public func createRecords<T>(entities: [T], completion: @escaping ((DataResponseCallback<ZCacheResponse, [T]>) -> Void))
    {
        
    }
    
    public func updateRecords<T>(entities: [T], completion: @escaping ((DataResponseCallback<ZCacheResponse, [T]>) -> Void))
    {
        
    }
    
    public func deleteRecords<T>(entities: [T], completion: @escaping ((DataResponseCallback<ZCacheResponse, [String]>) -> Void))
    {
        
    }
    
    public func deleteAllRecords(ids: [String], completion: @escaping ((DataResponseCallback<ZCacheResponse, [String]>) -> Void))
    {
        
    }
    
    public func getRecordsFromServer<T>(params: [String], completion: @escaping ((DataResponseCallback<ZCacheResponse, [T]>) -> Void))
    {
        
    }
    
    public func getDeletedRecordsFromServer<T>(params: [String], completion: @escaping ((DataResponseCallback<ZCacheResponse, [T]>) -> Void))
    {
        
    }
    
    public func newRecord() -> ZCRMRecord
    {
        return ZCRMRecord( moduleAPIName : apiName )
    }
    
    public func getRecordDelegate( id : String ) -> ZCRMRecordDelegate
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
    public func getRelatedLists( completion : @escaping( ResultType.DataResponse< [ ZCRMModuleRelation ], BulkAPIResponse > ) -> () )
    {
        ModuleAPIHandler( module : self, cacheFlavour : .urlVsResponse ).getAllRelatedLists { ( result ) in
            completion( result )
        }
    }
    
    public func getRelatedListsFromServer( completion : @escaping( ResultType.DataResponse< [ ZCRMModuleRelation ], BulkAPIResponse > ) -> () )
    {
        ModuleAPIHandler( module : self, cacheFlavour : .noCache ).getAllRelatedLists { ( result ) in
            completion( result )
        }
    }
    
    public func getRelatedList( id : Int64, completion : @escaping( ResultType.DataResponse< ZCRMModuleRelation, APIResponse > ) -> () )
    {
        ModuleAPIHandler( module: self, cacheFlavour: .urlVsResponse ).getRelatedList(id: id) { ( result ) in
            completion( result )
        }
    }
    
    public func getRelatedListFromServer( id : Int64, completion : @escaping( ResultType.DataResponse< ZCRMModuleRelation, APIResponse > ) -> () )
    {
        ModuleAPIHandler( module: self, cacheFlavour: .noCache ).getRelatedList(id: id) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns all the layouts of the module(BulkAPIResponse).
    ///
    /// - Returns: all the layouts of the module
    /// - Throws: ZCRMSDKError if failed to get all layouts
    public func getLayouts( completion : @escaping( ResultType.DataResponse< [ ZCRMLayout ], BulkAPIResponse > ) -> () )
    {
        ModuleAPIHandler(module: self, cacheFlavour: .urlVsResponse).getAllLayouts( modifiedSince : nil) { ( result ) in
            completion( result )
        }
    }
    
    public func getLayoutsFromServer( completion : @escaping( ResultType.DataResponse< [ ZCRMLayout ], BulkAPIResponse > ) -> () )
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
    public func getLayout( id : String, completion : @escaping( ResultType.DataResponse< ZCRMLayout, APIResponse > ) -> () )
    {
        ModuleAPIHandler( module : self, cacheFlavour : .urlVsResponse ).getLayout( layoutId : id ) { ( result ) in
            completion( result )
        }
    }
    
    public func getLayoutFromServer( id : String, completion : @escaping( ResultType.DataResponse< ZCRMLayout, APIResponse > ) -> () )
    {
        ModuleAPIHandler( module : self, cacheFlavour : .noCache ).getLayout( layoutId : id ) { ( result ) in
            completion( result )
        }
    }
    
    ///  Returns list of ZCRMFields of the module(BulkAPIResponse).
    ///
    /// - Returns: list of ZCRMFields of the module
    /// - Throws: ZCRMSDKError if failed to get all fields
    public func getFields( completion : @escaping( ResultType.DataResponse< [ ZCRMField ], BulkAPIResponse > ) -> () )
    {
        ModuleAPIHandler( module : self, cacheFlavour : .urlVsResponse ).getAllFields( modifiedSince : nil ) { ( result ) in
            completion( result )
        }
    }
    
    public func getFieldsFromServer( completion : @escaping( ResultType.DataResponse< [ ZCRMField ], BulkAPIResponse > ) -> () )
    {
        ModuleAPIHandler( module : self, cacheFlavour : .noCache ).getAllFields( modifiedSince : nil ) { ( result ) in
            completion( result )
        }
    }
    
    public func getField( id : String, completion : @escaping( ResultType.DataResponse< ZCRMField, APIResponse > ) -> () )
    {
        ModuleAPIHandler(module: self, cacheFlavour: .urlVsResponse).getField(fieldId: id) { ( result ) in
            completion( result )
        }
    }
    
    public func getFieldFromServer( id : String, completion : @escaping( ResultType.DataResponse< ZCRMField, APIResponse > ) -> () )
    {
        ModuleAPIHandler(module: self, cacheFlavour: .noCache).getField(fieldId: id) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns the custom views of the module(BulkAPIResponse).
    ///
    /// - Returns: custom views of the module
    /// - Throws: ZCRMSDKError if failed to get the custom views
    public func getCustomViews( completion : @escaping( ResultType.DataResponse< [ ZCRMCustomView ], BulkAPIResponse > ) -> () )
    {
        ModuleAPIHandler(module: self, cacheFlavour: .urlVsResponse).getAllCustomViews( modifiedSince : nil) { ( result ) in
            completion( result )
        }
    }
    
    public func getCustomViewsFromServer( completion : @escaping( ResultType.DataResponse< [ ZCRMCustomView ], BulkAPIResponse > ) -> () )
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
    public func getCustomView( id : Int64, completion : @escaping( ResultType.DataResponse< ZCRMCustomView, APIResponse > ) -> () )
    {
        ModuleAPIHandler( module : self, cacheFlavour : .urlVsResponse ).getCustomView( cvId : id ) { ( result ) in
            completion( result )
        }
    }
    
    public func getCustomViewFromServer( id : Int64, completion : @escaping( ResultType.DataResponse< ZCRMCustomView, APIResponse > ) -> () )
    {
        ModuleAPIHandler( module : self, cacheFlavour : .noCache ).getCustomView( cvId : id ) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns ZCRMRecord with the given ID of the module(APIResponse).
    ///
    /// - Parameter recordId: Id of the record to be returned
    /// - Returns: ZCRMRecord with the given ID of the module
    /// - Throws: ZCRMSDKError if failed to get the record
    public func getRecord( id : String, completion : @escaping( ResultType.DataResponse< ZCRMRecord, APIResponse > ) -> () )
    {
        EntityAPIHandler( recordDelegate : ZCRMRecordDelegate( id : id, moduleAPIName : self.apiName ) ).getRecord( withPrivateFields : false, completion : { ( result ) in
            completion( result )
        } )
    }
    
    public func getRecordWithPrivateFields( id : String, completion : @escaping( ResultType.DataResponse< ZCRMRecord, APIResponse > ) -> () )
    {
        EntityAPIHandler( recordDelegate : ZCRMRecordDelegate( id : id, moduleAPIName : self.apiName ) ).getRecord( withPrivateFields : true, completion : { ( result ) in
            completion( result )
        } )
    }
    
    public func getRecords( recordParams : ZCRMQuery.GetRecordParams, completion : @escaping( ResultType.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).getRecords( cvId : nil, filterId : nil, recordParams : recordParams ) { ( result ) in
            completion( result )
        }
    }
    
    public func getRecords( cvId : Int64, recordParams : ZCRMQuery.GetRecordParams, completion : @escaping( ResultType.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).getRecords( cvId : cvId, filterId : nil, recordParams : recordParams ) { ( result ) in
            completion( result )
        }
    }
    
    public func getRecords( cvId : Int64, filterId : Int64, recordParams : ZCRMQuery.GetRecordParams, completion : @escaping( ResultType.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).getRecords( cvId : cvId, filterId : filterId, recordParams : recordParams ) { ( result ) in
            completion( result )
        }
    }
    
    /**
     Returns List of all deleted records of the module( BulkAPIResponse )
     
     - Parameters:
        - ofType : Specify the type of deleted records to be fetched
            - all : All the deleted records
            - recycle : The deleted records that are in recycle bin
            - permanent : The records that are permanently deleted
        - completion : Returns an array of ZCRMTrashRecord and a bulkresponse
     */
    public func getTrashRecords( ofType : TrashRecordTypes, completion : @escaping ( ResultType.DataResponse< [ ZCRMTrashRecord ], BulkAPIResponse > ) -> Void )
    {
        MassEntityAPIHandler( module : self ).getDeletedRecords(type: ofType, params: ZCRMQuery.getRequestParams) { result in
            completion( result )
        }
    }
    
    /**
    Returns List of all deleted records of the module( BulkAPIResponse )
    
    - Parameters:
       - ofType : Specify the type of deleted records to be fetched
           - all : All the deleted records
           - recycle : The deleted records that are in recycle bin
           - permanent : The records that are permanently deleted
       - withParams : Specify the params that has to be included in the request
       - completion : Returns an array of ZCRMTrashRecord and a bulkresponse
    */
    public func getTrashRecords( ofType : TrashRecordTypes, withParams : GETRequestParams, completion : @escaping ( ResultType.DataResponse< [ ZCRMTrashRecord ], BulkAPIResponse > ) -> Void )
    {
        MassEntityAPIHandler( module : self ).getDeletedRecords(type: ofType, params: withParams) { result in
            completion( result )
        }
    }
    
     /// Returns List of all deleted records of the module(BulkAPIResponse).
     ///
     /// - Returns: List of all deleted records of the module
     /// - Throws: ZCRMSDKError if failed to get the records
     @available(*, deprecated, message: "Use the method getTrashRecords( ofType : TrashRecordTypes, completion : ) instead" )
     public func getDeletedRecords( completion : @escaping( ResultType.DataResponse< [ ZCRMTrashRecord ], BulkAPIResponse > ) -> () )
     {
         MassEntityAPIHandler( module : self ).getDeletedRecords(type: .all, params: ZCRMQuery.getRequestParams ) { ( result ) in
             completion( result )
         }
     }
     
     @available(*, deprecated, message: "Use the method getTrashRecords( ofType : TrashRecordTypes, withParams : GETRequestParams, completion : ) instead" )
     public func getDeletedRecords( withParams : GETRequestParams, completion : @escaping ( ResultType.DataResponse< [ ZCRMTrashRecord ], BulkAPIResponse > ) -> Void )
     {
         MassEntityAPIHandler( module : self ).getDeletedRecords(type: .all, params: withParams ) { result in
             completion( result )
         }
     }
     
     @available(*, deprecated, message: "Use the method getTrashRecords( ofType : TrashRecordTypes, withParams : GETRequestParams, completion : ) instead" )
     public func getDeletedRecords( modifiedSince : String, completion : @escaping( ResultType.DataResponse< [ ZCRMTrashRecord ], BulkAPIResponse > ) -> () )
     {
         var params : GETRequestParams = ZCRMQuery.getRequestParams
         params.modifiedSince = modifiedSince
         MassEntityAPIHandler( module : self ).getDeletedRecords(type: .all, params: params ) { result in
             completion( result )
         }
     }
     
     @available(*, deprecated, message: "Use the method getTrashRecords( ofType : TrashRecordTypes, withParams : GETRequestParams, completion : ) instead" )
     public func getDeletedRecords( page : Int, perPage : Int, completion : @escaping( ResultType.DataResponse< [ ZCRMTrashRecord ], BulkAPIResponse > ) -> () )
     {
         var params : GETRequestParams = ZCRMQuery.getRequestParams
         params.page = page
         params.perPage = perPage
         MassEntityAPIHandler( module : self ).getDeletedRecords(type: .all, params: params ) { result in
             completion( result )
         }
     }
     
     @available(*, deprecated, message: "Use the method getTrashRecords( ofType : TrashRecordTypes, withParams : GETRequestParams, completion : ) instead" )
     public func getDeletedRecords( modifiedSince : String, page : Int, perPage : Int, completion : @escaping( ResultType.DataResponse< [ ZCRMTrashRecord ], BulkAPIResponse > ) -> () )
     {
         var params : GETRequestParams = ZCRMQuery.getRequestParams
         params.page = page
         params.perPage = perPage
         params.modifiedSince = modifiedSince
         MassEntityAPIHandler( module : self ).getDeletedRecords(type: .all, params: params ) { result in
             completion( result )
         }
     }
     
     
     /// Returns List of recycle bin records of the module(BulkAPIResponse).
     ///
     /// - Returns: List of recycle bin records of the module
     /// - Throws: ZCRMSDKError if failed to get the records
     @available(*, deprecated, message: "Use the method getTrashRecords( ofType : TrashRecordTypes, completion : ) instead" )
     public func getRecycleBinRecords( completion : @escaping( ResultType.DataResponse< [ ZCRMTrashRecord ], BulkAPIResponse > ) -> () )
     {
         MassEntityAPIHandler( module : self ).getDeletedRecords(type: .recycle, params: ZCRMQuery.getRequestParams ) { ( result ) in
             completion( result )
         }
     }
     
     @available(*, deprecated, message: "Use the method getTrashRecords( ofType : TrashRecordTypes, withParams : GETRequestParams, completion : ) instead" )
     public func getRecycleBinRecords( withParams : GETRequestParams, completion : @escaping ( ResultType.DataResponse< [ ZCRMTrashRecord ], BulkAPIResponse > ) -> Void )
     {
         MassEntityAPIHandler( module : self ).getDeletedRecords(type: .recycle, params: withParams ) { result in
             completion( result )
         }
     }
     
     @available(*, deprecated, message: "Use the method getTrashRecords( ofType : TrashRecordTypes, withParams : GETRequestParams, completion : ) instead" )
     public func getRecycleBinRecords( modifiedSince : String, completion : @escaping( ResultType.DataResponse< [ ZCRMTrashRecord ], BulkAPIResponse > ) -> () )
     {
         var params : GETRequestParams = ZCRMQuery.getRequestParams
         params.modifiedSince = modifiedSince
         MassEntityAPIHandler( module : self ).getDeletedRecords(type: .recycle, params: params ) { result in
             completion( result )
         }
     }
     
    @available(*, deprecated, message: "Use the method getTrashRecords( ofType : TrashRecordTypes, withParams : GETRequestParams, completion : ) instead" )
     public func getRecycleBinRecords( page : Int, perPage : Int, completion : @escaping( ResultType.DataResponse< [ ZCRMTrashRecord ], BulkAPIResponse > ) -> () )
     {
         var params : GETRequestParams = ZCRMQuery.getRequestParams
         params.page = page
         params.perPage = perPage
         MassEntityAPIHandler( module : self ).getDeletedRecords(type: .recycle, params: params ) { result in
             completion( result )
         }
     }
     
     @available(*, deprecated, message: "Use the method getTrashRecords( ofType : TrashRecordTypes, withParams : GETRequestParams, completion : ) instead" )
     public func getRecycleBinRecords( modifiedSince : String, page : Int, perPage : Int, completion : @escaping( ResultType.DataResponse< [ ZCRMTrashRecord ], BulkAPIResponse > ) -> () )
     {
         var params : GETRequestParams = ZCRMQuery.getRequestParams
         params.page = page
         params.perPage = perPage
         params.modifiedSince = modifiedSince
         MassEntityAPIHandler( module : self ).getDeletedRecords(type: .recycle, params: params ) { result in
             completion( result )
         }
     }
     
     /// Returns List of permanently deleted records of the module(BulkAPIResponse).
     ///
     /// - Returns: List of permanently records of the module
     /// - Throws: ZCRMSDKError if failed to get the records
     @available(*, deprecated, message: "Use the method getTrashRecords( ofType : TrashRecordTypes, completion : ) instead" )
     public func getPermanentlyDeletedRecords( completion : @escaping( ResultType.DataResponse< [ ZCRMTrashRecord ], BulkAPIResponse > ) -> () )
     {
         MassEntityAPIHandler( module : self ).getDeletedRecords(type: .permanent, params: ZCRMQuery.getRequestParams ) { ( result ) in
             completion( result )
         }
     }
     
     @available(*, deprecated, message: "Use the method getTrashRecords( ofType : TrashRecordTypes, withParams : GETRequestParams, completion : ) instead" )
     public func getPermanentlyDeletedRecords( withParams : GETRequestParams, completion : @escaping( ResultType.DataResponse< [ ZCRMTrashRecord ], BulkAPIResponse > ) -> () )
     {
         MassEntityAPIHandler( module : self ).getDeletedRecords(type: .permanent, params: withParams ) { ( result ) in
             completion( result )
         }
     }
     
     @available(*, deprecated, message: "Use the method getTrashRecords( ofType : TrashRecordTypes, withParams : GETRequestParams, completion : ) instead" )
     public func getPermanentlyDeletedRecords( modifiedSince : String, completion : @escaping( ResultType.DataResponse< [ ZCRMTrashRecord ], BulkAPIResponse > ) -> () )
     {
         var params : GETRequestParams = ZCRMQuery.getRequestParams
         params.modifiedSince = modifiedSince
         MassEntityAPIHandler( module : self ).getDeletedRecords(type: .permanent, params: params ) { ( result ) in
             completion( result )
         }
     }
     
     @available(*, deprecated, message: "Use the method getTrashRecords( ofType : TrashRecordTypes, withParams : GETRequestParams, completion : ) instead" )
     public func getPermanentlyDeletedRecords( page : Int, perPage : Int, completion : @escaping( ResultType.DataResponse< [ ZCRMTrashRecord ], BulkAPIResponse > ) -> () )
     {
         var params : GETRequestParams = ZCRMQuery.getRequestParams
         params.page = page
         params.perPage = perPage
         MassEntityAPIHandler( module : self ).getDeletedRecords(type: .permanent, params: params ) { ( result ) in
             completion( result )
         }
     }
     
     @available(*, deprecated, message: "Use the method getTrashRecords( ofType : TrashRecordTypes, withParams : GETRequestParams, completion : ) instead" )
     public func getPermanentlyDeletedRecords( modifiedSince : String, page : Int, perPage : Int, completion : @escaping( ResultType.DataResponse< [ ZCRMTrashRecord ], BulkAPIResponse > ) -> () )
     {
         var params : GETRequestParams = ZCRMQuery.getRequestParams
         params.page = page
         params.perPage = perPage
         params.modifiedSince = modifiedSince
         MassEntityAPIHandler( module : self ).getDeletedRecords(type: .permanent, params: params ) { ( result ) in
             completion( result )
         }
     }
     
    /// Returns list of records which contains the given search text as substring(BulkAPIResponse).
    ///
    /// - Parameter text: text to be searched
    /// - Returns: list of records which contains the given search text as substring
    /// - Throws: ZCRMSDKError if failed to get the records
    public func searchBy( text : String, completion : @escaping( ResultType.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
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
    public func searchBy( text : String, page : Int, per_page : Int, completion : @escaping( ResultType.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
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
    public func searchBy( criteria : ZCRMQuery.ZCRMCriteria, completion : @escaping( ResultType.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
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
    public func searchBy( criteria : ZCRMQuery.ZCRMCriteria, page : Int, perPage : Int, completion : @escaping( ResultType.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
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
    public func searchBy( phone : String, completion : @escaping( ResultType.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
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
    public func searchBy( phone : String, page : Int, perPage : Int, completion : @escaping( ResultType.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
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
    public func searchBy( email : String, completion : @escaping( ResultType.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
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
    public func searchBy( email : String, page : Int, perPage : Int, completion : @escaping( ResultType.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
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
    public func createRecords(records: [ZCRMRecord], completion : @escaping( ResultType.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> ())
    {
        MassEntityAPIHandler(module: self).createRecords( triggers: nil, records: records) { ( result ) in
            completion( result )
        }
    }
    
    public func createRecords(triggers : [Trigger], records: [ZCRMRecord], completion : @escaping( ResultType.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> ())
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
    public func updateRecords(recordIds: [String], fieldAPIName: String, value: Any?, completion : @escaping( ResultType.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> ())
    {
        MassEntityAPIHandler(module: self).massUpdateRecords(triggers: nil, ids: recordIds, fieldValuePair: [ fieldAPIName : value ]) { result in
            completion( result )
        }
    }
    
    /**
      To update the given field values to the specifed record ids
     
     - Parameters:
        - recordIds : ID of the records that needs to be updated with the field value
        - fieldValuePair : A dictionary of field and its value
        - triggers : The triggers that needs to be activated during the update operation
        - completion :
            - Success : Returns an array of ZCRMRecords and a BulkAPIResponse
            - Failure : Returns error
     */
    private func massUpdateRecords( recordIds: [ String ], fieldValuePair : [ String : Any?  ], triggers : [ Trigger ]? = nil, completion : @escaping( ResultType.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> ())
    {
        MassEntityAPIHandler(module: self).massUpdateRecords(triggers: triggers, ids: recordIds, fieldValuePair: fieldValuePair ) { result in
            completion( result )
        }
    }
    
    /**
     To update the records
    
    - Parameters:
       - recordIds : Array of record Ids that needs to be updated
       - fieldAPIName : API name of the field to be updated
       - value : The Value with which the field to be updated
       - triggers : Triggers that needs to be activated during the update operation
       - completion :
           - Success : Returns an array of ZCRMRecord objects and a BulkAPIResponse
           - Failure : Returns error
    */
    public func updateRecords( recordIds: [String], fieldAPIName: String, value: Any?, triggers : [Trigger], completion : @escaping( ResultType.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> ())
    {
        MassEntityAPIHandler(module: self).massUpdateRecords(triggers: triggers, ids: recordIds, fieldValuePair: [ fieldAPIName : value ]) { result in
            completion( result )
        }
    }
    
    @available(*, deprecated, message: "Use the method updateRecords( recordIds :, fieldAPIName:, value:, triggers:, completion : ) instead" )
    public func updateRecords(triggers : [Trigger], recordIds: [String], fieldAPIName: String, value: Any?, completion : @escaping( ResultType.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> ())
    {
        MassEntityAPIHandler(module: self).massUpdateRecords(triggers: triggers, ids: recordIds, fieldValuePair: [ fieldAPIName : value ]) { result in
            completion( result )
        }
    }
    
    /**
      To update the records
     
     - Parameters:
        - records : Array of records that needs to be updated
        - triggers : Triggers that needs to be activated during the update operation
        - completion :
            - Success : Returns an array of ZCRMRecord objects and a BulkAPIResponse
            - Failure : Returns error
     */
    public func updateRecords( records: [ ZCRMRecord ], triggers : [ Trigger ]? = nil, completion : @escaping( ResultType.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> ())
    {
        MassEntityAPIHandler(module: self).updateRecords(triggers: triggers, records: records) { result in
            completion( result )
        }
    }
    
    /// Returns the upsert results of the set of records of the module(BulkAPIResponse).
    ///
    /// - Parameter records: list of ZCRMRecord objects to be upserted
    /// - Returns: upsert response of the records
    /// - Throws: ZCRMSDKError if failed to upsert records
    public func upsertRecords( records : [ ZCRMRecord ], completion : @escaping( ResultType.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).upsertRecords( triggers: nil, records : records, duplicateCheckFields: nil) { ( result ) in
            completion( result )
        }
    }
    
    /**
     Returns the upsert results of the set of records of the module(BulkAPIResponse).
    
    - Parameters:
        - triggers : To execute particular triggers of that module. If empty, all the workflows of that module gets executed
        - records : list of ZCRMRecord objects to be upserted
        - completion :
            - Returns - upsert response of the records
            - Throws -  ZCRMSDKError if failed to upsert records
     */
    public func upsertRecords( triggers : [Trigger],  records : [ ZCRMRecord ], completion : @escaping( ResultType.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).upsertRecords( triggers: triggers, records : records, duplicateCheckFields: nil) { ( result ) in
            completion( result )
        }
    }
    
    /**
     Returns the upsert results of the set of records of the module(BulkAPIResponse).
    
    - Parameters:
        - records : list of ZCRMRecord objects to be upserted
        - duplicateCheckFields : The system checks for duplicate records based on the duplicate check field's values
        - completion :
            - Returns - upsert response of the records
            - Throws -  ZCRMSDKError if failed to upsert records
     */
    public func upsertRecords( records : [ ZCRMRecord ], duplicateCheckFields : [ String ], completion : @escaping( ResultType.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).upsertRecords( triggers: nil, records : records, duplicateCheckFields: duplicateCheckFields) { ( result ) in
            completion( result )
        }
    }
    
    /**
     Returns the upsert results of the set of records of the module(BulkAPIResponse).
    
    - Parameters:
        - triggers : To execute particular triggers of that module. If empty, all the workflows of that module gets executed
        - records : list of ZCRMRecord objects to be upserted
        - duplicateCheckFields : The system checks for duplicate records based on the duplicate check field's values
        - completion :
            - Returns - upsert response of the records
            - Throws -  ZCRMSDKError if failed to upsert records
     */
    public func upsertRecords( triggers : [Trigger],  records : [ ZCRMRecord ], duplicateCheckFields : [ String ], completion : @escaping( ResultType.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).upsertRecords( triggers: triggers, records : records, duplicateCheckFields: duplicateCheckFields) { ( result ) in
            completion( result )
        }
    }
    
    /// Returns the mass delete results of the set of records of the module(BulkAPIResponse).
    ///
    /// - Parameter recordIds: id's of the record to be deleted
    /// - Returns: mass delete response of the record
    /// - Throws: ZCRMSDKError if failed to delete records
    @available(*, deprecated, message: "Use the method deleteRecords method which returns deleted record ids in the completion - deleteRecords( byIds recordIds:, completion: @escaping ( Result.DataResponse< [ Int64 ], BulkAPIResponse > ) -> () )" )
    public func deleteRecords(recordIds: [Int64], completion : @escaping( ResultType.Response< BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler(module: self).deleteRecords( ids : recordIds) { ( result ) in
            completion( result )
        }
    }
    
    /**
      To delete multiple records at a time by using their ID's
     
     - Parameters:
        - recordIds : ID's of the record to be deleted
        - completion :
            - Success : Returns an array of record ID's got deleted and a BulkAPIResponse
            - Failure : Returns Error
     */
    public func deleteRecords(byIds recordIds: [Int64], completion : @escaping( ResultType.DataResponse< [ Int64 ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler(module: self).deleteRecords( ids : recordIds) { ( result ) in
            completion( result )
        }
    }
    
    public func getTags( completion : @escaping ( ResultType.DataResponse< [ ZCRMTag ], BulkAPIResponse > ) -> () )
    {
        TagAPIHandler(module: self).getTags(completion: { ( result ) in
            completion( result )
        } )
    }
    
    public func createTag( tag : ZCRMTag, completion : @escaping ( ResultType.DataResponse< ZCRMTag, APIResponse > ) -> () )
    {
        if !tag.isCreate
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.invalidData) : TAG ID should be nil, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.inValidError( code : ErrorCode.invalidData, message : "TAG ID should be nil", details : nil ) ) )
            return
        }
        TagAPIHandler(module: self).createTag(tag: tag, completion: { ( result ) in
            completion( result )
        } )
    }
    
    public func createTags( tags : [ZCRMTag], completion : @escaping ( ResultType.DataResponse< [ ZCRMTag ], BulkAPIResponse > ) -> () )
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
    
    public func updateTags(tags : [ZCRMTag], completion : @escaping ( ResultType.DataResponse< [ ZCRMTag ], BulkAPIResponse > ) -> () )
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
    
    public func addTags( records : [ ZCRMRecord ], tags : [ String ], completion : @escaping( ResultType.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).addTags( records : records, tags : tags, overWrite : nil ) { ( result ) in
            completion( result )
        }
    }
    
    public func addTags( records : [ ZCRMRecord ], tags : [ String ], overWrite : Bool?, completion : @escaping( ResultType.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).addTags( records : records, tags : tags, overWrite : overWrite ) { ( result ) in
            completion( result )
        }
    }
    
    public func removeTags( records : [ ZCRMRecord ], tags : [ String ], completion : @escaping( ResultType.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : self ).removeTags( records : records, tags : tags ) { ( result ) in
            completion( result )
        }
    }
    
    init( apiName : String )
    {
        self.apiName = apiName
        self.id = String()
        self.isApiSupported = false
    }
}

extension ZCRMModuleDelegate : Hashable
{
    public static func == (lhs: ZCRMModuleDelegate, rhs: ZCRMModuleDelegate) -> Bool {
        let equals : Bool = lhs.apiName == rhs.apiName
        return equals
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine( apiName )
    }
}
