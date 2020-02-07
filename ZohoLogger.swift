//
//  ZohoLogger.swift
//  ZCRMiOS
//
//  Created by Michael Vieth on 2/7/20.
//  Code from Sauvik Dolui on 03/05/2017
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
  case verbose = "[🔔]" // verbose
  case debug = "[🟩]" // debug
  case info = "[🟦]" // info
  case warning = "[🟧]" // warning
  case error = "[🟥]" // error
  
  func value() -> Int {
    switch(self) {
    case .verbose:
      return 1
    case .debug:
      return 2
    case .info:
      return 3
    case .warning:
      return 4
    case .error:
      return 5
    }
  }
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
  
  public static var dateFormat = "yyyy-MM-dd hh:mm:ssSSS"
  public static var logLevel: LogEvent = .info
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
    if isLoggingEnabled && logLevel.value() <= LogEvent.error.value() {
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
    if isLoggingEnabled && logLevel.value() <= LogEvent.info.value() {
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
    if isLoggingEnabled && logLevel.value() <= LogEvent.debug.value() {
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
    if isLoggingEnabled && logLevel.value() <= LogEvent.verbose.value() {
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
    if isLoggingEnabled && logLevel.value() <= LogEvent.warning.value() {
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
