
//
//  FormDBHelper.swift
//  ZCRMiOS
//
//  Created by Sruthi Ravi on 17/08/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

import Foundation
public class FormDBHelper{
    
    private let db : SQLite
    
    init()
    {
        db = SQLite(dbName: "zohocrmsdk.db")
    }
    
    internal func createLayout() throws
    {
        //try foreignKeysCount(prepareStatement: try db.rawQuery(dbCommand: "PRAGMA foreign_keys;"))
        //try db.execSQL(dbCommand: ZCRMTableDetails.ENABLE_FOREIGN_KEYS)
        try db.execSQL(dbCommand: ZCRMTableDetails.CREATE_TABLE + ZCRMTableDetails.LayoutUpdateTime.TABLE_NAME + "(" + ZCRMTableDetails.LayoutUpdateTime.MODULE + " CHAR(100)," + ZCRMTableDetails.LayoutUpdateTime.TIME + " Double)")
        try db.execSQL(dbCommand: ZCRMTableDetails.CREATE_TABLE + ZCRMTableDetails.Layout.TABLE_NAME
            + "(" + ZCRMTableDetails.Layout.MODULE + " CHAR(30)," + ZCRMTableDetails.Layout.LAYOUT_NAME + " CHAR(30),"
            + ZCRMTableDetails.Layout.LAYOUT_ID + " CHAR(30) PRIMARY KEY NOT NULL," + ZCRMTableDetails.Layout.CREATED_BY_NAME + " CHAR(30),"
            + ZCRMTableDetails.Layout.CREATED_BY_ID + " CHAR(30)," + ZCRMTableDetails.Layout.CREATED_TIME + " CHAR(30),"
            + ZCRMTableDetails.Layout.MODIFIED_BY_NAME + " CHAR(30)," + ZCRMTableDetails.Layout.MODIFIED_BY_ID + " CHAR(30),"
            + ZCRMTableDetails.Layout.MODIFIED_TIME + " CHAR(30)," + ZCRMTableDetails.Layout.STATUS + " INT,"
            + ZCRMTableDetails.Layout.VISIBLE + " CHAR(10))")
        try db.execSQL(dbCommand: ZCRMTableDetails.CREATE_TABLE + ZCRMTableDetails.Profile.TABLE_NAME + "(" + ZCRMTableDetails.Profile.LAYOUT_ID + " CHAR(30),"
            + ZCRMTableDetails.Profile.PROFILE_ID + " CHAR(30)," + ZCRMTableDetails.Profile.PROFILE_NAME + " CHAR(30)," + ZCRMTableDetails.Profile.DEFAULT + " CHAR(10), FOREIGN KEY (" + ZCRMTableDetails.Profile.LAYOUT_ID + ")" + " REFERENCES " + ZCRMTableDetails.Layout.TABLE_NAME + "(" + ZCRMTableDetails.Layout.LAYOUT_ID + ")" + " ON DELETE CASCADE)")
         try self.createSection()
         try self.createField()
        //try foreignKeysCount(prepareStatement: try db.rawQuery(dbCommand: "PRAGMA foreign_keys;"))
    }
    
    internal func createSection() throws
    {
           try db.execSQL(dbCommand: ZCRMTableDetails.CREATE_TABLE + ZCRMTableDetails.Section.TABLE_NAME + "(" + ZCRMTableDetails.Section.LAYOUT_ID + " CHAR(30),"
            + ZCRMTableDetails.Section.SECTION_NAME + " CHAR(30)," + ZCRMTableDetails.Section.SECTION_DISPLAY_NAME + " CHAR(30),"
            + ZCRMTableDetails.Section.COLUMN_COUNT + " INT," + ZCRMTableDetails.Section.SEQUENCE + " INT, FOREIGN KEY (" + ZCRMTableDetails.Section.LAYOUT_ID + ")" + " REFERENCES " + ZCRMTableDetails.Layout.TABLE_NAME + "(" + ZCRMTableDetails.Layout.LAYOUT_ID + ")" + " ON DELETE CASCADE)")
    }
    
