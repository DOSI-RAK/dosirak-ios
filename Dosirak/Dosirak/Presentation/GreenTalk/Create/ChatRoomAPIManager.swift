//
//  ChatRoomAPIManager.swift
//  Dosirak
//
//  Created by 권민재 on 11/30/24.
//

import Foundation
import Moya
import UIKit

enum ChatRoomAPI {
    case createChatRoom(title: String, explanation: String, zoneCategoryName: String, defaultImage: String?, file: Data?)
}

extension ChatRoomAPI: TargetType {
    var baseURL: URL {
        return URL(string: "http://dosirak.store/api")!
    }
    
    var path: String {
        switch self {
        case .createChatRoom:
            return "/chat-rooms"
        }
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var task: Task {
        switch self {
        case .createChatRoom(let title, let explanation, let zoneCategoryName, let defaultImage, let file):
            var formData: [MultipartFormData] = []
            
            // JSON 데이터 생성
            var chatRoomData: [String: Any] = [
                "title": title,
                "explanation": explanation,
                "zoneCategoryName": zoneCategoryName
            ]
            
            if let defaultImage = defaultImage, file == nil {
                chatRoomData["defaultImage"] = defaultImage
            }
            
            // JSON 데이터를 "chatRoom" 필드로 추가
            if let jsonData = try? JSONSerialization.data(withJSONObject: chatRoomData, options: []) {
                formData.append(MultipartFormData(provider: .data(jsonData), name: "chatRoom"))
            } else {
                print("JSON 데이터 생성 실패")
            }
            
            // 파일 추가 (옵션)
            if let file = file {
                formData.append(MultipartFormData(provider: .data(file), name: "file", fileName: "chat_image.jpg", mimeType: "image/jpeg"))
            }
            
            return .uploadMultipart(formData)
        }
    }
    
    var headers: [String: String]? {
        return [
            "Content-Type": "multipart/form-data",
            "Authorization": "Bearer \(AppSettings.accessToken ?? "")"
        ]
    }
    
    var sampleData: Data {
        return Data()
    }
}

// MARK: - API Manager
final class ChatRoomAPIManager {
    static let shared = ChatRoomAPIManager()
    private let provider = MoyaProvider<ChatRoomAPI>(plugins: [NetworkLoggerPlugin()])
    private init() {}
    
    func createChatRoom(
        title: String,
        explanation: String,
        zoneCategoryName: String,
        defaultImage: String? = nil,
        file: UIImage? = nil,
        completion: @escaping (Result<ChatRoomResponse, Error>) -> Void
    ) {
        let compressedImageData = file?.jpegData(compressionQuality: 0.7)
        
        provider.request(.createChatRoom(title: title, explanation: explanation, zoneCategoryName: zoneCategoryName, defaultImage: defaultImage, file: compressedImageData)) { result in
            switch result {
            case .success(let response):
                do {
                    let responseData = try JSONDecoder().decode(ChatRoomResponse.self, from: response.data)
                    completion(.success(responseData))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Response Models
struct ChatRoomResponse: Decodable {
    let status: String
    let message: String
    let data: ChatRoomData?
}

struct ChatRoomData: Decodable {
    let id: Int
    let title: String
    let personCount: Int
}

