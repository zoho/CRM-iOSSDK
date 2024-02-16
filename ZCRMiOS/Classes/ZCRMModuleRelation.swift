//
//  ZCRMModuleRelation.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 14/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

public class ZCRMModuleRelationDelegate : ZCRMEntity, Hashable
{
    public internal( set ) var id : Int64 = APIConstants.INT64_MOCK
    public internal( set ) var apiName : String = APIConstants.STRING_MOCK
    public internal( set ) var label : String = APIConstants.STRING_MOCK
    
    public static func == (lhs: ZCRMModuleRelationDelegate, rhs: ZCRMModuleRelationDelegate) -> Bool {
        return lhs.id == rhs.id &&
            lhs.apiName == rhs.apiName &&
            lhs.label == rhs.label
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine( id )
    }
    
    public func copy() -> ZCRMModuleRelationDelegate {
        let moduleRelationDelegate = ZCRMModuleRelationDelegate()
        moduleRelationDelegate.id = id
        moduleRelationDelegate.apiName = apiName
        moduleRelationDelegate.label = label
        return moduleRelationDelegate
    }
    
}

public class ZCRMModuleRelation : ZCRMModuleRelationDelegate
{
	var parentModuleAPIName : String = APIConstants.STRING_MOCK
	public internal( set ) var isVisible : Bool = APIConstants.BOOL_MOCK
	public internal( set ) var isDefault : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var name : String = APIConstants.STRING_MOCK
    public internal( set ) var type : String = APIConstants.STRING_MOCK
    public internal( set ) var linkingModule : ZCRMModuleDelegate?
    public internal( set ) var action : String?
    public internal( set ) var sequenceNo : Int = APIConstants.INT_MOCK
    public internal( set ) var connectedModule : ZCRMModuleDelegate?
    internal var pipelineData : [ [ String : Any ] ] = []

    
    /// Initialize the instance of a ZCRMModuleRelation with the given module and related list
    ///
    /// - Parameters:
    ///   - relatedListAPIName: relatedListAPIName whose instance to be initialized
    ///   - parentModuleAPIName: parentModuleAPIName to get that module's relation
    internal init( relatedListAPIName : String, parentModuleAPIName : String )
    {
        super.init()
        self.apiName = relatedListAPIName
        self.parentModuleAPIName = parentModuleAPIName
    }
    
    internal init( parentModuleAPIName : String, relatedListId : Int64 )
    {
        super.init()
        self.parentModuleAPIName = parentModuleAPIName
        self.id = relatedListId
    }
    
    public func getJunctionRecord( recordId : Int64 ) -> ZCRMJunctionRecord
    {
        return ZCRMJunctionRecord( apiName : apiName, id : recordId )
    }
    
    /// Returns list of all records of the module of a requested page number with records of per_page count, before returning the list of records gets sorted with the given field and sort order(BulkAPIResponse).
    ///
    /// - Parameters:
    ///   - ofParentRecord: list of records of the module
    ///   - recordParams: Params to be included in fetching the records
    /// - Returns: sorted list of module of the ZCRMRecord
    /// - Throws: ZCRMSDKError if falied to get related records
    public func getRelatedRecords( ofParentRecord : ZCRMRecordDelegate, recordParams : ZCRMQuery.GetRecordParams, completion : @escaping( ZCRMResult.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> ())
	{
        do
        {
            try relatedModuleCheck( module : self.apiName )
            RelatedListAPIHandler( parentRecord : ofParentRecord, relatedList : self ).getRecords( recordParams : recordParams, pipelineId: nil ) { ( result ) in
                completion( result )
            }
        }
        catch
        {
            completion( .failure( typeCastToZCRMError( error ) ) )
        }
	}
    
    public override func copy() -> ZCRMModuleRelation {
        let moduleRelation = ZCRMModuleRelation(relatedListAPIName: apiName, parentModuleAPIName: parentModuleAPIName)
        moduleRelation.id = id
        moduleRelation.apiName = apiName
        moduleRelation.isVisible = isVisible
        moduleRelation.isDefault = isDefault
        moduleRelation.name = name
        moduleRelation.type = type
        moduleRelation.linkingModule = linkingModule?.copy()
        moduleRelation.action = action
        moduleRelation.sequenceNo = sequenceNo
        moduleRelation.connectedModule = connectedModule?.copy()
        moduleRelation.pipelineData = pipelineData
        return moduleRelation
    }
}

extension ZCRMModuleRelation
{
    public static func == (lhs: ZCRMModuleRelation, rhs: ZCRMModuleRelation) -> Bool {
        let equals : Bool = lhs.apiName == rhs.apiName &&
            lhs.parentModuleAPIName == rhs.parentModuleAPIName &&
            lhs.label == rhs.label &&
            lhs.id == rhs.id &&
            lhs.isVisible == rhs.isVisible &&
            lhs.name == rhs.name &&
            lhs.type == rhs.type &&
            lhs.linkingModule == rhs.linkingModule &&
            lhs.action == rhs.action &&
            lhs.sequenceNo == rhs.sequenceNo &&
            lhs.connectedModule == rhs.connectedModule
        return equals
    }
}