    internal func createField() throws
    {
         try db.execSQL(dbCommand: ZCRMTableDetails.CREATE_TABLE + ZCRMTableDetails.Fields.TABLE_NAME + "(" + ZCRMTableDetails.Fields.LAYOUT_ID + " CHAR(30) NOT NULL,"
            + ZCRMTableDetails.Fields.SECTION_NAME + " CHAR(30)," + ZCRMTableDetails.Fields.FIELD_ID + " CHAR(30) NOT NULL,"
            + ZCRMTableDetails.Fields.FIELD_APINAME + " CHAR(30)," + ZCRMTableDetails.Fields.FIELD_DISPLAY_NAME + " CHAR(30),"
            + ZCRMTableDetails.Fields.DATA_TYPE + " CHAR(20)," + ZCRMTableDetails.Fields.CREATE_LAYOUT + " CHAR(20),"
            + ZCRMTableDetails.Fields.VIEW_LAYOUT + " CHAR(20)," + ZCRMTableDetails.Fields.EDIT_LAYOUT + " CHAR(20),"
            + ZCRMTableDetails.Fields.QUICK_CREATE_LAYOUT + " CHAR(20)," + ZCRMTableDetails.Fields.MAX_LENGTH + " INT,"
            + ZCRMTableDetails.Fields.CUSTOM_FIELD + " CHAR(10)," + ZCRMTableDetails.Fields.MANDATORY + " CHAR(10),"
            + ZCRMTableDetails.Fields.VISIBLE + " CHAR(10)," + ZCRMTableDetails.Fields.READ_ONLY + " CHAR(10),"
            + ZCRMTableDetails.Fields.DEFAULT_VALUE + " CHAR(30)," + ZCRMTableDetails.Fields.SEQ_NUM + " INT, " + ZCRMTableDetails.Fields.UNIQUE_ID + " CHAR(150) PRIMARY KEY NOT NULL, FOREIGN KEY (" + ZCRMTableDetails.Fields.LAYOUT_ID + ")" + " REFERENCES " + ZCRMTableDetails.Layout.TABLE_NAME + "(" + ZCRMTableDetails.Layout.LAYOUT_ID + ")" + " ON DELETE CASCADE)")
         try db.execSQL(dbCommand: ZCRMTableDetails.CREATE_TABLE + ZCRMTableDetails.FieldPickListValues.TABLE_NAME + "("
            + ZCRMTableDetails.FieldPickListValues.FIELD_ID + " CHAR(30)," + ZCRMTableDetails.FieldPickListValues.ACTUAL_NAME + " CHAR(30),"
            + ZCRMTableDetails.FieldPickListValues.DISPLAY_NAME + " CHAR(30)," + ZCRMTableDetails.FieldPickListValues.SEQ_NUM + " INT,"
            + ZCRMTableDetails.FieldPickListValues.MAPS + " CHAR(50), " + ZCRMTableDetails.Fields.UNIQUE_ID + " CHAR(150), FOREIGN KEY (" + ZCRMTableDetails.FieldPickListValues.UNIQUE_ID + ")" + " REFERENCES " + ZCRMTableDetails.Fields.TABLE_NAME + "(" + ZCRMTableDetails.Fields.UNIQUE_ID + ")" + " ON DELETE CASCADE)")
    }
    
    internal func createCustomView() throws
    {
        try db.execSQL(dbCommand: ZCRMTableDetails.CREATE_TABLE + ZCRMTableDetails.CustomView.TABLE_NAME + "(" + ZCRMTableDetails.CustomView.MODULE + " CHAR(30)," + ZCRMTableDetails.CustomView.NAME + " CHAR(30)," + ZCRMTableDetails.CustomView.DISPLAY_NAME + " CHAR(30)," + ZCRMTableDetails.CustomView.SYSTEM_NAME + " CHAR(30)," + ZCRMTableDetails.CustomView.SORT_BY + " CHAR(20)," + ZCRMTableDetails.CustomView.SORT_ORDER + " CHAR(10),"+ZCRMTableDetails.CustomView.CUSTOM_VIEW_ID + " CHAR(30) PRIMARY KEY NOT NULL," + ZCRMTableDetails.CustomView.CATEGORY + " CHAR(30)," + ZCRMTableDetails.CustomView.FAVORITE + " INT," + ZCRMTableDetails.CustomView.IS_DEFAULT + " CHAR(10))")
        try db.execSQL(dbCommand: ZCRMTableDetails.CREATE_TABLE + ZCRMTableDetails.CustomViewFields.TABLE_NAME + "(" + ZCRMTableDetails.CustomViewFields.CUSTOM_VIEW_ID + " CHAR(30)," + ZCRMTableDetails.CustomViewFields.FIELD_NAME + " CHAR(30)," + ZCRMTableDetails.CustomView.MODULE + " CHAR(30), FOREIGN KEY (" + ZCRMTableDetails.CustomViewFields.CUSTOM_VIEW_ID + ")" + " REFERENCES " + ZCRMTableDetails.CustomView.TABLE_NAME + "(" + ZCRMTableDetails.CustomView.CUSTOM_VIEW_ID + ")" + " ON DELETE CASCADE)")
        try db.execSQL(dbCommand: ZCRMTableDetails.CREATE_TABLE + ZCRMTableDetails.CustomViewUpdateTime.TABLE_NAME + "(" + ZCRMTableDetails.LayoutUpdateTime.MODULE + " CHAR(30)," + ZCRMTableDetails.LayoutUpdateTime.TIME + " Double)")
    }
    
