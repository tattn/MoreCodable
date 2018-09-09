//
//  CodableDictionary.swift
//  MoreCodable
//
//  Created by Tatsuya Tanaka on 20180909.
//  Copyright © 2018年 tattn. All rights reserved.
//

import Foundation

public struct CodableDictionary<Key: Hashable, Value: Codable>: Codable where Key: CodingKey {
    public let rawValue: [Key: Value]
}

extension CodableDictionary {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)

        rawValue = .init(uniqueKeysWithValues:
            try container.allKeys.map {
                (key: $0, value: try container.decode(Value.self, forKey: $0))
            }
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)

        for (key, value) in rawValue {
            try container.encode(value, forKey: key)
        }
    }
}

extension CodableDictionary: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (Key, Value)...) {
        rawValue = elements.reduce(into: [:], { (result, element) in
            result[element.0] = element.1
        })
    }
}

extension CodableDictionary: Equatable where Key: Equatable, Value: Equatable {
    public static func == (lhs: CodableDictionary<Key, Value>, rhs: CodableDictionary<Key, Value>) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
