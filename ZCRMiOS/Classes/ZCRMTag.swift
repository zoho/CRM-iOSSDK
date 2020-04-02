//
//  ZCRMTag.swift
//  ZCRMiOS
//
//  Created by Umashri R on 30/07/18.
//

open class ZCRMTag : ZCRMEntity
{
    var isCreate : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var id : Int64 = APIConstants.INT64_MOCK
    public var name : String  = APIConstants.STRING_MOCK
    var moduleAPIName : String  = APIConstants.STRING_MOCK
    public internal( set ) var createdBy : ZCRMUserDelegate = USER_MOCK
    public internal( set ) var createdTime : String = APIConstants.STRING_MOCK
    public internal( set ) var modifiedBy : ZCRMUserDelegate = USER_MOCK
    public internal( set ) var modifiedTime : String = APIConstants.STRING_MOCK

    internal init( name : String, moduleAPIName : String )
    {
        self.name = name
        self.moduleAPIName = moduleAPIName
    }
    
    internal init()
    { }
    
    public func update( completion : @escaping ( Result.DataResponse< ZCRMTag, APIResponse > ) -> () )
    {
        TagAPIHandler( tag : self, module : ZCRMModuleDelegate( apiName : self.moduleAPIName ) ).update( completion : { ( result ) in
            completion( result )
        } )
    }
    
    public func getRecordCount( completion : @escaping ( Result.DataResponse< Int64, APIResponse > ) -> () )
    {
        if self.moduleAPIName == APIConstants.STRING_MOCK
        {
            ZCRMLogger.logError(message: "\(ErrorCode.mandatoryNotFound) : Tag Module API Name must not be nil, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code : ErrorCode.mandatoryNotFound , message: "Tag Module API Name must not be nil.", details : nil ) ) )
        }
        else
        {
            TagAPIHandler( tag: self, module : ZCRMModuleDelegate( apiName : self.moduleAPIName ) ).getRecordCount { ( result ) in
                completion( result )
            }
        }
    }
    
    public func merge( withTag : ZCRMTag, completion : @escaping ( Result.DataResponse< ZCRMTag, APIResponse > ) -> () )
    {
        TagAPIHandler( tag : self, module : ZCRMModuleDelegate( apiName : self.moduleAPIName ) ).merge( withTag : withTag ) { ( result ) in
            completion( result )
        }
    }
    
    public func delete( completion : @escaping ( Result.Response< APIResponse > ) -> () )
    {
        TagAPIHandler().delete( tagId : self.id , completion: { ( result ) in
            completion( result )
        } )
    }
}

extension ZCRMTag
{
    public func copy(with zone: NSZone? = nil) -> ZCRMTag {
        let tag = ZCRMTag(name: self.name, moduleAPIName: self.moduleAPIName)
        tag.isCreate = self.isCreate
        tag.id = self.id
        tag.createdBy = self.createdBy
        tag.createdTime = self.createdTime
        tag.modifiedBy = self.modifiedBy
        tag.modifiedTime = self.modifiedTime
        return tag
    }
    
    public static func == (lhs: ZCRMTag, rhs: ZCRMTag) -> Bool {
        let equals : Bool = lhs.name == rhs.name && lhs.moduleAPIName == rhs.moduleAPIName &&
            lhs.id == rhs.id && lhs.createdBy == rhs.createdBy &&
            lhs.createdTime == rhs.createdTime &&
            lhs.modifiedTime == rhs.modifiedTime &&
            lhs.modifiedBy == rhs.modifiedBy
        return equals
    }
}
