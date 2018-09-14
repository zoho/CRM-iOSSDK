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
    var isDefault : Bool = BOOL_NIL
    
    init( profileId : Int64, profileName : String, isDefault : Bool )
    {
        self.profileId = profileId
        self.profileName = profileName
        self.isDefault = isDefault
    }
    
    init( profileId : Int64, profileName : String )
    {
        self.profileId = profileId
        self.profileName = profileName
    }
}
var PROFILE_NIL : ZCRMProfileDelegate = ZCRMProfileDelegate(profileId: INT64_NIL, profileName: STRING_NIL)
