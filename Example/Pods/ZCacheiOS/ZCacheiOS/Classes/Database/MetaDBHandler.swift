//
//  MetaDBHandler.swift
//  ZCacheiOS
//
//  Created by Rajarajan on 26/11/20.
//

import Foundation

@available(iOS 12.0, *)
class MetaDBHandler {
    
    var moduleName: String
    let dbHandler = DBHandler()
    
    // Inserting & Fetching modules
    func insertModule< T >(module: T)
    {
        insertModules(modules: [module])
    }
    
    func insertModules< T >(modules: [T], isModuleModified: Bool = false)
    {
        do
        {
            for module in modules
            {
                let module = module as! ZCacheModule
                let dict = module.toDicitionary()
                if let dictionary = dict
                {
                    var cv = [ContentValues]()
                    cv.append(ContentValues(sequenceNumber: 1, columnName: "ID", value: module.id))
                    cv.append(ContentValues(sequenceNumber: 2, columnName: "NAME", value: module.apiName))
                    let json = jsonToString(json: dictionary)
                    cv.append(ContentValues(sequenceNumber: 3, columnName: "DATA", value: json))
                    cv.append(ContentValues(sequenceNumber: 4, columnName: "IS_MODIFIED", value: String(isModuleModified)))
                    try dbHandler.delete(tableName: "_MODULES", whereClause: "NAME", values: ["\"\(module.apiName)\""])
                    try dbHandler.insert(tableName: "_MODULES", contentValues: cv)
                }
            }
        }
        catch let sqliteError
        {
            ZCacheLogger.logError(message: sqliteError.description)
        }
    }
    
    func fetchModule< T >(name: String) -> T?
    {
        var module: T?
        var op: OpaquePointer?
        do
        {
            op = try dbHandler.rawQuery(query: "SELECT * FROM _MODULES WHERE NAME=\"\(name)\"")
            if (sqlite3_step(op) == SQLITE_ROW)
            {
                if let op = op
                {
                    if let data = sqlite3_column_text(op, 2)
                    {
                        let dataString = String(cString: data)
                        let moduleInstance = ZCache.getModule()
                        let obj = moduleInstance.toData(jsonString: dataString)
                        if let zCacheModuleObj = obj
                        {
                            if let zCacheModule = zCacheModuleObj as? T
                            {
                                module = zCacheModule
                            }
                            else
                            {
                                throw ZCacheError.invalidError(code: ErrorCode.invalidType, message: ErrorMessage.invalidModuleType, details: nil)
                            }
                        }
                    }
                }
            }
        }
        catch let error
        {
            ZCacheLogger.logError(message: error.description)
        }
        sqlite3_finalize(op)
        dbHandler.closeDB()
        return module
    }
    
    func fetchModule< T >(id: String) -> T?
    {
        var module: T?
        var op: OpaquePointer?
        do
        {
            op = try dbHandler.rawQuery(query: "SELECT * FROM _MODULES WHERE ID=\"\(id)\"")
            if (sqlite3_step(op) == SQLITE_ROW)
            {
                if let op = op
                {
                     if let data = sqlite3_column_text(op, 2)
                     {
                        let dataString = String(cString: data)
                        let moduleInstance = ZCache.getModule()
                        let obj = moduleInstance.toData(jsonString: dataString)
                        if let zCacheModuleObj = obj
                        {
                            if let zCacheModule = zCacheModuleObj as? T
                            {
                                module = zCacheModule
                            }
                            else
                            {
                                throw ZCacheError.invalidError(code: ErrorCode.invalidType, message: ErrorMessage.invalidModuleType, details: nil)
                            }
                        }
                    }
                }
            }
        }
        catch let error
        {
            ZCacheLogger.logError(message: error.description)
        }
        sqlite3_finalize(op)
        dbHandler.closeDB()
        return module
    }
    
    func fetchModules< T >() -> [T]
    {
        var modules: [T] = []
        var op: OpaquePointer?
        do
        {
            op = try dbHandler.rawQuery(query: "SELECT * FROM _MODULES")
            while (sqlite3_step(op) == SQLITE_ROW)
            {
                if let op = op
                {
                    if let data = sqlite3_column_text(op, 2)
                    {
                        let dataString = String(cString: data)
                        let moduleInstance = ZCache.getModule()
                        let obj = moduleInstance.toData(jsonString: dataString)
                        if let zCacheModuleObj = obj
                        {
                            if let zCacheModule = zCacheModuleObj as? T
                            {
                                modules.append(zCacheModule)
                            }
                            else
                            {
                                throw ZCacheError.invalidError(code: ErrorCode.invalidType, message: ErrorMessage.invalidModuleType, details: nil)
                            }
                        }
                    }
                }
            }
        }
        catch let error
        {
            ZCacheLogger.logError(message: error.description)
        }
        sqlite3_finalize(op)
        dbHandler.closeDB()
        return modules
    }
    
