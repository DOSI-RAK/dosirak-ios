//
//  UserProfileCoordinator.swift
//  Dosirak
//
//  Created by 권민재 on 10/22/24.
//

import UIKit

class UserProfileCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var nav: UINavigationController
    
    init() {
        self.nav = UINavigationController()
    }
    
    func start() {
        let profileVC = UserProfileViewController()
        profileVC.coordinator = self
        nav.pushViewController(profileVC, animated: false)
    }
    
    func moveToEditProfile() {
        let editProfileVC = EditProfileViewController()
        editProfileVC.hidesBottomBarWhenPushed = true // 탭 바 숨기기
        nav.pushViewController(editProfileVC, animated: true)
        
        // 현재 네비게이션 바 숨기기 (필요한 경우)
        //nav.setNavigationBarHidden(true, animated: false)
    }
    
}
