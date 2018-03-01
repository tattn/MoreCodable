//
//  RuleBasedCodingKey.swift
//  MoreCodable
//
//  Created by Tatsuya Tanaka on 20180221.
//  Copyright © 2018年 tattn. All rights reserved.
//

import Foundation

public protocol RuleBasedCodingKey: CodingKey {
    func codingKeyRule(key: String) -> String
}

public extension RuleBasedCodingKey where Self: RawRepresentable, Self.RawValue == String {
    var stringValue: String {
        return codingKeyRule(key: rawValue)
    }
}

public protocol SnakeCaseCodingKey: RuleBasedCodingKey {}

public extension SnakeCaseCodingKey {
    func codingKeyRule(key: String) -> String {
        return key.replacingOccurrences(of: "([A-Z])",
                                        with: "_$1",
                                        options: .regularExpression,
                                        range: key.startIndex..<key.endIndex).lowercased()
    }
}

public protocol UpperCamelCaseCodingKey: RuleBasedCodingKey {}

public extension UpperCamelCaseCodingKey {
    func codingKeyRule(key: String) -> String {
        return key.prefix(1).uppercased() + key.dropFirst()
    }
}
