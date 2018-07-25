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
    
    public override func getLayout( layoutId : Int64, completion : @escaping( ZCRMLayout?, APIResponse?, Error? ) -> () )
    {
        self.getLayout( layoutId : layoutId, refreshCache : false) { ( layout, response, error ) in
            completion( layout, response, error )
        }
    }
    
    func getLayout(layoutId: Int64, refreshCache: Bool, completion : @escaping( ZCRMLayout?, APIResponse?, Error? ) -> () )
    {
        do
        {
            let cachedModuleHandler = ZCRMCachedModuleHandler(moduleAPIName: self.apiName)
            let response : APIResponse = APIResponse()
            if(try !cachedModuleHandler.isLayoutUnderDBMode(refreshCache: refreshCache))
            {
                super.getAllLayouts { ( layouts, resp, err ) in
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
                            completion( layout, response, nil )
                        }
                        catch
                        {
                            completion( nil, nil, ZCRMError.ProcessingError( error.localizedDescription ) )
                        }
                    }
                }
            }
        }
        catch
        {
            completion( nil, nil, ZCRMError.ProcessingError( error.localizedDescription ) )
        }
    }
    
    func getLayoutId(moduleAPIName: String, layoutName: String) throws -> Int64
    {
        let cachedModuleHandler = ZCRMCachedModuleHandler(moduleAPIName: self.apiName)
        return try cachedModuleHandler.getLayoutId(layoutName: moduleAPIName)
    }

    public override func getAllLayouts( completion : @escaping( [ ZCRMLayout ]?, BulkAPIResponse?, Error? ) -> () )
    {
        self.getAllLayouts( refreshCache : false) { ( layouts, response, error ) in
            completion( layouts, response, error )
        }
    }
    
    public func getAllLayouts( refreshCache : Bool, completion : @escaping( [ ZCRMLayout ]?, BulkAPIResponse?, Error? ) -> () )
    {
        do
        {
            let cachedModuleHandler = ZCRMCachedModuleHandler(moduleAPIName: self.apiName)
            let response : BulkAPIResponse = BulkAPIResponse()
            if(try !cachedModuleHandler.isLayoutUnderDBMode(refreshCache: refreshCache))
            {
                super.getAllLayouts { ( layouts, resp, err ) in
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
                            completion( cachedLayouts, response, nil )
                        }
                        catch
                        {
                            completion( nil, nil, ZCRMError.ProcessingError( error.localizedDescription ) )
                        }
                    }
                }
            }
        }
        catch
        {
            completion( nil, nil, ZCRMError.ProcessingError( error.localizedDescription ) )
        }
    }
    
    public override func getCustomView( cvId : Int64, completion : @escaping( ZCRMCustomView?, APIResponse?, Error? ) -> () )
    {
        self.getCustomView( cvId : cvId, refreshCache : false) { ( customView, response, error ) in
            completion( customView, response, error )
        }
    }
    
    public func getCustomView( cvId : Int64, refreshCache : Bool, completion : @escaping( ZCRMCustomView?, APIResponse?, Error? ) -> () )
    {
        do
        {
            let cachedModuleHandler = ZCRMCachedModuleHandler(moduleAPIName: self.apiName)
            let response : APIResponse = APIResponse()
            if(try !cachedModuleHandler.isCustomViewUnderDBMode(refreshCache: refreshCache))
            {
                super.getAllCustomViews { ( customViews, resp, err ) in
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
                            completion( customView, response, nil )
                        }
                        catch
                        {
                            completion( nil, nil, ZCRMError.ProcessingError( error.localizedDescription ) )
                        }
                    }
                }
            }
        }
        catch
        {
            completion( nil, nil, ZCRMError.ProcessingError( error.localizedDescription ) )
        }
    }
    
    public override func getAllCustomViews( completion : @escaping( [ ZCRMCustomView ]?, BulkAPIResponse?, Error? ) -> () )
    {
        self.getAllCustomViews( refreshCache : false) { ( allCVs, response, error ) in
            completion( allCVs, response, error )
        }
    }
    
    public func getAllCustomViews( refreshCache : Bool, completion : @escaping( [ ZCRMCustomView ]?, BulkAPIResponse?, Error? ) -> () )
    {
        do
        {
            let cachedModuleHandler = ZCRMCachedModuleHandler(moduleAPIName: self.apiName)
            let response : BulkAPIResponse = BulkAPIResponse()
            if(try !cachedModuleHandler.isCustomViewUnderDBMode(refreshCache: refreshCache))
            {
                super.getAllCustomViews { ( customViews, resp, err ) in
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
                            completion( cvs, response, nil )
                        }
                        catch
                        {
                            completion( nil, nil, ZCRMError.ProcessingError( error.localizedDescription ) )
                        }
                    }
                }
            }
        }
        catch
        {
            completion( nil, nil, ZCRMError.ProcessingError( error.localizedDescription ) )
        }
    }
    
    public func refreshMetaData() throws -> ( [ ZCRMCustomView ], BulkAPIResponse, [ ZCRMLayout ], BulkAPIResponse )
    {
        var customViewResponse : BulkAPIResponse = BulkAPIResponse()
        var layoutResponse : BulkAPIResponse = BulkAPIResponse()
        var customViews : [ ZCRMCustomView ] = [ ZCRMCustomView ]()
        var layouts : [ ZCRMLayout ] = [ ZCRMLayout ]()
        var refreshError :  Error?
        do
        {
            self.getAllCustomViews( refreshCache : true) { ( cvList, response, error ) in
                if let err = error
                {
                    refreshError = ZCRMError.ProcessingError( err.localizedDescription )
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
            self.getAllLayouts( refreshCache : true) { ( layoutList, response, error ) in
                if let err = error
                {
                    refreshError = ZCRMError.ProcessingError( err.localizedDescription )
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
                throw ZCRMError.ProcessingError( refreshError!.localizedDescription )
            }
            return ( customViews, customViewResponse, layouts, layoutResponse )
        }
        catch
        {
            throw ZCRMError.ProcessingError( error.localizedDescription )
        }
    }
}
