//
//  ChatRoom.swift
//  Dosirak
//
//  Created by 권민재 on 10/27/24.
//

import Foundation

struct ChatRoom: Codable {
    let id: Int64
    let title: String
    let image: String
    let personCount: Int64
    let lastMessage: String
}
struct ChatRoomResponse: Codable {
    let personCount: Int64
    let explanation: String
    let messageList: [MessageResponse]
    let userList: [UserChatRoomResponse]

    struct MessageResponse: Codable {
        let id: Int64
        let content: String
        let messageType: String
        let createdAt: String
        let userId: Int64
        let chatRoomId: Int64
    }

    struct UserChatRoomResponse: Codable {
        let userId: Int64
        let nickName: String
        let profileImg: String
    }
}
