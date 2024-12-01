//
//  AppConfig.swift
//  Dosirak
//
//  Created by 권민재 on 11/1/24.
//

struct AppConfig {
    @InfoPlist("KAKAO_APP_KEY")
    static var appkey: String?

    @InfoPlist("NAVER_CLIENT_ID")
    static var naverClientId: String?
    
    @InfoPlist("NAVER_CLIENT_SECRET")
    static var naverClientSecret: String?
    
    @InfoPlist("NAVER_MAP_CLIENTID")
    static var naverMapClientId: String?
    
    @InfoPlist("NAVER_MAP_SECRET")
    static var naverMapSecret: String?
    
    @InfoPlist("STORY_APP_ID")
    static var instaAppId: String?
    
}
