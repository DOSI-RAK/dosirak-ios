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
        nav.pushViewController(editProfileVC, animated: false)
    }
    
}