    func isMetaSyncTimePresent() throws -> Bool
    {
        var isMetaSyncTimePresent = false
        let op = try dbHandler.rawQuery(query: "SELECT * FROM _LAST_META_SYNCED_TIME")
        if let op = op
        {
            let count = ZCache.database?.getRowCount(prepareStatement: op) ?? 0
            if count > 0
            {
                isMetaSyncTimePresent = true
            }
        }
        sqlite3_finalize(op)
        dbHandler.closeDB()
        return isMetaSyncTimePresent
    }
    
    func getLastMetaSyncedTime() throws -> String?
    {
        var lastMetaSyncedTime: String?
        let op = try dbHandler.rawQuery(query: "SELECT * FROM _LAST_META_SYNCED_TIME")
        if sqlite3_step(op) == SQLITE_ROW
        {
            if let op = op
            {
                if let time = sqlite3_column_text(op, 0)
                {
                    lastMetaSyncedTime = String(cString: time)
                }
            }
        }
        sqlite3_finalize(op)
        dbHandler.closeDB()
        return lastMetaSyncedTime
    }
    
    func updateMetaSyncedTime(modifiedSince: String) throws
    {
        try deleteMetaSyncedTime()
        let cv = ContentValues(sequenceNumber: 1, columnName: "TIME", value: modifiedSince)
        try dbHandler.insert(tableName: "_LAST_META_SYNCED_TIME", contentValues: [cv])
        ZCacheLogger.logInfo(message: "<<< DB :: Updating meta sync time success, time - \(modifiedSince).")
    }
    
    func deleteMetaSyncedTime() throws
    {
        try dbHandler.delete(tableName: "_LAST_META_SYNCED_TIME")
        ZCacheLogger.logInfo(message: "<<< DB :: Deleted meta sync time.")
    }
    
    func getLastDataSyncedTime() throws -> String?
    {
        var lastDataSyncedTime: String?
        let op = try dbHandler.rawQuery(query: "SELECT * FROM _MODULES WHERE NAME=\"\(moduleName)\"")
        if sqlite3_step(op) == SQLITE_ROW
        {
            if let op = op
            {
                if let time = sqlite3_column_text(op, 5)
                {
                    lastDataSyncedTime = String(cString: time)
                }
            }
        }
        sqlite3_finalize(op)
        dbHandler.closeDB()
        return lastDataSyncedTime
    }
    
    func updateDataSyncedTime(modifiedSince: String) throws
    {
        let cv = ContentValues(sequenceNumber: 6, columnName: "LAST_DATA_SYNCED_TIME", value: modifiedSince)
        try dbHandler.update(tableName: "_MODULES", contentValues: [cv], whereClause: "NAME", values: [moduleName])
        ZCacheLogger.logInfo(message: "<<< DB :: Updating data synced time success, time - \(modifiedSince).")
    }
    
    func getModulesCount() throws -> Int
    {
        var count = 0
        let op = try dbHandler.rawQuery(query: "SELECT * FROM _MODULES")
        if let op = op
        {
            count = ZCache.database?.getRowCount(prepareStatement: op) ?? 0
        }
        sqlite3_finalize(op)
        dbHandler.closeDB()
        return count
    }
    
    func isModulePresent(name: String) throws -> Bool
    {
        var isModulePresent = false
        let op = try dbHandler.rawQuery(query: "SELECT * FROM _MODULES WHERE NAME=\"\(name)\"")
        if let op = op
        {
            let count = ZCache.database?.getRowCount(prepareStatement: op) ?? 0
            if count > 0
            {
                isModulePresent = true
            }
            else
            {
                isModulePresent = false
            }
        }
        sqlite3_finalize(op)
        dbHandler.closeDB()
        return isModulePresent
    }
    
    func markModuleModified() throws
    {
        ZCacheLogger.logInfo(message: "Marking module: \(moduleName) as modified.")
        try markModulesModified(modules: [moduleName])
    }
    
    func markModulesModified(modules: [String]) throws
    {
        let modulesAsString = (modules.map{ "\"\($0)\"" }).joined(separator: ", ")
        ZCacheLogger.logInfo(message: "Marking modules: \(modulesAsString) as modified.")
        try dbHandler.execSQL(query: "UPDATE _MODULES SET IS_MODIFIED = 1 WHERE NAME IN (\(modulesAsString))")
        ZCacheLogger.logInfo(message: "<<< DB: Marked modules: \(modulesAsString) as modified.")
    }
    
    func isModuleModified() throws -> Bool
    {
        var isModuleModified = false
        ZCacheLogger.logInfo(message: "Getting 'Is module modified?' info.")
        let op = try dbHandler.rawQuery(query: "SELECT * FROM _MODULES WHERE NAME=\"\(moduleName)\"")
        if (sqlite3_step(op) == SQLITE_ROW)
        {
            if let op = op
            {
                if let isModified = sqlite3_column_text(op, 3)
                {
                    let value = Int( String(cString: isModified) ) ?? 0
                    isModuleModified = value > 0
                }
            }
        }
        sqlite3_finalize(op)
        dbHandler.closeDB()
        return isModuleModified
    }
    
