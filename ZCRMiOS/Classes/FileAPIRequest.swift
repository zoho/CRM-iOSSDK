//
//  FileAPIRequest.swift
//  ZCRMiOS
//
//  Created by Umashri R on 04/12/18.
//

import Foundation
import MobileCoreServices

internal class FileAPIRequest : APIRequest
{
    private var fileDownloadDelegate : ZCRMFileDownloadDelegate?
    private var fileUploadDelegate : ZCRMFileUploadDelegate?
    private static var fileAPIRequestDelegate : FileAPIRequestDelegate = FileAPIRequestDelegate()
    
    internal typealias isCompletion = (_ isConnected: Bool, _ apiResponse : APIResponse?) -> Void
    var completion: isCompletion?
    
    private static let urlSession : URLSession = URLSession(configuration: URLSessionConfiguration.default)
    internal static var fileUploadURLSessionWithDelegates : URLSession = URLSession(configuration: ZCRMSDKClient.shared.fileUploadURLSessionConfiguration, delegate: FileAPIRequest.fileAPIRequestDelegate, delegateQueue: OperationQueue())
    internal static var fileDownloadURLSessionWithDelegates : URLSession = URLSession(configuration: ZCRMSDKClient.shared.fileDownloadURLSessionConfiguration, delegate: FileAPIRequest.fileAPIRequestDelegate, delegateQueue: OperationQueue())
    internal var requestedModule : String?

    init( handler : APIHandler, fileDownloadDelegate : ZCRMFileDownloadDelegate)
    {
        self.fileDownloadDelegate = fileDownloadDelegate
        self.requestedModule = handler.getModuleName()
        super.init( handler : handler, cacheFlavour : .noCache )
    }
    
    init( handler : APIHandler, fileUploadDelegate : ZCRMFileUploadDelegate)
    {
        self.fileUploadDelegate = fileUploadDelegate
        super.init( handler : handler, cacheFlavour : .noCache )
    }
    
    init( handler : APIHandler )
    {
        super.init( handler : handler, cacheFlavour : .noCache )
    }
    
    internal func uploadLink( completion : @escaping( CRMResultType.Response< APIResponse > ) -> () )
    {
        let boundary = APIConstants.BOUNDARY
        self.createMultipartRequest( bodyData : Data(), fileName: "-", boundary : boundary) { ( url, error ) in
            if let err = error
            {
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( err )" )
                completion( .failure( typeCastToZCRMError( err ) ) )
                return
            }
            if let tempUrl = url
            {
                self.removeTempFile(atURL: tempUrl)
            }
            self.makeRequest() { result in
                do {
                    switch result {
                    case .success(let respdata, let response) :
                        if !respdata.isEmpty {
                            let response = try APIResponse( response : response, responseData: respdata, responseJSONRootKey: self.jsonRootKey, requestAPIName: self.requestedModule )
                            completion(.success(response))
                        } else {
                            let response = try APIResponse( response : response, responseJSONRootKey: self.jsonRootKey, requestAPIName: self.requestedModule)
                            completion(.success(response))
                        }
                    case .failure(let error) :
                        completion( .failure( typeCastToZCRMError( error ) ) )
                    }
                } catch {
                    ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                    completion(.failure( typeCastToZCRMError( error ) ) )
                }
            }
        }
    }
    
