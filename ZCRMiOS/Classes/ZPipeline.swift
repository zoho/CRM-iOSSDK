//
//  ZPipeline.swift
//  ZCRMiOS
//
//  Created by test on 15/02/24.
//

import Foundation

protocol ZPipelineDelegate
{
    var id : Int64 { get set }
    var displayName : String { get set }
}

protocol ZPipeline : ZPipelineDelegate
{
    var isDefault : Bool { get set }
    var actualName : String { get set }
}

protocol ZDealStageDelegate
{
    var id : Int64 { get set }
    var displayName : String { get set }
}

protocol ZDealStage : ZDealStageDelegate
{
    var actualName : String { get set }
    var probability : Int? { get set }
    var forecastType : String? { get set }
    var sequenceNumber : Int? { get set }
}
