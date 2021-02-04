//
//  ZCRMModuleRelation.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 14/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

public class ZCRMModuleRelation : ZCRMEntity, Codable
{
    public internal( set ) var apiName : String = APIConstants.STRING_MOCK
    var parentModuleAPIName : String = APIConstants.STRING_MOCK
    public internal( set ) var label : String = APIConstants.STRING_MOCK
    public internal( set ) var id : Int64 = APIConstants.INT64_MOCK
    public internal( set ) var isVisible : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var isDefault : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var name : String = APIConstants.STRING_MOCK
    public internal( set ) var type : String = APIConstants.STRING_MOCK
    public internal( set ) var module : String?
    public internal( set ) var action : String?
    public internal( set ) var sequenceNo : Int = APIConstants.INT_MOCK
    public internal( set ) var href : String?

    
    /// Initialize the instance of a ZCRMModuleRelation with the given module and related list
    ///
    /// - Parameters:
    ///   - relatedListAPIName: relatedListAPIName whose instance to be initialized
    ///   - parentModuleAPIName: parentModuleAPIName to get that module's relation
    internal init( relatedListAPIName : String, parentModuleAPIName : String )
    {
        self.apiName = relatedListAPIName
        self.parentModuleAPIName = parentModuleAPIName
    }
    
    internal init( parentModuleAPIName : String, relatedListId : Int64 )
    {
        self.parentModuleAPIName = parentModuleAPIName
        self.id = relatedListId
    }
    
    public func getJunctionRecord( recordId : Int64 ) -> ZCRMJunctionRecord
    {
        return ZCRMJunctionRecord( apiName : apiName, id : recordId )
    }
    
    /// Returns list of all records of the module of a requested page number with records of per_page count, before returning the list of records gets sorted with the given field and sort order(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - ofParentRecord: list of records of the module
    ///   - recordParams: Params to be included in fetching the records
    /// - Returns: sorted list of module of the ZCRMRecord
    /// - Throws: ZCRMSDKError if falied to get related records
    public func getRelatedRecords( ofParentRecord : ZCRMRecordDelegate, recordParams : ZCRMQuery.GetRecordParams, completion : @escaping( CRMResultType.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> ())
    {
        do
        {
            try relatedModuleCheck( module : self.apiName )
            RelatedListAPIHandler( parentRecord : ofParentRecord, relatedList : self ).getRecords( recordParams : recordParams ) { ( result ) in
                completion( result )
            }
        }
        catch
        {
            completion( .failure( typeCastToZCRMError( error ) ) )
        }
    }
    
    enum CodingKeys: String, CodingKey
    {
        case apiName
        case parentModuleAPIName
        case label
        case id
        case isVisible
        case isDefault
        case name
        case type
        case module
        case action
        case sequenceNo
        case href
    }
    
    public required convenience init( from decoder : Decoder ) throws
    {
        self.init()
        let values = try! decoder.container(keyedBy: CodingKeys.self)
        
        apiName = try! values.decode(String.self, forKey: .apiName)
        parentModuleAPIName = try! values.decode(String.self, forKey: .parentModuleAPIName)
        label = try! values.decode(String.self, forKey: .label)
        id = try! values.decode(Int64.self, forKey: .id)
        isVisible = try! values.decode(Bool.self, forKey: .isVisible)
        isDefault = try! values.decode(Bool.self, forKey: .isDefault)
        name = try! values.decode(String.self, forKey: .name)
        type = try! values.decode(String.self, forKey: .type)
        module = try! values.decodeIfPresent(String.self, forKey: .module)
        action = try! values.decodeIfPresent(String.self, forKey: .action)
        sequenceNo = try! values.decode(Int.self, forKey: .sequenceNo)
        href = try! values.decodeIfPresent(String.self, forKey: .href)
    }
    
    public func encode( to encoder : Encoder ) throws
    {
        var container = encoder.container( keyedBy : CodingKeys.self )
        try! container.encode(self.apiName, forKey: .apiName)
        try! container.encode(self.parentModuleAPIName, forKey: .id)
        try! container.encode(self.label, forKey: .label)
        try! container.encode(self.id, forKey: .id)
        try! container.encode(self.isVisible, forKey: .isVisible)
        try! container.encode(self.isDefault, forKey: .isDefault)
        try! container.encode(self.name, forKey: .name)
        try! container.encode(self.type, forKey: .type)
        try! container.encode(self.sequenceNo, forKey: .sequenceNo)
        try! container.encodeIfPresent(self.module, forKey: .module)
        try! container.encodeIfPresent(self.action, forKey: .action)
        try! container.encodeIfPresent(self.href, forKey: .href)
    }
    
    init()
    {
        self.apiName = String()
        self.parentModuleAPIName = String()
        self.label = String()
        self.id = Int64()
        self.isVisible = false
        self.isDefault = false
        self.name = String()
        self.type = String()
        self.sequenceNo = Int()
    }
}

extension ZCRMModuleRelation : Hashable
{
    public static func == (lhs: ZCRMModuleRelation, rhs: ZCRMModuleRelation) -> Bool {
        let equals : Bool = lhs.apiName == rhs.apiName &&
            lhs.parentModuleAPIName == rhs.parentModuleAPIName &&
            lhs.label == rhs.label &&
            lhs.id == rhs.id &&
            lhs.isVisible == rhs.isVisible &&
            lhs.name == rhs.name &&
            lhs.type == rhs.type &&
            lhs.module == rhs.module &&
            lhs.action == rhs.action &&
            lhs.href == rhs.href &&
            lhs.sequenceNo == rhs.sequenceNo
        return equals
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine( id )
    }
}
