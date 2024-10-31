//
//  KeychainStore.swift
//  Dosirak
//
//  Created by 권민재 on 10/29/24.
//

import Foundation
import KeychainAccess

@propertyWrapper
public struct KeychainStorage<T: Codable> {
    private let key: String
    private let keychain: Keychain

    public var wrappedValue: T? {
        get {
            return getItem()
        }
        set {
            if let newValue = newValue {
                saveItem(newValue)
            } else {
                deleteItem()
            }
        }
    }

    public init(key: String, service: String = Bundle.main.bundleIdentifier ?? "defaultService") {
        self.key = key
        self.keychain = Keychain(service: service)
    }

    // MARK: - Private Helpers
    private func getItem() -> T? {
        guard let data = try? keychain.getData(key) else {
            return nil
        }

        let decoder = JSONDecoder()
        return try? decoder.decode(T.self, from: data)
    }

    private func saveItem(_ item: T) {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(item) else {
            print("Failed to encode item for keychain")
            return
        }

        do {
            try keychain.set(data, key: key)
        } catch {
            print("Failed to save item to keychain: \(error)")
        }
    }

    private func deleteItem() {
        do {
            try keychain.remove(key)
        } catch {
            print("Failed to delete item from keychain: \(error)")
        }
    }
}
