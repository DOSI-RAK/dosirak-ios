//
//  StompClient.swift
//  Dosirak
//
//  Created by 권민재 on 11/7/24.
//

import Foundation

class StompClient {
    private var webSocketTask: URLSessionWebSocketTask?
    private let urlSession = URLSession(configuration: .default)
    private let accessToken: String
    private let chatRoomId: Int
    
    private var url: URL {
        return URL(string: "ws://dosirak.store/dosirak")! // 서버의 STOMP 엔드포인트
    }
    
    init(chatRoomId: Int, accessToken: String) {
        self.chatRoomId = chatRoomId
        self.accessToken = accessToken
    }
    
    // WebSocket 연결
    func connect() {
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        webSocketTask = urlSession.webSocketTask(with: request)
        webSocketTask?.resume()
        
        // STOMP CONNECT 프레임 전송
        let connectFrame = 
        """
        CONNECT
        accept-version:1.2,1.1,1.0
        """
        sendFrame(connectFrame)
        
        // 메시지 수신 대기
        receiveMessages()
    }
    
    // STOMP 프레임 전송
    private func sendFrame(_ frame: String) {
        webSocketTask?.send(.string(frame)) { error in
            if let error = error {
                print("Frame 전송 오류: \(error.localizedDescription)")
            }
        }
    }
    
    // 메시지 전송
    func sendMessage(content: String, messageType: String) {
        let messageFrame =
        """
        SEND
        destination:/app/chat-room/\(chatRoomId)/sendMessage
        content-type:application/json\n\n{"content":"\(content)", "messageType":"CHAT"}\u{00}
        """
        sendFrame(messageFrame)
    }
    
    // 구독
    func subscribe() {
        let subscribeFrame = """
        SUBSCRIBE\ndestination:/topic/chat-room/\(chatRoomId)\nid:sub-\(chatRoomId)\n\n\u{00}
        """
        sendFrame(subscribeFrame)
    }
    
    // 메시지 수신
    private func receiveMessages() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received message: \(text)")
                    // 메시지 처리 로직 추가
                case .data(let data):
                    print("Received data: \(data)")
                @unknown default:
                    break
                }
            case .failure(let error):
                print("Receive error: \(error.localizedDescription)")
            }
            self?.receiveMessages() // 계속 수신 대기
        }
    }
    
    // 연결 해제
    func disconnect() {
        let disconnectFrame = "DISCONNECT\n\n\u{00}"
        sendFrame(disconnectFrame)
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
}
