//
//  ZCRMDrilldownData.swift
//  ZCRMiOS
//
//  Created by Umashri R on 13/02/19.
//

import Foundation

open class ZCRMAnalyticsData : ZCRMEntity
{
    public internal(set) var dashboardId : Int64
    public internal(set) var componentId : Int64
    public internal(set) var reportId : Int64?
    public internal(set) var criteria : ZCRMQuery.ZCRMCriteria?
    public internal(set) var count : Int = APIConstants.INT_MOCK
    public internal(set) var aggregateLabel : String?
    public internal(set) var module : String?
    public internal(set) var requestType : String?
    public internal(set) var rowCount : Int?
    public internal(set) var componentName : String?
    public internal(set) var fields : [Field] = [Field]()
    public internal(set) var rows : [ Row ] = [ Row ]()
    
    init( componentId : Int64, dashboardId : Int64, criteria : ZCRMQuery.ZCRMCriteria? ) {
        self.componentId = componentId
        self.dashboardId = dashboardId
        self.criteria = criteria
    }
    
    public struct Field : Equatable
    {
        public internal( set ) var name : String
        public internal( set ) var label : String
        public internal( set ) var isSortable : Bool?
    }
    
    public struct Row : Equatable
    {
        public internal( set ) var fieldVsValue : [ String : Any ]?
        public internal( set ) var cells : [ Cell ] = [ Cell ]()
        
        init()
        { }
        
        public static func == (lhs: ZCRMAnalyticsData.Row, rhs: ZCRMAnalyticsData.Row) -> Bool {
            var equals : Bool = false
            if ( lhs.fieldVsValue == nil && rhs.fieldVsValue == nil )
            {
                equals = true &&
                    lhs.cells == rhs.cells
            }
            else if let lhsFieldVsValue = lhs.fieldVsValue, let rhsFieldVsValue = rhs.fieldVsValue
            {
                equals = NSDictionary(dictionary: lhsFieldVsValue).isEqual(to: rhsFieldVsValue) &&
                    lhs.cells == rhs.cells
            }
            return equals
        }
    }
    
    public struct Cell : Equatable
    {
        public internal( set ) var label : String?
        public internal( set ) var value : Any?
        public internal( set ) var key : String = APIConstants.STRING_MOCK
        
        init()
        { }
        
        public static func == (lhs: ZCRMAnalyticsData.Cell, rhs: ZCRMAnalyticsData.Cell) -> Bool {
            let equals : Bool = lhs.label == rhs.label &&
                lhs.key == rhs.key &&
                isEqual( lhs : lhs.value, rhs : rhs.value )
            return equals
        }
    }
}

/// Properties & APINames
extension ZCRMAnalyticsData
{
    struct ResponseJSONKeys
    {
        static let componentChuncks = "component_chunks"
        static let requestedObj = "requestedObj"
        static let reportId = "reportId"
        static let limitListCount = "listLimitCount"
        static let module = "module"
        static let reqType = "reqType"
        static let totalRowCount = "totalRowCount"
        static let type = "type"
        static let heading = "heading"
        static let columnName = "COLUMNNAME"
        static let fieldLabel = "FIELDLABEL"
        static let isSortable = "isSortable"
        static let body = "body"
        static let content = "CONTENT"
        static let Module = "MODULE"
        static let users = "Users"
        static let entityId = "ENTITYID"
        static let displayLabel = "DISPLAYLABEL"
        static let dataMap = "data_map"
        static let aggregates = "aggregates"
        static let value = "value"
        static let detailColumnInfo = "detail_column_info"
        static let label = "label"
        static let name = "name"
        static let rows = "rows"
        static let cells = "cells"
        static let aggregateColumnInfo = "aggregate_column_info"
    }
}

extension ZCRMAnalyticsData : Equatable
{
    public static func == (lhs: ZCRMAnalyticsData, rhs: ZCRMAnalyticsData) -> Bool {
        let equals : Bool = lhs.dashboardId == rhs.dashboardId &&
            lhs.componentId == rhs.componentId &&
            lhs.reportId == rhs.reportId &&
            lhs.criteria == rhs.criteria &&
            lhs.count == rhs.count &&
            lhs.aggregateLabel == rhs.aggregateLabel &&
            lhs.module == rhs.module &&
            lhs.requestType == rhs.requestType &&
            lhs.rowCount == rhs.rowCount &&
            lhs.componentName == rhs.componentName &&
            lhs.fields == rhs.fields &&
            lhs.rows == rhs.rows
        return equals
    }
}
