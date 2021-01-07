//
//  SQLite.swift
//  ZCacheiOS
//
//  Created by Rajarajan on 25/11/20.
//

import Foundation
import SQLite3

struct SQLite
{
    private var dbURL : URL
    private var database : OpaquePointer?
    private var count : Int = 0
    private let serialQueue = DispatchQueue( label : "com.zoho.cache.sdk.sqlite.execCommand", qos : .utility )
    private let SQLITE_STATIC = unsafeBitCast( 0, to : sqlite3_destructor_type.self )
    private let SQLITE_TRANSIENT = unsafeBitCast( -1, to : sqlite3_destructor_type.self )
    
    internal init() throws
    {
        dbURL =  try FileManager.default.url( for :  .documentDirectory, in : .userDomainMask, appropriateFor : nil, create : true )
        dbURL.appendPathComponent( "zCacheSDK.db" )
        ZCacheLogger.logError( message : "Database created in path \( dbURL.absoluteString )" )
    }
    
    private mutating func openDB() throws
    {
        ZCacheLogger.logInfo( message : "db path : \( dbURL.absoluteString )" )
        if sqlite3_open_v2( dbURL.absoluteString, &database, SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX, nil ) != SQLITE_OK
        {
            ZCacheLogger.logDebug( message : "\( ErrorCode.internalError ) : \( dbURL.absoluteString ) - Unable to open database" )
            throw ZCacheError.sdkError( code : ErrorCode.internalError, message : "\( dbURL.absoluteString ) - Unable to open database", details : nil )
        }
        ZCacheLogger.logInfo( message : "DB opened successfully!!" )
    }
    
    mutating func execSQL( dbCommand : String ) throws
    {
        var prepareStatement : OpaquePointer?
        
        defer {
            sqlite3_finalize( prepareStatement )
            closeDB()
        }
        
        try serialQueue.sync {
            try openDB()
            ZCacheLogger.logDebug( message : "Command inside execSQL : \( dbCommand )" )
            if sqlite3_prepare_v2( database, dbCommand, -1, &prepareStatement, nil ) == SQLITE_OK
            {
                if sqlite3_step( prepareStatement ) == SQLITE_DONE
                {
                    ZCacheLogger.logInfo( message : "Executed Successfully!!!" )
                }
                else
                {
                    try self.getDBError()
                }
            }
            else
            {
                try self.getDBError()
            }
        }
    }
    
    private func getDBError() throws
    {
        let errmsg = String( cString : sqlite3_errmsg( database ) )
        ZCacheLogger.logDebug( message : "\( ErrorCode.internalError ) : \( errmsg )" )
        throw ZCacheError.sdkError( code : ErrorCode.internalError, message : errmsg, details : nil )
    }
    
    mutating func rawQuery( dbCommand : String ) throws -> OpaquePointer?
    {
        var prepareStatement : OpaquePointer?
        try serialQueue.sync {
            try openDB()
            ZCacheLogger.logDebug( message : "Command inside rawQuery : \( dbCommand )" )
            if sqlite3_prepare_v2( database, dbCommand, -1, &prepareStatement, nil ) == SQLITE_OK
            {
                ZCacheLogger.logInfo( message : "Executed Successfully!!!" )
            }
            else
            {
                sqlite3_finalize( prepareStatement )
                try self.getDBError()
            }
        }
        return prepareStatement
    }
    
    mutating func insert( tableName : String, contentValues : [ ContentValues ] ) throws
    {
        var prepareStatement : OpaquePointer?
        let placeHolder = Array( repeating : "?", count : contentValues.count )
        let insertStatement = "\( DBConstant.DML_INSERT ) \( DBConstant.KEYS_INTO ) \( tableName ) (\( getColumnsAsString( contentValues : contentValues ) )) \( DBConstant.KEYS_VALUES ) (\( placeHolder.joined( separator : ", " ) ));"
        ZCacheLogger.logDebug( message : "Command inside insert : \( insertStatement )" )
        
        defer {
            sqlite3_finalize( prepareStatement )
            closeDB()
        }
        
        try serialQueue.sync {
            try openDB()
            if sqlite3_prepare_v2( database, insertStatement, -1, &prepareStatement, nil ) == SQLITE_OK
            {
                for contentValue in contentValues
                {
                    if contentValue.value == nil
                    {
                        if sqlite3_bind_null( prepareStatement, Int32( contentValue.sequenceNumber ) ) != SQLITE_OK
                        {
                            try self.getDBError()
                        }
                    }
                    else
                    {
                        if sqlite3_bind_text( prepareStatement, Int32( contentValue.sequenceNumber ), contentValue.value, -1, SQLITE_TRANSIENT ) != SQLITE_OK
                        {
                            try self.getDBError()
                        }
                    }
                }
                if sqlite3_step( prepareStatement ) == SQLITE_DONE
                {
                    ZCacheLogger.logInfo( message : "Executed Successfully!!!" )
                }
                else
                {
                    try self.getDBError()
                }
            }
            else
            {
                try self.getDBError()
            }
        }
    }
    
    private func getColumnsAsString( contentValues : [ ContentValues ] ) -> String
    {
        return (contentValues.map{ $0.columnName }).joined(separator: ", ")
    }
    
    mutating func noOfRows( tableName : String ) throws -> Int
    {
        guard let prepareStatement = try self.rawQuery( dbCommand : "\( DBConstant.KEYS_SELECT ) * \( DBConstant.KEYS_FROM ) \( tableName )" ) else
        {
            ZCacheLogger.logDebug( message : "\( ErrorCode.internalError ) : \( ErrorMessage.dbDataNotAvailable )" )
            throw ZCacheError.invalidError( code : ErrorCode.internalError, message : ErrorMessage.dbDataNotAvailable, details : nil )
        }
        defer {
            sqlite3_finalize( prepareStatement )
            closeDB()
        }
        return getRowCount( prepareStatement : prepareStatement )
    }
    
    func getRowCount( prepareStatement : OpaquePointer ) -> Int
    {
        var count = 0
        while sqlite3_step( prepareStatement ) == SQLITE_ROW {
            count += 1
        }
        return count
    }
    
    mutating func isTableExists( tableName : String ) throws -> Bool
    {
        guard let prepareStatement = try self.rawQuery( dbCommand : "\( DBConstant.KEYS_SELECT ) name \( DBConstant.KEYS_FROM ) sqlite_master \( DBConstant.CLAUSE_WHERE ) type = 'table' \( DBConstant.KEYS_AND ) name = '\( tableName )'" ) else
        {
            closeDB()
            ZCacheLogger.logDebug( message : "\( ErrorCode.internalError ) : \( ErrorMessage.dbDataNotAvailable )" )
            return false
        }
        defer {
            sqlite3_finalize( prepareStatement )
            self.closeDB()
        }
        if sqlite3_step( prepareStatement ) == SQLITE_ROW {
            if let tblName = sqlite3_column_text( prepareStatement, 0 ), tableName == String( cString : tblName )
            {
                ZCacheLogger.logDebug( message : "Table exists..." )
                return true
            }
        }
        return false
    }
    
    func getPath() -> String
    {
        return dbURL.absoluteString
    }
    
    func closeDB()
    {
        ZCacheLogger.logInfo( message : "DB closed!!!" )
        sqlite3_close( database )
    }
    
    func deleteDB()
    {
        do
        {
            try FileManager.default.removeItem( at : dbURL )
        }
        catch
        {
            ZCacheLogger.logDebug( message : "\( ErrorCode.internalError ) : unable to delete Database. Error -> \( error )" )
        }
    }
}
