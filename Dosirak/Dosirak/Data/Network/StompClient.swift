//
//  StompClient.swift
//  Dosirak
//
//  Created by 권민재 on 11/7/24.
//
//import StompClientLib
//import Foundation
//
//
//class StompClient: StompClientLibDelegate {
//    private let stompClient = StompClientLib()
//    private let url = URL(string: "ws://dosirak.store/dosirak")!
//    private let accessToken: String
//    private let chatRoomId: Int
//    private var isSubscribed = false
//    private var isConnected = false
//    var didReceiveMessage: ((String) -> Void)?
//
//    init(chatRoomId: Int, accessToken: String) {
//        self.chatRoomId = chatRoomId
//        self.accessToken = accessToken
//        connect()
//    }
//    
//    func connect() {
//        guard !isConnected else {
//            print("이미 연결되어 있습니다.")
//            return
//        }
//        let headers = [
//            "Authorization": "Bearer \(accessToken)",
//            "chatRoomId": "\(chatRoomId)"
//        ]
//        
//        print("WebSocket 연결 요청: \(url), 헤더: \(headers)")
//        stompClient.openSocketWithURLRequest(request: URLRequest(url: url) as NSURLRequest, delegate: self, connectionHeaders: headers)
//    }
//    
//    func subscribe() {
//        guard !isSubscribed else {
//            print("이미 구독된 상태입니다.")
//            return
//        }
//        
//        let destination = "/topic/chat-room/\(chatRoomId)"
//        stompClient.subscribe(destination: destination)
//        isSubscribed = true
//        print("구독 요청: \(destination)")
//    }
//    
//    func sendMessage(content: String, messageType: String) {
//        let destination = "/app/chat-room/\(chatRoomId)/sendMessage"
//        
//        let message: [String: Any] = [
//            "content": content,
//            "messageType": messageType
//        ]
//        
//        if let jsonData = try? JSONSerialization.data(withJSONObject: message, options: [.prettyPrinted]),
//           let jsonString = String(data: jsonData, encoding: .utf8) {
//            
//            let headers: [String: String] = [
//                "Authorization": "Bearer \(accessToken)"
//            ]
//            
//            print("전송할 메시지 (JSON): \(jsonString)")
//            print("전송 헤더: \(headers)")
//            
//            stompClient.sendMessage(message: jsonString, toDestination: destination, withHeaders: headers, withReceipt: nil)
//            
//        } else {
//            print("메시지 JSON 변환 실패")
//        }
//    }
//    
//    func disconnect() {
//        stompClient.disconnect()
//        isConnected = false
//        isSubscribed = false
//        print("STOMP 연결 해제")
//    }
//
//    // MARK: - StompClientLibDelegate
//    
//    func stompClientDidConnect(client: StompClientLib!) {
//        print("STOMP 연결 성공: chatRoomId = \(chatRoomId)")
//        isConnected = true
//        subscribe()
//    }
//    
//    func stompClientDidDisconnect(client: StompClientLib!) {
//        print("STOMP 연결 종료")
//        isConnected = false
//        isSubscribed = false
//    }
//    
//    func stompClient(client: StompClientLib!, didReceiveMessageWithJSONBody jsonBody: AnyObject?, akaStringBody stringBody: String?, withHeader header: [String : String]?, withDestination destination: String) {
//        print("응답 수신")
//        
//        if let jsonBody = jsonBody as? [String: Any] {
//            do {
//                // JSON 객체를 Data로 변환 후 디코딩
//                let jsonData = try JSONSerialization.data(withJSONObject: jsonBody, options: [])
//                let message = try JSONDecoder().decode(Message.self, from: jsonData)
//                
//                print("받은 메시지: \(message)")
//                didReceiveMessage?(message.content)
//                
//            } catch {
//                print("JSON 디코딩 실패: \(error)")
//            }
//        } else if let message = stringBody {
//            print("수신된 메시지 (문자열): \(message)")
//            didReceiveMessage?(message)
//        } else {
//            print("수신 메시지 변환 실패 또는 빈 메시지")
//        }
//    }
//    
//    func serverDidSendReceipt(client: StompClientLib!, withReceiptId receiptId: String) {
//        print("서버에서 메시지 수신 확인: \(receiptId)")
//    }
//    
//    func serverDidSendError(client: StompClientLib!, withErrorMessage description: String, detailedErrorMessage message: String?) {
//        print("STOMP 에러 발생: \(description), 세부 메시지: \(message ?? "")")
//    }
//    
//    func serverDidSendPing() {
//        print("서버에서 Ping 수신")
//    }
//}
import StompClientLib
import Foundation

extension Notification.Name {
    static let stompDidConnect = Notification.Name("stompDidConnect")
    static let stompDidDisconnect = Notification.Name("stompDidDisconnect")
}

