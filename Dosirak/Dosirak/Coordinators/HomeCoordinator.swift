//
//  HomeCoordinator.swift
//  Dosirak
//
//  Created by 권민재 on 10/17/24.
//

import UIKit

class HomeCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var nav: UINavigationController

    init() {
        // UINavigationController를 즉시 초기화
        self.nav = UINavigationController()
    }
    
    func start() {
        // 홈 화면으로 이동
        let homeVC = HomeViewController()
        homeVC.coordinator = self
        nav.pushViewController(homeVC, animated: false)
    }
    
    func navigateToDetail(for indexPath: IndexPath) {
        print("이동")
        let vc: UIViewController
        
        switch indexPath.section {
        case 0:
            guard let reactor = DIContainer.shared.resolve(GreenGuideReactor.self) else {
                fatalError("GreenGuideReactor를 생성할 수 없습니다.")
            }
            vc = GreenGuideViewController(reactor: reactor)
        
        case 1:
            if indexPath.row == 0 {
                vc = GreenClubViewController()
                vc.title = "Green Club" // title 설정
            } else {
                guard let reactor = DIContainer.shared.resolve(ChatListReactor.self) else {
                    fatalError("ChatListReactor를 생성할 수 없습니다.")
                }
                vc = ChatListViewController(reactor: reactor)
                vc.hidesBottomBarWhenPushed = true
            }
        case 2:
            vc = {
                let viewController: UIViewController
                switch indexPath.row {
                case 0:
                    viewController = GreenEliteViewController()
                    viewController.title = "Green Elite Controller" // title 설정
                case 1:
                    viewController = GreenHeroesViewController()
                    viewController.title = "Green Heroes" // title 설정
                default:
                    viewController = GreenAuthViewController()
                    viewController.title = "Green Auth Controller" // title 설정
                }
                return viewController
            }()
        default:
            return
        }
        
        print("VC Title: \(vc.title ?? "No Title")") // title이 설정되었는지 확인
        vc.hidesBottomBarWhenPushed = true
        nav.pushViewController(vc, animated: true)
    }
}
