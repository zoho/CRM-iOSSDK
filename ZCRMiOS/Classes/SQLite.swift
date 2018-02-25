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
    private let documentsDirectory = FileManager().urls( for : .documentDirectory, in : .userDomainMask ).first!
    private var dbURL : URL
    private var database : OpaquePointer?
    
    public init(dbName : String)
    {
        dbURL = documentsDirectory.appendingPathComponent( dbName )
    }
    
    func openDB() throws
    {
        print( "db path : \( dbURL.absoluteString )" )
        if sqlite3_open( dbURL.absoluteString, &database) != SQLITE_OK
        {
            print( "\( dbURL.absoluteString ) - Unable to open database" )
            throw ZCRMSDKError.ProcessingError( "\( dbURL.absoluteString ) - Unable to open database" )
        }
    
        try enableForeignKey()
    }
    
    func execSQL( dbCommand : String ) throws
    {
        var prepareStatement : OpaquePointer?
        try openDB()
        
        print("Command inside execSQL : \(dbCommand)") //- TODO log
        if sqlite3_prepare_v2( database, dbCommand, -1, &prepareStatement, nil ) == SQLITE_OK
        {
            if sqlite3_step( prepareStatement ) == SQLITE_DONE
            {
                print( ">> Executed Successfully!" )
            }
            else
            {
                let errmsg = String(cString: sqlite3_errmsg(database)!)
                print(">> Error occured, Details : \( errmsg )" )
                throw ZCRMSDKError.ProcessingError(errmsg)
            }
        }
        sqlite3_finalize(prepareStatement)
        
        closeDB()
    }
    
    func rawQuery( dbCommand : String ) throws -> OpaquePointer
    {
        var prepareStatement : OpaquePointer?
        try openDB()
        print("Command inside rawQuery : \(dbCommand)")  //- TODO lo
        if sqlite3_prepare_v2( database, dbCommand, -1, &prepareStatement, nil ) == SQLITE_OK
        {
           print( ">> Executed Successfully!" )
        }
        else
        {
            let errmsg = String(cString: sqlite3_errmsg(database)!)
            print(">> Error occured, Details : \( errmsg )" )
            throw ZCRMSDKError.ProcessingError( errmsg )
        }
        return prepareStatement!
    }
    
    func insert(tableName: String, contentValues: Dictionary <String, Any>) throws
    {
        var statement = "insert into "+tableName
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
        let prepareStatement = try self.rawQuery(dbCommand: "SELECT * FROM \(tableName)")
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
    
    func getPath() -> String
    {
        return self.dbURL.absoluteString
    }
    
    func closeDB()
    {
        sqlite3_close(self.database)
    }
    
    func enableForeignKey() throws
    {
        var prepareStatement : OpaquePointer?
        
        print("Command : \( ZCRMTableDetails.ENABLE_FOREIGN_KEYS )")
        if sqlite3_prepare_v2( database, ZCRMTableDetails.ENABLE_FOREIGN_KEYS, -1, &prepareStatement, nil ) == SQLITE_OK
        {
            if sqlite3_step( prepareStatement ) == SQLITE_DONE
            {
                print( ">> Executed Successfully!" )
            }
            else
            {
                let errmsg = String(cString: sqlite3_errmsg(database)!)
                print(">> Error occured, Details : \( errmsg )" )
                throw ZCRMSDKError.ProcessingError(errmsg)
            }
        }
        sqlite3_finalize(prepareStatement)
    }
}
