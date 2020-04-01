//
//  ZCRMPipeline.swift
//  ZCRMiOS
//
//  Created by Umashri R on 24/05/19.
//

open class ZCRMPipeline : ZCRMEntity
{
    public internal( set ) var displayName : String = APIConstants.STRING_MOCK
    public internal( set ) var isDefault : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var id : Int64 = APIConstants.INT64_MOCK
    public internal( set ) var actualName : String = APIConstants.STRING_MOCK
    public internal( set ) var stages : [ ZCRMDealStage ] = [ ZCRMDealStage ]()
    
    init( id : Int64 )
    {
        self.id = id
    }
}

extension ZCRMPipeline : Equatable
{
    public static func == (lhs: ZCRMPipeline, rhs: ZCRMPipeline) -> Bool {
        let equals : Bool = lhs.displayName == rhs.displayName &&
            lhs.isDefault == rhs.isDefault &&
            lhs.id == rhs.id &&
            lhs.actualName == rhs.actualName &&
            lhs.stages == rhs.stages
        return equals
    }
}
