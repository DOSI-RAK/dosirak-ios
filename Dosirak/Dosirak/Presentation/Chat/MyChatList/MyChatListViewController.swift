//
//  MyChatListViewController.swift
//  Dosirak
//
//  Created by 권민재 on 10/27/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class MyChatListViewController: BaseViewController {

    private let disposeBag = DisposeBag()
    var reactor: ChatListReactor?

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 96)
        layout.minimumLineSpacing = 0
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.register(MyChatListCell2.self, forCellWithReuseIdentifier: "MyChatListCell")
        return view
    }()
    
    init(reactor: ChatListReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
        bind(reactor: reactor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "내 채팅"
        view.backgroundColor = .bgColor
        setupView()
    }

    override func setupView() {
        view.addSubview(collectionView)
    }

    override func setupLayout() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func bind(reactor: ChatListReactor) {
        reactor.action.onNext(.loadMyChatRooms)
        reactor.state.map { $0.myChatRooms }
            .bind(to: collectionView.rx.items(cellIdentifier: "MyChatListCell", cellType: MyChatListCell2.self)) { index, chatRoom, cell in
                print("==============>\(chatRoom)")
                cell.chatImageView.image = UIImage(named: "profile")
                cell.titleLabel.text = chatRoom.title
                cell.lastMessageLabel.text = chatRoom.explanation
                cell.dateLabel.text = chatRoom.lastMessageTime
            }
            .disposed(by: disposeBag)
    }
}
class MyChatListCell2: UICollectionViewCell {
    let chatImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 13 // Adjust for rounded image view
        return imageView
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        return label
    }()

    let lastMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 2
        label.textColor = .gray
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        label.textAlignment = .center // Align to the right
        return label
    }()

    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray // 라이트 그레이 색상
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(chatImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(lastMessageLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(separatorView) // 구분선 추가

        chatImageView.snp.makeConstraints { make in
            make.width.height.equalTo(58) // Set the image size
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(10)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.leading.equalTo(chatImageView.snp.trailing).offset(10)
            make.trailing.equalTo(dateLabel.snp.leading).offset(-10)
        }

        lastMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(chatImageView.snp.trailing).offset(10)
            make.trailing.equalTo(dateLabel.snp.leading).offset(-10)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.trailing.equalToSuperview().inset(10)
            make.width.equalTo(60) // Adjust as needed
        }
        
        separatorView.snp.makeConstraints { make in
            make.height.equalTo(0.8) // 구분선 높이
            make.leading.trailing.equalToSuperview().inset(20) // 양쪽 가장자리 맞춤
            make.bottom.equalToSuperview() // 셀 하단에 맞춤
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
