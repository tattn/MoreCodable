//
//  MoreJSONEncoderTests.swift
//  MoreCodableTests
//
//  Created by Daniil Pendikov on 25/05/2019.
//  Copyright © 2019 tattn. All rights reserved.
//

import XCTest
@testable import MoreCodable

class MoreJSONEncoderTests: XCTestCase {
    
    struct User: Codable {
        let name: String
        let age: Int
    }
    
    var encoder = MoreJSONEncoder()

    override func setUp() {
        encoder = MoreJSONEncoder()
    }
    
    func testDecodeSimpleModel() throws {
        let user = User(name: "Tatsuya Tanaka", age: 24)
        let data = try encoder.encode(user)
        XCTAssertGreaterThan(data.count, 0)
        let dic = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        XCTAssertEqual(user.name, dic["name"] as? String)
        XCTAssertEqual(user.age, dic["age"] as? Int)
        XCTAssertEqual(dic.keys.count, 2)
    }
    
    func testSimpleMultiDateFormat() throws {
        struct Doc: Codable, MultiDateFormat {
            
            static var dateFormatter1: DateFormatter = {
                let formatter = DateFormatter()
                formatter.timeZone = TimeZone(identifier: "UTC")
                formatter.dateFormat = "yyyy-MM-dd-HH-mm"
                return formatter
            }()
            
            static var dateFormatter2: DateFormatter = {
                let formatter = DateFormatter()
                formatter.timeZone = TimeZone(identifier: "UTC")
                formatter.dateFormat = "yyyy.MM.dd.HH.mm"
                return formatter
            }()
            
            var id: String
            var date1: Date
            var date2: Date
            
            static func dateFormat(for codingKey: CodingKey) -> DateFormat? {
                switch codingKey {
                case CodingKeys.date1: return .formatted(dateFormatter1)
                case CodingKeys.date2: return .formatted(dateFormatter2)
                default: return nil
                }
            }
            
        }
        let numSecondsInYear: TimeInterval = 365 * 24 * 60 * 60
        let doc = Doc(id: "1", date1: Date(timeIntervalSince1970: 0),
                      date2: Date(timeIntervalSince1970: numSecondsInYear * 1.5))
        let data = try encoder.encode(doc)
        XCTAssertGreaterThan(data.count, 0)
        let dic = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        XCTAssertGreaterThan(data.count, 0)
        XCTAssertEqual(dic["id"] as? String, doc.id)
        XCTAssertEqual((dic["date1"] as? String)?.contains("1970"), true)
        XCTAssertEqual((dic["date2"] as? String)?.contains("1971"), true)
    }

    override func tearDown() {
        super.tearDown()
    }

}
