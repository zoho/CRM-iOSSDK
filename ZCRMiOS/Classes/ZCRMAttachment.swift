//
//  ZCRMAttachment.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 15/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

open class ZCRMAttachment : ZCRMEntity
{
    var parentRecord : ZCRMRecordDelegate
    public var fileExtension : String?
    public var fileSize : Int64 = APIConstants.INT64_MOCK
    public var owner : ZCRMUserDelegate = USER_MOCK
    public var createdBy : ZCRMUserDelegate = USER_MOCK
    public var createdTime : String = APIConstants.STRING_MOCK
    public var modifiedBy : ZCRMUserDelegate = USER_MOCK
    public var modifiedTime : String  = APIConstants.STRING_MOCK
    public var type : String = APIConstants.STRING_MOCK
    
    public var isEditable : Bool = APIConstants.BOOL_MOCK
    public var linkURL : String = APIConstants.STRING_MOCK
    public var fileName : String = APIConstants.STRING_MOCK
    public var attachmentId : Int64 = APIConstants.INT64_MOCK
	
    /// Initialise the instance of a attachment for the given record with given note attachment Id
    ///
    /// - Parameters:
    ///   - parentRecord: A record for which attachment instance is to be initialized
    ///   - fileName: name to get that attachment detail
    init( parentRecord : ZCRMRecordDelegate )
	{
        self.parentRecord = parentRecord
	}
    
    /// To download Attachment, it returns file as data, then it can be converted to a file.
    ///
    /// - Returns: FileAPIResponse containing the data of the file downloaded.
    /// - Throws: ZCRMSDkError if failed to download the attachment
    public func downloadFile( completion : @escaping( Result.Response< FileAPIResponse > ) -> () )
    {
        do
        {
            try idMockValueCheck( id : self.attachmentId )
            ZCRMModuleRelation(relatedListAPIName: "Attachments", parentModuleAPIName: self.parentRecord.moduleAPIName).downloadAttachment(ofParentRecord: self.parentRecord, attachmentId: self.attachmentId) { ( result ) in
                completion( result )
            }
        }
        catch
        {
            completion( .failure( typeCastToZCRMError( error ) ) )
        }
    }
}
