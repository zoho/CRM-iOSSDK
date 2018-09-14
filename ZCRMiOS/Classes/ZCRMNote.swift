//
//  ZCRMNote.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 15/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

open class ZCRMNote : ZCRMNoteDelegate
{
    var title : String
    var content : String
    var owner : ZCRMUserDelegate = USER_NIL
    var createdBy : ZCRMUserDelegate = USER_NIL
    var createdTime : String = STRING_NIL
    var modifiedBy : ZCRMUserDelegate = USER_NIL
    var modifiedTime : String = STRING_NIL
    var attachments : [ZCRMAttachment] = [ZCRMAttachment]()
	
    /// Initialize the instance of ZCRMNote with the given content
    ///
    /// - Parameter content: note content
    init( title : String, content : String, parentRecord : ZCRMRecordDelegate )
	{
        super.init(noteId: INT64_NIL, parentRecord: parentRecord)
		self.title = title
        self.content = content
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