    func insertLayoutTime(module: String) throws
    {
        try createLayout()
        let prepareStatement =  try db.rawQuery(dbCommand: "\(ZCRMTableDetails.SELECT_TABLE) \(ZCRMTableDetails.LayoutUpdateTime.TABLE_NAME) where \(ZCRMTableDetails.LayoutUpdateTime.MODULE) = '\(module)'")
        let count = db.getRowCount(prepareStatement: prepareStatement)
       
        if(count <= 0)
        {
            try db.execSQL(dbCommand: "insert into \(ZCRMTableDetails.LayoutUpdateTime.TABLE_NAME)(Module, Time) values ('\(module)', 0.0)")
        }
    }
    
    func updateLayoutTime(module: String, time: Double) throws
    {
        try db.execSQL(dbCommand: "update \(ZCRMTableDetails.LayoutUpdateTime.TABLE_NAME) set \(ZCRMTableDetails.LayoutUpdateTime.TIME) = \(time) where \(ZCRMTableDetails.LayoutUpdateTime.MODULE) = '\(module)'")
    }
    
    func getLayoutTime(module: String) throws -> Double
    {
        var time = 0.0
        let prepareStatement =  try db.rawQuery(dbCommand: "\(ZCRMTableDetails.SELECT_TABLE) \(ZCRMTableDetails.LayoutUpdateTime.TABLE_NAME) where \(ZCRMTableDetails.LayoutUpdateTime.MODULE) = '\(module)'")
        
        while sqlite3_step(prepareStatement) == SQLITE_ROW {
            time = sqlite3_column_double(prepareStatement, Int32(1))
        }
        db.closeDB()
        return time
    }
    
    func insertCustomViewTime(module: String) throws
    {
        try createCustomView()
        let prepareStatement =  try db.rawQuery(dbCommand: "\(ZCRMTableDetails.SELECT_TABLE) \(ZCRMTableDetails.CustomViewUpdateTime.TABLE_NAME) where \(ZCRMTableDetails.CustomViewUpdateTime.MODULE) = '\(module)'")
        let count = db.getRowCount(prepareStatement: prepareStatement)
        
        if(count <= 0)
        {
            try db.execSQL(dbCommand: "insert into \(ZCRMTableDetails.CustomViewUpdateTime.TABLE_NAME)(Module, Time) values ('\(module)', 0.0)")
        }
    }
    
    func updateCustomViewTime(module: String, time: Double) throws
    {
        try db.execSQL(dbCommand: "update \(ZCRMTableDetails.CustomViewUpdateTime.TABLE_NAME) set \(ZCRMTableDetails.CustomViewUpdateTime.TIME) = \(time) where \(ZCRMTableDetails.CustomViewUpdateTime.MODULE) = '\(module)'")
    }
    
    func getCustomViewTime(module: String) throws -> Double
    {
        var time = 0.0
        let prepareStatement =  try db.rawQuery(dbCommand: "\(ZCRMTableDetails.SELECT_TABLE) \(ZCRMTableDetails.CustomViewUpdateTime.TABLE_NAME) where \(ZCRMTableDetails.CustomViewUpdateTime.MODULE) = '\(module)'")
        
        while sqlite3_step(prepareStatement) == SQLITE_ROW {
            time = sqlite3_column_double(prepareStatement, Int32(1))
        }
        db.closeDB()
        return time
    }

