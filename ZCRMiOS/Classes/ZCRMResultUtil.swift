//
//  ZCRMResultUtil.swift
//  ZCRMiOS
//
//  Created by Janakiraman.sk on 27/04/23.
//

import Foundation

public struct ZCRMResultUtil {
    public typealias ReportFolders = (ZCRMResult.DataResponse<[ZCRMReportFolder], BulkAPIResponse>) -> Void
    public typealias ReportMetas = (ZCRMResult.DataResponse<[ZCRMReportMeta], BulkAPIResponse>) -> Void
    public typealias Report = (ZCRMResult.DataResponse<ZCRMReport, APIResponse>) -> Void
    public typealias ReportData = (ZCRMResult.DataResponse<ZCRMReport.Data, BulkAPIResponse>) -> Void
    public typealias ReportMail = (ZCRMResult.Response<APIResponse>) -> Void
    public typealias ReportExport = (ZCRMResult.DataResponse<Data, FileAPIResponse>) -> ()
    public typealias ReportChart = (ZCRMResult.DataResponse<ZCRMDashboardComponent, APIResponse>) -> Void
}
