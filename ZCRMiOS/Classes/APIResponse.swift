//
//  APIResponse.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 3/7/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

import Foundation

public class  APIResponse : CommonAPIResponse
{
    internal var data : ZCRMEntity?
    internal var status : String?
    internal var message : String?
    
    override init() {
        super.init()
    }
    
    override init( response : HTTPURLResponse, responseData : Data?, responseJSONRootKey : String ) throws
    {
        try super.init( response : response, responseData : responseData, responseJSONRootKey : responseJSONRootKey )
    }
    
    internal func setData(data : ZCRMEntity)
    {
        self.data = data
    }
    
    public func getData() -> ZCRMEntity
    {
        return self.data!
    }
    
    internal func setStatus( status : String )
    {
        self.status = status
    }
    
    public func getStatus() -> String
    {
        return self.status!
    }
    
    internal func setMessage( message : String )
    {
        self.message = message
    }
    
    public func getMessage() -> String
    {
        return self.message!
    }
    
    override func handleForFaultyResponses() throws
    {
        if(httpStatusCode == HTTPStatusCode.NO_CONTENT)
        {
            throw ZCRMError.InValidError( code : ErrorCode.INVALID_DATA, message : ErrorMessage.INVALID_ID_MSG )
        }
        else
        {
            throw ZCRMError.ProcessingError( code : responseJSON[ APIConstants.CODE ] as? String ?? ErrorCode.INVALID_DATA, message : responseJSON[APIConstants.MESSAGE] as? String ?? "Response is nil" )
        }
    }
    
    override func processDataResponse() throws
    {
        
        var msgJSON : [ String : Any ] = responseJSON
        
        if( responseJSON.hasValue( forKey : responseJSONRootKey ) )
        {
            let recordsArray : [ [ String : Any? ] ] =
                responseJSON[responseJSONRootKey] as! [ [ String : Any? ] ]
            
            msgJSON = recordsArray[ 0 ] as Any as! [ String : Any ]
        }
        
        if ( msgJSON.hasValue( forKey : APIConstants.MESSAGE ) )
        {
            message = msgJSON[ APIConstants.MESSAGE ] as? String
        }
        
        
        if( msgJSON.hasValue( forKey : APIConstants.STATUS ) )
        {
            status = msgJSON[ APIConstants.STATUS ] as? String
            if( status == APIConstants.CODE_ERROR )
            {
                if( msgJSON.hasValue( forKey : APIConstants.DETAILS ) )
                {
                    throw ZCRMError.ProcessingError( code :( msgJSON[ APIConstants.CODE ] as? String ?? ErrorCode.INVALID_DATA ), message : ( "\( message ?? "Empty Message" ) - \( msgJSON[ APIConstants.DETAILS] ?? [:] )" ) )
                }
                throw ZCRMError.ProcessingError( code : msgJSON[ APIConstants.CODE ] as? String ?? ErrorCode.INVALID_DATA, message: message ?? "Empty Message" )
            }
        } 
        
    } 
    
    
} // end of class

public class FileAPIResponse : APIResponse
{
    private var tempLocalUrl : URL?
    private var fileName: String?
    
    init(response: HTTPURLResponse, tempLocalUrl: URL?) throws
    {
        self.tempLocalUrl = tempLocalUrl!
        try super.init(response: response,responseData: nil,
                       responseJSONRootKey: JSONRootKey.NILL)
    }
    
    public func getFileName() -> String
    {
        return response!.suggestedFilename!
    }
    
    public func getFileData() throws -> Data
    {
        return try Data( contentsOf : self.tempLocalUrl! )
    }
    
    public func getTempLocalUrl() -> URL
    {
        return self.tempLocalUrl!
    }
    
    public func getTempLocalFilePath() -> String
    {
        return self.tempLocalUrl!.path
    }
    
    override func setResponseJSON(responseData: Data?) throws
    {
        if(httpStatusCode == HTTPStatusCode.OK || httpStatusCode == HTTPStatusCode.NO_CONTENT)
        {
            responseJSON = [String:Any]()
            if( httpStatusCode == HTTPStatusCode.OK )
            {
                status = APIConstants.CODE_SUCCESS
            }
        }
        else
        {
            let respStr: String = try String(contentsOf: tempLocalUrl!)
            let stringData : Data = respStr.data(using: .utf8)!
            let jsonStr : Any? = try? JSONSerialization.jsonObject(with: stringData, options: [])
            if let tempJSON = jsonStr as? [String : Any]
            {
                responseJSON = tempJSON
            }
            self.tempLocalUrl = nil
        }
    }
    
