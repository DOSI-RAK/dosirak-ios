//
//  ChatListRepository.swift
//  Dosirak
//
//  Created by 권민재 on 10/31/24.
//
import Moya
import RxSwift
import Foundation

protocol ChatListRepositoryType {
    func fetchMyLocationChatRoom(zone: String) -> Single<[ChatRoom]>
    func fetchMyChatRoomSummary() -> Single<[ChatRoomSummary]>
    func fetchChatRoomInfo(chatRoomId: Double) -> Single<ChatRoomInfo>
    func fetchMyChatRoomList() -> Single<[MyChatRoom]>
    func deleteChatRoom(chatRoomId: Double) -> Single<Void>
}

class ChatListRepository: ChatListRepositoryType {
    
    private let provider: MoyaProvider<ChatAPI>
    private let accessToken: String
    
    init(provider: MoyaProvider<ChatAPI>, accessToken: String) {
        self.provider = provider
        self.accessToken = accessToken
    }
    
    func fetchMyLocationChatRoom(zone: String) -> Single<[ChatRoom]> {
        return provider.rx.request(.fetchMyLocationChatRoom(accessToken: accessToken, zone: zone))
            .filterSuccessfulStatusCodes()
            .map { response -> [ChatRoom] in
                let json = try response.mapJSON() as? [String: Any]
                guard let data = json?["data"] as? [[String: Any]] else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Data not found"])
                }
                let chatRoomsData = try JSONSerialization.data(withJSONObject: data)
                return try JSONDecoder().decode([ChatRoom].self, from: chatRoomsData)
            }
    }
    
    func fetchMyChatRoomSummary() -> Single<[ChatRoomSummary]> {
        return provider.rx.request(.fetchMyChatRoomSummary(accessToken: accessToken))
            .filterSuccessfulStatusCodes()
            .map { response -> [ChatRoomSummary] in
                let json = try response.mapJSON() as? [String: Any]
                guard let data = json?["data"] as? [[String: Any]] else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Data not found"])
                }
                let chatRoomSummariesData = try JSONSerialization.data(withJSONObject: data)
                return try JSONDecoder().decode([ChatRoomSummary].self, from: chatRoomSummariesData)
            }
    }
    
    func fetchChatRoomInfo(chatRoomId: Double) -> Single<ChatRoomInfo> {
        return provider.rx.request(.fetchChatRoomInfo(accessToken: accessToken, chatRoomId: chatRoomId))
            .filterSuccessfulStatusCodes()
            .map { response -> ChatRoomInfo in
                let json = try response.mapJSON() as? [String: Any]
                guard let data = json?["data"] as? [String: Any] else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Data not found"])
                }
                let chatRoomInfoData = try JSONSerialization.data(withJSONObject: data)
                return try JSONDecoder().decode(ChatRoomInfo.self, from: chatRoomInfoData)
            }
    }
    
    func fetchMyChatRoomList() -> Single<[MyChatRoom]> {
        return provider.rx.request(.fetchMyChatRoomList(accessToken: accessToken))
            .filterSuccessfulStatusCodes()
            .map { response -> [MyChatRoom] in
                let json = try response.mapJSON() as? [String: Any]
                guard let data = json?["data"] as? [[String: Any]] else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Data not found"])
                }
                let chatRoomsData = try JSONSerialization.data(withJSONObject: data)
                return try JSONDecoder().decode([MyChatRoom].self, from: chatRoomsData)
            }
    }
    
    func deleteChatRoom(chatRoomId: Double) -> Single<Void> {
        return provider.rx.request(.deleteChatRoom(accessToken: accessToken, chatRoomId: chatRoomId))
            .filterSuccessfulStatusCodes()
            .map { response in
                print("Delete response:", response)
                return ()
            }
    }
}
