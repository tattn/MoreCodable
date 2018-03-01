//
//  URLQueryItemsEncoderTests.swift
//  MoreCodable
//
//  Created by Tatsuya Tanaka on 20180212.
//  Copyright © 2018年 tattn. All rights reserved.
//

import XCTest
import MoreCodable

class URLQueryItemsEncoderTests: XCTestCase {

    var encoder = URLQueryItemsEncoder()

    override func setUp() {
        super.setUp()
        encoder = URLQueryItemsEncoder()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testEncodeSimpleParameter() throws {
        struct Parameter: Codable {
            let query: String
            let offset: Int
            let limit: Int
        }
        let parameter = Parameter(query: "ねこ", offset: 10, limit: 20)
        let params: [URLQueryItem] = try encoder.encode(parameter)
        XCTAssertEqual("query", params[0].name)
        XCTAssertEqual(parameter.query, params[0].value)
        XCTAssertEqual("offset", params[1].name)
        XCTAssertEqual(parameter.offset.description, params[1].value)
        XCTAssertEqual("limit", params[2].name)
        XCTAssertEqual(parameter.limit.description, params[2].value)

        var components = URLComponents(string: "https://example.com")
        components?.queryItems = params
        XCTAssertEqual(components?.url?.absoluteString, "https://example.com?query=%E3%81%AD%E3%81%93&offset=10&limit=20")
    }
}
