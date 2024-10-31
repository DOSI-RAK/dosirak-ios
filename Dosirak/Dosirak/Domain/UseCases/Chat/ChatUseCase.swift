//
//  ChatUseCase.swift
//  Dosirak
//
//  Created by 권민재 on 10/31/24.
//
import Foundation
import RxSwift

protocol ChatUseCaseType {
    func sendMessage(_ message: String, to chatRoomId: Int) -> Observable<Void>
    func observeMessages() -> Observable<ChatMessage>
}

final class ChatUseCase: ChatUseCaseType {
    private let repository: ChatRepositoryType
    
    init(repository: ChatRepositoryType) {
        self.repository = repository
    }
    
    func sendMessage(_ message: String, to chatRoomId: Int) -> Observable<Void> {
        return repository.sendMessage(message, to: chatRoomId)
    }
    
    func observeMessages() -> Observable<ChatMessage> {
        return repository.observeMessages()
    }
}
