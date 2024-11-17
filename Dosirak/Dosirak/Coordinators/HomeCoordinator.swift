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
        self.nav = UINavigationController()
        
    }
    
    func start() {
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
                fatalError()
            }
            vc = GreenGuideViewController(reactor: reactor)
        
        case 1:
            if indexPath.row == 0 {
                vc = GreenClubViewController()
                vc.title = "Green Club" // title 설정
            } else {
                guard let reactor = DIContainer.shared.resolve(ChatListReactor.self) else {
                    fatalError()
                }
                vc = ChatListViewController(reactor: reactor)
                vc.hidesBottomBarWhenPushed = true
            }
        case 2:
            vc = {
                let viewController: UIViewController
                switch indexPath.row {
                case 0:
                    viewController = UIViewController()
                    viewController.title = "Green Elite Controller" // title 설정
                case 1:
                    viewController = GreenHeroesViewController()
                    viewController.title = "Green Heros" // title 설정
                default:
                    viewController = UIViewController()
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
