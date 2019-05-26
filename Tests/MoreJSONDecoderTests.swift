//
//  MoreJSONDecoder.swift
//  MoreCodableTests
//
//  Created by Daniil Pendikov on 25/05/2019.
//  Copyright © 2019 tattn. All rights reserved.
//

import XCTest
@testable import MoreCodable

class MoreJSONDecoderTests: XCTestCase {
    
    var decoder = MoreJSONDecoder()

    struct User: Codable {
        let name: String
        let age: Int
    }
    
    override func setUp() {
        decoder = MoreJSONDecoder()
    }
    
    func testDecodeSimpleModel() throws {
        let user = User(name: "Tatsuya Tanaka", age: 24)
        let data = try MoreJSONEncoder().encode(user)
        XCTAssertGreaterThan(data.count, 0)
        let decoded = try MoreJSONDecoder().decode(User.self, from: data)
        XCTAssertEqual(decoded.name, user.name)
        XCTAssertEqual(decoded.age, user.age)
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
        let data = try MoreJSONEncoder().encode(doc)
        XCTAssertGreaterThan(data.count, 0)
        let decoded = try MoreJSONDecoder().decode(Doc.self, from: data)
        XCTAssertGreaterThan(data.count, 0)
        XCTAssertEqual(decoded.id, doc.id)
        XCTAssertEqual(decoded.date1, doc.date1)
        XCTAssertEqual(decoded.date2, doc.date2)
    }
    
    override func tearDown() {
        super.tearDown()
    }

}
