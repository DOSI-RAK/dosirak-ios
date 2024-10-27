//
//  ChatListViewController.swift
//  Dosirak
//
//  Created by 권민재 on 10/26/24.
//

import UIKit
import SnapKit

//struct ChatRoom: Hashable {
//    let id: UUID
//    let title: String
//    let lastMessage: String
//    let isPopular: Bool
//    let timestamp: Date
//
//    init(title: String, lastMessage: String, isPopular: Bool, timestamp: Date) {
//        self.id = UUID()
//        self.title = title
//        self.lastMessage = lastMessage
//        self.isPopular = isPopular
//        self.timestamp = timestamp
//    }
//}
//
//class ChatListViewController: BaseViewController {
//    
//    enum Section: Int, CaseIterable {
//        case chatList
//        case nearbyInfo
//        case searchAndRoomList
//    }
//    
//    private var collectionView: UICollectionView!
//    private var dataSource: UICollectionViewDiffableDataSource<Section, ChatRoom>!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        configureCollectionView()
//        configureDataSource()
//        applyInitialSnapshot()
//    }
//    
//    override func bindRX() {
//       
//    }
//
//    private func configureCollectionView() {
//        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment in
//            let section = Section(rawValue: sectionIndex)
//            switch section {
//            case .chatList:
//                return self.createChatListLayout()
//            case .nearbyInfo:
//                return self.createNearbyInfoLayout()
//            case .searchAndRoomList:
//                return self.createSearchAndRoomListLayout()
//            case nil:
//                return nil
//            }
//        }
//        
//        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collectionView.backgroundColor = .white
//        collectionView.register(MyChatHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "chatHeader")
//        collectionView.register(NearbyInfoHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "nearbyHeader")
//        collectionView.register(SearchRoomHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "searchHeader")
//        
//        
//        collectionView.register(MyChatListCell.self, forCellWithReuseIdentifier: MyChatListCell.reusableIdentifier)
//        collectionView.register(NearbyInfoCell.self, forCellWithReuseIdentifier: NearbyInfoCell.reusableIdentifier)
//        collectionView.register(ChatListCell.self, forCellWithReuseIdentifier: ChatListCell.reusableIdentifier)
//        
//        view.addSubview(collectionView)
//        collectionView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
//    }
//
//    private func createChatListLayout() -> NSCollectionLayoutSection {
//        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(100), heightDimension: .absolute(100))
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//
//        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//
//        let section = NSCollectionLayoutSection(group: group)
//        section.boundarySupplementaryItems = [createChatHeader()]
//        section.orthogonalScrollingBehavior = .continuous
//        
//        return section
//    }
//
//    private func createNearbyInfoLayout() -> NSCollectionLayoutSection {
//        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//
//        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
//        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
//
//        let section = NSCollectionLayoutSection(group: group)
//        section.boundarySupplementaryItems = [createNearbyInfoHeader()]
//        
//        return section
//    }
//
//    private func createSearchAndRoomListLayout() -> NSCollectionLayoutSection {
//        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//
//        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
//        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
//
//        let section = NSCollectionLayoutSection(group: group)
//        section.boundarySupplementaryItems = [createSearchAndRoomHeader()]
//        
//        return section
//    }
//
//    private func createChatHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
//        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
//        return NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
//    }
//
//    private func createNearbyInfoHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
//        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
//        return NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
//    }
//
//    private func createSearchAndRoomHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
//        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
//        return NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
//    }
//
//    private func configureDataSource() {
//        dataSource = UICollectionViewDiffableDataSource<Section, ChatRoom>(collectionView: collectionView) { (collectionView, indexPath, chatRoom) -> UICollectionViewCell? in
//                switch indexPath.section {
//                case 0: // Chat List Section
//                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyChatListCell.reusableIdentifier, for: indexPath) as! MyChatListCell
//                    // Configure the cell with chatRoom data
//                    cell.titleLabel.text = chatRoom.title // Assuming you have a UILabel in ChatRoomCell
//                    return cell
//                    
//                case 1: // Nearby Info Section
//                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NearbyInfoCell.reusableIdentifier, for: indexPath) as! NearbyInfoCell
//                    // Configure the cell if needed
//                    return cell
//                    
//                case 2: // Search and Room List Section
//                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChatListCell.reusableIdentifier, for: indexPath) as! ChatListCell
//                    // Configure the cell if needed
//                    return cell
//                    
//                default:
//                    return nil
//                }
//            }
//            
//        
//        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
//            if indexPath.section == 0 {
//                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "chatHeader", for: indexPath) as! MyChatHeader
//                header.backgroundColor = .bgColor
//                return header
//            } else if indexPath.section == 1 {
//                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "nearbyHeader", for: indexPath) as! NearbyInfoHeader
//                header.backgroundColor = .bgColor
//                return header
//            } else {
//                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "searchHeader", for: indexPath) as! SearchRoomHeader
//                header.backgroundColor = .bgColor
//                return header
//            }
//        }
//    }
//
//    private func applyInitialSnapshot() {
//        var snapshot = NSDiffableDataSourceSnapshot<Section, ChatRoom>()
//        
//        snapshot.appendSections(Section.allCases)
//        
//        // 내 채팅 데이터 추가
//        let myChatRooms = [
//            ChatRoom(title: "My Chat 1", lastMessage: "Hello there!", isPopular: true, timestamp: Date()),
//            ChatRoom(title: "My Chat 2", lastMessage: "What's up?", isPopular: false, timestamp: Date()),
//            ChatRoom(title: "My Chat 3", lastMessage: "Meeting at 5?", isPopular: true, timestamp: Date()),
//            ChatRoom(title: "My Chat 4", lastMessage: "See you soon!", isPopular: false, timestamp: Date()),
//            ChatRoom(title: "My Chat 5", lastMessage: "Let's catch up!", isPopular: true, timestamp: Date())
//        ]
//        snapshot.appendItems(myChatRooms, toSection: .chatList)
//        
//        // 내 주변 정보 데이터 추가
//        let nearbyInfoRoom = ChatRoom(title: "My Nearby Place", lastMessage: "123 Main St, My City", isPopular: false, timestamp: Date())
//        snapshot.appendItems([nearbyInfoRoom], toSection: .nearbyInfo)
//        
//        // 검색 및 채팅방 리스트 데이터 추가
//        let chatRooms = [
//            ChatRoom(title: "Room 1", lastMessage: "Last message 1", isPopular: true, timestamp: Date()),
//            ChatRoom(title: "Room 2", lastMessage: "Last message 2", isPopular: false, timestamp: Date()),
//            ChatRoom(title: "Room 3", lastMessage: "Last message 3", isPopular: true, timestamp: Date())
//        ]
//        snapshot.appendItems(chatRooms, toSection: .searchAndRoomList)
//        
//        dataSource.apply(snapshot, animatingDifferences: true)
//    }
//}

