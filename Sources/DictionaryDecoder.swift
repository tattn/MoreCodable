//
//  DictionaryDecoder.swift
//  MoreCodable
//
//  Created by Tatsuya Tanaka on 20180211.
//  Copyright © 2018年 tattn. All rights reserved.
//

import Foundation


open class DictionaryDecoder: Decoder {
    open var codingPath: [CodingKey]
    open var userInfo: [CodingUserInfoKey: Any] = [:]
    var storage = Storage()

    public init() {
        codingPath = []
    }

    public init(container: Any, codingPath: [CodingKey] = []) {
        storage.push(container: container)
        self.codingPath = codingPath
    }

    open func container<Key: CodingKey>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
        let container = try lastContainer(forType: [String: Any].self)
        return KeyedDecodingContainer(KeyedContainer<Key>(decoder: self, codingPath: [], container: try unboxRawType(container, as: [String: Any].self)))
    }

    open func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        let container = try lastContainer(forType: [Any].self)
        return UnkeyedContanier(decoder: self, container: try unboxRawType(container, as: [Any].self))
    }

    open func singleValueContainer() throws -> SingleValueDecodingContainer {
        return SingleValueContanier(decoder: self)
    }

    private func unboxRawType<T>(_ value: Any, as type: T.Type) throws -> T {
        let description = "Expected to decode \(type) but found \(Swift.type(of: value)) instead."
        let error = DecodingError.typeMismatch(T.self, DecodingError.Context(codingPath: codingPath, debugDescription: description))
        return try castOrThrow(T.self, value, error: error)
    }

    private func unbox<T: Decodable>(_ value: Any, as type: T.Type) throws -> T {
        do {
            return try unboxRawType(value, as: T.self)
        } catch {
            storage.push(container: value)
            defer { _ = storage.popContainer() }
            return try T(from: self)
        }
    }

    private func lastContainer<T>(forType type: T.Type) throws -> Any {
        guard let value = storage.last else {
            let description = "Expected \(type) but found nil value instead."
            let error = DecodingError.Context(codingPath: codingPath, debugDescription: description)
            throw DecodingError.valueNotFound(type, error)
        }
        return value
    }

    private func notFound(key: CodingKey) -> DecodingError {
        let error = DecodingError.Context(codingPath: codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\").")
        return DecodingError.keyNotFound(key, error)
    }
}

extension DictionaryDecoder {
    open func decode<T : Decodable>(_ type: T.Type, from container: Any) throws -> T {
        return try unbox(container, as: T.self)
    }
}

extension DictionaryDecoder {
    private class KeyedContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
        private var decoder: DictionaryDecoder
        private(set) var codingPath: [CodingKey]
        private var container: [String: Any]

        init(decoder: DictionaryDecoder, codingPath: [CodingKey], container: [String: Any]) {
            self.decoder = decoder
            self.codingPath = codingPath
            self.container = container
        }

        var allKeys: [Key] { return container.keys.compactMap { Key(stringValue: $0) } }
        func contains(_ key: Key) -> Bool { return container[key.stringValue] != nil }

        private func find(forKey key: CodingKey) throws -> Any {
            return try container.tryValue(forKey: key.stringValue, error: decoder.notFound(key: key))
        }

