//
//  ZCRMTag.swift
//  ZCRMiOS
//
//  Created by Umashri R on 30/07/18.
//

import Foundation

public class ZCRMTag : ZCRMEntity
{
    private var id : Int64?
    private var name : String?
    private var createdBy : ZCRMUser?
    private var createdTime : String?
    private var modifiedBy : ZCRMUser?
    private var modifiedTime : String?
    private var moduleAPIName : String?
    
    /// Initialize the instance of ZCRMTag with the given tag id
    ///
    /// - Parameter tagId: id to get that tag's instance
    public init(tagId : Int64)
    {
        self.id = tagId
    }
    
    public init( tagId : Int64, moduleAPIName : String )
    {
        self.id = tagId
        self.moduleAPIName = moduleAPIName
    }
    
    /// Initialize the instance of ZCRMTag with the given tag name
    ///
    /// - Parameter tagName: name to get that tag's instance
    public init(tagName : String)
    {
        self.name = tagName
    }
    
    public init( tagId : Int64, tagName : String, moduleAPIName : String )
    {
        self.id = tagId
        self.name = tagName
        self.moduleAPIName = moduleAPIName
    }
    
    public init()
    { }
    
    internal func setModuleAPIName( moduleAPIName : String? )
    {
        self.moduleAPIName = moduleAPIName
    }
    
    public func getModuleAPIName() -> String?
    {
        return self.moduleAPIName
    }
    
    internal func setId(tagId : Int64?)
    {
        self.id = tagId
    }
    
    public func getId() -> Int64?
    {
        return self.id
    }
    
    internal func setName(tagName : String?)
    {
        self.name = tagName
    }
    
    public func getName() -> String?
    {
        return self.name
    }
    
    internal func setCreatedBy(createdBy : ZCRMUser?)
    {
        self.createdBy = createdBy
    }
    
    public func getCreatedBy() -> ZCRMUser?
    {
        return self.createdBy
    }
    
    internal func setCreatedTime(createdTime : String?)
    {
        self.createdTime = createdTime
    }
    
    public func getCreatedTime() -> String?
    {
        return self.createdTime
    }
    
    internal func setModifiedBy(modifiedBy : ZCRMUser?)
    {
        self.modifiedBy = modifiedBy
    }
    
    public func getModifiedBy() -> ZCRMUser?
    {
        return self.modifiedBy
    }
    
    internal func setModifiedTime(modifiedTime : String?)
    {
        self.modifiedTime = modifiedTime
    }
    
    public func getModifiedTime() -> String?
    {
        return modifiedTime
    }
    
    public func getRecordCount( completion : @escaping ( Int64?, Error? ) -> () )
    {
        if self.moduleAPIName == nil
        {
            completion( nil, ZCRMError.ProcessingError( "Tag Module API Name must not be nil." ) )
        }
        else
        {
            TagAPIHandler( tag : self, module : ZCRMModule( moduleAPIName : self.moduleAPIName! ) ).getRecordCount { ( count, error ) in
                completion( count, error )
            }
        }
    }
    
    public func merge( withTag : ZCRMTag, completion : @escaping ( ZCRMTag?, APIResponse?, Error? ) -> () )
    {
        TagAPIHandler(tag: self).merge(withTag: withTag) { (tag, response, error) in
            completion( tag, response, error )
        }
    }
    
    public func update( updateTag : ZCRMTag, completion : @escaping ( ZCRMTag?, APIResponse?, Error? ) -> () )
    {
        if self.moduleAPIName == nil
        {
            completion( nil, nil, ZCRMError.ProcessingError( "Tag Module API Name must not be nil." ) )
        }
        else
        {
            TagAPIHandler( tag : self, module : ZCRMModule( moduleAPIName : self.moduleAPIName! ) ).update( updateTag : updateTag, completion : { ( tag, response, error ) in
                completion( tag, response, error )
            } )
        }
    }
    
    public func delete( completion : @escaping ( APIResponse?, Error? ) -> () )
    {
        if ( self.getId() == nil )
        {
            completion( nil, ZCRMError.ProcessingError( "Tag ID must not be nil for delete operation." ) )
        }
        else
        {
            TagAPIHandler().delete( tagId : self.getId()! , completion: { ( response, error ) in
                completion( response, error )
            } )
        }
    }
}
