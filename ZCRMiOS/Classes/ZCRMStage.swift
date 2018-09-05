//
//  ZCRMStage.swift
//  ZCRMiOS
//
//  Created by Umashri R on 24/08/18.
//

import Foundation

public class ZCRMStage : ZCRMEntity
{
    private var displayLabel : String?
    private var probability : Int?
    private var name : String?
    private var forecastCategory : [ String : Any ]?
    private var id : Int64?
    private var forecastType : String?
    
    public init ( stageId : Int64 )
    {
        self.id = stageId
    }
    
    public func getId() -> Int64?
    {
        return self.id
    }
    
    internal func setName( name : String? )
    {
        self.name = name
    }
    
    public func getName() -> String?
    {
        return self.name
    }
    
    internal func setDisplayLabel( displayLabel : String? )
    {
        self.displayLabel = displayLabel
    }
    
    public func getDisplayLabel() -> String?
    {
        return self.displayLabel
    }
    
    internal func setProbability( probability : Int? )
    {
        self.probability = probability
    }
    
    public func getProbability() -> Int?
    {
        return self.probability
    }
    
    internal func setForecastCategory( forecastCategory : [ String : Any ]? )
    {
        self.forecastCategory = forecastCategory
    }
    
    public func getForecastCategory() -> [ String : Any ]?
    {
        return self.forecastCategory
    }
    
    internal func setForecastType( forecastType : String? )
    {
        self.forecastType = forecastType
    }
    
    public func getForecastType() -> String?
    {
        return self.forecastType
    }
}
