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
        public var refresh: Bool = false

        public var sortByField: String?

        public var sortOrder: SortOrder?

        public var page: Int?

        public var perPage: Int?

        public var modifiedSince: String?
        
        public init()
        {
            
        }
    }
}
