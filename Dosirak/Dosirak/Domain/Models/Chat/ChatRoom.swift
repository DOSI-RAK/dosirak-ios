//
//  ChatRoom.swift
//  Dosirak
//
//  Created by 권민재 on 10/27/24.
//

import Foundation

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
