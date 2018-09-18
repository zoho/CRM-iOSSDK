//
//  ZCRMLayoutDelegate.swift
//  ZCRMiOS
//
//  Created by Umashri R on 13/09/18.
//

open class ZCRMLayoutDelegate : ZCRMEntity
{
    var layoutId : Int64
    var layoutName : String
    
    public init( layoutId : Int64, layoutName : String )
    {
        self.layoutId = layoutId
        self.layoutName = layoutName
    }
}

var LAYOUT_NIL : ZCRMLayoutDelegate = ZCRMLayoutDelegate(layoutId: APIConstants.INT64_MOCK, layoutName: APIConstants.STRING_MOCK)
