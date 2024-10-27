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
    func moveToLoginSheet() {
        let sheetVC = LoginBottomSheetViewController(title: "잠시만요!", subtitle: "탈퇴 시 계정 및이용 기록은 모두 사라지며,\n 삭제된 데이터는 복구가 불가능 합니다.")
        sheetVC.modalPresentationStyle = .popover
        sheetVC.hidesBottomBarWhenPushed = true
        sheetVC.navigationController?.navigationBar.isHidden = true
        nav.pushViewController(sheetVC, animated: true)
    }
    
}
