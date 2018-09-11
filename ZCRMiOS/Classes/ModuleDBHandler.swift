//
//  ZCRMCachedModuleHandler.swift
//  ZCRMiOS
//
//  Created by Sruthi Ravi on 22/08/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

import Foundation
public class ZCRMCachedModuleHandler
{
    private var formDBHelper : FormDBHelper
    private var moduleAPIName : String
    
    init(moduleAPIName apiName: String)
    {
        self.formDBHelper = FormDBHelper()
        moduleAPIName = apiName
    }
    
    func isLayoutUnderDBMode(refreshCache: Bool) throws -> Bool
    {
        try formDBHelper.insertLayoutTime(module: moduleAPIName)
        let currentTimeInMiliseconds : Double = Date().timeIntervalSince1970 * 1000.0
        let time : Double = currentTimeInMiliseconds - (try formDBHelper.getLayoutTime(module: moduleAPIName))
        let noOfRows : Int = try formDBHelper.numberOfRows(tableName: ZCRMTableDetails.Layout.TABLE_NAME)
        if(time >= 4.32e+7 || time == 0 || noOfRows == 0 || refreshCache){
            print("Layouts API mode. refreshCache = \(refreshCache), time = \(time) and no of rows in layouts table = \(noOfRows)")
            return false
        }else{
            print("Layouts DB mode.")
            return true
        }
    }
    
    func saveLayoutsToDB(layouts : [ZCRMLayout]) throws
    {
        try formDBHelper.deleteLayoutDetails(moduleAPIname: moduleAPIName)
        for layout in layouts
        {
            try formDBHelper.insertLayout(module: moduleAPIName, layout: layout)
            try self.setSectionDetails(layout: layout)
            try self.setProfileDetails(layout: layout)
        }
    }
    
    func getLayoutId(layoutName: String) throws -> Int64
    {
        return try formDBHelper.getLayoutID(layoutName: layoutName, moduleAPIname: moduleAPIName)
    }
    
    func getLayout(layoutId: Int64) throws -> ZCRMLayout
    {
        let zcrmLayout = try getLayoutDetailsFromDB(apiName: moduleAPIName, layoutId: layoutId)
        return zcrmLayout
    }
    
    func getAllLayouts() throws -> [ZCRMLayout]
    {
        var layouts : [ZCRMLayout] = [ZCRMLayout]()
        let prepareStatement = try formDBHelper.getLayouts(apiName: moduleAPIName)
        while sqlite3_step(prepareStatement) == SQLITE_ROW {
            let layout = try getLayoutDetailsFromDB(apiName: moduleAPIName, layoutId: sqlite3_column_int64(prepareStatement, Int32(2)))
            layouts.append(layout)
        }
        return layouts
    }
    
    private func setSectionDetails(layout : ZCRMLayout) throws
    {
        let sections : [ZCRMSection] = layout.getAllSections()!
        for section in sections
        {
            try formDBHelper.insertSection(layoutId: layout.getId(), section: section)
            try self.setFieldDetails(layout: layout, section: section)
        }
    }
    
    private func setProfileDetails(layout : ZCRMLayout) throws
    {
        if(layout.getAccessibleProfiles() != nil)
        {
            let profiles : [ZCRMProfile] = layout.getAccessibleProfiles()!
            for profile in profiles
            {
                try formDBHelper.insertLayoutProfiles(layoutId: layout.getId(), profile: profile)
            }
        }
    }
    
    private func setFieldDetails(layout : ZCRMLayout, section : ZCRMSection) throws
    {
        let fields : [ZCRMField] = section.getAllFields()!
        for field in fields
        {
            try formDBHelper.insertField(layoutId: layout.getId(), sectionName: section.getName(), fields: field)
            try self.setPickListDetails(layoutId: layout.getId(), field: field)
        }
    }
    
    private func setPickListDetails(layoutId : Int64, field: ZCRMField) throws
    {
        if(field.getPickListValues() != nil)
        {
            let pickListValues : [ZCRMPickListValue] = field.getPickListValues()!
            for pickListValue in pickListValues
            {
                try formDBHelper.insertFieldPickListValues(layoutId: layoutId, fieldId: field.getId()!, pickListValue: pickListValue)
            }
        }
    }
    
    private func getLayoutDetailsFromDB(apiName: String, layoutId: Int64) throws -> ZCRMLayout
    {
        let layoutJSON : [String:Any] = try getLayoutDetails(layoutId: layoutId)
        let module = ZCRMModule(moduleAPIName: apiName)
        return ModuleAPIHandler(module: module).getZCRMLayout(layoutDetails: layoutJSON)
    }
    
