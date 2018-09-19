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
    var apiName : String
    public var id : Int64
    public var relatedDetails : [ String : Any ]?

    /// Initialize the instance of a relation with the given record and related record.
    ///
    /// - Parameters:
    ///   - apiName: apiName whose instance to be initialized
    ///   - id: related record id
    internal init( apiName : String, id : Int64 )
    {
        self.apiName = apiName
        self.id = id
    }
    
    /// To set the related details between the records
    ///
    /// - Parameters:
    ///   - fieldAPIName: fieldAPIName to which the field value is mapped
    ///   - value: the field value to be mapped
    public func setField( fieldAPIName : String, value : Any )
    {
        if self.relatedDetails == nil
        {
            self.relatedDetails = [ String : Any ]()
        }
        self.relatedDetails?[fieldAPIName] = value
    }
}
