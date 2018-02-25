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
    
    public override func getLayout(layoutId: Int64) throws -> APIResponse
    {
        return try self.getLayout(layoutId: layoutId, refreshCache: false)
    }
    
    func getLayout(layoutId: Int64, refreshCache: Bool) throws -> APIResponse
    {
        let cachedModuleHandler = ZCRMCachedModuleHandler(moduleAPIName: self.apiName)
        let response : APIResponse = APIResponse()
        if(try !cachedModuleHandler.isLayoutUnderDBMode(refreshCache: refreshCache))
        {
            try cachedModuleHandler.saveLayoutsToDB(layouts: super.getAllLayouts().getData() as! [ZCRMLayout])
        }
        response.setData(data: try cachedModuleHandler.getLayout(layoutId: layoutId))
        return response
    }
    
    func getLayoutId(moduleAPIName: String, layoutName: String) throws -> Int64
    {
        let cachedModuleHandler = ZCRMCachedModuleHandler(moduleAPIName: self.apiName)
        return try cachedModuleHandler.getLayoutId(layoutName: moduleAPIName)
    }

    public override func getAllLayouts() throws -> BulkAPIResponse
    {
        return try self.getAllLayouts(refreshCache: false)
    }
    
    public func getAllLayouts(refreshCache: Bool) throws -> BulkAPIResponse
    {
        let cachedModuleHandler = ZCRMCachedModuleHandler(moduleAPIName: self.apiName)
        let response : BulkAPIResponse = BulkAPIResponse()
        if(try !cachedModuleHandler.isLayoutUnderDBMode(refreshCache: refreshCache))
        {
            try cachedModuleHandler.saveLayoutsToDB(layouts: super.getAllLayouts().getData() as! [ZCRMLayout])
        }
        response.setData(data: try cachedModuleHandler.getAllLayouts())
        return response
    }
    
    public override func getCustomView(cvId: Int64) throws -> APIResponse
    {
        return try self.getCustomView(cvId: cvId, refreshCache: false)
    }
    
    public func getCustomView(cvId: Int64, refreshCache: Bool) throws -> APIResponse
    {
        let cachedModuleHandler = ZCRMCachedModuleHandler(moduleAPIName: self.apiName)
        let response : APIResponse = APIResponse()
        if(try !cachedModuleHandler.isCustomViewUnderDBMode(refreshCache: refreshCache))
        {
            try cachedModuleHandler.saveCustomViewsToDB(customViews: super.getAllCustomViews().getData() as! [ZCRMCustomView])
        }
        response.setData(data: try cachedModuleHandler.getCustomView(customViewId: cvId))
        return response
    }
    
    public override func getAllCustomViews() throws -> BulkAPIResponse
    {
        return try self.getAllCustomViews(refreshCache: false)
    }
    
    public func getAllCustomViews(refreshCache: Bool) throws -> BulkAPIResponse
    {
        let cachedModuleHandler = ZCRMCachedModuleHandler(moduleAPIName: self.apiName)
        let response : BulkAPIResponse = BulkAPIResponse()
        if(try !cachedModuleHandler.isCustomViewUnderDBMode(refreshCache: refreshCache))
        {
            try cachedModuleHandler.saveCustomViewsToDB(customViews: super.getAllCustomViews().getData() as! [ZCRMCustomView])
        }
        response.setData(data: try cachedModuleHandler.getAllCustomViews()!)
        return response
    }
    
    public func refreshMetaData() throws -> (BulkAPIResponse, BulkAPIResponse)
    {
        let customViews = try self.getAllCustomViews(refreshCache: true)
        let layouts = try self.getAllLayouts(refreshCache: true)
        return (customViews, layouts)
    }
}
