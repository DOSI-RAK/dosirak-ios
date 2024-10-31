//
//  ChatListReactor.swift
//  Dosirak
//
//  Created by 권민재 on 10/31/24.
//

import ReactorKit
import RxSwift

enum SortOption: String, CaseIterable {
    case popular
    case recent
}

class ChatListReactor: Reactor {
    
    enum Action {
        case loadMyChatRooms
        case loadNearbyChatRooms(String)
        case loadChatRoomSummary
        case selectSort(SortOption)
    }
    
    enum Mutation {
        case setMyChatRooms([MyChatRoom])
        case setNearbyChatRooms([ChatRoom])
        case setChatRoomSummary([ChatRoomSummary])
        case setLoading(Bool)
        case setError(String)
    }
    
    struct State {
        var myChatRooms: [MyChatRoom] = []
        var nearbyChatRooms: [ChatRoom] = []
        var chatRoomSummary: [ChatRoomSummary] = []
        var isLoading: Bool = false
        var errorMessage: String?
    }
    
    let initialState = State()
    private let chatListUseCase: ChatListUseCaseType
    
    init(chatListUseCase: ChatListUseCaseType) {
        self.chatListUseCase = chatListUseCase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadMyChatRooms:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                chatListUseCase.getMyChatRoomList()
                    .map { Mutation.setMyChatRooms($0) }
                    .catchAndReturn(Mutation.setError("Failed to load my chat rooms"))
                    .asObservable(),
                Observable.just(Mutation.setLoading(false))
            ])
            
        case .loadNearbyChatRooms(let zone):
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                chatListUseCase.getMyLocationChatRoom(zone: zone)
                    .map { Mutation.setNearbyChatRooms($0) }
                    .catchAndReturn(Mutation.setError("Failed to load nearby chat rooms"))
                    .asObservable(),
                Observable.just(Mutation.setLoading(false))
            ])
            
        case .loadChatRoomSummary:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                chatListUseCase.getMyChatRoomSummary()
                    .map { Mutation.setChatRoomSummary($0) }
                    .catchAndReturn(Mutation.setError("Failed to load chat room summary"))
                    .asObservable(),
                Observable.just(Mutation.setLoading(false))
            ])
            
        case .selectSort(let sortOption):
            // Sorting logic can be added here based on the selected option
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setMyChatRooms(let chatRooms):
            newState.myChatRooms = chatRooms
            
        case .setNearbyChatRooms(let chatRooms):
            newState.nearbyChatRooms = chatRooms
            
        case .setChatRoomSummary(let chatRoomSummary):
            newState.chatRoomSummary = chatRoomSummary
            
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .setError(let errorMessage):
            newState.errorMessage = errorMessage
        }
        return newState
    }
}
