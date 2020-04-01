//
//  ZCRMStage.swift
//  ZCRMiOS
//
//  Created by Umashri R on 24/08/18.
//

import Foundation

open class ZCRMDealStage : ZCRMEntity
{
    public internal( set ) var actualName : String = APIConstants.STRING_MOCK
    public internal( set ) var forecastCategory : String = APIConstants.STRING_MOCK
    public internal( set ) var id : Int64
    public internal( set ) var displayName : String = APIConstants.STRING_MOCK
    public internal( set ) var probability : Int?
    public internal( set ) var forecastType : String?
    public internal( set ) var sequenceNumber : Int?
    
    init( id : Int64 )
    {
        self.id = id
    }
}

extension ZCRMDealStage : Equatable
{
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
