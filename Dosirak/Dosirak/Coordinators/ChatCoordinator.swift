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
        let chatVC = PopupViewController(title: "잠시만요!", subtitle: "채팅방을 나간 이후에는 기록이 모두 삭제되며, 복구가 불가능합니다.")
        nav.pushViewController(chatVC, animated: false)
    }
}
 
