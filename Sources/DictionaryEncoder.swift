//
//  DictionaryEncoder.swift
//  MoreCodable
//
//  Created by Tatsuya Tanaka on 20180211.
//  Copyright © 2018年 tattn. All rights reserved.
//

import Foundation

open class DictionaryEncoder: Encoder {
    open var codingPath: [CodingKey] = []
    open var dateEncodingStrategy: DateEncodingStrategy = .deferredToDate
    open var userInfo: [CodingUserInfoKey: Any] = [:]
    private(set) var storage = Storage()

    public enum DateEncodingStrategy {
        case deferredToDate
        case secondsSince1970
        case millisecondsSince1970
        case iso8601
        case formatted(DateFormatter)
        case custom((Date, Encoder) throws -> Void)
    }

    public init() {}

    open func container<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
        return KeyedEncodingContainer(KeyedContainer<Key>(encoder: self, codingPath: codingPath))
    }

    open func unkeyedContainer() -> UnkeyedEncodingContainer {
        return UnkeyedContanier(encoder: self, codingPath: codingPath)
    }

    open func singleValueContainer() -> SingleValueEncodingContainer {
        return SingleValueContainer(encoder: self, codingPath: codingPath)
    }

    func box<T: Encodable>(_ value: T) throws -> Any {
        switch value {
        case let date as Date:
            return try wrapDate(date)
        default:
            try value.encode(to: self)
            return storage.popContainer()
        }
    }

    func wrapDate(_ date: Date) throws -> Any {
        switch dateEncodingStrategy {
        case .deferredToDate:
            try date.encode(to: self)
            return storage.popContainer()

        case .secondsSince1970:
            return TimeInterval(date.timeIntervalSince1970.description) as Any

        case .millisecondsSince1970:
            return TimeInterval((date.timeIntervalSince1970 * 1000).description) as Any

        case .iso8601:
            return _iso8601Formatter.string(from: date)

        case .formatted(let formatter):
            return formatter.string(from: date)

        case .custom(let closure):
            try closure(date, self)
            return storage.popContainer()
        }
    }
}

extension DictionaryEncoder {
    open func encode<T: Encodable>(_ value: T) throws -> [String: Any] {
        do {
            return try castOrThrow([String: Any].self, try box(value))
        } catch (let error) {
            throw EncodingError.invalidValue(value,
                                             EncodingError.Context(codingPath: [],
                                                                   debugDescription: "Top-level \(T.self) did not encode any values.",
                                                underlyingError: error)
            )
        }
    }
}

extension DictionaryEncoder {
    private class KeyedContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
        private var encoder: DictionaryEncoder
        private(set) var codingPath: [CodingKey]
        private var storage: Storage

        init(encoder: DictionaryEncoder, codingPath: [CodingKey]) {
            self.encoder = encoder
            self.codingPath = codingPath
            self.storage = encoder.storage

            if storage.count == codingPath.count {
                storage.push(container: [:] as [String: Any])
            }
        }

        deinit {
            guard let dictionary = storage.popContainer() as? [String: Any] else {
                assertionFailure(); return
            }
            storage.push(container: dictionary)
        }

        private func set(_ value: Any, forKey key: String) {
            guard var dictionary = storage.popContainer() as? [String: Any] else { assertionFailure(); return }
            dictionary[key] = value
            storage.push(container: dictionary)
        }

        func encodeNil(forKey key: Key) throws { set(NSNull(), forKey: key.stringValue) }
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

    private class UnkeyedContanier: UnkeyedEncodingContainer {
        var encoder: DictionaryEncoder
        private(set) var codingPath: [CodingKey]
        private var storage: Storage
        var count: Int { return storage.count }

        init(encoder: DictionaryEncoder, codingPath: [CodingKey]) {
            self.encoder = encoder
            self.codingPath = codingPath
            self.storage = encoder.storage

            storage.push(container: [] as [Any])
        }

        deinit {
            guard let array = storage.popContainer() as? [Any] else {
                assertionFailure(); return
            }
            storage.push(container: array)
        }

        private func push(_ value: Any) {
            guard var array = storage.popContainer() as? [Any] else { assertionFailure(); return }
            array.append(value)
            storage.push(container: array)
        }

        func encodeNil() throws { push(NSNull()) }
        func encode(_ value: Bool) throws {}
        func encode(_ value: Int) throws { push(try encoder.box(value)) }
        func encode(_ value: Int8) throws { push(try encoder.box(value)) }
        func encode(_ value: Int16) throws { push(try encoder.box(value)) }
        func encode(_ value: Int32) throws { push(try encoder.box(value)) }
        func encode(_ value: Int64) throws { push(try encoder.box(value)) }
        func encode(_ value: UInt) throws { push(try encoder.box(value)) }
        func encode(_ value: UInt8) throws { push(try encoder.box(value)) }
        func encode(_ value: UInt16) throws { push(try encoder.box(value)) }
        func encode(_ value: UInt32) throws { push(try encoder.box(value)) }
        func encode(_ value: UInt64) throws { push(try encoder.box(value)) }
        func encode(_ value: Float) throws { push(try encoder.box(value)) }
        func encode(_ value: Double) throws { push(try encoder.box(value)) }
        func encode(_ value: String) throws { push(try encoder.box(value)) }
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

    private class SingleValueContainer: SingleValueEncodingContainer {
        var encoder: DictionaryEncoder
        private(set) var codingPath: [CodingKey]
        private var storage: Storage
        var count: Int { return storage.count }

        init(encoder: DictionaryEncoder, codingPath: [CodingKey]) {
            self.encoder = encoder
            self.codingPath = codingPath
            self.storage = encoder.storage
        }

        private func push(_ value: Any) {
            guard var array = storage.popContainer() as? [Any] else { assertionFailure(); return }
            array.append(value)
            storage.push(container: array)
        }

        func encodeNil() throws { storage.push(container: NSNull()) }
        func encode(_ value: Bool) throws { storage.push(container: value) }
        func encode(_ value: Int) throws { storage.push(container: value) }
        func encode(_ value: Int8) throws { storage.push(container: value) }
        func encode(_ value: Int16) throws { storage.push(container: value) }
        func encode(_ value: Int32) throws { storage.push(container: value) }
        func encode(_ value: Int64) throws { storage.push(container: value) }
        func encode(_ value: UInt) throws { storage.push(container: value) }
        func encode(_ value: UInt8) throws { storage.push(container: value) }
        func encode(_ value: UInt16) throws { storage.push(container: value) }
        func encode(_ value: UInt32) throws { storage.push(container: value) }
        func encode(_ value: UInt64) throws { storage.push(container: value) }
        func encode(_ value: Float) throws { storage.push(container: value) }
        func encode(_ value: Double) throws { storage.push(container: value) }
        func encode(_ value: String) throws { storage.push(container: value) }
        func encode<T: Encodable>(_ value: T) throws { storage.push(container: try encoder.box(value)) }
    }
}
