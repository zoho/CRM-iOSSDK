//
//  ZCRMAttachment.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 15/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

open class ZCRMAttachment : ZCRMAttachmentDelegate
{
    public var fileName : String
    public var fileType : String = APIConstants.STRING_MOCK
    public var fileSize : Int64 = APIConstants.INT64_MOCK
    public var owner : ZCRMUserDelegate = USER_MOCK
    public var createdBy : ZCRMUserDelegate = USER_MOCK
    public var createdTime : String = APIConstants.STRING_MOCK
    public var modifiedBy : ZCRMUserDelegate = USER_MOCK
    public var modifiedTime : String  = APIConstants.STRING_MOCK
    
    public var isEditable : Bool = APIConstants.BOOL_MOCK
    public var type : String = APIConstants.STRING_MOCK
    public var linkURL : String = APIConstants.STRING_MOCK
	
    /// Initialise the instance of a attachment for the given record with given note attachment Id
    ///
    /// - Parameters:
    ///   - parentRecord: A record for which attachment instance is to be initialized
    ///   - fileName: name to get that attachment detail
    init( parentRecord : ZCRMRecordDelegate, fileName : String )
	{
        self.fileName = fileName
        super.init( attachmentId : APIConstants.INT64_MOCK, parentRecord : parentRecord )
	}
}
