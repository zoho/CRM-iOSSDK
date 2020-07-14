//
//  ZCRMVariableGroup.swift
//  ZCRMiOS
//
//  Created by Umashri R on 26/10/18.
//

open class ZCRMVariableGroup : ZCRMEntity
{
    public internal( set ) var id : Int64 = APIConstants.INT64_MOCK
    public var apiName : String = APIConstants.STRING_MOCK{
        didSet
        {
            self.isApiNameSet = true
        }
    }
    internal var isApiNameSet : Bool = APIConstants.BOOL_MOCK
    public var name : String = APIConstants.STRING_MOCK{
        didSet
        {
            self.isNameSet = true
        }
    }
    internal var isNameSet : Bool = APIConstants.BOOL_MOCK
    public var displayLabel : String = APIConstants.STRING_MOCK
    public var description : String?
    
    init( name : String )
    {
        self.name = name
        self.isNameSet = true
    }
    
    init( apiName : String, id : Int64 )
    {
        self.apiName = apiName
        self.isApiNameSet = true
        self.id = id
    }
}

extension ZCRMVariableGroup : NSCopying, Hashable
{
    public func copy( with zone : NSZone? = nil ) -> Any
    {
        let copy = ZCRMVariableGroup( apiName : self.apiName, id : self.id )
        copy.isApiNameSet = self.isApiNameSet
        copy.isNameSet = self.isNameSet
        copy.name = self.name
        copy.displayLabel = self.displayLabel
        copy.description = self.description
        return copy
    }
    
    public static func == (lhs: ZCRMVariableGroup, rhs: ZCRMVariableGroup) -> Bool {
        let equals : Bool = lhs.id == rhs.id &&
            lhs.apiName == rhs.apiName &&
            lhs.name == rhs.name &&
            lhs.displayLabel == rhs.displayLabel &&
            lhs.description == rhs.description
        return equals
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine( id )
    }
}

let VARIABLE_GROUP_MOCK = ZCRMVariableGroup(apiName: APIConstants.STRING_MOCK, id: APIConstants.INT64_MOCK)
