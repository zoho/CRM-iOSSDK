//
//  ZCRMTagDelegate.swift
//  ZCRMiOS
//
//  Created by Umashri R on 14/09/18.
//

open class ZCRMTagDelegate : ZCRMEntity
{
    public var tagId : Int64
    public var tagName : String  = APIConstants.STRING_MOCK
    var moduleAPIName : String  = APIConstants.STRING_MOCK
    
    init( tagId : Int64, moduleAPIName : String )
    {
        self.tagId = tagId
        self.moduleAPIName = moduleAPIName
    }
    
    init( tagId : Int64, tagName : String, moduleAPIName : String )
    {
        self.tagId = tagId
        self.tagName = tagName
        self.moduleAPIName = moduleAPIName
    }
    
    public func getRecordCount( completion : @escaping ( Result.DataResponse< Int64, APIResponse > ) -> () )
    {
        if self.moduleAPIName == APIConstants.STRING_MOCK
        {
            completion( .failure( ZCRMError.ProcessingError( code : ErrorCode.MANDATORY_NOT_FOUND , message: "Tag Module API Name must not be nil." ) ) )
        }
        else
        {
            TagAPIHandler( tag : self, module : ZCRMModuleDelegate( apiName : self.moduleAPIName ) ).getRecordCount { ( result ) in
                completion( result )
            }
        }
    }
    
    public func merge( withTag : ZCRMTag, completion : @escaping ( Result.DataResponse< ZCRMTag, APIResponse > ) -> () )
    {
        TagAPIHandler(tag: self).merge(withTag: withTag) { ( result ) in
            completion( result )
        }
    }
    
    public func update( updateTag : ZCRMTag, completion : @escaping ( Result.DataResponse< ZCRMTag, APIResponse > ) -> () )
    {
        if self.moduleAPIName == APIConstants.STRING_MOCK
        {
            completion( .failure( ZCRMError.ProcessingError( code : ErrorCode.MANDATORY_NOT_FOUND , message: "Tag Module API Name must not be nil." ) ) )
        }
        else
        {
            TagAPIHandler( tag : self, module : ZCRMModuleDelegate( apiName : self.moduleAPIName ) ).update( updateTag : updateTag, completion : { ( result ) in
                completion( result )
            } )
        }
    }
    
    public func delete( completion : @escaping ( Result.Response< APIResponse > ) -> () )
    {
        TagAPIHandler().delete( tagId : self.tagId , completion: { ( result ) in
            completion( result )
        } )
    }
}
