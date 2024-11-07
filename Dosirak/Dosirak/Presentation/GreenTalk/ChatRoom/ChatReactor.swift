//
//  ChatReactor.swift
//  Dosirak
//
//  Created by 권민재 on 10/18/24.
//
// ChatReactor.swift
import ReactorKit
import RxSwift

class ChatReactor: Reactor {
    enum Action {
        case connect
        case disconnect
        case sendMessage(String)
        case loadChatRoomInfo
    }
    
    enum Mutation {
        case setMessages([Message]) // Message 배열로 수정
        case addMessage(Message)     // Message 타입으로 추가
        case setChatRoomInfo(ChatRoomInfo)
    }
    
    struct State {
        var messageList: [Message] = []
        var chatRoomInfo: ChatRoomInfo?
    }

    let initialState = State()
    private let useCase: ChatUseCaseType

    init(useCase: ChatUseCaseType) {
        self.useCase = useCase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .connect:
            useCase.connect()
            return .empty()
        
        case .disconnect:
            useCase.disconnect()
            print("연결종료")
            return .empty()
        
        case .sendMessage(let content):
            useCase.sendMessage(content: content, messageType: "CHAT")
            return .empty()
        
        case .loadChatRoomInfo:
            return useCase.fetchChatRoomInfo()
                .map { Mutation.setChatRoomInfo($0) }
                .asObservable()
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
            newState.messageList = info.messageList // chatRoomInfo의 messageList를 상태에 반영
        }
        return newState
    }
}
