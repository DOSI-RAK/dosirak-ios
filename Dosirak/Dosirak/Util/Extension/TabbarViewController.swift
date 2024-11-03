//
//  TabbarViewController.swift
//  Dosirak
//
//  Created by 권민재 on 10/22/24.
//
import UIKit

class TabbarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // 탭바 배경 색을 흰색으로 설정
        tabBar.barTintColor = .white
        
        // 선택된 아이템의 색상을 설정 (선택 사항)
        tabBar.tintColor = .black // 선택된 아이템의 색상 예시

        // 선택되지 않은 아이템의 색상 설정 (선택 사항)
        tabBar.unselectedItemTintColor = .gray
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}