    func insertCustomView(module: String, customView: ZCRMCustomView) throws
    {
        var contentValues : [String : Any] = [ String : Any ]()
        contentValues.updateValue(module, forKey: ZCRMTableDetails.CustomView.MODULE)
        contentValues.updateValue(customView.getName(), forKey: ZCRMTableDetails.CustomView.NAME)
        contentValues.updateValue(customView.getDisplayName(), forKey: ZCRMTableDetails.CustomView.DISPLAY_NAME)
        contentValues.updateValue(customView.getSystemName()!, forKey: ZCRMTableDetails.CustomView.SYSTEM_NAME)
        contentValues.updateValue(String(customView.getId()), forKey: ZCRMTableDetails.CustomView.CUSTOM_VIEW_ID)
        if(customView.getSortByCol() != nil)
        {
        contentValues.updateValue(customView.getSortByCol()!, forKey: ZCRMTableDetails.CustomView.SORT_BY)
        }
        if(customView.getSortOrder() != nil)
        {
        contentValues.updateValue(customView.getSortOrder()!, forKey: ZCRMTableDetails.CustomView.SORT_ORDER)
        }
        contentValues.updateValue(customView.getCategory()!, forKey: ZCRMTableDetails.CustomView.CATEGORY)
        contentValues.updateValue(customView.getFavouriteSequence(), forKey: ZCRMTableDetails.CustomView.FAVORITE)
        contentValues.updateValue(String(customView.isDefaultCV()), forKey: ZCRMTableDetails.CustomView.IS_DEFAULT)
        try db.insert(tableName: ZCRMTableDetails.CustomView.TABLE_NAME,contentValues: contentValues)
        
        let currentTimeInMiliseconds = Date().timeIntervalSince1970 * 1000.0
        try updateCustomViewTime(module: module, time: currentTimeInMiliseconds
        )
    }
    
    func insertCustomViewFields(moduleAPIname : String, customViewId: Int64, fieldName: String) throws
    {
        var contentValues : [String : Any] = [ String : Any ]()
        contentValues.updateValue(String(customViewId), forKey: ZCRMTableDetails.CustomViewFields.CUSTOM_VIEW_ID)
        contentValues.updateValue(fieldName, forKey: ZCRMTableDetails.CustomViewFields.FIELD_NAME)
        contentValues.updateValue(moduleAPIname, forKey: ZCRMTableDetails.CustomViewFields.MODULE)
        try db.insert(tableName: ZCRMTableDetails.CustomViewFields.TABLE_NAME,contentValues: contentValues)
    }
    
    func insertLayout(module: String, layout: ZCRMLayout) throws
    {
        var contentValues : [String : Any] = [ String : Any ]()
        contentValues.updateValue( module, forKey: ZCRMTableDetails.Layout.MODULE)
        contentValues.updateValue(layout.getName()!, forKey: ZCRMTableDetails.Layout.LAYOUT_NAME)
        contentValues.updateValue(String(layout.getId()), forKey: ZCRMTableDetails.Layout.LAYOUT_ID)
        if (layout.getCreatedBy() != nil)
        {
            contentValues.updateValue(layout.getCreatedBy()!.getFullName(), forKey: ZCRMTableDetails.Layout.CREATED_BY_NAME)
            contentValues.updateValue(String(layout.getCreatedBy()!.getId()!), forKey: ZCRMTableDetails.Layout.CREATED_BY_ID)
            
            contentValues.updateValue(layout.getCreatedTime()!, forKey: ZCRMTableDetails.Layout.CREATED_TIME)
        }
        
        if (layout.getModifiedBy() != nil)
        {
            contentValues.updateValue(layout.getModifiedBy()!.getFullName(), forKey: ZCRMTableDetails.Layout.MODIFIED_BY_NAME)
            contentValues.updateValue(String(layout.getModifiedBy()!.getId()!), forKey: ZCRMTableDetails.Layout.MODIFIED_BY_ID)
        
            contentValues.updateValue(layout.getModifiedTime()!, forKey: ZCRMTableDetails.Layout.MODIFIED_TIME)
        }
        
        contentValues.updateValue(layout.getStatus()!, forKey: ZCRMTableDetails.Layout.STATUS)
        contentValues.updateValue(String(layout.isVisible()!), forKey: ZCRMTableDetails.Layout.VISIBLE)
        
        try db.insert(tableName: ZCRMTableDetails.Layout.TABLE_NAME,contentValues:  contentValues)
        
        let currentTimeInMiliseconds = Date().timeIntervalSince1970 * 1000.0
        try updateLayoutTime(module: module, time: currentTimeInMiliseconds)
    }
    