    func resetModuleModifiedTag() throws
    {
        ZCacheLogger.logInfo(message: "Resetting modified tag for the module: \(moduleName).")
        try dbHandler.execSQL(query: "UPDATE _MODULES SET IS_MODIFIED = 0 WHERE NAME=\"\(moduleName)\"")
        ZCacheLogger.logInfo(message: "<<< DB: Modified tag for the module: \(moduleName) has been reset.")
    }
    
    func markDataModified() throws
    {
        ZCacheLogger.logInfo(message: "<<< DB: Marking data modified for the module: \(moduleName).")
        try dbHandler.execSQL(query: "UPDATE _MODULES SET IS_DATA_MODIFIED = 1 WHERE NAME=\"\(moduleName)\"")
        ZCacheLogger.logInfo(message: "<<< DB: Marked data modified for the module: \(moduleName).")
    }
    
    func isDataModified() throws -> Bool
    {
        var isDataModified = false
        ZCacheLogger.logInfo(message: "Getting 'Is Data modified?' info.")
        let op = try dbHandler.rawQuery(query: "SELECT * FROM _MODULES WHERE NAME=\"\(moduleName)\"")
        if (sqlite3_step(op) == SQLITE_ROW)
        {
            if let op = op
            {
                if let isModified = sqlite3_column_text(op, 6)
                {
                    let value = Int( String(cString: isModified) ) ?? 0
                    isDataModified = value > 0
                }
            }
        }
        sqlite3_finalize(op)
        dbHandler.closeDB()
        return isDataModified
    }
    
    func resetDataModifiedTag() throws
    {
        ZCacheLogger.logInfo(message: "Resetting data modified tag for the module: \(moduleName).")
        try dbHandler.execSQL(query: "UPDATE _MODULES SET IS_DATA_MODIFIED = 0 WHERE NAME=\"\(moduleName)\"")
        ZCacheLogger.logInfo(message: "<<< DB: Data modified tag for the module: \(moduleName) has been reset.")
    }
    
    func hasDataChanges() throws -> Bool
    {
        var hasDataChanges = false
        ZCacheLogger.logInfo(message: "Getting 'Has Data Changes?' info for the module: \(moduleName).")
        let op = try dbHandler.rawQuery(query: "SELECT * FROM _MODULES WHERE NAME=\"\(moduleName)\"")
        if (sqlite3_step(op) == SQLITE_ROW)
        {
            if let op = op
            {
                if let hasChanges = sqlite3_column_text(op, 4)
                {
                    let value = Int( String(cString: hasChanges) ) ?? 0
                    hasDataChanges = value > 0
                }
            }
        }
        sqlite3_finalize(op)
        dbHandler.closeDB()
        return hasDataChanges
    }
    
    func markHasDataChanges(hasChanges: Bool) throws
    {
        ZCacheLogger.logInfo(message: "<<< DB: Module: \(moduleName) has data changes? \(hasChanges).")
        if hasChanges
        {
            try dbHandler.execSQL(query: "UPDATE _MODULES SET HAS_DATA_CHANGES = 1 WHERE NAME=\"\(moduleName)\"")
            ZCacheLogger.logInfo(message: "<<< DB: Marked module: \(moduleName) has data changes.")
        }
        else
        {
            try dbHandler.execSQL(query: "UPDATE _MODULES SET HAS_DATA_CHANGES = 0 WHERE NAME=\"\(moduleName)\"")
            ZCacheLogger.logInfo(message: "<<< DB: Marked module: \(moduleName) has no data changes.")
        }
    }
    
    func hasFieldChangesInServer(completion: @escaping ((Result<Bool, ZCacheError>) -> Void))
    {
        let cachedFields: [ZCacheField] = fetchModuleFields()
        var module = ZCache.getModule()
        module.apiName = moduleName
        module.getFieldsFromServer
        {
            (result: Result<[ZCacheField], ZCacheError>) -> Void in
            switch result
            {
            case .success(let fields):
                do
                {
                    if try self.isModulePresent(name: self.moduleName)
                    {
                        let serverFieldNames = fields.map({ $0.apiName })
                        let cachedFieldNames = cachedFields.map({ $0.apiName })
                        let newFields = serverFieldNames.difference(from: cachedFieldNames)
                        if newFields.isEmpty
                        {
                            completion(.success(false))
                        }
                        else
                        {
                            try self.markModuleModified()
                            completion(.success(true))
                        }
                    }
                    else
                    {
                        completion(.success(false))
                    }
                }
                catch let error
                {
                    ZCacheLogger.logError(message: error.description)
                    completion(.failure(ZCacheError.sqliteError(code: ErrorCode.dbError, message: error.description, details: nil)))
                }
            case .failure(let error):
                ZCacheLogger.logError(message: error.description)
                completion(.failure(ZCacheError.sqliteError(code: ErrorCode.dbError, message: error.description, details: nil)))
            }
        }
    }
    
