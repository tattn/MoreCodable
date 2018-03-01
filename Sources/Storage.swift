//
//  Storage.swift
//  MoreCodable
//
//  Created by Tatsuya Tanaka on 20180211.
//  Copyright © 2018年 tattn. All rights reserved.
//

import Foundation

final class Storage {
    private(set) var containers: [Any] = []

    var count: Int {
        return containers.count
    }

    var last: Any? {
        return containers.last
    }

    func push(container: Any) {
        containers.append(container)
    }

    @discardableResult
    func popContainer() -> Any {
        precondition(containers.count > 0, "Empty container stack.")
        return containers.popLast()!
    }
}
