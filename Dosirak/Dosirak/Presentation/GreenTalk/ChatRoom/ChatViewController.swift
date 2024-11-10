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
import ReactorKit

class ChatViewController: UIViewController {
    var disposeBag = DisposeBag()
    var reactor: ChatReactor?
    
    // 공지사항 뷰
    private let noticeView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexCode: "e3f4ef")
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let noticeLabel: UILabel = {
        let label = UILabel()
        label.text = "여기에 공지사항이 표시됩니다. 접을 수 있습니다."
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        return label
    }()
    
    private let toggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal) // 화살표 이미지 사용
        button.tintColor = .gray
        return button
    }()
    
    // 기존 UI 컴포넌트들
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
    
    private var isNoticeExpanded = false

    // 초기화 메서드
    init(reactor: ChatReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind(reactor: reactor!)
        
        reactor?.action.onNext(.connect)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        reactor?.action.onNext(.disconnect)
    }

    private func setupUI() {
        view.backgroundColor = .bgColor
        
        // 공지사항 뷰 구성
        view.addSubview(noticeView)
        noticeView.addSubview(noticeLabel)
        noticeView.addSubview(toggleButton)
        
        // 채팅 테이블과 입력 필드 구성
        view.addSubview(tableView)
        view.addSubview(messageInputField)
        view.addSubview(sendButton)
        
        setupLayout()
    }

    private func setupLayout() {
        // 공지사항 레이아웃 설정
        noticeView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(40) // 기본 접힌 높이
        }
        
        noticeLabel.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview().inset(10)
            make.right.equalTo(toggleButton.snp.left).offset(-8)
        }
        
        toggleButton.snp.makeConstraints { make in
            make.centerY.equalTo(noticeLabel)
            make.right.equalToSuperview().inset(10)
            make.width.height.equalTo(20)
        }
        
        // 테이블 및 입력 필드 레이아웃 설정
        tableView.snp.makeConstraints { make in
            make.top.equalTo(noticeView.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(messageInputField.snp.top).offset(-10)
        }

        messageInputField.snp.makeConstraints { make in
            make.left.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-10)
            make.height.equalTo(44)
        }

        sendButton.snp.makeConstraints { make in
            make.centerY.equalTo(messageInputField)
            make.left.equalTo(messageInputField.snp.right).offset(8)
            make.right.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.width.equalTo(60)
        }
    }
    
    func bind(reactor: ChatReactor) {
        // 메시지 전송
        sendButton.rx.tap
            .withLatestFrom(messageInputField.rx.text.orEmpty)
            .filter { !$0.isEmpty }
            .map { ChatReactor.Action.sendMessage($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.action.onNext(.loadChatRoomInfo)
        
        reactor.state
            .map { $0.chatRoomInfo?.explanation }
            .bind(to: noticeLabel.rx.text)
            .disposed(by: disposeBag)
        
        

        reactor.state
            .map { $0.chatRoomInfo?.messageList ?? [] }
            .bind(to: tableView.rx.items(cellIdentifier: ChatMessageCell.identifier, cellType: ChatMessageCell.self)) { index, message, cell in
                cell.configure(with: message)
            }
            .disposed(by: disposeBag)
        
        sendButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.messageInputField.text = ""
            })
            .disposed(by: disposeBag)
        
        // 공지사항 접기/펼치기 토글
        toggleButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.isNoticeExpanded.toggle()
                
                UIView.animate(withDuration: 0.3) {
                    self.noticeView.snp.updateConstraints { make in
                        make.height.equalTo(self.isNoticeExpanded ? 80 : 40)
                    }
                    self.toggleButton.setImage(UIImage(systemName: self.isNoticeExpanded ? "chevron.up" : "chevron.down"), for: .normal)
                    self.noticeLabel.numberOfLines = self.isNoticeExpanded ? 0 : 1 // 줄 수 설정
                    self.noticeLabel.lineBreakMode = self.isNoticeExpanded ? .byWordWrapping : .byTruncatingTail
                    self.view.layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)
    }
}
