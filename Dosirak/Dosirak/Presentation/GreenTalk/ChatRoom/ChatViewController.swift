//
//  ChatViewController.swift
//  Dosirak
//
//  Created by 권민재 on 10/18/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ChatViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    var reactor: ChatReactor?
    
    private let messageInputField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "메시지를 입력하세요."
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "send"), for: .normal)
        return button
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: ChatMessageCell.identifier)
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    init(chatRoomId: Int) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = DIContainer.shared.resolve(ChatReactor.self, argument: chatRoomId)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindReactor()
    }
    
    private func setupUI() {
        view.backgroundColor = .bgColor
        
        view.addSubview(tableView)
        view.addSubview(messageInputField)
        view.addSubview(sendButton)
        
        // 테이블 뷰 레이아웃
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(messageInputField.snp.top).offset(-10)
        }
        
        // 메시지 입력 필드 레이아웃
        messageInputField.snp.makeConstraints { make in
            make.left.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-10)
            make.height.equalTo(44)
        }
        
        // 전송 버튼 레이아웃
        sendButton.snp.makeConstraints { make in
            make.centerY.equalTo(messageInputField)
            make.left.equalTo(messageInputField.snp.right).offset(8)
            make.right.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.width.equalTo(60)
        }
    }
    
    private func bindReactor() {
        guard let reactor = reactor else { return }
        
        // 메시지 전송 액션
        sendButton.rx.tap
            .withLatestFrom(messageInputField.rx.text.orEmpty)
            .filter { !$0.isEmpty }
            .map { ChatReactor.Action.sendMessage($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 채팅방 정보 로드
        reactor.action.onNext(.loadChatRoomInfo)
        
        // 메시지 리스트 바인딩
        reactor.state
            .map { $0.chatRoomInfo?.messageList ?? [] }
            .bind(to: tableView.rx.items(cellIdentifier: ChatMessageCell.identifier, cellType: ChatMessageCell.self)) { index, message, cell in
                cell.configure(with: message)
            }
            .disposed(by: disposeBag)
        
        // 채팅방 정보 상태 바인딩
        reactor.state
            .map { $0.chatRoomInfo }
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] info in
                DispatchQueue.main.async {
                    self?.title = info.explanation
                }
            })
            .disposed(by: disposeBag)
        
        // 메시지 입력 필드 초기화
        sendButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.messageInputField.text = ""
            })
            .disposed(by: disposeBag)
    }
}
