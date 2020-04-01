//
//  ZCRMRestClient.swift
//  ZCRMiOS
//
//  Created by Boopathy P on 06/09/17.
//  Copyright © 2017 zohocrm. All rights reserved.
//

import Foundation

public class ZCRMSDKUtil
{
    public static func getModuleDelegate( apiName : String ) -> ZCRMModuleDelegate
    {
        return ZCRMModuleDelegate(apiName: apiName)
    }
    
    public static func getOrgDelegate() -> ZCRMOrgDelegate
    {
        return ZCRMOrgDelegate()
    }
    
    public static func newVariableGroup( name : String ) -> ZCRMVariableGroup
    {
        return ZCRMVariableGroup(name: name)
    }
    
    public static func newVariable( name : String, apiName : String, type : String, variableGroup : ZCRMVariableGroup ) -> ZCRMVariable
    {
        return ZCRMVariable(name: name, apiName: apiName, type: type, variableGroup: variableGroup)
    }
    
    public static func getOrgDetails( completion : @escaping( Result.DataResponse< ZCRMOrg, APIResponse > ) -> () )
    {
        OrgAPIHandler(cacheFlavour: CacheFlavour.forceCache).getOrgDetails { ( result ) in
            completion( result )
        }
    }
    
    public static func getOrgDetailsFromServer( completion : @escaping( Result.DataResponse< ZCRMOrg, APIResponse > ) -> () )
    {
        OrgAPIHandler(cacheFlavour: CacheFlavour.noCache).getOrgDetails { ( result ) in
            completion( result )
        }
    }
    
    public static func getModule( moduleAPIName : String, completion : @escaping( Result.DataResponse< ZCRMModule, APIResponse > ) -> () )
    {
        MetaDataAPIHandler().getModule( apiName : moduleAPIName ) { ( result ) in
            completion( result )
        }
    }
    
    public static func getModules( completion : @escaping( Result.DataResponse< [ ZCRMModule ], BulkAPIResponse > ) -> () )
    {
        MetaDataAPIHandler().getAllModules( modifiedSince : nil ) { ( result ) in
            completion( result )
        }
    }
    
    public static func getModules( modifiedSince : String, completion : @escaping( Result.DataResponse< [ ZCRMModule ], BulkAPIResponse > ) -> () )
    {
        MetaDataAPIHandler().getAllModules( modifiedSince : modifiedSince ) { ( result ) in
            completion( result )
        }
    }
    
    public static func getCurrentUser( completion : @escaping( Result.DataResponse< ZCRMUser, APIResponse > ) -> () )
    {
        UserAPIHandler(cacheFlavour: CacheFlavour.forceCache).getCurrentUser() { ( result ) in
            completion( result )
        }
    }
    
    public static func getCurrentUserFromServer( completion : @escaping( Result.DataResponse< ZCRMUser, APIResponse > ) -> () )
    {
        UserAPIHandler(cacheFlavour: .noCache).getCurrentUser { ( result ) in
            completion( result )
        }
    }
    
    public static func createVariables( variables : [ZCRMVariable], completion : @escaping( Result.DataResponse< [ZCRMVariable], BulkAPIResponse > ) -> () )
    {
        OrgAPIHandler().createVariables(variables: variables) { ( result ) in
            completion( result )
        }
    }
    
    public static func updateVariables( variables : [ZCRMVariable], completion : @escaping( Result.DataResponse< [ZCRMVariable], BulkAPIResponse > ) -> () )
    {
        OrgAPIHandler().updateVariables(variables: variables) { ( result ) in
            completion( result )
        }
    }
    
    public static func getVariableGroups( completion : @escaping( Result.DataResponse< [ZCRMVariableGroup], BulkAPIResponse > ) -> () )
    {
        OrgAPIHandler().getVariableGroups { ( result ) in
            completion( result )
        }
    }
    
    public static func getVariableGroup( id : Int64, completion : @escaping( Result.DataResponse< ZCRMVariableGroup, APIResponse > ) -> () )
    {
        OrgAPIHandler().getVariableGroup(id: id, apiName: nil) { ( result ) in
            completion(result)
        }
    }
    
    public static func getVariableGroup( apiName : String, completion : @escaping( Result.DataResponse< ZCRMVariableGroup, APIResponse > ) -> () )
    {
        OrgAPIHandler().getVariableGroup(id: nil, apiName: apiName) { ( result ) in
            completion(result)
        }
    }
    
    public static func getVariables( completion : @escaping( Result.DataResponse< [ZCRMVariable], BulkAPIResponse > ) -> () )
    {
        OrgAPIHandler().getVariables { ( result ) in
            completion( result )
        }
    }
    
    public static func getVariable( variableId : Int64, variableGroupId : Int64, completion : @escaping( Result.DataResponse< ZCRMVariable, APIResponse > ) -> () )
    {
        OrgAPIHandler().getVariable(variableId: variableId, variableAPIName: nil, variableGroupId: variableGroupId, variableGroupAPIName: nil) { ( result ) in
            completion( result )
        }
    }
    
