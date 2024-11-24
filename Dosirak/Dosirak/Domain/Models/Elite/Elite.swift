//
//  Elite.swift
//  Dosirak
//
//  Created by 권민재 on 11/24/24.
//

import Foundation

struct EliteUserInfo: Decodable {
    
    let id: Int
    let userId: Int
    let correctAnswers: Int
    let incorrectAnswers: Int
    let totalAnswers: Int
}

struct Problem: Decodable {
    let id: Int
    let problemId: Int
    let userId: Int
    let correct: Bool
    let problemDesc: String
    let problemAns: String
}
