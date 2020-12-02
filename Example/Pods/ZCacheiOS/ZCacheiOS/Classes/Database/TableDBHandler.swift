//
//  TableDBHandler.swift
//  ZCacheiOS
//
//  Created by Rajarajan on 27/11/20.
//

import Foundation

@available(iOS 12.0, *)
struct TableDBHandler {
    
    let dbHandler = DBHandler()
    
    func createTables() {
        createModulesTable()
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
    }
    
    func createModulesTable() {
        do {
            let idColumn = Column(name: "ID", dataType: "VARCHAR", constraint: ["NOT NULL"])
            let nameColumn = Column(name: "NAME", dataType: "VARCHAR", constraint: ["PRIMARY KEY NOT NULL"])
            let dataColumn = Column(name: "DATA", dataType: "VARCHAR", constraint: ["NOT NULL"])
            let isModifiedColumn = Column(name: "IS_MODIFIED", dataType: "VARCHAR", constraint: ["DEFAULT 0"])
            let hasDataChangesColumn = Column(name: "HAS_DATA_CHANGES", dataType: "VARCHAR", constraint: ["DEFAULT 0"])
            let lastDataSyncedTimeColumn = Column(name: "LAST_DATA_SYNCED_TIME", dataType: "VARCHAR", constraint: nil)
            let isDataModifiedColumn = Column(name: "IS_DATA_MODIFIED", dataType: "VARCHAR", constraint: ["DEFAULT 0"])
            
            let columns = [idColumn, nameColumn, dataColumn, isModifiedColumn, hasDataChangesColumn, lastDataSyncedTimeColumn, isDataModifiedColumn]
            
            try dbHandler.create(tableName: "_MODULES", columns: columns)
            
        } catch let sqliteError {
            ZCacheLogger.logError(message: sqliteError.description)
        }
    }
    
    func createUsersTable() {
        do {
            let idColumn = Column(name: "ID", dataType: "VARCHAR", constraint: ["PRIMARY KEY", "NOT NULL"])
            let orgIdColumn = Column(name: "ORG_ID", dataType: "VARCHAR", constraint: nil)
            let moduleNameColumn = Column(name: "MODULE_NAME", dataType: "VARCHAR", constraint: ["NOT NULL"])
            let dataColumn = Column(name: "DATA", dataType: "VARCHAR", constraint: ["NOT NULL"])
            
            let isCurrentUserColumn = Column(name: "IS_CURRENT_USER", dataType: "VARCHAR", constraint: ["DEFAULT 0"])
            
            let entryTimeColumn = Column(name: "ENTRY_TIME", dataType: "DATETIME", constraint: nil)
            let expiryTimeColumn = Column(name: "EXPIRY_TIME", dataType: "DATETIME", constraint: nil)
            
            let columns = [idColumn, orgIdColumn, moduleNameColumn, dataColumn, isCurrentUserColumn, entryTimeColumn, expiryTimeColumn]
            
            try dbHandler.create(tableName: "_USERS", columns: columns)
            
        } catch let sqliteError {
            ZCacheLogger.logError(message: sqliteError.description)
        }
    }
    
    func createLayoutsTable() {
        do {
            let idColumn = Column(name: "ID", dataType: "VARCHAR", constraint: ["PRIMARY KEY", "NOT NULL"])
            let dataColumn = Column(name: "DATA", dataType: "VARCHAR", constraint: ["NOT NULL"])
            let entryTimeColumn = Column(name: "ENTRY_TIME", dataType: "DATETIME", constraint: nil)
            
            let columns = [idColumn, dataColumn, entryTimeColumn]
            
            try dbHandler.create(tableName: "_LAYOUTS", columns: columns)
            
        } catch let sqliteError {
            ZCacheLogger.logError(message: sqliteError.description)
        }
    }
    
    func createModuleFieldsTable() {
        do {
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
            
        } catch let sqliteError {
            ZCacheLogger.logError(message: sqliteError.description)
        }
    }
    
