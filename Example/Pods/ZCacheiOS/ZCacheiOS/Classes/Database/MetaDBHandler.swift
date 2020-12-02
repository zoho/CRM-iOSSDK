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
    func insertModule< T : ZCacheModule >(module: T) {
        insertModules(modules: [module])
    }
    
    func insertModules< T : ZCacheModule >(modules: [T]) {
        do {
            for module in modules {
                var cv = [ContentValues]()
                cv.append(ContentValues(sequenceNumber: 1, columnName: "ID", value: module.id))
                cv.append(ContentValues(sequenceNumber: 2, columnName: "NAME", value: module.apiName))
                
                let dict = getDataAsDictionary(entity: module)
                let json = jsonToString(json: dict!)
            
                cv.append(ContentValues(sequenceNumber: 3, columnName: "DATA", value: json))
                cv.append(ContentValues(sequenceNumber: 4, columnName: "IS_MODIFIED", value: module.id))
                
                try dbHandler.insert(tableName: "_MODULES", contentValues: cv)
            }
        } catch let sqliteError {
            ZCacheLogger.logError(message: sqliteError.description)
        }
    }
    
    func fetchModule< T : ZCacheModule >(name: String) -> T? {
//        do {
//
//        } catch {
//            ZCacheLogger.logError(message: error.description)
//        }
        
        return nil
    }
    
    func fetchModule< T : ZCacheModule >(id: String) -> T? {
        return nil
    }
    
    func fetchModules< T: ZCacheModule >() -> [T] {
        var modules: [T] = []
        do {
            let cursor = try dbHandler.rawQuery(query: "SELECT * FROM _MODULES")
            if let op = cursor {
                
                guard let data = sqlite3_column_text(op, 2) else
                {
                    ZCacheLogger.logError(message: "<<< Query result is nil")
                    return []
                }
                let json = String(cString: data)
                let dict = stringToJson(string: json)
                if let dictionary = dict {
                    let module: T = try getDictionaryAsData(json: dictionary)
                    modules.append(module)
                } else {
                    return modules
                }
                
            } else {
                return modules
            }
            
        } catch let sqliteError {
            ZCacheLogger.logError(message: sqliteError.description)
        }
        return modules
    }
    
    // Inserting & Fetching users
    func insertUser(user: ZCacheUser) {
        
    }
    
    func insertUsers(users: [ZCacheUser]) {
        
    }
    
    func fetchUser(id: String) {
        
    }
    
    func fetchUsers() {
        
    }
    
    func insertCurrentUser(user: ZCacheUser) {
        
    }
    
    func fetchCurrentUser() {
        
    }
    
    // Inserting & Fetching layouts
    func insertLayout(user: ZCacheUser) {
        
    }
    
    func insertLayouts(users: [ZCacheUser]) {
        
    }
    
    func fetchLayout(id: String) {
        
    }
    
    func fetchLayouts() {
        
    }
    
    // Inserting & Fetching sections
    func insertSection(user: ZCacheUser) {
        
    }
    
    func insertSections(users: [ZCacheUser]) {
        
    }
    
    func fetchSection(apiName: String) {
        
    }
    
    func fetchSections() {
        
    }
    
    // Inserting & Fetching module fields
    func insertModuleField(user: ZCacheUser) {
        
    }
    
    func insertModuleFields(users: [ZCacheUser]) {
        
    }
    
    func fetchModuleField(id: String) {
        
    }
    
    func fetchModuleFields() {
        
    }
    
    // Inserting & Fetching layout fields
    func insertLayoutField(user: ZCacheUser) {
        
    }
    
    func insertLayoutFields(users: [ZCacheUser]) {
        
    }
    
    func fetchLayoutField(id: String) {
        
    }
    
    func fetchLayoutFields() {
        
    }
    
    init(moduleName: String) {
        self.moduleName = moduleName
    }
    
    convenience init() {
        self.init(moduleName: "")
    }
}
