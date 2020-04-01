//
//  ZCRMQuery.swift
//  ZCRMiOS
//
//  Created by Umashri R on 24/01/19.
//

public class ZCRMQuery
{
    public struct GetRecordParams
    {
        public var kanbanViewColumn : String?
        public var modifiedSince : String?
        public var fields : [String]?
        public var includePrivateFields : Bool?
        public var isConverted : Bool?
        public var isApproved : Bool?
        public var sortOrder : SortOrder?
        public var sortBy : String?
        public var page : Int?
        public var perPage : Int?
        public internal( set ) var startDateTime : String?
        public internal( set ) var endDateTime : String?
        public var filter : ZCRMCriteria?
        
        public init()
        { }
        
        mutating public func setEventCriteria( startDateTime : String, endDateTime : String )
        {
            self.startDateTime = startDateTime
            self.endDateTime = endDateTime
        }
    }
    
    public struct GetDrilldownDataParams
    {
        public var criteria : ZCRMCriteria?
        public var page : Int?
        public var fromHierarchy : Bool?
        public internal( set ) var drillBy : DrillBy?
        public internal( set ) var hierarchyFilterId : Int64?
        internal var fromIndex : Int?
        public var sortBy : String?
        public var sortOrder : SortOrder?
        
        public init( criteria : ZCRMCriteria, page : Int )
        {
            self.criteria = criteria
            self.page = page
            self.fromIndex = ( 101 * ( page - 1 ) ) + 1
        }
        
        public init( page : Int = 1 )
        {
            self.page = page
            self.fromIndex = ( 101 * ( page - 1 ) ) + 1
        }
        
        mutating public func setDrilldown( drillBy : DrillBy, hierarchyFilterId : Int64 )
        {
            self.drillBy = drillBy
            self.hierarchyFilterId = hierarchyFilterId
        }
        
        internal func getDrilldownAsString() -> String?
        {
            if self.drillBy != nil && self.hierarchyFilterId != nil
            {
                let drilldown = self.getDrilldownAsJSON()
                return drilldown.toString()
            }
            return nil
        }
        
        func getDrilldownAsJSON() -> [ String : Any ]
        {
            var drilldown : [ String : Any ] = [ String : Any ]()
            drilldown[ RequestParamKeys.drillBy ] = self.drillBy?.rawValue
            drilldown[ RequestParamKeys.hierarchyFilterId ] = self.hierarchyFilterId
            return drilldown
        }
    }
    
    public class ZCRMCriteria : Equatable
    {
        public var apiName : String
        public var comparator : String
        public var value : String
        internal var type : String?
        internal var recordQuery : String?
        internal var drilldownQuery : String?
        private var criteriaJSON : [ String : Any ] = [ String : Any ]()
        internal var filterJSON : [ String : Any ] = [ String : Any ]()
        internal var filterQuery : String?
        
        internal init(apiName : String, comparator : String, value : String) {
            self.apiName = apiName
            self.comparator = comparator
            self.value = value
            if self.apiName.contains( "(" ) && self.apiName.contains( "-" ) && self.apiName.contains( "/" ) && self.apiName.contains( ")" )
            {
                self.type = Constants.FORMULA_EXPRESSION
            }
            self.criteriaJSON = self.getCriteriaAsJSON()
            self.filterJSON = self.getFilterAsJSON()
            var recordQuery : String = "("
            recordQuery.append( contentsOf : self.apiName )
            recordQuery.append( ":" )
            recordQuery.append( contentsOf : self.comparator )
            recordQuery.append( ":" )
            recordQuery.append( contentsOf : self.value )
            recordQuery.append( ")" )
            self.recordQuery = recordQuery
            self.drilldownQuery = self.criteriaJSON.toString()
            self.filterQuery = self.filterJSON.toString()
        }
        
        public convenience init( apiName : String, comparator : Comparator, value : String )
        {
            self.init(apiName: apiName, comparator: comparator.criteria, value: value)
        }
        
