//
//  CodableDictionaryTests.swift
//  MoreCodableTests
//
//  Created by Tatsuya Tanaka on 20180909.
//  Copyright © 2018年 tattn. All rights reserved.
//

import XCTest
import MoreCodable

class CodableDictionaryTests: XCTestCase {

    let jsonEncoder = JSONEncoder()
    let jsonDecoder = JSONDecoder()
    
    override func setUp() {
        super.setUp()
    }
    
    func testEnumKey() {
        enum Key: String, Codable, CodingKey {
            case foo
        }

        let originalEnumKeyedDictionary: [Key: Int] = [
            .foo: 100
        ]

        let enumKeyedDictionary: CodableDictionary<Key, Int> = [
            .foo: 100
        ]

        let json = "{\"foo\":100}"
        let unexpectedJSON = "[\"foo\",100]"

        do {
            let encodedData = try! jsonEncoder.encode(originalEnumKeyedDictionary)
            let encodedJSON = String(data: encodedData, encoding: .utf8)!
            XCTAssertEqual(encodedJSON, unexpectedJSON)
        }

        do {
            let encodedData = try! jsonEncoder.encode(enumKeyedDictionary)
            let encodedJSON = String(data: encodedData, encoding: .utf8)!
            XCTAssertEqual(encodedJSON, json)
        }

        do {
            let data = unexpectedJSON.data(using: .utf8)!
            let decoded = try! jsonDecoder.decode(type(of: originalEnumKeyedDictionary), from: data)
            XCTAssertEqual(decoded, originalEnumKeyedDictionary)
        }

        do {
            let data = json.data(using: .utf8)!
            let decoded = try! jsonDecoder.decode(type(of: enumKeyedDictionary), from: data)
            XCTAssertEqual(decoded, enumKeyedDictionary)
        }
    }
}
