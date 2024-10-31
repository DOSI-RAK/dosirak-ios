//
//  ChatViewController.swift
//  Dosirak
//
//  Created by 권민재 on 10/18/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit


class ChatViewController: UIViewController {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    private let messages = BehaviorRelay<[ChatMessage]>(value: [])
    
    // MARK: - UI Elements
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension // 동적 높이 설정
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: ChatMessageCell.identifier)
        return tableView
    }()
    
    private let messageInputField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "메시지를 입력하세요."
        textField.borderStyle = .roundedRect
        textField.layer.cornerRadius = 12
        return textField
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "send"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "나의 채팅방"
        setupUI()
        setupBindings()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .bgColor
        
        // Add subviews
        view.addSubview(tableView)
        view.addSubview(messageInputField)
        view.addSubview(sendButton)
        
        // Layout using SnapKit
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(messageInputField.snp.top).offset(-10)
        }
        
        messageInputField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-10)
            make.height.equalTo(52)
        }
        
        sendButton.snp.makeConstraints { make in
            make.left.equalTo(messageInputField.snp.right).offset(10)
            make.centerY.equalTo(messageInputField)
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(44)
        }
    }
    
    // MARK: - Rx Bindings
    private func setupBindings() {

        sendButton.rx.tap
            .withLatestFrom(messageInputField.rx.text.orEmpty)
            .filter { !$0.isEmpty }
            .subscribe(onNext: { [weak self] message in
                self?.addMessage(message, isSentByCurrentUser: true) // true로 설정하여 내 메시지 표시
            })
            .disposed(by: disposeBag)
        
        messages
            .bind(to: tableView.rx.items(cellIdentifier: ChatMessageCell.identifier, cellType: ChatMessageCell.self)) { index, message, cell in
                cell.configure(with: message)
            }
            .disposed(by: disposeBag)
        
        sendButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.messageInputField.text = ""
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Helper Methods
    private func addMessage(_ message: String, isSentByCurrentUser: Bool) {
        let nickname = isSentByCurrentUser ? "나" : "상대방" // 가상 닉네임 설정
        let profileImage = isSentByCurrentUser ? "profile" : "profile" // 가상 이미지 설정
        let currentTime = getCurrentTime()
        
        let newMessage = ChatMessage(text: message, isSentByCurrentUser: isSentByCurrentUser, nickname: nickname, profileImageName: profileImage, time: currentTime)
        
        var currentMessages = messages.value
        currentMessages.append(newMessage)
        messages.accept(currentMessages)
        
        // Scroll to the bottom after adding a new message
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: currentMessages.count - 1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    private func getCurrentTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "a h:mm" 
        return dateFormatter.string(from: Date())
    }
}
