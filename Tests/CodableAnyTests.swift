//
//  CodableAnyTests.swift
//  MoreCodableTests
//
//  Created by Tatsuya Tanaka on 20180909.
//  Copyright © 2018年 tattn. All rights reserved.
//

import XCTest
import MoreCodable

class CodableAnyTests: XCTestCase {
    let jsonEncoder = JSONEncoder()
    let jsonDecoder = JSONDecoder()

    override func setUp() {
        super.setUp()
    }

    func testInt() {
        assertEncodingAndDecoding(["value": 1])
    }

    func testStringIntDictionary() {
        assertEncodingAndDecoding(["value": ["key": 1]])
    }

    func testDoubleArray() {
        assertEncodingAndDecoding([1.1, 2.2, 3.3])

        let decodedValue = encodeAndDecode([1, 2, 3] as [Double])
        XCTAssertEqual(decodedValue as! [Int], [1, 2, 3]) // double to int
    }

    func testNestedArray() {
        assertEncodingAndDecoding([[[["one", "two", "three"]]]])
    }

    func testOptional() {
        let decodedValue = encodeAndDecode([nil, 1, nil])
        let values = decodedValue as! [Any]
        XCTAssertNotNil(values[0])
        XCTAssertTrue(values[0] is Void)
        XCTAssertEqual(values[1] as! Int, 1)
        XCTAssertNotNil(values[2])
        XCTAssertTrue(values[2] is Void)
    }

    func testDate() {
        let date = Date()
        let decodedValue = encodeAndDecode(["key": date])
        XCTAssertEqual(decodedValue as! [String: Double], ["key": date.timeIntervalSinceReferenceDate]) // date to double
    }

    func testURL() {
        let url = URL(string: "https://example.com")!
        let decodedValue = encodeAndDecode(["key": url])
        XCTAssertEqual(decodedValue as! [String: String], ["key": url.absoluteString]) // url to string
    }

    private func encodeAndDecode(_ value: Any) -> Any {
        let _any = CodableAny(value)
        let data = try! jsonEncoder.encode(_any)
        return (try! jsonDecoder.decode(CodableAny.self, from: data)).value
    }

    private func assertEncodingAndDecoding<T: Equatable>(_ expectedValue: T) {
        let decodedValue = encodeAndDecode(expectedValue)
        XCTAssertEqual(decodedValue as! T, expectedValue)
    }
}
