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
}

public class ZCRMModuleRelation : ZCRMModuleRelationDelegate
{
	var parentModuleAPIName : String = APIConstants.STRING_MOCK
	public internal( set ) var isVisible : Bool = APIConstants.BOOL_MOCK
	public internal( set ) var isDefault : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var name : String = APIConstants.STRING_MOCK
    public internal( set ) var type : String = APIConstants.STRING_MOCK
    public internal( set ) var module : String?
    public internal( set ) var action : String?
    public internal( set ) var sequenceNo : Int = APIConstants.INT_MOCK
    public internal( set ) var href : String?

    
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
    public func getRelatedRecords( ofParentRecord : ZCRMRecordDelegate, recordParams : ZCRMQuery.GetRecordParams, completion : @escaping( Result.DataResponse< [ ZCRMRecord ], BulkAPIResponse > ) -> ())
	{
        do
        {
            try relatedModuleCheck( module : self.apiName )
            RelatedListAPIHandler( parentRecord : ofParentRecord, relatedList : self ).getRecords( recordParams : recordParams ) { ( result ) in
                completion( result )
            }
        }
        catch
        {
            completion( .failure( typeCastToZCRMError( error ) ) )
        }
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
            lhs.module == rhs.module &&
            lhs.action == rhs.action &&
            lhs.href == rhs.href &&
            lhs.sequenceNo == rhs.sequenceNo
        return equals
    }
}