    // Inserting & Fetching users
    func insertUser< T >(user: T, isCurrentUser: Bool = false)
    {
        do
        {
            let user = user as! ZCacheUser
            let dict = user.toDicitionary()
            if let dictionary = dict
            {
                var cv = [ContentValues]()
                cv.append(ContentValues(sequenceNumber: 1, columnName: "ID", value: user.id))
                cv.append(ContentValues(sequenceNumber: 2, columnName: "ORG_ID", value: user.orgId))
                cv.append(ContentValues(sequenceNumber: 3, columnName: "MODULE_NAME", value: user.moduleName))
                
                let json = jsonToString(json: dictionary)
            
                cv.append(ContentValues(sequenceNumber: 4, columnName: "DATA", value: json))
                cv.append(ContentValues(sequenceNumber: 5, columnName: "ENTRY_TIME", value: DBConstant.CURRENT_TIME))
                cv.append(ContentValues(sequenceNumber: 6, columnName: "EXPIRY_TIME", value: DBConstant.VALIDITY_TIME))
                
                if isCurrentUser
                {
                    try dbHandler.delete(tableName: "_CURRENT_USER", whereClause: "ID", values: [user.id])
                    try dbHandler.insert(tableName: "_CURRENT_USER", contentValues: cv)
                }
                else
                {
                    try dbHandler.delete(tableName: "_USERS", whereClause: "ID", values: [user.id])
                    try dbHandler.insert(tableName: "_USERS", contentValues: cv)
                }
            }
        }
        catch let sqliteError
        {
            ZCacheLogger.logError(message: sqliteError.description)
        }
    }
    
    func insertUsers< T >(users: [T])
    {
        do
        {
            for user in users
            {
                let user = user as! ZCacheUser
                let dict = user.toDicitionary()
                if let dictionary = dict
                {
                    var cv = [ContentValues]()
                    cv.append(ContentValues(sequenceNumber: 1, columnName: "ID", value: user.id))
                    cv.append(ContentValues(sequenceNumber: 2, columnName: "ORG_ID", value: user.orgId))
                    cv.append(ContentValues(sequenceNumber: 3, columnName: "MODULE_NAME", value: user.moduleName))
                    
                    let json = jsonToString(json: dictionary)
                
                    cv.append(ContentValues(sequenceNumber: 4, columnName: "DATA", value: json))
                    cv.append(ContentValues(sequenceNumber: 5, columnName: "ENTRY_TIME", value: DBConstant.CURRENT_TIME))
                    cv.append(ContentValues(sequenceNumber: 6, columnName: "EXPIRY_TIME", value: DBConstant.VALIDITY_TIME))
                    
                    try dbHandler.insert(tableName: "_USERS", contentValues: cv)
                }
            }
        }
        catch let sqliteError
        {
            ZCacheLogger.logError(message: sqliteError.description)
        }
    }
    
    func fetchUser< T >(id: String) -> T?
    {
        var user: T?
        var op: OpaquePointer?
        do
        {
            op = try dbHandler.rawQuery(query: "SELECT * FROM _USERS WHERE ID=\"\(id)\"")
            if (sqlite3_step(op) == SQLITE_ROW)
            {
                if let op = op
                {
                    if let data = sqlite3_column_text(op, 3)
                    {
                        let dataString = String(cString: data)
                        let userInstance = ZCache.getUser()
                        let obj = userInstance.toData(jsonString: dataString)
                        if let zCacheUserObj = obj
                        {
                            if let zCacheUser = zCacheUserObj as? T
                            {
                                user = zCacheUser
                            }
                            else
                            {
                                throw ZCacheError.invalidError(code: ErrorCode.invalidType, message: ErrorMessage.invalidUserType, details: nil)
                            }
                        }
                    }
                }
            }
        }
        catch let error
        {
            ZCacheLogger.logError(message: error.description)
        }
        sqlite3_finalize(op)
        dbHandler.closeDB()
        return user
    }
    
    func fetchUsers< T >() -> [T]
    {
        var users: [T] = []
        var op: OpaquePointer?
        do
        {
            op = try dbHandler.rawQuery(query: "SELECT * FROM _USERS")
            while (sqlite3_step(op) == SQLITE_ROW)
            {
                if let op = op
                {
                    if let data = sqlite3_column_text(op, 3)
                    {
                        let dataString = String(cString: data)
                        let userInstance = ZCache.getUser()
                        let obj = userInstance.toData(jsonString: dataString)
                        if let zCacheUserObj = obj
                        {
                            if let zCacheUser = zCacheUserObj as? T
                            {
                                users.append(zCacheUser)
                            }
                            else
                            {
                                throw ZCacheError.invalidError(code: ErrorCode.invalidType, message: ErrorMessage.invalidUserType, details: nil)
                            }
                        }
                    }
                }
            }
        }
        catch let error
        {
            ZCacheLogger.logError(message: error.description)
        }
        sqlite3_finalize(op)
        dbHandler.closeDB()
        return users
    }
    
