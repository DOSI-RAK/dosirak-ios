//
//  ErrorViewController.swift
//  Dosirak
//
//  Created by 권민재 on 11/28/24.
//

import UIKit
import SnapKit

class ErrorViewController: UIViewController {
    
    let coordinator = AppCoordinator()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5) // 반투명 배경
        self.navigationController?.navigationBar.isHidden = true
        setupView()
        setupLayout()
    }

    // MARK: - UI Setup
    private func setupView() {
        view.addSubview(alertContainerView)
        alertContainerView.addSubview(titleLabel)
        alertContainerView.addSubview(messageLabel)
        alertContainerView.addSubview(homeButton)
        
        homeButton.addTarget(self, action: #selector(goHome), for: .touchUpInside)
    }

    private func setupLayout() {
        // 중앙 알림 창
        alertContainerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(300)
            make.height.equalTo(180)
        }

        // 제목 라벨
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(alertContainerView).offset(20)
            make.centerX.equalTo(alertContainerView)
        }

        // 메시지 라벨
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalTo(alertContainerView).inset(20)
        }

        // 홈 버튼
        homeButton.snp.makeConstraints { make in
            make.bottom.equalTo(alertContainerView).offset(-20)
            make.centerX.equalTo(alertContainerView)
            make.width.equalTo(200)
            make.height.equalTo(44)
        }
    }

    // MARK: - Actions
    @objc private func goHome() {
        coordinator.moveToHomeFromAnyVC()
    }

    // MARK: - UI Components
    private let alertContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "측정 오류"
        label.textColor = UIColor.red
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "앗! 신뢰할 수 없는 측정이 발견되어\n측정값이 기록되지 않았어요."
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private let homeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("홈으로", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.systemGray
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        return button
    }()
}
