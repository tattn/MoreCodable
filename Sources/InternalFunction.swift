//
//  InternalFunction.swift
//  MoreCodable
//
//  Created by Tatsuya Tanaka on 20180211.
//  Copyright © 2018年 tattn. All rights reserved.
//

import Foundation

public enum MoreCodableError: Error {
    case cast
    case unwrapped
    case tryValue
}

func castOrThrow<T>(_ resultType: T.Type, _ object: Any, error: Error = MoreCodableError.cast) throws -> T {
    /// Int literals cannot be cast as a Double using `as?` so `Double(<Int>)` must be used instead.
    if let intValue = object as? Int,
       let result = Double(intValue) as? T {
        return result
    }
    /// Most `Any` types can be converted using `as?` if they're a compatible type
    guard let returnValue = object as? T else {
        throw error
    }

    return returnValue
}

extension Optional {
    func unwrapOrThrow(error: Error = MoreCodableError.unwrapped) throws -> Wrapped {
        guard let unwrapped = self else {
            throw error
        }

        return unwrapped
    }
}

extension Dictionary {
    func tryValue(forKey key: Key, error: Error = MoreCodableError.tryValue) throws -> Value {
        guard let value = self[key] else { throw error }
        return value
    }
}
