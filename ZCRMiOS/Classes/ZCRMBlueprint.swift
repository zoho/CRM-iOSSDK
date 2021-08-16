//
//  ZCRMBlueprint.swift
//  ZCRMiOS
//
//  Created by gowtham-pt2177 on 23/07/21.
//

import Foundation

public struct ZCRMBlueprint
{
    public let currentState : String
    public let isContinuous : Bool
    public internal( set ) var transitionDetails : [ Transition ] = []
    public internal( set ) var escalation : EscalationDetails?
    
    public struct EscalationDetails
    {
        public let days : Int
        public let status : String
    }
    
    public class TransitionDelegate
    {
        public let id : Int64
        public let name : String
        public internal( set ) var type : TransitionType = .manual
        public internal( set ) var isCriteriaMatched : Bool? = nil
        
        init( id : Int64, name : String, type : TransitionType )
        {
            self.id = id
            self.name = name
            self.type = type
        }
    }
    
    public class Transition : TransitionDelegate
    {
        public internal( set ) var nextFieldValue : String
        public var data : [ String : Any ]
        public let partialSavePercentage : Double
        public let fields : [ ZCRMFieldDelegate ]
        public internal( set ) var criteriaMessage : String? = nil
        public internal( set ) var autoTransitionTime : String? = nil
        /// Next possible transitions available from this transition. Available only for continuous transitions
        public internal( set ) var nextTransition : [ TransitionDelegate ] = []
        
        init( id : Int64, name : String, nextFieldValue : String, type : TransitionType, data : [ String : Any ], partialSavePercentage : Double, fields : [ ZCRMFieldDelegate ] )
        {
            self.nextFieldValue = nextFieldValue
            self.data = data
            self.partialSavePercentage = partialSavePercentage
            self.fields = fields
            super.init(id: id, name: name, type: type)
        }
    }
    
    public enum TransitionType : String
    {
        case manual
        case automatic
    }
}
