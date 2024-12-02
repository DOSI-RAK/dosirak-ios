//
//  SuccessCreateViewController.swift
//  Dosirak
//
//  Created by 권민재 on 12/3/24.
//

import UIKit
import SnapKit

class SuccessCreateViewController: UIViewController {

    // MARK: - UI Elements

    private let homeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "home_green"), for: .normal)
        button.addTarget(self, action: #selector(didTapHome), for: .touchUpInside)
        button.tintColor = .mainColor
        return button
    }()

    private let happyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "happy")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "채팅 생성!"
        label.font = UIFont.boldSystemFont(ofSize: 36)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "채팅방이 생성되었어요.\n보람찬 다회용기 생활 만들어가요."
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let myChatButton: UIButton = {
        let button = UIButton()
        button.setTitle("내 채팅", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .mainColor
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(didTapMyChat), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
    }

    // MARK: - Setup

    private func setupView() {
        view.backgroundColor = .white
        view.addSubview(homeButton)
        view.addSubview(happyImageView)
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(myChatButton)
    }

    private func setupLayout() {
        homeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.trailing.equalToSuperview().inset(20)
            make.width.height.equalTo(30)
        }

        happyImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(homeButton.snp.bottom).offset(40)
            make.width.equalTo(300)
            make.height.equalTo(300)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(happyImageView.snp.bottom).offset(20)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        myChatButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(50)
        }
    }

    // MARK: - Actions

    @objc private func didTapHome() {
        // 홈 화면으로 이동
        print("홈 버튼 클릭됨")
        dismiss(animated: true, completion: nil)
    }

    @objc private func didTapMyChat() {
        // 내 채팅 화면으로 이동
        print("내 채팅 버튼 클릭됨")
        dismiss(animated: true, completion: nil)
    }
}
