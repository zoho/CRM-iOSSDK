//
//  APIRequestExtension.swift
//  ZCRMiOS
//
//  Created by Umashri R on 30/03/20.
//

import Foundation

internal extension URLSession {
   func dataTask(with request : URLRequest, completion : @escaping (Result.DataURLResponse<Data, HTTPURLResponse>) -> Void) -> URLSessionDataTask {
       return dataTask(with: request) { (data, response, error) in

           if let error = error {
               ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
               completion( .failure( typeCastToZCRMError( error ) ) )
               return
           }
           
           guard let data = data else {
               return
           }
           
           guard let urlResponse = response, let httpResponse = urlResponse as? HTTPURLResponse else {
               ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.responseNil) : \(ErrorMessage.responseNilMsg), \( APIConstants.DETAILS ) : -")
               completion( .failure( ZCRMError.sdkError(code: ErrorCode.responseNil, message: ErrorMessage.responseNilMsg, details : nil) ) )
               return
           }
           
           completion( .success(data, httpResponse) )
       }
   }
   
   func uploadTask(with request : URLRequest, fromFile url : URL, completion : @escaping (Result.DataURLResponse<Data, HTTPURLResponse>) -> Void) -> URLSessionUploadTask {
       return uploadTask(with: request, fromFile: url) { (data, response, error) in
           if let error = error {
               ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
               completion( .failure( typeCastToZCRMError( error ) ) )
               return
           }
           
           guard let data = data else {
               return
           }
           
           guard let urlResponse = response, let httpResponse = urlResponse as? HTTPURLResponse else {
               ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.responseNil) : \(ErrorMessage.responseNilMsg), \( APIConstants.DETAILS ) : -")
               completion( .failure( ZCRMError.sdkError( code: ErrorCode.responseNil, message: ErrorMessage.responseNilMsg, details : nil ) ) )
               return
           }
           
           completion( .success(data, httpResponse) )
       }
   }
   
   func downloadTask(with request : URLRequest, completion : @escaping (Result.DataURLResponse<Any, HTTPURLResponse>) -> Void) -> URLSessionDownloadTask {
       return downloadTask(with: request) { (tempLocalURL, response, error) in
           if let error = error {
               ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
               completion( .failure( typeCastToZCRMError( error ) ) )
               return
           }
           
           guard let localURL = tempLocalURL else {
               ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \( ErrorCode.unableToConstructURL ) : \( ErrorMessage.unableToConstructURLMsg ), \( APIConstants.DETAILS ) : -")
               completion( .failure( ZCRMError.sdkError(code: ErrorCode.unableToConstructURL, message: ErrorMessage.unableToConstructURLMsg, details: nil) ) )
               return
           }
           
           guard let urlResponse = response, let httpResponse = urlResponse as? HTTPURLResponse  else {
               ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.responseNil) : \(ErrorMessage.responseNilMsg), \( APIConstants.DETAILS ) : -")
               completion( .failure( ZCRMError.sdkError( code: ErrorCode.responseNil, message: ErrorMessage.responseNilMsg, details : nil ) ) )
               return
           }
           completion( .success(localURL, httpResponse) )
       }
   }
}
internal enum HTTPStatusCode : Int
{
   case ok = 200
   case created = 201
   case accepted = 202
   case noContent = 204
   case multiStatus = 207
   case movedPermanently = 301
   case movedTemporarily = 302
   case notModified = 304
   case badRequest = 400
   case authorizationError = 401
   case forbidden = 403
   case notFound = 404
   case methodNotAllowed = 405
   case requestEntityTooLarge = 413
   case unsupportedMediaType = 415
   case tooManyRequest = 429
   case internalServerError = 500
   case badGateway = 502
   case unhandled
   
   init( statusCodeValue : Int )
   {
       if let code = HTTPStatusCode( rawValue: statusCodeValue )
       {
           self = code
       }
       else
       {
           ZCRMLogger.logInfo(message: "UNHANDLED -> HTTP status code : \( statusCodeValue )")
           self = .unhandled
       }
   }
}

internal let faultyStatusCodes : [HTTPStatusCode] = [HTTPStatusCode.authorizationError, HTTPStatusCode.badRequest, HTTPStatusCode.forbidden, HTTPStatusCode.internalServerError, HTTPStatusCode.methodNotAllowed, HTTPStatusCode.movedTemporarily, HTTPStatusCode.movedPermanently, HTTPStatusCode.requestEntityTooLarge, HTTPStatusCode.tooManyRequest, HTTPStatusCode.unsupportedMediaType, HTTPStatusCode.noContent, HTTPStatusCode.notFound, HTTPStatusCode.badGateway, HTTPStatusCode.unhandled, HTTPStatusCode.notModified]

public enum RequestMethod : String
{
   case get = "GET"
   case post = "POST"
   case patch = "PATCH"
   case put = "PUT"
   case delete = "DELETE"
   case undefined = "UNDEFINED"
}

struct ZCRMURLBuilder
{
    let path : String
    var host : String?
    var queryItems : [ URLQueryItem ]?

    var url : URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host ?? ZCRMSDKClient.shared.apiBaseURL
        components.path = path
        if self.queryItems?.isEmpty == false
        {
           components.queryItems = queryItems
        }
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        return components.url
    }
}

public protocol ZohoAuthProvider
{
    func getAccessToken( completion : @escaping( Result.Data< String > ) -> ()  )
}
