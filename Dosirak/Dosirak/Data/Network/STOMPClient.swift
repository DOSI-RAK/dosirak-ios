//
//  StompClient.swift
//  Dosirak
//
//  Created by 권민재 on 11/7/24.
//

//import Starscream
//import UIKit
//
//class StompWebSocketClient: WebSocketDelegate {
//    
//
//    private var socket: WebSocket!
//    private let url: URL
//    private let accessToken: String
//    private let chatRoomId: String
//
//    init(url: String, accessToken: String, chatRoomId: String) {
//        self.url = URL(string: url)!
//        self.accessToken = accessToken
//        self.chatRoomId = chatRoomId
//        configureSocket()
//    }
//
//    private func configureSocket() {
//        var request = URLRequest(url: url)
//        request.timeoutInterval = 5
//        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
//        
//        socket = WebSocket(request: request)
//        socket.delegate = self
//    }
//    
//    // MARK: - STOMP 메시지 생성
//    
//    private func stompConnect() -> String {
//        return "CONNECT\naccept-version:1.1,1.0\nheart-beat:10000,10000\n\n^@"
//    }
//    
//    private func stompSubscribe(to destination: String) -> String {
//        return "SUBSCRIBE\ndestination:\(destination)\nid:sub-\(UUID().uuidString)\n\n^@"
//    }
//    
//    private func stompSend(destination: String, body: String) -> String {
//        return "SEND\ndestination:\(destination)\ncontent-type:text/plain\n\n\(body)^@"
//    }
//    
//    private func stompDisconnect() -> String {
//        return "DISCONNECT\n\n^@"
//    }
//    
//    // MARK: - WebSocket 연결 및 STOMP 통신
//    
//    func connect() {
//        socket.connect()
//    }
//    
//    func disconnect() {
//        let disconnectMessage = stompDisconnect()
//        socket.write(string: disconnectMessage)
//        socket.disconnect()
//    }
//    
//    func subscribeToChatRoom() {
//        let destination = "/topic/chat-room/\(chatRoomId)"
//        let subscribeMessage = stompSubscribe(to: destination)
//        socket.write(string: subscribeMessage)
//    }
//    
//    func sendMessage(content: String) {
//        let destination = "/app/chat-room/\(chatRoomId)/sendMessage"
//        let sendMessage = stompSend(destination: destination, body: content)
//        socket.write(string: sendMessage)
//    }
//    
//    // MARK: - WebSocketDelegate
//    
//    func didReceive(event: WebSocketEvent, client: StarScream.WebSocketClient) {
//        switch event {
//        case .connected(let headers):
//            print("WebSocket 연결됨, 헤더: \(headers)")
//            // 연결 후 STOMP CONNECT 메시지 전송
//            let connectMessage = stompConnect()
//            socket.write(string: connectMessage)
//        case .disconnected(let reason, let code):
//            print("WebSocket 연결 해제됨, 이유: \(reason), 코드: \(code)")
//        case .text(let text):
//            print("메시지 수신: \(text)")
//            handleStompMessage(text: text)
//        case .binary(let data):
//            print("바이너리 데이터 수신: \(data.count) bytes")
//        case .error(let error):
//            print("WebSocket 오류 발생: \(String(describing: error))")
//        case .cancelled:
//            print("WebSocket 연결 취소됨")
//        default:
//            break
//        }
//    }
//    func didReceive(event: Starscream.WebSocketEvent, client: any Starscream.WebSocketClient) {
//        <#code#>
//    }
//    
//    // MARK: - STOMP 메시지 핸들링
//    
//    private func handleStompMessage(text: String) {
//        // STOMP 메시지 해석 및 로직 처리
//        print("STOMP 메시지 수신: \(text)")
//        // 필요한 경우 메시지를 파싱하고 이벤트를 처리할 수 있습니다.
//    }
//}
