//
//  ChatListViewController.swift
//  Dosirak
//
//  Created by 권민재 on 10/26/24.
import UIKit
import RxSwift
import RxCocoa
import SnapKit

class ChatListViewController: UIViewController {
    // MARK: - UI Elements
    private let segmentedControl = UISegmentedControl(items: ["인기순", "최신순"])
    private let searchBar = UISearchBar()
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    private let tableView = UITableView()
    private let createChatButton = UIButton(type: .system)

    // RxSwift
    private let disposeBag = DisposeBag()

    // MARK: - ViewModel (Assuming you have a ViewModel structure)
    private let viewModel = ChatListViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }

    private func setupUI() {
        view.backgroundColor = .white
        navigationItem.title = "Green Talk"

        // Setup Segmented Control
        view.addSubview(segmentedControl)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        // Setup Search Bar
        view.addSubview(searchBar)
        searchBar.placeholder = "Search"
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        // Setup CollectionView
        view.addSubview(collectionView)
        collectionView.backgroundColor = .clear
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(80)
        }

        // Setup TableView
        view.addSubview(tableView)
        tableView.register(ChatRoomCell.self, forCellReuseIdentifier: ChatRoomCell.reusableIdentifier)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview()
        }

        // Setup Create Button
        view.addSubview(createChatButton)
        createChatButton.setTitle("채팅방 만들기", for: .normal)
        createChatButton.backgroundColor = .systemGreen
        createChatButton.setTitleColor(.white, for: .normal)
        createChatButton.layer.cornerRadius = 10
        createChatButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
            make.height.equalTo(50)
        }
    }

    private func setupBindings() {
        // Binding for segmented control
        segmentedControl.rx.selectedSegmentIndex
            .subscribe(onNext: { [weak self] index in
                self?.viewModel.sortOrder.accept(index == 0 ? .popularity : .recent)
            }).disposed(by: disposeBag)

        // Binding for search bar text
        searchBar.rx.text.orEmpty
            .bind(to: viewModel.searchQuery)
            .disposed(by: disposeBag)

        // Binding chat list to the tableView
        viewModel.filteredChatRooms
            .bind(to: tableView.rx.items(cellIdentifier: ChatRoomCell.reusableIdentifier, cellType: ChatRoomCell.self)) { row, chatRoom, cell in
                cell.configure(with: chatRoom)
            }
            .disposed(by: disposeBag)
        
        // Create Chat Button Action
        createChatButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showCreateChatRoomScreen()
            })
            .disposed(by: disposeBag)
    }

    private func showCreateChatRoomScreen() {
        // Handle navigation to create chat room screen
    }
}
enum SortOrder {
    case popularity
    case recent
}

class ChatListViewModel {
    let disposeBag = DisposeBag()
    
    // Inputs
    let searchQuery = BehaviorRelay<String>(value: "")
    let sortOrder = BehaviorRelay<SortOrder>(value: .popularity)

    // Outputs
    let filteredChatRooms: Observable<[ChatRoom]>

    init() {
        let allChatRooms = Observable.just([
            ChatRoom(name: "Chat Room 1", members: 32),
            ChatRoom(name: "Chat Room 2", members: 15),
            // Add more mock data
        ])
        
        filteredChatRooms = Observable.combineLatest(searchQuery, sortOrder, allChatRooms) { query, sortOrder, rooms in
            var filtered = rooms.filter { $0.name.contains(query) }
            switch sortOrder {
            case .popularity:
                filtered.sort { $0.members > $1.members }
            case .recent:
                // Sort by recent (if you have a timestamp, use it)
                break
            }
            return filtered
        }
    }
}
