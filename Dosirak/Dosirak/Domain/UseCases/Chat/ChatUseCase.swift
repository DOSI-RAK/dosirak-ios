//
//  ChatUseCase.swift
//  Dosirak
//
//  Created by 권민재 on 10/31/24.
//
import Foundation
import RxSwift

protocol ChatUseCaseType {
    var chatRoomId: Int { get }
    func sendMessage(_ message: String) -> Observable<Void>
    func observeMessages() -> Observable<Message>
    func fetchChatRoomInfo() -> Single<ChatRoomInfo>
}

final class ChatUseCase: ChatUseCaseType {
    private let repository: ChatRepositoryType
    let chatRoomId: Int
    
    init(repository: ChatRepositoryType, chatRoomId: Int) {
        self.repository = repository
        self.chatRoomId = chatRoomId
    }
    
    func sendMessage(_ message: String) -> Observable<Void> {
        return repository.sendMessage(message)
    }
    
    func observeMessages() -> Observable<Message> {
        return repository.observeMessages()
    }
    
    func fetchChatRoomInfo() -> Single<ChatRoomInfo> {
        return repository.fetchChatRoomInfo()
    }
}
