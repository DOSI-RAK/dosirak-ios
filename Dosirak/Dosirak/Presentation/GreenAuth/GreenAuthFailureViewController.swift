//
//  GreenAuthFailureViewController.swift
//  Dosirak
//
//  Created by 권민재 on 11/25/24.
//


import UIKit
import SnapKit

class GreenAuthFailureViewController: UIViewController {
    
    var reason: String?

    private let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "failure"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "다회용기 사용이"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .systemGreen
        label.textAlignment = .center
        return label
    }()
    
    private let reasonLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("확인", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        setupConstraints()
        reasonLabel.text = reason
        confirmButton.addTarget(self, action: #selector(goToHome), for: .touchUpInside)
    }
    
    private func setupViews() {
        view.addSubview(imageView)
        view.addSubview(messageLabel)
        view.addSubview(reasonLabel)
        view.addSubview(confirmButton)
    }
    
    private func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(50)
            make.width.height.equalTo(100)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        reasonLabel.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
    }
    
    @objc private func goToHome() {
        guard let sceneDelegate = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive })?.delegate as? SceneDelegate else {
            print("SceneDelegate를 찾을 수 없습니다.")
            return
        }
        
        sceneDelegate.appCoordinator?.moveToHomeFromAnyVC()
    }

}