    func insertLayoutProfiles(layoutId: Int64, profile: ZCRMProfile) throws
    {
        
        var contentValues : [String : Any] = [ String : Any ]()
        contentValues.updateValue(String(layoutId), forKey: ZCRMTableDetails.Profile.LAYOUT_ID)
        contentValues.updateValue(String(profile.getId()), forKey: ZCRMTableDetails.Profile.PROFILE_ID)
        contentValues.updateValue(profile.getName(), forKey: ZCRMTableDetails.Profile.PROFILE_NAME)
        contentValues.updateValue(String(profile.isDefaultProfile()!), forKey: ZCRMTableDetails.Profile.DEFAULT)
        try db.insert(tableName: ZCRMTableDetails.Profile.TABLE_NAME, contentValues: contentValues)
    }
    
    func insertSection(layoutId: Int64, section: ZCRMSection) throws
    {
        var contentValues : [String : Any] = [ String : Any ]()
        contentValues.updateValue(String(layoutId), forKey: ZCRMTableDetails.Section.LAYOUT_ID)
        contentValues.updateValue(section.getName(), forKey: ZCRMTableDetails.Section.SECTION_NAME)
        contentValues.updateValue(section.getDisplayName()!, forKey: ZCRMTableDetails.Section.SECTION_DISPLAY_NAME)
        contentValues.updateValue(section.getColumnCount()!, forKey: ZCRMTableDetails.Section.COLUMN_COUNT)
        contentValues.updateValue(section.getSequence()!, forKey: ZCRMTableDetails.Section.SEQUENCE)
        try db.insert(tableName: ZCRMTableDetails.Section.TABLE_NAME, contentValues: contentValues)
    }
    
    func insertField(layoutId: Int64, sectionName: String, fields: ZCRMField) throws
    {
        var contentValues : [String : Any] = [ String : Any ]()
        contentValues.updateValue(String(layoutId), forKey: ZCRMTableDetails.Fields.LAYOUT_ID)
        contentValues.updateValue(sectionName, forKey: ZCRMTableDetails.Fields.SECTION_NAME)
        contentValues.updateValue(String(fields.getId()!), forKey: ZCRMTableDetails.Fields.FIELD_ID)
        contentValues.updateValue(fields.getAPIName(), forKey: ZCRMTableDetails.Fields.FIELD_APINAME)
        contentValues.updateValue(fields.getDisplayLabel()!, forKey: ZCRMTableDetails.Fields.FIELD_DISPLAY_NAME)
        contentValues.updateValue(fields.getDataType()!, forKey: ZCRMTableDetails.Fields.DATA_TYPE)
        contentValues.updateValue(String(fields.isPresentInCreateLayout()!), forKey: ZCRMTableDetails.Fields.CREATE_LAYOUT)
        contentValues.updateValue(String(fields.isPresentInViewLayout()!), forKey: ZCRMTableDetails.Fields.VIEW_LAYOUT)
        contentValues.updateValue(String(fields.isPresentInEditLayout()!), forKey: ZCRMTableDetails.Fields.EDIT_LAYOUT)
        contentValues.updateValue(String(fields.isPresentInQuickCreateLayout()!), forKey: ZCRMTableDetails.Fields.QUICK_CREATE_LAYOUT)
        contentValues.updateValue(fields.getMaxLength()!, forKey: ZCRMTableDetails.Fields.MAX_LENGTH)
        contentValues.updateValue(String(fields.isCustomField()!), forKey: ZCRMTableDetails.Fields.CUSTOM_FIELD)
        contentValues.updateValue(String(fields.isMandatory()!), forKey: ZCRMTableDetails.Fields.MANDATORY)
        contentValues.updateValue(String(fields.isVisible()!), forKey: ZCRMTableDetails.Fields.VISIBLE)
        contentValues.updateValue(String(fields.isReadOnly()!), forKey: ZCRMTableDetails.Fields.READ_ONLY)
        if(fields.getDefaultValue() != nil)
        {
            contentValues.updateValue(fields.getDefaultValue()!, forKey: ZCRMTableDetails.Fields.DEFAULT_VALUE)
        }
        contentValues.updateValue(fields.getSequenceNo()!, forKey: ZCRMTableDetails.Fields.SEQ_NUM)
        contentValues.updateValue(String(layoutId)+String(fields.getId()!), forKey: ZCRMTableDetails.Fields.UNIQUE_ID)
        try db.insert(tableName: ZCRMTableDetails.Fields.TABLE_NAME, contentValues: contentValues)
    }
    
