//
//  MoreJSONEncoderTests.swift
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

class MoreJSONEncoderTests: XCTestCase {
    
    func testEncodeSimpleModel() throws {
        struct User: Codable {
            let name: String
            let age: Int
        }
        let user = User(name: "Tatsuya Tanaka", age: 24)
        let data = try MoreJSONEncoder().encode(user)
        XCTAssertGreaterThan(data.count, 0)
        let dic = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        XCTAssertEqual(user.name, dic["name"] as? String)
        XCTAssertEqual(user.age, dic["age"] as? Int)
        XCTAssertEqual(dic.keys.count, 2)
    }
    
    func testSimpleMultiDateFormat() throws {
        let date = Date(timeIntervalSince1970: 0)
        let document = Document(date: date, dateTime: date, timestamp: date, timestampMilliseconds: date, custom: date)
        let data = try MoreJSONEncoder().encode(document)
        let dic = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        
        XCTAssertTrue(dic["date"] is String)
        XCTAssertTrue(dic["dateTime"] is String)
        XCTAssertTrue(dic["timestamp"] is Double)
        XCTAssertTrue(dic["timestampMilliseconds"] is Double)
        XCTAssertTrue(dic["custom"] is String)
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let decoded = try! MoreJSONDecoder().decode(Document.self, from: data)
        for date in [decoded.date, decoded.dateTime, decoded.timestamp, decoded.timestampMilliseconds, decoded.custom] {
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            XCTAssertEqual(components.year, 1970)
            XCTAssertEqual(components.month, 1)
            XCTAssertEqual(components.day, 1)
        }
        
    }
}
