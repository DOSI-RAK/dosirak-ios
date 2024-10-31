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
        guard let reactor = DIContainer.shared.resolve(UserProfileReactor.self) else { fatalError()}
        let editProfileVC = EditProfileViewController(reactor: reactor)
        editProfileVC.hidesBottomBarWhenPushed = true // 탭 바 숨기기
        nav.pushViewController(editProfileVC, animated: true)
        
    }
    func moveToLoginSheet() {
        let editVC = DIContainer.shared.resolve(EditProfileViewController.self)
        editVC?.modalPresentationStyle = .popover
        editVC?.hidesBottomBarWhenPushed = true
        editVC?.navigationController?.navigationBar.isHidden = true
        nav.pushViewController(editVC!, animated: true)
    }
    
}