    func insertFieldPickListValues(layoutId : Int64, fieldId: Int64, pickListValue: ZCRMPickListValue) throws
    {
        var contentValues : [String : Any] = [ String : Any ]()
        contentValues.updateValue(String(fieldId), forKey: ZCRMTableDetails.FieldPickListValues.FIELD_ID)
        contentValues.updateValue(pickListValue.getActualName(), forKey: ZCRMTableDetails.FieldPickListValues.ACTUAL_NAME)
        contentValues.updateValue(pickListValue.getDisplayName(), forKey: ZCRMTableDetails.FieldPickListValues.DISPLAY_NAME)
        contentValues.updateValue(pickListValue.getSequenceNumber(), forKey: ZCRMTableDetails.FieldPickListValues.SEQ_NUM)
        contentValues.updateValue(pickListValue.getMaps().ArrayOfDictToStringArray(), forKey: ZCRMTableDetails.FieldPickListValues.MAPS)
        contentValues.updateValue(String(layoutId)+String(fieldId), forKey: ZCRMTableDetails.FieldPickListValues.UNIQUE_ID)
        try db.insert(tableName: ZCRMTableDetails.FieldPickListValues.TABLE_NAME, contentValues: contentValues)
    }
    
    func getLayoutID(layoutName: String, moduleAPIname: String) throws -> Int64
    {
        var id : Int64 = 0
        let prepareStatement = try db.rawQuery(dbCommand: "SELECT \(ZCRMTableDetails.Layout.LAYOUT_ID) FROM \(ZCRMTableDetails.Layout.TABLE_NAME) WHERE \(ZCRMTableDetails.Layout.LAYOUT_NAME) ='\(layoutName)' AND \(ZCRMTableDetails.Layout.MODULE) = '\(moduleAPIname)'")
        
        while sqlite3_step(prepareStatement) == SQLITE_ROW {
            id = sqlite3_column_int64(prepareStatement, Int32(0))
        }
        
        sqlite3_finalize(prepareStatement)
        db.closeDB()
        return id
        
    }
    
    func getLayouts(apiName: String) throws -> OpaquePointer
    {
        return try db.rawQuery(dbCommand: "\(ZCRMTableDetails.SELECT_TABLE) \(ZCRMTableDetails.Layout.TABLE_NAME) WHERE  \(ZCRMTableDetails.Layout.MODULE) ='\(apiName)'")
    }
    
    func getLayout(layoutId: Int64) throws -> OpaquePointer
    {
        return try db.rawQuery(dbCommand: "\(ZCRMTableDetails.SELECT_TABLE) \(ZCRMTableDetails.Layout.TABLE_NAME) WHERE \(ZCRMTableDetails.Layout.LAYOUT_ID) = '\(layoutId)'")
    }
    
    func getSections(layoutId: Int64) throws -> OpaquePointer
    {
        return try db.rawQuery(dbCommand: "\(ZCRMTableDetails.SELECT_TABLE) \(ZCRMTableDetails.Section.TABLE_NAME) WHERE \(ZCRMTableDetails.Section.LAYOUT_ID) = '\(layoutId)'")
    }
    
    func getFields(layoutId: Int64, sectionName: String) throws -> OpaquePointer
    {
        return try db.rawQuery(dbCommand: "\(ZCRMTableDetails.SELECT_TABLE) \(ZCRMTableDetails.Fields.TABLE_NAME) WHERE \( ZCRMTableDetails.Fields.LAYOUT_ID) = '\(layoutId)' AND \(ZCRMTableDetails.Fields.SECTION_NAME) = '\( sectionName)'")
    }
    
