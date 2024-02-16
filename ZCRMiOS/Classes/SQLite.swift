//
//  SQLite.swift
//  ZCRMiOS
//
//  Created by Sruthi Ravi on 17/08/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

import Foundation
import SQLCipher

public class SQLite
{
    private var dbURL : URL
    private var database : OpaquePointer?
    private var count : Int = 0
    private let serialQueue = DispatchQueue( label : "com.zoho.crm.sdk.sqlite.execCommand", qos : .utility )
    internal let dbType : DBType
    internal static var sharedURL : URL?
    internal var isDBOpened : Bool = false
    
    internal init( dbType : DBType ) throws
    {
        self.dbType = dbType
        if let sharedURL = SQLite.sharedURL
        {
            dbURL = sharedURL
        }
        else
        {
            dbURL =  try FileManager.default.url( for : .documentDirectory, in : .userDomainMask, appropriateFor : nil, create : true )
        }
        dbURL.appendPathComponent( dbType.rawValue )
        ZCRMLogger.logInfo(message: "Database created in path \(dbURL.absoluteString)")
    }
    
    func openDB() throws
    {
        if isDBOpened
        {
            ZCRMLogger.logInfo(message: "DB is already open!!")
            return
        }
        try serialQueue.sync {
            ZCRMLogger.logInfo(message: "db path : \( dbURL.absoluteString )")
            if sqlite3_open_v2( dbURL.absoluteString, &database, SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX, nil) != SQLITE_OK
            {
                ZCRMLogger.logDebug(message: "\(ZCRMErrorCode.internalError) : \( dbURL.absoluteString ) - Unable to open database")
                throw ZCRMError.sdkError( code : ZCRMErrorCode.internalError, message : "\( dbURL.absoluteString ) - Unable to open database", details : nil )
            }
            var rc: Int32
            if ( dbType == .orgData || dbType == .userData || dbType == .analyticsData ) && ZCRMSDKClient.shared.isDBEncrypted &&  ZCRMSDKClient.shared.isDBCacheEnabled
            {
                let password = try getDBPassPhrase()
                rc = sqlite3_key(database, password, Int32(password.utf8CString.count))
                if (rc != SQLITE_OK) {
                    throw ZCRMError.sdkError( code : ZCRMErrorCode.internalError, message : "errmsg", details : nil )
                }
            }
        }
        isDBOpened = true
        ZCRMLogger.logInfo(message: "DB opened successfully!!")
    }
    
    func encryptDB( _ password : String ) throws
    {
        var rc : Int32 = 0
        let dbURLWithoutExtension : URL = dbURL.deletingPathExtension()
        try openDB()
        try serialQueue.sync
        {
            ZCRMLogger.logInfo(message: "db path : \( dbURL.absoluteString )")
            var errorMessage = UnsafeMutablePointer<CChar>(nil)
            let newDBName = String(format: "\( dbURLWithoutExtension.absoluteString )_encrypted.db")
            rc = sqlite3_exec( database, "ATTACH DATABASE '\( newDBName )' AS encrypted KEY '\( password )';", nil, nil, &errorMessage )
            if(rc != SQLITE_OK){
                if let errorMessage = errorMessage
                {
                    ZCRMLogger.logDebug(message: "\(ZCRMErrorCode.internalError) : \( dbURL.absoluteString ) - failed to attach to plaintext database :  \( String( cString: errorMessage ) )")
                    throw ZCRMError.sdkError( code : ZCRMErrorCode.internalError, message : "\( dbURL.absoluteString ) - failed to attach to plaintext database : \( String( cString: errorMessage ) )", details : nil )
                }
            }
            else
            {
                ZCRMLogger.logInfo(message: "attaching done")
            }
            rc = sqlite3_exec( database, "SELECT sqlcipher_export('encrypted');", nil, nil, &errorMessage )
            if(rc != SQLITE_OK){
                if let errorMessage = errorMessage
                {
                    ZCRMLogger.logDebug(message: "\(ZCRMErrorCode.internalError) : \( dbURL.absoluteString ) - failed in doing sqlcipher_export() with: res: \( String( cString: errorMessage ) )")
                    throw ZCRMError.sdkError( code : ZCRMErrorCode.internalError, message : "\( dbURL.absoluteString ) - failed in doing sqlcipher_export() with: res: \( String( cString: errorMessage ) )", details : nil )
                }
            }
            else
            {
                ZCRMLogger.logInfo(message: "sqlcipher_export() done")
            }
            rc = sqlite3_exec( database, "DETACH DATABASE encrypted;", nil, nil, &errorMessage )
            if(rc != SQLITE_OK){
                if let errorMessage = errorMessage
                {
                    ZCRMLogger.logDebug(message: "\(ZCRMErrorCode.internalError) : \( dbURL.absoluteString ) - failed to detach database with: res: \( String( cString: errorMessage ) )")
                    throw ZCRMError.sdkError( code : ZCRMErrorCode.internalError, message : "\( dbURL.absoluteString ) - failed to detach database with: res: \( String( cString: errorMessage ) )", details : nil )
                }
            }
            else
            {
                ZCRMLogger.logInfo(message: "detaching done")
            }
            
            do {
                if FileManager.default.fileExists(atPath: dbURL.absoluteURL.path) {
                    try FileManager.default.removeItem(atPath: dbURL.absoluteURL.path)
                }
                try FileManager.default.moveItem(atPath: "\( dbURLWithoutExtension.path)_encrypted.db", toPath: dbURL.absoluteURL.path)
            } catch {
                ZCRMLogger.logError(message: "\( error )")
            }
            closeDB()
            isDBOpened = false
        }
    }
    
