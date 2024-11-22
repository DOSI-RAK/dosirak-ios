//
//  Commit.swift
//  Dosirak
//
//  Created by 권민재 on 11/10/24.
//
import Foundation


//월별 커밋
struct MonthCommit: Decodable {
    
    let createdAt: String
    let commitCount: Int
}
//내 활동
struct CommitActivity: Decodable {
    let createAt: String
    let activityMessage: String
    let createAtTime: String
    let iconImageUrl: String
}

