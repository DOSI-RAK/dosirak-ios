//
//  CreateChatRoomViewController.swift
//  Dosirak
//
//  Created by 권민재 on 10/29/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import PanModal

class CreateChatRoomViewController: BaseViewController {
    
    private let disposeBag = DisposeBag()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            title = "채팅방 만들기"
            setupView()
            setupLayout()
            bindRX()
        }
        
        override func setupView() {
            view.backgroundColor = .bgColor
            view.addSubview(baseView)
            baseView.addSubview(chatProfileImageView)
            baseView.addSubview(editProfileButton)
            
            view.addSubview(chatNameLabel)
            view.addSubview(chatNameTextField)
            
            view.addSubview(locationLabel)
            view.addSubview(myLocationLabel)
            
            view.addSubview(myInfoLabel)
            view.addSubview(myInfoTextView)
            
            view.addSubview(createChatRoomButton)
        }
        
        override func setupLayout() {
            baseView.snp.makeConstraints {
                $0.top.equalTo(view.safeAreaLayoutGuide).inset(50)
                $0.centerX.equalTo(view)
                $0.width.equalTo(156)
                $0.height.equalTo(96)
            }
            
            chatProfileImageView.snp.makeConstraints {
                $0.width.height.equalTo(95)
                $0.centerY.equalTo(baseView)
                $0.leading.equalTo(baseView)
            }
            
            editProfileButton.snp.makeConstraints {
                $0.bottom.trailing.equalTo(baseView)
                $0.width.equalTo(45)
                $0.height.equalTo(30)
            }
            
            chatNameLabel.snp.makeConstraints {
                $0.top.equalTo(baseView.snp.bottom).offset(40)
                $0.leading.trailing.equalTo(view).inset(30)
                $0.height.equalTo(18)
            }
            
            chatNameTextField.snp.makeConstraints {
                $0.top.equalTo(chatNameLabel.snp.bottom).offset(10)
                $0.leading.trailing.equalTo(chatNameLabel)
                $0.height.equalTo(52)
            }
            
            locationLabel.snp.makeConstraints {
                $0.top.equalTo(chatNameTextField.snp.bottom).offset(30)
                $0.leading.trailing.equalTo(chatNameLabel)
                $0.height.equalTo(18)
            }
            
            myLocationLabel.snp.makeConstraints {
                $0.top.equalTo(locationLabel.snp.bottom).offset(10)
                $0.leading.trailing.equalTo(locationLabel)
            }
            
            myInfoLabel.snp.makeConstraints {
                $0.top.equalTo(myLocationLabel.snp.bottom).offset(30)
                $0.leading.trailing.equalTo(chatNameLabel)
                $0.height.equalTo(18)
            }
            
            myInfoTextView.snp.makeConstraints {
                $0.top.equalTo(myInfoLabel.snp.bottom).offset(10)
                $0.leading.trailing.equalTo(myLocationLabel)
                $0.height.equalTo(76)
            }
            
            createChatRoomButton.snp.makeConstraints {
                $0.leading.trailing.equalTo(view).inset(30)
                $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(30)
                $0.height.equalTo(52)
            }
        }
        
        override func bindRX() {
            createChatRoomButton.rx.tap
                .bind { [weak self] in
                    self?.createChatRoom()
                }
                .disposed(by: disposeBag)
        }
        
        private func createChatRoom() {
            guard let title = chatNameTextField.text, !title.isEmpty,
                  let explanation = myInfoTextView.text, !explanation.isEmpty,
                  let zoneCategoryName = myLocationLabel.text else {
                showAlert(message: "모든 필드를 입력하세요.")
                return
            }

            let defaultImageURL = "https://dosirakbucket.s3.ap-northeast-2.amazonaws.com/profile01.png"

            ChatRoomAPIManager.shared.createChatRoom(
                title: title,
                explanation: explanation,
                zoneCategoryName: zoneCategoryName,
                defaultImage: defaultImageURL,
                file: nil
            ) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        if response.status == "SUCCESS" {
                            self.showAlert(message: "채팅방이 생성되었습니다.") {
                                self.dismiss(animated: true)
                            }
                        } else {
                            self.showAlert(message: response.message)
                        }
                    case .failure:
                        self.showAlert(message: "채팅방 생성에 실패했습니다.")
                    }
                }
            }
        }
        
        private func showAlert(message: String, completion: (() -> Void)? = nil) {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
                completion?()
            })
            present(alert, animated: true)
        }
    
    // MARK: UI Elements
    let baseView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    let chatProfileImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "profilemini02")
        view.contentMode = .scaleAspectFill // 비율 유지하며 꽉 채우기
        view.layer.cornerRadius = 47.5 // 너비/높이의 절반
        view.layer.borderWidth = 2.0 // 테두리 두께
        view.layer.borderColor = UIColor.lightGray.cgColor // 테두리 색상
        view.clipsToBounds = true // 둥글게 잘리도록 설정
        return view
    }()
    
    let editProfileButton: UIButton = {
        let button = UIButton()
        button.setTitle("변경", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 14
        return button
    }()
    
    let chatNameLabel: UILabel = {
        let label = UILabel()
        label.text = "채팅방 이름"
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    let chatNameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 12
        return textField
    }()
    
    let locationLabel: UILabel = {
        let label = UILabel()
        label.text = "지역"
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    let myLocationLabel: UILabel = {
        let label = UILabel()
        label.text = AppSettings.userGeo
        return label
    }()
    
    let myInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "소개"
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    let myInfoTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .white
        textView.layer.cornerRadius = 12
        textView.font = UIFont.systemFont(ofSize: 16)
        return textView
    }()
    
    let createChatRoomButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .mainColor
        button.setTitle("채팅방 생성하기", for: .normal)
        button.layer.cornerRadius = 14
        return button
    }()
}
