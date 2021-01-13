//
//  ZCacheDownloadDelegate.swift
//  ZCacheiOS
//
//  Created by Rajarajan on 04/01/21.
//

import Foundation

public protocol ZCacheDownloadDelegate
{
    func onModuleDownload(cachedModule: ZCacheModule?, error: ZCacheError?, progressPercentage: Double?)
}
