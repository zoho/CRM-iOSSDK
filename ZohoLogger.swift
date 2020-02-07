//
//  ZohoLogger.swift
//  ZCRMiOS
//
//  Created by Michael Vieth on 2/7/20.
//
//
//  Logger.swift
//  SwiftLogger
//
//  Created by Sauvik Dolui on 03/05/2017.
//  Copyright © 2016 Innofied Solutions Pvt. Ltd. All rights reserved.
//
import Foundation

/// Enum which maps an appropiate symbol which added as prefix for each log message
///
/// - error: Log type error
/// - info: Log type info
/// - debug: Log type debug
/// - verbose: Log type verbose
/// - warning: Log type warning
/// - severe: Log type severe
enum LogEvent: String {
  case error = "[🟥]" // error
  case info = "[🟦]" // info
  case debug = "[🟩]" // debug
  case verbose = "[🔔]" // verbose
  case warning = "[🟧]" // warning
}


/// Wrapping Swift.print() within DEBUG flag
///
/// - Note: *print()* might cause [security vulnerabilities](https://codifiedsecurity.com/mobile-app-security-testing-checklist-ios/)
///
/// - Parameter object: The object which is to be logged
///
func print(_ object: Any) {
  // Only allowing in DEBUG mode
  #if DEBUG
  Swift.print(object)
  #endif
}

class ZohoLogger {
  
  static var dateFormat = "yyyy-MM-dd hh:mm:ssSSS"
  static var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = dateFormat
    formatter.locale = Locale.current
    formatter.timeZone = TimeZone.current
    return formatter
  }
  
  private static var isLoggingEnabled: Bool {
    #if DEBUG
    return true
    #else
    return false
    #endif
  }
  
  // MARK: - Loging methods
  
  
  /// Logs error messages on console with prefix [‼️]
  ///
  /// - Parameters:
  ///   - object: Object or message to be logged
  ///   - filename: File name from where loggin to be done
  ///   - line: Line number in file from where the logging is done
  ///   - column: Column number of the log message
  ///   - funcName: Name of the function from where the logging is done
  class func error( _ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
    if isLoggingEnabled {
      print("\(Date().toString()) \(LogEvent.error.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(funcName) -> \(object)")
    }
  }
  
  /// Logs info messages on console with prefix [ℹ️]
  ///
  /// - Parameters:
  ///   - object: Object or message to be logged
  ///   - filename: File name from where loggin to be done
  ///   - line: Line number in file from where the logging is done
  ///   - column: Column number of the log message
  ///   - funcName: Name of the function from where the logging is done
  class func info ( _ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
    if isLoggingEnabled {
      print("\(Date().toString()) \(LogEvent.info.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(funcName) -> \(object)")
    }
  }
  
  /// Logs debug messages on console with prefix [💬]
  ///
  /// - Parameters:
  ///   - object: Object or message to be logged
  ///   - filename: File name from where loggin to be done
  ///   - line: Line number in file from where the logging is done
  ///   - column: Column number of the log message
  ///   - funcName: Name of the function from where the logging is done
  class func debug( _ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
    if isLoggingEnabled {
      print("\(Date().toString()) \(LogEvent.debug.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(funcName) -> \(object)")
    }
  }
  
  /// Logs messages verbosely on console with prefix [🔬]
  ///
  /// - Parameters:
  ///   - object: Object or message to be logged
  ///   - filename: File name from where loggin to be done
  ///   - line: Line number in file from where the logging is done
  ///   - column: Column number of the log message
  ///   - funcName: Name of the function from where the logging is done
  class func verbose( _ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
    if isLoggingEnabled {
      print("\(Date().toString()) \(LogEvent.verbose.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(funcName) -> \(object)")
    }
  }
  
  /// Logs warnings verbosely on console with prefix [⚠️]
  ///
  /// - Parameters:
  ///   - object: Object or message to be logged
  ///   - filename: File name from where loggin to be done
  ///   - line: Line number in file from where the logging is done
  ///   - column: Column number of the log message
  ///   - funcName: Name of the function from where the logging is done
  class func warning( _ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
    if isLoggingEnabled {
      print("\(Date().toString()) \(LogEvent.warning.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(funcName) -> \(object)")
    }
  }
  
  
  /// Extract the file name from the file path
  ///
  /// - Parameter filePath: Full file path in bundle
  /// - Returns: File Name with extension
  private class func sourceFileName(filePath: String) -> String {
    let components = filePath.components(separatedBy: "/")
    return components.isEmpty ? "" : components.last!
  }
}

internal extension Date {
  func toString() -> String {
    return ZohoLogger.dateFormatter.string(from: self as Date)
  }
}
