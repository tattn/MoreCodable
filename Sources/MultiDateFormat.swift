//
//  MultiDateFormat.swift
//  MoreCodable
//
//  Created by Daniil Pendikov on 24/05/2019.
//  Copyright © 2019 tattn. All rights reserved.
//

import Foundation

/// A format to use for encoding / decoding date values.
public enum DateFormat {
    /// Encode / decode the `Date` as an ISO-8601-formatted string (in RFC 3339 format).
    case iso8601
    /// Encode / decode the `Date` as a UNIX timestamp (as a JSON number).
    case secondsSince1970
    /// Encode / decode the `Date` as UNIX millisecond timestamp (as a JSON number).
    case millisecondsSince1970
    /// Encode / decode the `Date` as a string formatted by the given formatter.
    case formatted(DateFormatter)
    /// Encode / decode the `Date` as a custom value encoded by the given closure.
    case custom((Date, Encoder) throws -> Void, (Decoder) throws -> Date)
}

/// A type that provides date formats to use with coding keys.
public protocol MultiDateFormat {
    /// The date format for this coding key.
    /// If nil for a coding key associated with date, the Encoder / Decoder strategy property will be used.
    static func dateFormat(for codingKey: CodingKey) -> DateFormat?
}

public typealias MultiDateFormatEncodable = Encodable & MultiDateFormat
public typealias MultiDateFormatDecodable = Decodable & MultiDateFormat
public typealias MultiDateFormatCodable = MultiDateFormatEncodable & MultiDateFormatDecodable
