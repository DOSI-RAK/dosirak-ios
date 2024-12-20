//
//  ChatRepository.swift
//  Dosirak
//
//  Created by 권민재 on 10/31/24.
//

import RxSwift
import Foundation

protocol ChatRepositoryType {
    func connect()
    func disconnect()
    func sendMessage(_ content: String, messageType: String)
    func observeMessages() -> Observable<Message>
    func fetchChatRoomInfo() -> Single<ChatRoomInfo>
}

class ChatRepository: ChatRepositoryType {
    private let stompClient: StompClient
    private let messageSubject = PublishSubject<Message>()
    private let chatRoomId: Int
    private let accessToken: String

    init(chatRoomId: Int, accessToken: String) {
        self.chatRoomId = chatRoomId
        self.accessToken = accessToken
        self.stompClient = StompClient(chatRoomId: chatRoomId, accessToken: accessToken)
         
        setupStompClient()
    }
    
    private func setupStompClient() {
        // StompClient의 메시지 수신을 구독하여 messageSubject로 전달
        stompClient.didReceiveMessage = { [weak self] message in
            self?.messageSubject.onNext(message)
        }
    }

    // WebSocket 연결
    func connect() {
        stompClient.connect()
        stompClient.subscribe()
    }

    // WebSocket 연결 해제
    func disconnect() {
        stompClient.disconnect()
    }

    // 메시지 전송
    func sendMessage(_ content: String, messageType: String) {
        stompClient.sendMessage(content: content, messageType: messageType)
    }

    // 메시지 수신을 관찰
    func observeMessages() -> Observable<Message> {
        return messageSubject.asObservable()
    }

    // 채팅방 정보 불러오기
    func fetchChatRoomInfo() -> Single<ChatRoomInfo> {
        let url = URL(string: "http://dosirak.store/api/chat-rooms/\(chatRoomId)/information")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        return Single.create { single in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    single(.failure(error))
                    return
                }
                
                guard let data = data else {
                    single(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                    return
                }
                
                do {
                    let chatRoomInfoResponse = try JSONDecoder().decode(APIResponse<ChatRoomInfo?>.self, from: data)
                    if let chatRoomInfo = chatRoomInfoResponse.data {
                        print("=============?\(chatRoomInfo.messageList)")
                        single(.success(chatRoomInfo))
                    } else {
                        single(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data in response"])))
                    }
                } catch {
                    single(.failure(error))
                }
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
