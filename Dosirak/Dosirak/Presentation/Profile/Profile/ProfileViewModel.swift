//
//  ProfileViewModel.swift
//  Dosirak
//
//  Created by 권민재 on 11/3/24.
//

import RxSwift
import RxRelay
import Moya
import Foundation

class ProfileViewModel {
    private let provider = MoyaProvider<ProfileAPI>()
    
    let userProfile = BehaviorRelay<UserProfileData?>(value: nil)
    
   
    func fetchUserProfile(accessToken: String) -> Single<UserProfileData> {
        return provider.rx.request(.getUserInfo(accessToken: accessToken))
            .filterSuccessfulStatusCodes()
            .map(UserProfileResponse.self)
            .flatMap { response in
                print("fetched")
                if response.status == "SUCCESS" {
                    self.userProfile.accept(response.data)
                    return Single.just(response.data)
                } else {
                    return Single.error(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch user profile"]))
                }
            }
    }
    
    func updateNickname(accessToken: String, newNickname: String) -> Single<String> {
        return provider.rx.request(.editNickName(accessToken: accessToken, nickName: newNickname))
            .filterSuccessfulStatusCodes()
            .map(EditNickNameResponse.self)
            .flatMap { response in
                if response.status == "SUCCESS" {
                    return Single.just(response.message)
                } else {
                    return Single.error(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to update nickname"]))
                }
            }
    }
    
    func logout(accessToken: String) -> Single<Bool> {
        return provider.rx.request(.logout(accessToken: accessToken))
            .filterSuccessfulStatusCodes()
            .map(AuthResponse.self)
            .flatMap { response in
                if response.status == "SUCCESS" {
                    return Single.just(true)
                } else {
                    return Single.error(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to logout"]))
                }
            }
    }
    
    
    func withdraw(kakaoAccessToken: String) -> Single<Bool> {
        return provider.rx.request(.withdraw(kakaoAccessToken: kakaoAccessToken))
            .filterSuccessfulStatusCodes()
            .map(AuthResponse.self)
            .flatMap { response in
                if response.status == "SUCCESS" {
                    return Single.just(true)
                } else {
                    return Single.error(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to withdraw"]))
                }
            }
    }
}