    private func getLayoutDetails(layoutId: Int64) throws -> [String:Any]
    {
        var layoutDetails : [String:Any] = [String:Any]()
        let prepareStatement = try formDBHelper.getLayout(layoutId: layoutId)
        while sqlite3_step(prepareStatement) == SQLITE_ROW
        {
            layoutDetails.updateValue(String(cString: sqlite3_column_text(prepareStatement, Int32(1))!), forKey: "name")
            layoutDetails.updateValue(String(cString: sqlite3_column_text(prepareStatement, Int32(2))!), forKey: "id")
            layoutDetails.updateValue(String(cString:sqlite3_column_text(prepareStatement, Int32(10))!).boolValue(), forKey: "visible")
            layoutDetails.updateValue(Int(sqlite3_column_int(prepareStatement, Int32(9))), forKey: "status")
            
            if(sqlite3_column_text(prepareStatement, Int32(3)) != nil) {
                var createdBy : [String:Any] = [String:Any]()
                createdBy.updateValue(String(cString: sqlite3_column_text(prepareStatement, Int32(3))!), forKey: "name")
                createdBy.updateValue(String(cString: sqlite3_column_text(prepareStatement, Int32(4))!), forKey: "id")
                layoutDetails.updateValue(createdBy, forKey: "created_by")
                layoutDetails.updateValue(String(cString: sqlite3_column_text(prepareStatement, Int32(5))!), forKey: "created_time")
            }
            
            if(sqlite3_column_text(prepareStatement, Int32(6)) != nil) {
                var modifiedBy : [String:Any] = [String:Any]()
                modifiedBy.updateValue(String(cString: sqlite3_column_text(prepareStatement, Int32(6))!), forKey: "name")
                modifiedBy.updateValue(String(cString: sqlite3_column_text(prepareStatement, Int32(7))!), forKey: "id")
                layoutDetails.updateValue(modifiedBy, forKey: "modified_by")
                layoutDetails.updateValue(String(cString: sqlite3_column_text(prepareStatement, Int32(8))!), forKey: "modified_time")
            }
            layoutDetails = try getSectionDetails(layoutDetails: &layoutDetails, layoutId: layoutId )
            layoutDetails = try getProfileDetails(layoutDetails: &layoutDetails, layoutId: layoutId)
        }
        return layoutDetails
    }
    
    
    private func getSectionDetails(layoutDetails: inout [String:Any], layoutId: Int64) throws -> [String:Any]
    {
        var sectionArray : [[String:Any]] = [ [ String : Any ] ]()
        let prepareStatement = try formDBHelper.getSections(layoutId: layoutId)
        while sqlite3_step(prepareStatement) == SQLITE_ROW
        {
            var sectionDetails : [String:Any] = [ String : Any ]()
            sectionDetails.updateValue(String(cString: sqlite3_column_text(prepareStatement, Int32(1))!), forKey: "name")
            sectionDetails.updateValue(String(cString: sqlite3_column_text(prepareStatement, Int32(2))!), forKey: "display_label")
            sectionDetails.updateValue(Int(sqlite3_column_int(prepareStatement, Int32(3))), forKey: "column_count")
            sectionDetails.updateValue(Int(sqlite3_column_int(prepareStatement, Int32(4))), forKey: "sequence_number")
            
            sectionDetails = try getFieldDetails(sectionDetails: &sectionDetails, sectionName: String(cString: sqlite3_column_text(prepareStatement, Int32(1))!), layoutId: layoutId)
            sectionArray.append(sectionDetails)
        }
        layoutDetails.updateValue(sectionArray, forKey: "sections")
        return layoutDetails
    }
    
