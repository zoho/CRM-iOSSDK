//
//  ZCRMProfile.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 11/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

open class ZCRMProfile : ZCRMProfileDelegate
{
    public internal( set ) var category : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var description : String?
    public internal( set ) var modifiedBy : ZCRMUserDelegate?
    public internal( set ) var createdBy : ZCRMUserDelegate?
    public internal( set ) var modifiedTime : String?
    public internal( set ) var createdTime : String?
	
	internal init( name : String )
	{
        super.init( id : APIConstants.INT64_MOCK, name : name )
	}
}

extension ZCRMProfile
{
    public static func == (lhs: ZCRMProfile, rhs: ZCRMProfile) -> Bool {
        let equals : Bool = lhs.category == rhs.category &&
            lhs.description == rhs.description &&
            lhs.modifiedBy == rhs.modifiedBy &&
            lhs.createdBy == rhs.createdBy &&
            lhs.modifiedTime == rhs.modifiedTime &&
            lhs.createdTime == rhs.createdTime
        return equals
    }
}
