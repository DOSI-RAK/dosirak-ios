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
    func moveLogin(window: UIWindow)
    func moveHome(window: UIWindow)
}

class AppCoordinator: Coordinator, AppCoordinatorBindable {
   
    func start() {
        print("Hello")
    }
    
    
    var childCoordinators: [Coordinator] = []
    
    func start(window: UIWindow) {
        if isFirstLaunch() {
            //moveHome(window: window)
            moveLogin(window: window)
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
            //self?.moveLogin()
        }
    }
    
    func moveLogin(window: UIWindow) {
//        let loginCoordinator = LoginCoordinator()
//        childCoordinators.append(loginCoordinator)
//        loginCoordinator.start()
        let vc = LoginViewController(reactor: LoginReactor(loginManager: LoginManager.shared))
        window.rootViewController = vc
    }
    
    func moveHome(window: UIWindow) {
        let tabbarVC = TabbarViewController()
        
        
        // Home 탭에 대한 Coordinator
        let homeCoordinator = HomeCoordinator()
        childCoordinators.append(homeCoordinator)
        homeCoordinator.start()
        let homeNavController = homeCoordinator.nav
        homeNavController.tabBarItem = UITabBarItem(title: "홈", image: UIImage(named: "home"),selectedImage: UIImage(named: "home_active"))

        let communityCoordinator = CommuityCoordinator()
        childCoordinators.append(communityCoordinator)
        
        let communityNavController = communityCoordinator.nav
        communityNavController.tabBarItem = UITabBarItem(title: "커뮤니티", image: UIImage(named: "activities"),selectedImage: UIImage(named: "activities_active"))
        
        let profileCoordinator = UserProfileCoordinator()
        childCoordinators.append(profileCoordinator)
        profileCoordinator.start()
        
        let profileNavController = profileCoordinator.nav
        profileNavController.tabBarItem = UITabBarItem(title: "내정보", image: UIImage(named: "person"),selectedImage: UIImage(named: "person_active"))
        
        
        let chatListCoordinator = ChatListCoordinator()
        childCoordinators.append(chatListCoordinator)
        chatListCoordinator.start()
        let chatListNavController = chatListCoordinator.nav
        chatListNavController.tabBarItem = UITabBarItem(title: "채팅", image: UIImage(named: "chat"), selectedImage: UIImage(named: "chat_active"))

        // TabBar에 네비게이션 컨트롤러 추가
        tabbarVC.viewControllers = [homeNavController,communityNavController,profileNavController,chatListNavController]
        
        
        
        
        
        window.rootViewController = tabbarVC
        window.makeKeyAndVisible()
    }
}
