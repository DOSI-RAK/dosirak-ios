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
        nav.pushViewController(homeVC, animated: false)
    }
}