class StompClient: StompClientLibDelegate {
    private let stompClient = StompClientLib()
    private let url = URL(string: "ws://dosirak.store/dosirak")!
    private let accessToken: String
    private let chatRoomId: Int
    private let queue = DispatchQueue(label: "stompQueue")
    private var lastMessageId = 0

    private(set) var isSubscribed = false
    private(set) var isConnected = false
    var didReceiveMessage: ((String) -> Void)?
    var messageList: [Message] = []

    init(chatRoomId: Int, accessToken: String) {
        self.chatRoomId = chatRoomId
        self.accessToken = accessToken
        connect()
    }

    func connect() {
        queue.sync {
            guard !isConnected else {
                print("이미 연결되어 있습니다.")
                return
            }
            let headers = [
                "Authorization": "Bearer \(accessToken)",
                "chatRoomId": "\(chatRoomId)"
            ]
            
            print("WebSocket 연결 요청: \(url), 헤더: \(headers)")
            stompClient.openSocketWithURLRequest(request: URLRequest(url: url) as NSURLRequest, delegate: self, connectionHeaders: headers)
        }
    }

    func subscribe() {
        queue.sync {
            guard isConnected, !isSubscribed else {
                print("이미 구독된 상태이거나 연결되지 않음.")
                return
            }
            
            let destination = "/topic/chat-room/\(chatRoomId)"
            stompClient.subscribe(destination: destination)
            isSubscribed = true
            print("구독 요청 완료: \(destination)")
        }
    }

    // MARK: - Unsubscribe from a topic
    func unsubscribe() {
        queue.sync {
            guard isSubscribed else {
                print("이미 구독이 해제된 상태입니다.")
                return
            }
            
            let destination = "/topic/chat-room/\(chatRoomId)"
            stompClient.unsubscribe(destination: destination)
            isSubscribed = false
            print("구독 해제: \(destination)")
        }
    }


    func disconnect() {
        queue.sync {
            guard isConnected else {
                print("이미 연결이 해제된 상태입니다.")
                return
            }
            stompClient.disconnect()
            isConnected = false
            isSubscribed = false
            NotificationCenter.default.post(name: .stompDidDisconnect, object: nil)
            print("STOMP 연결 해제 및 모든 구독 종료")
        }
    }

    func sendMessage(content: String, messageType: String) {
        let destination = "/app/chat-room/\(chatRoomId)/sendMessage"
        
        let message: [String: Any] = [
            "content": content,
            "messageType": messageType
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: message, options: [.prettyPrinted]),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            
            let headers: [String: String] = [
                "Authorization": "Bearer \(accessToken)"
            ]
            
            print("전송할 메시지 (JSON): \(jsonString)")
            stompClient.sendMessage(message: jsonString, toDestination: destination, withHeaders: headers, withReceipt: nil)
            
        } else {
            print("메시지 JSON 변환 실패")
        }
    }
    func stompClientDidConnect(client: StompClientLib!) {
        print("STOMP 연결 성공: chatRoomId = \(chatRoomId)")
        isConnected = true
        NotificationCenter.default.post(name: .stompDidConnect, object: nil)
        subscribe()
    }
    
    func stompClientDidDisconnect(client: StompClientLib!) {
        print("STOMP 연결 종료")
        isConnected = false
        isSubscribed = false
        NotificationCenter.default.post(name: .stompDidDisconnect, object: nil)
    }

    func stompClient(client: StompClientLib!, didReceiveMessageWithJSONBody jsonBody: AnyObject?, akaStringBody stringBody: String?, withHeader header: [String : String]?, withDestination destination: String) {
        print("응답 수신")
        
        if let jsonBody = jsonBody as? [String: Any] {
            do {
                // JSON 객체를 Data로 변환 후 디코딩
                let jsonData = try JSONSerialization.data(withJSONObject: jsonBody, options: [])
                let message = try JSONDecoder().decode(Message.self, from: jsonData)
                
                print("받은 메시지: \(message)")
                messageList.append(message)
                didReceiveMessage?(message.content)
                
            } catch {
                print("JSON 디코딩 실패: \(error)")
            }
        } else if let message = stringBody {
            print("수신된 메시지 (문자열): \(message)")
            didReceiveMessage?(message)
        } else {
            print("수신 메시지 변환 실패 또는 빈 메시지")
        }
    }
    
    func serverDidSendReceipt(client: StompClientLib!, withReceiptId receiptId: String) {
        print("서버에서 메시지 수신 확인: \(receiptId)")
    }
    
    func serverDidSendError(client: StompClientLib!, withErrorMessage description: String, detailedErrorMessage message: String?) {
        print("STOMP 에러 발생: \(description), 세부 메시지: \(message ?? "")")
    }
    
    func serverDidSendPing() {
        print("서버에서 Ping 수신")
    }
}
