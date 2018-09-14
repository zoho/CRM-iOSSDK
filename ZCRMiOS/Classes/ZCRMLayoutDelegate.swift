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

var LAYOUT_NIL : ZCRMLayoutDelegate = ZCRMLayoutDelegate(layoutId: INT64_NIL, layoutName: STRING_NIL)
