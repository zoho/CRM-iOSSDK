//
//  ZCRMTableDetails.swift
//  ZCRMiOS
//
//  Created by Sruthi Ravi on 17/08/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

import Foundation
public class ZCRMTableDetails
{
    public static var CREATE_TABLE = "CREATE TABLE IF NOT EXISTS ";
    public static var DROP_TABLE = "DROP TABLE ";
    public static var SELECT_TABLE = "SELECT * FROM";
    public static var DELETE_TABLE = "DELETE FROM";
    public static var ENABLE_FOREIGN_KEYS = "PRAGMA foreign_keys = ON;"
    
    public class LoggedInToken
    {
        public static var TABLE_NAME = "LoggedInToken";
        public static var AUTHTOKEN = "AUTHTOKEN";
        public static var EMAIL_ID = "EMAIL_ID";
        public static var ACTIVE = "ACTIVE";
    }
    
    public class CustomView
    {
        public static var TABLE_NAME = "CustomViews";
        public static var MODULE = "MODULE";
        public static var NAME = "NAME";
        public static var SYSTEM_NAME = "SYSTEM_NAME";
        public static var DISPLAY_NAME = "DISPLAY_NAME";
        public static var CUSTOM_VIEW_ID = "CUSTOM_VIEW_ID";
        public static var SORT_BY = "SORT_BY";
        public static var SORT_ORDER = "SORT_ORDER";
        public static var CATEGORY = "CATEGORY";
        public static var FAVORITE = "FAVORITE";
        public static var IS_DEFAULT = "IS_DEFAULT";
    }
    
    public class CustomViewFields
    {
        public static var TABLE_NAME = "CustomViewFields";
        public static var CUSTOM_VIEW_ID = "CUSTOM_VIEW_ID";
        public static var FIELD_NAME = "FIELD_NAME";
        public static var MODULE = "MODULE";
    }
    
    public class Layout
    {
        public static var TABLE_NAME = "Layouts";
        public static var MODULE = "MODULE";
        public static var LAYOUT_NAME = "LAYOUT_NAME";
        public static var LAYOUT_ID = "LAYOUT_ID";
        public static var CREATED_BY_NAME = "CREATED_BY_NAME";
        public static var CREATED_BY_ID = "CREATED_BY_ID";
        public static var CREATED_TIME = "CREATED_TIME";
        public static var MODIFIED_BY_NAME = "MODIFIED_BY_NAME";
        public static var MODIFIED_BY_ID = "MODIFIED_BY_ID";
        public static var MODIFIED_TIME = "MODIFIED_TIME";
        public static var STATUS = "STATUS";
        public static var VISIBLE = "VISIBLE";
    }
    
    public class Profile
    {
        public static var TABLE_NAME = "Profile";
        public static var LAYOUT_ID = "LAYOUT_ID";
        public static var PROFILE_NAME = "PROFILE_NAME";
        public static var PROFILE_ID = "PROFILE_ID";
        public static var DEFAULT = "IS_DEFAULT";
    }
    
    public class Section
    {
        public static var TABLE_NAME = "Sections";
        public static var LAYOUT_ID = "LAYOUT_ID";
        public static var SECTION_NAME = "SECTION_NAME";
        public static var SECTION_DISPLAY_NAME = "SECTION_DISPLAY_NAME";
        public static var COLUMN_COUNT = "COLUMN_COUNT";
        public static var SEQUENCE = "SEQUENCE";
    }
    public class Fields
    {
        public static var TABLE_NAME = "Fields";
        public static var LAYOUT_ID = "LAYOUT_ID";
        public static var SECTION_NAME = "SECTION_NAME";
        public static var FIELD_ID = "FIELD_ID";
        public static var FIELD_APINAME = "FIELD_APINAME";
        public static var FIELD_DISPLAY_NAME = "FIELD_DISPLAY_NAME";
        public static var DATA_TYPE = "DATA_TYPE";
        public static var CREATE_LAYOUT = "CREATE_LAYOUT";
        public static var VIEW_LAYOUT = "VIEW_LAYOUT";
        public static var EDIT_LAYOUT = "EDIT_LAYOUT";
        public static var QUICK_CREATE_LAYOUT = "QUICK_CREATE_LAYOUT";
        public static var MAX_LENGTH = "MAX_LENGTH";
        public static var CUSTOM_FIELD = "CUSTOM_FIELD";
        public static var MANDATORY = "MANDATORY";
        public static var VISIBLE = "VISIBLE";
        public static var READ_ONLY = "READ_ONLY";
        public static var DEFAULT_VALUE = "DEFAULT_VALUE";
        public static var SEQ_NUM = "SEQ_NUM";
        public static var UNIQUE_ID = "UNIQUE_ID";
    }
    public class FieldPickListValues
    {
        public static var TABLE_NAME = "FieldPickListValues";
        public static var FIELD_ID = "FIELD_ID";
        public static var DISPLAY_NAME = "DISPLAY_NAME";
        public static var ACTUAL_NAME = "ACTUAL_NAME";
        public static var SEQ_NUM = "SEQ_NUM";
        public static var MAPS = "MAPS";
        public static var UNIQUE_ID = "UNIQUE_ID";
    }
    public class LayoutUpdateTime
    {
        public static var TABLE_NAME = "LayoutUpdateTime";
        public static var MODULE = "MODULE";
        public static var TIME = "TIME";
    }
    public class CustomViewUpdateTime
    {
        public static var TABLE_NAME = "CustomViewUpdateTime";
        public static var MODULE = "MODULE";
        public static var TIME = "TIME";
    }
    public class RecordTable
    {
        public static var UPDATE_TIME = "UPDATE_TIME";
        public static var LAYOUT_NAME = "LAYOUT";
        public static var ID = "ID";
        public static var CREATED_BY_NAME = "CREATED_BY_NAME";
        public static var MODIFIED_BY_NAME = "MODIFIED_BY_NAME";
        public static var OWNER_NAME = "OWNER_NAME";
    }
}
