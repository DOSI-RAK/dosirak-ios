//
//  UserRepositoryType.swift
//  Dosirak
//
//  Created by 권민재 on 10/29/24.
//
import RxSwift

protocol UserRepositoryType {
    func loginWithKakao() -> Observable<String?>
    func loginWithNaver() -> Observable<String?>
    func registerUser(accessToken: String, nickName: String?) -> Observable<Bool>
    func registerNickName(accessToken: String, nickName: String) -> Observable<Bool>
}
