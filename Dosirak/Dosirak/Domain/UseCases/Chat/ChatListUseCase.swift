//
//  ChatListUseCase.swift
//  Dosirak
//
//  Created by 권민재 on 10/31/24.
//

import RxSwift

protocol ChatListUseCaseType {
    func getMyLocationChatRoom(zone: String) -> Single<[ChatRoom]>
    func getMyChatRoomSummary() -> Single<[ChatRoomSummary]>
    func getChatRoomInfo(chatRoomId: Double) -> Single<ChatRoomInfo>
    func getMyChatRoomList() -> Single<[MyChatRoom]>
    func removeChatRoom(chatRoomId: Double) -> Single<Void>
}

class ChatListUseCase: ChatListUseCaseType {
    private let chatListRepository: ChatListRepositoryType
    
    init(chatListRepository: ChatListRepositoryType) {
        self.chatListRepository = chatListRepository
    }
    
    func getMyLocationChatRoom(zone: String) -> Single<[ChatRoom]> {
        return chatListRepository.fetchMyLocationChatRoom(zone: zone)
    }
    
    func getMyChatRoomSummary() -> Single<[ChatRoomSummary]> {
        return chatListRepository.fetchMyChatRoomSummary()
    }
    
    func getChatRoomInfo(chatRoomId: Double) -> Single<ChatRoomInfo> {
        return chatListRepository.fetchChatRoomInfo(chatRoomId: chatRoomId)
    }
    
    func getMyChatRoomList() -> Single<[MyChatRoom]> {
        return chatListRepository.fetchMyChatRoomList()
    }
    
    func removeChatRoom(chatRoomId: Double) -> Single<Void> {
        return chatListRepository.deleteChatRoom(chatRoomId: chatRoomId)
    }
}