    public static func getVariable( variableId : Int64, variableGroupAPIName : String, completion : @escaping( Result.DataResponse< ZCRMVariable, APIResponse > ) -> () )
    {
        OrgAPIHandler().getVariable(variableId: variableId, variableAPIName: nil, variableGroupId: nil, variableGroupAPIName:  variableGroupAPIName) { ( result ) in
            completion( result )
        }
    }
    
    public static func getVariable( variableAPIName : String, variableGroupId : Int64, completion : @escaping( Result.DataResponse< ZCRMVariable, APIResponse > ) -> () )
    {
        OrgAPIHandler().getVariable(variableId: nil, variableAPIName: variableAPIName, variableGroupId: variableGroupId, variableGroupAPIName: nil) { ( result ) in
            completion( result )
        }
    }
    
    public static func getVariable( variableAPIName : String, variableGroupAPIName : String, completion : @escaping( Result.DataResponse< ZCRMVariable, APIResponse > ) -> () )
    {
        OrgAPIHandler().getVariable(variableId: nil, variableAPIName: variableAPIName, variableGroupId: nil, variableGroupAPIName: variableGroupAPIName) { ( result ) in
            completion( result )
        }
    }
    
    public static func deleteVariables( ids : [Int64], completion : @escaping( Result.Response< BulkAPIResponse > ) -> () )
    {
        OrgAPIHandler().deleteVariables(ids: ids) { ( result ) in
            completion( result )
        }
    }
    
    public static func getNotifications( completion : @escaping( Result.DataResponse< [ ZCRMNotification  ], BulkAPIResponse > ) -> () )
    {
        NotificationAPIHandler().getNotifications( page : nil, perPage : nil ) { ( result ) in
            completion( result )
        }
    }
    
    public static func getNotifications( page : Int, perPage : Int, completion : @escaping( Result.DataResponse< [ ZCRMNotification  ], BulkAPIResponse > ) -> () )
    {
        NotificationAPIHandler().getNotifications( page : page, perPage : perPage ) { ( result ) in
            completion( result )
        }
    }
    
    
    public static func getNotificationsCount( completion : @escaping( Result.DataResponse< [ String : Any ], APIResponse > ) -> () )
    {
        NotificationAPIHandler().getNotificationsCount { ( result ) in
            completion( result )
        }
    }
    
    @available(*, deprecated, message: "Use the method 'markAllNotificationsAsRead'" )
    public func markAllAsRead( completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        NotificationAPIHandler().markNotificationsAsRead(recordId: nil, notificationIds: nil) { ( result ) in
            completion( result )
        }
    }
    
    public static func markAllNotificationsAsRead( completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        NotificationAPIHandler().markNotificationsAsRead(recordId: nil, notificationIds: nil) { ( result ) in
            completion( result )
        }
    }
    
    public static func markNotificationsAsRead( notificationIds : [Int64], completion : @escaping( Result.Response< APIResponse > ) -> () )
    {
        NotificationAPIHandler().markNotificationsAsRead(recordId: nil, notificationIds: notificationIds) { ( result ) in
            completion( result )
        }
    }
    
    public static func getDashboards( then onCompletion : @escaping ZCRMAnalytics.ArrayOfDashboards )
    {
        // 200 is the maxNumber of records that can be retreived in an API Call
        DashboardAPIHandler( cacheFlavour : .urlVsResponse ).getDashboards( fromPage : nil, withPerPageOf : nil, searchWord : nil, dashboardFilter : nil ) { ( result ) in
            onCompletion( result )
        }
    }
    
    public static func getDashboardsFromServer( then onCompletion : @escaping ZCRMAnalytics.ArrayOfDashboards )
    {
        // 200 is the maxNumber of records that can be retreived in an API Call
        DashboardAPIHandler( cacheFlavour : .noCache ).getDashboards( fromPage : nil, withPerPageOf : nil, searchWord : nil, dashboardFilter : nil ) { ( result ) in
            onCompletion( result )
        }
    }
    
    public static func getDashboards( dashboardFilter : DashboardFilter, then onCompletion : @escaping ZCRMAnalytics.ArrayOfDashboards )
    {
        DashboardAPIHandler( cacheFlavour : .urlVsResponse ).getDashboards( fromPage : nil, withPerPageOf : nil, searchWord : nil, dashboardFilter : dashboardFilter ) { ( result ) in
            onCompletion( result )
        }
    }
    
    public static func getDashboardsFromServer( dashboardFilter : DashboardFilter, then onCompletion : @escaping ZCRMAnalytics.ArrayOfDashboards )
    {
        DashboardAPIHandler( cacheFlavour : .noCache ).getDashboards( fromPage : nil, withPerPageOf : nil, searchWord : nil, dashboardFilter : dashboardFilter ) { ( result ) in
            onCompletion( result )
        }
    }
    
