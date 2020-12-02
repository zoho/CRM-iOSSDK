//
//  DBHandler.swift
//  ZCacheiOS
//
//  Created by Rajarajan on 25/11/20.
//

import Foundation


@available(iOS 12.0, *)
struct DBHandler
{
    init()
    {
        
    }
    
    func execSQL(query: String) throws {
        try ZCache.database?.execSQL( dbCommand : query )
    }
    
    func rawQuery(query: String) throws -> OpaquePointer? {
        let op = try ZCache.database?.rawQuery( dbCommand : query )
        
        if sqlite3_step(op) == SQLITE_ROW
        {
            return op
        }
        else
        {
            return nil
        }
    }
    
    func create( tableName : String, columns : [ Column ] ) throws
    {
        let createStatement = "\( DBConstant.DML_CREATE ) TABLE IF NOT EXISTS (\( getColumnsAsStringArray( columns : columns ).joined( separator : ", " ) ));"
        try ZCache.database?.execSQL( dbCommand : createStatement )
    }
    
    func insert( tableName : String, contentValues : [ ContentValues ] ) throws
    {
        try ZCache.database?.insert( tableName : tableName, contentValues : contentValues )
    }
    
    func update( tableName : String, contentValues : [ ContentValues ], whereClause : String, values : [ String ] ) throws
    {
        let updateStatement = "\( DBConstant.DML_UPDATE ) \( tableName ) \( DBConstant.KEYS_SET ) \( getColumnVsValueAsString( contentValues : contentValues ) ) \( DBConstant.CLAUSE_WHERE ) \( whereClause ) = \( values.joined( separator : ", " ) )"
        try ZCache.database?.execSQL( dbCommand : updateStatement )
    }
    
    func delete( tableName : String ) throws
    {
        let deleteStatement = "\( DBConstant.DML_DELETE ) \( DBConstant.KEYS_FROM ) \( tableName )"
        try ZCache.database?.execSQL( dbCommand : deleteStatement )
    }
    
    func delete( tableName : String, whereClause : String, values : [ String ] ) throws
    {
        let deleteStatement = "\( DBConstant.DML_DELETE ) \( DBConstant.KEYS_FROM ) \( tableName ) \( DBConstant.CLAUSE_WHERE ) \( whereClause ) = \( values.joined( separator : ", " ) )"
        try ZCache.database?.execSQL( dbCommand : deleteStatement )
    }
    
    func getColumnsAsStringArray( columns : [ Column ] ) -> [ String ]
    {
        var columnsAsStringArray = [ String ]()
        for column in columns
        {
            columnsAsStringArray.append( column.columnAsString )
        }
        return columnsAsStringArray
    }
    
    func getColumnVsValueAsString( contentValues : [ ContentValues ] ) -> String
    {
        var columnVsValue = [ String ]()
        for contentValue in contentValues
        {
            columnVsValue.append( "\( contentValue.columnName ) = \( contentValue.value ?? "" )" )
        }
        return columnVsValue.joined( separator : ", " )
    }
}
