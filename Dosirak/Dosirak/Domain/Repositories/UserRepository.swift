//
//  UserRepository.swift
//  Dosirak
//
//  Created by 권민재 on 10/20/24.
//


import RxSwift

protocol UserRepository {
    func regist(provider: String, accessToken: String) -> Observable<User>
}

