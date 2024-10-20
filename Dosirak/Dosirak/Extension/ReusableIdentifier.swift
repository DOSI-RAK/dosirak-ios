//
//  ReusableIdentifier.swift
//  Dosirak
//
//  Created by 권민재 on 10/17/24.
//

extension NSObject {
    static var reusableIdentifier: String {
        return String(describing: self)
    }
}
