//
//  ChatListViewController.swift
//  Dosirak
//
//  Created by 권민재 on 10/26/24.
import UIKit
import RxSwift
import RxCocoa
struct ChatRoomData {
    let image: UIImage
    let title: String
    let lastMessage: String
    let date: String
}

class ChatListViewController: BaseViewController {
    private let disposeBag = DisposeBag()
    private let selectedButton = BehaviorRelay<SortToggleButton?>(value: nil)
    private let chatRoomList: [ChatRoomData] = [
        ChatRoomData(image: UIImage(named: "profile03_58px") ?? UIImage(), title: "Chat Room 1", lastMessage: "채팅방소개채팅방소개채팅방소개채팅방소개채팅방소개채팅방소개채팅방소개", date: "오전 10:00"),
        ChatRoomData(image: UIImage(named: "profile03_58px") ?? UIImage(), title: "Chat Room 2", lastMessage: "How are you?채팅방소개채팅방소개채팅방소개채팅방소개채팅방소개", date: "오전 10:05"),
        ChatRoomData(image: UIImage(named: "profile03_58px") ?? UIImage(), title: "Chat Room 3", lastMessage: "Let's meet up!채팅방소개채팅방소개채팅방소개", date: "오전 10:15"),
        ChatRoomData(image: UIImage(named: "profile03_58px") ?? UIImage(), title: "Chat Room 3", lastMessage: "Let's meet up!채팅방소개채팅방소개채팅방소개", date: "오전 10:15"),
        ChatRoomData(image: UIImage(named: "profile03_58px") ?? UIImage(), title: "Chat Room 3", lastMessage: "Let's meet up!채팅방소개채팅방소개채팅방소개", date: "오전 10:15"),ChatRoomData(image: UIImage(named: "profile03_58px") ?? UIImage(), title: "Chat Room 3", lastMessage: "Let's meet up!채팅방소개채팅방소개채팅방소개", date: "오전 10:15"),
        // Add more dummy data as needed
    ]
    // MARK: - 더미 데이터
    private let chatRooms = BehaviorRelay<[ChatRoom]>(value: [
        ChatRoom(id: 1, title: "마지막대화1", image: "profile1", personCount: 5, lastMessage: "안녕하세요!"),
        ChatRoom(id: 2, title: "마지막대화2", image: "profile2", personCount: 10, lastMessage: "여기 채팅방 소개입니다."),
        ChatRoom(id: 3, title: "마지막대화3", image: "profile3", personCount: 15, lastMessage: "어떤 도움이 필요하신가요?"),
    ])
    
    // MARK: - 라이프 사이클
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .bgColor
        popularButton.isSelected = true
        recentButton.isSelected = false
    }
    override func setupView() {
        view.addSubview(collectionView)
        view.addSubview(baseView)
        baseView.addSubview(chatRoomListView)
        baseView.addSubview(myLocationLabel)
        baseView.addSubview(locationLabel)
        baseView.addSubview(chatroomSearchBar)
        baseView.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(popularButton)
        buttonStackView.addArrangedSubview(recentButton)
        
        
        view.addSubview(floatingButton)
        
        
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    override func setupLayout() {
        collectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalTo(view)
            $0.trailing.equalTo(view)
            $0.height.equalTo(120)
        }
        baseView.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(view)
            $0.bottom.equalTo(self.view)
        }
        locationLabel.snp.makeConstraints {
            $0.top.equalTo(baseView.snp.top).inset(10)
            $0.leading.equalTo(baseView).inset(20)
            $0.trailing.equalTo(baseView)
        }
        myLocationLabel.snp.makeConstraints {
            $0.leading.equalTo(locationLabel)
            $0.top.equalTo(locationLabel.snp.bottom).offset(10)
        }
        chatroomSearchBar.snp.makeConstraints {
            $0.leading.equalTo(myLocationLabel.snp.leading)
            $0.trailing.equalTo(view)
            $0.height.equalTo(50)
            $0.top.equalTo(myLocationLabel.snp.bottom).offset(10)
        }
        buttonStackView.snp.makeConstraints {
            $0.leading.equalTo(chatroomSearchBar.snp.leading)
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
    
    override func bindRX() {
        
        Observable.just(chatRoomList)
            .bind(to: chatRoomListView.rx.items(cellIdentifier: "MyChatListCell", cellType: MyChatListCell2.self)) { index, chatRoom, cell in
                // Configure the cell
                cell.chatImageView.image = chatRoom.image
                cell.titleLabel.text = chatRoom.title
                cell.lastMessageLabel.text = chatRoom.lastMessage
                cell.lastMessageLabel.textColor = .gray
                // Set the date label, you can add it in your cell if needed
                cell.dateLabel.text = chatRoom.date
            }
            .disposed(by: disposeBag)
        chatRooms
            .bind(to: collectionView.rx.items(cellIdentifier: "cell")) { index, chatRoom, cell in
                cell.backgroundColor = .systemGreen // 컬렉션 뷰의 셀 디자인
                // 이미지나 추가 UI 설정 필요 시 여기서 추가 가능
            }
            .disposed(by: disposeBag)
        
        floatingButton.rx.tap
            .subscribe(onNext: { [weak self] in
                // 채팅방 만들기 버튼 클릭 시 이벤트 처리
                print("채팅방 만들기 버튼 클릭됨")
            })
            .disposed(by: disposeBag)
        
        popularButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.selectedButton.accept(self?.popularButton)
            })
            .disposed(by: disposeBag)
        
        // Recent button tapped
        recentButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.selectedButton.accept(self?.recentButton)
            })
            .disposed(by: disposeBag)
        
        
        selectedButton
            .asObservable()
            .subscribe(onNext: { [weak self] selected in
                guard let self = self else { return }
                self.popularButton.isSelected = (selected == self.popularButton)
                self.recentButton.isSelected = (selected == self.recentButton)
            })
            .disposed(by: disposeBag)
        
    }
    
    
    
    
    // MARK: - UI 요소들
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: 100, height: 100)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private let baseView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 34
        return view
    }()
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.text = "현재 위치"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .gray
        return label
    }()
    private let myLocationLabel: UILabel = {
        let label = UILabel()
        label.text = "dongjak"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    private let chatroomSearchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.backgroundColor = .bgColor
        return sb
    }()
    
    lazy var chatRoomListView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 96)
        layout.minimumLineSpacing = 0
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.register(MyChatListCell2.self, forCellWithReuseIdentifier: "MyChatListCell")
        return view
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
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let recentButton: SortToggleButton = {
        let button = SortToggleButton()
        button.setTitle("최신순", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
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
