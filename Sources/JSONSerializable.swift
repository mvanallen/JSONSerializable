//
//  JSONSerializable.swift
//  JSONSerializable
//
//  Created by Michael VanAllen on 29.03.17.
//  Copyright © 2017 ReactiveCode Studios. All rights reserved.
//
//  https://github.com/mvanallen/JSONSerializable
//

import Foundation


// MARK: - Protocols

public protocol JSONRepresentable {
	var JSONRepresentation: Any { get }
}

public protocol JSONSerializable: JSONRepresentable {
	func toJSON() -> String?
}


// MARK: - JSONSerializable extensions (for "multi-value"/collection types)

extension /*Struct :*/ JSONSerializable {
	
	private func structRepresentation(for mirror: Mirror) -> Any {
		var representation = [String : Any]()
		
		for case let (label?, value) in mirror.children {
			switch value {
				
			case let value as JSONRepresentable:
				representation[label] = value.JSONRepresentation
				
			case let value where JSONSerialization.isValidJSONObject([value]):
				representation[label] = value
				
			default:
				print("[JSONSerializable.JSONRepresentation] *** WARNING – \(type(of: self)): OMITTING property '\(label): \(type(of: value))' w/ non-representable value: \(value)")
				break
			}
		}
		
		return representation
	}
	
	public var JSONRepresentation: Any {
		let mirror = Mirror(reflecting: self)
		
		switch mirror.displayStyle {
			
		case let type where type == Mirror.DisplayStyle.struct:
			return structRepresentation(for: mirror)
			
		default:
			return NSNull()
		}
	}
	
	public func toJSON() -> String? {
		let representation = JSONRepresentation
		
		guard JSONSerialization.isValidJSONObject(representation) else {
			return nil
		}
		
		do {
			let data = try JSONSerialization.data(withJSONObject: representation, options: [])
			
			return String(data: data, encoding: .utf8)
			
		} catch {
			return nil
		}
	}
}

extension Array: JSONSerializable {
	
	public var JSONRepresentation: Any {
		var representation = [Any]()
		
		for value in self {
			switch value {
				
			case let value as JSONRepresentable:
				representation.append(value.JSONRepresentation)
				
			case let value where JSONSerialization.isValidJSONObject([value]):
				representation.append(value)
				
			default:
				print("[Array.JSONSerializable.JSONRepresentation] *** WARNING – \(type(of: self)): OMITTING member '\(type(of: value))' w/ non-representable value: \(value)")
				break
			}
		}
		
		return representation
	}
}

extension Dictionary: JSONSerializable {
	
	public var JSONRepresentation: Any {
		var representation = [String : Any]()
		
		for case let (key as String, value) in self {
			switch value {
				
			case let value as JSONRepresentable:
				representation[key] = value.JSONRepresentation
				
			case let value where JSONSerialization.isValidJSONObject([value]):
				representation[key] = value
				
			default:
				print("[Dictionary.JSONSerializable.JSONRepresentation] *** WARNING – \(type(of: self)): OMITTING member '\(key): \(type(of: value))' w/ non-representable value: \(value)")
				break
			}
		}
		
		return representation
	}
}


// MARK: - JSONRepresentable extensions (for "single-value"/primitive types)

extension Date: JSONRepresentable {
	
	/// Date conforming to ISO 8601 for use in JSON data structures
	
	public static let JSONDateFormatter: DateFormatter = {
		let fm = DateFormatter()
		fm.locale		= Locale(identifier: "en_US_POSIX")
		fm.timeZone		= TimeZone(secondsFromGMT: 0)
		fm.dateFormat	= "YYYY-MM-dd'T'HH:mm:ss.SSS'Z'";
		return fm
	}()
	
	public static func fromJSON(_ representation: String) -> Date? {
		
		return self.JSONDateFormatter.date(from: representation)
	}
	
	public var JSONRepresentation: Any {
		
		return Date.JSONDateFormatter.string(from: self)
	}
}

extension URL: JSONRepresentable {
	
	public var JSONRepresentation: Any {
		
		return self.absoluteString
	}
}
