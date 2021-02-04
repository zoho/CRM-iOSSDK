//
//  ZCRMSection.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 14/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//
import ZCacheiOS

public class ZCRMSection : ZCRMEntity, ZCacheSection
{
    public var id: String
    public var apiName : String
    public internal( set ) var name : String = APIConstants.STRING_MOCK
    public internal( set ) var displayName : String = APIConstants.STRING_MOCK
    public internal( set ) var columnCount : Int = APIConstants.INT_MOCK
    public internal( set ) var sequence : Int = APIConstants.INT_MOCK
    public internal( set ) var fields : [ ZCRMField ] = [ ZCRMField ]()
    public internal( set ) var isSubformSection : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var reorderRows : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var tooltip : String?
    public internal( set ) var maximumRows : Int?
    
    public func getFieldFromServer<T>(id: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    {
        var zcrmField: ZCRMField?
        for field in fields
        {
            if field.id == id
            {
                zcrmField = field
            }
        }
        if let zcrmField = zcrmField
        {
            completion(.success(zcrmField as! T))
        }
        else
        {
            completion(.failure(ZCacheError.invalidError(code: ErrorCode.invalidData, message: ErrorMessage.invalidIdMsg, details: nil)))
        }
    }
    
    public func getFieldsFromServer<T>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {
        completion(.success(fields as! [T]))
    }
    
    public func getFieldsFromServer<T>(modifiedSince: String, completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {
        completion(.success(fields as! [T]))
    }
    
    /// Initialise the instance of a section with the given section name.
    ///
    /// - Parameter sectionName: section name whose associated section is to be initialised
    internal init( apiName : String )
    {
        self.id = apiName
        self.apiName = apiName
    }
    
    /// Add given ZCRMFields to the sections.
    ///
    /// - Parameter field: ZCRMField to be added
    internal func addField(field : ZCRMField)
    {
        self.fields.append( field )
    }
    
    enum CodingKeys: String, CodingKey
    {
        case id
        case apiName
        case name
        case displayName
        case columnCount
        case sequence
        case fields
        case isSubformSection
        case reorderRows
        case tooltip
        case maximumRows
    }
    required public init(from decoder: Decoder) throws {
        let container = try! decoder.container(keyedBy: CodingKeys.self)
        
        id = try! container.decode(String.self, forKey: .id)
        apiName = try! container.decode(String.self, forKey: .apiName)
        name = try! container.decode(String.self, forKey: .name)
        displayName = try! container.decode(String.self, forKey: .displayName)
        columnCount = try! container.decode(Int.self, forKey: .columnCount)
        sequence = try! container.decode(Int.self, forKey: .sequence)
        fields = try! container.decode([ZCRMField].self, forKey: .fields)
        isSubformSection = try! container.decode(Bool.self, forKey: .isSubformSection)
        reorderRows = try! container.decode(Bool.self, forKey: .reorderRows)
        tooltip = try! container.decodeIfPresent(String.self, forKey: .tooltip)
        maximumRows = try! container.decodeIfPresent(Int.self, forKey: .maximumRows)
    }
    open func encode( to encoder : Encoder ) throws
    {
        var container = encoder.container( keyedBy : CodingKeys.self )
        
        try! container.encodeIfPresent(self.id, forKey: .id)
        try! container.encode(self.apiName, forKey: .apiName)
        try! container.encode(self.name, forKey: .name)
        try! container.encode(self.displayName, forKey: .displayName)
        try! container.encode(self.columnCount, forKey: .columnCount)
        try! container.encode(self.sequence, forKey: .sequence)
        try! container.encode(self.fields, forKey: .fields)
        try! container.encode(self.isSubformSection, forKey: .isSubformSection)
        try! container.encode(self.reorderRows, forKey: .reorderRows)
        try! container.encodeIfPresent(self.tooltip, forKey: .tooltip)
        try! container.encodeIfPresent(self.maximumRows, forKey: .maximumRows)
    }
}

extension ZCRMSection : Equatable
{
    public static func == (lhs: ZCRMSection, rhs: ZCRMSection) -> Bool {
        let equals : Bool = lhs.name == rhs.name &&
            lhs.displayName == rhs.displayName &&
            lhs.columnCount == rhs.columnCount &&
            lhs.sequence == rhs.sequence &&
            lhs.fields == rhs.fields &&
            lhs.isSubformSection == rhs.isSubformSection
        return equals
    }
}
