//
//  ZCacheQuery.swift
//  ZCacheiOS
//
//  Created by Rajarajan on 23/12/20.
//

import Foundation

public class ZCacheQuery 
{
    public struct GetRecordParams
    {
        var refresh: Bool = false

        var sortByField: String?

        var sortOrder: SortOrder?

        var page: Int?

        var perPage: Int?

        var modifiedSince: String?
        
        public init()
        {
            
        }
    }
}
