//
//  GreenTalkViewController.swift
//  Dosirak
//
//  Created by 권민재 on 10/27/24.
//

import UIKit
import SnapKit

class GreenTalkViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var collectionView: UICollectionView!
    private let floatingButton: UIButton = {
        let button = UIButton()
        button.setTitle("채팅방 만들기", for: .normal)
        button.backgroundColor = .mainColor
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .bgColor
        title = "Green Talk"
        setupCollectionView()
        setupFloatingButton()
    }
    
    // 전체 UI 세팅
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(MyChatCell.self, forCellWithReuseIdentifier: "MyChatCell")
        collectionView.register(NearbySectionCell.self, forCellWithReuseIdentifier: "NearbySectionCell")
        collectionView.register(ChatRoomListCell.self, forCellWithReuseIdentifier: "ChatRoomListCell")
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    // 플로팅 버튼 설정
    func setupFloatingButton() {
        view.addSubview(floatingButton)
        floatingButton.snp.makeConstraints {
            $0.height.equalTo(52)
            $0.leading.equalTo(view).inset(20)
            $0.trailing.equalTo(view).offset(-20)
            $0.bottom.equalTo(view).inset(80)
        }
    }

    // 버튼 클릭 시 행동
    @objc private func floatingButtonTapped() {
        // 버튼 클릭 시 동작을 여기에 구현
        print("Floating button tapped!")
    }
    
    // 섹션 수
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3 // 1: 내 채팅방, 2: 내 주변, 3: 채팅방 리스트
    }
    
    // 각 섹션의 셀 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3 // 내 채팅방 아이템 수
        case 1:
            return 1 // 내 주변 섹션은 하나의 셀로 구성
        case 2:
            return 5 // 채팅방 리스트 아이템 수
        default:
            return 0
        }
    }
    
    // 각 셀의 내용 설정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyChatCell", for: indexPath) as! MyChatCell
            cell.configure(title: "마지막대화 \(indexPath.item)")
            return cell
        } else if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NearbySectionCell", for: indexPath) as! NearbySectionCell
            cell.configure(address: "동작구 상도동")
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChatRoomListCell", for: indexPath) as! ChatRoomListCell
            cell.configure(title: "채팅방이름 \(indexPath.item)", description: "채팅방소개...", memberCount: 32)
            return cell
        }
    }
    
    // 헤더 뷰 설정
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as! HeaderView
        
        if indexPath.section == 0 {
            headerView.configure(title: "내 채팅방", showSegment: false) // 세그먼트 없음
        } else if indexPath.section == 1 {
            headerView.configure(title: "내 주변", showSegment: false) // 세그먼트 없음
        } else {
            headerView.configure(title: "채팅방 리스트", showSegment: true) // 세그먼트 있음
        }
        
        return headerView
    }
    
    // 셀 크기 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: 80, height: 80)
        } else if indexPath.section == 1 {
            return CGSize(width: collectionView.frame.width - 32, height: 120)
        } else {
            return CGSize(width: collectionView.frame.width - 32, height: 80)
        }
    }
    
    // 헤더 크기 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 80) // 헤더 높이 조정
    }
    
    // 가로 스크롤 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
    }
}

// "내 채팅방" 셀 클래스
class MyChatCell: UICollectionViewCell {
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .mainColor
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        contentView.addSubview(titleLabel)
        titleLabel.textAlignment = .center
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configure(title: String) {
        titleLabel.text = title
    }
}

// "내 주변" 셀 클래스
class NearbySectionCell: UICollectionViewCell {
    private let addressLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        contentView.addSubview(addressLabel)
        addressLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configure(address: String) {
        addressLabel.text = address
    }
}

// "채팅방 리스트" 셀 클래스
class ChatRoomListCell: UICollectionViewCell {
    private let nameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let memberCountLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        let stackView = UIStackView(arrangedSubviews: [nameLabel, descriptionLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        contentView.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        nameLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        
        contentView.addSubview(memberCountLabel)
        memberCountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }
    
    func configure(title: String, description: String, memberCount: Int) {
        nameLabel.text = title
        descriptionLabel.text = description
        memberCountLabel.text = "\(memberCount)명"
    }
}

// 헤더 뷰 클래스
class HeaderView: UICollectionReusableView {
    private let titleLabel = UILabel()
    private let segmentControl = UISegmentedControl(items: ["인기순", "최신순"])
    private let searchBar = UISearchBar()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        addSubview(titleLabel)
        addSubview(segmentControl)
        addSubview(searchBar)
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
        }
        
        segmentControl.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(segmentControl.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
    func configure(title: String, showSegment: Bool) {
        titleLabel.text = title
        segmentControl.isHidden = !showSegment
        searchBar.isHidden = !showSegment
    }
}
