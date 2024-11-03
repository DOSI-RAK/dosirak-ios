//
//  CreateBottomViewController.swift
//  Dosirak
//
//  Created by 권민재 on 11/4/24.
//

import UIKit
import SnapKit

class CreateBottomViewController: UIViewController {
    
    // 아이콘 선택 콜백
    var didSelectIcon: ((UIImage?) -> Void)?
    
    private let iconImages: [UIImage?] = [
        UIImage(named: "teamprofile01"),
        UIImage(named: "teamprofile02"),
        UIImage(named: "teamprofile03"),
        UIImage(named: "photo") // 카메라 아이콘
    ]
    
    private let iconStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 20
        return stackView
    }()
    
    private let dimmedBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupLayout()
        setupGesture()
    }
    
    private func setupViews() {
        view.backgroundColor = .clear
        view.addSubview(dimmedBackgroundView)
        view.addSubview(contentView)
        
        for icon in iconImages {
            let iconButton = UIButton()
            iconButton.setImage(icon, for: .normal)
            iconButton.addTarget(self, action: #selector(iconTapped(_:)), for: .touchUpInside)
            iconStackView.addArrangedSubview(iconButton)
        }
        
        contentView.addSubview(iconStackView)
    }
    
    private func setupLayout() {
        dimmedBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(305)
        }
        
        iconStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissBottomSheet))
        dimmedBackgroundView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func iconTapped(_ sender: UIButton) {
        didSelectIcon?(sender.image(for: .normal))
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func dismissBottomSheet() {
        dismiss(animated: true, completion: nil)
    }
}
