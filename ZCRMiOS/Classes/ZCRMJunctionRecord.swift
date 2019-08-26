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
    ///   - fieldAPIName: fieldAPIName to which the field value is mapped
    ///   - value: the field value to be mapped
    @available(*, deprecated, message: "Use the method 'setValue'" )
    public func setField( fieldAPIName : String, value : Any? )
    {
        self.relatedDetails.updateValue( value, forKey : fieldAPIName )
    }
    
    public func setValue( ofField : String, value : Any? )
    {
        self.relatedDetails.updateValue( value, forKey : ofField )
    }
}

extension ZCRMJunctionRecord : Equatable
{
    public static func == ( lhs : ZCRMJunctionRecord, rhs : ZCRMJunctionRecord ) -> Bool {
        var isRelatedDetailsEqual : Bool = false
        for ( key, value ) in lhs.relatedDetails
        {
            if rhs.relatedDetails.hasKey( forKey : key )
            {
                if isEqual( lhs : value, rhs : rhs.relatedDetails[ key ] as Any? )
                {
                    isRelatedDetailsEqual = true
                }
                else
                {
                    return false
                }
            }
            else
            {
                return false
            }
        }
        let equals : Bool = lhs.apiName == rhs.apiName &&
            lhs.id == rhs.id &&
            isRelatedDetailsEqual
        return equals
    }
}
