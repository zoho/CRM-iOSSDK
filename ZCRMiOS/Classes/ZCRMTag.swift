//
//  ZCRMTag.swift
//  ZCRMiOS
//
//  Created by Umashri R on 30/07/18.
//

open class ZCRMTag : ZCRMTagDelegate
{
    var createdBy : ZCRMUserDelegate = USER_MOCK
    var createdTime : String = APIConstants.STRING_MOCK
    var modifiedBy : ZCRMUserDelegate = USER_MOCK
    var modifiedTime : String = APIConstants.STRING_MOCK
    
    init( tagName : String )
    {
        super.init( tagId : APIConstants.INT64_MOCK, tagName : tagName, moduleAPIName : APIConstants.STRING_MOCK )
    }
    
    init()
    {
        super.init( tagId : APIConstants.INT64_MOCK)
    }
}