    private func getFieldDetails(sectionDetails: inout [String:Any], sectionName: String, layoutId: Int64) throws -> [String:Any]
    {
        var fieldArray : [[String:Any]] = [ [ String : Any ] ]()
        let prepareStatement = try formDBHelper.getFields(layoutId: layoutId, sectionName: sectionName)
        while sqlite3_step(prepareStatement) == SQLITE_ROW
        {
            var fieldDetails : [String:Any] = [ String : Any ]()
            fieldDetails.updateValue(String(cString: sqlite3_column_text(prepareStatement, Int32(3))!), forKey: "api_name")
            fieldDetails.updateValue(String(cString: sqlite3_column_text(prepareStatement, Int32(11))!).boolValue(), forKey: "custom_field")
            fieldDetails.updateValue(String(cString: sqlite3_column_text(prepareStatement, Int32(5))!), forKey: "data_type")
            if(sqlite3_column_text(prepareStatement, Int32(15)) != nil)
            {
                fieldDetails.updateValue(String(cString: sqlite3_column_text(prepareStatement, Int32(15))!), forKey: "default_value")
            }
            fieldDetails.updateValue(String(cString: sqlite3_column_text(prepareStatement, Int32(4))!), forKey: "field_label")
            fieldDetails.updateValue(String(cString: sqlite3_column_text(prepareStatement, Int32(2))!), forKey: "id")
            fieldDetails.updateValue(Int(sqlite3_column_int(prepareStatement, Int32(10))), forKey: "length")
            fieldDetails.updateValue(String(cString: sqlite3_column_text(prepareStatement, Int32(14))!).boolValue(), forKey: "read_only")
            fieldDetails.updateValue(String(cString: sqlite3_column_text(prepareStatement, Int32(12))!).boolValue(), forKey: "required")
            fieldDetails.updateValue(Int(sqlite3_column_int(prepareStatement, Int32(16))), forKey: "sequence_number")
            fieldDetails.updateValue(String(cString: sqlite3_column_text(prepareStatement, Int32(13))!).boolValue(), forKey: "visible")
            
            fieldDetails = try getPickListDetails(fieldDetails: &fieldDetails, uniqueId: String(cString: sqlite3_column_text(prepareStatement, Int32(17))!))
            
            var viewType : [String:Any] = [String:Any]()
            viewType.updateValue(String(cString: sqlite3_column_text(prepareStatement, Int32(7))!).boolValue(), forKey: "view")
            viewType.updateValue(String(cString: sqlite3_column_text(prepareStatement, Int32(8))!).boolValue(), forKey: "edit")
            viewType.updateValue(String(cString: sqlite3_column_text(prepareStatement, Int32(6))!).boolValue(), forKey: "create")
            viewType.updateValue(String(cString: sqlite3_column_text(prepareStatement, Int32(9))!).boolValue(), forKey: "quick_create")
            fieldDetails.updateValue(viewType, forKey: "view_type")
            
            fieldArray.append(fieldDetails)
        }
        sectionDetails.updateValue(fieldArray, forKey: "fields")
        return sectionDetails
    }
    
    private func getPickListDetails(fieldDetails: inout [String:Any], uniqueId: String) throws -> [String:Any]
    {
        var pickListArray : [[String:Any]] = [ [ String : Any ] ]()
        let prepareStatement = try formDBHelper.getPickListValues(uniqueId: uniqueId)
        while sqlite3_step(prepareStatement) == SQLITE_ROW
        {
            var pickListDetails : [String:Any] = [ String : Any ]()
            pickListDetails.updateValue(String(cString: sqlite3_column_text(prepareStatement, Int32(2))!), forKey: "display_value")
            pickListDetails.updateValue(String(cString: sqlite3_column_text(prepareStatement, Int32(1))!), forKey: "actual_value")
            pickListDetails.updateValue(Int(sqlite3_column_int(prepareStatement, Int32(3))), forKey: "sequence_number")
            pickListDetails.updateValue(try String(cString: sqlite3_column_text(prepareStatement, Int32(4))!).toNSArray(), forKey: "maps")
            pickListArray.append(pickListDetails)
        }
        fieldDetails.updateValue(pickListArray, forKey: "pick_list_values")
        return fieldDetails
    }
    
    private func getProfileDetails(layoutDetails: inout [String:Any], layoutId: Int64) throws -> [String:Any]
    {
        var profileArray : [[String:Any]] = [ [ String : Any ] ]()
        let prepareStatement = try formDBHelper.getProfiles(layoutId: layoutId)
        while sqlite3_step(prepareStatement) == SQLITE_ROW
        {
            var profileDetails : [String:Any] = [ String : Any ]()
            profileDetails.updateValue(String(cString: sqlite3_column_text(prepareStatement, Int32(1))!), forKey: "id")
            profileDetails.updateValue(String(cString: sqlite3_column_text(prepareStatement, Int32(2))!), forKey: "name")
            profileDetails.updateValue(String(cString: sqlite3_column_text(prepareStatement, Int32(3))!).boolValue(), forKey: "default")
            profileArray.append(profileDetails)
        }
        layoutDetails.updateValue(profileArray, forKey: "profiles")
        return layoutDetails
    }
    
