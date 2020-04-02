//
//  TaxAPIHandler.swift
//  ZCRMiOS
//
//  Created by Umashri R on 06/09/18.
//

import Foundation

internal class TaxAPIHandler : CommonAPIHandler
{
    internal func getAllTaxes( completion : @escaping ( Result.DataResponse< [ ZCRMTax ], BulkAPIResponse > ) -> Void )
    {
        var taxes : [ ZCRMTax ] = [ ZCRMTax ]()
        
        setJSONRootKey(key: JSONRootKey.TAXES)
        setUrlPath(urlPath: "\( URLPathConstants.org )/\( URLPathConstants.taxes )")
        setRequestMethod(requestMethod: .get)

        let request : APIRequest = APIRequest( handler: self )
        print( "Request : \( request.toString() )" )
        
        request.getBulkAPIResponse() { result in
            do
            {
                switch result
                {
                case .success(let bulkResponse) :
                    let responseJSON = bulkResponse.getResponseJSON()
                    if responseJSON.isEmpty == true
                    {
                        ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.responseNil) : \(ErrorMessage.responseJSONNilMsg), \( APIConstants.DETAILS ) : -")
                        completion( .failure( ZCRMError.processingError( code: ErrorCode.responseNil, message: ErrorMessage.responseJSONNilMsg, details : nil ) ) )
                        return
                    }
                    let taxesList : [[ String : Any ]] = try responseJSON.getArrayOfDictionaries(key: self.getJSONRootKey())
                    for taxDetails in taxesList
                    {
                        try taxes.append( self.getZCRMOrgTax( taxDetails: taxDetails ) )
                    }
                    bulkResponse.setData(data: taxes)
                    completion( .success( taxes, bulkResponse ) )
                case .failure(let error) :
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
            catch
            {
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func getTax( withId : Int64, completion : @escaping ( Result.DataResponse< ZCRMTax, APIResponse > ) -> Void )
    {
        setJSONRootKey( key : JSONRootKey.TAXES )
        setUrlPath(urlPath: "\( URLPathConstants.org )/\( URLPathConstants.taxes )/\( withId )")
        setRequestMethod(requestMethod: .get)

        let request = APIRequest(handler: self)
        print( "Request : \(request.toString())" )
        
        request.getAPIResponse() { result in
            do
            {
                switch result
                {
                case .success(let response) :
                    let responseJSON : [ String : Any ] = response.getResponseJSON()
                    let taxesList : [[ String : Any ]] = try responseJSON.getArrayOfDictionaries(key: self.getJSONRootKey())
                    let tax = try self.getZCRMOrgTax(taxDetails: taxesList[0])
                    response.setData(data: tax )
                    completion( .success( tax, response ))
                case .failure(let error) :
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
            catch
            {
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func createTax( tax : ZCRMTax, completion : @escaping( Result.DataResponse< ZCRMTax, APIResponse > ) -> Void )
    {
        setJSONRootKey( key : JSONRootKey.TAXES )
        var reqBodyObj : [ String : [[ String : Any ]] ] = [ String : [[ String : Any]] ]()
        var dataArray : [[ String : Any ]] = [[ String : Any ]]()
        dataArray.append( getZCRMTaxAsJSON(tax: tax) )
        reqBodyObj[getJSONRootKey()] = dataArray

        setUrlPath(urlPath: "\( URLPathConstants.org )/\( URLPathConstants.taxes )")
        setRequestMethod(requestMethod: .post)
        setRequestBody(requestBody: reqBodyObj)

        let request : APIRequest = APIRequest( handler: self )
        print( "Request : \( request.toString() )" )

        request.getAPIResponse { ( resultType ) in
            do
            {
               switch resultType
               {
               case .success(let response) :
                    let entityResponseJSON : [ String : Any ] = response.getResponseJSON()
                    let respDataArr : [ [ String : Any? ] ] = try entityResponseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                    let respData : [String:Any?] = respDataArr[0]
                    let taxJSON : [ String : Any ] = try respData.getDictionary(key: APIConstants.DETAILS)
                    let tax : ZCRMTax = try self.getZCRMOrgTax(taxDetails: taxJSON)
                    response.setData( data : tax )
                    completion( .success( tax, response ) )
               case .failure(let error) :
                   completion( .failure( typeCastToZCRMError( error ) ) )
               }
            }
            catch
            {
               completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func createTaxes( taxes : [ ZCRMTax ], completion : @escaping( Result.DataResponse< [ ZCRMTax ], BulkAPIResponse > ) -> Void )
    {
        if taxes.count > 100
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : USER ID must not be nil, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError(code: ErrorCode.maxCountExceeded, message: ErrorMessage.apiMaxRecordsMsg, details: nil) ) )
            return
        }
        
        setJSONRootKey( key : JSONRootKey.TAXES )
        var reqBodyObj : [ String : [[ String : Any ]] ] = [ String : [[ String : Any]] ]()
        var dataArray : [[ String : Any ]] = [[ String : Any ]]()
        for tax in taxes
        {
            dataArray.append( self.getZCRMTaxAsJSON(tax: tax) )
        }
        reqBodyObj[getJSONRootKey()] = dataArray
 
        setUrlPath(urlPath: "\( URLPathConstants.org )/\( URLPathConstants.taxes )")
        setRequestMethod(requestMethod: .post)
        setRequestBody(requestBody: reqBodyObj)
 
        let request : APIRequest = APIRequest( handler: self )
        print( "Request : \( request.toString() )" )
 
        request.getBulkAPIResponse { ( resultType ) in
            do
            {
                switch resultType
                {
                case .success(let response) :
                    let responses : [ EntityResponse ] = response.getEntityResponses()
                    var createdTaxes : [ ZCRMTax ] = [ ZCRMTax ]()
                    for entityResponse in responses
                    {
                        if APIConstants.CODE_SUCCESS == entityResponse.getStatus()
                        {
                            let entityResponseJSON : [ String : Any ] = entityResponse.getResponseJSON()
                            let taxJSON : [ String : Any ] = try entityResponseJSON.getDictionary(key: APIConstants.DETAILS)
                            if taxJSON.isEmpty == true
                            {
                                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.responseNil) : \(ErrorMessage.responseJSONNilMsg), \( APIConstants.DETAILS ) : -, Response : \( entityResponse )")
                            }
                            else
                            {
                                do
                                {
                                    let tax : ZCRMTax = try self.getZCRMOrgTax(taxDetails: taxJSON)
                                    createdTaxes.append(tax)
                                }
                                catch
                                {
                                    ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \( APIConstants.DETAILS ) : \( error ), Response : \( response )")
                                }
                                
                            }
                        }
                    }
                    response.setData( data : createdTaxes )
                    completion( .success( createdTaxes, response ) )
                case .failure(let error) :
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
            catch
            {
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
 
    internal func updateTaxes( taxes : [ ZCRMTax ], completion : @escaping( Result.DataResponse< [ ZCRMTax ], BulkAPIResponse > ) -> () )
    {
        if taxes.count > 100
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : USER ID must not be nil, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError(code: ErrorCode.maxCountExceeded, message: ErrorMessage.apiMaxRecordsMsg, details: nil) ) )
            return
        }
        
        setJSONRootKey(key: JSONRootKey.TAXES)
        var reqBodyObj : [ String : [[ String : Any ]] ] = [ String : [[ String : Any ]] ]()
        var dataArray : [ [ String : Any ] ] = [ [ String : Any ] ]()
        for tax in taxes
        {
            dataArray.append( self.getZCRMTaxAsJSON(tax: tax) )
        }
        reqBodyObj[ getJSONRootKey() ] = dataArray
 
        setUrlPath(urlPath: "\( URLPathConstants.org )/\( URLPathConstants.taxes )")
        setRequestMethod(requestMethod: .patch)
        setRequestBody(requestBody: reqBodyObj)
 
        let request : APIRequest = APIRequest(handler: self)
        print( "Request : \(request.toString())" )
        request.getBulkAPIResponse { ( resultType ) in
            do
            {
                switch resultType
                {
                case .success(let response) :
                    let responses : [ EntityResponse ] = response.getEntityResponses()
                    for ( index, entityResponse ) in responses.enumerated()
                    {
                        if APIConstants.CODE_SUCCESS == entityResponse.getStatus()
                        {
                            let entityResponseJSON : [ String : Any ] = entityResponse.getResponseJSON()
                            let taxJSON :[ String : Any ] = try entityResponseJSON.getDictionary(key: APIConstants.DETAILS)
                            if taxJSON.isEmpty == true
                            {
                                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.responseNil) : \(ErrorMessage.responseJSONNilMsg), \( APIConstants.DETAILS ) : -, Response : \( entityResponse )")
                            }
                            else
                            {
                                if taxJSON.hasValue(forKey: ResponseJSONKeys.id), let id = taxJSON[ "id" ] , let taxId = Int64( "\( id )" )
                                {
                                    taxes[ index ].id = taxId
                                    taxes[ index ].displayName = "\( taxes[ index ].name ) - \( taxes[ index ].percentage ) %"
                                }
                            }
                        }
                    }
                    response.setData( data : taxes )
                    completion( .success( taxes, response ) )
                case .failure(let error) :
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
            catch
            {
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
 
    internal func deleteTax( withId : Int64, completion : @escaping( Result.Response< APIResponse > ) -> Void )
    {
        setJSONRootKey(key: JSONRootKey.TAXES)
        setUrlPath(urlPath: "\( URLPathConstants.org )/\( URLPathConstants.taxes )/\( withId )" )
        setRequestMethod(requestMethod: .delete )
        let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
        request.getAPIResponse { ( resultType ) in
            switch resultType
            {
            case .success(let response) :
                completion( .success( response ) )
            case .failure(let error) :
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
 
    internal func deleteTaxes( ids : [ Int64 ], completion : @escaping( Result.Response< BulkAPIResponse > ) -> () )
    {
        if ids.count > 100
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.mandatoryNotFound) : USER ID must not be nil, \( APIConstants.DETAILS ) : -")
            completion( .failure( ZCRMError.processingError(code: ErrorCode.maxCountExceeded, message: ErrorMessage.apiMaxRecordsMsg, details: nil) ) )
            return
        }
        
        setJSONRootKey(key: JSONRootKey.TAXES)
        let idsString : String = ids.map{ String( $0 ) }.joined(separator: ",")
        
        setUrlPath(urlPath: "\( URLPathConstants.org )/\( URLPathConstants.taxes )")
        addRequestParam(param: RequestParamKeys.ids, value: idsString)
        setRequestMethod(requestMethod: .delete)
 
        let request : APIRequest = APIRequest( handler: self )
        print( "Request : \( request.toString() )" )
 
        request.getBulkAPIResponse { ( resultType ) in
            do{
                switch resultType
                {
                case .success(let response) :
                    
                    let responses : [ EntityResponse ] = response.getEntityResponses()
                    var deletedTaxes : [ ZCRMTax ] = [ ZCRMTax ]()
                    for entityResponse in responses
                    {
                        if APIConstants.CODE_SUCCESS == entityResponse.getStatus()
                        {
                            let entityResponseJSON : [ String : Any ] = entityResponse.getResponseJSON()
                            let taxJSON : [ String : Any ] = try entityResponseJSON.getDictionary(key: APIConstants.DETAILS)
                            if taxJSON.isEmpty == true
                            {
                                ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.responseNil) : \(ErrorMessage.responseJSONNilMsg), \( APIConstants.DETAILS ) : -, Response : \( entityResponse )")
                            }
                            else
                            {
                                do
                                {
                                    let tax : ZCRMTax = try ZCRMTax( id : taxJSON.getInt64(key: ResponseJSONKeys.id) )
                                    deletedTaxes.append( tax )
                                }
                                catch
                                {
                                    ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \( APIConstants.DETAILS ) : \( error ), Response : \( response )")
                                }
                            }
                        }
                    }
                    response.setData(data: deletedTaxes)
                    completion( .success( response ) )
                case .failure(let error) :
                    completion( .failure( typeCastToZCRMError( error ) ) )
                }
            }
            catch{
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
 
    private func getZCRMOrgTax( taxDetails : [ String : Any ] ) throws -> ZCRMTax
    {
        let tax : ZCRMTax = try ZCRMTax(id: taxDetails.getInt64(key: ResponseJSONKeys.id), name: taxDetails.getString(key: ResponseJSONKeys.name))
        tax.id = try taxDetails.getInt64(key: ResponseJSONKeys.id)
        tax.percentage = try taxDetails.getDouble(key: ResponseJSONKeys.value)
        if taxDetails.hasValue(forKey: ResponseJSONKeys.displayLabel)
        {
            tax.displayName = try taxDetails.getString(key: ResponseJSONKeys.displayLabel)
        }
        return tax
    }
 
    private func getZCRMTaxAsJSON( tax : ZCRMTax ) -> [ String : Any ]
    {
        var taxJSON : [ String : Any ] = [ String : Any ]()
        taxJSON.updateValue( tax.name , forKey: ResponseJSONKeys.name )
        taxJSON.updateValue( tax.percentage , forKey: ResponseJSONKeys.value )
        if tax.id != APIConstants.INT64_MOCK
        {
            taxJSON.updateValue( tax.id , forKey: ResponseJSONKeys.id )
        }
        if tax.displayName != APIConstants.STRING_MOCK
        {
            taxJSON.updateValue( tax.displayName , forKey: ResponseJSONKeys.displayLabel )
        }
        return taxJSON
    }
 
}

fileprivate extension TaxAPIHandler
{
    struct RequestParamKeys {
        static let ids = "ids"
    }
    struct ResponseJSONKeys
    {
        static let id = "id"
        static let name = "name"
        static let displayLabel = "display_label"
        static let value = "value"
        static let sequenceNumber = "sequence_number"
    }
    
    struct URLPathConstants {
        static let org = "org"
        static let taxes = "taxes"
    }
}
