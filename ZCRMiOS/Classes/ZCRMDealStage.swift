//
//  ZCRMDealStage.swift
//  ZCRMiOS
//
//  Created by test on 15/02/24.
//

import Foundation

open class ZCRMDealStageDelegate : ZDealStageDelegate, ZCRMEntity, Hashable
{
    public internal( set ) var id : Int64
    public internal( set ) var displayName : String = APIConstants.STRING_MOCK
    
    init( id : Int64 )
    {
        self.id = id
    }
    
    public static func == ( lhs : ZCRMDealStageDelegate, rhs : ZCRMDealStageDelegate ) -> Bool
    {
        let equals : Bool = lhs.id == rhs.id &&
            lhs.displayName == rhs.displayName
        return equals
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine( id )
    }
}

open class ZCRMDealStage : ZCRMDealStageDelegate, ZDealStage
{
    public internal( set ) var actualName : String = APIConstants.STRING_MOCK
    public internal( set ) var forecastCategory : String = APIConstants.STRING_MOCK
    public internal( set ) var probability : Int?
    public internal( set ) var forecastType : String?
    public internal( set ) var sequenceNumber : Int?

    public static func == ( lhs : ZCRMDealStage, rhs : ZCRMDealStage ) -> Bool
    {
        let equals : Bool = lhs.actualName == rhs.actualName &&
            lhs.forecastCategory == rhs.forecastCategory &&
            lhs.id == rhs.id &&
            lhs.displayName == rhs.displayName &&
            lhs.probability == rhs.probability &&
            lhs.forecastType == rhs.forecastType &&
            lhs.sequenceNumber == rhs.sequenceNumber
        return equals
    }
}
