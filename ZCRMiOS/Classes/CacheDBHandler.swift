//
//  CacheDBHandler.swift
//  ZCRMiOS
//
//  Created by Boopathy P on 09/12/18.
//

import Foundation
import SQLCipher

internal class CacheDBHandler
{
    internal var dbRequest : SQLite
    internal var responseTableStatement = ResponsesTableStatement()
    internal var organizationsTableStatement = OrganizationsTableStatement()
    internal let serialQueue = DispatchQueue( label : "com.zoho.crm.sdk.cacheDBHandler.execCommand", qos : .utility )
    
    init?( dbType : DBType )
    {
        do
        {
            dbRequest = try SQLite(dbType: dbType)
        }
        catch
        {
            ZCRMLogger.logError(message: "Failed to construct CacheDBHandler for DBType : \( dbType )")
            return nil
        }
    }
    
    public func createResponsesTable() throws
    {
        let createTableStatement = ResponsesTableStatement().createTable()
        try dbRequest.execSQL( dbCommand : createTableStatement )
    }
    
    func createOrganizationsTable() throws
    {
        let createTableStatement = OrganizationsTableStatement().createTable()
        try dbRequest.execSQL( dbCommand : createTableStatement )
    }
    
    func insertData( withURL : String, data : String, validity : String, isOrganizationsAPI : Bool ) throws
    {
        try self.deleteData(withURL: withURL, isOrganizationsAPI: isOrganizationsAPI)
        try self.serialQueue.sync {
            var insertStatement : String
            if isOrganizationsAPI
            {
                insertStatement = organizationsTableStatement.insert( withURL, data: data, validity: validity)
            }
            else
            {
                insertStatement = responseTableStatement.insert( withURL, data : data, validity : validity )
            }
            try dbRequest.execSQL( dbCommand : insertStatement )
        }
    }
    
    func fetchData( withURL : String, isOrganizationsAPI : Bool ) throws -> Dictionary< String, Any >?
    {
        var fetchStatement : String
        if isOrganizationsAPI
        {
            
            fetchStatement = organizationsTableStatement.fetchData( withURL )
            
        }
        else
        {
            fetchStatement = responseTableStatement.fetchData( withURL )
        }
        var responseJSON : Dictionary< String, Any >? = nil
        try serialQueue.sync {
            if try dbRequest.isTableExists(tableName: DBConstant.TABLE_RESPONSES) && dbRequest.isTableExists(tableName: DBConstant.ORG_DETAILS)
            {
                guard let queryResult : OpaquePointer = try dbRequest.rawQuery( dbCommand : fetchStatement ) else
                {
                    throw ZCRMError.inValidError(code : ZCRMErrorCode.internalError, message : ZCRMErrorMessage.dbDataNotAvailable, details : nil )
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
            }
            else
            {
                try self.createResponsesTable()
                try self.createOrganizationsTable()
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
                    throw ZCRMError.inValidError(code : ZCRMErrorCode.internalError, message : ZCRMErrorMessage.dbDataNotAvailable, details : nil )
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
            }
            else
            {
                try self.createResponsesTable()
            }
        }
        return responseJSON
    }

    func deleteData( withURL : String, isOrganizationsAPI : Bool ) throws
    {
        try self.serialQueue.sync {
            if try dbRequest.isTableExists(tableName: DBConstant.TABLE_RESPONSES) && dbRequest.isTableExists(tableName: DBConstant.ORG_DETAILS)
            {
                var deleteStatement : String
                if isOrganizationsAPI
                {
                    deleteStatement = organizationsTableStatement.delete( withURL )
                }
                else
                {
                    deleteStatement = responseTableStatement.delete( withURL )
                }
                try dbRequest.execSQL( dbCommand : deleteStatement )
            }
            else
            {
                try self.createResponsesTable()
                try self.createOrganizationsTable()
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
