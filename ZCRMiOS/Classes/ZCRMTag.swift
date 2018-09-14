//
//  ZCRMTag.swift
//  ZCRMiOS
//
//  Created by Umashri R on 30/07/18.
//

open class ZCRMTag : ZCRMTagDelegate
{
    var createdBy : ZCRMUserDelegate = USER_NIL
    var createdTime : String = STRING_NIL
    var modifiedBy : ZCRMUserDelegate = USER_NIL
    var modifiedTime : String = STRING_NIL
    
    init( tagName : String )
    {
        super.init(tagId: INT64_NIL, tagName: tagName, moduleAPIName: STRING_NIL)
    }
    
    init()
    {
        super.init(tagId: INT64_NIL)
    }
}
