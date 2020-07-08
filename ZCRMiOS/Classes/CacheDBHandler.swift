//
//  CacheDBHandler.swift
//  ZCRMiOS
//
//  Created by Boopathy P on 09/12/18.
//

import Foundation

internal class CacheDBHandler
{
    private var dbRequest : SQLite
    private var responseTableStatement = ResponsesTableStatement()
    internal let serialQueue = DispatchQueue( label : "com.zoho.crm.sdk.cacheDBHandler.execCommand", qos : .utility )
    
    init( dbName : String ) throws
    {
        dbRequest = try SQLite( dbName : dbName )
    }
    
    public func createResponsesTable() throws
    {
        let createTableStatement = ResponsesTableStatement().createTable()
        try dbRequest.execSQL( dbCommand : createTableStatement )
    }
    
    func insertData( withURL : String, data : String, validity : String ) throws
    {
        try self.deleteData(withURL: withURL)
        try self.serialQueue.sync {
            let insertStatement = responseTableStatement.insert( withURL, data : data, validity : validity )
            try dbRequest.execSQL( dbCommand : insertStatement )
        }
    }
    
    func fetchData( withURL : String ) throws -> Dictionary< String, Any >?
    {
        let fetchStatement = responseTableStatement.fetchData( withURL )
        var responseJSON : Dictionary< String, Any >? = nil
        try serialQueue.sync {
            if try dbRequest.isTableExists(tableName: DBConstant.TABLE_RESPONSES)
            {
                guard let queryResult : OpaquePointer = try dbRequest.rawQuery( dbCommand : fetchStatement ) else
                {
                    throw ZCRMError.inValidError(code : ErrorCode.internalError, message : ErrorMessage.dbDataNotAvailable, details : nil )
                }
                if sqlite3_step( queryResult ) == SQLITE_ROW
                {
                    if let dataQueryResult = sqlite3_column_text( queryResult, 1 )
                    {
                        let dataString = String( cString : dataQueryResult )
                        responseJSON = dataString.toDictionary()
                    }
                }
                sqlite3_finalize(queryResult)
                dbRequest.closeDB()
            }
            else
            {
                try self.createResponsesTable()
            }
        }
        return responseJSON
    }
    
    func searchData( withURL : String ) throws -> Dictionary< String, Dictionary< String, Any > >?
    {
        let searchStatement = responseTableStatement.searchData( withURL )
        var responseJSON : Dictionary< String, Dictionary< String, Any > > = Dictionary< String, Dictionary< String, Any > >()
        try serialQueue.sync {
            if try dbRequest.isTableExists(tableName: DBConstant.TABLE_RESPONSES)
            {
                guard let queryResult : OpaquePointer = try dbRequest.rawQuery( dbCommand : searchStatement ) else
                {
                    throw ZCRMError.inValidError(code : ErrorCode.internalError, message : ErrorMessage.dbDataNotAvailable, details : nil )
                }
                while sqlite3_step( queryResult ) == SQLITE_ROW
                {
                    if let dataQueryStatement = sqlite3_column_text( queryResult, 0 ), let dataQueryResult = sqlite3_column_text( queryResult, 1 )
                    {
                        let dataQuery = String( cString : dataQueryStatement )
                        let dataString = String( cString : dataQueryResult )
                        responseJSON[ dataQuery ] = dataString.toDictionary()
                    }
                }
                sqlite3_finalize(queryResult)
                dbRequest.closeDB()
            }
            else
            {
                try self.createResponsesTable()
            }
        }
        return responseJSON
    }
    
    func deleteData( withURL : String ) throws
    {
        try self.serialQueue.sync {
            if try dbRequest.isTableExists(tableName: DBConstant.TABLE_RESPONSES)
            {
                let deleteStatement = responseTableStatement.delete( withURL )
                try dbRequest.execSQL( dbCommand : deleteStatement )
            }
            else
            {
                try self.createResponsesTable()
            }
        }
    }
    
    func deleteZCRMRecords( withModuleName moduleName : String ) throws
    {
        try self.serialQueue.sync {
            if try dbRequest.isTableExists(tableName: DBConstant.TABLE_RESPONSES)
            {
                let deleteStatement = responseTableStatement.deleteAllRecords(withModuleName: moduleName)
                try dbRequest.execSQL( dbCommand : deleteStatement )
            }
        }
    }
    
    func deleteResponsesCache() throws
    {
        if try dbRequest.isTableExists(tableName: DBConstant.TABLE_RESPONSES)
        {
            let deleteStatement = responseTableStatement.deleteAll()
            try dbRequest.execSQL( dbCommand : deleteStatement )
        }
        else
        {
            try self.createResponsesTable()
        }
    }
}
