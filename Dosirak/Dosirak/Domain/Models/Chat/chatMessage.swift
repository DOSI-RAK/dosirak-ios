//
//  chatMessage.swift
//  Dosirak
//
//  Created by 권민재 on 10/31/24.
//

import Foundation


enum MessageType: String, Codable {
    case chat = "CHAT"
    case join = "JOIN"
}

// 메시지 구조체
struct Message: Decodable {
    let id: Int
    let content: String
    let messageType: MessageType
    let createdAt: String
    let userChatRoomResponse: UserChatRoomResponse
    let chatRoomId: Int
}

// 메시지 내 사용자 정보 (userChatRoomResponse 필드용)
struct UserChatRoomResponse: Decodable {
    let userId: Int
    let nickName: String?
    let profileImg: String
}

// 사용자 정보 구조체 (userList 필드용)
struct User: Decodable {
    let userId: Int
    let nickName: String? // 닉네임이 null일 수 있으므로 Optional로 설정
    let profileImg: String
}
