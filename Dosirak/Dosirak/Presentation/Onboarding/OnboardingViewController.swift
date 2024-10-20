//
//  OnboardingViewController.swift
//  Dosirak
//
//  Created by 권민재 on 10/17/24.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    var coordinator: OnboardingCoordinator?
    
    
    var onboardingCompletionHandler: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .mainColor
        title = "Onboarding"

        // Do any additional setup after loading the view.
        let completeButton = UIButton(type: .system)
        completeButton.setTitle("완료", for: .normal)
        completeButton.addTarget(self, action: #selector(completeOnboarding), for: .touchUpInside)
        
        view.addSubview(completeButton)
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            completeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            completeButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    @objc func completeOnboarding() {
        onboardingCompletionHandler?() // 온보딩이 완료되었음을 알림
    }
    
    func finishOnBoarding() {
        coordinator?.didFinishOnboarding()
    }


}
