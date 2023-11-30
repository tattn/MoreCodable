//
//  FailableTests.swift
//  MoreCodableTests
//
//  Created by Tatsuya Tanaka on 20180219.
//  Copyright © 2018年 tattn. All rights reserved.
//

import XCTest
import MoreCodable

class FailableTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testFailableArray() {
        let json = """
[
    {"name": "Taro", "age": 20},
    {"name": "Hanako", "age": "にゃーん"}
]
""".data(using: .utf8)!

        struct User: Codable {
            let name: String
            let age: Int
        }

        let users = try! JSONDecoder().decode([Failable<User>].self,
                                              from: json)

        XCTAssertEqual(users[0].value?.name, "Taro")
        XCTAssertEqual(users[0].value?.age, 20)
        XCTAssertNil(users[1].value)
    }

    func testFailableURL() {
        let json = """
{"url": "https://foo.com", "url2": "a://invalid url string"}
""".data(using: .utf8)!

        struct Model: Codable {
            let url: Failable<URL>
            let url2: Failable<URL>
        }

        let model = try! JSONDecoder().decode(Model.self,
                                              from: json)

        XCTAssertEqual(model.url.value?.absoluteString, "https://foo.com")
        XCTAssertNil(model.url2.value)
    }

}