    func fetchCurrentUser< T >() -> T?
    {
        var user: T?
        var op: OpaquePointer?
        do
        {
            op = try dbHandler.rawQuery(query: "SELECT * FROM _CURRENT_USER")
            if (sqlite3_step(op) == SQLITE_ROW)
            {
                if let op = op
                {
                    if let data = sqlite3_column_text(op, 3)
                    {
                        let dataString = String(cString: data)
                        let userInstance = ZCache.getUser()
                        let obj = userInstance.toData(jsonString: dataString)
                        if let zCacheUserObj = obj
                        {
                            if let zCacheUser = zCacheUserObj as? T
                            {
                                user = zCacheUser
                            }
                            else
                            {
                                throw ZCacheError.invalidError(code: ErrorCode.invalidType, message: ErrorMessage.invalidUserType, details: nil)
                            }
                        }
                    }
                }
            }
        }
        catch let error
        {
            ZCacheLogger.logError(message: error.description)
        }
        sqlite3_finalize(op)
        dbHandler.closeDB()
        return user
    }
    
    // Inserting & Fetching layouts
    func insertLayout< T >(layout: T)
    {
        insertLayouts(layouts: [layout])
    }
    
    func insertLayouts< T >(layouts: [T])
    {
        do
        {
            for layout in layouts
            {
                let layout = layout as! ZCacheLayout
                let dict = layout.toDicitionary()
                
                if let dictionary = dict
                {
                    var cv = [ContentValues]()
                    cv.append(ContentValues(sequenceNumber: 1, columnName: "ID", value: layout.id))
                    
                    let json = jsonToString(json: dictionary)
                
                    cv.append(ContentValues(sequenceNumber: 2, columnName: "DATA", value: json))
                    cv.append(ContentValues(sequenceNumber: 3, columnName: "ENTRY_TIME", value: DBConstant.CURRENT_TIME))
                    
                    try dbHandler.insert(tableName: "_LAYOUTS", contentValues: cv)
                }
            }
        }
        catch let error
        {
            ZCacheLogger.logError(message: error.description)
        }
    }
    
    func fetchLayout< T >(id: String) -> T?
    {
        var layout: T?
        var op: OpaquePointer?
        do
        {
            op = try dbHandler.rawQuery(query: "SELECT * FROM _LAYOUTS WHERE ID=\"\(id)\"")
            if (sqlite3_step(op) == SQLITE_ROW)
            {
                if let op = op
                {
                    if let data = sqlite3_column_text(op, 1)
                    {
                        let dataString = String(cString: data)
                        let layoutInstance = ZCache.getLayout()
                        let obj = layoutInstance?.toData(jsonString: dataString)
                        if let zCacheLayoutObj = obj
                        {
                            if let zCacheLayout = zCacheLayoutObj as? T
                            {
                                layout = zCacheLayout
                            }
                            else
                            {
                                throw ZCacheError.invalidError(code: ErrorCode.invalidType, message: ErrorMessage.invalidLayoutType, details: nil)
                            }
                        }
                    }
                }
            }
        }
        catch let error
        {
            ZCacheLogger.logError(message: error.description)
        }
        sqlite3_finalize(op)
        dbHandler.closeDB()
        return layout
    }
    
    func fetchLayouts< T >() -> [T]
    {
        var layouts: [T] = []
        var op: OpaquePointer?
        do
        {
            op = try dbHandler.rawQuery(query: "SELECT * FROM _LAYOUTS")
            while (sqlite3_step(op) == SQLITE_ROW)
            {
                if let op = op
                {
                    if let data = sqlite3_column_text(op, 1)
                    {
                        let dataString = String(cString: data)
                        let layoutInstance = ZCache.getLayout()
                        let obj = layoutInstance?.toData(jsonString: dataString)
                        if let zCacheLayoutObj = obj
                        {
                            if let zCacheLayout = zCacheLayoutObj as? T
                            {
                                layouts.append(zCacheLayout)
                            }
                            else
                            {
                                throw ZCacheError.invalidError(code: ErrorCode.invalidType, message: ErrorMessage.invalidLayoutType, details: nil)
                            }
                        }
                    }
                }
            }
        }
        catch let error
        {
            ZCacheLogger.logError(message: error.description)
        }
        sqlite3_finalize(op)
        dbHandler.closeDB()
        return layouts
    }
    