        internal func getCriteriaAsJSON() -> [ String : Any ]
        {
            var criteria : [ String : Any ] = [ String : Any ]()
            criteria[ RequestParamKeys.apiName ] = self.apiName
            criteria[ RequestParamKeys.comparator ] = self.comparator
            criteria[ RequestParamKeys.value ] = self.value
            criteria[ RequestParamKeys.type ] = self.type
            return criteria
        }
        
        private func getFilterAsJSON() -> [ String : Any ]
        {
            var criteria : [ String : Any ] = [ String : Any ]()
            var fields : [ String : Any ] = [ String : Any ]()
            fields[ RequestParamKeys.apiName ] = self.apiName
            criteria[ RequestParamKeys.field ] = fields
            criteria[ RequestParamKeys.comparator ] = self.comparator
            criteria[ RequestParamKeys.value ] = self.value
            return criteria
        }
        
        public func and( criteria : ZCRMQuery.ZCRMCriteria )
        {
            self.add( operatorString : RequestParamKeys.and, criteria : criteria )
        }
        
        public func or( criteria : ZCRMQuery.ZCRMCriteria )
        {
            self.add( operatorString : RequestParamKeys.or, criteria : criteria )
        }
        
        private func add( operatorString : String, criteria : ZCRMQuery.ZCRMCriteria )
        {
            if let selfRecordQuery = self.recordQuery, let anotherRecordQuery = criteria.recordQuery
            {
                var recordQuery : String = "("
                recordQuery.append( contentsOf : selfRecordQuery )
                recordQuery.append( contentsOf : operatorString )
                recordQuery.append( contentsOf : anotherRecordQuery )
                recordQuery.append( ")" )
                self.recordQuery = recordQuery
            }
            if let selfDrilldownQuery = self.drilldownQuery, let anotherDrilldownQuery = criteria.drilldownQuery
            {
                var drilldownQuery : String = selfDrilldownQuery
                drilldownQuery.append( contentsOf : ",\"\( operatorString )\"," )
                drilldownQuery.append( contentsOf : anotherDrilldownQuery )
                self.drilldownQuery = drilldownQuery
            }
            var filterJSON = [ String : Any ]()
            var groups = [ [ String : Any ] ]()
            filterJSON[ RequestParamKeys.groupOperator ] = operatorString
            groups.append( self.filterJSON )
            groups.append( criteria.filterJSON )
            filterJSON[ RequestParamKeys.group ] = groups
            self.filterJSON = filterJSON
            self.filterQuery = self.filterJSON.toString()
        }
        
        public struct Constants
        {
            public static let EMPTY : String = "${EMPTY}"
            public static let EQUAL : String = "equal"
            public static let BETWEEN : String = "between"
            internal static let FORMULA_EXPRESSION : String = "formula_expression"
        }
        
        public static func == (lhs: ZCRMQuery.ZCRMCriteria, rhs: ZCRMQuery.ZCRMCriteria) -> Bool {
            let equals : Bool = lhs.apiName == rhs.apiName &&
                lhs.comparator == rhs.comparator &&
                lhs.value == rhs.value &&
                lhs.type == rhs.type &&
                NSDictionary( dictionary : lhs.criteriaJSON ).isEqual( to : rhs.criteriaJSON )
            return equals
        }
    }
    
    public enum Comparator {
        
        case string( StringComparator )
        case integer( IntegerComparator )
        case array( ArrayComparator )
        case id( IdComparator )
        
        var criteria : String {
            switch self {
            case .string(let str) :
                return str.rawValue
            case .id(let str) :
                return str.rawValue
            case .array(let str) :
                return str.rawValue
            case .integer(let str) :
                return str.rawValue
            }
        }
        
        static func == (lhs : Comparator , rhs : Comparator) -> Bool
        {
            if case .string = lhs, case .string = rhs {
                if lhs.criteria == rhs.criteria
                {
                    return true
                }
            }
            else if case .array = lhs, case .array = rhs {
                if lhs.criteria == rhs.criteria
                {
                    return true
                }
            }
            else if case .integer = lhs, case .integer = rhs {
                if lhs.criteria == rhs.criteria
                {
                    return true
                }
            }
            else if case .id = lhs, case .id = rhs {
                if lhs.criteria == rhs.criteria
                {
                    return true
                }
            }
            return false
        }
    }

