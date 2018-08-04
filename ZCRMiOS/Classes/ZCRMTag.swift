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
    
    /// Initialize the instance of ZCRMTag with the given tag id
    ///
    /// - Parameter tagId: id to get that tag's instance
    public init(tagId : Int64)
    {
        self.id = tagId
    }
    
    /// Initialize the instance of ZCRMTag with the given tag name
    ///
    /// - Parameter tagName: name to get that tag's instance
    public init(tagName : String)
    {
        self.name = tagName
    }
    
    public init()
    { }
    
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
    
    public func getRecordCount( module : ZCRMModule, completion : @escaping ( Int64?, Error? ) -> () )
    {
        TagAPIHandler(tag: self, module: module).getRecordCount { (count, error) in
            completion( count, error )
        }
    }
    
    public func mergeTags( conflictTag : ZCRMTag, completion : @escaping ( ZCRMTag?, APIResponse?, Error? ) -> () )
    {
        TagAPIHandler(tag: self).mergeTag(conflictTag: conflictTag) { (tag, response, error) in
            completion( tag, response, error )
        }
    }
    
    public func updateTag( updateTag : ZCRMTag, module : ZCRMModule, completion : @escaping ( ZCRMTag?, APIResponse?, Error? ) -> () )
    {
        TagAPIHandler(tag: self, module: module).updateTag(updateTag : updateTag, completion: { ( tag, response, error ) in
            completion( tag, response, error )
        } )
    }
    
    public func deleteTag( completion : @escaping ( APIResponse?, Error? ) -> () )
    {
        TagAPIHandler(tag: self).deleteTag(completion: { ( response, error ) in
            completion( response, error )
        } )
    }
}
