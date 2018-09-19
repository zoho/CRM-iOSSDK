//
//  ZCRMLayoutDelegate.swift
//  ZCRMiOS
//
//  Created by Umashri R on 13/09/18.
//

open class ZCRMLayoutDelegate : ZCRMEntity
{
    public var layoutId : Int64
    public var layoutName : String
    
    internal init( layoutId : Int64, layoutName : String )
    {
        self.layoutId = layoutId
        self.layoutName = layoutName
    }
}

let LAYOUT_MOCK : ZCRMLayoutDelegate = ZCRMLayoutDelegate( layoutId : APIConstants.INT64_MOCK, layoutName : APIConstants.STRING_MOCK )
