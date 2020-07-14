//
//  ZCRMSection.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 14/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

public class ZCRMSection : ZCRMEntity
{
    public internal( set ) var apiName : String
    public internal( set ) var name : String = APIConstants.STRING_MOCK
    public internal( set ) var displayName : String = APIConstants.STRING_MOCK
    public internal( set ) var columnCount : Int = APIConstants.INT_MOCK
    public internal( set ) var sequence : Int = APIConstants.INT_MOCK
    public internal( set ) var fields : [ ZCRMField ] = [ ZCRMField ]()
    public internal( set ) var isSubformSection : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var reorderRows : Bool = APIConstants.BOOL_MOCK
    public internal( set ) var tooltip : String?
    public internal( set ) var maximumRows : Int?
    
    /// Initialise the instance of a section with the given section name.
    ///
    /// - Parameter sectionName: section name whose associated section is to be initialised
    internal init( apiName : String )
    {
        self.apiName = apiName
    }
    
    /// Add given ZCRMFields to the sections.
    ///
    /// - Parameter field: ZCRMField to be added
    internal func addField(field : ZCRMField)
    {
        self.fields.append( field )
    }
}

extension ZCRMSection : Equatable
{
    public static func == (lhs: ZCRMSection, rhs: ZCRMSection) -> Bool {
        let equals : Bool = lhs.name == rhs.name &&
            lhs.displayName == rhs.displayName &&
            lhs.columnCount == rhs.columnCount &&
            lhs.sequence == rhs.sequence &&
            lhs.fields == rhs.fields &&
            lhs.isSubformSection == rhs.isSubformSection
        return equals
    }
}
