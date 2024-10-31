//
//  ChatReactor.swift
//  Dosirak
//
//  Created by 권민재 on 10/18/24.
//
import ReactorKit
import RxSwift

final class ChatReactor: Reactor {
    enum Action {
        case sendMessage(String)
    }
    
    enum Mutation {
        case receiveMessage(ChatMessage)
    }
    
    struct State {
        var messages: [ChatMessage] = []
    }
    
    let initialState = State()
    
    private let chatUseCase: ChatUseCaseType
    
    init(chatUseCase: ChatUseCaseType) {
        self.chatUseCase = chatUseCase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .sendMessage(let content):
            return chatUseCase.sendMessage(content, to: 1234) // Chat Room ID 하드코딩된 예시
                .flatMap { _ in Observable<Mutation>.empty() }
        }
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let messageStream = chatUseCase.observeMessages()
            .map { Mutation.receiveMessage($0) }
        return Observable.merge(mutation, messageStream)
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .receiveMessage(let message):
            newState.messages.append(message)
        }
        return newState
    }
}
