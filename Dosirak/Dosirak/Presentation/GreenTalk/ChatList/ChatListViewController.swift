//
//  ChatListViewController.swift
//  Dosirak
//
//  Created by 권민재 on 10/26/24.
import UIKit
import RxSwift
import RxCocoa
import KeychainAccess

class ChatListViewController: BaseViewController {
    private let disposeBag = DisposeBag()
    private let selectedButton = BehaviorRelay<SortToggleButton?>(value: nil)
    
    var reactor: ChatListReactor?
    
    init(reactor: ChatListReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
        bind(reactor: reactor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 라이프 사이클
    override func viewDidLoad() {
        super.viewDidLoad()
        chatRoomListView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        title = "Green Talk"
        view.backgroundColor = .bgColor
        popularButton.isSelected = true
        recentButton.isSelected = false
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //navigationController?.setNavigationBarHidden(true, animated: false)
        reactor?.action.onNext(.loadChatRoomSummary)
        reactor?.action.onNext(.loadNearbyChatRooms("청담동"))
        
    }
    override func setupView() {
        view.addSubview(headerView)
        view.addSubview(collectionView)
        view.addSubview(baseView)
        baseView.addSubview(chatRoomListView)
        baseView.addSubview(myLocationLabel)
        baseView.addSubview(locationLabel)
        baseView.addSubview(chatroomSearchBar)
        baseView.addSubview(buttonStackView)
        baseView.addSubview(reloadButton)
        buttonStackView.addArrangedSubview(popularButton)
        buttonStackView.addArrangedSubview(recentButton)
        
        view.addSubview(floatingButton)
        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        
        
    }
    
    override func setupLayout() {
        
        headerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalTo(view)
            $0.height.equalTo(52)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.equalTo(view)
            $0.trailing.equalTo(view)
            $0.height.equalTo(60)
        }
        baseView.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(view)
            $0.bottom.equalTo(self.view)
        }
        locationLabel.snp.makeConstraints {
            $0.top.equalTo(baseView.snp.top).inset(20)
            $0.leading.equalTo(baseView).inset(20)
            $0.trailing.equalTo(baseView)
        }
        myLocationLabel.snp.makeConstraints {
            $0.leading.equalTo(locationLabel)
            $0.top.equalTo(locationLabel.snp.bottom).offset(10)
        }
        reloadButton.snp.makeConstraints {
            $0.leading.equalTo(myLocationLabel.snp.trailing)
            $0.width.height.equalTo(52)
            $0.centerY.equalTo(myLocationLabel)
            
        }
        
        
        chatroomSearchBar.snp.makeConstraints {
            $0.leading.equalTo(baseView)
            $0.trailing.equalTo(view)
            $0.height.equalTo(50)
            $0.top.equalTo(myLocationLabel.snp.bottom).offset(10)
        }
        buttonStackView.snp.makeConstraints {
            $0.leading.equalTo(myLocationLabel.snp.leading)
            $0.top.equalTo(self.chatroomSearchBar.snp.bottom).offset(10)
            $0.width.equalTo(120)
            $0.height.equalTo(30)
        }
        chatRoomListView.snp.makeConstraints {
            $0.top.equalTo(buttonStackView.snp.bottom).offset(10)
            $0.leading.trailing.bottom.equalTo(view)
        }
        
        floatingButton.snp.makeConstraints {
            $0.bottom.equalTo(view.snp.bottom).inset(40)
            $0.height.equalTo(55)
            $0.width.equalTo(350)
            $0.centerX.equalTo(view)
            
        }
    }
    
    
    func bind(reactor: ChatListReactor) {
       
        reactor.action.onNext(.loadChatRoomSummary)
        reactor.action.onNext(.loadNearbyChatRooms("청담동"))
        

        reactor.state.map { $0.chatRoomSummary }
            .do(onNext: { summary in
                print("Fetched Summary:", summary)
            })
            .bind(to: collectionView.rx.items(cellIdentifier: "cell", cellType: MyChatCell.self)) { index, chatRoomSummary, cell in
                if let messageText = chatRoomSummary.lastMessage {
                    cell.titleLabel.text = messageText
                } else {
                    cell.titleLabel.text  = "채팅이 없습니다."
                    cell.chatRoomId = chatRoomSummary.id
                }
                
                let url = URL(string: chatRoomSummary.image)
                cell.imageView.kf.setImage(with: url)
                
            }
            .disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(ChatRoomSummary.self)
            .subscribe(onNext: { [weak self] chatRoom in
                guard let self = self else { return }
                
                if let chatVC = DIContainer.shared.resolve(ChatViewController.self, argument: chatRoom.id) {
                    chatVC.title = chatRoom.title
                    self.navigationController?.pushViewController(chatVC, animated: true)
                } else {
                    print("Error: ChatViewController could not be resolved.")
                }
            })
            .disposed(by: disposeBag)
        
        
        
        
        reactor.state.map { $0.nearbyChatRooms }
            .bind(to: chatRoomListView.rx.items(cellIdentifier: "MyChatListCell", cellType: MyChatListTableViewCell.self)) { index, chatRoom, cell in
                let url = URL(string: chatRoom.image)
                cell.chatImageView.kf.setImage(with: url)
                cell.titleLabel.text = chatRoom.title
                cell.lastMessageLabel.text = chatRoom.explanation
            }
            .disposed(by: disposeBag)
        
        chatRoomListView.rx.modelSelected(ChatRoom.self)
            .subscribe(onNext: { [weak self] chatRoom in
                guard let self = self else { return }
                
                if let chatVC = DIContainer.shared.resolve(ChatViewController.self, argument: chatRoom.id) {
                    chatVC.title = chatRoom.title
                    self.navigationController?.pushViewController(chatVC, animated: true)
                } else {
                    print("Error: ChatViewController could not be resolved.")
                }
            })
            .disposed(by: disposeBag)
        
        // 나머지 바인딩 설정
        headerView.viewAllButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let reactor = DIContainer.shared.resolve(ChatListReactor.self) else { fatalError() }
                let myChatListVC = MyChatListViewController(reactor: reactor)
                myChatListVC.hidesBottomBarWhenPushed = true
                self?.navigationController?.pushViewController(myChatListVC, animated: true)
            })
            .disposed(by: disposeBag)
        
        floatingButton.rx.tap
            .subscribe(onNext: { [weak self] in
                let createVC = CreateChatRoomViewController()
                createVC.hidesBottomBarWhenPushed = true
                self?.navigationController?.pushViewController(createVC, animated: true)
            })
            .disposed(by: disposeBag)
    }

    
    
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 128, height: 40)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isUserInteractionEnabled = true 
        collectionView.register(MyChatCell.self, forCellWithReuseIdentifier: "cell")
        return collectionView
    }()
    
    private let headerView =  MyChatHeaderView()
    
    private let baseView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 40
        return view
    }()
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.text = "내 주변"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .gray
        return label
    }()
    private let myLocationLabel: UILabel = {
        let label = UILabel()
        label.text = "강남구 압구정동"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    private let reloadButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "reload"), for: .normal)
        return button
    }()
    
    
    private let chatroomSearchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.backgroundColor = .bgColor
        return sb
    }()
    
    var chatRoomListView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none // 원한다면 구분선 제거
        tableView.register(MyChatListTableViewCell.self, forCellReuseIdentifier: "MyChatListCell")
        return tableView
    }()
    
    private let floatingButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setTitle("채팅방 만들기", for: .normal)
        button.backgroundColor = .mainColor
        button.tintColor = .white
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        return button
    }()
    
    private let popularButton: SortToggleButton = {
        let button = SortToggleButton()
        button.setTitle("인기순", for: .normal)
        
        return button
    }()
    
    
    private let recentButton: SortToggleButton = {
        let button = SortToggleButton()
        button.setTitle("최신순", for: .normal)
        
        return button
    }()
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 5  // 버튼 간격 설정
        //stackView.alignment = .fill
        stackView.distribution = .fillEqually
        return stackView
    }()
}
    
    
    
    
extension ChatListViewController: UITableViewDelegate {
    // 고정된 셀 높이 설정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100 // 원하는 높이로 설정
    }
}