    override func processDataResponse() throws
    {
    }
    
}

public class BulkAPIResponse : CommonAPIResponse
{
    private var bulkData : [ZCRMEntity] = [ZCRMEntity]()
    private var bulkEntityResponses : [EntityResponse] = [EntityResponse]()
    
    override init()
    {
        super.init()
    }
    
    override init( response : HTTPURLResponse, responseData : Data?, responseJSONRootKey : String ) throws
    {
        try super.init( response : response, responseData : responseData, responseJSONRootKey : responseJSONRootKey )
    }
    
    public func getEntityResponses() -> [EntityResponse]
    {
        return self.bulkEntityResponses
    }
    
    internal func setData(data: [ZCRMEntity])
    {
        self.bulkData = data
    }
    
    public func getData() -> [ZCRMEntity]
    {
        return self.bulkData
    }
    
    override func processDataResponse() throws
    {
        if(self.responseJSON.hasValue( forKey : responseJSONRootKey ) )
        {
            let recordsArray : [[String:Any?]] = responseJSON.optArray(key: responseJSONRootKey) as! [[String:Any?]]
            for recordJSON in recordsArray
            {
                if(recordJSON.hasValue(forKey: APIConstants.STATUS) && recordJSON.hasValue(forKey: APIConstants.MESSAGE))
                {
                    let individualResponse : EntityResponse = EntityResponse(entityResponseJSON: recordJSON as Any as! [ String : Any ])
                    self.bulkEntityResponses.append(individualResponse)
                }
            }
        }
        else
        {
            throw ZCRMError.ProcessingError( code : ErrorCode.RESPONSE_ROOT_KEY_NIL, message : "Response root key is nil." )
        }
    }
    
    override func handleForFaultyResponses() throws
    {
        if(self.httpStatusCode == HTTPStatusCode.NO_CONTENT)
        {
            self.responseJSON = [String:Any]()
        }
        else
        {
            throw ZCRMError.ProcessingError( code : ( responseJSON[ APIConstants.CODE ] as? String ?? ErrorCode.INVALID_DATA ), message : ( responseJSON[APIConstants.MESSAGE] as? String ?? "Response is nil" ) )
        }
    }
}

public class EntityResponse
{
    private var responseJSON : [String:Any]
    private var status : String
    private var code : String
    private var message : String
    private var data : ZCRMEntity?
    private var upsertedDetails : [ String : String ] = [ String : String ]()
    
    init(entityResponseJSON: [String:Any])
    {
        self.responseJSON = entityResponseJSON
        self.status = entityResponseJSON[APIConstants.STATUS] as! String
        self.code = entityResponseJSON[APIConstants.CODE] as! String
        self.message = entityResponseJSON[APIConstants.MESSAGE] as! String
        if entityResponseJSON.hasValue( forKey : APIConstants.ACTION )
        {
            self.upsertedDetails[ "\( APIConstants.ACTION )" ] = entityResponseJSON[ APIConstants.ACTION ] as? String
            
        }
        if entityResponseJSON.hasValue( forKey : APIConstants.DUPLICATE_FIELD )
        {
            self.upsertedDetails[ "\( APIConstants.DUPLICATE_FIELD )" ] = entityResponseJSON[ APIConstants.DUPLICATE_FIELD ] as? String
        }
    }
    
    internal func setData(data: ZCRMEntity?)
    {
        self.data = data;
    }
    
    public func getData() -> ZCRMEntity?
    {
        return self.data
    }
    
    public func getResponseJSON() -> [String:Any]
    {
        return self.responseJSON
    }
    
    public func getStatus() -> String
    {
        return self.status
    }
    
    public func getCode() -> String
    {
        return self.code
    }
    
    public func getUpsertedDetails() -> [ String : String ]
    {
        return self.upsertedDetails
    }
    
    public func getMessage() -> String
    {
        return self.message
    }
}
