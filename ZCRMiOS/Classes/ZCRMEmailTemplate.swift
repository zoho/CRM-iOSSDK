//
//  ZCRMEmailTemplate.swift
//  ZCRMiOS
//
//  Created by test on 15/02/24.
//

import Foundation

public class ZCRMEmailTemplate : ZCRMEntity
{
    public let id : Int64
    public let name : String
    public internal( set ) var createdTime : String?
    public internal( set ) var modifiedTime : String?
    public let folder : Folder
    public internal( set ) var attachments : [ Attachment ]?
    public internal( set ) var lastUsageTime : String?
    public let module : ZCRMModuleDelegate
    public internal( set ) var modifiedBy : ZCRMUserDelegate?
    public internal( set ) var type : ZCRMTemplateType?
    public internal( set ) var isFavorite : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var createdBy : ZCRMUserDelegate?
    public internal( set ) var content : String?
    public internal( set ) var subject : String = APIConstants.STRING_MOCK
    public internal( set ) var isAssociated : Bool?
    public internal( set ) var isConsentLinked : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var editorMode : ZCRMTemplateEditorMode = .unhandled
    public internal( set ) var lastVersionStatistics: LastVersionStatistics?
    
    public struct Attachment : Equatable
    {
        public var size : Int64
        public var file_name : String
        public var fileId : String
        public var id : Int64
    }
    
    public struct Folder : Equatable
    {
        public var name : String
        public var id : Int64
    }
    
    public struct LastVersionStatistics : Equatable
    {
        public var tracked: Int
        public var delivered: Int
        public var opened: Int
        public var bounced: Int
        public var sent: Int
        public var clicked: Int
    }
    
    internal init( id : Int64, name : String, folder : Folder, module : ZCRMModuleDelegate )
    {
        self.id = id
        self.name = name
        self.folder = folder
        self.module = module
    }
    
    public func getAttachments( completion : @escaping ( ZCRMResult.Data< [Attachment]? > ) -> () )
    {
        if let attachments = attachments
        {
            completion( .success( attachments ) )
        }
        else
        {
            EmailAPIHandler().getEmailTemplate( byId: id ) { result in
                switch result
                {
                case .success(let template, _) :
                    self.content = template.content
                    self.attachments = template.attachments
                    completion( .success( self.attachments ) )
                case .failure(let error) :
                    ZCRMLogger.logError( message : "\( error )" )
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
        }
    }
    
    public func getContent( completion : @escaping ( ZCRMResult.Data< String > ) -> () )
    {
        if let content = content
        {
            completion( .success( content ) )
        }
        else
        {
            EmailAPIHandler().getEmailTemplate( byId: id ) { result in
                switch result
                {
                case .success(let template, _) :
                    self.content = template.content
                    self.attachments = template.attachments
                    if let content = template.content
                    {
                        completion( .success( content ) )
                    }
                case .failure(let error) :
                    ZCRMLogger.logError( message : "\( error )" )
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
        }
    }
}

extension ZCRMEmailTemplate : Hashable
{
    public static func == (lhs: ZCRMEmailTemplate, rhs: ZCRMEmailTemplate) -> Bool {
        return lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.createdTime == rhs.createdTime &&
            lhs.modifiedTime == rhs.modifiedTime &&
            lhs.folder == rhs.folder &&
            lhs.lastUsageTime == rhs.lastUsageTime &&
            lhs.module == rhs.module &&
            lhs.modifiedBy == rhs.modifiedBy &&
            lhs.type == rhs.type &&
            lhs.isFavorite == rhs.isFavorite &&
            lhs.createdBy == rhs.createdBy &&
            lhs.content == rhs.content &&
            lhs.isAssociated == rhs.isAssociated &&
            lhs.attachments == rhs.attachments &&
            lhs.isConsentLinked == rhs.isConsentLinked &&
            lhs.subject == rhs.subject &&
            lhs.editorMode == rhs.editorMode &&
            lhs.lastVersionStatistics == rhs.lastVersionStatistics
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine( id )
    }
}