    // Inserting & Fetching sections
    func insertLayoutSection< T >(layoutId: String, section: T)
    {
        insertLayoutSections(layoutId: layoutId, sections: [section])
    }
    
    func insertLayoutSections< T >(layoutId: String, sections: [T])
    {
        do
        {
            for section in sections
            {
                let section = section as! ZCacheSection
                let dict = section.toDicitionary()
                
                if let dictionary = dict
                {
                    var cv = [ContentValues]()
                    cv.append(ContentValues(sequenceNumber: 1, columnName: "ID", value: section.id))
                    cv.append(ContentValues(sequenceNumber: 2, columnName: "API_NAME", value: section.apiName))
                    cv.append(ContentValues(sequenceNumber: 2, columnName: "LAYOUT_ID", value: layoutId))

                    let json = jsonToString(json: dictionary)
                
                    cv.append(ContentValues(sequenceNumber: 2, columnName: "DATA", value: json))
                    cv.append(ContentValues(sequenceNumber: 3, columnName: "ENTRY_TIME", value: DBConstant.CURRENT_TIME))
                    
                    try dbHandler.insert(tableName: "_LAYOUT_SECTIONS", contentValues: cv)
                }
            }
        }
        catch let error
        {
            ZCacheLogger.logError(message: error.description)
        }
    }
    
    func fetchLayoutSection< T >(name: String, layoutId: String) -> T?
    {
        var section: T?
        var op: OpaquePointer?
        do
        {
            op = try dbHandler.rawQuery(query: "SELECT * FROM _LAYOUT_SECTIONS WHERE API_NAME=\"\(name)\" AND LAYOUT_ID=\"\(layoutId)\"")
            if (sqlite3_step(op) == SQLITE_ROW)
            {
                if let op = op
                {
                    if let data = sqlite3_column_text(op, 1)
                    {
                        let dataString = String(cString: data)
                        let sectionInstance = ZCache.getSection()
                        let obj = sectionInstance?.toData(jsonString: dataString)
                        if let zCacheSectionObj = obj
                        {
                            if let zCacheSection = zCacheSectionObj as? T
                            {
                                section = zCacheSection
                            }
                            else
                            {
                                throw ZCacheError.invalidError(code: ErrorCode.invalidType, message: ErrorMessage.invalidSectionType, details: nil)
                            }
                        }
                    }
                }
            }
        }
        catch let error
        {
            ZCacheLogger.logError(message: error.description)
        }
        sqlite3_finalize(op)
        dbHandler.closeDB()
        return section
    }
    
    func fetchLayoutSections< T >(layoutId: String) -> [T]
    {
        var sections: [T] = []
        var op: OpaquePointer?
        do
        {
            op = try dbHandler.rawQuery(query: "SELECT * FROM _LAYOUT_SECTIONS WHERE LAYOUT_ID=\"\(layoutId)\"")
            while (sqlite3_step(op) == SQLITE_ROW)
            {
                if let op = op
                {
                    if let data = sqlite3_column_text(op, 1)
                    {
                        let dataString = String(cString: data)
                        let sectionInstance = ZCache.getSection()
                        let obj = sectionInstance?.toData(jsonString: dataString)
                        if let zCacheSectionObj = obj
                        {
                            if let zCacheSection = zCacheSectionObj as? T
                            {
                                sections.append(zCacheSection)
                            }
                            else
                            {
                                throw ZCacheError.invalidError(code: ErrorCode.invalidType, message: ErrorMessage.invalidSectionType, details: nil)
                            }
                        }
                    }
                }
            }
        }
        catch let error
        {
            ZCacheLogger.logError(message: error.description)
        }
        sqlite3_finalize(op)
        dbHandler.closeDB()
        return sections
    }
    
    // Inserting & Fetching module fields
    func insertModuleField< T >(field: T)
    {
        insertModuleFields(fields: [field])
    }
    
    func insertModuleFields< T >(fields: [T])
    {
        do
        {
            for field in fields
            {
                let field = field as! ZCacheField
                let dict = field.toDicitionary()
                
                if let dictionary = dict
                {
                    var cv = [ContentValues]()
                    cv.append(ContentValues(sequenceNumber: 1, columnName: "ID", value: field.id))
                    cv.append(ContentValues(sequenceNumber: 2, columnName: "MODULE_NAME", value: moduleName))
        
                    let json = jsonToString(json: dictionary)
                
                    cv.append(ContentValues(sequenceNumber: 3, columnName: "DATA", value: json))
                    cv.append(ContentValues(sequenceNumber: 4, columnName: "ENTRY_TIME", value: DBConstant.CURRENT_TIME))
                    
                    try dbHandler.execSQL(query: "DELETE FROM _MODULE_FIELDS WHERE ID=\"\(field.id)\" AND MODULE_NAME=\"\(moduleName)\"")
                    try dbHandler.insert(tableName: "_MODULE_FIELDS", contentValues: cv)
                }
            }
        }
        catch let error
        {
            ZCacheLogger.logError(message: error.description)
        }
    }
    