    public static func getDashboards( fromPage page :Int, perPage :Int, then onCompletion : @escaping ZCRMAnalytics.ArrayOfDashboards )
    {
        DashboardAPIHandler( cacheFlavour : .urlVsResponse ).getDashboards( fromPage : page, withPerPageOf : perPage, searchWord : nil, dashboardFilter : nil ) { ( result ) in
            onCompletion( result )
        }
    }
    
    public static func getDashboardsFromServer( fromPage page :Int, perPage :Int, then onCompletion : @escaping ZCRMAnalytics.ArrayOfDashboards )
    {
        DashboardAPIHandler( cacheFlavour : .noCache ).getDashboards( fromPage : page, withPerPageOf : perPage, searchWord : nil, dashboardFilter : nil ) { ( result ) in
            onCompletion( result )
        }
    }
    
    public static func getDashboards( fromPage page :Int, perPage :Int, dashboardFilter : DashboardFilter, then onCompletion : @escaping ZCRMAnalytics.ArrayOfDashboards )
    {
        DashboardAPIHandler( cacheFlavour : .urlVsResponse ).getDashboards( fromPage : page, withPerPageOf : perPage, searchWord : nil, dashboardFilter : dashboardFilter ) { ( result ) in
            onCompletion( result )
        }
    }
    
    public static func getDashboardsFromServer( fromPage page : Int, perPage : Int, dashboardFilter : DashboardFilter, then onCompletion : @escaping ZCRMAnalytics.ArrayOfDashboards )
    {
        DashboardAPIHandler( cacheFlavour : .noCache ).getDashboards( fromPage : page, withPerPageOf : perPage, searchWord : nil, dashboardFilter : dashboardFilter ) { ( result ) in
            onCompletion( result )
        }
    }
    
    public static func searchDashboardsFromServer( searchWord : String, then onCompletion : @escaping ZCRMAnalytics.ArrayOfDashboards )
    {
        DashboardAPIHandler( cacheFlavour : .noCache ).getDashboards( fromPage : nil, withPerPageOf : nil, searchWord : searchWord, dashboardFilter : nil ) { ( result ) in
            onCompletion( result )
        }
    }
    
    public static func searchDashboardsFromServer( searchWord : String, dashboardFilter : DashboardFilter, then onCompletion : @escaping ZCRMAnalytics.ArrayOfDashboards )
    {
        DashboardAPIHandler( cacheFlavour : .noCache ).getDashboards( fromPage : nil, withPerPageOf : nil, searchWord : searchWord, dashboardFilter : dashboardFilter ) { ( result ) in
            onCompletion( result )
        }
    }
    
    public static func getDashboardWithId(id: Int64,then onCompletion: @escaping ZCRMAnalytics.Dashboard)
    {
        DashboardAPIHandler(cacheFlavour: .urlVsResponse).getDashboardWithId(id: id) { (resultType) in
            onCompletion(resultType)
        }
    }
    
    public static func getDashboardWithIdFromServer(id: Int64,then onCompletion: @escaping ZCRMAnalytics.Dashboard)
    {
        DashboardAPIHandler(cacheFlavour: .noCache).getDashboardWithId(id: id) { (resultType) in
            onCompletion(resultType)
        }
    }
    
    public static func getDashboardComponentColorThemes( onCompletion: @escaping ZCRMAnalytics.ArrayOfColorThemes )
    {
        DashboardAPIHandler(cacheFlavour: .urlVsResponse).getDashboardComponentColorThemes { (resultType) in
            onCompletion(resultType)
        }
    }
    
    public static func getDashboardComponentColorThemesFromServer( onCompletion: @escaping ZCRMAnalytics.ArrayOfColorThemes )
    {
        DashboardAPIHandler(cacheFlavour: .noCache).getDashboardComponentColorThemes { (resultType) in
            onCompletion(resultType)
        }
    }
    
    public static func searchDashboards( searchWord : String, then onCompletion : @escaping ( [ ZCRMDashboard ]?, ZCRMError? ) -> () )
    {
        DashboardAPIHandler(cacheFlavour: .noCache).searchDashboards(searchWord: searchWord) { ( dashboards, error) in
            onCompletion( dashboards, error )
        }
    }
    
    public static func getAnalytics() -> ZCRMAnalytics
    {
        return ZCRMAnalytics()
    }
    
    public struct ZCRMAnalytics {
        public typealias Dashboard = (Result.DataResponse<ZCRMDashboard,APIResponse>) -> Void
        public typealias ArrayOfDashboards = (Result.DataResponse<[ZCRMDashboard],BulkAPIResponse>) -> Void
        public typealias ArrayOfColorThemes = (Result.DataResponse<[ZCRMAnalyticsColorThemes],APIResponse>) -> Void
        public typealias RefreshResponse = (Result.Response<APIResponse>) -> Void
        public typealias DashboardComponent = (Result.DataResponse<ZCRMDashboardComponent,APIResponse>) -> Void
    }
}
