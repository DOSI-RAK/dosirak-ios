//
//  AppSettings.swift
//  Dosirak
//
//  Created by 권민재 on 11/18/24.
//
import Foundation

struct AppSettings {
    @UserDefault(key: "accessToken", defaultValue: nil)
    static var accessToken: String?
    
    @UserDefault(key: "refreshToken", defaultValue: nil)
    static var refreshToken: String?
    
    @UserDefault(key: "isLoggedIn", defaultValue: false)
    static var isLoggedIn: Bool
    
    @UserDefault(key: "isFirstLaunch", defaultValue: false)
    static var isFitstLaunch: Bool
    
    @UserDefault(key: "userGeo", defaultValue: "강남구 역삼동")
    static var userGeo: String
    
    @UserDefault(key: "userLocation", defaultValue: Location(latitude: 37.497942, longitude: 127.027621))
    static var userLocation: Location
    
    
}

struct UserInfo {
    @UserDefault(key: "socialAccessToken", defaultValue: nil)
    static var accessToken: String?
    @UserDefault(key: "socialRefreshToken", defaultValue: nil)
    static var refreshToken: String?
    
    @UserDefault(key: "socialType", defaultValue: nil)
    static var socialType: LoginType?
    
    @UserDefault(key: "nickName", defaultValue: "민재")
    static var nickName: String
    
    
}

struct Location {
    let latitude: Double
    let longitude: Double
}
