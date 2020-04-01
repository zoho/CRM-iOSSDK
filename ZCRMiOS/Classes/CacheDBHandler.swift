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
    private var pushNotificationTableStatement = PushNotificationsTableStatement()
    private var portalTableStatement = PortalTableStatement()
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
    
    public func createPushNotificationsTable() throws
    {
        let createTableStatement = PushNotificationsTableStatement().createTable()
        try dbRequest.execSQL(dbCommand: createTableStatement)
    }
    
    public func createPortalTable() throws
    {
        let createTableStatement = PortalTableStatement().createTable()
        try dbRequest.execSQL(dbCommand: createTableStatement)
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
    
    func deleteZCRMDashboardComponent( id : String ) throws
    {
        try self.serialQueue.sync {
            if try dbRequest.isTableExists(tableName: DBConstant.TABLE_RESPONSES)
            {
                let deleteStatement = responseTableStatement.deleteComponent( withId : id )
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
    
    func insertInsId( nfId : String, nfChannel : String, insId : String, appId : String, apnsMode : String ) throws
    {
        try deleteInsId()
        try self.serialQueue.sync {
            let insertStatement = pushNotificationTableStatement.insert(nfId: nfId, nfChannel: nfChannel, insId: insId, appId: appId, apnsMode: apnsMode)
            try dbRequest.execSQL(dbCommand: insertStatement)
        }
    }
    
    func fetchInsId() throws -> [ String : String ]
    {
        var pushNotification : [ String : String ] = [ String : String ]()
        let fetchStatement = pushNotificationTableStatement.fetchData()
        try serialQueue.sync {
            if try dbRequest.isTableExists(tableName: DBConstant.TABLE_PUSH_NOTIFICATIONS)
            {
                guard let queryResult : OpaquePointer = try dbRequest.rawQuery(dbCommand: fetchStatement) else
                {
                    throw ZCRMError.inValidError(code : ErrorCode.internalError, message : ErrorMessage.dbDataNotAvailable, details : nil )
                }
                if sqlite3_step( queryResult ) == SQLITE_ROW
                {
                    if let nfId = sqlite3_column_text( queryResult, 0 ), let nfChannel = sqlite3_column_text( queryResult, 1 ), let insId = sqlite3_column_text( queryResult, 2 ), let appId = sqlite3_column_text( queryResult, 3 ), let apnsMode = sqlite3_column_text( queryResult, 4 )
                    {
                        pushNotification["nfId"] = String( cString : nfId )
                        pushNotification["nfChannel"] = String( cString: nfChannel )
                        pushNotification["insId"] = String( cString: insId )
                        pushNotification["appId"] = String( cString: appId )
                        pushNotification["apnsMode"] = String( cString: apnsMode )
                    }
                }
                sqlite3_finalize(queryResult)
                dbRequest.closeDB()
            }
            else
            {
                try self.createPushNotificationsTable()
            }
        }
        return pushNotification
    }
    
    func deleteInsId() throws
    {
        try self.serialQueue.sync {
            if try dbRequest.isTableExists(tableName: DBConstant.TABLE_PUSH_NOTIFICATIONS)
            {
                let deleteStatement = pushNotificationTableStatement.delete()
                try dbRequest.execSQL(dbCommand: deleteStatement)
            }
            else
            {
                try createPushNotificationsTable()
            }
        }
    }
    
    func insertPortal( portalId : Int64 ) throws
    {
        try deletePortal()
        try self.serialQueue.sync {
            let insertStatement = portalTableStatement.insert(portalId: portalId)
            try dbRequest.execSQL(dbCommand: insertStatement)
        }
    }
    
    func fetchPortal() throws -> Int64
    {
        var portalId : Int64 = Int64()
        let fetchStatement = portalTableStatement.fetchData()
        try serialQueue.sync {
            if try dbRequest.isTableExists(tableName: DBConstant.TABLE_CURRENT_PORTAL)
            {
                guard let queryResult : OpaquePointer = try dbRequest.rawQuery(dbCommand: fetchStatement) else
                {
                    throw ZCRMError.inValidError(code : ErrorCode.internalError, message : ErrorMessage.dbDataNotAvailable, details : nil )
                }
                if sqlite3_step( queryResult ) == SQLITE_ROW
                {
                    if let portalIdStr = sqlite3_column_text( queryResult, 0 ), let portal = Int64(String(cString: portalIdStr))
                    {
                        portalId = portal
                    }
                }
                sqlite3_finalize(queryResult)
                dbRequest.closeDB()
            }
            else
            {
                try self.createPortalTable()
            }
        }
        return portalId
    }
    
    func deletePortal() throws
    {
        try self.serialQueue.sync {
            if try dbRequest.isTableExists(tableName: DBConstant.TABLE_CURRENT_PORTAL)
            {
                let deleteStatement = portalTableStatement.delete()
                try dbRequest.execSQL(dbCommand: deleteStatement)
            }
            else
            {
                try self.createPortalTable()
            }
        }
    }
}
