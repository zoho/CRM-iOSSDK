//
//  Column.swift
//  ZCacheiOS
//
//  Created by Rajarajan on 25/11/20.
//

import Foundation

public struct Column
{
    let name : String
    let dataType : String
    let constraint : [ String ]?
    internal private( set ) var columnAsString : String = String()
    
    init( name : String, dataType : String, constraint : [ String ]? )
    {
        self.name = name
        self.dataType = dataType
        self.constraint = constraint
        self.columnAsString = self.getColumnAsString()
    }
    
    func getColumnAsString() -> String
    {
        if let constraint = constraint
        {
            let columnAsString = "\( name ) \( dataType ) \( constraint.joined( separator : " " ) )"
            return columnAsString
        }
        else
        {
            let columnAsString = "\( name ) \( dataType )"
            return columnAsString
        }
    }
}
