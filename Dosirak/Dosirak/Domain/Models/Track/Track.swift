//
//  Track.swift
//  Dosirak
//
//  Created by 권민재 on 11/27/24.
//

import Foundation

struct Track: Decodable {
    let id: String
    let addressLevelOne: String
    let addressLevelTwo: String
    let latitude: Double
    let longitude: Double
}

struct Distance: Decodable {
    let moveTrackDistance: Double
}
