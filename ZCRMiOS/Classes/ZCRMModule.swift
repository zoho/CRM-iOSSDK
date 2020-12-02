//
//  ZCRMModule.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 14/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

open class ZCRMModule : ZCRMModuleDelegate
{
    public internal( set ) var singularLabel : String = APIConstants.STRING_MOCK
    public internal( set ) var pluralLabel : String = APIConstants.STRING_MOCK
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
    
    enum Keys: String, CodingKey
    {
        case apiName
        case id
        case isApiSupported
        
        case name
        case singularLabel
        case pluralLabel
        
        case isCreatable
        case isViewable
        case isConvertible
        case isEditable
        case isDeletable
        
        case modifiedBy
        case modifiedTime
        
        case accessibleProfiles
        case relatedLists
        
        case isGlobalSearchSupported
        case visibility
        case isAPISupported
        case isQuickCreateAvailable
        case isScoringSupported
        case sequenceNumber
        case generatedType
        case businessCardFieldLimit
        case webLink
        
        case arguments
        
        case displayField
        case searchLayoutFields
        case parentModule
        case customView
        
        case isKanbanViewEnabled
        case filterStatus
        case isSubMenuPresent
        case perPage
        case isFilterSupported
        case isFeedsRequired
        case isEmailTemplateSupported
        case properties
    }
    
    init( apiName : String, singularLabel : String, pluralLabel : String )
    {
        self.singularLabel = singularLabel
        self.pluralLabel = pluralLabel
        super.init( apiName : apiName )
	}
    
    required public init(from decoder: Decoder) throws {
        
        super.init( apiName: String() )
        
        let values = try! decoder.container(keyedBy: Keys.self)
        name = try! values.decode(String.self, forKey: .name)
        id = try! values.decode(String.self, forKey: .id)
        
        apiName = try! values.decode(String.self, forKey: .apiName)
        isApiSupported = try! values.decode(Bool.self, forKey: .isApiSupported)
        singularLabel = try! values.decode(String.self, forKey: .singularLabel)
        pluralLabel = try! values.decode(String.self, forKey: .pluralLabel)
        
        isCreatable = try! values.decode(Bool.self, forKey: .isCreatable)
        isViewable = try! values.decode(Bool.self, forKey: .isViewable)
        isConvertible = try! values.decode(Bool.self, forKey: .isConvertible)
        isEditable = try! values.decode(Bool.self, forKey: .isEditable)
        isDeletable = try! values.decode(Bool.self, forKey: .isDeletable)
        
        modifiedBy = getUserDelegate(from: values, forKey: .modifiedBy)
        modifiedTime = try! values.decode(String.self, forKey: .isCreatable)
        
//        accessibleProfiles = try! values.decode(String.self, forKey: .isCreatable)
//        relatedLists = try! values.decode(String.self, forKey: .isCreatable)
        
        isGlobalSearchSupported = try! values.decode(Bool.self, forKey: .isCreatable)
        visibility = try! values.decode(Int.self, forKey: .isCreatable)
        isAPISupported = try! values.decode(Bool.self, forKey: .isCreatable)
        isQuickCreateAvailable = try! values.decode(Bool.self, forKey: .isCreatable)
        isScoringSupported = try! values.decode(Bool.self, forKey: .isCreatable)
        sequenceNumber = try! values.decode(Int.self, forKey: .isCreatable)
        generatedType = try! values.decode(String.self, forKey: .isCreatable)
        businessCardFieldLimit = try! values.decode(Int.self, forKey: .isCreatable)
        webLink = try! values.decode(String.self, forKey: .isCreatable)
        
//        arguments = try! values.decodeIfPresent([ [ String : Any ] ].self, forKey: .arguments)
        
        displayField = try! values.decode(String.self, forKey: .displayField)
        searchLayoutFields = try! values.decode([String].self, forKey: .searchLayoutFields)
        
        parentModule = getModuleDelegate(from: values, forKey: .parentModule)
        
//        customView = try! values.decode(String.self, forKey: .customView)
        
        isKanbanViewEnabled = try! values.decode(Bool.self, forKey: .isKanbanViewEnabled)
        filterStatus = try! values.decode(Bool.self, forKey: .filterStatus)
        isSubMenuPresent = try! values.decode(Bool.self, forKey: .isSubMenuPresent)
        perPage = try! values.decode(Int.self, forKey: .perPage)
        isFilterSupported = try! values.decode(Bool.self, forKey: .isFilterSupported)
        isFeedsRequired = try! values.decode(Bool.self, forKey: .isFeedsRequired)
        isEmailTemplateSupported = try! values.decode(Bool.self, forKey: .isEmailTemplateSupported)
        properties = try! values.decode([String].self, forKey: .properties)
        
    }
    
