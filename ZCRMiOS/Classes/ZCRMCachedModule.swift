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
    
    public override func getLayout( layoutId : Int64, completion : @escaping( APIResponse?, Error? ) -> () )
    {
        self.getLayout( layoutId : layoutId, refreshCache : false) { ( response, error ) in
            completion( response, error )
        }
    }
    
    func getLayout(layoutId: Int64, refreshCache: Bool, completion : @escaping( APIResponse?, Error? ) -> () )
    {
        do
        {
            let cachedModuleHandler = ZCRMCachedModuleHandler(moduleAPIName: self.apiName)
            let response : APIResponse = APIResponse()
            if(try !cachedModuleHandler.isLayoutUnderDBMode(refreshCache: refreshCache))
            {
                super.getAllLayouts { ( resp, err ) in
                    if let error = err
                    {
                        completion( nil, error )
                    }
                    if let bulkResponse = resp
                    {
                        do
                        {
                            try cachedModuleHandler.saveLayoutsToDB( layouts : bulkResponse.getData() as! [ ZCRMLayout ] )
                            response.setData(data: try cachedModuleHandler.getLayout(layoutId: layoutId))
                            completion( response, nil )
                        }
                        catch
                        {
                            completion( nil, ZCRMSDKError.ProcessingError( error.localizedDescription ) )
                        }
                    }
                }
            }
        }
        catch
        {
            completion( nil, ZCRMSDKError.ProcessingError( error.localizedDescription ) )
        }
    }
    
    func getLayoutId(moduleAPIName: String, layoutName: String) throws -> Int64
    {
        let cachedModuleHandler = ZCRMCachedModuleHandler(moduleAPIName: self.apiName)
        return try cachedModuleHandler.getLayoutId(layoutName: moduleAPIName)
    }

    public override func getAllLayouts( completion : @escaping( BulkAPIResponse?, Error? ) -> () )
    {
        self.getAllLayouts( refreshCache : false) { ( response, error ) in
            completion( response, error )
        }
    }
    
    public func getAllLayouts( refreshCache : Bool, completion : @escaping( BulkAPIResponse?, Error? ) -> () )
    {
        do
        {
            let cachedModuleHandler = ZCRMCachedModuleHandler(moduleAPIName: self.apiName)
            let response : BulkAPIResponse = BulkAPIResponse()
            if(try !cachedModuleHandler.isLayoutUnderDBMode(refreshCache: refreshCache))
            {
                super.getAllLayouts { ( resp, err ) in
                    if let error = err
                    {
                        completion( nil, error )
                    }
                    if let bulkResponse = resp
                    {
                        do
                        {
                            try cachedModuleHandler.saveLayoutsToDB( layouts : bulkResponse.getData() as! [ ZCRMLayout ] )
                            response.setData(data: try cachedModuleHandler.getAllLayouts())
                            completion( response, nil )
                        }
                        catch
                        {
                            completion( nil, ZCRMSDKError.ProcessingError( error.localizedDescription ) )
                        }
                    }
                }
            }
        }
        catch
        {
            completion( nil, ZCRMSDKError.ProcessingError( error.localizedDescription ) )
        }
    }
    
    public override func getCustomView( cvId : Int64, completion : @escaping( APIResponse?, Error? ) -> () )
    {
        self.getCustomView( cvId : cvId, refreshCache : false) { ( response, error ) in
            completion( response, error )
        }
    }
    
    public func getCustomView( cvId : Int64, refreshCache : Bool, completion : @escaping( APIResponse?, Error? ) -> () )
    {
        do
        {
            let cachedModuleHandler = ZCRMCachedModuleHandler(moduleAPIName: self.apiName)
            let response : APIResponse = APIResponse()
            if(try !cachedModuleHandler.isCustomViewUnderDBMode(refreshCache: refreshCache))
            {
                super.getAllCustomViews { ( resp, err ) in
                    if let error = err
                    {
                        completion( nil, error )
                    }
                    if let bulkResponse = resp
                    {
                        do
                        {
                            try cachedModuleHandler.saveCustomViewsToDB( customViews : bulkResponse.getData() as! [ ZCRMCustomView ] )
                            response.setData(data: try cachedModuleHandler.getCustomView(customViewId: cvId))
                            completion( response, nil )
                        }
                        catch
                        {
                            completion( nil, ZCRMSDKError.ProcessingError( error.localizedDescription ) )
                        }
                    }
                }
            }
        }
        catch
        {
            completion( nil, ZCRMSDKError.ProcessingError( error.localizedDescription ) )
        }
    }
    
    public override func getAllCustomViews( completion : @escaping( BulkAPIResponse?, Error? ) -> () )
    {
        self.getAllCustomViews( refreshCache : false) { ( response, error ) in
            completion( response, error )
        }
    }
    
    public func getAllCustomViews( refreshCache : Bool, completion : @escaping( BulkAPIResponse?, Error? ) -> () )
    {
        do
        {
            let cachedModuleHandler = ZCRMCachedModuleHandler(moduleAPIName: self.apiName)
            let response : BulkAPIResponse = BulkAPIResponse()
            if(try !cachedModuleHandler.isCustomViewUnderDBMode(refreshCache: refreshCache))
            {
                super.getAllCustomViews { ( resp, err ) in
                    if let error = err
                    {
                        completion( nil, error )
                    }
                    if let bulkResponse = resp
                    {
                        do
                        {
                            try cachedModuleHandler.saveCustomViewsToDB( customViews : bulkResponse.getData() as! [ ZCRMCustomView ] )
                            response.setData( data : try cachedModuleHandler.getAllCustomViews()!)
                            completion( response, nil )
                        }
                        catch
                        {
                            completion( nil, ZCRMSDKError.ProcessingError( error.localizedDescription ) )
                        }
                    }
                }
            }
        }
        catch
        {
            completion( nil, ZCRMSDKError.ProcessingError( error.localizedDescription ) )
        }
    }
    
    public func refreshMetaData() throws -> (BulkAPIResponse, BulkAPIResponse)
    {
        var customViews : BulkAPIResponse = BulkAPIResponse()
        var layouts : BulkAPIResponse = BulkAPIResponse()
        var refreshError :  Error?
        do
        {
            self.getAllCustomViews( refreshCache : true) { ( response, error ) in
                if let err = error
                {
                    refreshError = ZCRMSDKError.ProcessingError( err.localizedDescription )
                }
                if let bulkResponse = response
                {
                    customViews = bulkResponse
                }
            }
            self.getAllLayouts( refreshCache : true) { ( response, error ) in
                if let err = error
                {
                    refreshError = ZCRMSDKError.ProcessingError( err.localizedDescription )
                }
                if let bulkResponse = response
                {
                    layouts = bulkResponse
                }
            }
            if refreshError != nil
            {
                throw ZCRMSDKError.ProcessingError( refreshError!.localizedDescription )
            }
            return (customViews, layouts)
        }
        catch
        {
            throw ZCRMSDKError.ProcessingError( error.localizedDescription )
        }
    }
}
