//
//  StompClient.swift
//  Dosirak
//
//  Created by 권민재 on 11/7/24.
//
import StompClientLib
import Foundation

class StompClient: StompClientLibDelegate {
    private let stompClient = StompClientLib()
    private let url = URL(string: "ws://dosirak.store/dosirak")!
    private let accessToken: String
    private let chatRoomId: Int

    init(chatRoomId: Int, accessToken: String) {
        self.chatRoomId = chatRoomId
        self.accessToken = accessToken
        connect()
    }
    var didReceiveMessage: ((String) -> Void)?
    // WebSocket 연결
    func connect() {
        let headers = [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "application/json"
            
        ]
        
        stompClient.openSocketWithURLRequest(request: URLRequest(url: url) as NSURLRequest, delegate: self, connectionHeaders: headers)
    }

    // 채팅방에 메시지 구독
    func subscribe() {
        let destination = "/topic/chat-room/\(chatRoomId)"
        stompClient.subscribe(destination: destination)
        print("구독 요청: \(destination)")
    }

    // 채팅방에 메시지 전송
    func sendMessage(content: String, messageType: String) {
        let destination = "/app/chat-room/\(chatRoomId)/sendMessage"
        
        // JSON 형식의 메시지 생성
        let message: [String: Any] = [
            "content": content,
            "messageType": messageType
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: message, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            stompClient.sendMessage(message: jsonString, toDestination: destination, withHeaders: ["Content-Type": "application/json"], withReceipt: nil)
            print("메시지 전송: \(jsonString) -> \(destination)")
        }
    }

    // WebSocket 연결 해제
    func disconnect() {
        stompClient.disconnect()
        print("STOMP 연결 해제")
    }

    // MARK: - StompClientLibDelegate 메서드

    func stompClientDidConnect(client: StompClientLib!) {
        print("STOMP 연결 성공")
    }

    func stompClientDidDisconnect(client: StompClientLib!) {
        print("STOMP 연결 종료")
    }

    func stompClient(client: StompClientLib!, didReceiveMessageWithJSONBody jsonBody: AnyObject?, akaStringBody stringBody: String?, withHeader header: [String : String]?, withDestination destination: String) {
        if let message = stringBody {
            print("받은 메시지: \(message)")
        }
    }

    func serverDidSendReceipt(client: StompClientLib!, withReceiptId receiptId: String) {
        print("서버에서 메시지 수신 확인: \(receiptId)")
    }

    func serverDidSendError(client: StompClientLib!, withErrorMessage description: String, detailedErrorMessage message: String?) {
        print("STOMP 에러 발생: \(description), 세부 메시지: \(message?.description ?? "")")
    }

    func serverDidSendPing() {
        print("서버에서 Ping 수신")
    }
}
