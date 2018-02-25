//
//  ZCRMJunctionRecord.swift
//  ZCRMiOS
//
//  Created by Boopathy P on 23/08/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

import Foundation

public class ZCRMJunctionRecord
{
    private var apiName : String
    private var id : Int64
    private var relatedDetails : [ String : Any ] = [ String : Any ]()

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
    
    
    /// Returns the Id of the related record.
    ///
    /// - Returns: the Id of the related record
    public func getId() -> Int64
    {
        return self.id
    }
    
    
    /// Returns the API name of the related record.
    ///
    /// - Returns: the API name of the related record
    public func getApiName() -> String
    {
        return self.apiName
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
    
    
    /// To get the related details between the records
    ///
    /// - Returns: related details between the records
    public func getRelatedDetails() -> [ String : Any ]?
    {
        return self.relatedDetails
    }
}
