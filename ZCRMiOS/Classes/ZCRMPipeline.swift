//
//  ZCRMPipeline.swift
//  ZCRMiOS
//
//  Created by test on 15/02/24.
//

import Foundation

open class ZCRMPipelineDelegate : ZPipelineDelegate, ZCRMEntity, Hashable
{
    public internal( set ) var id : Int64
    public internal( set ) var displayName : String = APIConstants.STRING_MOCK
    
    init( id : Int64 )
    {
        self.id = id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine( id )
    }
    
    public static func == (lhs: ZCRMPipelineDelegate, rhs: ZCRMPipelineDelegate) -> Bool {
        let equals : Bool = lhs.displayName == rhs.displayName &&
            lhs.id == rhs.id
        return equals
    }
}

open class ZCRMPipeline : ZCRMPipelineDelegate, ZPipeline
{
    public internal( set ) var isDefault : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var actualName : String = APIConstants.STRING_MOCK
    public internal( set ) var stages : [ ZCRMDealStage ] = [ ZCRMDealStage ]()
    
    public static func == (lhs: ZCRMPipeline, rhs: ZCRMPipeline) -> Bool {
        let equals : Bool = lhs.displayName == rhs.displayName &&
            lhs.isDefault == rhs.isDefault &&
            lhs.id == rhs.id &&
            lhs.actualName == rhs.actualName &&
            lhs.stages == rhs.stages
        return equals
    }
}
