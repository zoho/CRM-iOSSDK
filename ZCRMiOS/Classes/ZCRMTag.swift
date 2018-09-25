//
//  ZCRMTag.swift
//  ZCRMiOS
//
//  Created by Umashri R on 30/07/18.
//

open class ZCRMTag : ZCRMTagDelegate
{
    var createdBy : ZCRMUserDelegate = USER_MOCK
    var createdTime : String = APIConstants.STRING_MOCK
    var modifiedBy : ZCRMUserDelegate = USER_MOCK
    var modifiedTime : String = APIConstants.STRING_MOCK
    
    internal init( tagName : String )
    {
        super.init( tagId : APIConstants.INT64_MOCK, tagName : tagName, moduleAPIName : APIConstants.STRING_MOCK )
    }
    
    internal init()
    {
        super.init( tagId : APIConstants.INT64_MOCK, moduleAPIName : APIConstants.STRING_MOCK)
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
}
