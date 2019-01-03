//
//  URLQueryItemsDecoder.swift
//  MoreCodable
//
//  Created by Tatsuya Tanaka on 20180212.
//  Copyright © 2018年 tattn. All rights reserved.
//

import Foundation

open class URLQueryItemsDecoder: Decoder {
    open var codingPath: [CodingKey]
    open var userInfo: [CodingUserInfoKey: Any] = [:]
    private var storage = Storage()

    public init() {
        codingPath = []
    }

    public init(container: Any, codingPath: [CodingKey] = []) {
        storage.push(container: container)
        self.codingPath = codingPath
    }

    open func container<Key: CodingKey>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
        let container = try lastContainer(forType: [URLQueryItem].self)
        return KeyedDecodingContainer(KeyedContainer<Key>(decoder: self, codingPath: [], container: container))
    }

    open func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        let container = try lastContainer(forType: [URLQueryItem].self)
        return UnkeyedContanier(decoder: self, container: container)
    }

    open func singleValueContainer() throws -> SingleValueDecodingContainer {
        return SingleValueContainer(decoder: self)
    }

    private func unbox<T: Decodable>(_ value: Any, as type: T.Type) throws -> T {
        return try unbox(value, as: type, codingPath: codingPath)
    }

    private func unbox<T: Decodable>(_ value: Any, as type: T.Type, codingPath: [CodingKey]) throws -> T {
        let description = "Expected to decode \(type) but found \(Swift.type(of: value)) instead."
        let error = DecodingError.typeMismatch(T.self, DecodingError.Context(codingPath: codingPath, debugDescription: description))
        do {
            return try castOrThrow(T.self, value, error: error)
        } catch {
            storage.push(container: value)
            defer { _ = storage.popContainer() }
            return try T(from: self)
        }
    }

    private func lastContainer<T: Decodable>(forType type: T.Type) throws -> T {
        guard let value = storage.last else {
            let description = "Expected \(type) but found nil value instead."
            let error = DecodingError.Context(codingPath: codingPath, debugDescription: description)
            throw DecodingError.valueNotFound(type, error)
        }
        return try unbox(value, as: T.self)
    }

    private func notFound(key: CodingKey) -> DecodingError {
        let error = DecodingError.Context(codingPath: codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\").")
        return DecodingError.keyNotFound(key, error)
    }
}

extension URLQueryItemsDecoder {
    open func decode<T: Decodable>(_ type: T.Type, from container: [URLQueryItem]) throws -> T {
        storage.push(container: container)
        return try T(from: self)
    }
}

extension URLQueryItemsDecoder {
    private class KeyedContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
        private var decoder: URLQueryItemsDecoder
        private(set) var codingPath: [CodingKey]
        private var container: [URLQueryItem]

        init(decoder: URLQueryItemsDecoder, codingPath: [CodingKey], container: [URLQueryItem]) {
            self.decoder = decoder
            self.codingPath = codingPath
            self.container = container
        }

        var allKeys: [Key] { return container.compactMap { Key(stringValue: $0.name) } }
        func contains(_ key: Key) -> Bool { return container.contains(where: { $0.name == key.stringValue }) }

        private func find(forKey key: CodingKey) throws -> URLQueryItem {
            return try container.first(where: { $0.name == key.stringValue })
                .unwrapOrThrow(error: decoder.notFound(key: key))
        }
        
        private func contains(_ key: CodingKey) -> Bool {
            return container.contains(where: { $0.name == key.stringValue })
        }

        func _decode<T: Decodable & LosslessStringConvertible>(_ type: T.Type, forKey key: Key) throws -> T {
            let value = try find(forKey: key)
            decoder.codingPath.append(key)
            defer { decoder.codingPath.removeLast() }
            return try T.init(try value.value.unwrapOrThrow()).unwrapOrThrow()
        }

        func _decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
            let value = try find(forKey: key)
            decoder.codingPath.append(key)
            defer { decoder.codingPath.removeLast() }
            return try decoder.unbox(value, as: T.self)
        }

        func decodeNil(forKey key: Key) throws -> Bool { return !contains(key) }
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
            fatalError("unreachable")
        }

        func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
            fatalError("unreachable")
        }

        func _superDecoder(forKey key: CodingKey = AnyCodingKey.super) throws -> Decoder {
            decoder.codingPath.append(key)
            defer { decoder.codingPath.removeLast() }

            let value = try find(forKey: key)
            return URLQueryItemsDecoder(container: value, codingPath: decoder.codingPath)
        }

        func superDecoder() throws -> Decoder {
            return try _superDecoder()
        }

        func superDecoder(forKey key: Key) throws -> Decoder {
            return try _superDecoder(forKey: key)
        }
    }

    private class UnkeyedContanier: UnkeyedDecodingContainer {
        private var decoder: URLQueryItemsDecoder
        private(set) var codingPath: [CodingKey]
        private var container: [URLQueryItem]

        var count: Int? { return container.count }
        var isAtEnd: Bool { return currentIndex >= count! }

        private(set) var currentIndex: Int
        private var currentCodingPath: [CodingKey] { return decoder.codingPath + [AnyCodingKey(index: currentIndex)] }

        init(decoder: URLQueryItemsDecoder, container: [URLQueryItem]) {
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
            defer { decoder.codingPath.removeLast() }

            let value = try decoder.unbox(try container[currentIndex].value.unwrapOrThrow(), as: T.self)

            defer { currentIndex += 1 }
            return try decoder.unbox(value, as: T.self)
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
            fatalError("unreachable")
        }

        func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
            fatalError("unreachable")
        }

        func superDecoder() throws -> Decoder {
            decoder.codingPath.append(AnyCodingKey(index: currentIndex))
            defer { decoder.codingPath.removeLast() }

            try checkIndex(UnkeyedContanier.self)

            let value = container[currentIndex]
            currentIndex += 1
            return URLQueryItemsDecoder(container: value, codingPath: decoder.codingPath)
        }
    }

    private class SingleValueContainer: SingleValueDecodingContainer {
        private var decoder: URLQueryItemsDecoder
        private(set) var codingPath: [CodingKey]

        init(decoder: URLQueryItemsDecoder) {
            self.decoder = decoder
            self.codingPath = decoder.codingPath
        }

        func _decode<T: Decodable>(_ type: T.Type) throws -> T {
            return try decoder.lastContainer(forType: type)
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
        func decode<T: Decodable>(_ type: T.Type) throws -> T { return try _decode(type) }
    }
}
