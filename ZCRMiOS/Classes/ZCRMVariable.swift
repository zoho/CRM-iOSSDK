//
//  ZCRMVariable.swift
//  ZCRMiOS
//
//  Created by Umashri R on 26/10/18.
//

open class ZCRMVariable : ZCRMEntity
{
    public var name : String = APIConstants.STRING_MOCK
    public var apiName : String = APIConstants.STRING_MOCK
    public internal( set ) var variableGroup : ZCRMVariableGroup = VARIABLE_GROUP_MOCK
    public internal( set ) var type : String = APIConstants.STRING_MOCK
    public internal( set ) var id : Int64 = APIConstants.INT64_MOCK
    public var value : String?
    public var description : String?
    var isCreate : Bool = APIConstants.BOOL_MOCK
    
    init( name : String, apiName : String, type : String, variableGroup : ZCRMVariableGroup )
    {
        self.name = name
        self.apiName = apiName
        self.type = type
        self.variableGroup = variableGroup
        self.isCreate = true
    }
    
    init( id : Int64 )
    {
        self.id = id
    }
    
    public func create( completion : @escaping( ResultType.DataResponse< ZCRMVariable, APIResponse > ) -> () )
    {
        OrgAPIHandler(variable: self).createVariable { ( result ) in
            self.isCreate = false
            completion( result )
        }
    }
    
    public func update( completion : @escaping( ResultType.DataResponse< ZCRMVariable, APIResponse > ) -> () )
    {
        OrgAPIHandler(variable: self).updateVariable { ( result ) in
            completion( result )
        }
    }
    
    public func delete( completion : @escaping( ResultType.Response< APIResponse > ) -> () )
    {
        OrgAPIHandler().deleteVariable(id: self.id) { ( result ) in
            completion( result )
        }
    }
}

extension ZCRMVariable : NSCopying, Hashable
{
    public func copy( with zone : NSZone? = nil ) -> Any
    {
        let copy = ZCRMVariable( id : self.id )
        copy.name = self.name
        copy.apiName = self.apiName
        copy.variableGroup = self.variableGroup
        copy.type = self.type
        copy.id = self.id
        copy.value = self.value
        copy.description = self.description
        copy.isCreate = self.isCreate
        return copy
    }
    
    public static func == (lhs: ZCRMVariable, rhs: ZCRMVariable) -> Bool {
        let equals : Bool = lhs.name == rhs.name &&
            lhs.apiName == rhs.apiName &&
            lhs.variableGroup == rhs.variableGroup &&
            lhs.type == rhs.type &&
            lhs.id == rhs.id &&
            lhs.value == rhs.value &&
            lhs.description == rhs.description
        return equals
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine( id )
    }
}
