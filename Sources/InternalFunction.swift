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
