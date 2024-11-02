//
//  ChatReactor.swift
//  Dosirak
//
//  Created by 권민재 on 10/18/24.
//
import ReactorKit
import RxSwift
import Foundation

class ChatReactor: Reactor {
    // Action 정의
    enum Action {
        case loadChatRoomInfo
        case sendMessage(String)
    }
    
    // Mutation 정의
    enum Mutation {
        case setChatRoomInfo(ChatRoomInfo)
        case appendMessage(Message)
    }
    
    // State 정의
    struct State {
        var chatRoomInfo: ChatRoomInfo? // messageList는 chatRoomInfo 내부에서 관리
    }
    
    let initialState: State
    private let chatUseCase: ChatUseCaseType
    private let disposeBag = DisposeBag()
    
    init(chatUseCase: ChatUseCaseType) {
        self.chatUseCase = chatUseCase
        self.initialState = State()
        
        // 새로운 메시지를 관찰하고, 상태에 추가하는 로직
        chatUseCase.observeMessages()
            .map { Mutation.appendMessage($0) }
            .subscribe(onNext: { [weak self] mutation in
                self?.action.onNext(.loadChatRoomInfo) // 새로운 메시지가 들어오면 정보 업데이트
            })
            .disposed(by: disposeBag)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadChatRoomInfo:
            // 채팅방 정보 가져오기
            return chatUseCase.fetchChatRoomInfo()
                .map { Mutation.setChatRoomInfo($0) }
                .asObservable()
            
        case .sendMessage(let content):
            // 새 메시지 전송
            return chatUseCase.sendMessage(content)
                .flatMap { _ -> Observable<Mutation> in
                    // 전송한 메시지의 객체 생성 후 Mutation으로 반환
                    let message = Message(
                        id: UUID().hashValue,
                        content: content,
                        messageType: .chat,
                        createdAt: Date().description,
                        userChatRoomResponse: UserChatRoomResponse(
                            userId: 0,  // 실제 유저 ID로 변경 필요
                            nickName: "Me",
                            profileImg: ""  // 실제 프로필 이미지 URL이 있으면 추가
                        ),
                        chatRoomId: self.initialState.chatRoomInfo?.userList.first?.userId ?? 1
                    )
                    return Observable.just(Mutation.appendMessage(message))
                }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setChatRoomInfo(let info):
            newState.chatRoomInfo = info
            
        case .appendMessage(let message):
            if let chatRoomInfo = newState.chatRoomInfo {
                // 기존 messageList를 수정 가능하게 복사하여 메시지 추가 후 새로운 ChatRoomInfo로 업데이트
                var updatedMessages = chatRoomInfo.messageList
                updatedMessages.append(message)
                
                // 변경된 messageList로 새로운 ChatRoomInfo 생성
                let updatedChatRoomInfo = ChatRoomInfo(
                    personCount: chatRoomInfo.personCount,
                    explanation: chatRoomInfo.explanation,
                    messageList: updatedMessages,
                    userList: chatRoomInfo.userList
                )
                newState.chatRoomInfo = updatedChatRoomInfo
            }
        }
        
        return newState
    }
}
