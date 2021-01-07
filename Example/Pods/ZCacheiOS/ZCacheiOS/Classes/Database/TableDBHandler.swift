//
//  TableDBHandler.swift
//  ZCacheiOS
//
//  Created by Rajarajan on 27/11/20.
//

import Foundation

@available(iOS 12.0, *)
class TableDBHandler
{
    let dbHandler = DBHandler()
    var modules = [String]()
    
    func createTables()
    {
        createModulesTable()
        createCurrentUserTable()
        createUsersTable()
        createLayoutsTable()
        createModuleFieldsTable()
        createLayoutSectionsTable()
        createLayoutFieldsTable()
        createSectionFieldsTable()
        createTrashRecordsTable()
        createLookUpRecordsTable()
        createSyncFailedRecordsTable()
        createDynamicModulesTable()
        createLastSyncedTimeTable()
        
        ZCacheLogger.logInfo(message: "<<< Created tables.")
    }
    
    func createModulesTable()
    {
        do
        {
            let idColumn = Column(name: "ID", dataType: "VARCHAR", constraint: ["NOT NULL"])
            let nameColumn = Column(name: "NAME", dataType: "VARCHAR", constraint: ["PRIMARY KEY NOT NULL"])
            let dataColumn = Column(name: "DATA", dataType: "VARCHAR", constraint: ["NOT NULL"])
            let isModifiedColumn = Column(name: "IS_MODIFIED", dataType: "VARCHAR", constraint: ["DEFAULT 0"])
            let hasDataChangesColumn = Column(name: "HAS_DATA_CHANGES", dataType: "VARCHAR", constraint: ["DEFAULT 0"])
            let lastDataSyncedTimeColumn = Column(name: "LAST_DATA_SYNCED_TIME", dataType: "VARCHAR", constraint: ["DEFAULT \"\(getCurrentDateTime())\""])
            let isDataModifiedColumn = Column(name: "IS_DATA_MODIFIED", dataType: "VARCHAR", constraint: ["DEFAULT 0"])
            
            let columns = [idColumn, nameColumn, dataColumn, isModifiedColumn, hasDataChangesColumn, lastDataSyncedTimeColumn, isDataModifiedColumn]
            
            try dbHandler.create(tableName: "_MODULES", columns: columns)
            
        }
        catch let sqliteError
        {
            ZCacheLogger.logError(message: sqliteError.description)
        }
    }
    
    func createCurrentUserTable()
    {
        do
        {
            let idColumn = Column(name: "ID", dataType: "VARCHAR", constraint: ["PRIMARY KEY", "NOT NULL"])
            let orgIdColumn = Column(name: "ORG_ID", dataType: "VARCHAR", constraint: nil)
            let moduleNameColumn = Column(name: "MODULE_NAME", dataType: "VARCHAR", constraint: ["NOT NULL"])
            let dataColumn = Column(name: "DATA", dataType: "VARCHAR", constraint: ["NOT NULL"])
            
            let entryTimeColumn = Column(name: "ENTRY_TIME", dataType: "DATETIME", constraint: nil)
            let expiryTimeColumn = Column(name: "EXPIRY_TIME", dataType: "DATETIME", constraint: nil)
            
            let columns = [idColumn, orgIdColumn, moduleNameColumn, dataColumn, entryTimeColumn, expiryTimeColumn]
            
            try dbHandler.create(tableName: "_CURRENT_USER", columns: columns)
            
        }
        catch let sqliteError
        {
            ZCacheLogger.logError(message: sqliteError.description)
        }
    }
    
