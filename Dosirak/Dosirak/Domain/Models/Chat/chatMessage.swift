//
//  chatMessage.swift
//  Dosirak
//
//  Created by 권민재 on 10/31/24.
//

import Foundation

//struct ChatMessage: Codable {
//    let id: Int
//    let content: String
//    let messageType: String
//    let createdAt: String
//    let userId: Int
//    let chatRoomId: Int
//}
struct ChatMessage: Codable {
    let text: String
    let isSentByCurrentUser: Bool
    let nickname: String
    let profileImageName: String
    let time: String
}
