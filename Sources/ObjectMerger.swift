//
//  ObjectMerger.swift
//  MoreCodable
//
//  Created by Tatsuya Tanaka on 20180302.
//  Copyright © 2018年 tattn. All rights reserved.
//

import Foundation

public struct ObjectMerger {
    private let encoder = DictionaryEncoder()
    private let decoder = DictionaryDecoder()

    public init() {}

    public func merge<T: Decodable, A: Encodable, B: Encodable>(_ type: T.Type = T.self, _ aObject: A, _ bObject: B) throws -> T {
        print(try encoder.encode(bObject))
        let dictionary = try encoder.encode(aObject)
            .merging(try encoder.encode(bObject)) { left, _ in left }
        return try decoder.decode(T.self, from: dictionary)
    }

    public func merge<T: Decodable, A: Encodable, B: Encodable, C: Encodable>(_ type: T.Type = T.self, _ aObject: A, _ bObject: B, _ cObject: C) throws -> T {
        let dictionary = try encoder.encode(aObject)
            .merging(try encoder.encode(bObject)) { left, _ in left }
            .merging(try encoder.encode(cObject)) { left, _ in left }
        return try decoder.decode(T.self, from: dictionary)
    }

    public func merge<T: Decodable, A: Encodable, B: Encodable, C: Encodable, D: Encodable>(_ type: T.Type = T.self, _ aObject: A, _ bObject: B, _ cObject: C, _ dObject: D) throws -> T {
        let dictionary = try encoder.encode(aObject)
            .merging(try encoder.encode(bObject)) { left, _ in left }
            .merging(try encoder.encode(cObject)) { left, _ in left }
            .merging(try encoder.encode(dObject)) { left, _ in left }
        return try decoder.decode(T.self, from: dictionary)
    }
}