    /// - Parameter content: ZCRMNote as JSON to be added
    internal func uploadFile( filePath : String, entity : [ String : Any? ]?, completion : @escaping( CRMResultType.Response< APIResponse > ) -> () )
    {
        let fileURL = URL( fileURLWithPath : filePath )
        let boundary = APIConstants.BOUNDARY
        do
        {
            let httpBodyData = try getFilePart( fileURL : fileURL, entity : entity, data : nil, fileName : nil, boundary : boundary )
            createMultipartRequest( bodyData : httpBodyData, fileName: filePath.lastPathComponent(), boundary : boundary ) { ( url, error ) in
                if let err = error
                {
                    ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( err )" )
                    completion( .failure( typeCastToZCRMError( err ) ) )
                    return
                }
                if let url = url
                {
                    guard let request = self.request else
                    {
                        self.removeTempFile(atURL: url)
                        ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.internalError) : Unable to construct URLRequest, \( APIConstants.DETAILS ) : -")
                        completion( .failure( ZCRMError.sdkError(code: ErrorCode.internalError, message: "Unable to construct URLRequest", details : nil ) ) )
                        return
                    }
                    
                    let jsonRootKey = self.jsonRootKey
                    FileAPIRequest.urlSession.uploadTask(with: request, fromFile: url) { resultType in
                        self.removeTempFile(atURL: url)
                        do
                        {
                            switch resultType
                            {
                            case .success(let respData, let resp) :
                                let response = try APIResponse( response : resp, responseData : respData, responseJSONRootKey : jsonRootKey, requestAPIName: self.requestedModule )
                                completion( .success( response ) )
                            case .failure(let error) :
                                completion( .failure( typeCastToZCRMError( error ) ) )
                            }
                        }
                        catch
                        {
                            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                            completion( .failure( typeCastToZCRMError( error ) ) )
                        }
                    }.resume()
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
    internal func uploadFile( fileName : String, entity : [ String : Any? ]?, fileData : Data, completion : @escaping( CRMResultType.Response< APIResponse > ) -> () )
    {
        do
        {
            let boundary = APIConstants.BOUNDARY
            let httpBodyData = try getFilePart( fileURL : nil, entity: entity, data : fileData, fileName : fileName, boundary : boundary )
            createMultipartRequest(bodyData: httpBodyData, fileName: fileName, boundary: boundary) { ( url, error ) in
                if let err = error
                {
                    ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( err )" )
                    completion( .failure( typeCastToZCRMError( err ) ) )
                    return
                }
                if let url = url
                {
                    guard let request = self.request else
                    {
                        self.removeTempFile(atURL: url)
                        ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.internalError) : Unable to construct URLRequest, \( APIConstants.DETAILS ) : -")
                        completion( .failure( ZCRMError.sdkError(code: ErrorCode.internalError, message: "Unable to construct URLRequest", details : nil ) ) )
                        return
                    }
                    
                    let jsonRootKey = self.jsonRootKey
                    FileAPIRequest.urlSession.uploadTask(with: request, fromFile: url) { resultType in
                        self.removeTempFile(atURL: url)
                        do
                        {
                            switch resultType
                            {
                            case .success(let respData, let resp) :
                                let response = try APIResponse( response : resp, responseData : respData, responseJSONRootKey : jsonRootKey, requestAPIName: self.requestedModule )
                                completion( .success( response ) )
                            case .failure(let error) :
                                completion( .failure( typeCastToZCRMError( error ) ) )
                            }
                        }
                        catch
                        {
                            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                            completion( .failure( typeCastToZCRMError( error ) ) )
                        }
                    }.resume()
                }
            }
        }
        catch
        {
            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
            completion( .failure( typeCastToZCRMError( error ) ) )
        }
    }
    
    /**
        If the ZCRMSDKClient.shared..fileUploadURLSessionConfiguration is set to background, uploads from data fail directly after the app exists, we need to write the data to a local file before we can upload.
     
        - Parameters:
            - fileData : The data that needs to be uploaded
            - fileName : Name of the file being uploaded. It is used to create the temp file.
     */
    private func getTempFileURL( fileData : Data?, fileName : String?) throws -> URL
    {
        do
        {
            if let tempFileName = fileName, let tempFileData = fileData
            {
                let tempFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\( tempFileName )")
                try tempFileData.write(to: tempFileURL)
                return tempFileURL
            }
            else
            {
                throw ZCRMError.inValidError(code: ErrorCode.invalidData, message: "File name and data are required to perform the upload task", details: nil)
            }
        }
        catch
        {
            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
            throw typeCastToZCRMError( error )
        }
    }
    
    /**
        To remove the temporary file created during the upload task using data. ( Required only when the ZCRMSDKClient.fileUploadURLSessionConfiguration is set to background )
        
        - Parameters:
            - tempFileURL : URL to remove the temporary file created while uploading the data.
     */
    private func removeTempFile( atURL tempFileURL : URL)
    {
        do
        {
            try FileManager.default.removeItem(at: tempFileURL)
            ZCRMLogger.logInfo(message: "Temp file created for data upload has been deleted successfully")
        }
        catch
        {
            ZCRMLogger.logFault(message: "ZCRMError - Details : \( error ), Message : Failed to delete the temporary file created to upload the data. URL -> \( tempFileURL.absoluteString )")
        }
    }
    
    
    internal func uploadFile( fileRefId : String, filePath : String?, fileName : String?, fileData : Data?, entity : [ String : Any? ]? , _ isCompleted : @escaping isCompletion)
    {
        completion = isCompleted
        guard let completion = completion else {
            return
        }
        do
        {
            var fileURL : URL
            var httpBodyData : Data?
            let boundary = APIConstants.BOUNDARY
            if let filePath = filePath
            {
                fileURL = URL( fileURLWithPath : filePath )
                httpBodyData = try getFilePart( fileURL : fileURL, entity : entity, data : nil, fileName : nil, boundary : boundary )
            }
            else if let tempFileName = fileName, let tempFileData = fileData
            {
                httpBodyData = try getFilePart( fileURL : nil, entity: entity, data : tempFileData, fileName : tempFileName, boundary : boundary )
            }
            guard let httpBody = httpBodyData else
            {
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : Unable to construct HTTPBody" )
                fileUploadDelegate?.didFail( fileRefId : fileRefId, ZCRMError.processingError(code: ErrorCode.invalidData, message: "Unable to construct HTTPBody", details: nil) )
                completion( false, nil)
                return
            }
            let fileUploadDelegate = self.fileUploadDelegate
            createMultipartRequest( bodyData : httpBody, fileName: fileName ?? filePath?.lastPathComponent() ?? "-", boundary : boundary ) { ( tempFileUrl, error ) in
                if let err = error
                {
                    ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( err )" )
                    fileUploadDelegate?.didFail( fileRefId : fileRefId, typeCastToZCRMError( err ) )
                    completion( false, nil )
                    return
                }
                if let tempFileUrl = tempFileUrl
                {
                    guard let request = self.request else
                    {
                        self.removeTempFile(atURL: tempFileUrl)
                        ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( ErrorCode.internalError ) : Unable to construct URLRequest, \( APIConstants.DETAILS ) : -" )
                        fileUploadDelegate?.didFail( fileRefId : fileRefId, ZCRMError.sdkError( code : ErrorCode.internalError, message : "Unable to construct URLRequest", details : nil ) )
                        completion( false, nil)
                        return
                    }
                    
                    let fileUploadTaskReference = FileUploadTaskReference(fileRefId: fileRefId, uploadClosure: { taskDetails, taskFinished, error in
                        if let error = error
                        {
                            self.fileUploadDelegate?.didFail(fileRefId: fileRefId, typeCastToZCRMError( error ))
                            self.removeTempFile(atURL: tempFileUrl)
                            completion( false , nil)
                        }
                        else if let taskFinished = taskFinished
                        {
                            do
                            {
                                if let httpResponse = taskFinished.dataTask?.response as? HTTPURLResponse, let data = taskFinished.data
                                {
                                    let jsonRootKey = self.jsonRootKey
                                    let response = try APIResponse( response : httpResponse, responseData : data, responseJSONRootKey : jsonRootKey, requestAPIName: self.requestedModule )
                                    uploadTasksQueue.async {
                                        FileTasks.liveUploadTasks?.removeValue(forKey: fileRefId)
                                    }
                                    fileUploadDelegate?.didFinish( fileRefId : fileRefId, response )
                                    self.removeTempFile(atURL: tempFileUrl)
                                    completion( true, response )
                                }
                                else
                                {
                                    ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \(ErrorCode.responseNil) : \(ErrorMessage.responseNilMsg), \( APIConstants.DETAILS ) : -" )
                                    throw ZCRMError.sdkError( code : ErrorCode.responseNil, message : ErrorMessage.responseNilMsg, details : nil )
                                }
                            }
                            catch
                            {
                                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                                uploadTasksQueue.async {
                                    FileTasks.liveUploadTasks?.removeValue(forKey: fileRefId)
                                }
                                fileUploadDelegate?.didFail( fileRefId : fileRefId, typeCastToZCRMError( error ) )
                                self.removeTempFile(atURL: tempFileUrl)
                                completion( false , nil)
                            }
                        }
                        else if let taskDetails = taskDetails
                        {
                            fileUploadDelegate?.progress(fileRefId: fileRefId, session: taskDetails.session, sessionTask: taskDetails.task, progressPercentage: taskDetails.progress, totalBytesSent: taskDetails.bytesSent, totalBytesExpectedToSend: taskDetails.totalBytesExpectedToSend)
                        }
                    })
                    let uploadTask = FileAPIRequest.fileUploadURLSessionWithDelegates.uploadTask(with: request, fromFile : tempFileUrl)
                    FileAPIRequest.fileAPIRequestDelegate.uploadTaskWithFileRefIdDict.updateValue( fileUploadTaskReference, forKey: uploadTask)
                    uploadTasksQueue.async {
                        if FileTasks.liveUploadTasks == nil
                        {
                            FileTasks.liveUploadTasks = [ String : URLSessionUploadTask ]()
                        }
                        if let tasks = FileTasks.liveUploadTasks, tasks[ fileRefId ] == nil
                        {
                            FileTasks.liveUploadTasks?.updateValue( uploadTask, forKey: fileRefId)
                            uploadTask.resume()
                        }
                        else
                        {
                            ZCRMLogger.logError( message : "Error Occurred : A task with file reference Id - \( fileRefId ) is already present. Please provide a unique reference id" )
                            fileUploadDelegate?.didFail( fileRefId: fileRefId, ZCRMError.inValidError(code: ErrorCode.invalidData, message: "A task with file reference Id - \( fileRefId ) is already present. Please provide a unique reference id", details: nil) )
                        }
                    }
                }
            }
        }
        catch
        {
            ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
            fileUploadDelegate?.didFail( fileRefId : fileRefId, typeCastToZCRMError( error ) )
            completion( false, nil )
        }
    }
    
    private func createMultipartRequest( bodyData : Data, fileName : String, boundary : String, completion : @escaping( URL?, ZCRMError? ) -> () )
    {
        var tempURL : URL
        var httpBodyData = bodyData
        guard let boundaryEncoded = "\r\n--\(boundary)".data( using : String.Encoding.utf8 ) else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.processingError) : Unable to create multi part data, \( APIConstants.DETAILS ) : -")
            completion( nil, ZCRMError.processingError( code : ErrorCode.processingError, message : "Unable to create multi part data", details : nil ) )
            return
        }
        httpBodyData.append( boundaryEncoded )
        do
        {
            tempURL = try self.getTempFileURL(fileData: httpBodyData, fileName: fileName)
        }
        catch
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : Unable to write data to a file, \( APIConstants.DETAILS ) : -")
            completion( nil, ZCRMError.processingError( code : ErrorCode.unableToConstructURL, message : ErrorMessage.unableToConstructURLMsg, details : nil ) )
            return
        }

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
                    ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.unableToConstructURL) : \(ErrorMessage.unableToConstructURLMsg), \( APIConstants.DETAILS ) : -")
                    completion( nil, ZCRMError.processingError( code : ErrorCode.unableToConstructURL, message : ErrorMessage.unableToConstructURLMsg, details : nil ) )
                    return
                }
                self.request!.setValue( "multipart/form-data; boundary=\( boundary )", forHTTPHeaderField : "Content-Type" )
                self.request!.setValue( "\(httpBodyData.count)", forHTTPHeaderField : "Content-Length" )
                completion( tempURL, nil )
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
                filePartData.append( try encodeStr( str : "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n" ))
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
            
            if let url = URL(string : name.addingPercentEncoding(withAllowedCharacters: .urlUserAllowed) ?? "")
            {
                filePartData.append( try encodeStr( str : "Content-Type: \(getMimeTypeFor( fileURL : url ))\r\n\r\n"))
            }
            else
            {
                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.processingError) : URL String could not be constructed, \( APIConstants.DETAILS ) : -")
                throw ZCRMError.processingError( code : ErrorCode.processingError, message : "URL String could not be constructed", details : nil )
            }
            filePartData.append( fileData )
        }

        return filePartData
    }
    
    private func encodeStr( str : String ) throws -> Data
    {
        guard let strEncoded = str.data( using : String.Encoding.utf8 ) else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.processingError) : Unable to encode the given string, \( APIConstants.DETAILS ) : -")
            throw ZCRMError.processingError( code : ErrorCode.processingError, message : "Unable to encode the given string", details : nil )
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

    internal func downloadFile( completion : @escaping( CRMResultType.Response< FileAPIResponse > ) -> () )
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
                    ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.internalError) : Unable to construct URLRequest")
                    completion( .failure( ZCRMError.sdkError(code: ErrorCode.internalError, message: "Unable to construct URLRequest", details : nil ) ) )
                    return
                }
                FileAPIRequest.urlSession.downloadTask(with: request) { resultType in
                    do
                    {
                        switch resultType
                        {
                        case .success(let respData, let resp) :
                            if let url = respData as? URL {
                                let response = try FileAPIResponse( response : resp, tempLocalUrl : url, requestAPIName: self.requestedModule )
                                completion( .success( response ) )
                            }
                        case .failure(let error) :
                            completion( .failure( typeCastToZCRMError( error ) ) )
                        }
                    } catch {
                        ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                        completion( .failure( typeCastToZCRMError( error ) ) )
                    }
                }.resume()
            }
        }
    }

    internal func downloadFile( fileRefId : String )
    {
        let fileDownloadDelegate = self.fileDownloadDelegate
        self.initialiseRequest { ( err ) in
            if let error = err
            {
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                fileDownloadDelegate?.didFail( fileRefId: fileRefId, typeCastToZCRMError( error ) )
                return
            }
            else
            {
                do
                {
                    guard let request = self.request else
                    {
                        ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.internalError) : Unable to construct URLRequest, \( APIConstants.DETAILS ) : -")
                        throw ZCRMError.sdkError(code: ErrorCode.internalError, message: "Unable to construct URLRequest", details : nil)
                    }
                    
                    let fileDownloadTaskReference = FileDownloadTaskReference(fileRefId: fileRefId) { ( taskDetails, taskFinished, error ) in
                        if let error = error
                        {
                            fileDownloadDelegate?.didFail( fileRefId: fileRefId, typeCastToZCRMError( error ) )
                        }
                        else if let taskFinished = taskFinished
                        {
                            do
                            {
                                guard let response = taskFinished.downloadTask?.response as? HTTPURLResponse else
                                {
                                    ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.responseNil) : \(ErrorMessage.responseNilMsg), \( APIConstants.DETAILS ) : -")
                                    throw ZCRMError.sdkError(code: ErrorCode.responseNil, message: ErrorMessage.responseNilMsg, details : nil)
                                }
                                
                                downloadTasksQueue.async {
                                    FileTasks.liveDownloadTasks?.removeValue(forKey: fileRefId)
                                }
                                let fileAPIResponse : FileAPIResponse = try FileAPIResponse(response: response, tempLocalUrl: taskFinished.location, requestAPIName: self.requestedModule)
                                fileDownloadDelegate?.didFinish( fileRefId: fileRefId, fileAPIResponse )
                            }
                            catch
                            {
                                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                                fileDownloadDelegate?.didFail( fileRefId: fileRefId, typeCastToZCRMError( error ) )
                            }
                        }
                        else if let taskDetails = taskDetails
                        {
                            fileDownloadDelegate?.progress( fileRefId : fileRefId, session: taskDetails.session, downloadTask: taskDetails.task, progressPercentage: taskDetails.progress, totalBytesWritten: taskDetails.totalBytesWritten, totalBytesExpectedToWrite: taskDetails.totalBytesExpectedToWrite )
                        }
                    }
                    
                    let downloadTask = FileAPIRequest.fileDownloadURLSessionWithDelegates.downloadTask(with: request)
                    FileAPIRequest.fileAPIRequestDelegate.downloadTaskWithFileRefIdDict.updateValue( fileDownloadTaskReference, forKey: downloadTask)
                    downloadTasksQueue.async {
                        if FileTasks.liveDownloadTasks == nil
                        {
                            FileTasks.liveDownloadTasks = [ String : URLSessionDownloadTask ]()
                        }
                        FileTasks.liveDownloadTasks?.updateValue(downloadTask, forKey: fileRefId)
                    }
                    downloadTask.resume()
                }
                catch
                {
                    ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
                    fileDownloadDelegate?.didFail( fileRefId: fileRefId, typeCastToZCRMError( error ) )
                }
            }
        }
    }
}

