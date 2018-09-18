//
//  TaxAPIHandler.swift
//  ZCRMiOS
//
//  Created by Umashri R on 06/09/18.
//
/*
import Foundation

internal class TaxAPIHandler : CommonAPIHandler
{
    internal func getAllTaxes( completion : @escaping( Result.DataResponse< [ ZCRMOrgTax ], BulkAPIResponse > ) -> () )
    {
        var taxes : [ ZCRMOrgTax ] = [ ZCRMOrgTax ]()
        
        setJSONRootKey(key: JSONRootKey.TAXES)
        setUrlPath(urlPath: "/org/taxes")
        setRequestMethod(requestMethod: .GET)
        
        let request : APIRequest = APIRequest( handler: self )
        print( "Request : \( request.toString() )" )
        
        request.getBulkAPIResponse(completion: { ( resultType ) in
            do
            {
                let bulkResponse = try resultType.resolve()
                let responseJSON = bulkResponse.getResponseJSON()
                if responseJSON.isEmpty == false
                {
                    let taxesList:[[String:Any]] = responseJSON.getArrayOfDictionaries(key: self.getJSONRootKey())
                    for taxDetails in taxesList
                    {
                       taxes.append(self.getZCRMOrgTax(taxDetails: taxDetails))
                    }
                    bulkResponse.setData(data: taxes)
                }
                completion( .success( taxes, bulkResponse ) )
            }
            catch{
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        } )
    }
    
    internal func getTax( taxId : Int64, completion : @escaping( Result.DataResponse< ZCRMOrgTax, APIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.TAXES )
        setUrlPath(urlPath: "/org/taxes/\(taxId)")
        setRequestMethod(requestMethod: .GET)
        
        let request = APIRequest(handler: self)
        print( "Request : \(request.toString())" )
        
        request.getAPIResponse { ( resultType ) in
            do
            {
                let response = try resultType.resolve()
                let responseJSON : [String:Any] = response.getResponseJSON()
                let taxesList : [[String:Any]] = responseJSON.getArrayOfDictionaries(key: self.getJSONRootKey())
                let tax = self.getZCRMOrgTax(taxDetails: taxesList[0])
                response.setData(data: tax )
                completion( .success( tax, response ))
            }
            catch
            {
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func createTaxes( taxes : [ ZCRMOrgTax ], completion : @escaping( Result.DataResponse< [ ZCRMOrgTax ], BulkAPIResponse > ) -> () )
    {
        setJSONRootKey( key : JSONRootKey.TAXES )
        var reqBodyObj : [String:[[String:Any]]] = [String:[[String:Any]]]()
        var dataArray : [[String:Any]] = [[String:Any]]()
        for tax in taxes
        {
            if ( tax.getName() != nil)
            {
                dataArray.append( self.getZCRMOrgTaxAsJSON(tax: tax) as Any as! [String:Any] )
            }
        }
        reqBodyObj[getJSONRootKey()] = dataArray
        
        setUrlPath(urlPath: "/org/taxes")
        setRequestMethod(requestMethod: .POST)
        setRequestBody(requestBody: reqBodyObj)
        
        let request : APIRequest = APIRequest( handler: self )
        print( "Request : \( request.toString() )" )
        
        request.getBulkAPIResponse { ( resultType ) in
            do{
                let bulkResponse = try resultType.resolve()
                let responses : [EntityResponse] = bulkResponse.getEntityResponses()
                var createdTaxes : [ZCRMOrgTax] = [ZCRMOrgTax]()
                for entityResponse in responses
                {
                    if(CODE_SUCCESS == entityResponse.getStatus())
                    {
                        let entResponseJSON : [String:Any] = entityResponse.getResponseJSON()
                        let taxJSON : [String:Any] = entResponseJSON.getDictionary(key: DETAILS)
                        let tax : ZCRMOrgTax = self.getZCRMOrgTax(taxDetails: taxJSON)
                        createdTaxes.append(tax)
                        entityResponse.setData(data: tax)
                    }
                    else
                    {
                        entityResponse.setData(data: nil)
                    }
                }
                bulkResponse.setData( data : createdTaxes )
                completion( .success( createdTaxes, bulkResponse ) )
            }
            catch{
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func updateTaxes( taxes : [ ZCRMOrgTax ], completion : @escaping( Result.DataResponse< [ ZCRMOrgTax ], BulkAPIResponse > ) -> () )
    {
        setJSONRootKey(key: JSONRootKey.TAXES)
        var reqBodyObj : [String:[[String:Any]]] = [String:[[String:Any]]]()
        var dataArray : [[String:Any]] = [[String:Any]]()
        for tax in taxes
        {
            if ( tax.getId() != nil )
            {
                dataArray.append( self.getZCRMOrgTaxAsJSON(tax: tax) as Any as! [String:Any] )
            }
        }
        reqBodyObj[getJSONRootKey()] = dataArray
        
        setUrlPath(urlPath: "/org/taxes")
        setRequestMethod(requestMethod: .PUT)
        setRequestBody(requestBody: reqBodyObj)
        
        let request : APIRequest = APIRequest(handler: self)
        print( "Request : \(request.toString())" )
        request.getBulkAPIResponse { ( resultType ) in
            do{
                let bulkResponse = try resultType.resolve()
                let responses : [EntityResponse] = bulkResponse.getEntityResponses()
                var updatedTaxes : [ZCRMOrgTax] = [ZCRMOrgTax]()
                for entityResponse in responses
                {
                    if(CODE_SUCCESS == entityResponse.getStatus())
                    {
                        let entResponseJSON : [String:Any] = entityResponse.getResponseJSON()
                        let taxJSON :[String:Any] = entResponseJSON.getDictionary(key: DETAILS)
                        let tax : ZCRMOrgTax = self.getZCRMOrgTax(taxDetails: taxJSON)
                        updatedTaxes.append(tax)
                        entityResponse.setData(data: tax)
                    }
                    else
                    {
                        entityResponse.setData(data: nil)
                    }
                }
                bulkResponse.setData( data : updatedTaxes )
                completion( .success( updatedTaxes, bulkResponse ) )
            }
            catch{
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func deleteTax( taxId : Int64, completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        setJSONRootKey(key: JSONRootKey.TAXES)
        let idString = String(taxId)
        setUrlPath(urlPath: "/org/taxes/\(idString)" )
        setRequestMethod(requestMethod: .DELETE )
        let request : APIRequest = APIRequest(handler: self)
        print( "Request : \( request.toString() )" )
        request.getAPIResponse { ( resultType ) in
            do{
                let response = try resultType.resolve()
                completion( .success( response ) )
            }
            catch{
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func deleteTaxes( ids : [ Int64 ], completion : @escaping( Result.Response< BulkAPIResponse > ) -> () )
    {
        setJSONRootKey(key: JSONRootKey.TAXES)
        var idsString : String = String()
        for index in 0..<ids.count
        {
            idsString.append( String(ids[ index ]) )
            if ( index != ( ids.count - 1 ) )
            {
                idsString.append(",")
            }
        }
        setUrlPath(urlPath: "/org/taxes")
        addRequestParam(param: RequestParamKeys.ids, value: idsString)
        setRequestMethod(requestMethod: .DELETE)
        
        let request : APIRequest = APIRequest( handler: self )
        print( "Request : \( request.toString() )" )
        
        request.getBulkAPIResponse { ( resultType ) in
            do{
                let bulkResponse = try resultType.resolve()
                let responses : [EntityResponse] = bulkResponse.getEntityResponses()
                for entityResponse in responses
                {
                    let entResponseJSON : [String:Any] = entityResponse.getResponseJSON()
                    let taxJSON : [String:Any] = entResponseJSON.getDictionary(key: DETAILS)
                    let tax : ZCRMOrgTax = self.getZCRMOrgTax(taxDetails: taxJSON)
                    entityResponse.setData(data: tax)
                }
                completion( .success( bulkResponse ) )
            }
            catch{
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    internal func getZCRMOrgTax( taxDetails : [ String : Any? ] ) -> ZCRMOrgTax
    {
        let tax : ZCRMOrgTax = ZCRMOrgTax()
        tax.setId(id: taxDetails.optInt64(key: ResponseJSONKeys.id))
        tax.setName(name: taxDetails.optString(key: ResponseJSONKeys.name))
        tax.setDisplayLabel(displayLabel: taxDetails.optString(key: ResponseJSONKeys.displayLabel))
        tax.setValue(value: taxDetails.optDouble(key: ResponseJSONKeys.value))
        tax.setSequenceNumber(sequenceNumber: taxDetails.optInt(key: ResponseJSONKeys.sequenceNumber))
        return tax
    }
    
    internal func getZCRMOrgTaxAsJSON( tax : ZCRMOrgTax ) -> [ String : Any? ]
    {
        var taxJSON : [ String : Any? ] = [ String : Any? ]()
        if let id = tax.getId()
        {
            taxJSON[ ResponseJSONKeys.id ] = id
        }
        if let name = tax.getName()
        {
            taxJSON[ ResponseJSONKeys.name ] = name
        }
        if let displayLabel = tax.getDisplayLabel()
        {
            taxJSON[ ResponseJSONKeys.displayLabel ] = displayLabel
        }
        if let value = tax.getValue()
        {
            taxJSON[ ResponseJSONKeys.value ] = value
        }
        if let sequenceNumber = tax.getSequenceNumber()
        {
            taxJSON[ ResponseJSONKeys.sequenceNumber ] = sequenceNumber
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
}
 */
