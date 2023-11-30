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

    func testEncodingMultipleTimesUsingTheSameEncoder() throws {
        struct Element1: Codable, Equatable {
            let p1: String
        }

        struct Element2: Codable, Equatable {
            let p2: String
        }

        struct ComplexStruct: Codable, Equatable {
            let element1: Element1
            let element2: Element2

            init(element1: Element1, element2: Element2) {
                self.element1 = element1
                self.element2 = element2
            }

            func encode(to encoder: Encoder) throws {
                try element1.encode(to: encoder)
                try element2.encode(to: encoder)
            }

            init(from decoder: Decoder) throws {
                self.element1 = try Element1(from: decoder)
                self.element2 = try Element2(from: decoder)
            }
        }

        let object = ComplexStruct(element1: .init(p1: "p1"), element2: .init(p2: "p2"))
        let expected = ["p1": "p1", "p2": "p2"]
        let result = try encoder.encode(object)
        XCTAssertEqual(result as? [String: String], expected)
    }

    func testEncodeDate() throws {
        struct Model: Codable {
            let date: Date
            let optionalDate: Date?
        }
        let date = Date(timeIntervalSince1970: 1234567890)
        let seeds: [(model: Model, count: Int)] = [
            (model: Model(date: date, optionalDate: nil), count: 1),
            (model: Model(date: date, optionalDate: date), count: 2),
        ]
        for seed in seeds {
            encoder.dateEncodingStrategy = .deferredToDate
            var dictionary = try encoder.encode(seed.model)
            XCTAssertEqual(dictionary["date"] as? Double, seed.model.date.timeIntervalSinceReferenceDate)
            XCTAssertEqual(dictionary["optionalDate"] as? Double, seed.model.optionalDate?.timeIntervalSinceReferenceDate)
            XCTAssertEqual(dictionary.keys.count, seed.count)

            encoder.dateEncodingStrategy = .secondsSince1970
            dictionary = try encoder.encode(seed.model)
            XCTAssertEqual(dictionary["date"] as? TimeInterval, seed.model.date.timeIntervalSince1970)
            XCTAssertEqual(dictionary["optionalDate"] as? TimeInterval, seed.model.optionalDate?.timeIntervalSince1970)
            XCTAssertEqual(dictionary.keys.count, seed.count)

            encoder.dateEncodingStrategy = .millisecondsSince1970
            dictionary = try encoder.encode(seed.model)
            XCTAssertEqual(dictionary["date"] as? TimeInterval, seed.model.date.timeIntervalSince1970 * 1000)
            XCTAssertEqual(dictionary["optionalDate"] as? TimeInterval, seed.model.optionalDate.map { $0.timeIntervalSince1970 * 1000 })
            XCTAssertEqual(dictionary.keys.count, seed.count)

            if #available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *) {
            encoder.dateEncodingStrategy = .iso8601
            dictionary = try encoder.encode(seed.model)
                XCTAssertEqual(dictionary["date"] as? String, seed.model.date.ISO8601Format())
                XCTAssertEqual(dictionary["optionalDate"] as? String, seed.model.optionalDate?.ISO8601Format())
                XCTAssertEqual(dictionary.keys.count, seed.count)
            }

            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
            encoder.dateEncodingStrategy = .formatted(dateFormatter)
            dictionary = try encoder.encode(seed.model)
            XCTAssertEqual(dictionary["date"] as? String, dateFormatter.string(from: seed.model.date))
            XCTAssertEqual(dictionary["optionalDate"] as? String, seed.model.optionalDate.map(dateFormatter.string))
            XCTAssertEqual(dictionary.keys.count, seed.count)

            encoder.dateEncodingStrategy = .custom { date, encoder in
                var container = encoder.singleValueContainer()
                try container.encode(13)
            }
            dictionary = try encoder.encode(seed.model)
            XCTAssertEqual(dictionary["date"] as? Int, 13)
            XCTAssertEqual(dictionary["optionalDate"] as? Int, seed.model.optionalDate == nil ? nil : 13)
            XCTAssertEqual(dictionary.keys.count, seed.count)
        }
    }
}

#if os(Linux)
private extension Date {
    func ISO8601Format() -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
}
#endif
