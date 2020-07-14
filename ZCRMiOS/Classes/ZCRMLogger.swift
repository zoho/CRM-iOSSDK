//
//  ZCRMLogger.swift
//  ZCRMiOS
//
//  Created by Umashri R on 08/01/19.
//

import os.log

open class ZCRMLogger
{
    internal static var minLogLevel : LogLevels = LogLevels.error
    internal static var isLogEnabled : Bool = true
    
    internal static func initLogger( isLogEnabled : Bool )
    {
        self.isLogEnabled = isLogEnabled
    }
    
    internal static func initLogger( isLogEnabled : Bool, minLogLevel : LogLevels )
    {
        self.isLogEnabled = isLogEnabled
        self.minLogLevel = minLogLevel
    }
    
    public static func logDefault( file : String = #file, function : String = #function, line : Int = #line, column : Int = #column, message : String )
    {
        self.configLog(file: file, function: function, line: line, column: column, message: message, logLevel: .byDefault)
    }
    
    public static func logInfo( file : String = #file, function : String = #function, line : Int = #line, column : Int = #column, message : String )
    {
        self.configLog(file: file, function: function, line: line, column: column, message: message, logLevel: .info)
    }
    
    public static func logDebug( file : String = #file, function : String = #function, line : Int = #line, column : Int = #column, message : String )
    {
        self.configLog(file: file, function: function, line: line, column: column, message: message, logLevel: .debug)
    }
    
    public static func logError( file : String = #file, function : String = #function, line : Int = #line, column : Int = #column, message : String )
    {
        self.configLog(file: file, function: function, line: line, column: column, message: message, logLevel: .error)
    }
    
    public static func logFault( file : String = #file, function : String = #function, line : Int = #line, column : Int = #column, message : String )
    {
        self.configLog(file: file, function: function, line: line, column: column, message: message, logLevel: .fault)
    }
    
    private static func configLog( file : String, function : String, line : Int, column : Int, message : String, logLevel : LogLevels )
    {
        if self.isLogEnabled == true && self.minLogLevel.rawValue <= logLevel.rawValue
        {
            let configMsg : String = file.lastPathComponent() + " ::: " + function + " ::: " + String(line) + " ::: " + String(column)
            if #available(iOS 10.0, *)
            {
                var osType : OSLogType = OSLogType.error
                switch logLevel
                {
                    case .byDefault:
                        osType = OSLogType.default
                    case .info:
                        osType = OSLogType.info
                    case .debug:
                        osType = OSLogType.debug
                    case .error:
                        osType = OSLogType.error
                    case .fault:
                        osType = OSLogType.fault
                }
                os_log("%s%s ::: %s", log: OSLog.default, type: osType, APIConstants.EXCEPTION_LOG_MSG, configMsg, message)
            }
            else
            {
                // Fallback on earlier versions
                print( "\(configMsg) ::: \(message)" )
            }
        }
    }
}