    func createLayoutSectionsTable() {
        do {
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
            
        } catch let sqliteError {
            ZCacheLogger.logError(message: sqliteError.description)
        }
    }
    
    func createLayoutFieldsTable() {
        do {
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
            
        } catch let sqliteError {
            ZCacheLogger.logError(message: sqliteError.description)
        }
    }
    
    func createSectionFieldsTable() {
        do {
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
            
        } catch let sqliteError {
            ZCacheLogger.logError(message: sqliteError.description)
        }
    }
    
    func createTrashRecordsTable() {
        do {
            let idColumn = Column(name: "ID", dataType: "VARCHAR", constraint: ["PRIMARY KEY", "NOT NULL"])
            let moduleNameColumn = Column(name: "MODULE_NAME", dataType: "VARCHAR", constraint: ["NOT NULL"])
            let deletedByColumn = Column(name: "DELETED_BY", dataType: "VARCHAR", constraint: nil)
            let deletedTimeColumn = Column(name: "DELETED_TIME", dataType: "DATETIME", constraint: nil)
            
            let isRecAvailableInServerColumn = Column(name: "IS_REC_AVAIL_IN_SERVER", dataType: "VARCHAR", constraint: ["DEFAULT 1"])
            
            let isOfflineDataColumn = Column(name: "IS_OFFLINE_DATA", dataType: "VARCHAR", constraint: ["DEFAULT 0"])
            let apiOperationColumn = Column(name: "API_OPERATION", dataType: "VARCHAR", constraint: nil)
            
            let columns = [idColumn, moduleNameColumn, deletedByColumn, deletedTimeColumn, isRecAvailableInServerColumn, isOfflineDataColumn, apiOperationColumn]
            
            try dbHandler.create(tableName: "_TRASH_RECORDS", columns: columns)
            
        } catch let sqliteError {
            ZCacheLogger.logError(message: sqliteError.description)
        }
    }
    
    func createLookUpRecordsTable() {
        do {
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
            
        } catch let sqliteError {
            ZCacheLogger.logError(message: sqliteError.description)
        }
    }
    
    func createSyncFailedRecordsTable() {
        do {
            let idColumn = Column(name: "ID", dataType: "VARCHAR", constraint: ["PRIMARY KEY", "NOT NULL"])
            let moduleNameColumn = Column(name: "MODULE_NAME", dataType: "VARCHAR", constraint: ["NOT NULL"])
            let errorCodeColumn = Column(name: "ERROR_CODE", dataType: "VARCHAR", constraint: ["NOT NULL"])
            let errorMessageColumn = Column(name: "ERROR_MESSAGE", dataType: "VARCHAR", constraint: ["NOT NULL"])
            let apiOperationColumn = Column(name: "API_OPERATION", dataType: "VARCHAR", constraint: nil)
            
            let columns = [idColumn, moduleNameColumn, errorCodeColumn, errorMessageColumn, apiOperationColumn]
            
            try dbHandler.create(tableName: "_SYNC_FAILED_RECORDS", columns: columns)
            
        } catch let sqliteError {
            ZCacheLogger.logError(message: sqliteError.description)
        }
    }
    
    func createDynamicModulesTable() {
        do {
            let column = Column(name: "NAME", dataType: "VARCHAR", constraint: ["PRIMARY KEY NOT NULL"])
            try dbHandler.create(tableName: "_DYNAMIC_MODULES", columns: [column])
            
        } catch let sqliteError {
            ZCacheLogger.logError(message: sqliteError.description)
        }
    }
    
    func createLastSyncedTimeTable() {
        do {
            let column = Column(name: "TIME", dataType: "VARCHAR", constraint: ["NOT NULL"])
            try dbHandler.create(tableName: "_LAST_META_SYNCED_TIME", columns: [column])
            
        } catch let sqliteError {
            ZCacheLogger.logError(message: sqliteError.description)
        }
    }
}
