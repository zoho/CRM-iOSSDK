//
//  ZCRMProfileDelegate.swift
//  ZCRMiOS
//
//  Created by Umashri R on 13/09/18.
//

open class ZCRMProfileDelegate : ZCRMEntity
{
    var profileId : Int64
    var profileName : String
    public var isDefault : Bool = APIConstants.BOOL_MOCK
    
    internal init( profileId : Int64, profileName : String, isDefault : Bool )
    {
        self.profileId = profileId
        self.profileName = profileName
        self.isDefault = isDefault
    }
    
    internal init( profileId : Int64, profileName : String )
    {
        self.profileId = profileId
        self.profileName = profileName
    }
}

let PROFILE_MOCK : ZCRMProfileDelegate = ZCRMProfileDelegate( profileId : APIConstants.INT64_MOCK, profileName : APIConstants.STRING_MOCK )
