//
//  ObjectMergerTests.swift
//  MoreCodableTests
//
//  Created by Tatsuya Tanaka on 20180302.
//  Copyright © 2018年 tattn. All rights reserved.
//

import XCTest
import MoreCodable

class ObjectMergerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSimpleCase() throws {
        struct APIResponse: Encodable {
            let id: Int
            let title: String
            let foo: String
        }

        struct APIResponse2: Encodable {
            let tags: [String]
        }

        struct Model: Decodable {
            let id: Int
            let title: String
            let tags: [String]
        }

        let response = APIResponse(id: 0, title: "Awesome article", foo: "bar")
        let response2 = APIResponse2(tags: ["swift", "ios", "macos"])
        let model = try ObjectMerger().merge(Model.self, response, response2)

        XCTAssertEqual(model.id, response.id)
        XCTAssertEqual(model.title, response.title)
        XCTAssertEqual(model.tags, response2.tags)
    }
}
