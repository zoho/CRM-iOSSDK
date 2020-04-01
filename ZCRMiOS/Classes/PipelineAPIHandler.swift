//
//  PipelineAPIHandler.swift
//  ZCRMiOS
//
//  Created by Umashri R on 24/05/19.
//

internal class PipelineAPIHandler : CommonAPIHandler
{
    private var cache : CacheFlavour
    
    init( cache : CacheFlavour )
    {
        self.cache = cache
    }
    
    override func setModuleName() {
        self.requestedModule = "pipeline"
    }
    
    func getPipelines( layoutId : Int64, completion : @escaping( Result.DataResponse< [ ZCRMPipeline ], BulkAPIResponse > ) -> () )
    {
        setIsCacheable( true )
        setJSONRootKey( key : JSONRootKey.PIPELINE )
        setUrlPath( urlPath :  "\( URLPathConstants.settings )/\( URLPathConstants.pipeline )" )
        addRequestParam( param : RequestParamKeys.layoutId, value : String( layoutId ) )
        setRequestMethod( requestMethod : .get )
        let request : APIRequest = APIRequest( handler : self, cacheFlavour : cache )
        ZCRMLogger.logDebug( message : "Request : \( request.toString() )" )
        
        request.getAPIResponse { ( resultType ) in
            do{
                let response = try resultType.resolve()
                let responseJSON : [ String :  Any ] = response.responseJSON
                let pipelinesArray = try responseJSON.getArrayOfDictionaries( key : self.getJSONRootKey() )
                var pipelinesJSON : [ String : Any ] = [ String : Any ]()
                pipelinesJSON[ JSONRootKey.PIPELINE ] = try pipelinesArray[ 0 ].getArrayOfDictionaries( key : ResponseJSONKeys.pickListValues )
                let bulkResponse : BulkAPIResponse = try BulkAPIResponse( responseJSON : pipelinesJSON, responseJSONRootKey : JSONRootKey.PIPELINE, requestAPIName: "pipeline"  )
                if pipelinesJSON.isEmpty == true
                {
                    ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.responseNil) : \(ErrorMessage.responseJSONNilMsg), \( APIConstants.DETAILS ) : -")
                    completion( .failure( ZCRMError.sdkError( code : ErrorCode.responseNil, message : ErrorMessage.responseJSONNilMsg, details : nil ) ) )
                    return
                }
                let pipelines = try self.getZCRMPipelines( pipelinesDetails : pipelinesJSON.getArrayOfDictionaries( key : JSONRootKey.PIPELINE ) )
                bulkResponse.setData( data : pipelines )
                completion( .success( pipelines, bulkResponse ) )
            }
            catch{
                ZCRMLogger.logError( message : "ZCRM SDK - Error Occurred : \( error )" )
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
        if let displayLabel = stageDetails.optString(key: ResponseJSONKeys.displayLabel)
        {
            stage.displayName = displayLabel
        }
        else if let name = stageDetails.optString( key : ResponseJSONKeys.displayValue )
        {
            stage.displayName = name
        }
        else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.valueNil) : \( ResponseJSONKeys.displayLabel ) must not be nil, \( APIConstants.DETAILS ) : -")
            throw ZCRMError.inValidError( code : ErrorCode.valueNil, message : "\( ResponseJSONKeys.displayLabel ) must not be nil", details : nil )
        }
        stage.forecastCategory = try stageDetails.getDictionary( key : ResponseJSONKeys.forecastCategory ).getString( key : ResponseJSONKeys.name )
        if let actualValue = stageDetails.optString( key : ResponseJSONKeys.name )
        {
            stage.actualName = actualValue
        }
        else if let actualValue = stageDetails.optString( key : ResponseJSONKeys.actualValue )
        {
            stage.actualName = actualValue
        }
        else
        {
            ZCRMLogger.logError(message: "ZCRM SDK - Error Occurred : \(ErrorCode.valueNil) : \( ResponseJSONKeys.actualValue ) must not be nil, \( APIConstants.DETAILS ) : -")
            throw ZCRMError.inValidError( code : ErrorCode.valueNil, message : "\( ResponseJSONKeys.actualValue ) must not be nil", details : nil )
        }
        stage.probability = stageDetails.optInt( key : ResponseJSONKeys.probability )
        stage.forecastType = stageDetails.optString( key : ResponseJSONKeys.forecastType )
        stage.sequenceNumber = stageDetails.optInt( key : ResponseJSONKeys.sequenceNumber )
        return stage
    }
}

extension PipelineAPIHandler
{
    struct ResponseJSONKeys
    {
        static let pickListValues : String = "pick_list_values"
        static let displayValue : String = "display_value"
        static let defaultString : String = "default"
        static let maps : String = "maps"
        static let actualValue : String = "actual_value"
        static let id : String = "id"
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

extension RequestParamKeys
{
    static let layoutId : String = "layout_id"
}
