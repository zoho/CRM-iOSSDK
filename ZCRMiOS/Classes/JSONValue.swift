//
//  JSONValue.swift
//  ZCRMiOS
//
//  Created by Rajarajan on 07/12/20.
//

import Foundation

public struct JSONValue: Decodable {
  var value: Any?

  struct CodingKeys: CodingKey {
    var stringValue: String
    var intValue: Int?
    init?(intValue: Int) {
      self.stringValue = "\(intValue)"
      self.intValue = intValue
    }
    init?(stringValue: String) { self.stringValue = stringValue }
  }

  init(value: Any?) {
    self.value = value
  }

  public init(from decoder: Decoder) throws
  {
    let container = try? decoder.singleValueContainer()
    if let recordVal = try? container?.decode(ZCRMRecordDelegate.self)
    {
        value = recordVal
    }
    else if let layoutVal = try? container?.decode(ZCRMLayoutDelegate.self)
    {
        value = layoutVal
    }
    else if let userVal = try? container?.decode(ZCRMUserDelegate.self)
    {
        value = userVal
    }
    else if let lineItemVal = try? container?.decode(ZCRMInventoryLineItem.self)
    {
        print("<<< LineItem: \(lineItemVal)")
        value = lineItemVal
    }
    else if let priceBookVal = try? container?.decode(ZCRMPriceBookPricing.self)
    {
        value = priceBookVal
    }
    else if let eventParticipantVal = try? container?.decode(ZCRMEventParticipant.self)
    {
        value = eventParticipantVal
    }
    else if let taxVal = try? container?.decode(ZCRMTaxDelegate.self)
    {
        value = taxVal
    }
    else if let lineTaxVal = try? container?.decode(ZCRMLineTax.self)
    {
        value = lineTaxVal
    }
    else if let dataProcessBasisDetailsVal = try? container?.decode(ZCRMDataProcessBasisDetails.self)
    {
        value = dataProcessBasisDetailsVal
    }
    else if let subformVal = try? container?.decode(ZCRMSubformRecord.self)
    {
        value = subformVal
    }
    else if var container = try? decoder.unkeyedContainer()
    {
      var result = [Any?]()
        print("<<< LineItem unkeyedContainer")
      while !container.isAtEnd
      {
        result.append(try container.decode(JSONValue.self).value)
      }
      value = result
    }
    else if let container = try? decoder.container(keyedBy: CodingKeys.self)
    {
      var result = [String: Any?]()
      try container.allKeys.forEach
      {
        (key) throws in
        result[key.stringValue] = try container.decode(JSONValue.self, forKey: key).value
      }
      value = result
    }
    else if let container = try? decoder.singleValueContainer()
    {
        if let intVal = try? container.decode(Int.self)
        {
          value = intVal
        }
        else if let doubleVal = try? container.decode(Double.self)
        {
          value = doubleVal
        }
        else if let boolVal = try? container.decode(Bool.self)
        {
          value = boolVal
        }
        else if let stringVal = try? container.decode(String.self)
        {
          value = stringVal
        }
        else
        {
            value = nil
        }
    }
    else
    {
        value = nil
    }
  }
}

extension JSONValue: Encodable {
  public func encode(to encoder: Encoder) throws {
    if !(value is NSNull)
    {
        if let array = value as? [Any]
        {
            var container = encoder.unkeyedContainer()
            for value in array
            {
                let decodable = JSONValue(value: value)
                try container.encode(decodable)
            }
        }
        else if let dictionary = value as? [String: Any]
        {
            var container = encoder.container(keyedBy: CodingKeys.self)
            for (key, value) in dictionary
            {
                let codingKey = CodingKeys(stringValue: key)!
                let decodable = JSONValue(value: value)
                try container.encode(decodable, forKey: codingKey)
            }
        }
        else if let layout = value as? ZCRMLayoutDelegate
        {
            try layout.encode(to: encoder)
        }
        else if let user = value as? ZCRMUserDelegate
        {
            try user.encode(to: encoder)
        }
        else if let record = value as? ZCRMRecordDelegate
        {
            try record.encode(to: encoder)
        }
        else if let lineItem = value as? ZCRMInventoryLineItem
        {
            try lineItem.encode(to: encoder)
        }
        else if let priceBook = value as? ZCRMPriceBookPricing
        {
            try priceBook.encode(to: encoder)
        }
        else if let eventParticipant = value as? ZCRMEventParticipant
        {
            try eventParticipant.encode(to: encoder)
        }
        else if let tax = value as? ZCRMTaxDelegate
        {
            try tax.encode(to: encoder)
        }
        else if let lineTax = value as? ZCRMLineTax
        {
            try lineTax.encode(to: encoder)
        }
        else if let dataProcessBasisDetails = value as? ZCRMDataProcessBasisDetails
        {
            try dataProcessBasisDetails.encode(to: encoder)
        }
        else if let subform = value as? ZCRMSubformRecord
        {
            try subform.encode(to: encoder)
        }
        else
        {
          var container = encoder.singleValueContainer()
          if let intVal = value as? Int
          {
            try container.encode(intVal)
          }
          else if let doubleVal = value as? Double
          {
            try container.encode(doubleVal)
          }
          else if let boolVal = value as? Bool
          {
            try container.encode(boolVal)
          }
          else if let stringVal = value as? String
          {
            try container.encode(stringVal)
          }
          else
          {
            ZCRMLogger.logError(message: "<<< The value is not encodable: \(value ?? "Nil Value").")
//            throw EncodingError.invalidValue(value ?? "Nil Value.", EncodingError.Context.init(codingPath: [], debugDescription: "The value is not encodable"))
          }
        }
    }
  }
}
 
