//
//  CommunityCoordinator.swift
//  Dosirak
//
//  Created by 권민재 on 10/24/24.
//
import UIKit
class CommuityCoordinator: Coordinator {
    var childCoordinators: [any Coordinator] = []
    var nav: UINavigationController
    
    init() {
        self.nav = UINavigationController()
    }
    
    func start() {
        let communityVC = CommunityViewController()
        nav.pushViewController(communityVC, animated: false)
    }
    
    
    
    
}
