//
//  ZCRMLogger.swift
//  ZCRMiOS
//
//  Created by Umashri R on 08/01/19.
//

import os.log

open class ZCRMLogger
{
    internal static var minLogLevel : LogLevels = LogLevels.ERROR
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
        self.configLog(file: file, function: function, line: line, column: column, message: message, logLevel: .DEFAULT)
    }
    
    public static func logInfo( file : String = #file, function : String = #function, line : Int = #line, column : Int = #column, message : String )
    {
        self.configLog(file: file, function: function, line: line, column: column, message: message, logLevel: .INFO)
    }
    
    public static func logDebug( file : String = #file, function : String = #function, line : Int = #line, column : Int = #column, message : String )
    {
        self.configLog(file: file, function: function, line: line, column: column, message: message, logLevel: .DEBUG)
    }
    
    public static func logError( file : String = #file, function : String = #function, line : Int = #line, column : Int = #column, message : String )
    {
        self.configLog(file: file, function: function, line: line, column: column, message: message, logLevel: .ERROR)
    }
    
    public static func logFault( file : String = #file, function : String = #function, line : Int = #line, column : Int = #column, message : String )
    {
        self.configLog(file: file, function: function, line: line, column: column, message: message, logLevel: .FAULT)
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
                    case .DEFAULT:
                        osType = OSLogType.default
                    case .INFO:
                        osType = OSLogType.info
                    case .DEBUG:
                        osType = OSLogType.debug
                    case .ERROR:
                        osType = OSLogType.error
                    case .FAULT:
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
