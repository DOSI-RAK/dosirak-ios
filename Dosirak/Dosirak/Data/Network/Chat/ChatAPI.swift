//
//  ChatAPI.swift
//  Dosirak
//
//  Created by 권민재 on 10/29/24.
//
import Moya
import Foundation
import UIKit

enum ChatAPI {
    case fetchMyLocationChatRoom(accessToken: String, zone: String)
    case fetchMyChatRoomSummary(accessToken: String)
    case fetchChatRoomInfo(accessToken: String, chatRoomId: Double)
    case fetchMyChatRoomList(accessToken: String)
    case deleteChatRoom(accessToken: String, chatRoomId: Double)
}

extension ChatAPI: TargetType {
    var baseURL: URL {
        return URL(string: "http://dosirak.store")!
    }
    
    var path: String {
        switch self {
        case .fetchMyChatRoomList:
            return "/api/chat-rooms/by-user"
        case .fetchChatRoomInfo(_, let chatRoomId):
            return "/api/chat-rooms/\(chatRoomId)/information"
        case .fetchMyLocationChatRoom(_, let zone):
            return "/api/chat-rooms/zone-category/\(zone)"
        case .deleteChatRoom(_, let chatRoomId):
            return "/api/chat-rooms/\(chatRoomId)"
        case .fetchMyChatRoomSummary:
            return "/api/chat-rooms/main/by-user"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchMyChatRoomList, .fetchMyChatRoomSummary, .fetchMyLocationChatRoom, .fetchChatRoomInfo:
            return .get
        case .deleteChatRoom:
            return .delete
        }
    }
    
    var task: Task {
        switch self {
        case .fetchMyLocationChatRoom, .fetchMyChatRoomList, .fetchMyChatRoomSummary, .fetchChatRoomInfo, .deleteChatRoom:
            return .requestPlain
            
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .fetchMyLocationChatRoom(let accessToken, _),
             .fetchMyChatRoomSummary(let accessToken),
             .fetchChatRoomInfo(let accessToken, _),
             //.createChatRoom(let accessToken, _, _),
             .fetchMyChatRoomList(let accessToken),
             .deleteChatRoom(let accessToken, _):
            return ["Authorization": "Bearer \(accessToken)", "Content-Type": "application/json"]
        }
    }
}
