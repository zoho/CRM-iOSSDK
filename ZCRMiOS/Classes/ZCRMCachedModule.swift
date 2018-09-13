//
//  ZCRMCachedModule.swift
//  ZCRMiOS
//
//  Created by Sruthi Ravi on 21/08/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

import Foundation
public class ZCRMCachedModule : ZCRMModule{
    
    private var apiName : String
    
    public override init(moduleAPIName: String)
    {
        self.apiName = moduleAPIName
        super.init(moduleAPIName: moduleAPIName)
    }
    
    public override func getLayout( layoutId : Int64, completion : @escaping( Result.DataResponse< ZCRMLayout, APIResponse > ) -> () )
    {
        self.getLayout( layoutId : layoutId, refreshCache : false) { ( result ) in
            completion( result )
        }
    }
    
    func getLayout(layoutId: Int64, refreshCache: Bool, completion : @escaping( Result.DataResponse< ZCRMLayout, APIResponse > ) -> () )
    {
        do
        {
            let cachedModuleHandler = ZCRMCachedModuleHandler(moduleAPIName: self.apiName)
            let response : APIResponse = APIResponse()
            if(try !cachedModuleHandler.isLayoutUnderDBMode(refreshCache: refreshCache))
            {
                super.getAllLayouts { ( result ) in
                    do{
                        let bulkResponse = try result.resolve()
                        let allLayouts = bulkResponse.data
                        do
                        {
                            try cachedModuleHandler.saveLayoutsToDB( layouts : allLayouts )
                            let layout = try cachedModuleHandler.getLayout(layoutId: layoutId)
                            response.setData(data: layout )
                            completion( .success( layout, response ) )
                        }
                        catch
                        {
                            completion( .failure( ZCRMError.SDKError( code : ErrorCode.INTERNAL_ERROR, message : error.localizedDescription ) ) )
                        }
                        
                    }
                    catch{
                        completion( .failure( typeCastToZCRMError( error ) ) )
                    }
                }
            }
        }
        catch
        {
            completion( .failure( ZCRMError.SDKError( code : ErrorCode.INTERNAL_ERROR, message : error.localizedDescription ) ) )
        }
    }
    
    func getLayoutId(moduleAPIName: String, layoutName: String) throws -> Int64
    {
        let cachedModuleHandler = ZCRMCachedModuleHandler(moduleAPIName: self.apiName)
        return try cachedModuleHandler.getLayoutId(layoutName: moduleAPIName)
    }

    public override func getAllLayouts( completion : @escaping( Result.DataResponse< [ ZCRMLayout ], BulkAPIResponse > ) -> () )
    {
        self.getAllLayouts( refreshCache : false) { ( result ) in
            completion( result )
        }
    }

    public func getAllLayouts( refreshCache : Bool, completion : @escaping( Result.DataResponse< [ ZCRMLayout ], BulkAPIResponse > ) -> () )
    {
        do
        {
            let cachedModuleHandler = ZCRMCachedModuleHandler(moduleAPIName: self.apiName)
            let response : BulkAPIResponse = BulkAPIResponse()
            if(try !cachedModuleHandler.isLayoutUnderDBMode(refreshCache: refreshCache))
            {
                super.getAllLayouts { ( result ) in
                    do{
                        let bulkResponse = try result.resolve()
                        let allLayouts = bulkResponse.data
                        do
                        {
                            try cachedModuleHandler.saveLayoutsToDB( layouts : allLayouts )
                            let cachedLayouts = try cachedModuleHandler.getAllLayouts()
                            response.setData(data: cachedLayouts )
                            completion( .success( cachedLayouts, response ) )
                        }
                        catch
                        {
                            completion( .failure( ZCRMError.SDKError( code : ErrorCode.INTERNAL_ERROR, message : error.localizedDescription ) ) )
                        }
                    }
                    catch{
                        completion( .failure( typeCastToZCRMError( error ) ) )
                    }
                }
            }
        }
        catch
        {
            completion( .failure( ZCRMError.SDKError( code : ErrorCode.INTERNAL_ERROR, message : error.localizedDescription ) ) )
        }
    }
    
    public override func getCustomView( cvId : Int64, completion : @escaping( Result.DataResponse< ZCRMCustomView, APIResponse > ) -> () )
    {
        self.getCustomView( cvId : cvId, refreshCache : false) { ( result ) in
            completion( result )
        }
    }

    public func getCustomView( cvId : Int64, refreshCache : Bool, completion : @escaping( Result.DataResponse< ZCRMCustomView, APIResponse > ) -> () )
    {
        do
        {
            let cachedModuleHandler = ZCRMCachedModuleHandler(moduleAPIName: self.apiName)
            let response : APIResponse = APIResponse()
            if(try !cachedModuleHandler.isCustomViewUnderDBMode(refreshCache: refreshCache))
            {
                super.getAllCustomViews { ( result ) in
                    do{
                        let bulkResponse = try result.resolve()
                        let allCVs = bulkResponse.data
                        do
                        {
                            try cachedModuleHandler.saveCustomViewsToDB( customViews : allCVs )
                            let customView = try cachedModuleHandler.getCustomView(customViewId: cvId)
                            response.setData(data: customView )
                            completion( .success( customView, response ) )
                        }
                        catch
                        {
                            completion( .failure( ZCRMError.SDKError( code : ErrorCode.INTERNAL_ERROR, message : error.localizedDescription ) ) )
                        }
                    }
                    catch{
                        completion( .failure( typeCastToZCRMError( error ) ) )
                    }
                }
            }
        }
        catch
        {
            completion( .failure( ZCRMError.SDKError( code : ErrorCode.INTERNAL_ERROR, message : error.localizedDescription ) ) )
        }
    }
    
    public override func getAllCustomViews( completion : @escaping( Result.DataResponse< [ ZCRMCustomView ], BulkAPIResponse > ) -> () )
    {
        self.getAllCustomViews( refreshCache : false) { ( result ) in
            completion( result )
        }
    }

    public func getAllCustomViews( refreshCache : Bool, completion : @escaping( Result.DataResponse< [ ZCRMCustomView ], BulkAPIResponse > ) -> () )
    {
        do
        {
            let cachedModuleHandler = ZCRMCachedModuleHandler(moduleAPIName: self.apiName)
            let response : BulkAPIResponse = BulkAPIResponse()
            if(try !cachedModuleHandler.isCustomViewUnderDBMode(refreshCache: refreshCache))
            {
                super.getAllCustomViews { ( result ) in
                    do{
                        let bulkResponse = try result.resolve()
                        let allCVs = bulkResponse.data
                        do
                        {
                            try cachedModuleHandler.saveCustomViewsToDB( customViews : allCVs )
                            let cvs = try cachedModuleHandler.getAllCustomViews()!
                            response.setData( data : cvs )
                            completion( .success( cvs, response ) )
                        }
                        catch
                        {
                            completion( .failure( ZCRMError.SDKError( code : ErrorCode.INTERNAL_ERROR, message : error.localizedDescription ) ) )
                        }
                    }
                    catch{
                        completion( .failure( typeCastToZCRMError( error ) ) )
                    }
                }
            }
        }
        catch
        {
            completion( .failure( ZCRMError.SDKError( code : ErrorCode.INTERNAL_ERROR, message : error.localizedDescription ) ) )
        }
    }
}
