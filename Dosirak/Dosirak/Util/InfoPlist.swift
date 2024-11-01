//
//  InfoPlist.swift
//  Dosirak
//
//  Created by 권민재 on 11/1/24.
//

import Foundation

@propertyWrapper
struct InfoPlist<T> {
    private let key: String

    init(_ key: String) {
        self.key = key
    }

    var wrappedValue: T? {
        return Bundle.main.object(forInfoDictionaryKey: key) as? T
    }
}
