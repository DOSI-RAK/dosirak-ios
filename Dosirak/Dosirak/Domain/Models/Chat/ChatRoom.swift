//
//  ChatRoom.swift
//  Dosirak
//
//  Created by 권민재 on 10/27/24.
//

import Foundation

// 채팅방 목록에 사용되는 채팅방 정보 기본 구조체
struct ChatRoom: Decodable {
    let id: Int
    let title: String
    let image: String
    let personCount: Int
    let explanation: String
}
struct MyChatRoom: Decodable {
    let id: Int
    let title: String
    let image: String
    let explanation: String
    let lastMessageTime: String
}

// 요약된 채팅방 정보 구조체
struct ChatRoomSummary: Decodable {
    let id: Int
    let image: String
    let lastMessage: String
}

// 상세한 채팅방 정보 구조체
struct ChatRoomInfo: Decodable {
    let personCount: Int
    let explanation: String
    let messageList: [Message]
    let userList: [User]
}

// 메시지 정보 구조체
struct Message: Decodable {
    let id: Int
    let content: String
    let messageType: String
    let createdAt: String
    let userId: Int
    let chatRoomId: Int
}

// 사용자 정보 구조체
struct User: Decodable {
    let userId: Int
    let nickName: String
    let profileImg: String
}
