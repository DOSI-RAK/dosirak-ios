//
//  AppCoordinator.swift
//  Dosirak
//
//  Created by 권민재 on 10/17/24.
//
import UIKit

protocol Coordinator {
    var childCoordinators: [Coordinator] { get set }
    func start()
}

protocol AppCoordinatorBindable {
    func moveOnboarding()
    func moveLogin()
    func moveHome(window: UIWindow)
}

class AppCoordinator: Coordinator, AppCoordinatorBindable {
    func start() {
        print("Hello")
    }
    
    
    var childCoordinators: [Coordinator] = []
    
    func start(window: UIWindow) {
        if isFirstLaunch() {
            moveHome(window: window)
        } else {
            // moveLogin()
        }
    }
    
    private func isFirstLaunch() -> Bool {
        let userDefaults = UserDefaults.standard
        let isOnboardingShown = userDefaults.bool(forKey: "isOnboardingShown")
        return !isOnboardingShown
    }
    
    private func setupOnboardingComplete() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: "isOnboardingShown")
        userDefaults.synchronize()
    }
    
    func moveOnboarding() {
        let onboardingCoordinator = OnboardingCoordinator()
        childCoordinators.append(onboardingCoordinator)
        onboardingCoordinator.start()
        
        onboardingCoordinator.onboardingDidFinish = { [weak self] in
            self?.setupOnboardingComplete()
            self?.childCoordinators.removeAll()
            self?.moveLogin()
        }
    }
    
    func moveLogin() {
        let loginCoordinator = LoginCoordinator()
        childCoordinators.append(loginCoordinator)
        loginCoordinator.start()
    }
    
    func moveHome(window: UIWindow) {
        let tabbarVC = TabbarViewController()
        
        
        // Home 탭에 대한 Coordinator
        let homeCoordinator = HomeCoordinator()
        childCoordinators.append(homeCoordinator)
        homeCoordinator.start() // homeCoordinator가 자신의 UINavigationController를 관리
        let homeNavController = homeCoordinator.nav
        homeNavController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)

        // Chat 탭에 대한 Coordinator
        let chatCoordinator = ChatCoordinator()
        childCoordinators.append(chatCoordinator)
        chatCoordinator.start() // chatCoordinator가 자신의 UINavigationController를 관리
        let chatNavController = chatCoordinator.nav
        chatNavController.tabBarItem = UITabBarItem(title: "Chat", image: UIImage(systemName: "message"), tag: 1)
        
        let profileCoordinator = UserProfileCoordinator()
        childCoordinators.append(profileCoordinator)
        profileCoordinator.start()
        
        let profileNavController = profileCoordinator.nav
        profileNavController.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 2)

        // TabBar에 네비게이션 컨트롤러 추가
        tabbarVC.viewControllers = [homeNavController,chatNavController,profileNavController]
        
        
        
        
        
        window.rootViewController = tabbarVC
        window.makeKeyAndVisible()
    }
}
