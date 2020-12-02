//
//  ZCRMCodingKeys.swift
//  ZCRMiOS
//
//  Created by Rajarajan on 02/12/20.
//

import Foundation

enum ModuleCodingKeys: String, CodingKey
{
    case id
    case apiName = "api_name"
}

func getModuleDelegate<T>(from container: KeyedDecodingContainer<T>, forKey key: KeyedDecodingContainer<T>.Key) -> ZCRMModuleDelegate {
    
    let moduleContainer = try! container.nestedContainer(keyedBy: ModuleCodingKeys.self, forKey: key)
    let moduleId = try! moduleContainer.decode(String.self, forKey: .id)
    let moduleApiName = try! moduleContainer.decode(String.self, forKey: .apiName)
    let module = ZCRMModuleDelegate(apiName: moduleApiName)
    module.id = moduleId
    return module
}

enum UserCodingKeys: String, CodingKey
{
    case id
    case name
}

func getUserDelegate<T>(from container: KeyedDecodingContainer<T>, forKey key: KeyedDecodingContainer<T>.Key) -> ZCRMUserDelegate {
    
    let userContainer = try! container.nestedContainer(keyedBy: UserCodingKeys.self, forKey: key)
    let userId = try! userContainer.decode(String.self, forKey: .id)
    let userName = try! userContainer.decode(String.self, forKey: .name)
    let user = ZCRMUserDelegate(id: userId, name: userName)
    return user
}
