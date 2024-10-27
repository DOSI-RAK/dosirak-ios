//
//  PopupViewController.swift
//  Dosirak
//
//  Created by 권민재 on 10/27/24.
//

import UIKit
import SnapKit

class PopupViewController: UIViewController {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textAlignment = .center
        label.textColor = .red
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .center
        label.textColor = .gray
        label.numberOfLines = 0
        return label
    }()
    
    private let firstButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("취소", for: .normal)
        button.backgroundColor = .mainColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        return button
    }()
    
    private let secondButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("채팅방 나가기", for: .normal)
        button.backgroundColor = .bgColor
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 10
        return button
    }()
    
    // 초기화 메서드
    init(title: String, subtitle: String) {
        super.init(nibName: nil, bundle: nil)
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5) // 배경을 어둡게 설정
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(firstButton)
        containerView.addSubview(secondButton)
        
        // 컨테이너 뷰 레이아웃 설정
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview() // 중앙에 위치
            make.width.equalTo(300) // 가로 폭
            make.height.greaterThanOrEqualTo(200) // 높이
        }
        
        // titleLabel 레이아웃 설정
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        // subtitleLabel 레이아웃 설정
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        // 첫 번째 버튼 레이아웃 설정
        firstButton.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(50) // 버튼 높이
        }
        
        // 두 번째 버튼 레이아웃 설정
        secondButton.snp.makeConstraints { make in
            make.top.equalTo(firstButton.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(50) // 버튼 높이
            make.bottom.equalTo(containerView).offset(-20) // 컨테이너 뷰 아래쪽 여백
        }
        
        // 버튼 동작 설정
        firstButton.addTarget(self, action: #selector(firstButtonTapped), for: .touchUpInside)
        secondButton.addTarget(self, action: #selector(secondButtonTapped), for: .touchUpInside)
    }
    
    @objc private func firstButtonTapped() {
        // 버튼 1 클릭 시 동작
        print("버튼 1 클릭됨")
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func secondButtonTapped() {
        // 버튼 2 클릭 시 동작
        print("버튼 2 클릭됨")
        dismiss(animated: true, completion: nil)
    }
    
    // 모달 표시 메서드
    func presentPopup(from viewController: UIViewController) {
        viewController.present(self, animated: true, completion: nil)
    }
}

// 사용 예
// let popupVC = PopupViewController(title: "제목", subtitle: "부제목")
// popupVC.presentPopup(from: self) // 현재 뷰 컨트롤러에서 팝업 표시
