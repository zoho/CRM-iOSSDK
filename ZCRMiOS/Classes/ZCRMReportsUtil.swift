//
//  ZCRMReportsUtil.swift
//  ZCRMiOS
//
//  Created by Janakiraman.sk on 12/07/23.
//

import Foundation

public class ZCRMReportsUtil {
        
    public static func getReportFolders(_ params: GETPaginationParams? = nil, criteria: ZCRMQuery.ZCRMCriteria? = nil, then onCompletion: @escaping ZCRMResultUtil.ReportFolders) {
        ReportApiHandler(cache: .urlVsResponse).getReportFolders(params, criteria: criteria, then: onCompletion)
    }
    
    public static func getReportFoldersFromServer(_ params: GETPaginationParams? = nil, criteria: ZCRMQuery.ZCRMCriteria? = nil, then onCompletion: @escaping ZCRMResultUtil.ReportFolders) {
        ReportApiHandler().getReportFolders(params, criteria: criteria, then: onCompletion)
    }
    
    public static func searchReportFolder(searchWord: String, params: GETPaginationParams? = nil, then onCompletion: @escaping ZCRMResultUtil.ReportFolders) {
        ReportApiHandler().getReportFolders(params, criteria: .init(apiName: ZCRMReport.ResponseJSONKeys.name, comparator: .string(.contains), value: searchWord), then: onCompletion)
    }
        
    public static func getReportMetas(_ params: GETReportParams? = nil, filter: ZCRMReportCategory = .everything, folderId: Int64? = nil, criteria: ZCRMQuery.ZCRMCriteria? = nil, then onCompletion: @escaping ZCRMResultUtil.ReportMetas) {
        ReportApiHandler(cache: .urlVsResponse).getReportMetas(params, filter: filter, folderId: folderId, criteria: criteria, then: onCompletion)
    }

    public static func getReportMetasFromServer(_ params: GETReportParams? = nil, filter: ZCRMReportCategory = .everything, folderId: Int64? = nil, criteria: ZCRMQuery.ZCRMCriteria? = nil, then onCompletion: @escaping ZCRMResultUtil.ReportMetas) {
        ReportApiHandler().getReportMetas(params, filter: filter, folderId: folderId, criteria: criteria, then: onCompletion)
    }
    
    public static func searchReportMetas(searchWord: String, params: GETReportParams? = nil, filter: ZCRMReportCategory = .everything, folderId: Int64? = nil, then onCompletion: @escaping ZCRMResultUtil.ReportMetas) {
        ReportApiHandler().getReportMetas(params, filter: filter, folderId: folderId, criteria: .init(apiName: ZCRMReport.ResponseJSONKeys.name, comparator: .string(.contains), value: searchWord), then: onCompletion)
    }
    
    public static func getReportFromServer(id: Int64, then onCompletion: @escaping ZCRMResultUtil.Report) {
        ReportApiHandler().getReport(reportId: id, then: onCompletion)
    }
    
    public static func getChartComponent(id: Int64, then onCompletion: @escaping ZCRMResultUtil.ReportChart) {
        ReportApiHandler().getChartComponent(reportId: id, then: onCompletion)
    }
    
    public static func reportRunData(report: ZCRMReport, params: GETPaginationParams?, then onCompletion: @escaping ZCRMResultUtil.ReportData) {
        ReportApiHandler().runData(params: params, report: report, then: onCompletion)
    }
    
}
