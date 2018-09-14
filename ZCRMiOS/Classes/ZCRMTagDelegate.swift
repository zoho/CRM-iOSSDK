//
//  ZCRMTagDelegate.swift
//  ZCRMiOS
//
//  Created by Umashri R on 14/09/18.
//

open class ZCRMTagDelegate : ZCRMEntity
{
    var tagId : Int64
    var tagName : String = STRING_NIL
    var moduleAPIName : String = STRING_NIL
    
    init( tagId : Int64 )
    {
        self.tagId = tagId
    }
    
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
        if self.moduleAPIName == STRING_NIL
        {
            completion( .failure( ZCRMError.ProcessingError( code : ErrorCode.MANDATORY_NOT_FOUND , message: "Tag Module API Name must not be nil." ) ) )
        }
        else
        {
            TagAPIHandler( tag : self, module : ZCRMModule( moduleAPIName : self.moduleAPIName ) ).getRecordCount { ( result ) in
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
        if self.moduleAPIName == STRING_NIL
        {
            completion( .failure( ZCRMError.ProcessingError( code : ErrorCode.MANDATORY_NOT_FOUND , message: "Tag Module API Name must not be nil." ) ) )
        }
        else
        {
            TagAPIHandler( tag : self, module : ZCRMModule( moduleAPIName : self.moduleAPIName ) ).update( updateTag : updateTag, completion : { ( result ) in
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
