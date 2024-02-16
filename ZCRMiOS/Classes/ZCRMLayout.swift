//
//  ZCRMLayout.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 14/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

open class ZCRMLayout : ZCRMLayoutDelegate
{
    public internal( set ) var createdBy : ZCRMUserDelegate?
    public internal( set ) var createdTime : String?
    public internal( set ) var modifiedBy : ZCRMUserDelegate?
    public internal( set ) var modifiedTime : String?
    public internal( set ) var isVisible : Bool = APIConstants.BOOL_MOCK
    @available(*, deprecated, renamed: "isActive")
    public internal( set ) var status : Int?
    public internal( set ) var isActive: Bool?
    public internal( set ) var sections : [ ZCRMSection ] = [ ZCRMSection ]()
    public internal( set ) var accessibleProfiles : [ ZCRMProfileDelegate ] = [ ZCRMProfileDelegate ]()
	
    init( name : String )
    {
        super.init( id : APIConstants.INT64_MOCK, name : name )
    }
	
    /// Add ZCRMSection to the ZCRMLayout.
    ///
    /// - Parameter section: ZCRMSection to be added
	internal func addSection(section : ZCRMSection)
	{
        self.sections.append(section)
	}
    
    /**
     To get all the pipeline details of the layout from DB if the data is already cached ( i.e ) the data has already been fetched from the server atleast once and DB has not been cleared after that
    
    - Precondition: The **layout ID** must be of **Deals** module
    
    - Parameters:
       - completion :
           - Success : Returns an array of ZCRMPipeline objects and a BulkAPIResponse
           - Failure : ZCRMError
    */
    public func getPipelines( completion : @escaping( ZCRMResult.DataResponse< [ ZCRMPipeline ], BulkAPIResponse > ) -> () )
    {
        PipelineAPIHandler( cache : .urlVsResponse ).getPipelines( layoutId : self.id ) { ( result ) in
            completion( result )
        }
    }
    
    /**
     To get all the pipeline details of the layout from Server
    
    - Precondition: The **layout ID** must be of **Deals** module
    
    - Parameters:
       - requestHeaders : Headers that needs to be included in the request
       - completion :
           - Success : Returns an array of ZCRMPipeline objects and a BulkAPIResponse
           - Failure : ZCRMError
    */
    public func getPipelinesFromServer( completion : @escaping( ZCRMResult.DataResponse< [ ZCRMPipeline ], BulkAPIResponse > ) -> () )
    {
        PipelineAPIHandler( cache : .noCache ).getPipelines( layoutId : self.id ) { ( result ) in
            completion( result )
        }
    }
    
    /**
     To get all the pipeline details of the layout from Server
    
    - Precondition: The **layout ID** must be of **Deals** module
     
    - Note: If request headers contains **X-CRM-ORG** key, then the response will not be cached
    
    - Parameters:
       - requestHeaders : Headers that needs to be included in the request
       - completion :
            - Success : Returns an array of ZCRMPipeline objects and a BulkAPIResponse
            - Failure : ZCRMError
    */
    public func getPipelinesFromServer( requestHeaders : [ String : String ], completion : @escaping( ZCRMResult.DataResponse< [ ZCRMPipeline ], BulkAPIResponse > ) -> () )
    {
        PipelineAPIHandler( cache : .noCache ).getPipelines( layoutId : self.id, requestHeaders: requestHeaders ) { ( result ) in
            completion( result )
        }
    }
}

extension ZCRMLayout
{
    public static func == (lhs: ZCRMLayout, rhs: ZCRMLayout) -> Bool {
        let equals : Bool = lhs.createdBy == rhs.createdBy &&
            lhs.createdTime == rhs.createdTime &&
            lhs.modifiedBy == rhs.modifiedBy &&
            lhs.modifiedTime == rhs.modifiedTime &&
            lhs.isVisible == rhs.isVisible &&
            lhs.status == rhs.status &&
            lhs.isActive == rhs.isActive &&
            lhs.sections == rhs.sections &&
            lhs.accessibleProfiles == rhs.accessibleProfiles
        return equals
    }
}
