//
//  TabbarViewController.swift
//  Dosirak
//
//  Created by 권민재 on 10/22/24.
import UIKit
import RxSwift

class TabbarViewController: UITabBarController,UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // 탭바의 배경색을 흰색으로 설정
        tabBar.backgroundColor = .white
        
        // 선택된 아이템의 색상
        tabBar.tintColor = .black
        
        // 선택되지 않은 아이템의 색상
        tabBar.unselectedItemTintColor = .gray
        
        // 반투명 비활성화
        tabBar.isTranslucent = false
        self.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
           guard let viewControllers = tabBarController.viewControllers else { return true }
           
           // 2번째, 3번째 탭 확인
           if let index = viewControllers.firstIndex(of: viewController), (index == 1 || index == 2) {
               if !isUserLoggedIn() {
                   showLoginAlert()
                   return false // 탭 이동 방지
               }
           }
           
           return true // 탭 이동 허용
       }

       private func isUserLoggedIn() -> Bool {
           // UserDefaults에서 accessToken 여부 확인
           return UserDefaults.standard.string(forKey: "accessToken") != nil
       }

       private func showLoginAlert() {
           let alert = UIAlertController(
               title: "로그인이 필요합니다",
               message: "이 기능을 사용하려면 로그인이 필요합니다.",
               preferredStyle: .alert
           )
           alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
           alert.addAction(UIAlertAction(title: "로그인", style: .default) { [weak self] _ in
               self?.navigateToLogin()
           })
           present(alert, animated: true)
       }

       private func navigateToLogin() {
           let loginVC = WhiteLoginViewController()
           loginVC.modalPresentationStyle = .fullScreen
           present(loginVC, animated: true)
       }
}
