//
//  PipelineAPIHandler.swift
//  ZCRMiOS
//
//  Created by test on 15/02/24.
//

import Foundation

internal class PipelineAPIHandler : CommonAPIHandler
{
    internal var cache : ZCRMCacheFlavour
    
    init( cache : ZCRMCacheFlavour )
    {
        self.cache = cache
    }
    
    override func setModuleName() {
        self.requestedModule = "pipeline"
    }
    
    func getPipelines( layoutId : Int64, requestHeaders : [ String : String ]? = nil, completion : @escaping( ZCRMResult.DataResponse< [ ZCRMPipeline ], BulkAPIResponse > ) -> () )
    {
        setIsCacheable( ( requestHeaders ?? [:] ).hasValue(forKey: X_CRM_ORG ) ? false : true )
        setJSONRootKey( key : JSONRootKey.PIPELINE )
        setUrlPath( urlPath :  "\( URLPathConstants.settings )/\( URLPathConstants.pipeline )" )
        addRequestParam( param : RequestParamKeys.layoutId, value : String( layoutId ) )
        setRequestMethod( requestMethod : .get )
        
        for ( key, value ) in requestHeaders ?? [:]
        {
            addRequestHeader(header: key, value: value)
        }
        let request : APIRequest = APIRequest( handler : self, cacheFlavour : cache, dbType: .metaData )
        ZCRMLogger.logDebug( message : "Request : \( request.toString() )" )
        
        request.getAPIResponse { ( resultType ) in
            do{
                let response = try resultType.resolve()
                let responseJSON : [ String :  Any ] = response.responseJSON
                let pipelinesArray = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                var pipelinesJSON : [ String : Any ] = [ String : Any ]()
                pipelinesJSON[ JSONRootKey.PIPELINE ] = try pipelinesArray[ 0 ].getArrayOfDictionaries( key : ResponseJSONKeys.pickListValues )
                let bulkResponse : BulkAPIResponse = try BulkAPIResponse( responseJSON : pipelinesJSON, responseJSONRootKey : JSONRootKey.PIPELINE, requestAPIName: "pipeline"  )
                if pipelinesJSON.isEmpty
                {
                    ZCRMLogger.logError(message: "\(ZCRMErrorCode.responseNil) : \(ZCRMErrorMessage.responseJSONNilMsg), \( APIConstants.DETAILS ) : -")
                    completion( .failure( ZCRMError.sdkError( code : ZCRMErrorCode.responseNil, message : ZCRMErrorMessage.responseJSONNilMsg, details : nil ) ) )
                    return
                }
                let pipelines = try self.getZCRMPipelines( pipelinesDetails : pipelinesJSON.getArrayOfDictionaries( key : JSONRootKey.PIPELINE ) )
                bulkResponse.setData( data : pipelines )
                completion( .success( pipelines, bulkResponse ) )
            }
            catch{
                ZCRMLogger.logError( message : "\( error )" )
                completion( .failure( typeCastToZCRMError( error ) ) )
            }
        }
    }
    
    private func getZCRMPipelines( pipelinesDetails : [ [ String : Any ] ] ) throws -> [ ZCRMPipeline ]
    {
        var pipelines : [ ZCRMPipeline ] = [ ZCRMPipeline ]()
        for pipelineDetails in pipelinesDetails
        {
            let pipeline = try self.getZCRMPipeline( pipelineDetails : pipelineDetails )
            pipelines.append( pipeline )
        }
        return pipelines
    }
    
    private func getZCRMPipeline( pipelineDetails : [ String : Any ] ) throws -> ZCRMPipeline
    {
        let pipeline : ZCRMPipeline = ZCRMPipeline( id : try pipelineDetails.getInt64( key : ResponseJSONKeys.id ) )
        pipeline.displayName = try pipelineDetails.getString( key : ResponseJSONKeys.displayValue )
        if pipelineDetails.hasValue( forKey : ResponseJSONKeys.defaultString )
        {
            pipeline.isDefault = try pipelineDetails.getBoolean( key : ResponseJSONKeys.defaultString )
        }
        pipeline.actualName = try pipelineDetails.getString( key : ResponseJSONKeys.actualValue )
        let stagesDetails : [ [ String : Any ] ] = try pipelineDetails.getArrayOfDictionaries( key : ResponseJSONKeys.maps )
        var stages : [ ZCRMDealStage ] = [ ZCRMDealStage ]()
        for stageDetails in stagesDetails
        {
            let stage : ZCRMDealStage = try self.getZCRMDealStage( stageDetails : stageDetails )
            stages.append( stage )
        }
        pipeline.stages = stages
        return pipeline
    }
    
    internal func getZCRMDealStage( stageDetails : [ String : Any ] ) throws -> ZCRMDealStage
    {
        let stage : ZCRMDealStage = ZCRMDealStage( id : try stageDetails.getInt64( key : ResponseJSONKeys.id ) )
        stage.forecastCategory = try stageDetails.getDictionary( key : ResponseJSONKeys.forecastCategory ).getString( key : ResponseJSONKeys.name )
        return try getZDealStage(dealStage: stage, stageDetails: stageDetails)
    }
    
    private func getZDealStage< T : ZDealStage >( dealStage : T, stageDetails : [ String : Any ] ) throws -> T
    {
        var dealStage : T = dealStage
        if let displayLabel = stageDetails.optString(key: ResponseJSONKeys.displayLabel)
        {
            dealStage.displayName = displayLabel
        }
        else if let name = stageDetails.optString( key : ResponseJSONKeys.displayValue )
        {
            dealStage.displayName = name
        }
        else
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.valueNil) : \( ResponseJSONKeys.displayLabel ) must not be nil, \( APIConstants.DETAILS ) : -")
            throw ZCRMError.inValidError( code : ZCRMErrorCode.valueNil, message : "\( ResponseJSONKeys.displayLabel ) must not be nil", details : nil )
        }
        if let actualValue = stageDetails.optString( key : ResponseJSONKeys.name )
        {
            dealStage.actualName = actualValue
        }
        else if let actualValue = stageDetails.optString( key : ResponseJSONKeys.actualValue )
        {
            dealStage.actualName = actualValue
        }
        else
        {
            ZCRMLogger.logError(message: "\(ZCRMErrorCode.valueNil) : \( ResponseJSONKeys.actualValue ) must not be nil, \( APIConstants.DETAILS ) : -")
            throw ZCRMError.inValidError( code : ZCRMErrorCode.valueNil, message : "\( ResponseJSONKeys.actualValue ) must not be nil", details : nil )
        }
        dealStage.probability = stageDetails.optInt( key : ResponseJSONKeys.probability )
        dealStage.forecastType = stageDetails.optString( key : ResponseJSONKeys.forecastType )
        dealStage.sequenceNumber = stageDetails.optInt( key : ResponseJSONKeys.sequenceNumber )
        return dealStage
    }
    
    struct ResponseJSONKeys {
        static let pickListValues : String = "pick_list_values"
        static let id : String = "id"
        static let displayValue : String = "display_value"
        static let defaultString : String = "default"
        static let maps : String = "maps"
        static let actualValue : String = "actual_value"
        static let probability = "probability"
        static let forecastCategory = "forecast_category"
        static let forecastType = "forecast_type"
        static let displayLabel = "display_label"
        static let name = "name"
        static let sequenceNumber = "sequence_number"
    }
    
    struct URLPathConstants {
        static let settings = "settings"
        static let pipeline = "pipeline"
    }
}
