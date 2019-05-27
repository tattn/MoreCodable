<h1 align="center">MoreCodable</h1>

<h5 align="center">MoreCodable expands the possibilities of "Codable".</h5>

<div align="center">
  <a href="https://travis-ci.org/tattn/MoreCodable">
    <img src="https://travis-ci.org/tattn/MoreCodable.svg?branch=master" alt="Build Status" />
  </a>
  <a href="https://github.com/Carthage/Carthage">
    <img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat" alt="Carthage compatible" />
  </a>
  <a href="http://cocoapods.org/pods/MoreCodable">
    <img src="https://img.shields.io/cocoapods/v/MoreCodable.svg" alt="CocoaPods" />
  </a>
  <a href="http://cocoapods.org/pods/MoreCodable">
    <img src="https://img.shields.io/cocoapods/p/MoreCodable.svg" alt="Platform" />
  </a>
  <a href="https://developer.apple.com/swift">
    <img src="https://img.shields.io/badge/Swift-5-F16D39.svg" alt="Swift Version" />
  </a>
  <a href="./LICENSE">
    <img src="https://img.shields.io/badge/license-MIT-green.svg?style=flat-square" alt="license:MIT" />
  </a>
</div>

<br />


# Installation

## Carthage

```ruby
github "tattn/MoreCodable"
```

## CocoaPods

```ruby
pod 'MoreCodable'
```

# Feature

## DictionaryEncoder / DictionaryDecoder

```swift
struct User: Codable {
    let id: Int
    let name: String
}

let encoder = DictionaryEncoder()
let user = User(id: 123, name: "tattn")
let dictionary: [String: Any] = try! encoder.encode(user) // => {"id": 123, "name": "tattn"}
```

```swift
let decoder = DictionaryDecoder()
let user = try decoder.decode(User.self, from: dictionary)
```

## URLQueryItemsEncoder / URLQueryItemsDecoder

```swift
struct Parameter: Codable {
    let query: String
    let offset: Int
    let limit: Int
}
let parameter = Parameter(query: "ねこ", offset: 10, limit: 20)
let encoder = URLQueryItemsEncoder()
let params: [URLQueryItem] = try! encoder.encode(parameter)

var components = URLComponents(string: "https://example.com")
components?.queryItems = params
components?.url // https://example.com?query=%E3%81%AD%E3%81%93&offset=10&limit=20
```

```swift
let decoder = URLQueryItemsDecoder()
let parameter = try decoder.decode(Parameter.self, from: params)
```

## ObjectMerger

```swift
struct APIResponse: Encodable {
    let id: Int
    let title: String
    let foo: String
}

struct APIResponse2: Encodable {
    let tags: [String]
}

struct Model: Decodable {
    let id: Int
    let title: String
    let tags: [String]
}

let response = APIResponse(id: 0, title: "Awesome article", foo: "bar")
let response2 = APIResponse2(tags: ["swift", "ios", "macos"])
let model = try ObjectMerger().merge(Model.self, response, response2)

// success
XCTAssertEqual(model.id, response.id)
XCTAssertEqual(model.title, response.title)
XCTAssertEqual(model.tags, response2.tags)
```

## RuleBasedCodingKey

```swift
struct User: Codable {
    let userId: String
    let name: String

    enum CodingKeys: String, RuleBasedCodingKey {
        case userId
        case name

        func codingKeyRule(key: String) -> String {
            return key.uppercased() // custom rule
        }
    }
}

let json = """
{"USERID": "abc", "NAME": "tattn"}
""".data(using: .utf8)!

let user = try! JSONDecoder().decode(User.self, from: json) // => User(userId: "abc", name: "tattn")
```

### SnakeCaseCodingKey

```swift
struct User: Codable {
    let userId: String
    let name: String

    enum CodingKeys: String, SnakeCaseCodingKey {
        case userId
        case name
    }
}

let json = """
{"user_id": "abc", "name": "tattn"}
""".data(using: .utf8)!

let user = try! JSONDecoder().decode(User.self, from: json) // ok
```

### UpperCamelCaseCodingKey

```swift
struct User: Codable {
    let userId: String
    let name: String

    enum CodingKeys: String, UpperCamelCaseCodingKey {
        case userId
        case name
    }
}

let json = """
{"UserId": "abc", "Name": "tattn"}
""".data(using: .utf8)!

let user = try! JSONDecoder().decode(User.self, from: json) // ok
```

## Failable<Wrapped>

```swift
let json = """
[
    {"name": "Taro", "age": 20},
    {"name": "Hanako"}
]
""".data(using: .utf8)! // Hanako has no "age"

struct User: Codable {
    let name: String
    let age: Int
}

let users = try! JSONDecoder().decode([Failable<User>].self,
                                      from: json)

// success
XCTAssertEqual(users[0].value?.name, "Taro")
XCTAssertEqual(users[0].value?.age, 20)
XCTAssertNil(users[1].value)
```

## StringTo<T>

```swift
let json = """
{
    "int": "100",
    "articleId": "abc"
}
""".data(using: .utf8)!

struct Root: Codable {
    let int: StringTo<Int>
    let articleId: StringTo<ArticleId>

    struct ArticleId: LosslessStringConvertible, Codable {
        var description: String

        init?(_ description: String) {
            self.description = description
        }
    }
}

let root = try! JSONDecoder().decode(Root.self, from: json)

// success
XCTAssertEqual(root.int.value, 100)
XCTAssertEqual(root.articleId.value.description, "abc")
```

## MultiDateFormat
```swift
let json = """
{
    "date": "2019.05.27",
    "dateTime": "2019-05-27T17:26:59+0000",
    "timestamp": 1558978068,
    "timestampMilliseconds": 1558978141863,
    "custom": "1558978068"
}
""".data(using: .utf8)!

struct Document: Codable {
    var date: Date
    var dateTime: Date
    var timestamp: Date
    var timestampMilliseconds: Date
    var custom: Date
}

extension Document: MultiDateFormat {
    
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter
    }()
    
    static func dateFormat(for codingKey: CodingKey) -> DateFormat? {
        switch codingKey {
        case CodingKeys.date: return .formatted(dateFormatter)
        case CodingKeys.dateTime: return .iso8601
        case CodingKeys.timestamp: return .secondsSince1970
        case CodingKeys.timestampMilliseconds: return .millisecondsSince1970
        case CodingKeys.custom: return .custom({ (date, encoder) in
            var container = encoder.singleValueContainer()
            try container.encode(String(date.timeIntervalSince1970))
        }, { (decoder) -> Date in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            let timeInterval = TimeInterval(string)!
            return Date(timeIntervalSince1970: timeInterval)
        })
        default: return nil
        }
    }
    
}

let decoded = try! MoreJSONDecoder().decode(Document.self, from: json)
let encoded = try! MoreJSONEncoder().encode(document)
```

# ToDo
- [ ] XMLDecoder/XMLEncoder
- [ ] CSVDecoder/CSVEncoder

# Related project

**DataConvertible**  
https://github.com/tattn/DataConvertible

# Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D

## Support this project

Donating to help me continue working on this project.

[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://paypal.me/tattn/)

# License

MoreCodable is released under the MIT license. See LICENSE for details.