    func decryptDB( _ password : String ) throws
    {
        var rc : Int32 = 0
        let dbURLWithoutExtension : URL = dbURL.deletingPathExtension()
        try openDB()
        try serialQueue.sync
        {
            ZCRMLogger.logInfo(message: "db path : \( dbURL.absoluteString )")
            var errorMessage = UnsafeMutablePointer<CChar>(nil)
            let newDBName = String(format: "\( dbURLWithoutExtension.absoluteString )_decrypted.db")
            
            rc = sqlite3_exec( database, "ATTACH DATABASE '\( newDBName )' AS plaintext KEY '';", nil, nil, &errorMessage )
            if(rc != SQLITE_OK){
                if let errorMessage = errorMessage
                {
                    ZCRMLogger.logDebug(message: "\(ZCRMErrorCode.internalError) : \( dbURL.absoluteString ) - failed to attach to plaintext database :  \( String( cString: errorMessage ) )")
                    throw ZCRMError.sdkError( code : ZCRMErrorCode.internalError, message : "\( dbURL.absoluteString ) - failed to attach to plaintext database : \( String( cString: errorMessage ) )", details : nil )
                }
            }
            else
            {
                ZCRMLogger.logInfo(message: "attaching done")
            }
            rc = sqlite3_exec( database, "SELECT sqlcipher_export('plaintext');", nil, nil, &errorMessage )
            if(rc != SQLITE_OK){
                if let errorMessage = errorMessage
                {
                    ZCRMLogger.logDebug(message: "\(ZCRMErrorCode.internalError) : \( dbURL.absoluteString ) - failed in doing sqlcipher_export() with: res: \( String( cString: errorMessage ) )")
                    throw ZCRMError.sdkError( code : ZCRMErrorCode.internalError, message : "\( dbURL.absoluteString ) - failed in doing sqlcipher_export() with: res: \( String( cString: errorMessage ) )", details : nil )
                }
            }
            else
            {
                ZCRMLogger.logInfo(message: "sqlcipher_export() done")
            }
            rc = sqlite3_exec( database, "DETACH DATABASE plaintext;", nil, nil, &errorMessage )
            if(rc != SQLITE_OK){
                if let errorMessage = errorMessage
                {
                    ZCRMLogger.logDebug(message: "\(ZCRMErrorCode.internalError) : \( dbURL.absoluteString ) - failed to detach database with: res: \( String( cString: errorMessage ) )")
                    throw ZCRMError.sdkError( code : ZCRMErrorCode.internalError, message : "\( dbURL.absoluteString ) - failed to detach database with: res: \( String( cString: errorMessage ) )", details : nil )
                }
            }
            else
            {
                ZCRMLogger.logInfo(message: "detaching done")
            }
            
            do {
                if FileManager.default.fileExists(atPath: dbURL.absoluteURL.path) {
                    try FileManager.default.removeItem(atPath: dbURL.absoluteURL.path)
                }
                try FileManager.default.moveItem(atPath: "\( dbURLWithoutExtension.path)_decrypted.db", toPath: dbURL.absoluteURL.path)
            } catch {
                ZCRMLogger.logError(message: "\( error )")
            }
            closeDB()
            isDBOpened = false
        }
    }
    
