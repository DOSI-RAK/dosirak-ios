//
//  ChatRepository.swift
//  Dosirak
//
//  Created by 권민재 on 10/31/24.
//

import Foundation
import RxSwift
import SocketIO
import KeychainAccess

protocol ChatRepositoryType {
    func sendMessage(_ message: String) -> Observable<Void>
    func fetchChatRoomInfo() -> Single<ChatRoomInfo>
    func observeMessages() -> Observable<Message>
}

final class ChatRepository: ChatRepositoryType {
   
    
    private let manager: SocketManager
    private let socket: SocketIOClient
    private let accessToken: String
    private let chatRoomId: Int
    
    init(accessToken: String, chatRoomId: Int) {
        self.accessToken = accessToken
        self.chatRoomId = chatRoomId
        let socketURL = URL(string: "ws://dosirak.store/app/chat-room/\(chatRoomId)/sendMessage")!
        self.manager = SocketManager(socketURL: socketURL, config: [
            .log(true),
            .compress,
            .extraHeaders(["Authorization": "Bearer \(accessToken)", "Content-Type": "application/json"])
        ])
            
        self.socket = manager.defaultSocket
        // self.socket.connect()
    }
    
    func fetchChatRoomInfo() -> Single<ChatRoomInfo> {
        return Single.create { single in
            let url = URL(string: "http://dosirak.store/api/chat-rooms/\(self.chatRoomId)/information")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(self.accessToken)", forHTTPHeaderField: "Authorization")
            
            print("Request URL: \(url)")
            print("Authorization Header: Bearer \(self.accessToken)")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error received: \(error.localizedDescription)")
                    single(.failure(error))
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("HTTP Status Code: \(httpResponse.statusCode)")
                }
                
                guard let data = data else {
                    print("No data received")
                    single(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                    return
                }
                
                do {
                    print("Raw JSON Data: \(String(data: data, encoding: .utf8) ?? "No JSON Data")")
                    
                    // 전체 응답을 `ChatRoomInfoResponse`로 디코딩하고 `data` 필드만 추출
                    let chatRoomInfoResponse = try JSONDecoder().decode(ChatRoomInfoResponse.self, from: data)
                    
                    if let chatRoomInfo = chatRoomInfoResponse.data {
                        single(.success(chatRoomInfo))  // `data` 필드만 반환
                    } else {
                        single(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data field in response"])))
                    }
                    
                } catch {
                    print("JSON Decoding Error: \(error.localizedDescription)")
                    single(.failure(error))
                }
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    func sendMessage(_ message: String) -> Observable<Void> {
        return Observable.create { observer in
            let data: [String: Any] = [
                "chatRoomId": self.chatRoomId,
                "content": message,
                "messageType": MessageType.chat.rawValue
            ]
            self.socket.emit("sendMessage", data)
            observer.onNext(())
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    func observeMessages() -> Observable<Message> {
        return Observable.create { observer in
            self.socket.on("newMessage") { (data, ack) in
                if let messageData = data.first as? [String: Any],
                   let jsonData = try? JSONSerialization.data(withJSONObject: messageData),
                   let message = try? JSONDecoder().decode(Message.self, from: jsonData) {
                    observer.onNext(message)
                }
            }
            
            return Disposables.create {
                self.socket.off("newMessage")
            }
        }
    }
}
