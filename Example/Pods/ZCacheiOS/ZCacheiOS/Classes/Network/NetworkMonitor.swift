//
//  NetworkMonitor.swift
//  ZCacheiOS
//
//  Created by Rajarajan on 27/11/20.
//

import Foundation
import Network
import SystemConfiguration

@available(iOS 12.0, *)
public class NetworkMonitor
{
    
    static let shared = NetworkMonitor()
    private init()
    {
        
    }
    let monitor = NWPathMonitor()
    private var status: NWPath.Status = .requiresConnection
    var isReachable: Bool { status == .satisfied }
    var isReachableOnCellular: Bool = true

    public func startMonitoring()
    {
        monitor.pathUpdateHandler =
        {
            [weak self] path in
            self?.status = path.status
            self?.isReachableOnCellular = path.isExpensive
            if path.status == .satisfied
            {
                ZCacheLogger.logInfo(message: "<<< We're connected!")
            }
            else
            {
                ZCacheLogger.logInfo(message: "<<< No connection.")
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }

    public func stopMonitoring()
    {
        monitor.cancel()
    }
}