struct ChatRoom: Hashable {
    let id: UUID
    let title: String
    let lastMessage: String
    let isPopular: Bool
    let timestamp: Date

    init(title: String, lastMessage: String, isPopular: Bool, timestamp: Date) {
        self.id = UUID()
        self.title = title
        self.lastMessage = lastMessage
        self.isPopular = isPopular
        self.timestamp = timestamp
    }
}

class ChatListViewController: BaseViewController {

    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Int, ChatRoom>!
    private var bottomSheetView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureDataSource()
        applyInitialSnapshot()
        setupBottomSheet()
    }

    private func setupBottomSheet() {
        bottomSheetView = UIView()
        bottomSheetView.backgroundColor = .lightGray // 바텀 시트 배경색
        view.addSubview(bottomSheetView)

        // 바텀 시트 초기 설정
        bottomSheetView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(view.frame.height * 0.75) // 기본 높이 0.75
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        bottomSheetView.addGestureRecognizer(panGesture)
    }

    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let bottomSheet = gesture.view else { return }

        let translation = gesture.translation(in: view).y
        let newHeight = bottomSheet.frame.height - translation

        if newHeight >= view.frame.height * 0.75 && newHeight <= view.frame.height {
            bottomSheet.snp.updateConstraints { make in
                make.height.equalTo(newHeight)
            }
            gesture.setTranslation(.zero, in: view)
        }

        if gesture.state == .ended {
            let velocity = gesture.velocity(in: view).y
            let targetHeight: CGFloat
            
            if velocity > 0 {
                targetHeight = view.frame.height // 아래로 드래그 시 최대 높이로
            } else {
                targetHeight = view.frame.height * 0.75 // 위로 드래그 시 기본 높이로
            }

            // 애니메이션을 통해 높이 변경
            UIView.animate(withDuration: 0.3) {
                bottomSheet.snp.updateConstraints { make in
                    make.height.equalTo(targetHeight)
                }
                self.view.layoutIfNeeded()
            }
        }
    }

    private func configureCollectionView() {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment in
            return self.createChatListLayout()
        }

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.register(MyChatHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "chatHeader")
        collectionView.register(MyChatListCell.self, forCellWithReuseIdentifier: MyChatListCell.reusableIdentifier)

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func createChatListLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [createChatHeader()]
        
        return section
    }

    private func createChatHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
        return NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
    }

    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, ChatRoom>(collectionView: collectionView) { (collectionView, indexPath, chatRoom) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyChatListCell.reusableIdentifier, for: indexPath) as! MyChatListCell
            cell.titleLabel.text = chatRoom.title // Assuming you have a UILabel in MyChatListCell
            return cell
        }

        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "chatHeader", for: indexPath) as! MyChatHeader
            header.backgroundColor = .bgColor
            return header
        }
    }

    private func applyInitialSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, ChatRoom>()
        snapshot.appendSections([0]) // Single section for chat list

        // 내 채팅 데이터 추가
        let myChatRooms = [
            ChatRoom(title: "My Chat 1", lastMessage: "Hello there!", isPopular: true, timestamp: Date()),
            ChatRoom(title: "My Chat 2", lastMessage: "What's up?", isPopular: false, timestamp: Date()),
            ChatRoom(title: "My Chat 3", lastMessage: "Meeting at 5?", isPopular: true, timestamp: Date()),
            ChatRoom(title: "My Chat 4", lastMessage: "See you soon!", isPopular: false, timestamp: Date()),
            ChatRoom(title: "My Chat 5", lastMessage: "Let's catch up!", isPopular: true, timestamp: Date())
        ]
        snapshot.appendItems(myChatRooms, toSection: 0)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
