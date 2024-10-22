//
//  ChatReactor.swift
//  Dosirak
//
//  Created by 권민재 on 10/18/24.
//

//import ReactorKit
//import RxSwift
//
//
//class ChatReactor: Reactor {
//    
//    private let disposeBag = DisposeBag()
//    
//    enum Action {
//        case connect
//        case disconnect
//        case sendMessage(String)
//    }
//    
//    enum Mutation {
//        case setConnected(Bool)
//        case setReceivedMessage(String)
//    }
//    
//    struct State {
//        var isConnected: Bool = false
//        var receivedMessage: String?
//    }
//    
//    let initialState: State = State()
//    private let socketManager = RxSocketManager.shared
//    
//    func mutate(action: Action) -> Observable<Mutation> {
//        switch action {
//        case .connect:
//            socketManager.connect()
//            
//            return socketManager.isConnected
//                .map { Mutation.setConnected($0) }
//        case .disconnect:
//            socketManager.disconnect()
//            return Observable.just(Mutation.setConnected(false))
//        case .sendMessage(let message):
//            return socketManager.emit(event: "sendMessage", with: [message])
//                .flatMap { Observable.empty() }
//        }
//    }
//    
//    func reduce(state: State, mutation: Mutation) -> State {
//        var newState = state
//        switch mutation {
//        case .setConnected(let isConnected):
//            newState.isConnected = isConnected
//        case .setReceivedMessage(let message):
//            newState.receivedMessage = message
//        }
//        return newState
//    }
//    
//  
//    
//}
