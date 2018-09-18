//
//  ZCRMNote.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 15/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

open class ZCRMNote : ZCRMNoteDelegate
{
    var title : String?
    var content : String
    var owner : ZCRMUserDelegate = USER_MOCK
    var createdBy : ZCRMUserDelegate = USER_MOCK
    var createdTime : String = APIConstants.STRING_MOCK
    var modifiedBy : ZCRMUserDelegate = USER_MOCK
    var modifiedTime : String = APIConstants.STRING_MOCK
    var attachments : [ZCRMAttachment] = [ZCRMAttachment]()
	
    /// Initialize the instance of ZCRMNote with the given content
    ///
    /// - Parameter content: note content
    init( content : String, parentRecord : ZCRMRecordDelegate )
	{
        self.content = content
        super.init( noteId : APIConstants.INT64_MOCK, parentRecord : parentRecord )
	}
    
    /// To add attachment to the note(Only for internal use).
    ///
    /// - Parameter attachment: add attachment to the note
    func addAttachment(attachment : ZCRMAttachment)
    {
        if( self.attachments.count > 0 )
        {
            self.attachments.append(attachment)
        }
        else
        {
            self.attachments = [ attachment ]
        }
    }
}
