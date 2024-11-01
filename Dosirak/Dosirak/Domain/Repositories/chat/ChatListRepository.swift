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
        print("Calling fetchMyLocationChatRoom")
        return provider.rx.request(.fetchMyLocationChatRoom(accessToken: accessToken, zone: zone))
            .filterSuccessfulStatusCodes()
            .map(ChatRoomResponse.self)
            .flatMap { response in
                if response.status == "SUCCESS" {
                    return Single.just(response.data)
                } else {
                    return Single.error(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch chat room summary"]))
                }
            }
    }
    
    func fetchMyChatRoomSummary() -> Single<[ChatRoomSummary]> {
        print("Calling fetchMyChatRoomSummary ")
        return provider.rx.request(.fetchMyChatRoomSummary(accessToken: accessToken))
            .filterSuccessfulStatusCodes()
            .map { response in
                do {
                    let decodedResponse = try JSONDecoder().decode(MyChatRoomSummaryResponse.self, from: response.data)
                    if decodedResponse.status == "SUCCESS" {
                        print("=======>\(decodedResponse.status)")
                        print("Fetched ChatRoomSummary Response:", decodedResponse.data) // 디버그용 출력
                        return decodedResponse.data
                    } else {
                        throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch chat room summary"])
                    }
                } catch {
                    print("Decoding error:", error)
                    throw error
                }
            }
            .do(onSuccess: { summaries in
                print("Decoded My Chat Room Summary:", summaries) // 디코딩 확인용
            })
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
            .do(onSuccess: { chatRoomInfo in
                print("Fetched Chat Room Info:", chatRoomInfo)
            })
    }
    
    func fetchMyChatRoomList() -> Single<[MyChatRoom]> {
        print("Calling fetchMyChatRoomList")
        return provider.rx.request(.fetchMyChatRoomList(accessToken: accessToken))
            .filterSuccessfulStatusCodes()
            .map { response in
                do {
                    let decodedResponse = try JSONDecoder().decode(MyChatRoomListResponse.self, from: response.data)
                    if decodedResponse.status == "SUCCESS" {
                        print("=======>\(decodedResponse.status)")
                        print("Fetched ChatRoomSummary Response:", decodedResponse.data) // 디버그용 출력
                        return decodedResponse.data
                    } else {
                        throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch chat room summary"])
                    }
                } catch {
                    print("Decoding error:", error)
                    throw error
                }
            }
            .do(onSuccess: { summaries in
                print("Decoded My Chat RoomList:", summaries) // 디코딩 확인용
            })
    }
    
    func deleteChatRoom(chatRoomId: Double) -> Single<Void> {
        return provider.rx.request(.deleteChatRoom(accessToken: accessToken, chatRoomId: chatRoomId))
            .filterSuccessfulStatusCodes()
            .do(onSuccess: { response in
                print("Delete Chat Room Response:", response)
            })
            .map { _ in () }
    }
}
