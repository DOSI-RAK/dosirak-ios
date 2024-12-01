//
//  PopupViewController.swift
//  Dosirak
//
//  Created by 권민재 on 10/27/24.
//

import UIKit
import SnapKit

class CustomPopupViewController: UIViewController {

    // MARK: - Properties
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let cancelButton = UIButton()
    private let confirmButton = UIButton()

    private var confirmAction: (() -> Void)?
    private var cancelAction: (() -> Void)?
    
    // MARK: - Initializer
    init(title: String, message: String, confirmButtonText: String, cancelButtonText: String, confirmAction: (() -> Void)?, cancelAction: (() -> Void)? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.titleLabel.text = title
        self.messageLabel.text = message
        self.confirmButton.setTitle(confirmButtonText, for: .normal)
        self.cancelButton.setTitle(cancelButtonText, for: .normal)
        self.confirmAction = confirmAction
        self.cancelAction = cancelAction
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    // MARK: - Setup UI
    private func setupView() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        // Popup container
        let popupContainer = UIView()
        popupContainer.backgroundColor = .white
        popupContainer.layer.cornerRadius = 16
        popupContainer.clipsToBounds = true
        view.addSubview(popupContainer)

        // Title label
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = .red
        titleLabel.textAlignment = .center
        popupContainer.addSubview(titleLabel)

        // Message label
        messageLabel.font = UIFont.systemFont(ofSize: 14)
        messageLabel.textColor = .darkGray
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        popupContainer.addSubview(messageLabel)

        // Buttons
        popupContainer.addSubview(cancelButton)
        popupContainer.addSubview(confirmButton)

        // Cancel button style
        cancelButton.backgroundColor = UIColor.mainColor
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        cancelButton.layer.cornerRadius = 10
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)

        // Confirm button style
        confirmButton.backgroundColor = UIColor.systemGray5
        confirmButton.setTitleColor(.darkGray, for: .normal)
        confirmButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        confirmButton.layer.cornerRadius = 10
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)

        // Layout
        popupContainer.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }

        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(cancelButton.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    // MARK: - Actions
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: cancelAction)
    }

    @objc private func confirmButtonTapped() {
        dismiss(animated: true, completion: confirmAction)
    }
}
