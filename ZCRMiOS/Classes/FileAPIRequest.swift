//
//  FileAPIRequest.swift
//  ZCRMiOS
//
//  Created by Umashri R on 04/12/18.
//

import Foundation
import MobileCoreServices

internal class FileAPIRequest : APIRequest, URLSessionDataDelegate, URLSessionDownloadDelegate
{
    private var fileDownloadDelegate : FileDownloadDelegate?
    private var fileUploadDelegate : FileUploadDelegate?

    init( handler : APIHandler, fileDownloadDelegate : FileDownloadDelegate )
    {
        self.fileDownloadDelegate = fileDownloadDelegate
        super.init( handler : handler, cacheFlavour : .NO_CACHE )
    }
    
    init( handler : APIHandler, fileUploadDelegate : FileUploadDelegate )
    {
        self.fileUploadDelegate = fileUploadDelegate
        super.init( handler : handler, cacheFlavour : .NO_CACHE )
    }
    
    init( handler : APIHandler )
    {
        super.init( handler : handler, cacheFlavour : .NO_CACHE )
    }
    
    internal func uploadLink( completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        let boundary = APIConstants.BOUNDARY
        self.createMultipartRequest( bodyData : Data(), boundary : boundary) { ( data, error ) in
            if let err = error
            {
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( err )" )
                completion( .failure( typeCastToZCRMError( err ) ) )
                return
            }
            self.makeRequest { ( urlResponse, responseData, error ) in
                if let err = error
                {
                    ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( err )" )
                    completion( .failure( typeCastToZCRMError( err ) ) )
                    return
                }
                else if let urlResp = urlResponse
                {
                    do
                    {
                        if let respData = responseData
                        {
                            let response = try APIResponse( response : urlResp, responseData : respData, responseJSONRootKey : self.jsonRootKey )
                            completion( .success( response ) )
                        }
                        else
                        {
                            let response = try APIResponse( response : urlResp, responseJSONRootKey : self.jsonRootKey )
                            completion( .success( response ) )
                        }
                    }
                    catch
                    {
                        ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                        completion( .failure( typeCastToZCRMError( error ) ) )
                    }
                }
                else
                {
                    ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.RESPONSE_NIL) : \(ErrorMessage.RESPONSE_NIL_MSG)")
                    completion( .failure( ZCRMError.SDKError( code: ErrorCode.RESPONSE_NIL, message: ErrorMessage.RESPONSE_NIL_MSG, details : nil ) ) )
                }
            }
        }
    }
    
    /// - Parameter content: ZCRMNote as JSON to be added
    internal func uploadFile( filePath : String, entity : [ String : Any? ]?, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        let fileURL = URL( fileURLWithPath : filePath )
        let boundary = APIConstants.BOUNDARY
        do
        {
            let httpBodyData = try getFilePart( fileURL : fileURL, entity : entity, data : nil, fileName : nil, boundary : boundary )
            createMultipartRequest( bodyData : httpBodyData, boundary : boundary ) { ( data, error ) in
                if let err = error
                {
                    ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( err )" )
                    completion( .failure( typeCastToZCRMError( err ) ) )
                    return
                }
                if let data = data
                {
                    guard let request = self.request else
                    {
                        ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.INTERNAL_ERROR) : Unable to construct URLRequest")
                        completion( .failure( ZCRMError.SDKError(code: ErrorCode.INTERNAL_ERROR, message: "Unable to construct URLRequest", details : nil ) ) )
                        return
                    }
                    let session : URLSession = URLSession( configuration : .default )
                    session.uploadTask(with: request, from: data, completionHandler: { ( responseData, urlResponse, error) in
                        if let err = error
                        {
                            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( err )" )
                            completion( .failure( typeCastToZCRMError( err ) ) )
                            return
                        }
                        else if let urlResp = urlResponse as? HTTPURLResponse, let respData = responseData
                        {
                            do
                            {
                                let response = try APIResponse( response : urlResp, responseData : respData, responseJSONRootKey : self.jsonRootKey )
                                completion( .success( response ) )
                            }
                            catch
                            {
                                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                                completion( .failure( typeCastToZCRMError( error ) ) )
                            }
                        }
                        else
                        {
                            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.RESPONSE_NIL) : \(ErrorMessage.RESPONSE_NIL_MSG)")
                            completion( .failure( ZCRMError.SDKError( code: ErrorCode.RESPONSE_NIL, message: ErrorMessage.RESPONSE_NIL_MSG, details : nil ) ) )
                        }
                    }).resume()
                }
            }
        }
        catch
        {
            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
            completion( .failure( typeCastToZCRMError( error ) ) )
        }
    }
    
    /// - Parameter content: ZCRMNote as JSON to be added
    internal func uploadFile( fileName : String, entity : [ String : Any? ]?, fileData : Data, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        do
        {
            let boundary = APIConstants.BOUNDARY
            let httpBodyData = try getFilePart( fileURL : nil, entity: entity, data : fileData, fileName : fileName, boundary : boundary )
            createMultipartRequest(bodyData: httpBodyData, boundary: boundary) { ( data, error ) in
                if let err = error
                {
                    ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( err )" )
                    completion( .failure( typeCastToZCRMError( err ) ) )
                    return
                }
                if let data = data
                {
                    guard let request = self.request else
                    {
                        ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.INTERNAL_ERROR) : Unable to construct URLRequest")
                        completion( .failure( ZCRMError.SDKError(code: ErrorCode.INTERNAL_ERROR, message: "Unable to construct URLRequest", details : nil ) ) )
                        return
                    }
                    let session : URLSession = URLSession( configuration : .default )
                    session.uploadTask(with: request, from: data, completionHandler: { ( responseData, urlResponse, error) in
                        if let err = error
                        {
                            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( err )" )
                            completion( .failure( typeCastToZCRMError( err ) ) )
                            return
                        }
                        else if let urlResp = urlResponse as? HTTPURLResponse, let respData = responseData
                        {
                            do
                            {
                                let response = try APIResponse( response : urlResp, responseData : respData, responseJSONRootKey : self.jsonRootKey )
                                completion( .success( response ) )
                            }
                            catch
                            {
                                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                                completion( .failure( typeCastToZCRMError( error ) ) )
                            }
                        }
                        else
                        {
                            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.RESPONSE_NIL) : \(ErrorMessage.RESPONSE_NIL_MSG)")
                            completion( .failure( ZCRMError.SDKError( code: ErrorCode.RESPONSE_NIL, message: ErrorMessage.RESPONSE_NIL_MSG, details : nil ) ) )
                        }
                    }).resume()
                }
            }
        }
        catch
        {
            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
            completion( .failure( typeCastToZCRMError( error ) ) )
        }
    }
    
    internal func uploadFile( filePath : String, entity : [ String : Any? ]? )
    {
        do
        {
            let sema = DispatchSemaphore( value : 0 )
            let urlSessionConfig : URLSessionConfiguration = URLSessionConfiguration.default
            let urlSession : URLSession = URLSession( configuration : urlSessionConfig, delegate : self as URLSessionDelegate, delegateQueue : nil )
            
            let fileURL = URL( fileURLWithPath : filePath )
            let boundary = APIConstants.BOUNDARY
            let httpBodyData = try getFilePart( fileURL : fileURL, entity : entity, data : nil, fileName : nil, boundary : boundary )
            
            createMultipartRequest( bodyData : httpBodyData, boundary : boundary ) { ( data, error ) in
                if let err = error
                {
                    ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( err )" )
                    self.fileUploadDelegate?.didFail( typeCastToZCRMError( err ) )
                    return
                }
                if let data = data
                {
                    guard let request = self.request else
                    {
                        ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( ErrorCode.INTERNAL_ERROR ) : Unable to construct URLRequest" )
                        self.fileUploadDelegate?.didFail( ZCRMError.SDKError( code : ErrorCode.INTERNAL_ERROR, message : "Unable to construct URLRequest", details : nil ) )
                        return
                    }
                    let task = urlSession.uploadTask( with : request, from : data )
                    sema.signal()
                    task.resume()
                    sema.wait()
                }
            }
        }
        catch
        {
            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
            self.fileUploadDelegate?.didFail( typeCastToZCRMError( error ) )
        }
    }
    
    internal func uploadFile( fileName : String, entity : [ String : Any? ]?, fileData : Data )
    {
        do
        {
            let sema = DispatchSemaphore( value : 0 )
            let urlSessionConfig : URLSessionConfiguration = URLSessionConfiguration.default
            let urlSession : URLSession = URLSession( configuration : urlSessionConfig, delegate : self as URLSessionDelegate, delegateQueue : nil )
            
            let boundary = APIConstants.BOUNDARY
            let httpBodyData = try getFilePart( fileURL : nil, entity: entity, data : fileData, fileName : fileName, boundary : boundary )
            
            createMultipartRequest( bodyData : httpBodyData, boundary : boundary ) { ( data, error ) in
                if let err = error
                {
                    ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( err )" )
                    self.fileUploadDelegate?.didFail( typeCastToZCRMError( err ) )
                    return
                }
                if let data = data
                {
                    guard let request = self.request else
                    {
                        ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( ErrorCode.INTERNAL_ERROR ) : Unable to construct URLRequest" )
                        self.fileUploadDelegate?.didFail( ZCRMError.SDKError( code : ErrorCode.INTERNAL_ERROR, message : "Unable to construct URLRequest", details : nil ) )
                        return
                    }
                    let task = urlSession.uploadTask( with : request, from : data )
                    sema.signal()
                    task.resume()
                    sema.wait()
                }
            }
        }
        catch
        {
            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
            self.fileUploadDelegate?.didFail( typeCastToZCRMError( error ) )
        }
    }
    
    func urlSession( _ session : URLSession, task : URLSessionTask, didCompleteWithError error : Error? )
    {
        if let err = error
        {
            fileUploadDelegate?.didFail( typeCastToZCRMError( err ) )
        }
    }
    
    func urlSession( _ session : URLSession, dataTask : URLSessionDataTask, didReceive response : URLResponse, completionHandler : @escaping ( URLSession.ResponseDisposition ) -> Void )
    {
        completionHandler( .allow )
    }
    
    func urlSession( _ session : URLSession, task : URLSessionTask, didSendBodyData bytesSent : Int64, totalBytesSent : Int64, totalBytesExpectedToSend : Int64 )
    {
        let progress : Double = Double ( ( Double( totalBytesSent ) / Double( totalBytesExpectedToSend ) ) * 100 )
        fileUploadDelegate?.progress( session : session, sessionTask : task, progressPercentage : progress, totalBytesSent : totalBytesSent, totalBytesExpectedToSend : totalBytesExpectedToSend )
    }
    
    func urlSession( _ session : URLSession, dataTask : URLSessionDataTask, didReceive data : Data )
    {
        do
        {
            if let httpResponse = dataTask.response as? HTTPURLResponse
            {
                let response = try APIResponse( response : httpResponse, responseData : data, responseJSONRootKey : self.jsonRootKey )
                fileUploadDelegate?.didFinish( response )
            }
            else
            {
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \(ErrorCode.RESPONSE_NIL) : \(ErrorMessage.RESPONSE_NIL_MSG)" )
                throw ZCRMError.SDKError( code : ErrorCode.RESPONSE_NIL, message : ErrorMessage.RESPONSE_NIL_MSG, details : nil )
            }
        }
        catch
        {
            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
            fileUploadDelegate?.didFail( typeCastToZCRMError( error ) )
        }
    }
    
    private func createMultipartRequest( bodyData : Data, boundary : String, completion : @escaping( Data?, ZCRMError? ) -> () )
    {
        var httpBodyData = bodyData
        guard let boundaryEncoded = "\r\n--\(boundary)".data( using : String.Encoding.utf8 ) else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.PROCESSING_ERROR) : Unable to create multi part data")
            completion( nil, ZCRMError.ProcessingError( code : ErrorCode.PROCESSING_ERROR, message : "Unable to create multi part data", details : nil ) )
            return
        }
        httpBodyData.append( boundaryEncoded )

        self.initialiseRequest { ( error ) in
            if let err = error
            {
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( err )" )
                completion( nil, typeCastToZCRMError( err ) )
            }
            else
            {
                guard self.request != nil else
                {
                    ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.UNABLE_TO_CONSTRUCT_URL) : \(ErrorMessage.UNABLE_TO_CONSTRUCT_URL_MSG)")
                    completion( nil, ZCRMError.ProcessingError( code : ErrorCode.UNABLE_TO_CONSTRUCT_URL, message : ErrorMessage.UNABLE_TO_CONSTRUCT_URL_MSG, details : nil ) )
                    return
                }
                self.request!.setValue( "multipart/form-data; boundary=\(boundary)", forHTTPHeaderField : "Content-Type" )
                self.request!.setValue( "\(httpBodyData.count)", forHTTPHeaderField : "Content-Length" )
                completion( httpBodyData, nil )
            }
        }
    }

    /// - Parameter content: ZCRMNote as JSON to be added
    private func getFilePart( fileURL : URL?, entity : [ String : Any? ]?, data : Data?, fileName : String?, boundary : String ) throws -> Data
    {
        var filePartData : Data = Data()
        if let entity = entity {
            for key in entity.keys {
                filePartData.append( try encodeStr( str : "--\(boundary)\r\n" ) )
                filePartData.append( try encodeStr( str : "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n" ) )
                if let entityJSON = try entity.getDictionary( key : key ).convertToJSON()
                {
                    filePartData.append( try encodeStr( str : "\( entityJSON )\r\n" ) )
                }
                filePartData.append( try encodeStr( str : "Content-Type: application/json\r\n\r\n" ) )
            }
        }
        if let url = fileURL
        {
            filePartData.append( try encodeStr( str : "--\(boundary)\r\n" ) )
            filePartData.append( try encodeStr( str : "Content-Disposition: form-data; name=\"file\"; filename=\"\(url.lastPathComponent)\"\r\n" ) )
            filePartData.append( try encodeStr( str : "Content-Type: \(getMimeTypeFor( fileURL : url ))\r\n\r\n" ) )
            filePartData.append( try Data( contentsOf : url ) )
        }
        if let fileData = data, let name = fileName
        {
            filePartData.append( try encodeStr( str : "--\(boundary)\r\n" ) )
            filePartData.append( try encodeStr( str : "Content-Disposition: form-data; name=\"file\"; filename=\"\( name )\"\r\n" ) )
            if let url = URL(string : name)
            {
                filePartData.append( try encodeStr( str : "Content-Type: \(getMimeTypeFor( fileURL : url ))\r\n\r\n" ) )
            }
            else
            {
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.PROCESSING_ERROR) : URL String could not be constructed")
                throw ZCRMError.ProcessingError( code : ErrorCode.PROCESSING_ERROR, message : "URL String could not be constructed", details : nil )
            }
            filePartData.append( fileData )
        }

        return filePartData
    }
    
    private func encodeStr( str : String ) throws -> Data
    {
        guard let strEncoded = str.data( using : String.Encoding.utf8 ) else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.PROCESSING_ERROR) : Unable to encode the given string")
            throw ZCRMError.ProcessingError( code : ErrorCode.PROCESSING_ERROR, message : "Unable to encode the given string", details : nil )
        }
        return strEncoded
    }

    private func getMimeTypeFor( fileURL : URL ) -> String
    {
        let pathExtension = fileURL.pathExtension
        if let uniformTypeIdentifier = UTTypeCreatePreferredIdentifierForTag( kUTTagClassFilenameExtension, pathExtension as CFString, nil )?.takeRetainedValue()
        {
            if let mimeType = UTTypeCopyPreferredTagWithClass( uniformTypeIdentifier, kUTTagClassMIMEType )?.takeRetainedValue()
            {
                return mimeType as String
            }
        }
        return "application/octet-stream"
    }

    internal func downloadFile( completion : @escaping( Result.Response< FileAPIResponse > ) -> () )
    {
        self.initialiseRequest { ( err ) in
            if let error = err
            {
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
            else
            {
                guard let request = self.request else
                {
                    ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.INTERNAL_ERROR) : Unable to construct URLRequest")
                    completion( .failure( ZCRMError.SDKError(code: ErrorCode.INTERNAL_ERROR, message: "Unable to construct URLRequest", details : nil ) ) )
                    return
                }
                let session : URLSession = URLSession(configuration: .default)
                session.downloadTask(with: request, completionHandler: { tempLocalUrl, response, err in
                    if let error = err
                    {
                        let zcrmError = typeCastToZCRMError( error )
                        ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                        completion( .failure( zcrmError ) )
                        return
                    }
                    if let fileResponse = response as? HTTPURLResponse, let localUrl = tempLocalUrl
                    {
                        do
                        {
                            let response = try FileAPIResponse( response : fileResponse, tempLocalUrl : localUrl )
                            completion( .success( response ) )
                        }
                        catch
                        {
                            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                            completion( .failure( typeCastToZCRMError( error ) ) )
                        }
                    }
                    else
                    {
                        ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.RESPONSE_NIL) : \(ErrorMessage.RESPONSE_NIL_MSG)")
                        completion( .failure( ZCRMError.SDKError( code: ErrorCode.RESPONSE_NIL, message: ErrorMessage.RESPONSE_NIL_MSG, details : nil ) ) )
                    }
                }).resume()
            }
        }
    }

    internal func downloadFile()
    {
        let sema = DispatchSemaphore(value: 0)
        let urlSessionConfig : URLSessionConfiguration = URLSessionConfiguration.default
        let operationQueue = OperationQueue()
        let urlSession : URLSession = URLSession(configuration: urlSessionConfig, delegate: self as URLSessionDelegate, delegateQueue: operationQueue)
        self.initialiseRequest { ( err ) in
            if let error = err
            {
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                self.fileDownloadDelegate?.didFail( typeCastToZCRMError( error ) )
                return
            }
            else
            {
                do
                {
                    guard let request = self.request else
                    {
                        ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.INTERNAL_ERROR) : Unable to construct URLRequest")
                        throw ZCRMError.SDKError(code: ErrorCode.INTERNAL_ERROR, message: "Unable to construct URLRequest", details : nil)
                    }
                    let downloadTask = urlSession.downloadTask(with: request)
                    sema.signal()
                    downloadTask.resume()
                }
                catch
                {
                    ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                    self.fileDownloadDelegate?.didFail( typeCastToZCRMError( error ) )
                }
            }
            sema.wait()
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL)
    {
        do
        {
            guard let response = downloadTask.response as? HTTPURLResponse else
            {
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.RESPONSE_NIL) : \(ErrorMessage.RESPONSE_NIL_MSG)")
                throw ZCRMError.SDKError(code: ErrorCode.RESPONSE_NIL, message: ErrorMessage.RESPONSE_NIL_MSG, details : nil)
            }
            let fileAPIResponse : FileAPIResponse = try FileAPIResponse(response: response, tempLocalUrl: location)
            fileDownloadDelegate?.didFinish( fileAPIResponse )
        }
        catch
        {
            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error.description )" )
            self.fileDownloadDelegate?.didFail( typeCastToZCRMError( error ) )
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
    {
        let progress : Double = Double ( ( totalBytesWritten / totalBytesExpectedToWrite ) * 100 )
        fileDownloadDelegate?.progress( session: session, downloadTask: downloadTask, progressPercentage: progress, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite )
    }
}

public protocol FileDownloadDelegate
{
    func progress( session: URLSession, downloadTask: URLSessionDownloadTask, progressPercentage : Double, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64 )
    
    func didFinish( _ fileAPIResponse : FileAPIResponse )
    
    func didFail( _ withError : ZCRMError? )
}

public protocol FileUploadDelegate
{
    func progress( session : URLSession, sessionTask : URLSessionTask, progressPercentage : Double, totalBytesSent : Int64, totalBytesExpectedToSend : Int64 )
    
    func didFinish( _ apiResponse : APIResponse )
    
    func didFail( _ withError : ZCRMError? )
}
