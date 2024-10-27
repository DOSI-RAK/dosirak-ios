//
//  ChatCoordinator.swift
//  Dosirak
//
//  Created by 권민재 on 10/21/24.
//
import UIKit
class ChatListCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var nav: UINavigationController
    
    init() {
        self.nav = UINavigationController()
    }
    
    func start() {
        let chatVC = ChatListViewController()
        nav.pushViewController(chatVC, animated: false)
    }
}
 
