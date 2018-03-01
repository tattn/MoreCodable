//
//  StringTo.swift
//  MoreCodable
//
//  Created by Tatsuya Tanaka on 20180219.
//  Copyright © 2018年 tattn. All rights reserved.
//

import Foundation

public struct StringTo<T: LosslessStringConvertible>: Codable {
    public let value: T

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)

        guard let value = T(stringValue) else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: decoder.codingPath,
                      debugDescription: "The string cannot cast to \(T.self).")
            )
        }

        self.value = value
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value.description)
    }
}
