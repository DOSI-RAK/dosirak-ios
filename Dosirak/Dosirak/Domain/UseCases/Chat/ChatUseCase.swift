//
//  ChatUseCase.swift
//  Dosirak
//
//  Created by 권민재 on 10/31/24.
//
import RxSwift

protocol ChatUseCaseType {
    func connect()
    func disconnect()
    func sendMessage(content: String, messageType: String)
    func observeMessages() -> Observable<String>
    func fetchChatRoomInfo() -> Single<ChatRoomInfo>
}

class ChatUseCase: ChatUseCaseType {
    private let repository: ChatRepositoryType

    init(repository: ChatRepositoryType) {
        self.repository = repository
    }
    
    func connect() {
        repository.connect()
    }
    
    func disconnect() {
        repository.disconnect()
    }
    
    func sendMessage(content: String, messageType: String) {
        repository.sendMessage(content, messageType: messageType)
    }
    
    func observeMessages() -> Observable<String> {
        return repository.observeMessages()
    }
    
    func fetchChatRoomInfo() -> Single<ChatRoomInfo> {
        return repository.fetchChatRoomInfo()
    }
}
