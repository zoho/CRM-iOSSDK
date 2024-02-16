//
//  ZCRMBlueprint.swift
//  ZCRMiOS
//
//  Created by test on 15/02/24.
//

import Foundation

public struct ZCRMBlueprint
{
    public internal( set ) var id : Int64
    public internal( set ) var isActive : Bool
    public internal( set ) var name : String
    public internal( set ) var layout : ZCRMLayoutDelegate
    public internal( set ) var module : ZCRMModuleDelegate
    public internal( set ) var pipeline : ZCRMPipelineDelegate?
    
    public func getTransitions( completion : @escaping ( ZCRMResult.DataResponse< [ Transitions ], BulkAPIResponse > ) -> () )
    {
        OrgAPIHandler().getBlueprintTransitions(id: id, completion: completion)
    }
    
    public struct Transitions
    {
        public internal( set ) var id : Int64
        public internal( set ) var isActionsAvailable : Bool
        public internal( set ) var commonSources : [ TransitionState ]
        public internal( set ) var from : TransitionState
        public internal( set ) var to : TransitionState
        public internal( set ) var name :  String
    }
    
    public struct TransitionState
    {
        public internal( set ) var id : Int64
        public internal( set ) var name : String
    }
}
