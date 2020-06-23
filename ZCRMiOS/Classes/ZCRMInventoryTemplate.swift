//
//  ZCRMInventoryTemplate.swift
//  ZCRMiOS
//
//  Created by gowtham-pt2177 on 10/06/20.
//

import Foundation

public class ZCRMInventoryTemplate : ZCRMEntity
{
    public let id : Int64
    public let name : String
    public internal( set ) var createdTime : String?
    public internal( set ) var modifiedTime : String?
    public let folder : Folder
    public internal( set ) var lastUsageTime : String?
    public let module : ZCRMModuleDelegate
    public internal( set ) var modifiedBy : ZCRMUserDelegate?
    public internal( set ) var type : ZCRMTemplateType = .unhandled
    public internal( set ) var isFavorite : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var createdBy : ZCRMUserDelegate?
    public internal( set ) var content : String?
    
    internal init( id : Int64, name : String, folder : Folder, module : ZCRMModuleDelegate )
    {
        self.folder = folder
        self.module = module
        self.id = id
        self.name = name
    }
    
    public struct Folder : Equatable
    {
        public var name : String
        public var id : Int64
    }
    
    public func getContent( completion : @escaping ( Result.Data< String > ) -> () )
    {
        if let content = content
        {
            completion( .success( content ) )
        }
        else
        {
            EmailAPIHandler().getInventoryTemplate( byId: id ) { result in
                switch result
                {
                case .success(let template, _) :
                    if let content = template.content
                    {
                        self.content = content
                        completion( .success( content ) )
                    }
                case .failure(let error) :
                    ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
        }
    }
}

extension ZCRMInventoryTemplate : Hashable
{
    public static func == ( lhs : ZCRMInventoryTemplate, rhs : ZCRMInventoryTemplate ) -> Bool
    {
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
            lhs.content == rhs.content
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine( id )
    }
}
