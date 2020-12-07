//
//  ZCRMCustomView.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 17/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

open class ZCRMCustomView : ZCRMEntity, Codable
{
    public internal( set ) var id : Int64 = APIConstants.INT64_MOCK
    var moduleAPIName : String
    public internal( set ) var sysName : String?
    public internal( set ) var isDefault : Bool = APIConstants.BOOL_MOCK
    
    public internal( set ) var name : String
    public internal( set ) var displayName : String = APIConstants.STRING_MOCK
    public internal( set ) var fields : [String] = [String]()
    public internal( set ) var favouriteSequence : Int?
    public internal( set ) var sortByCol : String?
    public internal( set ) var sortOrder : SortOrder?
    public internal( set ) var category : String = APIConstants.STRING_MOCK
    public internal( set ) var isOffline : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var isSystemDefined : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var sharedType : String?
    public internal( set ) var criteria : ZCRMQuery.ZCRMCriteria?
    public internal( set ) var sharedDetails : String?
    
    /// Initialise the instance of a custom view with the given custom view Id.
    ///
    /// - Parameters:
    ///   - cvName: custom view Name whose associated custom view is to be initialised
    ///   - moduleAPIName: module API name of a custom view is to be initialised
    init ( name : String, moduleAPIName : String )
    {
        self.name = name
        self.moduleAPIName = moduleAPIName
    }
    
    public func getFilters( completion: @escaping( ResultType.DataResponse< [ ZCRMFilter ], BulkAPIResponse > ) -> () )
    {
        ModuleAPIHandler( module : ZCRMModuleDelegate( apiName : self.moduleAPIName ), cacheFlavour : .urlVsResponse ).getFilters( cvId : self.id ) { ( result ) in
            completion( result )
        }
    }
    
    public func getFiltersFromServer( completion: @escaping( ResultType.DataResponse< [ ZCRMFilter ], BulkAPIResponse > ) -> () )
    {
        ModuleAPIHandler( module : ZCRMModuleDelegate( apiName : self.moduleAPIName ), cacheFlavour : .noCache ).getFilters( cvId : self.id ) { ( result ) in
            completion( result )
        }
    }
    
    public func getRecords( recordParams : ZCRMQuery.GetRecordParams, completion : @escaping( ResultType.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : ZCRMModuleDelegate( apiName : self.moduleAPIName ) ).getRecords(cvId: self.id, filterId: nil, recordParams: recordParams) { ( result ) in
            completion( result )
        }
    }
    
    enum CodingKeys: String, CodingKey
    {
        case id
        case moduleAPIName
        case sysName
        case isDefault
        case name
        case displayName
        case fields
        case favouriteSequence
        case sortByCol
        case sortOrder
        case category
        case isOffline
        case isSystemDefined
        case sharedType
        case criteria
        case sharedDetails
    }
    
    public required convenience init( from decoder : Decoder ) throws
    {
        self.init()
        let values = try! decoder.container(keyedBy: CodingKeys.self)
        
        id = try! values.decode(Int64.self, forKey: .id)
        moduleAPIName = try! values.decode(String.self, forKey: .moduleAPIName)
        sysName = try! values.decodeIfPresent(String.self, forKey: .sysName)
        isDefault = try! values.decode(Bool.self, forKey: .isDefault)
        name = try! values.decode(String.self, forKey: .name)
        displayName = try! values.decode(String.self, forKey: .displayName)
        fields = try! values.decode([String].self, forKey: .fields)
        favouriteSequence = try! values.decodeIfPresent(Int.self, forKey: .favouriteSequence)
        sortByCol = try! values.decodeIfPresent(String.self, forKey: .sortByCol)
        sortOrder = try! values.decodeIfPresent(SortOrder.self, forKey: .sortOrder)
        category = try! values.decode(String.self, forKey: .category)
        isOffline = try! values.decode(Bool.self, forKey: .isOffline)
        isSystemDefined = try! values.decode(Bool.self, forKey: .isSystemDefined)
        sharedType = try! values.decodeIfPresent(String.self, forKey: .sharedType)
//        criteria = try! values.decodeIfPresent(ZCRMQuery.ZCRMCriteria.self, forKey: .criteria)
        sharedDetails = try! values.decodeIfPresent(String.self, forKey: .sharedDetails)
    }
    
    public func encode( to encoder : Encoder ) throws
    {
        var container = encoder.container( keyedBy : CodingKeys.self )
        try! container.encode(self.id, forKey: .id)
        try! container.encode(self.moduleAPIName, forKey: .moduleAPIName)
        try! container.encodeIfPresent(self.sysName, forKey: .sysName)
        try! container.encode(self.isDefault, forKey: .isDefault)
        
        try! container.encode(self.name, forKey: .name)
        try! container.encode(self.displayName, forKey: .displayName)
        try! container.encode(self.fields, forKey: .fields)
        try! container.encodeIfPresent(self.favouriteSequence, forKey: .favouriteSequence)
        try! container.encodeIfPresent(self.sortByCol, forKey: .sortByCol)
        
        try! container.encodeIfPresent(self.sortOrder, forKey: .sortOrder)
        try! container.encode(self.category, forKey: .category)
        try! container.encode(self.isOffline, forKey: .isOffline)
        try! container.encode(self.isSystemDefined, forKey: .isSystemDefined)
        try! container.encodeIfPresent(self.sharedType, forKey: .sharedType)
//        try! container.encodeIfPresent(self.criteria, forKey: .criteria)
        try! container.encodeIfPresent(self.sharedDetails, forKey: .sharedDetails)
    }
    
    init()
    {
        self.id = APIConstants.INT64_MOCK
        self.moduleAPIName = String()
        self.isDefault = false
        self.name = String()
        self.displayName = String()
        self.fields = []
        self.category = String()
        self.isOffline = false
        self.isSystemDefined = false
    }
}

extension ZCRMCustomView : Hashable
{
    public static func == (lhs: ZCRMCustomView, rhs: ZCRMCustomView) -> Bool {
        var criteriaFlag : Bool = false
        if lhs.criteria == nil && rhs.criteria == nil
        {
            criteriaFlag = true
        }
        else
        {
            return false
        }
        let equals : Bool = lhs.moduleAPIName == rhs.moduleAPIName &&
            lhs.sysName == rhs.sysName &&
            lhs.isDefault == rhs.isDefault &&
            lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.displayName == rhs.displayName &&
            lhs.fields == rhs.fields &&
            lhs.favouriteSequence == rhs.favouriteSequence &&
            lhs.sortByCol == rhs.sortByCol &&
            lhs.sortOrder == rhs.sortOrder &&
            lhs.category == rhs.category &&
            lhs.isOffline == rhs.isOffline &&
            lhs.isSystemDefined == rhs.isSystemDefined &&
            lhs.sharedType == rhs.sharedType &&
            lhs.sharedDetails == rhs.sharedDetails &&
            lhs.criteria == rhs.criteria &&
            criteriaFlag
        return equals
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine( id )
    }
}