    func isCustomViewUnderDBMode(refreshCache: Bool) throws -> Bool
    {
        try formDBHelper.insertCustomViewTime(module: self.moduleAPIName)
        let currentTimeInMiliseconds : Double = Date().timeIntervalSince1970 * 1000.0
        let time : Double = currentTimeInMiliseconds - (try formDBHelper.getCustomViewTime(module: self.moduleAPIName))
        let noOfRows : Int = try formDBHelper.numberOfRows(tableName: ZCRMTableDetails.CustomView.TABLE_NAME)
        if(time >= 4.32e+7 || time == 0 || noOfRows == 0 || refreshCache){
            print("Custom View API mode. refreshCache = \(refreshCache), time = \(time) and no of rows in cv table = \(noOfRows)")
            return false
        }else{
            print("Custom View DB mode.")
            return true
        }
    }
    
    func saveCustomViewsToDB(customViews : [ZCRMCustomView]) throws
    {
        try formDBHelper.deleteCustomview(moduleAPIname: moduleAPIName)
        for customView in customViews
        {
            try formDBHelper.insertCustomView(module: self.moduleAPIName, customView: customView)
            try self.setCvFieldDetails(moduleAPIname: moduleAPIName, customView: customView )
        }
    }
    
    private func setCvFieldDetails(moduleAPIname: String, customView: ZCRMCustomView) throws
    {
        if let fieldNames = customView.getDisplayFieldsAPINames()
        {
            for fieldName in fieldNames
            {
                try formDBHelper.insertCustomViewFields(moduleAPIname: moduleAPIName, customViewId: customView.getId(), fieldName: fieldName)
            }
        }
    }
    
    func getCustomView(customViewId: Int64) throws -> ZCRMCustomView
    {
        return try getCvDetailsFromDB(cvId: customViewId)
    }
    
    func getAllCustomViews() throws -> [ZCRMCustomView]?
    {
        var customviews : [ZCRMCustomView] = [ZCRMCustomView]()
        let prepareStatement = try formDBHelper.getCustomViews(apiName: self.moduleAPIName)
        while sqlite3_step(prepareStatement) == SQLITE_ROW {
            let customview : ZCRMCustomView = try getCvDetailsFromDB(cvId: sqlite3_column_int64(prepareStatement, Int32(6)))
            customviews.append(customview)
        }
        return customviews
    }
    
    private func getCvDetailsFromDB(cvId: Int64) throws -> ZCRMCustomView
    {
        let cvJSON : [String:Any] = try getCvDetails(cvId: cvId)
        let module = ZCRMModule(moduleAPIName: self.moduleAPIName)
        return ModuleAPIHandler(module: module).getZCRMCustomView(cvDetails: cvJSON)
    }
    
    private func getCvDetails(cvId: Int64) throws -> [String:Any]
    {
        var cvDetails : [String:Any] = [String:Any]()
        let prepareStatement = try formDBHelper.getCustomView(customviewId: cvId)
        while sqlite3_step(prepareStatement) == SQLITE_ROW
        {
            cvDetails.updateValue(String(cString: sqlite3_column_text(prepareStatement, Int32(6))!), forKey: "id")
            cvDetails.updateValue(String(cString: sqlite3_column_text(prepareStatement, Int32(1))!), forKey: "name")
            cvDetails.updateValue(String(cString: sqlite3_column_text(prepareStatement, Int32(2))!), forKey: "display_value")
            cvDetails.updateValue(String(cString: sqlite3_column_text(prepareStatement, Int32(9))!).boolValue(), forKey: "default")
            cvDetails.updateValue(String(cString: sqlite3_column_text(prepareStatement, Int32(3))!), forKey: "system_name")
            cvDetails.updateValue(String(cString: sqlite3_column_text(prepareStatement, Int32(7))!), forKey: "category")
            cvDetails.updateValue(Int(sqlite3_column_int(prepareStatement, Int32(8))), forKey: "favorite")
            if(sqlite3_column_text(prepareStatement, Int32(4)) != nil)
            {
            cvDetails.updateValue(String(cString: sqlite3_column_text(prepareStatement, Int32(4))!), forKey: "sort_by")
            }
            if(sqlite3_column_text(prepareStatement, Int32(5)) != nil)
            {
            cvDetails.updateValue(String(cString: sqlite3_column_text(prepareStatement, Int32(5))!), forKey: "sort_order")
            }
            cvDetails = try getCVfields(cvDetails: &cvDetails,cvId: cvId)
        }
        return cvDetails
    }
    
    private func getCVfields(cvDetails: inout [String:Any], cvId: Int64) throws -> [String:Any]
    {
        var fieldNames : [String] = [String]()
        let prepareStatement = try formDBHelper.getCustomViewFields(customviewId: cvId)
        while sqlite3_step(prepareStatement) == SQLITE_ROW {
           fieldNames.append(String(cString: sqlite3_column_text(prepareStatement, Int32(1))!))
        }
        cvDetails.updateValue(fieldNames, forKey: "fields")
        return cvDetails
    }
}
