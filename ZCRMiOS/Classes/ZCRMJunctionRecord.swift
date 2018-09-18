//
//  ZCRMJunctionRecord.swift
//  ZCRMiOS
//
//  Created by Boopathy P on 23/08/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

import Foundation

open class ZCRMJunctionRecord
{
    public var apiName : String
    public var id : Int64
    public var relatedDetails : [ String : Any ] = [ String : Any ]()

    /// Initialize the instance of a relation with the given record and related record.
    ///
    /// - Parameters:
    ///   - apiName: apiName whose instance to be initialized
    ///   - id: related record id
    public init( apiName : String, id : Int64 )
    {
        self.apiName = apiName
        self.id = id
    }
    
    /// To set the related details between the records
    ///
    /// - Parameters:
    ///   - fieldAPIName: fieldAPIName to which the field value is mapped
    ///   - value: the field value to be mapped
    public func setRelatedData( fieldAPIName : String, value : Any )
    {
        self.relatedDetails[fieldAPIName] = value
    }
}
