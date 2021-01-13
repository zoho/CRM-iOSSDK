//
//  EntityDBHandler.swift
//  ZCacheiOS
//
//  Created by Rajarajan on 11/12/20.
//

import Foundation

@available(iOS 12.0, *)
class EntityDBHandler
{
    let moduleName: String
    
    let dbHandler = DBHandler()
    
    var fieldsMap: [String: [ZCacheField]] = [:]
    
    var recordsAvailabiltyMap: [String: Bool] = [:]
    
    func execute< T >(query: String, completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {
        var records: [T] = []
        var op: OpaquePointer?
        do
        {
            op = try dbHandler.rawQuery(query: query)
            while (sqlite3_step(op) == SQLITE_ROW)
            {
                if let op = op
                {
                    if let data = sqlite3_column_text(op, 12)
                    {
                        let record: T? = try fetchRecord(data: data)
                        if let record = record
                        {
                            records.append(record)
                        }
                    }
                    else if let data = sqlite3_column_text(op, 11)
                    {
                        let record: T? = try fetchRecord(data: data)
                        if let record = record
                        {
                            records.append(record)
                        }
                    }
                }
            }
            completion(.success(records))
        }
        catch let sqliteError
        {
            ZCacheLogger.logError(message: sqliteError.description)
            completion(.failure(ZCacheError.sqliteError(code: ErrorCode.dbError, message: sqliteError.description, details: nil)))
        }
        sqlite3_finalize(op)
        dbHandler.closeDB()
    }
    
    func insertRecord< T >(record: T) throws
    {
        do
        {
            let details = getDetails(entity: record)
            if let dictionary = details.dict, let id = details.id, let moduleName = details.moduleName
            {
                var cv = [ContentValues]()
                let isRecordAvailable = isZCacheRecordAvailable(id: id, moduleName: moduleName)
                if !isRecordAvailable
                {
                    cv.append(ContentValues(sequenceNumber: 1, columnName: "_ID", value: id))
                    cv.append(ContentValues(sequenceNumber: 2, columnName: "_LAYOUT_ID", value: details.layoutId))
                    cv.append(ContentValues(sequenceNumber: 3, columnName: "OFFLINE_OWNER", value: nil))
                    cv.append(ContentValues(sequenceNumber: 4, columnName: "OFFLINE_CREATED_BY", value: nil))
                    cv.append(ContentValues(sequenceNumber: 5, columnName: "OFFLINE_CREATED_TIME", value: nil))
                    cv.append(ContentValues(sequenceNumber: 6, columnName: "OFFLINE_MODIFIED_BY", value: nil))
                    cv.append(ContentValues(sequenceNumber: 7, columnName: "OFFLINE_MODIFIED_TIME", value: nil))
                    cv.append(ContentValues(sequenceNumber: 8, columnName: "ENTRY_TIME", value: DBConstant.CURRENT_TIME))
                    cv.append(ContentValues(sequenceNumber: 9, columnName: "IS_REC_AVAIL_IN_SERVER", value: "1"))
                    cv.append(ContentValues(sequenceNumber: 10, columnName: "IS_OFFLINE_DATA", value: "0"))
                    cv.append(ContentValues(sequenceNumber: 11, columnName: "API_OPERATION", value: nil))
                    let dictionaryAsString = jsonToString(json: dictionary)
                    cv.append(ContentValues(sequenceNumber: 12, columnName: "actual_record_details", value: dictionaryAsString))
                    cv.append(ContentValues(sequenceNumber: 13, columnName: "modified_record_details", value: nil))
                }
                try insertRecord(record: record, contentValues: cv)
            }
            else
            {
                print("<<< invalid record: \(String(describing: details.id)), \(String(describing: details.moduleName)), \(record)")
                throw ZCacheError.invalidError(code: ErrorCode.invalidData, message: ErrorMessage.invalidDataMsg, details: nil)
            }
        }
        catch let sqliteError
        {
            ZCacheLogger.logError(message: sqliteError.description)
            throw ZCacheError.sqliteError(code: ErrorCode.dbError, message: sqliteError.description, details: nil)
        }
    }
    
    func insertRecord< T >(record: T, contentValues: [ContentValues]) throws
    {
        do
        {
            var cv = contentValues
            let details = getDetails(entity: record)
            if let dictionary = details.dict, let id = details.id, let moduleName = details.moduleName
            {
                let isRecordAvailable = isZCacheRecordAvailable(id: id, moduleName: moduleName)
                let metaDBHandler = MetaDBHandler(moduleName: moduleName)
                var fields = [ZCacheField]()
                if let layoutId = details.layoutId
                {
                    if let zCacheFields = fieldsMap[layoutId]
                    {
                        fields = zCacheFields
                    }
                    else
                    {
                        fields = metaDBHandler.fetchLayoutFields(layoutId: layoutId)
                        fieldsMap[layoutId] = fields
                    }
                }
                if fields.isEmpty
                {
                    if let zCacheFields = fieldsMap[moduleName]
                    {
                        fields = zCacheFields
                    }
                    else
                    {
                        fields = metaDBHandler.fetchModuleFields()
                        fieldsMap[moduleName] = fields
                    }
                }
                var sequenceNumber = 14
                for field in fields
                {
                    let lookUpModules = field.lookupModules
                    let isLookUpType = field.type.rawValue.contains("lookup")
                    let valueFromDict = dictionary[field.apiName]
                    
                    if lookUpModules.isEmpty && !isLookUpType
                    {
                        if let value = valueFromDict
                        {
                            let data = String(describing: value)
                            cv.append(ContentValues(sequenceNumber: sequenceNumber, columnName: field.apiName, value: data))
                        }
                        else if !isRecordAvailable
                        {
                            cv.append(ContentValues(sequenceNumber: sequenceNumber, columnName: field.apiName, value: nil))
                        }
                    }
                    else if !lookUpModules.isEmpty && lookUpModules.count == 1
                    {
                        if let array = valueFromDict as? [[String:Any?]]
                        {
                            for item in array
                            {
                                let objString = jsonToString(json: item)
                                let entityInstance = ZCache.getEntity(ofType: field.type)
                                if let objString = objString
                                {
                                    let obj = entityInstance.toData(jsonString: objString)
                                    if let obj = obj
                                    {
                                       let details = getDetails(entity: obj)
                                        cv.append(ContentValues(sequenceNumber: sequenceNumber, columnName: field.apiName, value: details.id))
                                        try insertRecord(record: obj)
                                    }
                                }
                            }
                            if array.count == 0 && !isRecordAvailable
                            {
                                cv.append(ContentValues(sequenceNumber: sequenceNumber, columnName: field.apiName, value: nil))
                            }
                        }
                        else if let obj = valueFromDict as? [String:Any?]
                        {
                            let objString = jsonToString(json: obj)
                            let entityInstance = ZCache.getEntity(ofType: field.type)
                            if let objString = objString
                            {
                                let obj = entityInstance.toData(jsonString: objString)
                                if let obj = obj
                                {
                                   let details = getDetails(entity: obj)
                                    cv.append(ContentValues(sequenceNumber: sequenceNumber, columnName: field.apiName, value: details.id))
                                    try insertRecord(record: obj)
                                }
                            }
                        }
                        else if !isRecordAvailable
                        {
                            cv.append(ContentValues(sequenceNumber: sequenceNumber, columnName: field.apiName, value: nil))
                        }
                    }
                    else if ( lookUpModules.isEmpty && isLookUpType ) || ( !lookUpModules.isEmpty && lookUpModules.count > 1 )
                    {
                        if let array = valueFromDict as? [[String:Any?]]
                        {
                            for item in array
                            {
                                let objString = jsonToString(json: item)
                                let entityInstance = ZCache.getEntity(ofType: field.type)
                                if let objString = objString
                                {
                                    let obj = entityInstance.toData(jsonString: objString)
                                    if let obj = obj
                                    {
                                       let details = getDetails(entity: obj)
                                        cv.append(ContentValues(sequenceNumber: sequenceNumber, columnName: field.apiName, value: details.id))
                                        try insertRecord(record: obj)
                                    }
                                }
                            }
                            if array.count == 0 && !isRecordAvailable
                            {
                                cv.append(ContentValues(sequenceNumber: sequenceNumber, columnName: field.apiName, value: nil))
                            }
                        }
                        else if let obj = valueFromDict as? [String:Any?]
                        {
                            let objString = jsonToString(json: obj)
                            let entityInstance = ZCache.getEntity(ofType: field.type)
                            if let objString = objString
                            {
                                let obj = entityInstance.toData(jsonString: objString)
                                if let obj = obj
                                {
                                   let details = getDetails(entity: obj)
                                    cv.append(ContentValues(sequenceNumber: sequenceNumber, columnName: field.apiName, value: details.id))
                                    try insertRecord(record: obj)
                                }
                            }
                        }
                        else if !isRecordAvailable
                        {
                            cv.append(ContentValues(sequenceNumber: sequenceNumber,columnName: field.apiName, value: nil))
                        }
                    }
                    sequenceNumber += 1
                }
                if isZCacheRecordAvailable(id: id, moduleName: moduleName)
                {
                    if !cv.isEmpty
                    {
                        try dbHandler.update(tableName: moduleName, contentValues: cv, whereClause: "_ID", values: [id])
                    }
                }
                else
                {
                    try dbHandler.insert(tableName: moduleName, contentValues: cv)
                    recordsAvailabiltyMap[id] = true
                }
            }
        }
        catch let sqliteError
        {
            ZCacheLogger.logError(message: sqliteError.description)
            throw ZCacheError.sqliteError(code: ErrorCode.dbError, message: sqliteError.description, details: nil)
        }
    }
    
    func getDetails< T >(entity: T) -> (dict: [String:Any]?, id: String?, layoutId: String?, moduleName: String?)
    {
        var dict: [String:Any]?
        var id: String?
        var layoutId: String?
        var moduleName: String?

        if let record = entity as? ZCacheRecord
        {
            dict = record.toDicitionary()
            id = record.id
            layoutId = record.layoutId
            moduleName = record.moduleName
        }
        else if let user = entity as? ZCacheUser
        {
            dict = user.toDicitionary()
            id = user.id
            moduleName = user.moduleName
        }
        else if let module = entity as? ZCacheModule
        {
            dict = module.toDicitionary()
            id = module.id
            moduleName = module.apiName
        }
        else if let field = entity as? ZCacheField
        {
            dict = field.toDicitionary()
            id = field.id
        }
        else if let layout = entity as? ZCacheLayout
        {
            dict = layout.toDicitionary()
            id = layout.id
            layoutId = layout.id
        }
        else if let section = entity as? ZCacheSection
        {
            dict = section.toDicitionary()
            id = section.id
        }
        else if let trashRecord = entity as? ZCacheTrashRecord
        {
            dict = trashRecord.toDicitionary()
            id = trashRecord.id
            moduleName = trashRecord.moduleName
        }
        else if let value = entity as? String
        {
            id = value
            layoutId = value
        }
        return (dict, id, layoutId, moduleName)
    }
    
    func fetchRecord< T >(id: String) -> T?
    {
        var record: T?
        var op: OpaquePointer?
        do
        {
            op = try dbHandler.rawQuery(query: "SELECT * FROM \(moduleName) WHERE _ID=\(id)")
            if (sqlite3_step(op) == SQLITE_ROW)
            {
                if let op = op
                {
                    if let data = sqlite3_column_text(op, 12)
                    {
                        record = try fetchRecord(data: data)
                    }
                    else if let data = sqlite3_column_text(op, 11)
                    {
                        record = try fetchRecord(data: data)
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
        return record
    }
    
    private func fetchRecord< T >(data: UnsafePointer<UInt8>) throws -> T?
    {
        var record: T?
        let dataString = String(cString: data)
        let recordInstance = ZCache.getRecord(moduleName: moduleName)
        let obj = recordInstance.toData(jsonString: dataString)
        if let zCacheRecordObj = obj
        {
            if let zCacheRecord = zCacheRecordObj as? T
            {
                record = zCacheRecord
            }
            else
            {
                throw ZCacheError.invalidError(code: ErrorCode.invalidType, message: ErrorMessage.invalidModuleType, details: nil)
            }
        }
        return record
    }
    
    func createRecord< T >(record: T, completion: @escaping ((DataResponseCallback<ZCacheResponse, T>) -> Void))
    {
        do
        {
            var zCacheRecord = record as! ZCacheRecord
            var id = Int64.random(in: 0..<1000000000000000000)
            var isIdPresent = isRecordPresent(id: String(id), moduleName: moduleName)
            while (isIdPresent)
            {
                id = Int64.random(in: 0..<1000000000000000000)
                isIdPresent = isRecordPresent(id: String(id), moduleName: moduleName)
            }
            zCacheRecord.id = String(id)
            
            let details = getDetails(entity: zCacheRecord)
            if let dictionary = details.dict, let moduleName = details.moduleName
            {
                var cv = [ContentValues]()
                let metaDBHandler = MetaDBHandler(moduleName: moduleName)
                let currentUser: ZCacheUser? = metaDBHandler.fetchCurrentUser()
                if let currentUser = currentUser
                {
                    zCacheRecord.offlineOwner = currentUser
                    zCacheRecord.offlineCreatedBy = currentUser
                    zCacheRecord.offlineModifiedBy = currentUser
                    let currentUserAsDict = currentUser.toDicitionary()
                    if let currentUserAsDict = currentUserAsDict
                    {
                        cv.append(ContentValues(sequenceNumber: 1, columnName: "_ID", value: String(id)))
                        cv.append(ContentValues(sequenceNumber: 2, columnName: "_LAYOUT_ID", value: details.layoutId))
                        let currentUserAsString = jsonToString(json: currentUserAsDict)
                        cv.append(ContentValues(sequenceNumber: 3, columnName: "OFFLINE_OWNER", value: currentUserAsString))
                        cv.append(ContentValues(sequenceNumber: 4, columnName: "OFFLINE_CREATED_BY", value: currentUserAsString))
                        let dateTime = getCurrentDateTime()
                        cv.append(ContentValues(sequenceNumber: 5, columnName: "OFFLINE_CREATED_TIME", value: dateTime))
                        cv.append(ContentValues(sequenceNumber: 6, columnName: "OFFLINE_MODIFIED_BY", value: currentUserAsString))
                        cv.append(ContentValues(sequenceNumber: 7, columnName: "OFFLINE_MODIFIED_TIME", value: dateTime))
                        zCacheRecord.offlineCreatedTime = dateTime
                        zCacheRecord.offlineModifiedTime = dateTime
                        cv.append(ContentValues(sequenceNumber: 8, columnName: "ENTRY_TIME", value: dateTime))
                        cv.append(ContentValues(sequenceNumber: 9, columnName: "IS_REC_AVAIL_IN_SERVER", value: "0"))
                        cv.append(ContentValues(sequenceNumber: 10, columnName: "IS_OFFLINE_DATA", value: "1"))
                        cv.append(ContentValues(sequenceNumber: 11, columnName: "API_OPERATION", value: "POST"))
                        let dictionaryAsString = jsonToString(json: dictionary)
                        cv.append(ContentValues(sequenceNumber: 12, columnName: "actual_record_details", value: dictionaryAsString))
                        cv.append(ContentValues(sequenceNumber: 13, columnName: "modified_record_details", value: nil))
                    }
                }
                try insertRecord(record: zCacheRecord, contentValues: cv)
                completion(.fromCache(info: nil, data: zCacheRecord as? T, waitForServer: false))
            } 
            else
            {
                ZCacheLogger.logError(message: ErrorMessage.invalidDataMsg)
                completion(.failure(error: ZCacheError.invalidError(code: ErrorCode.invalidData, message: ErrorMessage.invalidDataMsg, details: nil)))
            }
        }
        catch let error
        {
            ZCacheLogger.logError(message: error.description)
            completion(.failure(error: ZCacheError.invalidError(code: ErrorCode.dbError, message: error.description, details: nil)))
        }
    }
    
    func updateRecord< T >(record: T, completion: @escaping ((DataResponseCallback<ZCacheResponse, T>) -> Void))
    {
        do
        {
            var zCacheRecord = record as! ZCacheRecord
            let details = getDetails(entity: zCacheRecord)
            if let dictionary = details.dict, let id = details.id, let moduleName = details.moduleName
            {
                var cv = [ContentValues]()
                let metaDBHandler = MetaDBHandler(moduleName: moduleName)
                let currentUser: ZCacheUser? = metaDBHandler.fetchCurrentUser()
                if let currentUser = currentUser
                {
                    let currentUserAsDict = currentUser.toDicitionary()
                    if let currentUserAsDict = currentUserAsDict
                    {
                        cv.append(ContentValues(sequenceNumber: 1, columnName: "_ID", value: String(id)))
                        cv.append(ContentValues(sequenceNumber: 2, columnName: "_LAYOUT_ID", value: details.layoutId))
                        if let offlineOwner = zCacheRecord.offlineOwner, let offlineOwnerAsDict = offlineOwner.toDicitionary(), let offlineOwnerAsString = jsonToString(json: offlineOwnerAsDict)
                        {
                            cv.append(ContentValues(sequenceNumber: 3, columnName: "OFFLINE_OWNER", value: offlineOwnerAsString))
                        }
                        else
                        {
                            cv.append(ContentValues(sequenceNumber: 3, columnName: "OFFLINE_OWNER", value: nil))
                        }
                        if let offlineCreatedBy = zCacheRecord.offlineCreatedBy, let offlineCreatedByAsDict = offlineCreatedBy.toDicitionary(), let offlineCreatedByAsString = jsonToString(json: offlineCreatedByAsDict)
                        {
                            cv.append(ContentValues(sequenceNumber: 4, columnName: "OFFLINE_CREATED_BY", value: offlineCreatedByAsString))
                        }
                        else
                        {
                            cv.append(ContentValues(sequenceNumber: 4, columnName: "OFFLINE_CREATED_BY", value: nil))
                        }
                        cv.append(ContentValues(sequenceNumber: 5, columnName: "OFFLINE_CREATED_TIME", value: zCacheRecord.offlineCreatedTime))
                        
                        let currentUserAsString = jsonToString(json: currentUserAsDict)
                        cv.append(ContentValues(sequenceNumber: 6, columnName: "OFFLINE_MODIFIED_BY", value: currentUserAsString))
                        zCacheRecord.offlineModifiedBy = currentUser
                        let dateTime = getCurrentDateTime()
                        cv.append(ContentValues(sequenceNumber: 7, columnName: "OFFLINE_MODIFIED_TIME", value: dateTime))
                        zCacheRecord.offlineModifiedTime = dateTime
                        
                        cv.append(ContentValues(sequenceNumber: 8, columnName: "ENTRY_TIME", value: dateTime))
                        
                        if isServerRecord(id: id)
                        {
                            cv.append(ContentValues(sequenceNumber: 9, columnName: "IS_REC_AVAIL_IN_SERVER", value: "1"))
                        }
                        else
                        {
                            cv.append(ContentValues(sequenceNumber: 9, columnName: "IS_REC_AVAIL_IN_SERVER", value: "0"))
                        }
                        cv.append(ContentValues(sequenceNumber: 10, columnName: "IS_OFFLINE_DATA", value: "1"))
                        cv.append(ContentValues(sequenceNumber: 11, columnName: "API_OPERATION", value: "PUT"))
                        let dictionaryAsString = jsonToString(json: dictionary)
                        cv.append(ContentValues(sequenceNumber: 13, columnName: "modified_record_details", value: dictionaryAsString))
                    }
                }
                try insertRecord(record: zCacheRecord, contentValues: cv)
                completion(.fromCache(info: nil, data: zCacheRecord as? T, waitForServer: false))
            }
            else
            {
                ZCacheLogger.logError(message: ErrorMessage.invalidDataMsg)
                completion(.failure(error: ZCacheError.invalidError(code: ErrorCode.invalidData, message: ErrorMessage.invalidDataMsg, details: nil)))
            }
        }
        catch let error
        {
            ZCacheLogger.logError(message: error.description)
            completion(.failure(error: ZCacheError.invalidError(code: ErrorCode.dbError, message: error.description, details: nil)))
        }
    }
    
    func deleteRecord(id: String, completion: @escaping ((DataResponseCallback<ZCacheResponse, String>) -> Void))
    {
        do
        {
            try insertTrashRecord(id: id)
            completion(.fromCache(info: nil, data: id, waitForServer: false))
        }
        catch let sqliteError
        {
            completion(.failure(error: ZCacheError.sqliteError(code: ErrorCode.dbError, message: sqliteError.description, details: nil)))
        }
    }
    
    func createRecords< T >(entities: [T], completion: @escaping ((DataResponseCallback<ZCacheResponse, [T]>) -> Void))
    {
        let dg = DispatchGroup()
        var records: [T] = []
        for entity in entities
        {
            dg.enter()
            createRecord(record: entity)
            {
                result in
                switch result
                {
                case .fromCache(info: _, data: let record, waitForServer: _):
                    if let record = record
                    {
                        records.append(record)
                    }
                    dg.leave()
                case .fromServer(info: _, data: _):
                    break
                case .failure(error: let error):
                    ZCacheLogger.logError(message: error.description)
                    dg.leave()
                }
            }
        }
        dg.dispatchMain
        {
            completion(.fromCache(info: nil, data: records, waitForServer: false))
        }
    }
    
    func insertRecords< T >(records: [T]) throws
    {
        do
        {
            for record in records
            {
                try insertRecord(record: record)
            }
        }
        catch let sqliteError
        {
            throw sqliteError
        }
    }
    
    func fetchRecords< T >(page: Int, perPage: Int, sortBy: String?, sortOrder: SortOrder?) -> [T]
    {
        var records: [T] = []
        var limit = String(perPage)
        if page > 1
        {
            let startIndex = (page - 1) * perPage + 1
            limit = "\(startIndex), \(perPage)"
        }
        var sorting: String?
        if let sortBy = sortBy
        {
            if sortOrder == SortOrder.ascending
            {
                sorting = "ORDER BY \(sortBy) ASC"
            }
            else
            {
                sorting = "ORDER BY \(sortBy) DESC"
            }
        }
        var dbQuery = String()
        if let sorting = sorting
        {
            dbQuery += " \(sorting)"
        }
        var op: OpaquePointer?
        do
        {
            op = try dbHandler.rawQuery(query: "SELECT * FROM \(moduleName) WHERE (API_OPERATION ISNULL OR API_OPERATION != 'DELETE') \(dbQuery) LIMIT \(limit)")
            while sqlite3_step(op) == SQLITE_ROW
            {
                if let op = op
                {
                    if let data = sqlite3_column_text(op, 12)
                    {
                        let record: T? = try fetchRecord(data: data)
                        if let record = record
                        {
                            records.append(record)
                        }
                    }
                    else if let data = sqlite3_column_text(op, 11)
                    {
                        let record: T? = try fetchRecord(data: data)
                        if let record = record
                        {
                            records.append(record)
                        }
                    }
                }
            }
        }
        catch let error
        {
            ZCacheLogger.logError(message: error.description)
            try? MetaDBHandler(moduleName: moduleName).markModuleModified()
        }
        sqlite3_finalize(op)
        dbHandler.closeDB()
        return records
    }
    
    func updateRecords< T >(entities: [T], completion: @escaping ((DataResponseCallback<ZCacheResponse, [T]>) -> Void))
    {
        let dg = DispatchGroup()
        var records: [T] = []
        for entity in entities
        {
            dg.enter()
            updateRecord(record: entity)
            {
                result in
                switch result
                {
                case .fromCache(info: _, data: let record, waitForServer: _):
                    if let record = record
                    {
                        records.append(record)
                    }
                    dg.leave()
                case .fromServer(info: _, data: _):
                    break
                case .failure(error: let error):
                    ZCacheLogger.logError(message: error.description)
                    dg.leave()
                }
            }
        }
        dg.dispatchMain
        {
            completion(.fromCache(info: nil, data: records, waitForServer: false))
        }
    }
    
    func deleteAllRecords(ids: [String], completion: @escaping ((DataResponseCallback<ZCacheResponse, [String]>) -> Void))
    {
        let dg = DispatchGroup()
        var recordIds: [String] = []
        for id in ids
        {
            dg.enter()
            deleteRecord(id: id)
            {
                result in
                switch result
                {
                case .fromCache(info: _, data: let id, waitForServer: _):
                    if let id = id
                    {
                        recordIds.append(id)
                    }
                    dg.leave()
                case .fromServer(info: _, data: _):
                    break
                case .failure(error: let error):
                    ZCacheLogger.logError(message: error.description)
                    dg.leave()
                }
            }
        }
        dg.dispatchMain
        {
            completion(.fromCache(info: nil, data: recordIds, waitForServer: false))
        }
    }
    
    func insertTrashRecord(id: String) throws
    {
        var cv = [ContentValues]()
        let metaDBHandler = MetaDBHandler(moduleName: moduleName)
        let currentUser: ZCacheUser? = metaDBHandler.fetchCurrentUser()
        if let currentUser = currentUser
        {
            let currentUserAsDict = currentUser.toDicitionary()
            if let currentUserAsDict = currentUserAsDict
            {
                cv.append(ContentValues(sequenceNumber: 1, columnName: "ID", value: String(id)))
                cv.append(ContentValues(sequenceNumber: 2, columnName: "MODULE_NAME", value: moduleName))
                if let deletedByAsString = jsonToString(json: currentUserAsDict)
                {
                    cv.append(ContentValues(sequenceNumber: 3, columnName: "DELETED_BY", value: deletedByAsString))
                }
                else
                {
                    cv.append(ContentValues(sequenceNumber: 3, columnName: "DELETED_BY", value: nil))
                }
                cv.append(ContentValues(sequenceNumber: 4, columnName: "DELETED_TIME", value: DBConstant.CURRENT_TIME))
                let row = getRow(id: id)
                cv.append(ContentValues(sequenceNumber: 5, columnName: "IS_REC_AVAIL_IN_SERVER", value: row["IS_REC_AVAIL_IN_SERVER"]))
                cv.append(ContentValues(sequenceNumber: 6, columnName: "IS_OFFLINE_DATA", value: row["IS_OFFLINE_DATA"]))
                cv.append(ContentValues(sequenceNumber: 7, columnName: "API_OPERATION", value: row["API_OPERATION"]))
            }
        }
        do
        {
            try dbHandler.insert(tableName: "_TRASH_RECORDS", contentValues: cv)
            try dbHandler.execSQL(query: "UPDATE \(moduleName) SET API_OPERATION='DELETE' WHERE _ID=\"\(id)\"")
        }
        catch let sqliteError
        {
            ZCacheLogger.logError(message: "<<< DB : Error while inserting trash records - \(sqliteError).")
            throw ZCacheError.sqliteError(code: ErrorCode.dbError, message: sqliteError.description, details: nil)
        }
    }
    
    func deleteRecordFromCache(id: String) throws
    {
        do
        {
           try dbHandler.delete(tableName: moduleName, whereClause: "_ID", values: [id])
        }
        catch let error
        {
            ZCacheLogger.logError(message: error.description)
            throw ZCacheError.sqliteError(code: ErrorCode.dbError, message: error.description, details: nil)
        }
    }
    
    func alterRecordTable(unmodifiedFields: [ZCacheField]) throws
    {
        //Step1 - Create backup table
        TableDBHandler().createRecordTable(moduleName: "\(moduleName)_backup")
        { [self]
            result in
            switch result
            {
            case .success:
                do
                {
                    let fields = unmodifiedFields.reduce(into: [String]())
                    {
                        $0.append($1.apiName)
                    }
                    
                    //Step2 - Get backup from old records table
                    let fieldsAsString = (fields.map{ $0 }).joined(separator: ", ")
                    try? dbHandler.execSQL(query: "INSERT INTO \(moduleName)_backup SELECT \(fieldsAsString) FROM \(moduleName)")
                    
                    //Step3 - Drop old records table
                    try? dbHandler.execSQL(query: "DROP TABLE \(moduleName)")

                    //Step4 - Rename backup table as old table
                    renameTable(name: "\(moduleName)_backup", as: moduleName)
                }
            case .failure(let error):
                do
                {
                    ZCacheLogger.logError(message: "<<< DB :: Alter record table failed - \(error).")
                    throw error
                }
            }
        }
    }
    
    func renameTable(name oldName: String, as newName: String)
    {
        do
        {
            try dbHandler.execSQL(query: "ALTER TABLE \(oldName) RENAME TO \(newName)")
        }
        catch let error
        {
            ZCacheLogger.logError(message: "<<< DB :: Renaming altered record table failed - \(error).")
        }
    }
    
    func clearRequiredDBSpaceforInsert(for recordsCountFromServer: Int) throws
    {
        let recordsCountFromCache = try getRecordsCount()
        let totalCount = recordsCountFromCache + recordsCountFromServer
        if totalCount > 100000
        {
            let neededSpace = (recordsCountFromServer + recordsCountFromCache) - 100000
            let spaceGained = try clearOlderRecords(limit: neededSpace)
            if neededSpace != spaceGained
            {
                ZCacheLogger.logError(message: ErrorMessage.requiredSpaceNotAvailableInCache)
                throw ZCacheError.sqliteError(code: ErrorCode.dbError, message: ErrorMessage.requiredSpaceNotAvailableInCache, details: nil)
            }
        }
        else
        {
            ZCacheLogger.logError(message: ErrorMessage.requiredSpaceAvailableInCache)
        }
    }
    
    func getRecordsCount() throws -> Int
    {
        var count = 0
        var op: OpaquePointer?
        do
        {
            op = try dbHandler.rawQuery(query: "SELECT * FROM \(moduleName) WHERE (API_OPERATION ISNULL OR API_OPERATION != 'DELETE')")
            if let op = op
            {
                count = ZCache.database?.getRowCount(prepareStatement: op) ?? 0
            }
        }
        catch let error
        {
            throw ZCacheError.sqliteError(code: ErrorCode.dbError, message: error.description, details: nil)
        }
        sqlite3_finalize(op)
        dbHandler.closeDB()
        return count
    }
    
    func clearOlderRecords(limit: Int) throws -> Int
    {
        var recordIds = [String]()
        var recordsCount = 0
        let op = try dbHandler.rawQuery(query: "SELECT * FROM \(moduleName) WHERE IS_OFFLINE_DATA=0 ORDER BY _ID ASC LIMIT $limit")
        if let op = op
        {
            let count = ZCache.database?.getRowCount(prepareStatement: op) ?? 0
            if count > 0
            {
                while (sqlite3_step(op) == SQLITE_ROW)
                {
                    if let data = sqlite3_column_text(op, 0)
                    {
                        let id = String(cString: data)
                        recordIds.append(id)
                    }
                }
                try clearServerDeletedRecordsFromCache(ids: recordIds)
                recordsCount = recordIds.count
            }
            else
            {
                recordsCount = 0
            }
        }
        sqlite3_finalize(op)
        dbHandler.closeDB()
        return recordsCount
    }
    
    func clearServerDeletedRecordsFromCache(ids: [String]) throws
    {
        if !ids.isEmpty
        {
            let idsAsString = (ids.map{ $0 }).joined(separator: ", ")
            try dbHandler.execSQL(query: "DELETE FROM \(moduleName) WHERE _ID IN (\(idsAsString)")
        }
    }
    
    func isZCacheRecordAvailable(id: String, moduleName: String) -> Bool
    {
        var isRecordAvailable = false
        if let isAvailable = recordsAvailabiltyMap[id]
        {
            isRecordAvailable = isAvailable
        }
        else
        {
            isRecordAvailable = isRecordPresent(id: id, moduleName: moduleName)
            recordsAvailabiltyMap[id] = isRecordAvailable
        }
        return isRecordAvailable
    }
    
    func isRecordPresent(id: String, moduleName: String) -> Bool
    {
        ZCacheLogger.logInfo(message: "Getting 'Is Record Present?' info for the record: \(id) from module: \(moduleName).")
        var isRecordPresent: Bool = false
        var op: OpaquePointer?
        do
        {
            let query = "SELECT * from \(moduleName) WHERE _ID=\"\(id)\" AND (API_OPERATION ISNULL OR API_OPERATION != 'DELETE')"
            op = try dbHandler.rawQuery(query: query)
            if sqlite3_step(op) == SQLITE_ROW
            {
                isRecordPresent = true
            }
            else
            {
                isRecordPresent = false
            }
        }
        catch let error
        {
            ZCacheLogger.logError(message: "<<< DB : Is Record Present? failed - \(error).")
        }
        sqlite3_finalize(op)
        dbHandler.closeDB()
        return isRecordPresent
    }
    
    func isRecordDeleted(id: String) -> Bool
    {
        ZCacheLogger.logInfo(message: "Getting 'Is Record Deleted?' info for the record: \(id) from module: \(moduleName).")
        var isRecordDeleted: Bool = false
        var op: OpaquePointer?
        do
        {
            let query = "SELECT * from \(moduleName) WHERE _ID=\"\(id)\" AND API_OPERATION='DELETE'"
            op = try dbHandler.rawQuery(query: query)
            if sqlite3_step(op) == SQLITE_ROW
            {
                isRecordDeleted = true
            }
            else
            {
                isRecordDeleted = false
            }
        }
        catch let error
        {
            ZCacheLogger.logError(message: "<<< DB : Is Record Deleted? failed - \(error).")
        }
        sqlite3_finalize(op)
        dbHandler.closeDB()
        return isRecordDeleted
    }
    
    func isServerRecord(id: String) -> Bool
    {
        ZCacheLogger.logInfo(message: "Getting 'Is Server Record?' info for the record: \(id) from module: \(moduleName).")
        var isServerRecord: Bool = true
        var op: OpaquePointer?
        do
        {
            let query = "SELECT * from \(moduleName) WHERE _ID=\"\(id)\""
            op = try dbHandler.rawQuery(query: query)
            if sqlite3_step(op) == SQLITE_ROW
            {
                if let op = op
                {
                    if let data = sqlite3_column_text(op, 8)
                    {
                        let value = String(cString: data)
                        if value == "0"
                        {
                            isServerRecord = false
                        }
                    }
                }
            }
        }
        catch let error
        {
            ZCacheLogger.logError(message: "<<< DB : Is Server Record? failed - \(error).")
        }
        sqlite3_finalize(op)
        dbHandler.closeDB()
        return isServerRecord
    }
    
    func getRow(id: String) -> [String: String]
    {
        ZCacheLogger.logInfo(message: "Getting row: \(id) from module: \(moduleName).")
        var dict: [String: String] = [:]
        var op: OpaquePointer?
        do
        {
            let query = "SELECT * from \(moduleName) WHERE _ID=\"\(id)\""
            op = try dbHandler.rawQuery(query: query)
            if sqlite3_step(op) == SQLITE_ROW
            {
                if let op = op
                {
                    var count: Int32 = 0
                    while count < 13
                    {
                        if let columnName = sqlite3_column_name(op, count), let data = sqlite3_column_text(op, count)
                        {
                            let key = String(cString: columnName)
                            let value = String(cString: data)
                            dict[key] = value
                        }
                        count += 1
                    }
                }
            }
        }
        catch let error
        {
            ZCacheLogger.logError(message: "<<< DB : Getting row failed - \(error).")
        }
        sqlite3_finalize(op)
        dbHandler.closeDB()
        return dict
    }
    
    init(moduleName: String)
    {
        self.moduleName = moduleName
    }
}
