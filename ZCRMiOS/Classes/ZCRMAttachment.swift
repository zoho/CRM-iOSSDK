//
//  ZCRMAttachment.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 15/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

open class ZCRMAttachment : ZCRMAttachmentDelegate
{
    var fileName : String
    var fileType : String = STRING_NIL
    var fileSize : Int64 = INT64_NIL
    var owner : ZCRMUserDelegate = USER_NIL
    var createdBy : ZCRMUserDelegate = USER_NIL
    var createdTime : String = STRING_NIL
    var modifiedBy : ZCRMUserDelegate = USER_NIL
    var modifiedTime : String = STRING_NIL
    
    var isEditable : Bool = BOOL_NIL
    var type : String = STRING_NIL
    var linkURL : String = STRING_NIL
	
    /// Initialise the instance of a attachment for the given record with given note attachment Id
    ///
    /// - Parameters:
    ///   - parentRecord: A record for which attachment instance is to be initialized
    ///   - fileName: name to get that attachment detail
    init( parentRecord : ZCRMRecordDelegate, fileName : String )
	{
        super.init( attachmentId : INT64_NIL, parentRecord : parentRecord )
		self.fileName = fileName
	}
}
