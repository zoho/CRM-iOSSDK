//
//  ZCRMLayout.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 14/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//
import ZCacheiOS

open class ZCRMLayout : ZCRMLayoutDelegate
{
    public internal( set ) var createdBy : ZCRMUserDelegate?
    public internal( set ) var createdTime : String?
    public internal( set ) var modifiedBy : ZCRMUserDelegate?
    public internal( set ) var modifiedTime : String?
    public internal( set ) var isVisible : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var status : Int = APIConstants.INT_MOCK
    public internal( set ) var sections : [ ZCRMSection ] = [ ZCRMSection ]()
    public internal( set ) var accessibleProfiles : [ ZCRMProfileDelegate ] = [ ZCRMProfileDelegate ]()
    
    init( name : String )
    {
        super.init( id : APIConstants.STRING_MOCK, name : name )
    }
    
    enum CodingKeys: String, CodingKey
    {
        case createdBy
        case createdTime
        case modifiedBy
        case modifiedTime
        case isVisible
        case status
        case sections
        case accessibleProfiles
    }
    required public init(from decoder: Decoder) throws {
        try! super.init(from: decoder)
        let container = try! decoder.container(keyedBy: CodingKeys.self)
        
        createdBy = try! container.decodeIfPresent(ZCRMUserDelegate.self, forKey: .createdBy)
        createdTime = try! container.decodeIfPresent(String.self, forKey: .createdTime)
        modifiedBy = try! container.decodeIfPresent(ZCRMUserDelegate.self, forKey: .modifiedBy)
        modifiedTime = try! container.decodeIfPresent(String.self, forKey: .modifiedTime)
        isVisible = try! container.decode(Bool.self, forKey: .isVisible)
        status = try! container.decode(Int.self, forKey: .status)
        sections = try! container.decode([ ZCRMSection ].self, forKey: .sections)
        accessibleProfiles = try! container.decode([ ZCRMProfileDelegate ].self, forKey: .accessibleProfiles)
    }
    open override func encode( to encoder : Encoder ) throws
    {
        try! super.encode(to: encoder)
        var container = encoder.container( keyedBy : CodingKeys.self )
        
        try! container.encodeIfPresent(self.createdBy, forKey: .createdBy)
        try! container.encodeIfPresent(self.createdTime, forKey: .createdTime)
        try! container.encodeIfPresent(self.modifiedBy, forKey: .modifiedBy)
        try! container.encodeIfPresent(self.modifiedTime, forKey: .modifiedTime)
        try! container.encode(self.isVisible, forKey: .isVisible)
        try! container.encode(self.status, forKey: .status)
        try! container.encode(self.sections, forKey: .sections)
        try! container.encode(self.accessibleProfiles, forKey: .accessibleProfiles)
    }
    
    public override func getSectionFromServer<T>(id: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    {
        var zcrmSection: ZCRMSection?
        for section in sections
        {
            if section.apiName == name
            {
                zcrmSection = section
            }
        }
        if let zcrmSection = zcrmSection
        {
            completion(.success(zcrmSection as! T))
        }
        else
        {
            completion(.failure(ZCacheError.invalidError(code: ErrorCode.invalidData, message: ErrorMessage.invalidNameMsg, details: nil)))
        }
    }
    
    public override func getSectionsFromServer<T>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {
        completion(.success(sections as! [T]))
    }
    
    public override func getSectionsFromServer<T>(modifiedSince: String, completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {
        completion(.success(sections as! [T]))
    }
    
    public override func getFieldFromServer<T>(id: String, completion: @escaping ((Result<T, ZCacheError>) -> Void))
    {
        var zcrmField: ZCRMField?
        for section in sections
        {
            for field in section.fields
            {
                if field.id == id
                {
                    zcrmField = field
                    break
                }
            }
        }
        if let zcrmField = zcrmField
        {
            completion(.success(zcrmField as! T))
        }
        else
        {
            completion(.failure(ZCacheError.invalidError(code: ErrorCode.invalidData, message: ErrorMessage.invalidNameMsg, details: nil)))
        }
    }
    
    public override func getFieldsFromServer<T>(completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {
        var fields = [ZCacheField]()
        for section in sections
        {
            fields.append(contentsOf: section.fields)
        }
        completion(.success(fields as! [T]))
    }
    
    public override func getFieldsFromServer<T>(modifiedSince: String, completion: @escaping ((Result<[T], ZCacheError>) -> Void))
    {
        var fields = [ZCacheField]()
        for section in sections
        {
            fields.append(contentsOf: section.fields)
        }
        completion(.success(fields as! [T]))
    }
    
    /// Add ZCRMSection to the ZCRMLayout.
    ///
    /// - Parameter section: ZCRMSection to be added
    internal func addSection(section : ZCRMSection)
    {
        self.sections.append(section)
    }
}

extension ZCRMLayout
{
    public static func == (lhs: ZCRMLayout, rhs: ZCRMLayout) -> Bool {
        let equals : Bool = lhs.createdBy == rhs.createdBy &&
            lhs.createdTime == rhs.createdTime &&
            lhs.modifiedBy == rhs.modifiedBy &&
            lhs.modifiedTime == rhs.modifiedTime &&
            lhs.isVisible == rhs.isVisible &&
            lhs.status == rhs.status &&
            lhs.sections == rhs.sections &&
            lhs.accessibleProfiles == rhs.accessibleProfiles
        return equals
    }
}
