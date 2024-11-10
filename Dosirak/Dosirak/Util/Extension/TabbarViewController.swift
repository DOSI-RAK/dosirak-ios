//
//  TabbarViewController.swift
//  Dosirak
//
//  Created by 권민재 on 10/22/24.
import UIKit

class TabbarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // 탭바의 배경색을 흰색으로 설정
        tabBar.backgroundColor = .white
        
        // 선택된 아이템의 색상
        tabBar.tintColor = .black
        
        // 선택되지 않은 아이템의 색상
        tabBar.unselectedItemTintColor = .gray
        
        // 반투명 비활성화
        tabBar.isTranslucent = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}