    func execSQL( dbCommand : String ) throws
    {
        var prepareStatement : OpaquePointer?
        
        defer {
            sqlite3_finalize(prepareStatement)
        }
        try openDB()
        try serialQueue.sync {
            
            var rc: Int32
            ZCRMLogger.logDebug(message: "Command inside execSQL : \(dbCommand)")
            if sqlite3_prepare_v2(database, dbCommand, -1, &prepareStatement, nil) != SQLITE_OK {
                throw ZCRMError.sdkError( code : ZCRMErrorCode.internalError, message : "errmsg", details : nil )
            }
            
            rc = sqlite3_step(prepareStatement)
            if (rc == SQLITE_ROW || rc == SQLITE_DONE) {
                ZCRMLogger.logInfo(message: " Executed Successfully!!!")
            }
            else
            {
                try self.getDBError()
            }
        }
    }
    
    func getDBError() throws
    {
        let errmsg = String( cString : sqlite3_errmsg( database ) )
        ZCRMLogger.logDebug(message: "\(ZCRMErrorCode.internalError) : \(errmsg)")
        throw ZCRMError.sdkError( code : ZCRMErrorCode.internalError, message : errmsg, details : nil )
    }
    
    func rawQuery( dbCommand : String ) throws -> OpaquePointer?
    {
        var prepareStatement : OpaquePointer?
        try openDB()
        try serialQueue.sync {
            ZCRMLogger.logDebug(message: "Command inside rawQuery : \(dbCommand)")
            if sqlite3_prepare_v2( database, dbCommand, -1, &prepareStatement, nil ) == SQLITE_OK
            {
                ZCRMLogger.logInfo(message: "Executed Successfully!!!")
            }
            else
            {
                try self.getDBError()
            }
        }
        return prepareStatement
    }
    
    func insert(tableName: String, contentValues: Dictionary <String, Any>) throws
    {
        var statement = "\(DBConstant.DML_INSERT) \(DBConstant.KEYS_INTO) " + tableName
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
            ZCRMLogger.logDebug(message: "\(ZCRMErrorCode.internalError) : \(ZCRMErrorMessage.dbDataNotAvailable)")
            throw ZCRMError.inValidError(code : ZCRMErrorCode.internalError, message : ZCRMErrorMessage.dbDataNotAvailable, details : nil )
        }
        defer {
            sqlite3_finalize( prepareStatement )
        }
        return getRowCount(prepareStatement: prepareStatement)
    }
    
    func getRowCount(prepareStatement : OpaquePointer) -> Int
    {
        var count = 0
        while sqlite3_step(prepareStatement) == SQLITE_ROW {
            count += 1
        }
        return count
    }
    
    func isTableExists( tableName : String ) throws -> Bool
    {
        guard let prepareStatement = try self.rawQuery(dbCommand: "\(DBConstant.KEYS_SELECT) name \(DBConstant.KEYS_FROM) sqlite_master \(DBConstant.CLAUSE_WHERE) type = 'table' \(DBConstant.KEYS_AND) name = '\(tableName)'") else
        {
            ZCRMLogger.logDebug(message: "\(ZCRMErrorCode.internalError) : \(ZCRMErrorMessage.dbDataNotAvailable)")
            return false
        }
        defer {
            sqlite3_finalize( prepareStatement )
        }
        var isTableExists : Bool = false
        serialQueue.sync {
            if sqlite3_step(prepareStatement) == SQLITE_ROW {
                if let tblName = sqlite3_column_text( prepareStatement, 0 ), tableName == String( cString: tblName )
                {
                    ZCRMLogger.logDebug(message: "Table exists...")
                    isTableExists = true
                }
            }
        }
        return isTableExists
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
            ZCRMLogger.logDebug(message: "\(ZCRMErrorCode.internalError) : unable to delete Database. Error -> \( error )")
        }
    }
}
