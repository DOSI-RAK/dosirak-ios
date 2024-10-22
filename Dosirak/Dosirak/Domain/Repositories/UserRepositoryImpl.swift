//
//  UserRepositoryImpl.swift
//  Dosirak
//
//  Created by 권민재 on 10/20/24.
//
import RxSwift
import Moya
import Foundation

//class UserRepositoryImpl: UserRepository {
//    private let provider: MoyaProvider<UserAPI>
//
//    init(provider: MoyaProvider<UserAPI>) {
//        self.provider = provider
//    }
//
//    func regist(provider: String, accessToken: String) -> Observable<User> {
//        return provider.rx.request(.regist(provider: provider, accessToken: accessToken))
//            .map { response in
//                guard (200...299).contains(response.statusCode) else {
//                    throw UserError.networkError(NSError(domain: "", code: response.statusCode, userInfo: nil))
//                }
//                
//                let json = try JSONSerialization.jsonObject(with: response.data, options: []) as? [String: Any]
//                guard let id = json?["id"] as? Int,
//                      let nickname = json?["nickname"] as? String,
//                      let token = json?["token"] as? String else {
//                    throw UserError.parsingError
//                }
//                
//                return User(id: id, nickname: nickname, accessToken: token)
//            }
//            .asObservable()
//            .catchError { error in
//                return Observable.error(UserError.networkError(error))
//            }
//    }
//}
