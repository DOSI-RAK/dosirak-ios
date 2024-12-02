//
//  RewardConfirmViewController.swift
//  Dosirak
//
//  Created by 권민재 on 12/3/24.
//

import UIKit
import PanModal
import SnapKit

class RewardConfirmationViewController: UIViewController, PanModalPresentable {

    // MARK: - Properties
    private let rewardAmount: Int = 10
    private let imageName: String = "coin"

    // PanModal 설정
    var panScrollable: UIScrollView? {
        return nil
    }

    var shortFormHeight: PanModalHeight {
        return .contentHeight(300)
    }

    var longFormHeight: PanModalHeight {
        return .contentHeight(300)
    }

    var cornerRadius: CGFloat {
        return 20.0
    }

    var showDragIndicator: Bool {
        return false
    }

    // MARK: - UI Elements
    private let coinImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 2
        return label
    }()

    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("아니오", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .mainColor
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.1
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 5
        return button
    }()

    private let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("네", for: .normal)
        button.setTitleColor(.mainColor, for: .normal)
        button.backgroundColor = .white
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.mainColor.cgColor
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.1
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 5
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
    }

    private func setupView() {
        view.backgroundColor = .white
        view.addSubview(coinImageView)
        view.addSubview(titleLabel)
        view.addSubview(cancelButton)
        view.addSubview(confirmButton)

        coinImageView.image = UIImage(named: imageName)
        titleLabel.text = "\(rewardAmount) 리워드가 소진돼요!\n계속하시겠어요?"

        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
    }

    private func setupLayout() {
        coinImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(20)
            make.width.height.equalTo(80)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(coinImageView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        cancelButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.trailing.equalToSuperview().inset(20)
            make.height.equalTo(48)
        }

        confirmButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.top.equalTo(cancelButton.snp.bottom).offset(10)
            make.leading.equalTo(view).inset(20)
            make.height.equalTo(48)
        }
    }

    // MARK: - Actions
    @objc private func didTapCancel() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func didTapConfirm() {
        print("확인 버튼이 눌렸습니다.")
        // SuccessCreateViewController로 이동
        let successVC = SuccessCreateViewController()
        successVC.modalPresentationStyle = .fullScreen
        present(successVC, animated: true, completion: nil)
    }
}
