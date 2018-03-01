//
//  URLQueryItem+.swift
//  MoreCodable
//
//  Created by Tatsuya Tanaka on 20180212.
//  Copyright © 2018年 tattn. All rights reserved.
//

import Foundation

extension URLQueryItem: Codable {
    enum CodingKeys: String, CodingKey {
        case name
        case value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        let value = try container.decode(String.self, forKey: .value)
        self.init(name: name, value: value)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(value, forKey: .value)
    }
}