        func _decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
            let value = try find(forKey: key)
            decoder.codingPath.append(key)
            defer { decoder.codingPath.removeLast() }
            return try decoder.unbox(value, as: T.self)
        }

        func decodeNil(forKey key: Key) throws -> Bool { throw decoder.notFound(key: key) }
        func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool { return try _decode(type, forKey: key) }
        func decode(_ type: Int.Type, forKey key: Key) throws -> Int { return try _decode(type, forKey: key) }
        func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 { return try _decode(type, forKey: key) }
        func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 { return try _decode(type, forKey: key) }
        func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 { return try _decode(type, forKey: key) }
        func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 { return try _decode(type, forKey: key) }
        func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt { return try _decode(type, forKey: key) }
        func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 { return try _decode(type, forKey: key) }
        func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 { return try _decode(type, forKey: key) }
        func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 { return try _decode(type, forKey: key) }
        func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 { return try _decode(type, forKey: key) }
        func decode(_ type: Float.Type, forKey key: Key) throws -> Float { return try _decode(type, forKey: key) }
        func decode(_ type: Double.Type, forKey key: Key) throws -> Double { return try _decode(type, forKey: key) }
        func decode(_ type: String.Type, forKey key: Key) throws -> String { return try _decode(type, forKey: key) }
        func decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T { return try _decode(type, forKey: key) }

        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
            decoder.codingPath.append(key)
            defer { decoder.codingPath.removeLast() }

            let value = try find(forKey: key)
            let dictionary = try decoder.unboxRawType(value, as: [String: Any].self)
            return KeyedDecodingContainer(KeyedContainer<NestedKey>(decoder: decoder, codingPath: [], container: dictionary))
        }

        func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
            decoder.codingPath.append(key)
            defer { decoder.codingPath.removeLast() }

            let value = try find(forKey: key)
            let array = try decoder.unboxRawType(value, as: [Any].self)
            return UnkeyedContanier(decoder: decoder, container: array)
        }

        func _superDecoder(forKey key: CodingKey = AnyCodingKey.super) throws -> Decoder {
            decoder.codingPath.append(key)
            defer { decoder.codingPath.removeLast() }

            let value = try find(forKey: key)
            return DictionaryDecoder(container: value, codingPath: decoder.codingPath)
        }

        func superDecoder() throws -> Decoder {
            return try _superDecoder()
        }

        func superDecoder(forKey key: Key) throws -> Decoder {
            return try _superDecoder(forKey: key)
        }
    }

    private class UnkeyedContanier: UnkeyedDecodingContainer {
        private var decoder: DictionaryDecoder
        private(set) var codingPath: [CodingKey]
        private var container: [Any]

        var count: Int? { return container.count }
        var isAtEnd: Bool { return currentIndex >= count! }

        private(set) var currentIndex: Int
        private var currentCodingPath: [CodingKey] { return decoder.codingPath + [AnyCodingKey(index: currentIndex)] }

        init(decoder: DictionaryDecoder, container: [Any]) {
            self.decoder = decoder
            self.codingPath = decoder.codingPath
            self.container = container
            currentIndex = 0
        }

        private func checkIndex<T>(_ type: T.Type) throws {
            if isAtEnd {
                let error = DecodingError.Context(codingPath: currentCodingPath, debugDescription: "container is at end.")
                throw DecodingError.valueNotFound(T.self, error)
            }
        }

        func _decode<T: Decodable>(_ type: T.Type) throws -> T {
            try checkIndex(type)

            decoder.codingPath.append(AnyCodingKey(index: currentIndex))
            defer {
                decoder.codingPath.removeLast()
                currentIndex += 1
            }
            return try decoder.unbox(container[currentIndex], as: T.self)
        }

        func decodeNil() throws -> Bool {
            try checkIndex(Any?.self)
            return false
        }
        func decode(_ type: Bool.Type) throws -> Bool { return try _decode(type) }
        func decode(_ type: Int.Type) throws -> Int { return try _decode(type) }
        func decode(_ type: Int8.Type) throws -> Int8 { return try _decode(type) }
        func decode(_ type: Int16.Type) throws -> Int16 { return try _decode(type) }
        func decode(_ type: Int32.Type) throws -> Int32 { return try _decode(type) }
        func decode(_ type: Int64.Type) throws -> Int64 { return try _decode(type) }
        func decode(_ type: UInt.Type) throws -> UInt { return try _decode(type) }
        func decode(_ type: UInt8.Type) throws -> UInt8 { return try _decode(type) }
        func decode(_ type: UInt16.Type) throws -> UInt16 { return try _decode(type) }
        func decode(_ type: UInt32.Type) throws -> UInt32 { return try _decode(type) }
        func decode(_ type: UInt64.Type) throws -> UInt64 { return try _decode(type) }
        func decode(_ type: Float.Type) throws -> Float { return try _decode(type) }
        func decode(_ type: Double.Type) throws -> Double { return try _decode(type) }
        func decode(_ type: String.Type) throws -> String { return try _decode(type) }
        func decode<T: Decodable>(_ type: T.Type) throws -> T { return try _decode(type) }

        func nestedContainer<NestedKey: CodingKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> {
            decoder.codingPath.append(AnyCodingKey(index: currentIndex))
            defer { decoder.codingPath.removeLast() }

            try checkIndex(UnkeyedContanier.self)

            let value = container[currentIndex]
            let dictionary = try castOrThrow([String: Any].self, value)

            currentIndex += 1
            return KeyedDecodingContainer(KeyedContainer<NestedKey>(decoder: decoder, codingPath: [], container: dictionary))
        }

        func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
            decoder.codingPath.append(AnyCodingKey(index: currentIndex))
            defer { decoder.codingPath.removeLast() }

            try checkIndex(UnkeyedContanier.self)

            let value = container[currentIndex]
            let array = try castOrThrow([Any].self, value)

            currentIndex += 1
            return UnkeyedContanier(decoder: decoder, container: array)
        }

        func superDecoder() throws -> Decoder {
            decoder.codingPath.append(AnyCodingKey(index: currentIndex))
            defer { decoder.codingPath.removeLast() }

            try checkIndex(UnkeyedContanier.self)

            let value = container[currentIndex]
            currentIndex += 1
            return DictionaryDecoder(container: value, codingPath: decoder.codingPath)
        }
    }

    private class SingleValueContanier: SingleValueDecodingContainer {
        private var decoder: DictionaryDecoder
        private(set) var codingPath: [CodingKey]

        init(decoder: DictionaryDecoder) {
            self.decoder = decoder
            self.codingPath = decoder.codingPath
        }

        func _decode<T>(_ type: T.Type) throws -> T {
            let container = try decoder.lastContainer(forType: type)
            return try decoder.unboxRawType(container, as: T.self)
        }

        func decodeNil() -> Bool { return decoder.storage.last == nil }
        func decode(_ type: Bool.Type) throws -> Bool { return try _decode(type) }
        func decode(_ type: Int.Type) throws -> Int { return try _decode(type) }
        func decode(_ type: Int8.Type) throws -> Int8 { return try _decode(type) }
        func decode(_ type: Int16.Type) throws -> Int16 { return try _decode(type) }
        func decode(_ type: Int32.Type) throws -> Int32 { return try _decode(type) }
        func decode(_ type: Int64.Type) throws -> Int64 { return try _decode(type) }
        func decode(_ type: UInt.Type) throws -> UInt { return try _decode(type) }
        func decode(_ type: UInt8.Type) throws -> UInt8 { return try _decode(type) }
        func decode(_ type: UInt16.Type) throws -> UInt16 { return try _decode(type) }
        func decode(_ type: UInt32.Type) throws -> UInt32 { return try _decode(type) }
        func decode(_ type: UInt64.Type) throws -> UInt64 { return try _decode(type) }
        func decode(_ type: Float.Type) throws -> Float { return try _decode(type) }
        func decode(_ type: Double.Type) throws -> Double { return try _decode(type) }
        func decode(_ type: String.Type) throws -> String { return try _decode(type) }
        func decode<T: Decodable>(_ type: T.Type) throws -> T {
            let container = try decoder.lastContainer(forType: type)
            return try decoder.unbox(container, as: T.self)
        }
    }
}
