//
//  ZCRMFilter.swift
//  ZCRMiOS
//
//  Created by Umashri R on 14/06/19.
//

open class ZCRMFilter : ZCRMEntity
{
    public internal( set ) var id : Int64
    public internal( set ) var name : String
    internal var parentCvId : Int64
    internal var moduleAPIName : String
    public internal( set ) var criteria : ZCRMQuery.ZCRMCriteria?
    
    init( id : Int64, name : String, parentCvId : Int64, moduleAPIName : String )
    {
        self.id = id
        self.name = name
        self.parentCvId = parentCvId
        self.moduleAPIName = moduleAPIName
    }
    
    public func getRecords( recordParams : ZCRMQuery.GetRecordParams, completion : @escaping( ResultType.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> () )
    {
        MassEntityAPIHandler( module : ZCRMModuleDelegate( apiName : self.moduleAPIName ) ).getRecords( cvId : self.parentCvId, filterId : self.id, recordParams : recordParams ) { ( result ) in
            completion( result )
        }
    }
}

extension ZCRMFilter : Hashable
{
    public static func == (lhs: ZCRMFilter, rhs: ZCRMFilter) -> Bool {
        let equals : Bool = lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.parentCvId == rhs.parentCvId &&
            lhs.moduleAPIName == rhs.moduleAPIName &&
            lhs.criteria == rhs.criteria
        return equals
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine( id )
    }
}
