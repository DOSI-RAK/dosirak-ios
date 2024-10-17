//
//  AppCoordinator.swift
//  Dosirak
//
//  Created by 권민재 on 10/17/24.
//
import UIKit


protocol Coordinator {
    var childCoordinators: [Coordinator] { get set }
    var nav: UINavigationController { get set }
    
    func start()
}

class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var nav: UINavigationController
    
    init(nav: UINavigationController) {
        self.nav = nav
    }
    
    
    func start() {
        if isFirstLaunch() {
            moveOnboarding()
        } else {
            moveLogin()
        }
    }
    
    private func isFirstLaunch() -> Bool {
        let userDefaults = UserDefaults.standard
        let isOnboardingShown = userDefaults.bool(forKey: "isOnboardingShown")
        return !isOnboardingShown
    }
    
    private func setupOnboardingComplete() {
        let userDeafults = UserDefaults.standard
        userDeafults.set(true, forKey: "isOnboardingShown")
        userDeafults.synchronize()
    }
    
    private func moveOnboarding() {
        let onboardingCoordinator = OnboardingCoordinator(nav: nav)
        childCoordinators.append(onboardingCoordinator)
        onboardingCoordinator.start()
        
        onboardingCoordinator.onboardingDidFinish = { [weak self] in
            self?.setupOnboardingComplete()
            self?.childCoordinators.removeAll()
            self?.moveLogin()
        }
        
    }
    
    private func moveLogin() {
        let loginCoordinator = LoginCoordinator(nav: nav)
        childCoordinators.append(loginCoordinator)
        loginCoordinator.start()
        
        
    }
        
}
