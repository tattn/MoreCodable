//
//  MoreJSONDecoder.swift
//  MoreCodableTests
//
//  Created by Daniil Pendikov on 25/05/2019.
//  Copyright © 2019 tattn. All rights reserved.
//

import XCTest
@testable import MoreCodable

fileprivate struct Document: Codable {
    var date: Date
    var dateTime: Date
    var timestamp: Date
    var timestampMilliseconds: Date
    var custom: Date
}

extension Document: MultiDateFormat {
    
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter
    }()
    
    static func dateFormat(for codingKey: CodingKey) -> DateFormat? {
        switch codingKey {
        case CodingKeys.date: return .formatted(dateFormatter)
        case CodingKeys.dateTime: return .iso8601
        case CodingKeys.timestamp: return .secondsSince1970
        case CodingKeys.timestampMilliseconds: return .millisecondsSince1970
        case CodingKeys.custom: return .custom({ (date, encoder) in
            var container = encoder.singleValueContainer()
            try container.encode(String(date.timeIntervalSince1970))
        }, { (decoder) -> Date in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            let timeInterval = TimeInterval(string)!
            return Date(timeIntervalSince1970: timeInterval)
        })
        default: return nil
        }
    }
    
}

fileprivate let json = """
{
"date": "2019.05.27",
"dateTime": "2019-05-27T17:26:59+0000",
"timestamp": 1558978068,
"timestampMilliseconds": 1558978141863,
"custom": "1558978068"
}
"""

class MoreJSONDecoderTests: XCTestCase {
    
    func testDecodeSimpleModel() throws {
        struct User: Codable {
            let name: String
            let age: Int
        }
        let user = User(name: "Tatsuya Tanaka", age: 24)
        let data = try MoreJSONEncoder().encode(user)
        XCTAssertGreaterThan(data.count, 0)
        let decoded = try MoreJSONDecoder().decode(User.self, from: data)
        XCTAssertEqual(decoded.name, user.name)
        XCTAssertEqual(decoded.age, user.age)
    }
    
    func testSimpleMultiDateFormat() throws {
        let data = json.data(using: .utf8)!
        let document = try MoreJSONDecoder().decode(Document.self, from: data)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let dates = [document.date, document.dateTime, document.timestamp, document.timestampMilliseconds, document.custom]
        
        for date in dates {
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            XCTAssertEqual(components.year, 2019)
            XCTAssertEqual(components.month, 5)
            XCTAssertEqual(components.day, 27)
        }
    }

}