    func createUsersTable()
    {
        do
        {
            let idColumn = Column(name: "ID", dataType: "VARCHAR", constraint: ["PRIMARY KEY", "NOT NULL"])
            let orgIdColumn = Column(name: "ORG_ID", dataType: "VARCHAR", constraint: nil)
            let moduleNameColumn = Column(name: "MODULE_NAME", dataType: "VARCHAR", constraint: ["NOT NULL"])
            let dataColumn = Column(name: "DATA", dataType: "VARCHAR", constraint: ["NOT NULL"])
            let entryTimeColumn = Column(name: "ENTRY_TIME", dataType: "DATETIME", constraint: nil)
            let expiryTimeColumn = Column(name: "EXPIRY_TIME", dataType: "DATETIME", constraint: nil)
            
            let columns = [idColumn, orgIdColumn, moduleNameColumn, dataColumn, entryTimeColumn, expiryTimeColumn]
            
            try dbHandler.create(tableName: "_USERS", columns: columns)
            
        }
        catch let sqliteError
        {
            ZCacheLogger.logError(message: sqliteError.description)
        }
    }
    
    func createLayoutsTable()
    {
        do
        {
            let idColumn = Column(name: "ID", dataType: "VARCHAR", constraint: ["PRIMARY KEY", "NOT NULL"])
            let dataColumn = Column(name: "DATA", dataType: "VARCHAR", constraint: ["NOT NULL"])
            let entryTimeColumn = Column(name: "ENTRY_TIME", dataType: "DATETIME", constraint: nil)
            let columns = [idColumn, dataColumn, entryTimeColumn]
            try dbHandler.create(tableName: "_LAYOUTS", columns: columns)
            
        }
        catch let sqliteError
        {
            ZCacheLogger.logError(message: sqliteError.description)
        }
    }
    
    func createModuleFieldsTable()
    {
        do
        {
            let query = """
                CREATE TABLE IF NOT EXISTS _MODULE_FIELDS
                (
                    ID VARCHAR NOT NULL,
                    MODULE_NAME VARCHAR NOT NULL,
                    DATA VARCHAR,
                    ENTRY_TIME DATETIME,
                    PRIMARY KEY(ID, MODULE_NAME)
                )
            """
            try dbHandler.execSQL(query: query)
            
        }
        catch let sqliteError
        {
            ZCacheLogger.logError(message: sqliteError.description)
        }
    }
    
    func createLayoutSectionsTable()
    {
        do
        {
            let query = """
                CREATE TABLE IF NOT EXISTS _LAYOUT_SECTIONS
                (
                    ID VARCHAR,
                    API_NAME VARCHAR NOT NULL,
                    LAYOUT_ID VARCHAR NOT NULL,
                    DATA VARCHAR,
                    ENTRY_TIME DATETIME,
                    PRIMARY KEY(API_NAME, LAYOUT_ID)
                )
            """
            try dbHandler.execSQL(query: query)
            
        }
        catch let sqliteError
        {
            ZCacheLogger.logError(message: sqliteError.description)
        }
    }
    
    func createLayoutFieldsTable()
    {
        do
        {
            let query = """
                CREATE TABLE IF NOT EXISTS _LAYOUT_FIELDS
                (
                    ID VARCHAR NOT NULL,
                    LAYOUT_ID VARCHAR NOT NULL,
                    DATA VARCHAR,
                    ENTRY_TIME DATETIME,
                    PRIMARY KEY(ID, LAYOUT_ID)
                )
            """
            try dbHandler.execSQL(query: query)
            
        }
        catch let sqliteError
        {
            ZCacheLogger.logError(message: sqliteError.description)
        }
    }
    
    func createSectionFieldsTable()
    {
        do
        {
            let query = """
                CREATE TABLE IF NOT EXISTS _SECTION_FIELDS
                (
                    ID VARCHAR NOT NULL,
                    API_NAME VARCHAR NOT NULL,
                    DATA VARCHAR,
                    ENTRY_TIME DATETIME,
                    PRIMARY KEY(ID, API_NAME)
                )
            """
            try dbHandler.execSQL(query: query)
            
        }
        catch let sqliteError
        {
            ZCacheLogger.logError(message: sqliteError.description)
        }
    }
    
