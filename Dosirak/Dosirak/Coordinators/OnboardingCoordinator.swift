//
//  OnboardingCoordinator.swift
//  Dosirak
//
//  Created by 권민재 on 10/17/24.
//
import UIKit

class OnboardingCoordinator: Coordinator {
    
    var nav = UINavigationController()
    var childCoordinators: [Coordinator] = []
    
    var onboardingDidFinish: (() -> Void)?

    
    
    func start() {
        let onboardingVC = OnboardingViewController()
        
        nav.pushViewController(onboardingVC, animated: true)
    }
    
    func didFinishOnboarding() {
        onboardingDidFinish?()
    }
}