public protocol ZCRMFileDownloadDelegate
{
    func progress( fileRefId : String, session: URLSession, downloadTask: URLSessionDownloadTask, progressPercentage : Double, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64 )
    
    func didFinish( fileRefId : String, _ fileAPIResponse : FileAPIResponse )
    
    func didFail( fileRefId : String, _ withError : ZCRMError? )
}

public protocol ZCRMFileUploadDelegate
{
    func progress( fileRefId : String, session : URLSession, sessionTask : URLSessionTask, progressPercentage : Double, totalBytesSent : Int64, totalBytesExpectedToSend : Int64 )
    
    func didFinish( fileRefId : String, _ apiResponse : APIResponse )
    
    func didFail( fileRefId : String, _ withError : ZCRMError? )

}


internal class FileAPIRequestDelegate : NSObject, URLSessionDataDelegate, URLSessionTaskDelegate, URLSessionDownloadDelegate
{
    
    var uploadTaskWithFileRefIdDict : [ URLSessionTask : FileUploadTaskReference ] = [ URLSessionTask : FileUploadTaskReference ]()
    var downloadTaskWithFileRefIdDict : [ URLSessionTask : FileDownloadTaskReference ] = [ URLSessionTask : FileDownloadTaskReference ]()
    
    func urlSession( _ session : URLSession, task : URLSessionTask, didCompleteWithError error : Error? )
    {
         if let err = error
         {
             if let _ = task as? URLSessionDownloadTask
             {
                 if let fileDownloadTaskReference = downloadTaskWithFileRefIdDict[ task ]
                 {
                     fileDownloadTaskReference.downloadClosure( nil, nil, typeCastToZCRMError( err ))
                 }
             }
             else if let _ = task as? URLSessionUploadTask
             {
                 if let fileUploadTaskReference = uploadTaskWithFileRefIdDict[ task ]
                 {
                     fileUploadTaskReference.uploadClosure( nil, nil, typeCastToZCRMError( err ))
                 }
             }
         }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL)
    {
        if let fileDownloadTaskReference = downloadTaskWithFileRefIdDict[ downloadTask ]
        {
            fileDownloadTaskReference.downloadClosure( nil, FileDownloadTaskFinished(downloadTask: downloadTask, location: location), nil)
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
    {
        let progress : Double = Double ( ( totalBytesWritten / totalBytesExpectedToWrite ) * 100 )
        if let fileDownloadTaskReference = downloadTaskWithFileRefIdDict[ downloadTask ]
        {
            fileDownloadTaskReference.downloadClosure( FileDownloadTaskDetails(progress: progress, session: session, task: downloadTask, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite), nil, nil)
        }
    }
    
    func urlSession( _ session : URLSession, dataTask : URLSessionDataTask, didReceive response : URLResponse, completionHandler : @escaping ( URLSession.ResponseDisposition ) -> Void )
    {
        completionHandler( .allow )
    }
    
    func urlSession( _ session : URLSession, task : URLSessionTask, didSendBodyData bytesSent : Int64, totalBytesSent : Int64, totalBytesExpectedToSend : Int64 )
    {
        let progress : Double = Double ( ( Double( totalBytesSent ) / Double( totalBytesExpectedToSend ) ) * 100 )
        if let fileUploadTaskReference = uploadTaskWithFileRefIdDict[ task ]
        {
            fileUploadTaskReference.uploadClosure( FileUploadTaskDetails(progress: progress, session: session, task: task, bytesSent: bytesSent, totalBytesSent: totalBytesSent, totalBytesExpectedToSend: totalBytesExpectedToSend), nil, nil )
        }
    }
    
    func urlSession( _ session : URLSession, dataTask : URLSessionDataTask, didReceive data : Data )
    {
        if let fileUploadTaskReference = uploadTaskWithFileRefIdDict[ dataTask ]
        {
            fileUploadTaskReference.uploadClosure( nil, FileUploadTaskFinished( dataTask: dataTask, data: data ), nil )
        }
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        if let identifier = session.configuration.identifier, let completionHandler = ZCRMSDKClient.shared.sessionCompletionHandlers[ identifier ]
        {
            DispatchQueue.main.async {
                completionHandler()
            }
        }
    }
}

/**
   To hold the file reference id and a closure for passing the upload task details to the delegate

    The closure has three parameters which helps to specify the status of the upload. The three parameters are,
 
    1. FileUploadTaskDetails : Contains the progress details of the upload task
    2. FileUploadTaskFinished : Contains the data of the uploaded file
    3. Error : Error details
*/
internal struct FileUploadTaskReference
{
    var fileRefId : String
    var uploadClosure : ( FileUploadTaskDetails?, FileUploadTaskFinished?, Error? ) -> Void
}

internal struct FileUploadTaskDetails
{
    var progress : Double
    var session : URLSession
    var task : URLSessionTask
    var bytesSent : Int64
    var totalBytesSent : Int64
    var totalBytesExpectedToSend : Int64
}

internal struct FileUploadTaskFinished
{
    var dataTask : URLSessionDataTask?
    var data : Data?
}

/**
   To hold the file reference id and a closure for passing the download task details to the delegate

    The closure has three parameters which helps to specify the status of the download. The three parameters are,
 
    1. FileDownloadTaskDetails : Contains the progress details of the download task
    2. FileDownloadTaskFinished : Contains the location of the downloaded file
    3. Error : Error details
*/
internal struct FileDownloadTaskReference
{
    var fileRefId : String
    var downloadClosure : ( FileDownloadTaskDetails?, FileDownloadTaskFinished?, Error? ) -> Void
}

internal struct FileDownloadTaskDetails
{
    var progress : Double
    var session : URLSession
    var task : URLSessionDownloadTask
    var totalBytesWritten : Int64
    var totalBytesExpectedToWrite : Int64
}

internal struct FileDownloadTaskFinished
{
    var downloadTask : URLSessionDownloadTask?
    var location : URL?
}

internal struct FileTasks
{
    static var liveUploadTasks : [ String : URLSessionTask]?
    static var liveDownloadTasks : [ String : URLSessionDownloadTask ]?
}

internal var uploadTasksQueue = DispatchQueue(label: "com.zoho.crm.sdk.fileuploadtasks.queue" )
internal var downloadTasksQueue = DispatchQueue(label: "com.zoho.crm.sdk.filedownloadtasks.queue" )

/**
    To cancel a specific upload task which is in progress.
 
    - Parameters:
        - id : Reference ID (fileRefId) of the upload task which has to be cancelled.
        - completion : Returns an APIResponse with success message if the task has been cancelled or, an error message if the cancellation failed.
 */

public func cancelUploadTask(withRefId id : String, completion : @escaping ( CRMResultType.Response< APIResponse > ) -> () )
{
    let response = APIResponse()
    response.setStatus(status: "error")
    
    uploadTasksQueue.async
    {
        guard let fileUploadTasks = FileTasks.liveUploadTasks, !fileUploadTasks.isEmpty else
        {
            completion( .failure( ZCRMError.processingError(code: ErrorCode.processingError, message: "There are no upload tasks in progress.", details: nil) ))
            return
        }
        guard let task = fileUploadTasks[ id ] else
        {
            completion( .failure( ZCRMError.processingError(code: ErrorCode.processingError, message: "There is no upload task in progress with refId - \( id ).", details: nil) ))
            return
        }
        if task.state != URLSessionTask.State.completed {
            task.cancel()
        }
        FileTasks.liveUploadTasks?.removeValue(forKey: id)
    }
    response.setStatus(status: "Success")
    response.setMessage(message: "Upload task with refId - \( id ) has been cancelled successfully.")
    completion( .success( response ))
}

/**
    To cancel a specific download task which is in progress
 
    - Parameters:
        - id : ID of the particular download task which has to be cancelled.
        - completion : Returns the APIResponse with success message if the upload has been cancelled or, an error message if the cancellation failed

         ID of the download task differs according to the type of action performed. The different types of ID are,

         * Attachment ID - Entity download attachments
         * Attachment ID - Entity notes attachment download
         * Note ID - Voice note
         * User ID - User photo download
         * Record ID - Record photo download
         * Image ID - Email inline image attachment
         * Attachment ID ( or ) File Name ( or ) Message ID ( For cancelling all the attachments download in mail ) - Email attachment
         * Component ID - DashboardComponent
 */

public func cancelDownloadTask(withId id : String, completion : @escaping ( CRMResultType.Response< APIResponse > ) -> () )
{
    let response = APIResponse()
    response.setStatus(status: "error")
    
    downloadTasksQueue.async {
        guard let fileDownloadTasks = FileTasks.liveDownloadTasks, !fileDownloadTasks.isEmpty else
        {
            completion( .failure( ZCRMError.processingError(code: ErrorCode.processingError, message: "There are no download tasks in progress.", details: nil) ))
            return
        }
        
        guard let task = fileDownloadTasks[ id ] else
        {
            completion( .failure( ZCRMError.processingError(code: ErrorCode.processingError, message: "There is no download task in progress with refId - \( id ).", details: nil) ))
            return
        }
        if task.state != URLSessionDownloadTask.State.completed
        {
            task.cancel()
        }
        FileTasks.liveDownloadTasks?.removeValue(forKey: id)
    }
    response.setStatus(status: "Success")
    response.setMessage(message: "Download task with refId - \( id ) has been cancelled successfully.")
    completion( .success( response ))
}
