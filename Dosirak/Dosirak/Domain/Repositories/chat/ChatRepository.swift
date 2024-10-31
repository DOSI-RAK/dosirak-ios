//
//  ChatRepository.swift
//  Dosirak
//
//  Created by 권민재 on 10/31/24.
//

import Foundation
import RxSwift
import SocketIO

protocol ChatRepositoryType {
    func sendMessage(_ message: String, to chatRoomId: Int) -> Observable<Void>
    func observeMessages() -> Observable<ChatMessage>
}

final class ChatRepository: ChatRepositoryType {
    private let manager: SocketManager
    private let socket: SocketIOClient
    
    // 서버 URL과 설정 정의
    init() {
        self.manager = SocketManager(socketURL: URL(string: "http://dosirak.store/app/chat-room/{id}/sendMessage")!, config: [.log(true), .compress])
        self.socket = manager.defaultSocket
        self.socket.connect()
    }
    
    // 메시지 전송 메서드
    func sendMessage(_ message: String, to chatRoomId: Int) -> Observable<Void> {
        return Observable.create { observer in
            let data: [String: Any] = ["chatRoomId": chatRoomId, "content": message]
            // 서버로 메시지 전송
            self.socket.emit("sendMessage", data)
            observer.onNext(())
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    // 메시지 수신 메서드
    func observeMessages() -> Observable<ChatMessage> {
        return Observable.create { observer in
            // 새로운 메시지를 수신할 때마다 "newMessage" 이벤트가 발생
            self.socket.on("newMessage") { (data, ack) in
                if let messageData = data.first as? [String: Any],
                   let jsonData = try? JSONSerialization.data(withJSONObject: messageData),
                   let message = try? JSONDecoder().decode(ChatMessage.self, from: jsonData) {
                    // 수신한 메시지를 observer로 전달
                    observer.onNext(message)
                }
            }
            
            // 소켓 리스너를 정리하는 디스포저블 생성
            return Disposables.create {
                self.socket.off("newMessage")
            }
        }
    }
}
