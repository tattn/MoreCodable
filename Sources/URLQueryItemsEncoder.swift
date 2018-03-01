//
//  URLQueryItemsEncoder.swift
//  MoreCodable
//
//  Created by Tatsuya Tanaka on 20180212.
//  Copyright © 2018年 tattn. All rights reserved.
//

import Foundation

open class URLQueryItemsEncoder: Encoder {
    open var codingPath: [CodingKey] = []
    open var userInfo: [CodingUserInfoKey: Any] = [:]
    private var storage = Storage()

    public init() {}

    open func container<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
        return KeyedEncodingContainer(KeyedContainer<Key>(encoder: self, codingPath: codingPath))
    }

    open func unkeyedContainer() -> UnkeyedEncodingContainer {
        return UnkeyedContanier(encoder: self, codingPath: codingPath)
    }

    open func singleValueContainer() -> SingleValueEncodingContainer {
        return UnkeyedContanier(encoder: self, codingPath: codingPath)
    }

    private func box<T: Encodable>(_ value: T) throws -> Any {
        try value.encode(to: self)
        return storage.popContainer()
    }
}

extension URLQueryItemsEncoder {
    open func encode<T: Encodable>(_ value: T) throws -> [URLQueryItem] {
        do {
            return try castOrThrow([URLQueryItem].self, try box(value))
        } catch (let error) {
            throw EncodingError.invalidValue(value,
                                             EncodingError.Context(codingPath: [],
                                                                   debugDescription: "Top-evel \(T.self) did not encode any values.",
                                                underlyingError: error)
            )
        }
    }
}

extension URLQueryItemsEncoder {
    private class KeyedContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
        private var encoder: URLQueryItemsEncoder
        private(set) var codingPath: [CodingKey]
        private var storage: Storage

        init(encoder: URLQueryItemsEncoder, codingPath: [CodingKey]) {
            self.encoder = encoder
            self.codingPath = codingPath
            self.storage = encoder.storage

            storage.push(container: [URLQueryItem]())
        }

        private func set(_ value: Any, forKey key: String) {
            guard var queryItems = storage.popContainer() as? [URLQueryItem] else { assertionFailure(); return }
            queryItems.append(URLQueryItem(name: key, value: String(describing: value)))
            storage.push(container: queryItems)
        }

        func encodeNil(forKey key: Key) throws {}
        func encode(_ value: Bool, forKey key: Key) throws { set(value, forKey: key.stringValue) }
        func encode(_ value: Int, forKey key: Key) throws { set(value, forKey: key.stringValue) }
        func encode(_ value: Int8, forKey key: Key) throws { set(value, forKey: key.stringValue) }
        func encode(_ value: Int16, forKey key: Key) throws { set(value, forKey: key.stringValue) }
        func encode(_ value: Int32, forKey key: Key) throws { set(value, forKey: key.stringValue) }
        func encode(_ value: Int64, forKey key: Key) throws { set(value, forKey: key.stringValue) }
        func encode(_ value: UInt, forKey key: Key) throws { set(value, forKey: key.stringValue) }
        func encode(_ value: UInt8, forKey key: Key) throws { set(value, forKey: key.stringValue) }
        func encode(_ value: UInt16, forKey key: Key) throws { set(value, forKey: key.stringValue) }
        func encode(_ value: UInt32, forKey key: Key) throws { set(value, forKey: key.stringValue) }
        func encode(_ value: UInt64, forKey key: Key) throws { set(value, forKey: key.stringValue) }
        func encode(_ value: Float, forKey key: Key) throws { set(value, forKey: key.stringValue) }
        func encode(_ value: Double, forKey key: Key) throws { set(value, forKey: key.stringValue) }
        func encode(_ value: String, forKey key: Key) throws { set(value, forKey: key.stringValue) }
        func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
            encoder.codingPath.append(key)
            defer { encoder.codingPath.removeLast() }
            set(try encoder.box(value), forKey: key.stringValue)
        }

        func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
            codingPath.append(key)
            defer { codingPath.removeLast() }
            return KeyedEncodingContainer(KeyedContainer<NestedKey>(encoder: encoder, codingPath: codingPath))
        }

        func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
            codingPath.append(key)
            defer { codingPath.removeLast() }
            return UnkeyedContanier(encoder: encoder, codingPath: codingPath)
        }

        func superEncoder() -> Encoder {
            return encoder
        }

        func superEncoder(forKey key: Key) -> Encoder {
            return encoder
        }
    }

    private class UnkeyedContanier: UnkeyedEncodingContainer, SingleValueEncodingContainer {
        var encoder: URLQueryItemsEncoder
        private(set) var codingPath: [CodingKey]
        private var storage: Storage
        var count: Int { return (storage.last as? [Any])?.count ?? 0 }

        init(encoder: URLQueryItemsEncoder, codingPath: [CodingKey]) {
            self.encoder = encoder
            self.codingPath = codingPath
            self.storage = encoder.storage

            storage.push(container: [] as [String])
        }

        private func push(_ value: Any) {
            guard var array = storage.popContainer() as? [String] else { assertionFailure(); return }
            array.append(String(describing: value))
            storage.push(container: array)
        }

        func encodeNil() throws {}
        func encode(_ value: Bool) throws {}
        func encode(_ value: Int) throws { push(value) }
        func encode(_ value: Int8) throws { push(value) }
        func encode(_ value: Int16) throws { push(value) }
        func encode(_ value: Int32) throws { push(value) }
        func encode(_ value: Int64) throws { push(value) }
        func encode(_ value: UInt) throws { push(value) }
        func encode(_ value: UInt8) throws { push(value) }
        func encode(_ value: UInt16) throws { push(value) }
        func encode(_ value: UInt32) throws { push(value) }
        func encode(_ value: UInt64) throws { push(value) }
        func encode(_ value: Float) throws { push(value) }
        func encode(_ value: Double) throws { push(value) }
        func encode(_ value: String) throws { push(value) }
        func encode<T: Encodable>(_ value: T) throws {
            encoder.codingPath.append(AnyCodingKey(index: count))
            defer { encoder.codingPath.removeLast() }
            push(try encoder.box(value))
        }

        func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
            codingPath.append(AnyCodingKey(index: count))
            defer { codingPath.removeLast() }
            return KeyedEncodingContainer(KeyedContainer<NestedKey>(encoder: encoder, codingPath: codingPath))
        }

        func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
            codingPath.append(AnyCodingKey(index: count))
            defer { codingPath.removeLast() }
            return UnkeyedContanier(encoder: encoder, codingPath: codingPath)

        }

        func superEncoder() -> Encoder {
            return encoder
        }
    }
}
