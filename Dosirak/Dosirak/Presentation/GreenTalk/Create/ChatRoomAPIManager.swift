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
        return URL(string: "http://dosirak.store/api")! // API 기본 URL
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
            
            // JSON 데이터 추가
            let chatRoomData = [
                "title": title,
                "explanation": explanation,
                "zoneCategoryName": zoneCategoryName,
                "defaultImage": defaultImage ?? ""
            ]
            
            if let jsonData = try? JSONSerialization.data(withJSONObject: chatRoomData) {
                print("🛠️ JSON Data: \(String(data: jsonData, encoding: .utf8) ?? "")")
                formData.append(MultipartFormData(provider: .data(jsonData), name: "chatRoom"))
            }
            
            // 파일 추가
            if let file = file {
                print("🛠️ Adding File - Size: \(file.count) bytes")
                formData.append(MultipartFormData(
                    provider: .data(file),
                    name: "file",
                    fileName: "profile_image.jpg",
                    mimeType: "image/jpeg"
                ))
            } else {
                print("🛠️ No File Added")
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


final class ChatRoomAPIManager {
    static let shared = ChatRoomAPIManager()
    private let provider = MoyaProvider<ChatRoomAPI>(plugins: [NetworkLoggerPlugin()])
    private init() {}
    
    func createChatRoom(
        title: String,
        explanation: String,
        zoneCategoryName: String,
        defaultImage: String? = nil,
        file: UIImage? = nil, // UIImage를 받도록 수정
        completion: @escaping (Result<ChatRoomResponse, Error>) -> Void
    ) {
        print("=== API Request Debugging ===")
        print("Title: \(title)")
        print("Explanation: \(explanation)")
        print("Zone Category Name: \(zoneCategoryName)")
        print("Default Image: \(defaultImage ?? "N/A")")
        print("File Provided: \(file != nil ? "Yes" : "No")")
        print("=============================")
        
        // 이미지를 압축하여 데이터로 변환
        let compressedImageData = file?.jpegData(compressionQuality: 0.7) // 압축률 설정
        
        provider.request(.createChatRoom(title: title, explanation: explanation, zoneCategoryName: zoneCategoryName, defaultImage: defaultImage, file: compressedImageData)) { result in
            switch result {
            case .success(let response):
                print("=== API Response Debugging ===")
                print("Status Code: \(response.statusCode)")
                if let responseString = String(data: response.data, encoding: .utf8) {
                    print("Response Data: \(responseString)")
                } else {
                    print("Response Data: Unable to decode")
                }
                print("==============================")
                
                do {
                    let responseData = try JSONDecoder().decode(ChatRoomResponse.self, from: response.data)
                    completion(.success(responseData))
                } catch {
                    print("Decoding Error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("=== API Request Failed ===")
                print("Error: \(error.localizedDescription)")
                print("===========================")
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Moya TargetType
// MARK: - NetworkLoggerPlugin
final class NetworkLoggerPlugin: PluginType {
    func willSend(_ request: RequestType, target: TargetType) {
        print("=== Network Request ===")
        print("URL: \(request.request?.url?.absoluteString ?? "N/A")")
        print("HTTP Method: \(request.request?.httpMethod ?? "N/A")")
        if let headers = request.request?.allHTTPHeaderFields {
            print("Headers: \(headers)")
        }
        if let httpBody = request.request?.httpBody, let bodyString = String(data: httpBody, encoding: .utf8) {
            print("Body: \(bodyString)")
        } else {
            print("Body: N/A")
        }
        print("=======================")
    }
    
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case .success(let response):
            print("=== Network Response ===")
            print("Status Code: \(response.statusCode)")
            if let responseString = String(data: response.data, encoding: .utf8) {
                print("Response Data: \(responseString)")
            } else {
                print("Response Data: Unable to decode")
            }
            print("=========================")
        case .failure(let error):
            print("=== Network Error ===")
            print("Error: \(error.localizedDescription)")
            print("=====================")
        }
    }
}

// MARK: - Response Model
struct ChatRoomResponse: Decodable {
    let status: String
    let message: String
    let data: ChatRoomData
}

struct ChatRoomData: Decodable {
    let id: Int
    let title: String
    let personCount: Int
}