    public enum StringComparator : String {
        case equal = "equal"
        case equals = "equals"
        case notEqual = "not_equal"
        case like = "like"
        case notLike = "not_like"
        case startsWith = "starts_with"
        case endsWith = "ends_with"
        case contains = "contains"
        case notContains = "not_contains"
        case between = "between"
    }

    public enum IntegerComparator : String {
        case equal = "equal"
        case notEqual = "not_equal"
        case greaterThan = "greater_than"
        case greaterEqual = "greater_equal"
        case lessEqual = "less_equal"
        case lessThan = "less_than"
    }

    public enum ArrayComparator : String {
        case equal = "equal"
        case notEqual = "not_equal"
        case `in` = "in"
        case notIn = "not_in"
        case contains = "contains"
        case notContains = "not_contains"
        case startsWith = "starts_with"
        case endsWith = "ends_with"
    }

    public enum IdComparator : String {
        case equal = "equal"
        case notEqual = "not_equal"
    }
}

extension RequestParamKeys
{
    static let field = "field"
    static let apiName = "api_name"
    static let comparator = "comparator"
    static let value = "value"
    static let and = "and"
    static let or = "or"
    static let groupOperator = "group_operator"
    static let drillBy : String = "drill_by"
    static let hierarchyFilterId : String = "hierarchy_filter_id"
}

@available(*, deprecated, message: "Use ZCRMQuery.Comparator instead" )
public enum Comparator {
    
    case string( StringComparator )
    case integer( IntegerComparator )
    case array( ArrayComparator )
    case id( IdComparator )
    
    var criteria : String {
        switch self {
        case .string(let str) :
            return str.rawValue
        case .id(let str) :
            return str.rawValue
        case .array(let str) :
            return str.rawValue
        case .integer(let str) :
            return str.rawValue
        }
    }
}

@available(*, deprecated, message: "Use ZCRMQuery.Comparator instead" )
extension Comparator {
    
    static func == (lhs : Comparator , rhs : Comparator) -> Bool
    {
        if case .string = lhs, case .string = rhs {
            if lhs.criteria == rhs.criteria
            {
                return true
            }
        }
        else if case .array = lhs, case .array = rhs {
            if lhs.criteria == rhs.criteria
            {
                return true
            }
        }
        else if case .integer = lhs, case .integer = rhs {
            if lhs.criteria == rhs.criteria
            {
                return true
            }
        }
        else if case .id = lhs, case .id = rhs {
            if lhs.criteria == rhs.criteria
            {
                return true
            }
        }
        return false
    }
}

@available(*, deprecated, message: "Use ZCRMQuery.StringComparator instead" )
public enum StringComparator : String {
    case equal = "equal"
    case equals = "equals"
    case notEqual = "not_equal"
    case like = "like"
    case notLike = "not_like"
    case startsWith = "starts_with"
    case endsWith = "ends_with"
    case contains = "contains"
    case notContains = "not_contains"
}

@available(*, deprecated, message: "Use ZCRMQuery.IntegerComparator instead" )
public enum IntegerComparator : String {
    case equal = "equal"
    case notEqual = "not_equal"
    case greaterThan = "greater_than"
    case greaterEqual = "greater_equal"
    case lessEqual = "less_equal"
    case lessThan = "less_than"
}

@available(*, deprecated, message: "Use ZCRMQuery.ArrayComparator instead" )
public enum ArrayComparator : String {
    case equal = "equal"
    case notEqual = "not_equal"
    case `in` = "in"
    case notIn = "not_in"
    case contains = "contains"
    case notContains = "not_contains"
    case startsWith = "starts_with"
    case endsWith = "ends_with"
}

@available(*, deprecated, message: "Use ZCRMQuery.IdComparator instead" )
public enum IdComparator : String {
    case equal = "equal"
    case notEqual = "not_equal"
}
