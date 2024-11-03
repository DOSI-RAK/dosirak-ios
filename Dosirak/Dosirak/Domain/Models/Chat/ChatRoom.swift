//
//  ChatRoom.swift
//  Dosirak
//
//  Created by 권민재 on 10/27/24.
//

import Foundation

struct MyChatRoomSummaryResponse: Decodable {
    let status: String
    let message: String
    let data: [ChatRoomSummary]
}
struct ChatRoomResponse: Decodable {
    let status: String
    let message: String
    let data: [ChatRoom]
}

struct MyChatRoomListResponse: Decodable {
    let status: String
    let message: String
    let data: [MyChatRoom]
}

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
    let lastMessageTime: String?
}

// 요약된 채팅방 정보 구조체
struct ChatRoomSummary: Decodable {
    let id: Int
    let title: String
    let image: String
    let lastMessage: String?
}

struct ChatRoomInfo: Decodable {
    let personCount: Int
    let explanation: String
    let messageList: [Message]
    let userList: [User]
}
