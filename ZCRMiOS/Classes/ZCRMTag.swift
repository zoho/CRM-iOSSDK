//
//  ZCRMTag.swift
//  ZCRMiOS
//
//  Created by Umashri R on 30/07/18.
//

open class ZCRMTag : ZCRMTagDelegate
{
    var isCreate : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var moduleAPIName : String  = APIConstants.STRING_MOCK
    public internal( set ) var id : Int64 = APIConstants.INT64_MOCK
    public internal( set ) var createdBy : ZCRMUserDelegate = USER_MOCK
    public internal( set ) var createdTime : String = APIConstants.STRING_MOCK
    public internal( set ) var modifiedBy : ZCRMUserDelegate = USER_MOCK
    public internal( set ) var modifiedTime : String = APIConstants.STRING_MOCK

    internal init( name : String, moduleAPIName : String )
    {
        self.moduleAPIName = moduleAPIName
        super.init(name: name)
    }
    
    internal init()
    {
        super.init(name: APIConstants.STRING_MOCK)
    }
    
    public func update( completion : @escaping ( ZCRMResult.DataResponse< ZCRMTag, APIResponse > ) -> () )
    {
        TagAPIHandler( tag : self, module : ZCRMModuleDelegate( apiName : self.moduleAPIName ) ).update( completion : { ( result ) in
            completion( result )
        } )
    }
    
    public func getRecordCount( completion : @escaping ( ZCRMResult.DataResponse< Int64, APIResponse > ) -> () )
    {
        if self.moduleAPIName == APIConstants.STRING_MOCK
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.mandatoryNotFound) : Tag Module API Name must not be nil, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError( code : ZCRMErrorCode.mandatoryNotFound , message: "Tag Module API Name must not be nil.", details : nil ) ) )
        }
        else
        {
            TagAPIHandler( tag: self, module : ZCRMModuleDelegate( apiName : self.moduleAPIName ) ).getRecordCount { ( result ) in
                completion( result )
            }
        }
    }
    
    public func merge( withTag : ZCRMTag, completion : @escaping ( ZCRMResult.DataResponse< ZCRMTag, APIResponse > ) -> () )
    {
        TagAPIHandler( tag : self, module : ZCRMModuleDelegate( apiName : self.moduleAPIName ) ).merge( withTag : withTag ) { ( result ) in
            completion( result )
        }
    }
    
    public func delete( completion : @escaping ( ZCRMResult.Response< APIResponse > ) -> () )
    {
        TagAPIHandler().delete( tagId : self.id, moduleName: moduleAPIName, completion: { ( result ) in
            completion( result )
        } )
    }
    
    override func copy() -> ZCRMTag {
        let tag = ZCRMTag(name: name, moduleAPIName: moduleAPIName)
        tag.colorCode = colorCode
        tag.isCreate = isCreate
        tag.id = id
        tag.createdBy = createdBy
        tag.createdTime = createdTime
        tag.modifiedBy = modifiedBy
        tag.modifiedTime = modifiedTime
        return tag
    }
}

extension ZCRMTag : Hashable
{
    public static func == (lhs: ZCRMTag, rhs: ZCRMTag) -> Bool {
        let equals : Bool = lhs.name == rhs.name && lhs.moduleAPIName == rhs.moduleAPIName &&
            lhs.id == rhs.id && lhs.createdBy == rhs.createdBy &&
            lhs.createdTime == rhs.createdTime &&
            lhs.modifiedTime == rhs.modifiedTime &&
            lhs.modifiedBy == rhs.modifiedBy
        return equals
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine( id )
    }
}
