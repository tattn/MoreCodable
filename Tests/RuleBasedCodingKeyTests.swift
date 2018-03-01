//
//  RuleBasedCodingKeyTests.swift
//  MoreCodableTests
//
//  Created by Tatsuya Tanaka on 20180221.
//  Copyright © 2018年 tattn. All rights reserved.
//

import XCTest
import MoreCodable

class RuleBasedCodingKeyTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testCustomRule() {
        struct User: Codable {
            let userId: String
            let name: String

            enum CodingKeys: String, RuleBasedCodingKey {
                case userId
                case name

                func codingKeyRule(key: String) -> String {
                    return key.uppercased()
                }
            }
        }

        let json = """
{"USERID": "abc", "NAME": "tattn"}
""".data(using: .utf8)!

        let decoder = JSONDecoder()
        let user = try! decoder.decode(User.self, from: json)

        XCTAssertEqual(user.userId, "abc")
        XCTAssertEqual(user.name, "tattn")
    }
    
    func testSnakeCase() {
        struct User: Codable {
            let userId: String
            let name: String

            enum CodingKeys: String, SnakeCaseCodingKey {
                case userId
                case name
            }
        }

        let json = """
{"user_id": "abc", "name": "Tatsuya Tanaka"}
""".data(using: .utf8)!

        let decoder = JSONDecoder()
        let user = try! decoder.decode(User.self, from: json)

        XCTAssertEqual(user.userId, "abc")
        XCTAssertEqual(user.name, "Tatsuya Tanaka")
    }

    func testUpperCamelCase() {
        struct User: Codable {
            let userId: String
            let name: String

            enum CodingKeys: String, UpperCamelCaseCodingKey {
                case userId
                case name
            }
        }

        let json = """
{"UserId": "abc", "Name": "Tatsuya Tanaka"}
""".data(using: .utf8)!

        let decoder = JSONDecoder()
        let user = try! decoder.decode(User.self, from: json)

        XCTAssertEqual(user.userId, "abc")
        XCTAssertEqual(user.name, "Tatsuya Tanaka")
    }
    
}
