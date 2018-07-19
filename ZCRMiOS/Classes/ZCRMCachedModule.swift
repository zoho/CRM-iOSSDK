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
    
    public override func getLayout( layoutId : Int64, completion : @escaping( APIResponse?, ZCRMLayout?, Error? ) -> () )
    {
        self.getLayout( layoutId : layoutId, refreshCache : false) { ( response, layout, error ) in
            completion( response, layout, error )
        }
    }
    
    func getLayout(layoutId: Int64, refreshCache: Bool, completion : @escaping( APIResponse?, ZCRMLayout?, Error? ) -> () )
    {
        do
        {
            let cachedModuleHandler = ZCRMCachedModuleHandler(moduleAPIName: self.apiName)
            let response : APIResponse = APIResponse()
            if(try !cachedModuleHandler.isLayoutUnderDBMode(refreshCache: refreshCache))
            {
                super.getAllLayouts { ( resp, layouts, err ) in
                    if let error = err
                    {
                        completion( nil, nil, error )
                    }
                    if let allLayouts = layouts
                    {
                        do
                        {
                            try cachedModuleHandler.saveLayoutsToDB( layouts : allLayouts )
                            let layout = try cachedModuleHandler.getLayout(layoutId: layoutId)
                            response.setData(data: layout )
                            completion( response, layout, nil )
                        }
                        catch
                        {
                            completion( nil, nil, ZCRMSDKError.ProcessingError( error.localizedDescription ) )
                        }
                    }
                }
            }
        }
        catch
        {
            completion( nil, nil, ZCRMSDKError.ProcessingError( error.localizedDescription ) )
        }
    }
    
    func getLayoutId(moduleAPIName: String, layoutName: String) throws -> Int64
    {
        let cachedModuleHandler = ZCRMCachedModuleHandler(moduleAPIName: self.apiName)
        return try cachedModuleHandler.getLayoutId(layoutName: moduleAPIName)
    }

    public override func getAllLayouts( completion : @escaping( BulkAPIResponse?, [ ZCRMLayout ]?, Error? ) -> () )
    {
        self.getAllLayouts( refreshCache : false) { ( response, layouts, error ) in
            completion( response, layouts, error )
        }
    }
    
    public func getAllLayouts( refreshCache : Bool, completion : @escaping( BulkAPIResponse?, [ ZCRMLayout ]?, Error? ) -> () )
    {
        do
        {
            let cachedModuleHandler = ZCRMCachedModuleHandler(moduleAPIName: self.apiName)
            let response : BulkAPIResponse = BulkAPIResponse()
            if(try !cachedModuleHandler.isLayoutUnderDBMode(refreshCache: refreshCache))
            {
                super.getAllLayouts { ( resp, layouts, err ) in
                    if let error = err
                    {
                        completion( nil, nil, error )
                    }
                    if let allLayouts = layouts
                    {
                        do
                        {
                            try cachedModuleHandler.saveLayoutsToDB( layouts : allLayouts )
                            let cachedLayouts = try cachedModuleHandler.getAllLayouts()
                            response.setData(data: cachedLayouts )
                            completion( response, cachedLayouts, nil )
                        }
                        catch
                        {
                            completion( nil, nil, ZCRMSDKError.ProcessingError( error.localizedDescription ) )
                        }
                    }
                }
            }
        }
        catch
        {
            completion( nil, nil, ZCRMSDKError.ProcessingError( error.localizedDescription ) )
        }
    }
    
    public override func getCustomView( cvId : Int64, completion : @escaping( APIResponse?, ZCRMCustomView?, Error? ) -> () )
    {
        self.getCustomView( cvId : cvId, refreshCache : false) { ( response, customView, error ) in
            completion( response, customView, error )
        }
    }
    
    public func getCustomView( cvId : Int64, refreshCache : Bool, completion : @escaping( APIResponse?, ZCRMCustomView?, Error? ) -> () )
    {
        do
        {
            let cachedModuleHandler = ZCRMCachedModuleHandler(moduleAPIName: self.apiName)
            let response : APIResponse = APIResponse()
            if(try !cachedModuleHandler.isCustomViewUnderDBMode(refreshCache: refreshCache))
            {
                super.getAllCustomViews { ( resp, customViews, err ) in
                    if let error = err
                    {
                        completion( nil, nil, error )
                    }
                    if let allCVs = customViews
                    {
                        do
                        {
                            try cachedModuleHandler.saveCustomViewsToDB( customViews : allCVs )
                            let customView = try cachedModuleHandler.getCustomView(customViewId: cvId)
                            response.setData(data: customView )
                            completion( response, customView, nil )
                        }
                        catch
                        {
                            completion( nil, nil, ZCRMSDKError.ProcessingError( error.localizedDescription ) )
                        }
                    }
                }
            }
        }
        catch
        {
            completion( nil, nil, ZCRMSDKError.ProcessingError( error.localizedDescription ) )
        }
    }
    
    public override func getAllCustomViews( completion : @escaping( BulkAPIResponse?, [ ZCRMCustomView ]?, Error? ) -> () )
    {
        self.getAllCustomViews( refreshCache : false) { ( response, allCVs, error ) in
            completion( response, allCVs, error )
        }
    }
    
    public func getAllCustomViews( refreshCache : Bool, completion : @escaping( BulkAPIResponse?, [ ZCRMCustomView ]?, Error? ) -> () )
    {
        do
        {
            let cachedModuleHandler = ZCRMCachedModuleHandler(moduleAPIName: self.apiName)
            let response : BulkAPIResponse = BulkAPIResponse()
            if(try !cachedModuleHandler.isCustomViewUnderDBMode(refreshCache: refreshCache))
            {
                super.getAllCustomViews { ( resp, customViews, err ) in
                    if let error = err
                    {
                        completion( nil, nil, error )
                    }
                    if let allCVs = customViews
                    {
                        do
                        {
                            try cachedModuleHandler.saveCustomViewsToDB( customViews : allCVs )
                            let cvs = try cachedModuleHandler.getAllCustomViews()!
                            response.setData( data : cvs )
                            completion( response, cvs, nil )
                        }
                        catch
                        {
                            completion( nil, nil, ZCRMSDKError.ProcessingError( error.localizedDescription ) )
                        }
                    }
                }
            }
        }
        catch
        {
            completion( nil, nil, ZCRMSDKError.ProcessingError( error.localizedDescription ) )
        }
    }
    
    public func refreshMetaData() throws -> ( BulkAPIResponse, [ ZCRMCustomView ], BulkAPIResponse, [ ZCRMLayout ] )
    {
        var customViewResponse : BulkAPIResponse = BulkAPIResponse()
        var layoutResponse : BulkAPIResponse = BulkAPIResponse()
        var customViews : [ ZCRMCustomView ] = [ ZCRMCustomView ]()
        var layouts : [ ZCRMLayout ] = [ ZCRMLayout ]()
        var refreshError :  Error?
        do
        {
            self.getAllCustomViews( refreshCache : true) { ( response, cvList, error ) in
                if let err = error
                {
                    refreshError = ZCRMSDKError.ProcessingError( err.localizedDescription )
                }
                if let bulkResponse = response
                {
                    customViewResponse = bulkResponse
                }
                if let allCVs = cvList
                {
                    customViews = allCVs
                }
            }
            self.getAllLayouts( refreshCache : true) { ( response, layoutList, error ) in
                if let err = error
                {
                    refreshError = ZCRMSDKError.ProcessingError( err.localizedDescription )
                }
                if let bulkResponse = response
                {
                    layoutResponse = bulkResponse
                }
                if let allLayouts = layoutList
                {
                    layouts = allLayouts
                }
            }
            if refreshError != nil
            {
                throw ZCRMSDKError.ProcessingError( refreshError!.localizedDescription )
            }
            return ( customViewResponse, customViews, layoutResponse, layouts )
        }
        catch
        {
            throw ZCRMSDKError.ProcessingError( error.localizedDescription )
        }
    }
}
