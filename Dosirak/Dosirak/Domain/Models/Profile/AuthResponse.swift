//
//  AuthResponse.swift
//  Dosirak
//
//  Created by 권민재 on 11/3/24.
//

struct AuthResponse: Decodable {
    let status: String
    let message: String
}

struct EditNickNameResponse: Codable {
    let status: String
    let message: String
    let data: NickNameData
    let exception: String?
}

struct NickNameData: Codable {
    let nickName: String?
}
struct UserProfileResponse: Codable {
    let status: String
    let message: String
    let data: UserProfileData
    let exception: String?
}
struct UserProfileData: Codable {
    let nickName: String?
    let email: String
    let name: String
    let createdAt: String
    let reward: Int
}
