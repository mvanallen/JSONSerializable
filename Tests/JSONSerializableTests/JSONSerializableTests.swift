//
//  JSONSerializableTests.swift
//  ReactiveCode Studios
//
//  Created by Michael VanAllen on 29.03.17.
//  Copyright © 2017 ReactiveCode Studios. All rights reserved.
//

import Foundation
import XCTest
import JSONSerializable


class JSONSerializableTests: XCTestCase {
	
	struct BoxStruct: JSONSerializable {
		let url: URL
		var date: Date
		var things: [ThingsStruct]
		var items: [String : ItemStruct]
	}
	
	struct ThingsStruct: JSONSerializable {
		var a: String
		var b: [String]
		var c: [String : String]
		var d: Int
		var e: Bool
		var f: NSNull
		
		var item: ItemStruct
	}
	
	struct ItemStruct: JSONSerializable {
		var name: String
	}
	
	// MARK: Setup / Teardown
	
	override func setUp() {
		super.setUp()
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
	
	// MARK: - Arrays
	
	func testArrayWithSupportedTypes() {
		let array: [Any] = [ "one", 2, true, NSNull(), ["three", "four"], ["five": "six"]]
		
		print("\n### ArrayWithSupportedTypes (raw) : \n\(array)")
		
		var notNil = false
		if let json = array.toJSON() {
			notNil = true
			
			print("### ArrayWithSupportedTypes (json): \n\(json)")
			
			let expected = "[\"one\",2,true,null,[\"three\",\"four\"],{\"five\":\"six\"}]"
			XCTAssertEqual(json, expected)
		}
		
		XCTAssertTrue(notNil)
	}
	
	func testArrayWithUnsupportedType() {
		let array: [Any] = [ "one", "Data".data(using: .utf8)! ]
		
		print("\n### ArrayWithUnsupportedType (raw) : \n\(array)")
		
		var notNil = false
		if let json = array.toJSON() {
			notNil = true
			
			print("### ArrayWithUnsupportedType (json): \n\(json)")
			
			let expected = "[\"one\"]"
			XCTAssertEqual(json, expected)
		}
		
		XCTAssertTrue(notNil)
	}
	
	func testArrayWithJSONSerializableStructs() {
		let array: [Any] = [ItemStruct(name: "one"), ItemStruct(name: "two")]
		
		print("\n### testArrayWithStructs (raw) : \n\(array)")
		
		var notNil = false
		if let json = array.toJSON() {
			notNil = true
			
			print("### testArrayWithStructs (json): \n\(json)")
			
			let expected = "[{\"name\":\"one\"},{\"name\":\"two\"}]"
			XCTAssertEqual(json, expected)
		}
		
		XCTAssertTrue(notNil)
	}
	
	// MARK: Dictionaries
	
	func testDictionaryWithSupportedTypes() {
		let dict: [String : Any] = ["a" : "one", "b" : 2, "c" : true, "d" : NSNull(), "e" : ["three", "four"], "f" : ["five": "six"] ]
		
		print("\n### DictionaryWithSupportedTypes (raw) : \n\(dict)")
		
		var notNil = false
		if let json = dict.toJSON() {
			notNil = true
			
			print("### DictionaryWithSupportedTypes (json): \n\(json)")
			
			let jsonDict: [String : Any] = try! JSONSerialization.jsonObject(with: json.data(using: .utf8)!, options: []) as! [String : Any]
			XCTAssertEqual(jsonDict["a"] as? String,					dict["a"] as? String)
			XCTAssertEqual(jsonDict["b"] as? Int,						dict["b"] as? Int)
			XCTAssertEqual(jsonDict["c"] as? Bool,						dict["c"] as? Bool)
			XCTAssertEqual(jsonDict["d"] as? NSNull,					dict["d"] as? NSNull)
			XCTAssertEqual(jsonDict["e"] as! Array<String>,				dict["e"] as! Array<String>)
			XCTAssertEqual(jsonDict["f"] as! Dictionary<String, String>,dict["f"] as! Dictionary<String, String>)
			
			//let expected = "{\"b\":2,\"e\":[\"three\",\"four\"],\"a\":\"one\",\"f\":{\"five\":\"six\"},\"d\":null,\"c\":true}"
			//XCTAssertEqual(json, expected)
		}
		
		XCTAssertTrue(notNil)
	}
	
	func testDictionaryWithUnsupportedType() {
		let dict: [String : Any] = ["a" : "one", "b" : "Data".data(using: .utf8)! ]
		
		print("\n### DictionaryWithUnsupportedType (raw) : \n\(dict)")
		
		var notNil = false
		if let json = dict.toJSON() {
			notNil = true
			
			print("### DictionaryWithUnsupportedType (json): \n\(json)")
			
			let expected = "{\"a\":\"one\"}"
			XCTAssertEqual(json, expected)
		}
		
		XCTAssertTrue(notNil)
	}
	
	func testDictionaryWithJSONSerializableStructs() {
		let dict: [String : Any] = ["a" : ItemStruct(name: "one"), "b" : ItemStruct(name: "two")]
		
		print("\n### DictionaryWithJSONSerializableStructs (raw) : \n\(dict)")
		
		var notNil = false
		if let json = dict.toJSON() {
			notNil = true
			
			print("### DictionaryWithJSONSerializableStructs (json): \n\(json)")
			
			let jsonDict: [String : Any] = try! JSONSerialization.jsonObject(with: json.data(using: .utf8)!, options: []) as! [String : Any]
			XCTAssertEqual((jsonDict["a"] as! Dictionary<String, String>)["name"], (dict["a"] as? ItemStruct)?.name)
			XCTAssertEqual((jsonDict["b"] as! Dictionary<String, String>)["name"], (dict["b"] as? ItemStruct)?.name)
			
			//let expected = "{\"b\":{\"name\":\"two\"},\"a\":{\"name\":\"one\"}}"
			//XCTAssertEqual(json, expected)
		}
		
		XCTAssertTrue(notNil)
	}
	
	// MARK: Structs
	
	func testJSONSerializableStruct() {
		let someThings = ThingsStruct(a: "one", b: ["two", "three"], c: ["four" : "five"], d: 6, e: true, f: NSNull(), item: ItemStruct(name: "Widget"))
		let moreThings = ThingsStruct(a: "six", b: ["seven", "eight"], c: ["nine" : "ten"], d: 0, e: false, f: NSNull(), item: ItemStruct(name: "Sprocket"))
		
		let box = BoxStruct(url: URL(string: "http://boxes.org")!, date: Date(), things: [someThings, moreThings], items: ["drink": ItemStruct(name: "KoolAid"), "snack": ItemStruct(name: "Snickers")])
		/*
		print("### Things:")
		print(things.JSONRepresentation)
		
		print("### More things:")
		print(moreThings.JSONRepresentation)
		
		print("### Box:")
		print(box.JSONRepresentation)
		*/
		print("\n### BOX: \n\(box)\n")
		
		var notNil = false
		if let json = box.toJSON() {
			notNil = true
			
			print("### JSON: \n\(json)\n")
			
			XCTAssert(true)
		}
		
		XCTAssertTrue(notNil)
	}
}

#if os(Linux)
extension JSONSerializableTests {
	static var allTests : [(String, (JSONSerializableTests) -> () throws -> Void)] {
		return [
			("testArrayWithSupportedTypes", testArrayWithSupportedTypes),
			("testArrayWithUnsupportedType", testArrayWithUnsupportedType),
			("testArrayWithJSONSerializableStructs", testArrayWithJSONSerializableStructs),
			("testDictionaryWithSupportedTypes", testDictionaryWithSupportedTypes),
			("testDictionaryWithUnsupportedType", testDictionaryWithUnsupportedType),
			("testDictionaryWithJSONSerializableStructs", testDictionaryWithJSONSerializableStructs),
			("testJSONSerializableStruct", testJSONSerializableStruct)
		]
	}
}
#endif