    func fetchModuleField< T >(id: String) -> T?
    {
        var field: T?
        var op: OpaquePointer?
        do
        {
            op = try dbHandler.rawQuery(query: "SELECT * FROM _MODULE_FIELDS WHERE ID=\"\(id)\" AND MODULE_NAME=\"\(moduleName)\"")
            if (sqlite3_step(op) == SQLITE_ROW)
            {
                if let op = op
                {
                    if let data = sqlite3_column_text(op, 1)
                    {
                        let dataString = String(cString: data)
                        let fieldInstance = ZCache.getField()
                        let obj = fieldInstance.toData(jsonString: dataString)
                        if let zCacheFieldObj = obj
                        {
                            if let zCacheField = zCacheFieldObj as? T
                            {
                                field = zCacheField
                            }
                            else
                            {
                                throw ZCacheError.invalidError(code: ErrorCode.invalidType, message: ErrorMessage.invalidFieldType, details: nil)
                            }
                        }
                    }
                }
            }
        }
        catch let error
        {
            ZCacheLogger.logError(message: error.description)
        }
        sqlite3_finalize(op)
        dbHandler.closeDB()
        return field
    }
    
    func fetchModuleFields< T >() -> [T]
    {
        var fields: [T] = []
        var op: OpaquePointer?
        do
        {
            op = try dbHandler.rawQuery(query: "SELECT * FROM _MODULE_FIELDS WHERE MODULE_NAME=\"\(moduleName)\"")
            while (sqlite3_step(op) == SQLITE_ROW)
            {
                if let op = op
                {
                    if let data = sqlite3_column_text(op, 2)
                    {
                        let dataString = String(cString: data)
                        let fieldInstance = ZCache.getField()
                        let obj = fieldInstance.toData(jsonString: dataString)
                        if let zCacheFieldObj = obj
                        {
                            if let zCacheField = zCacheFieldObj as? T
                            {
                                fields.append(zCacheField)
                            }
                            else
                            {
                                throw ZCacheError.invalidError(code: ErrorCode.invalidType, message: ErrorMessage.invalidFieldType, details: nil)
                            }
                        }
                    }
                }
            }
        }
        catch let error
        {
            ZCacheLogger.logError(message: error.description)
        }
        sqlite3_finalize(op)
        dbHandler.closeDB()
        return fields
    }
    
    // Inserting & Fetching layout fields
    func insertLayoutField< T >(layoutId: String, field: T)
    {
        insertLayoutFields(layoutId: layoutId, fields: [field])
    }
    
    func insertLayoutFields< T >(layoutId: String, fields: [T])
    {
        do
        {
            for field in fields
            {
                let field = field as! ZCacheField
                let dict = field.toDicitionary()
                
                if let dictionary = dict
                {
                    var cv = [ContentValues]()
                    cv.append(ContentValues(sequenceNumber: 1, columnName: "ID", value: field.id))
                    cv.append(ContentValues(sequenceNumber: 2, columnName: "LAYOUT_ID", value: layoutId))
        
                    let json = jsonToString(json: dictionary)
                
                    cv.append(ContentValues(sequenceNumber: 3, columnName: "DATA", value: json))
                    cv.append(ContentValues(sequenceNumber: 4, columnName: "ENTRY_TIME", value: DBConstant.CURRENT_TIME))
                    
                    try dbHandler.insert(tableName: "_LAYOUT_FIELDS", contentValues: cv)
                }
            }
        }
        catch let error
        {
            ZCacheLogger.logError(message: error.description)
        }
    }
    
    func fetchLayoutField< T >(id: String, layoutId: String) -> T?
    {
        var field: T?
        var op: OpaquePointer?
        do
        {
            op = try dbHandler.rawQuery(query: "SELECT * FROM _LAYOUT_FIELDS WHERE ID=\"\(id)\" AND LAYOUT_ID=\"\(layoutId)\"")
            if (sqlite3_step(op) == SQLITE_ROW)
            {
                if let op = op
                {
                    if let data = sqlite3_column_text(op, 2)
                    {
                        let dataString = String(cString: data)
                        let fieldInstance = ZCache.getField()
                        let obj = fieldInstance.toData(jsonString: dataString)
                        if let zCacheFieldObj = obj
                        {
                            if let zCacheField = zCacheFieldObj as? T
                            {
                                field = zCacheField
                            }
                            else
                            {
                                throw ZCacheError.invalidError(code: ErrorCode.invalidType, message: ErrorMessage.invalidFieldType, details: nil)
                            }
                        }
                    }
                }
            }
        }
        catch let error
        {
            ZCacheLogger.logError(message: error.description)
        }
        sqlite3_finalize(op)
        dbHandler.closeDB()
        return field
    }
    
