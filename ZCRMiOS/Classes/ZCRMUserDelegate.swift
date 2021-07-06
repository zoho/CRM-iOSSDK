//
//  ZCRMUserDelegate.swift
//  ZCRMiOS
//
//  Created by Boopathy P on 16/09/18.
//

open class ZCRMUserDelegate : ZCRMEntity
{
    public internal( set ) var id : Int64
    public var name : String
    internal var data : [ String : Any? ] = [ String : Any? ](){
        didSet
        {
            for ( key, value ) in data
            {
                upsertJSON.updateValue(value, forKey: key)
            }
        }
    }
    internal var upsertJSON : [ String : Any? ] = [ String : Any? ]()
    
    internal init( id : Int64, name : String )
    {
        self.id = id
        self.name = name
    }
    
    public func delete( completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        UserAPIHandler().deleteUser( userId : self.id ) { ( result ) in
            completion( result )
        }
    }
}

extension ZCRMUserDelegate : Hashable
{
    public static func == (lhs: ZCRMUserDelegate, rhs: ZCRMUserDelegate) -> Bool {
        let equals : Bool = lhs.id == rhs.id &&
            lhs.name == rhs.name
        return equals
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine( id )
    }
}

let USER_MOCK : ZCRMUserDelegate = ZCRMUserDelegate( id : APIConstants.INT64_MOCK, name : APIConstants.STRING_MOCK )
