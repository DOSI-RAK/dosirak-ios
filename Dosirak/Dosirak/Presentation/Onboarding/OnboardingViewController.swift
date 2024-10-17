//
//  OnboardingViewController.swift
//  Dosirak
//
//  Created by 권민재 on 10/17/24.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    var coordinator: OnBoardingCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Onboarding"

        // Do any additional setup after loading the view.
    }
    
    func finishOnBoarding() {
        coordinator?.didFinishOnBoarding()
    }


}
