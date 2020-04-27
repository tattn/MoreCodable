import Foundation
import XCTest
import MoreCodable

class DictionaryCachableEncoderTests: XCTestCase {
    struct HashableUser: Encodable, Hashable {
        let name: String
        let age: Int
    }

    let hashableUser = HashableUser(name: "Tatsuya Tanaka", age: 24)

    let cache = DictionaryCachableEncoder.DefaultCache()

    func buildEncoder() -> DictionaryCachableEncoder {
        let encoder = DictionaryCachableEncoder()
        encoder.cache = cache
        return encoder
    }

    func testSimpleModel() throws {
        // First
        do {
            XCTAssertEqual(cache.storage.count, 0)

            let encoder = buildEncoder()
            let dictionary = try encoder.encode(hashableUser)
            XCTAssertEqual(hashableUser.name, dictionary["name"] as? String)
            XCTAssertEqual(hashableUser.age, dictionary["age"] as? Int)
            XCTAssertEqual(dictionary.keys.count, 2)

            XCTAssertEqual(cache.storage.count, 1)
        }

        // Second
        do {
            XCTAssertEqual(cache.storage.count, 1)

            let encoder = buildEncoder()
            let dictionary = try encoder.encode(hashableUser)
            XCTAssertEqual(hashableUser.name, dictionary["name"] as? String)
            XCTAssertEqual(hashableUser.age, dictionary["age"] as? Int)
            XCTAssertEqual(dictionary.keys.count, 2)

            XCTAssertEqual(cache.storage.count, 1)
        }
    }

    func testSimpleModelWithCustomUserInfo() throws {
        let encoder = buildEncoder()
        encoder.userInfoHasher = { _ in 0 }

        do {
            XCTAssertEqual(cache.storage.count, 0)
            _ = try encoder.encode(hashableUser)
            XCTAssertEqual(cache.storage.count, 1)
        }

        do {
            XCTAssertEqual(cache.storage.count, 1)
            _ = try encoder.encode(hashableUser)
            XCTAssertEqual(cache.storage.count, 1)
        }

        encoder.userInfoHasher = { _ in 1 }

        do {
            XCTAssertEqual(cache.storage.count, 1)
            _ = try encoder.encode(hashableUser)
            XCTAssertEqual(cache.storage.count, 2)
        }
    }

}
