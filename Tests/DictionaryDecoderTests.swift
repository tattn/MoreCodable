//
//  DictionaryDecoderTests.swift
//  MoreCodable
//
//  Created by Tatsuya Tanaka on 20180211.
//  Copyright © 2018年 tattn. All rights reserved.
//

import XCTest
@testable import MoreCodable

class DictionaryDecoderTests: XCTestCase {

    var decoder = DictionaryDecoder()

    override func setUp() {
        super.setUp()
        decoder = DictionaryDecoder()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testDecodeSimpleModel() throws {
        struct User: Codable {
            let name: String
            let age: Int
        }

        let dictionary: [String: Any] = [
            "name": "Tatsuya Tanaka",
            "age": 24
        ]
        let user = try decoder.decode(User.self, from: dictionary)
        XCTAssertEqual(user.name, dictionary["name"] as? String)
        XCTAssertEqual(user.age, dictionary["age"] as? Int)
    }

    func testFailDecoding() {
        decoder.storage.push(container: "string"); do {
            let container = try! decoder.singleValueContainer()
            XCTAssertNil(try? container.decode(Bool.self))
        }

        struct CustomType: Decodable {
            let value: Int = 0
        }
        decoder = DictionaryDecoder()
        decoder.storage.push(container: CustomType()); do {
            let container = try! decoder.singleValueContainer()
            XCTAssertNil(try? container.decode(Bool.self))
        }
    }

    func testOptionalValues() throws {
        struct Model: Codable, Equatable {
            let int: Int?
            let string: String?
            let double: Double?
        }

        XCTAssertEqual(try decoder.decode(Model.self, from: ["int": 0, "string": "test"]), Model(int: 0, string: "test", double: nil))
        XCTAssertEqual(try decoder.decode(Model.self, from: ["double": 0.5, "string": "test"]), Model(int: nil, string: "test", double: 0.5))
    }

    func testDate() throws {
        struct Model: Codable, Equatable {
            let date: Date
            let optionalDate: Date?
        }

        let date = Date(timeIntervalSince1970: 1234567890)
        decoder.dateDecodingStrategy = .deferredToDate
        XCTAssertEqual(try decoder.decode(Model.self, from: ["date": date.timeIntervalSinceReferenceDate]), Model(date: date, optionalDate: nil))

        decoder.dateDecodingStrategy = .secondsSince1970
        XCTAssertEqual(try decoder.decode(Model.self, from: ["date": date.timeIntervalSince1970]), Model(date: date, optionalDate: nil))

        decoder.dateDecodingStrategy = .millisecondsSince1970
        XCTAssertEqual(try decoder.decode(Model.self, from: ["date": date.timeIntervalSince1970 * 1000]), Model(date: date, optionalDate: nil))

        if #available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *) {
            decoder.dateDecodingStrategy = .iso8601
            XCTAssertEqual(try decoder.decode(Model.self, from: ["date": date.ISO8601Format()]), Model(date: date, optionalDate: nil))
        }

        do {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            XCTAssertEqual(try decoder.decode(Model.self, from: ["date": dateFormatter.string(from: date)]), Model(date: date, optionalDate: nil))
        }

        decoder.dateDecodingStrategy = .custom { decoder in
            let contaienr = try decoder.singleValueContainer()
            return try contaienr.decode(Int.self) == 13 ? date : date.addingTimeInterval(.infinity)
        }
        XCTAssertEqual(try decoder.decode(Model.self, from: ["date": 13]), Model(date: date, optionalDate: nil))
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
