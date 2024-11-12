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


struct Message: Decodable {
    let id: Int
    let content: String
    let messageType: MessageType
    let createdAt: String
    let userChatRoomResponse: UserChatRoomResponse
    let chatRoomId: Int
}

struct UserChatRoomResponse: Decodable {
    let userId: Int
    let nickName: String?
    let profileImg: String
}



struct User: Decodable {
    let userId: Int
    let nickName: String?
    let profileImg: String
}
