import Foundation

/*
 An encoder that, if the value to encode is hashable, caches the encoded result.
 This is useful to speed up applications that have to encode the same hashable value numerous times
 The cache key is calculated from the combination of:
 1- The hashable value to enconde
 2- The userInfo dictionary (note that you have to provide a closure to convert it to a hashable object)
 */
open class DictionaryCachableEncoder: DictionaryEncoder {
    open var userInfoHasher: ([CodingUserInfoKey: Any]) -> AnyHashable = { _ in AnyHashable(0) }
    open var cache: CacheProtocol = DefaultCache.shared

    override func box<T: Encodable>(_ value: T) throws -> Any {
        if let hashableValue = value as? AnyHashable {
            let userInfoHash = userInfoHasher(userInfo)
            let cacheKey = AnyHashable([hashableValue, userInfoHash])
            if let cached = cache.storage[cacheKey] {
                return cached
            } else {
                let container = try super.box(value)
                cache.storage[cacheKey] = container
                return container
            }
        } else {
            return try super.box(value)
        }
    }
}

// MARK: cache related

public protocol CacheProtocol: class {
    var storage: [AnyHashable: Any] { get set }
}

extension DictionaryCachableEncoder {
    open class DefaultCache: CacheProtocol {
        public static let shared = DefaultCache()

        open var storage: [AnyHashable: Any] = [:]

        public init() { }
    }
}
