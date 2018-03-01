//
//  StringToTests.swift
//  MoreCodableTests
//
//  Created by Tatsuya Tanaka on 20180221.
//  Copyright © 2018年 tattn. All rights reserved.
//

import XCTest
@testable import MoreCodable

class StringToTests: XCTestCase {

    let json = """
{
    "int": "100",
    "articleId": "abc"
}
""".data(using: .utf8)!

    struct Root: Codable {
        let int: StringTo<Int>
        let articleId: StringTo<ArticleId>

        struct ArticleId: LosslessStringConvertible, Codable {
            var description: String

            init?(_ description: String) {
                self.description = description
            }
        }
    }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testExample() {
        let decoder = JSONDecoder()
        let root = try! decoder.decode(Root.self, from: json)
        XCTAssertEqual(root.int.value, 100)
        XCTAssertEqual(root.articleId.value.description, "abc")
    }

}

