//
//  ZCRMModule.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 14/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

open class ZCRMModule : ZCRMModuleDelegate
{
    public internal( set ) var singularLabel : String
    public internal( set ) var pluralLabel : String
    public internal( set ) var id : Int64 = APIConstants.INT64_MOCK
    public internal( set ) var name : String = APIConstants.STRING_MOCK
    
    public internal( set ) var isCreatable : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var isViewable : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var isConvertible : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var isEditable : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var isDeletable : Bool = APIConstants.BOOL_MOCK
    
    public internal( set ) var modifiedBy : ZCRMUserDelegate?
    public internal( set ) var modifiedTime : String?
    
    public internal( set ) var accessibleProfiles : [ZCRMProfileDelegate]?
    public internal( set ) var relatedLists : [ZCRMModuleRelation]?

    
    public internal( set ) var isGlobalSearchSupported : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var isVisible : Bool?
    public internal( set ) var visibility : Int = APIConstants.INT_MOCK
    public internal( set ) var isAPISupported : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var isQuickCreateAvailable : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var isScoringSupported : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var sequenceNumber : Int?
    public internal( set ) var generatedType : String = APIConstants.STRING_MOCK
    public internal( set ) var businessCardFieldLimit : Int?
    public internal( set ) var webLink : String?
    
    public internal( set ) var arguments : [ [ String : Any ] ]?
    
    public internal( set ) var displayField : String?
    public internal( set ) var searchLayoutFields : [ String ]?
    public internal( set ) var parentModule : ZCRMModuleDelegate?
    public internal( set ) var customView : ZCRMCustomView?
    
    public internal( set ) var isKanbanViewEnabled : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var filterStatus : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var isSubMenuPresent : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var perPage : Int?
    public internal( set ) var isFilterSupported : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var isFeedsRequired : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var isEmailTemplateSupported : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var properties : [ String ]?
    internal var internalBusinessCardFields : [ String ]?
    internal var fields : [ Int64 : ZCRMField ]?
    
    internal init( apiName : String, singularLabel : String, pluralLabel : String )
    {
        self.singularLabel = singularLabel
        self.pluralLabel = pluralLabel
        super.init( apiName : apiName )
	}
    
    func addAccessibleProfiles( profile : ZCRMProfileDelegate )
    {
        if self.accessibleProfiles == nil
        {
            self.accessibleProfiles = [ ZCRMProfileDelegate ]()
        }
        self.accessibleProfiles?.append( profile )
    }
    
    func addRelatedList( relatedList : ZCRMModuleRelation )
    {
        if self.relatedLists == nil
        {
            self.relatedLists = [ ZCRMModuleRelation ]()
        }
        self.relatedLists?.append( relatedList )
    }
    
    /**
      Returns list of ZCRMFields of the module
     
     - Parameters:
        - completion :
            - Success : Returns an array of ZCRMField objects and a BulkAPIResponse
            - Failure : Returns Error
     */
    override public func getFields( completion : @escaping( ZCRMResult.DataResponse< [ ZCRMField ], BulkAPIResponse > ) -> () )
    {
        if let fields = fields
        {
            completion( .success( Array( fields.values ), BulkAPIResponse()) )
        }
        else
        {
            ModuleAPIHandler( module : self, cacheFlavour : .noCache ).getAllFields( modifiedSince : nil ) { ( result ) in
                if case .success( let fields, _) = result
                {
                    self.fields = fields.reduce( [ Int64 : ZCRMField ](), { dict, field in
                        var fieldsMap = dict
                        fieldsMap.updateValue( field, forKey: field.id )
                        return fieldsMap
                    })
                }
                completion( result )
            }
        }
    }
    
    /**
      To get the details of the field in a module by it's Id from DB.
     
     - Parameters:
        - id : Id of the field whose details to be fetched
        - completion:
            - Success : Returns a ZCRMField object and an APIResponse
            - Failure : Returns Error
     */
    override public func getField( id : Int64, completion : @escaping( ZCRMResult.DataResponse< ZCRMField, APIResponse > ) -> () )
    {
        if let fields = fields
        {
            if let field = fields[ id ]
            {
                completion( .success( field, APIResponse()) )
            }
            else
            {
                ZCRMLogger.logError(message: "\( ZCRMErrorCode.invalidData ) : \( ZCRMErrorMessage.invalidIdMsg ), \( APIConstants.DETAILS ) : \("-")")
                completion( .failure( ZCRMError.processingError(code: ZCRMErrorCode.invalidData, message: ZCRMErrorMessage.invalidIdMsg, details: nil)) )
            }
        }
        else
        {
            ModuleAPIHandler(module: self, cacheFlavour: .noCache).getField(fieldId: id) { ( result ) in
                completion( result )
            }
        }
    }
    