    open override func encode( to encoder : Encoder ) throws
    {
        var container = encoder.container( keyedBy : Keys.self )
        
        try container.encode( self.id, forKey : Keys.id )
        try container.encode( self.apiName, forKey : Keys.apiName )
        try container.encode( self.isApiSupported, forKey : Keys.isApiSupported )

        try container.encode( self.name, forKey : Keys.name )
        try container.encode( self.singularLabel, forKey : Keys.singularLabel )
        try container.encode( self.pluralLabel, forKey : Keys.pluralLabel )
        
        try container.encode( self.isCreatable, forKey : Keys.isCreatable )
        try container.encode( self.isViewable, forKey : Keys.isViewable )
        try container.encode( self.isConvertible, forKey : Keys.isConvertible )
        try container.encode( self.isEditable, forKey : Keys.isEditable )
        try container.encode( self.isDeletable, forKey : Keys.isDeletable )
        
        var modifiedByContainer = container.nestedContainer(keyedBy: UserCodingKeys.self, forKey: .modifiedBy)
        
        try modifiedByContainer.encodeIfPresent( self.modifiedBy?.id, forKey : UserCodingKeys.id )
        try modifiedByContainer.encodeIfPresent( self.modifiedBy?.name, forKey : UserCodingKeys.name )
        try container.encodeIfPresent( self.modifiedTime, forKey : Keys.modifiedTime )
        
//        try container.encode( self.accessibleProfiles, forKey : Keys.accessibleProfiles)
//        try container.encode( self.relatedLists, forKey : Keys.relatedLists )
        
        try container.encode( self.isGlobalSearchSupported, forKey : Keys.isGlobalSearchSupported )
        try container.encode( self.visibility, forKey : Keys.visibility )
        try container.encode( self.isAPISupported, forKey : Keys.isAPISupported )
        try container.encode( self.isQuickCreateAvailable, forKey : Keys.isQuickCreateAvailable )
        try container.encode( self.isScoringSupported, forKey : Keys.isScoringSupported )
        try container.encodeIfPresent( self.sequenceNumber, forKey : Keys.sequenceNumber )
        try container.encode( self.generatedType, forKey : Keys.generatedType )
        try container.encodeIfPresent( self.businessCardFieldLimit, forKey : Keys.businessCardFieldLimit )
        try container.encodeIfPresent( self.webLink, forKey : Keys.webLink )
        
//        try container.encode( self.arguments, forKey : Keys.arguments)
        
        try container.encodeIfPresent( self.displayField, forKey : Keys.displayField )
        try container.encodeIfPresent( self.searchLayoutFields, forKey : Keys.searchLayoutFields )
        try container.encodeIfPresent( self.parentModule, forKey : Keys.parentModule )
        
//        try container.encodeIfPresent( self.customView, forKey : Keys.customView )
        
        try container.encode( self.isKanbanViewEnabled, forKey : Keys.isKanbanViewEnabled )
        try container.encode( self.filterStatus, forKey : Keys.filterStatus )
        try container.encode( self.isSubMenuPresent, forKey : Keys.isSubMenuPresent )
        try container.encodeIfPresent( self.perPage, forKey : Keys.perPage )
        try container.encode( self.isFilterSupported, forKey : Keys.isFilterSupported )
        try container.encode( self.isFeedsRequired, forKey : Keys.isFeedsRequired )
        try container.encode( self.isEmailTemplateSupported, forKey : Keys.isEmailTemplateSupported )
        try container.encodeIfPresent( self.properties, forKey : Keys.properties )
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
            lhs.isFeedsRequired == rhs.isFeedsRequired
        return equals
    }
}
