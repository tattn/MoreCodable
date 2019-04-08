//
//  DictionaryEncoderTests.swift
//  MoreCodableTests
//
//  Created by Tatsuya Tanaka on 20180211.
//  Copyright © 2018年 tattn. All rights reserved.
//

import XCTest
import MoreCodable

class DictionaryEncoderTests: XCTestCase {

    var encoder = DictionaryEncoder()

    struct User: Codable {
        let name: String
        let age: Int
    }
    
    override func setUp() {
        super.setUp()
        encoder = DictionaryEncoder()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testEncodeSimpleModel() throws {
        let user = User(name: "Tatsuya Tanaka", age: 24)
        let dictionary = try encoder.encode(user)
        XCTAssertEqual(user.name, dictionary["name"] as? String)
        XCTAssertEqual(user.age, dictionary["age"] as? Int)
        XCTAssertEqual(dictionary.keys.count, 2)
    }

    func testEncodeNestedModel() throws {
        struct Article: Codable {
            let title: String
            let author: User
        }

        let user = User(name: "Tatsuya Tanaka", age: 24)
        let article = Article(title: "Swift Tips", author: user)
        let dictionary = try encoder.encode(article)
        XCTAssertEqual(article.title, dictionary["title"] as? String)
        XCTAssertEqual(dictionary.keys.count, 2)

        let dictionaryAuthor = dictionary["author"] as! [String: Any]
        XCTAssertEqual(article.author.name, dictionaryAuthor["name"] as? String)
        XCTAssertEqual(article.author.age, dictionaryAuthor["age"] as? Int)
        XCTAssertEqual(dictionaryAuthor.keys.count, 2)
    }

    func testEncodeOptionalValue() throws {
        struct Model: Codable {
            let int: Int?
            let string: String?
            let double: Double?
        }
        let seeds: [(model: Model, count: Int)] = [
            (model: Model(int: nil, string: nil, double: nil), count: 0),
            (model: Model(int: 100, string: nil, double: nil), count: 1),
            (model: Model(int: nil, string: "a", double: nil), count: 1),
            (model: Model(int: nil, string: nil, double: 0.5), count: 1),
            (model: Model(int: 100, string: "a", double: nil), count: 2),
            (model: Model(int: nil, string: "a", double: 0.5), count: 2),
            (model: Model(int: 100, string: nil, double: 0.5), count: 2),
            (model: Model(int: 100, string: "a", double: 0.5), count: 3),
        ]
        do {
            let dictionary = try encoder.encode(seeds[0].model)
            XCTAssertNil(dictionary["int"])
            XCTAssertNil(dictionary["string"])
            XCTAssertNil(dictionary["double"])
        }
        for seed in seeds {
            let dictionary = try encoder.encode(seed.model)
            XCTAssertEqual(seed.model.int, dictionary["int"] as? Int)
            XCTAssertEqual(seed.model.string, dictionary["string"] as? String)
            XCTAssertEqual(seed.model.double, dictionary["double"] as? Double)
            XCTAssertEqual(dictionary.keys.count, seed.count)
        }
    }

    func testEncodeArray() throws {
        XCTAssertThrowsError(try encoder.encode([1, 2, 3]))
    }

    func testEncodeAndDecode() throws {
        struct Model: Codable, Equatable {
            let int: Int?
            let string: String?
            let double: Double?
        }
        let value = Model(int: 1, string: nil, double: 0.5)
        let encodedValue = try encoder.encode(value)
        let decodedValue = try DictionaryDecoder().decode(Model.self, from: encodedValue)
        XCTAssertEqual(value, decodedValue)
    }
}
