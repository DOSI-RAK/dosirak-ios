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
import RxKeyboard

class ChatViewController: UIViewController {
    var disposeBag = DisposeBag()
    var reactor: ChatReactor?
    
    private let noticeView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexCode: "e3f4ef")
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let noticeLabel: UILabel = {
        let label = UILabel()
        label.text = "공지사항 표시"
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        return label
    }()
    
    private let toggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    private let messageInputField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "메시지 입력"
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
        setupNavigationBar()
        bind(reactor: reactor!)
        
        reactor?.action.onNext(.connect)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        reactor?.action.onNext(.disconnect)
    }
    
    private func setupNavigationBar() {
        // 네비게이션 바 오른쪽에 버튼 추가
        let rightBarButton = UIBarButtonItem(
            image: UIImage(named: "exit"),
            style: .plain,
            target: nil,
            action: nil
        )
        
        navigationItem.rightBarButtonItem = rightBarButton
        //navigationController?.navigationBar.tintColor = .bgColor
        // Reactor를 이용한 버튼 클릭 액션 바인딩
//        rightBarButton.rx.tap
//            .map { ChatReactor.Action.didTapOptionsButton }
//            .bind(to: reactor!.action)
//            .disposed(by: disposeBag)
    }

    private func setupUI() {
        view.backgroundColor = .bgColor
        
        view.addSubview(noticeView)
        noticeView.addSubview(noticeLabel)
        noticeView.addSubview(toggleButton)
        
        view.addSubview(tableView)
        view.addSubview(messageInputField)
        view.addSubview(sendButton)
        
        setupLayout()
    }

    private func setupLayout() {
        noticeView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(40)
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
            .map { $0.messageList }
            .do(onNext: { [weak self] messages in
                guard let self = self, !messages.isEmpty else { return }
                
                // 테이블 뷰가 데이터가 로드될 때 가장 아래로 스크롤
                DispatchQueue.main.async {
                    self.scrollToBottom()
                }
            })
            .bind(to: tableView.rx.items(cellIdentifier: ChatMessageCell.identifier, cellType: ChatMessageCell.self)) { index, message, cell in
                cell.configure(with: message)
            }
            .disposed(by: disposeBag)
        
        sendButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.messageInputField.text = ""
            })
            .disposed(by: disposeBag)
        
        toggleButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.isNoticeExpanded.toggle()
                
                UIView.animate(withDuration: 0.3) {
                    self.noticeView.snp.updateConstraints { make in
                        make.height.equalTo(self.isNoticeExpanded ? 80 : 40)
                    }
                    self.toggleButton.setImage(UIImage(systemName: self.isNoticeExpanded ? "chevron.up" : "chevron.down"), for: .normal)
                    self.noticeLabel.numberOfLines = self.isNoticeExpanded ? 0 : 1
                    self.noticeLabel.lineBreakMode = self.isNoticeExpanded ? .byWordWrapping : .byTruncatingTail
                    self.view.layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)
        
        RxKeyboard.instance.visibleHeight
                    .drive(onNext: { [weak self] keyboardHeight in
                        guard let self = self else { return }
                        let isKeyboardVisible = keyboardHeight > 0
                        UIView.animate(withDuration: 0.3) {
                            self.messageInputField.snp.updateConstraints { make in
                                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-keyboardHeight - (isKeyboardVisible ? 10 : 0))
                            }
                            self.view.layoutIfNeeded()
                        }
                    })
                    .disposed(by: disposeBag)
        
        
        
    }
    
    private func scrollToBottom() {
        guard tableView.numberOfSections > 0 else { return }
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        guard lastRowIndex >= 0 else { return }
        
        let indexPath = IndexPath(row: lastRowIndex, section: lastSectionIndex)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
}
