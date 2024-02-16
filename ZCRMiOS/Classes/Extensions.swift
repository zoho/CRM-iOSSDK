//
//  Extensions.swift
//  ZCRMiOS
//
//  Created by test on 15/02/24.
//

import Foundation

// CommonUtilExtension
internal struct OrganizationTableStatement
{
    func insert( organizationId : Int64 ) -> String
    {
        return "\(DBConstant.DML_INSERT) \(DBConstant.KEYS_INTO) \(DBConstant.TABLE_CURRENT_ORGANIZATION) (\(DBConstant.COLUMN_ORGANIZATION_ID)) \(DBConstant.KEYS_VALUES) (\"\(organizationId)\");"
    }
    
    func createTable() -> String
    {
        return "\(DBConstant.DML_CREATE) TABLE IF NOT EXISTS \(DBConstant.TABLE_CURRENT_ORGANIZATION)(\(DBConstant.COLUMN_ORGANIZATION_ID) VARCHAR PRIMARY KEY NOT NULL);"
    }
    
    func delete() -> String
    {
        return "\(DBConstant.DML_DELETE) \(DBConstant.KEYS_FROM) \(DBConstant.TABLE_CURRENT_ORGANIZATION)"
    }
    
    func fetchData() -> String
    {
        return "\(DBConstant.DQL_SELECT) * \(DBConstant.KEYS_FROM) \(DBConstant.TABLE_CURRENT_ORGANIZATION);"
    }
}

extension CacheDBHandler {
    
    internal var organizationTableStatement : OrganizationTableStatement
    {
        return OrganizationTableStatement()
    }
    
    func createOrganizationTable() throws
    {
        let createTableStatement = organizationTableStatement.createTable()
        try dbRequest.execSQL(dbCommand: createTableStatement)
    }
    
    func encryptDB( _ password : String ) throws
    {
        try serialQueue.sync {
            try dbRequest.encryptDB( password )
        }
    }
    
    func decryptDB( _ password : String ) throws
    {
        try serialQueue.sync {
            try dbRequest.decryptDB( password )
        }
    }
}

extension EntityAPIHandler.ResponseJSONKeys {
    static let Email = "Email"
}

extension RequestParamKeys {
    static let layoutId : String = "layout_id"
    static let pipelineId : String = "pipeline_id"
    static let feature : String = "feature"
}

extension DBConstant
{
    static let MULTIORG_DB_SUPPORT_PREFERENCE = "IS_MULTIORG_DB_SUPPORTED"
}
