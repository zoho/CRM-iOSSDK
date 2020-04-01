//
//  ZCRMJunctionRecord.swift
//  ZCRMiOS
//
//  Created by Boopathy P on 23/08/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

import Foundation

open class ZCRMJunctionRecord : ZCRMEntity
{
    var apiName : String
    public internal( set ) var id : Int64
    public var relatedDetails : [ String : Any? ] = [ String : Any? ]()

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
    ///   - ofField: fieldAPIName to which the field value is mapped
    ///   - value: the field value to be mapped
    public func setValue( ofField : String, value : Any? )
    {
        self.relatedDetails.updateValue( value, forKey : ofField )
    }
}

extension ZCRMJunctionRecord : Equatable
{
    public static func == ( lhs : ZCRMJunctionRecord, rhs : ZCRMJunctionRecord ) -> Bool {
        if lhs.relatedDetails.count == rhs.relatedDetails.count {
            for ( key, value ) in lhs.relatedDetails
            {
                if rhs.relatedDetails.hasKey( forKey : key )
                {
                    if !isEqual( lhs : value, rhs : rhs.relatedDetails[ key ] as Any? )
                    {
                        return false
                    }
                }
                else
                {
                    return false
                }
            }
        }
        else
        {
            return false
        }
        let equals : Bool = lhs.apiName == rhs.apiName &&
            lhs.id == rhs.id
        return equals
    }
}