    public override func copy() -> ZCRMModule {
        
        let module = ZCRMModule(apiName: apiName, singularLabel: singularLabel, pluralLabel: pluralLabel)
        module.id = id
        module.name = name
        module.isCreatable = isCreatable
        module.isViewable = isViewable
        module.isConvertible = isConvertible
        module.isEditable = isEditable
        module.isDeletable = isDeletable
        module.modifiedBy = modifiedBy?.copy()
        module.modifiedTime = modifiedTime
        module.accessibleProfiles = accessibleProfiles?.copy()
        module.relatedLists = relatedLists?.copy()
        module.isGlobalSearchSupported = isGlobalSearchSupported
        module.isVisible = isVisible
        module.visibility = visibility
        module.isAPISupported = isAPISupported
        module.isQuickCreateAvailable = isQuickCreateAvailable
        module.isScoringSupported = isScoringSupported
        module.sequenceNumber = sequenceNumber
        module.generatedType = generatedType
        module.businessCardFieldLimit = businessCardFieldLimit
        module.webLink = webLink
        module.arguments = arguments
        module.displayField = displayField
        module.searchLayoutFields = searchLayoutFields
        module.parentModule = parentModule?.copy()
        module.customView = customView?.copy()
        module.isKanbanViewEnabled = isKanbanViewEnabled
        module.filterStatus = filterStatus
        module.isSubMenuPresent = isSubMenuPresent
        module.perPage = perPage
        module.isFilterSupported = isFilterSupported
        module.isFeedsRequired = isFeedsRequired
        module.isEmailTemplateSupported = isEmailTemplateSupported
        module.properties = properties
        module.internalBusinessCardFields = internalBusinessCardFields
        module.fields = fields?.copy()
       
        return module
    }
}

extension ZCRMModule
{
    public static func == (lhs: ZCRMModule, rhs: ZCRMModule) -> Bool {
        var argumentsFlag : Bool = true
        if lhs.arguments == nil && rhs.arguments == nil
        {
            argumentsFlag = true
        }
        else if let lhsArguments = lhs.arguments, let rhsArguments = rhs.arguments
        {
            if lhsArguments.count == rhsArguments.count
            {
                for index in 0..<lhsArguments.count
                {
                    if !NSDictionary(dictionary: lhsArguments[index]).isEqual(to: rhsArguments[index])
                    {
                        return false
                    }
                }
            }
            else
            {
                return false
            }
        }
        else
        {
            return false
        }
        let equals : Bool = lhs.singularLabel == rhs.singularLabel &&
            lhs.pluralLabel == rhs.pluralLabel &&
            lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.isCreatable == rhs.isCreatable &&
            lhs.isViewable == rhs.isViewable &&
            lhs.isConvertible == rhs.isConvertible &&
            lhs.isEditable == rhs.isEditable &&
            lhs.isDeletable == rhs.isDeletable &&
            lhs.modifiedBy == rhs.modifiedBy &&
            lhs.modifiedTime == rhs.modifiedTime &&
            lhs.accessibleProfiles == rhs.accessibleProfiles &&
            lhs.relatedLists == rhs.relatedLists &&
            lhs.isGlobalSearchSupported == rhs.isGlobalSearchSupported &&
            lhs.visibility == rhs.visibility &&
            lhs.isAPISupported == rhs.isAPISupported &&
            lhs.isQuickCreateAvailable == rhs.isQuickCreateAvailable &&
            lhs.isScoringSupported == rhs.isScoringSupported &&
            lhs.sequenceNumber == rhs.sequenceNumber &&
            lhs.generatedType == rhs.generatedType &&
            lhs.businessCardFieldLimit == rhs.businessCardFieldLimit &&
            lhs.webLink == rhs.webLink &&
            argumentsFlag &&
            lhs.displayField == rhs.displayField &&
            lhs.searchLayoutFields == rhs.searchLayoutFields &&
            lhs.parentModule == rhs.parentModule &&
            lhs.customView == rhs.customView &&
            lhs.isKanbanViewEnabled == rhs.isKanbanViewEnabled &&
            lhs.filterStatus == rhs.filterStatus &&
            lhs.isSubMenuPresent == rhs.isSubMenuPresent &&
            lhs.perPage == rhs.perPage &&
            lhs.isFilterSupported == rhs.isFilterSupported &&
            lhs.isFeedsRequired == rhs.isFeedsRequired &&
            lhs.internalBusinessCardFields == rhs.internalBusinessCardFields &&
            lhs.fields == rhs.fields
        return equals
    }
}
