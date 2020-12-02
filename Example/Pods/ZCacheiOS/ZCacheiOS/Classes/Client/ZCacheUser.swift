//
//  ZCacheUser.swift
//  ZCacheiOS
//
//  Created by Rajarajan on 25/11/20.
//

import Foundation

public protocol ZCacheUser {
    var id: String { get set }
    var moduleName: String { get set }
    var orgId: String? { get set }
}
