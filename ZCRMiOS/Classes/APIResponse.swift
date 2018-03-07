//
//  APIResponse.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 3/7/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

import Foundation

public class APIResponse : CommonAPIResponse
{
    internal var data : ZCRMEntity?
    internal var status : String?
    internal var message : String?
    
    override init() {
        super.init()
    }
    
    override init(response: HTTPURLResponse, responseData: Data?) throws
    {
        try super.init(response: response, responseData: responseData)
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
            throw ZCRMSDKError.InValidError(INVALID_ID_MSG)
        }
        else
        {
            let msg : String = "\(responseJSON[CODE]!) - \(responseJSON[MESSAGE]!)"
            throw ZCRMSDKError.ProcessingError(msg)
        }
    }
    
    override func processDataResponse() throws
    {
        var msgJSON : [ String : Any ] = responseJSON
        if( responseJSON.hasValue( forKey : DATA ) )
        {
            let recordsArray : [ [ String : Any? ] ] = responseJSON[ DATA ] as! [ [ String : Any? ] ]
            msgJSON = recordsArray[ 0 ] as Any as! [ String : Any ]
        }
        if ( msgJSON.hasValue( forKey : MESSAGE ) )
        {
            message = msgJSON[ MESSAGE ] as? String
        }
        if( msgJSON.hasValue( forKey : STATUS ) )
        {
            status = msgJSON[ STATUS ] as? String
            if( status == CODE_ERROR )
            {
                var msg : String = String()
                if( msgJSON.hasValue( forKey : DETAILS ) )
                {
                    msg = "\( msgJSON[ CODE ] as! String ) - \( message! ) - \( msgJSON[ DETAILS] as! [ String : Any ] )"
                    throw ZCRMSDKError.ProcessingError( msg )
                }
                msg = "\( msgJSON[ CODE ] as! String ) - \( message! )"
                throw ZCRMSDKError.ProcessingError( msg )
            }
        }
    }
}

public class FileAPIResponse : APIResponse
{
    private var tempLocalUrl : URL?
    private var fileName: String?
    
    init(response: HTTPURLResponse, tempLocalUrl: URL?) throws
    {
        self.tempLocalUrl = tempLocalUrl!
        try super.init(response: response, responseData: nil)
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
                status = CODE_SUCCESS
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
    
}

public class BulkAPIResponse : CommonAPIResponse
{
    private var bulkData : [ZCRMEntity] = [ZCRMEntity]()
    private var info : ResponseInfo?
    private var bulkEntityResponses : [EntityResponse] = [EntityResponse]()
    
    override init()
    {
        super.init()
    }
    
    override init(response: HTTPURLResponse, responseData: Data?) throws
    {
        try super.init(response: response, responseData: responseData)
        self.setInfo()
    }
    
    private func setInfo()
    {
        if(self.responseJSON.hasValue(forKey: INFO))
        {
            self.info = ResponseInfo(infoObj: self.responseJSON.optDictionary(key: INFO)!)
        }
    }
    
    public func getInfo() -> ResponseInfo
    {
        return self.info!
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
        if(self.responseJSON.hasValue(forKey: DATA))
        {
            let recordsArray : [[String:Any?]] = responseJSON.optArray(key: "data") as! [[String:Any?]]
            for recordJSON in recordsArray
            {
                if(recordJSON.hasValue(forKey: STATUS))
                {
                    let individualResponse : EntityResponse = EntityResponse(entityResponseJSON: recordJSON as Any as! [ String : Any ])
                    self.bulkEntityResponses.append(individualResponse)
                }
            }
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
            let message : String = "\(responseJSON[CODE]!) - \(responseJSON[MESSAGE]!)"
            throw ZCRMSDKError.ProcessingError(message)
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
        self.status = entityResponseJSON[STATUS] as! String
        self.code = entityResponseJSON[CODE] as! String
        self.message = entityResponseJSON[MESSAGE] as! String
        if entityResponseJSON.hasValue( forKey : ACTION )
        {
            self.upsertedDetails[ "\( ACTION )" ] = entityResponseJSON[ ACTION ] as? String
            
        }
        if entityResponseJSON.hasValue( forKey : DUPLICATE_FIELD )
        {
            self.upsertedDetails[ "\( DUPLICATE_FIELD )" ] = entityResponseJSON[ DUPLICATE_FIELD ] as? String
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

public class ResponseInfo
{
    private var moreRecords : Bool;
    private var recordCount : Int;
    private var pageNo : Int;
    private var perPage : Int;
    
    init(infoObj : [String:Any])
    {
        self.moreRecords = infoObj.optBoolean(key: MORE_RECORDS)!
        self.recordCount = infoObj.optInt(key: COUNT)!
        self.pageNo = infoObj.optInt(key: PAGE)!
        self.perPage = infoObj.optInt(key: PER_PAGE)!
    }
    
    public func hasMoreRecords() -> Bool
    {
        return self.moreRecords
    }
    
    public func getRecordCount() -> Int
    {
        return self.recordCount
    }
    
    public func getPageNo() -> Int
    {
        return self.pageNo
    }
    
    public func getPerPageCount() -> Int
    {
        return self.perPage
    }
}

