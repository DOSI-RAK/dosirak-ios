//
//  ChatCoordinator.swift
//  Dosirak
//
//  Created by 권민재 on 10/21/24.
//
import UIKit
class ChatCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var nav: UINavigationController
    
    init(nav: UINavigationController) {
        self.nav = nav
    }
    
    func start() {
        let chatVC = ChatViewController()
        nav.pushViewController(chatVC, animated: true)
    }
}
