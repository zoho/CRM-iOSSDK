//
//  ZCRMTagDelegate.swift
//  ZCRMiOS
//
//  Created by gowtham-pt2177 on 31/08/21.
//

import Foundation

open class ZCRMTagDelegate : ZCRMEntity
{
    public var name : String  = APIConstants.STRING_MOCK
    /**
     Color code of the tag
     
     Note: ColorCode has been supported from v2.2 version
     */
    public var colorCode : String?
    
    init( name : String ) {
        self.name = name
    }
    
    func copy() -> ZCRMTagDelegate
    {
        let copyObj = ZCRMTagDelegate(name: name)
        copyObj.colorCode = colorCode
        return copyObj
    }
}

extension ZCRMTagDelegate : Equatable
{
    public static func == (lhs: ZCRMTagDelegate, rhs: ZCRMTagDelegate) -> Bool {
        return lhs.name == rhs.name &&
            lhs.colorCode == rhs.colorCode
    }
}
