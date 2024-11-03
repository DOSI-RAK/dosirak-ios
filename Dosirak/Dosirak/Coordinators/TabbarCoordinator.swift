//
//  TabbarController.swift
//  Dosirak
//
//  Created by 권민재 on 11/1/24.
//

import UIKit

class TabBarCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var tabBarController: UITabBarController
    
    init(tabBarController: UITabBarController) {
        self.tabBarController = tabBarController
    }
    
    func start() {
        // Home 탭
        let homeCoordinator = HomeCoordinator()
        childCoordinators.append(homeCoordinator)
        homeCoordinator.start()
        let homeNavController = homeCoordinator.nav
        homeNavController.tabBarItem = UITabBarItem(title: "홈", image: UIImage(named: "home"), selectedImage: UIImage(named: "home_active"))
        
        // Community 탭
        let communityCoordinator = CommuityCoordinator()
        childCoordinators.append(communityCoordinator)
        let communityNavController = communityCoordinator.nav
        communityNavController.tabBarItem = UITabBarItem(title: "내 활동", image: UIImage(named: "activities"), selectedImage: UIImage(named: "activities_active"))
        
        // Profile 탭
        let profileCoordinator = UserProfileCoordinator()
        childCoordinators.append(profileCoordinator)
        profileCoordinator.start()
        let profileNavController = profileCoordinator.nav
        profileNavController.tabBarItem = UITabBarItem(title: "내정보", image: UIImage(named: "person"), selectedImage: UIImage(named: "person_active"))
        
        // TabBar에 각 Navigation Controller 설정
        tabBarController.viewControllers = [homeNavController, communityNavController, profileNavController]
    }
}
