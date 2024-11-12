//
//  ChatReactor.swift
//  Dosirak
//
//  Created by 권민재 on 10/18/24.
//
// ChatReactor.swift
import ReactorKit
import RxSwift
import Foundation

class ChatReactor: Reactor {
    enum Action {
        case connect
        case disconnect
        case sendMessage(String)
        case loadChatRoomInfo
        case receiveMessage(Message) // 수신한 메시지를 처리하는 Action
    }
    
    enum Mutation {
        case setMessages([Message])
        case addMessage(Message)
        case setChatRoomInfo(ChatRoomInfo)
        case setError(String) // 에러 메시지 Mutation
    }
    
    struct State {
        var messageList: [Message] = []
        var chatRoomInfo: ChatRoomInfo?
        var errorMessage: String? // 에러 메시지 상태
    }

    let initialState = State()
    private let useCase: ChatUseCaseType
    private let disposeBag = DisposeBag()

    init(useCase: ChatUseCaseType) {
        self.useCase = useCase
        observeMessages()  // 메시지 수신을 옵저빙
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .connect:
            useCase.connect()
            return .empty()
        
        case .disconnect:
            useCase.disconnect()
            print("연결 종료")
            return .empty()
        
        case .sendMessage(let content):
            useCase.sendMessage(content: content, messageType: "CHAT")
            return .empty()
        
        case .loadChatRoomInfo:
            return useCase.fetchChatRoomInfo()
                .map { Mutation.setChatRoomInfo($0) }
                .catch { error in
                    .just(Mutation.setError("Failed to load chat room info: \(error.localizedDescription)"))
                }
                .asObservable()
                
        case .receiveMessage(let message):  // 수신된 메시지를 상태에 추가
            return .just(Mutation.addMessage(message))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setMessages(let messages):
            newState.messageList = messages
            
        case .addMessage(let message):
            newState.messageList.append(message)
            
        case .setChatRoomInfo(let info):
            newState.chatRoomInfo = info
            newState.messageList = info.messageList
            
        case .setError(let error):
            newState.errorMessage = error
        }
        return newState
    }

    private func observeMessages() {
            useCase.observeMessages()
                .map { Action.receiveMessage($0) }
                .bind(to: action)
                .disposed(by: disposeBag)
        }
}
