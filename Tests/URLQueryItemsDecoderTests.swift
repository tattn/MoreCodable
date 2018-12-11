//
//  URLQueryItemsDecoderTests.swift
//  MoreCodableTests
//
//  Created by Tatsuya Tanaka on 20180212.
//  Copyright © 2018年 tattn. All rights reserved.
//

import XCTest
import MoreCodable

class URLQueryItemsDecoderTests: XCTestCase {

    var decoder = URLQueryItemsDecoder()

    override func setUp() {
        super.setUp()
        decoder = URLQueryItemsDecoder()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testDecodeSimpleParameter() throws {
        struct Parameter: Codable {
            let string: String
            let int: Int
            let double: Double
        }
        let params: [URLQueryItem] = [
            URLQueryItem(name: "string", value: "abc"),
            URLQueryItem(name: "int", value: "123"),
            URLQueryItem(name: "double", value: Double.pi.description)
        ]
        let parameter = try decoder.decode(Parameter.self, from: params)

        XCTAssertEqual(parameter.string, params[0].value)
        XCTAssertEqual(parameter.int.description, params[1].value)
        XCTAssertEqual(parameter.double.description, params[2].value)
        
    }
    
    func testDecodeOptionalParameter() throws {
        struct Parameter: Codable {
            let string: String?
            let int: Int?
            let double: Double?
        }
        let params: [URLQueryItem] = [
            URLQueryItem(name: "string", value: "abc"),
            URLQueryItem(name: "int", value: "123"),
            URLQueryItem(name: "double", value: Double.pi.description)
        ]
        let parameter = try decoder.decode(Parameter.self, from: params)
        
        XCTAssertEqual(parameter.string, params[0].value)
        XCTAssertEqual(parameter.int?.description, params[1].value)
        XCTAssertEqual(parameter.double?.description, params[2].value)
    }
    
    func testDecodeEmptyOptionalParameter() throws {
        struct Parameter: Codable {
            let string: String?
            let int: Int?
            let double: Double?
        }
        let params: [URLQueryItem] = [
        ]
        let parameter = try decoder.decode(Parameter.self, from: params)
        
        XCTAssertEqual(parameter.string, nil)
        XCTAssertEqual(parameter.int, nil)
        XCTAssertEqual(parameter.double, nil)
    }
}
