//
//  SQLite.swift
//  ZCRMiOS
//
//  Created by Sruthi Ravi on 17/08/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

import Foundation
public class SQLite
{
    private var dbURL : URL
    private var database : OpaquePointer?
    private var count : Int = 0
    private let serialQueue = DispatchQueue( label : "com.zoho.crm.sdk.sqlite.execCommand", qos : .utility )
    
    public init(dbName : String) throws
    {
        dbURL =  try FileManager.default.url( for :  .documentDirectory, in : .userDomainMask, appropriateFor : nil, create : true )
        dbURL.appendPathComponent( dbName )
        ZCRMLogger.logInfo(message: "Database created in path \(dbURL.absoluteString)")
    }
    
    func openDB() throws
    {
        ZCRMLogger.logInfo(message: "db path : \( dbURL.absoluteString )")
        if sqlite3_open_v2( dbURL.absoluteString, &database, SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX, nil) != SQLITE_OK
        {
            ZCRMLogger.logDebug(message: "\(ErrorCode.INTERNAL_ERROR) : \( dbURL.absoluteString ) - Unable to open database")
            throw ZCRMError.SDKError( code : ErrorCode.INTERNAL_ERROR, message : "\( dbURL.absoluteString ) - Unable to open database", details : nil )
        }
        ZCRMLogger.logInfo(message: "DB opened successfully!!")
    }
    
    func execSQL( dbCommand : String ) throws
    {
        var prepareStatement : OpaquePointer?
        try serialQueue.sync {
            try openDB()
            ZCRMLogger.logDebug(message: "Command inside execSQL : \(dbCommand)")
            if sqlite3_prepare_v2( database, dbCommand, -1, &prepareStatement, nil ) == SQLITE_OK
            {
                if sqlite3_step( prepareStatement ) == SQLITE_DONE
                {
                    ZCRMLogger.logInfo(message: " Executed Successfully!!!")
                }
                else
                {
                    sqlite3_finalize(prepareStatement)
                    try self.getDBError()
                }
            }
            else
            {
                sqlite3_finalize(prepareStatement)
                try self.getDBError()
            }
            sqlite3_finalize(prepareStatement)
            closeDB()
        }
    }
    
    func getDBError() throws
    {
        closeDB()
        let errmsg = String( cString : sqlite3_errmsg( database ) )
        ZCRMLogger.logDebug(message: "\(ErrorCode.INTERNAL_ERROR) : \(errmsg)")
        throw ZCRMError.SDKError( code : ErrorCode.INTERNAL_ERROR, message : errmsg, details : nil )
    }
    
    func rawQuery( dbCommand : String ) throws -> OpaquePointer?
    {
        var prepareStatement : OpaquePointer?
        try serialQueue.sync {
            try openDB()
            ZCRMLogger.logDebug(message: "Command inside rawQuery : \(dbCommand)")
            if sqlite3_prepare_v2( database, dbCommand, -1, &prepareStatement, nil ) == SQLITE_OK
            {
                ZCRMLogger.logInfo(message: " Executed Successfully!!!")
            }
            else
            {
                sqlite3_finalize(prepareStatement)
                try self.getDBError()
            }
        }
        return prepareStatement
    }
    
    func insert(tableName: String, contentValues: Dictionary <String, Any>) throws
    {
        var statement = "\(DBConstant.DML_INSERT) \(DBConstant.KEYS_INTO) "+tableName
        var keys = [String]()
        var values = [Any]()
        
        for (key, value) in contentValues {
            
            keys.append(key)
            
            switch value {
            case _ as String: values.append("'" + String(describing: value) + "'" as Any)
            default: values.append(value)
            }
        }
        let val : String = "(" + (values.map{String(describing: $0)}).joined(separator: ",") + ")"
        statement = statement + "(" + (keys.map{String($0)}).joined(separator: ",") + ") values " + val
        
        try self.execSQL(dbCommand: statement)
    }
    
    func noOfRows( tableName : String) throws -> Int
    {
        guard let prepareStatement = try self.rawQuery(dbCommand: "\(DBConstant.KEYS_SELECT) * \(DBConstant.KEYS_FROM) \(tableName)") else
        {
            ZCRMLogger.logDebug(message: "\(ErrorCode.INTERNAL_ERROR) : \(ErrorMessage.DB_DATA_NOT_AVAILABLE)")
            throw ZCRMError.InValidError(code : ErrorCode.INTERNAL_ERROR, message : ErrorMessage.DB_DATA_NOT_AVAILABLE, details : nil )
        }
        return getRowCount(prepareStatement: prepareStatement)
    }
    
    func getRowCount(prepareStatement : OpaquePointer) -> Int
    {
        var count = 0
        while sqlite3_step(prepareStatement) == SQLITE_ROW {
            count += 1
        }
        closeDB()
        return count
    }
    
    func isTableExists( tableName : String ) throws -> Bool
    {
        guard let prepareStatement = try self.rawQuery(dbCommand: "\(DBConstant.KEYS_SELECT) name \(DBConstant.KEYS_FROM) sqlite_master \(DBConstant.CLAUSE_WHERE) type = 'table' \(DBConstant.KEYS_AND) name = '\(tableName)'") else
        {
            closeDB()
            ZCRMLogger.logDebug(message: "\(ErrorCode.INTERNAL_ERROR) : \(ErrorMessage.DB_DATA_NOT_AVAILABLE)")
            return false
        }
        if sqlite3_step(prepareStatement) == SQLITE_ROW {
            if let tblName = sqlite3_column_text( prepareStatement, 0 ), tableName == String( cString: tblName )
            {
                sqlite3_finalize(prepareStatement)
                self.closeDB()
                ZCRMLogger.logDebug(message: "Table exists...")
                return true
            }
        }
        sqlite3_finalize(prepareStatement)
        self.closeDB()
        return false
    }
    
    func getPath() -> String
    {
        return dbURL.absoluteString
    }
    
    func closeDB()
    {
        ZCRMLogger.logInfo(message: "DB closed!!!")
        sqlite3_close(database)
    }
    
    func enableForeignKey() throws
    {
        var prepareStatement : OpaquePointer?
        
        ZCRMLogger.logDebug(message: "Command : \( ZCRMTableDetails.ENABLE_FOREIGN_KEYS )")
        if sqlite3_prepare_v2( database, ZCRMTableDetails.ENABLE_FOREIGN_KEYS, -1, &prepareStatement, nil ) == SQLITE_OK
        {
            if sqlite3_step( prepareStatement ) == SQLITE_DONE
            {
                ZCRMLogger.logInfo(message: " Executed Successfully!!!")
            }
            else
            {
                try self.getDBError()
            }
        }
        sqlite3_finalize(prepareStatement)
    }
    
    func deleteDB()
    {
        do
        {
            try FileManager.default.removeItem( at : dbURL )
        }
        catch
        {
            ZCRMLogger.logDebug(message: "\(ErrorCode.INTERNAL_ERROR) : unable to delete Database. Error -> \( error )")
        }
    }
}