    func createTrashRecordsTable()
    {
        do
        {
            let idColumn = Column(name: "ID", dataType: "VARCHAR", constraint: ["PRIMARY KEY", "NOT NULL"])
            let moduleNameColumn = Column(name: "MODULE_NAME", dataType: "VARCHAR", constraint: ["NOT NULL"])
            let deletedByColumn = Column(name: "DELETED_BY", dataType: "VARCHAR", constraint: nil)
            let deletedTimeColumn = Column(name: "DELETED_TIME", dataType: "DATETIME", constraint: nil)
            
            let isRecAvailableInServerColumn = Column(name: "IS_REC_AVAIL_IN_SERVER", dataType: "VARCHAR", constraint: ["DEFAULT 1"])
            
            let isOfflineDataColumn = Column(name: "IS_OFFLINE_DATA", dataType: "VARCHAR", constraint: ["DEFAULT 0"])
            let apiOperationColumn = Column(name: "API_OPERATION", dataType: "VARCHAR", constraint: nil)
            
            let columns = [idColumn, moduleNameColumn, deletedByColumn, deletedTimeColumn, isRecAvailableInServerColumn, isOfflineDataColumn, apiOperationColumn]
            
            try dbHandler.create(tableName: "_TRASH_RECORDS", columns: columns)
            
        }
        catch let sqliteError
        {
            ZCacheLogger.logError(message: sqliteError.description)
        }
    }
    
    func createLookUpRecordsTable()
    {
        do
        {
            let query = """
                CREATE TABLE IF NOT EXISTS _LOOKUP_RECORDS
                (
                    ID VARCHAR NOT NULL,
                    MODULE_NAME VARCHAR NOT NULL,
                    MODIFIED_BY VARCHAR,
                    ENTRY_TIME DATETIME,
                    IS_REC_AVAIL_IN_SERVER VARCHAR DEFAULT 1,
                    IS_OFFLINE_DATA VARCHAR DEFAULT 0,
                    API_OPERATION VARCHAR NOT NULL,
                    LOOKUP_ID VARCHAR NOT NULL,
                    LOOKUP_MODULE VARCHAR NOT NULL,
                    LOOKUP_FIELD VARCHAR NOT NULL,
                    PRIMARY KEY(ID, LOOKUP_ID)
                )
            """
            try dbHandler.execSQL(query: query)
        }
        catch let sqliteError
        {
            ZCacheLogger.logError(message: sqliteError.description)
        }
    }
    
    func createSyncFailedRecordsTable()
    {
        do
        {
            let idColumn = Column(name: "ID", dataType: "VARCHAR", constraint: ["PRIMARY KEY", "NOT NULL"])
            let moduleNameColumn = Column(name: "MODULE_NAME", dataType: "VARCHAR", constraint: ["NOT NULL"])
            let errorCodeColumn = Column(name: "ERROR_CODE", dataType: "VARCHAR", constraint: ["NOT NULL"])
            let errorMessageColumn = Column(name: "ERROR_MESSAGE", dataType: "VARCHAR", constraint: ["NOT NULL"])
            let apiOperationColumn = Column(name: "API_OPERATION", dataType: "VARCHAR", constraint: nil)
            
            let columns = [idColumn, moduleNameColumn, errorCodeColumn, errorMessageColumn, apiOperationColumn]
            
            try dbHandler.create(tableName: "_SYNC_FAILED_RECORDS", columns: columns)
            
        }
        catch let sqliteError
        {
            ZCacheLogger.logError(message: sqliteError.description)
        }
    }
    
    func createDynamicModulesTable()
    {
        do
        {
            let column = Column(name: "NAME", dataType: "VARCHAR", constraint: ["PRIMARY KEY NOT NULL"])
            try dbHandler.create(tableName: "_DYNAMIC_MODULES", columns: [column])
            
        }
        catch let sqliteError
        {
            ZCacheLogger.logError(message: sqliteError.description)
        }
    }
    