    func getProfiles(layoutId: Int64) throws -> OpaquePointer
    {
        return try db.rawQuery(dbCommand: "\(ZCRMTableDetails.SELECT_TABLE) \(ZCRMTableDetails.Profile.TABLE_NAME) WHERE \(ZCRMTableDetails.Profile.LAYOUT_ID) = '\(layoutId)'")
    }
    
    func getPickListValues(uniqueId: String) throws -> OpaquePointer
    {
        return try db.rawQuery(dbCommand: "\(ZCRMTableDetails.SELECT_TABLE) \(ZCRMTableDetails.FieldPickListValues.TABLE_NAME) WHERE \(ZCRMTableDetails.FieldPickListValues.UNIQUE_ID) = '\(uniqueId)'")
    }
    
    func deleteLayoutDetails(moduleAPIname: String) throws
    {
        try db.execSQL(dbCommand: "\(ZCRMTableDetails.DELETE_TABLE) \(ZCRMTableDetails.Layout.TABLE_NAME) WHERE \(ZCRMTableDetails.Layout.MODULE) = '\(moduleAPIname)'")
        
        db.closeDB()
    }

    
    func getCustomViews(apiName: String) throws -> OpaquePointer
    {
        return try db.rawQuery(dbCommand: "\(ZCRMTableDetails.SELECT_TABLE) \(ZCRMTableDetails.CustomView.TABLE_NAME) WHERE \(ZCRMTableDetails.CustomView.MODULE) ='\(apiName)'")
    }
    
    func getCustomView(customviewId: Int64) throws -> OpaquePointer
    {
        return try db.rawQuery(dbCommand: "\(ZCRMTableDetails.SELECT_TABLE) \(ZCRMTableDetails.CustomView.TABLE_NAME) WHERE \(ZCRMTableDetails.CustomView.CUSTOM_VIEW_ID) = '\(customviewId)'")
    }
    
    func getCustomViewFields(customviewId: Int64) throws -> OpaquePointer
    {
        return try db.rawQuery(dbCommand: "\(ZCRMTableDetails.SELECT_TABLE) \(ZCRMTableDetails.CustomViewFields.TABLE_NAME) WHERE \(ZCRMTableDetails.CustomViewFields.CUSTOM_VIEW_ID) = '\(customviewId)'")
    }
    
    func deleteCustomview(moduleAPIname: String) throws
    {
        try db.execSQL(dbCommand: "\(ZCRMTableDetails.DELETE_TABLE) \(ZCRMTableDetails.CustomView.TABLE_NAME) WHERE \(ZCRMTableDetails.CustomView.MODULE) = '\(moduleAPIname)'")
       
        db.closeDB()
    }
    
    func numberOfRows(tableName: String) throws -> Int
    {
        return try db.noOfRows(tableName: tableName)
    }
    
    func dropTables() throws
    {
        try db.execSQL(dbCommand: ZCRMTableDetails.DROP_TABLE + ZCRMTableDetails.CustomView.TABLE_NAME)
        try db.execSQL(dbCommand: ZCRMTableDetails.DROP_TABLE + ZCRMTableDetails.FieldPickListValues.TABLE_NAME)
        try db.execSQL(dbCommand: ZCRMTableDetails.DROP_TABLE + ZCRMTableDetails.Profile.TABLE_NAME)
        try db.execSQL(dbCommand: ZCRMTableDetails.DROP_TABLE + ZCRMTableDetails.CustomViewFields.TABLE_NAME)
        try db.execSQL(dbCommand: ZCRMTableDetails.DROP_TABLE + ZCRMTableDetails.CustomViewUpdateTime.TABLE_NAME)
        try db.execSQL(dbCommand: ZCRMTableDetails.DROP_TABLE + ZCRMTableDetails.Fields.TABLE_NAME)
        try db.execSQL(dbCommand: ZCRMTableDetails.DROP_TABLE + ZCRMTableDetails.Layout.TABLE_NAME)
        try db.execSQL(dbCommand: ZCRMTableDetails.DROP_TABLE + ZCRMTableDetails.LayoutUpdateTime.TABLE_NAME)
        try db.execSQL(dbCommand: ZCRMTableDetails.DROP_TABLE + ZCRMTableDetails.Section.TABLE_NAME)
    }

}