    func fetchLayoutFields< T >(layoutId: String) -> [T]
    {
        var fields: [T] = []
        var op: OpaquePointer?
        do
        {
            op = try dbHandler.rawQuery(query: "SELECT * FROM _LAYOUT_FIELDS WHERE LAYOUT_ID=\"\(layoutId)\"")
            while (sqlite3_step(op) == SQLITE_ROW)
            {
                if let op = op
                {
                    if let data = sqlite3_column_text(op, 2)
                    {
                        let dataString = String(cString: data)
                        let fieldInstance = ZCache.getField()
                        let obj = fieldInstance.toData(jsonString: dataString)
                        if let zCacheFieldObj = obj
                        {
                            if let zCacheField = zCacheFieldObj as? T
                            {
                                fields.append(zCacheField)
                            }
                            else
                            {
                                throw ZCacheError.invalidError(code: ErrorCode.invalidType, message: ErrorMessage.invalidFieldType, details: nil)
                            }
                        }
                    }
                }
            }
        }
        catch let error
        {
            ZCacheLogger.logError(message: error.description)
        }
        sqlite3_finalize(op)
        dbHandler.closeDB()
        return fields
    }
    
    // Inserting & Fetching section fields
    func insertSectionField< T >(sectionName: String, field: T)
    {
        insertSectionFields(sectionName: sectionName, fields: [field])
    }
    
    func insertSectionFields< T >(sectionName: String, fields: [T])
    {
        do
        {
            for field in fields
            {
                let field = field as! ZCacheField
                let dict = field.toDicitionary()
                if let dictionary = dict
                {
                    var cv = [ContentValues]()
                    cv.append(ContentValues(sequenceNumber: 1, columnName: "ID", value: field.id))
                    cv.append(ContentValues(sequenceNumber: 2, columnName: "API_NAME", value: sectionName))
        
                    let json = jsonToString(json: dictionary)
                
                    cv.append(ContentValues(sequenceNumber: 3, columnName: "DATA", value: json))
                    cv.append(ContentValues(sequenceNumber: 4, columnName: "ENTRY_TIME", value: DBConstant.CURRENT_TIME))
                    
                    try dbHandler.insert(tableName: "_SECTION_FIELDS", contentValues: cv)
                }
            }
        }
        catch let error
        {
            ZCacheLogger.logError(message: error.description)
        }
    }
    
    func fetchSectionField< T >(id: String, sectionName: String) -> T?
    {
        var field: T?
        var op: OpaquePointer?
        do
        {
            op = try dbHandler.rawQuery(query: "SELECT * FROM _SECTION_FIELDS WHERE API_NAME=\"\(sectionName)\" AND ID=\"\(id)\"")
            if (sqlite3_step(op) == SQLITE_ROW)
            {
                if let op = op
                {
                    if let data = sqlite3_column_text(op, 2)
                    {
                        let dataString = String(cString: data)
                        let fieldInstance = ZCache.getField()
                        let obj = fieldInstance.toData(jsonString: dataString)
                        if let zCacheFieldObj = obj
                        {
                            if let zCacheField = zCacheFieldObj as? T
                            {
                                field = zCacheField
                            }
                            else
                            {
                                throw ZCacheError.invalidError(code: ErrorCode.invalidType, message: ErrorMessage.invalidFieldType, details: nil)
                            }
                        }
                    }
                }
            }
        }
        catch let error
        {
            ZCacheLogger.logError(message: error.description)
        }
        sqlite3_finalize(op)
        dbHandler.closeDB()
        return field
    }
    
    func fetchSectionFields< T >(sectionName: String) -> [T]
    {
        var fields: [T] = []
        var op: OpaquePointer?
        do
        {
            op = try dbHandler.rawQuery(query: "SELECT * FROM _SECTION_FIELDS WHERE API_NAME=\"\(sectionName)\"")
            while (sqlite3_step(op) == SQLITE_ROW)
            {
                if let op = op
                {
                    if let data = sqlite3_column_text(op, 2)
                    {
                        let dataString = String(cString: data)
                        let fieldInstance = ZCache.getField()
                        let obj = fieldInstance.toData(jsonString: dataString)
                        if let zCacheFieldObj = obj
                        {
                            if let zCacheField = zCacheFieldObj as? T
                            {
                                fields.append(zCacheField)
                            }
                            else
                            {
                                throw ZCacheError.invalidError(code: ErrorCode.invalidType, message: ErrorMessage.invalidFieldType, details: nil)
                            }
                        }
                    }
                }
            }
        }
        catch let error
        {
            ZCacheLogger.logError(message: error.description)
        }
        sqlite3_finalize(op)
        dbHandler.closeDB()
        return fields
    }
    
    init(moduleName: String)
    {
        self.moduleName = moduleName
    }
    
    convenience init()
    {
        self.init(moduleName: String())
    }
}