    func createLastSyncedTimeTable()
    {
        do
        {
            let column = Column(name: "TIME", dataType: "VARCHAR", constraint: ["NOT NULL"])
            try dbHandler.create(tableName: "_LAST_META_SYNCED_TIME", columns: [column])
        }
        catch let sqliteError
        {
            ZCacheLogger.logError(message: sqliteError.description)
        }
    }
    
    func createRecordTable(moduleName: String, ignoreLookUp: Bool = false, completion: ((VoidResult) throws -> Void)? = nil)
    {
        modules.append(moduleName)
        let mOps = ZCache.getModuleOps(name: moduleName)
        mOps.getFields
        {
            [self] (result: Result<[ZCacheField], ZCacheError>) -> Void in
            switch result
            {
            case .success(let fields):
                do
                {
                var fieldsFromServer = [String]()
                for field in fields
                {
                    if field.lookupModules.isEmpty
                    {
                        if !field.type.rawValue.contains("LOOKUP")
                        {
                            fieldsFromServer.append("\(field.apiName) VARCHAR ")
                        }
                        else
                        {
                            fieldsFromServer.append("\(field.apiName) VARCHAR ")
                            fieldsFromServer.append("\(field.apiName)_LOOKUP_MODULE VARCHAR ")
                        }
                    }
                    else
                    {
                        let lUpModules = field.lookupModules
                        if lUpModules.count == 1
                        {
                            if !ignoreLookUp && !modules.contains(lUpModules[0])
                            {
                                createRecordTable(moduleName: lUpModules[0], ignoreLookUp: ZCacheFieldOps(apiOps: field).shouldIgnoreLookUp())
                            }
                            fieldsFromServer.append("\(field.apiName) VARCHAR ")
                        }
                        else
                        {
                            for lUpModule in lUpModules
                            {
                                if !ignoreLookUp && !modules.contains(lUpModule)
                                {
                                    createRecordTable(moduleName: lUpModule, ignoreLookUp: ZCacheFieldOps(apiOps: field).shouldIgnoreLookUp())
                                }
                            }
                            fieldsFromServer.append("\(field.apiName) VARCHAR ")
                            fieldsFromServer.append("\(field.apiName)_LOOKUP_MODULE VARCHAR ")
                        }
                    }
                }
                    do
                    {
                        if let _ = try ZCache.database?.isTableExists(tableName: moduleName)
                        {
                            let list = (fieldsFromServer.map{ $0 }).joined(separator: ", ")
                            let query = """
                            CREATE TABLE IF NOT EXISTS \(moduleName) ( _ID VARCHAR PRIMARY KEY NOT NULL, _LAYOUT_ID VARCHAR, OFFLINE_OWNER VARCHAR, OFFLINE_CREATED_BY VARCHAR, OFFLINE_CREATED_TIME VARCHAR, OFFLINE_MODIFIED_BY VARCHAR, OFFLINE_MODIFIED_TIME VARCHAR, ENTRY_TIME DATETIME, IS_REC_AVAIL_IN_SERVER VARCHAR default 1, IS_OFFLINE_DATA VARCHAR default 0, API_OPERATION VARCHAR, actual_record_details VARCHAR, modified_record_details VARCHAR, \(list) )
                            """
                            ZCacheLogger.logInfo(message: "<<< Create \(moduleName) Table: \(query)")
                            try dbHandler.execSQL(query: query)
                            try completion?(.success)
                        }
                        else
                        {
                            try completion?(.success)
                        }
                    }
                    catch let error
                    {
                        try? completion?(.failure(ZCacheError.sdkError(code: ErrorCode.dbError, message: error.description, details: nil)))
                    }
            }
            case .failure(let error):
                do
                {
                    ZCacheLogger.logError(message: error.description)
                }
            }
        }
    }
}
