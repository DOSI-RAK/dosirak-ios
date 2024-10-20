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


class ChatViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // UI Components
    let collectionView: UICollectionView
    let messageTextField = UITextField()
    let sendButton = UIButton(type: .system)
    let photoButton = UIButton(type: .system)
    
    var messages: [String] = [] // Placeholder data for chat messages
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupCollectionView()
        setupInputComponents()
    }
    
    // CollectionView 설정
    func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Register cell
        collectionView.register(ChatCell.self, forCellWithReuseIdentifier: "ChatCell")
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(60) // 입력창 공간 확보
        }
    }
    
    // 메시지 입력 필드와 버튼들 설정
    func setupInputComponents() {
        let inputContainerView = UIView()
        view.addSubview(inputContainerView)
        
        inputContainerView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(60)
        }
        
        // 메시지 입력 필드 설정
        inputContainerView.addSubview(messageTextField)
        messageTextField.placeholder = "Type a message..."
        messageTextField.borderStyle = .roundedRect
        messageTextField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.top.bottom.equalToSuperview().inset(10)
        }
        
        // 사진 추가 버튼 설정
        inputContainerView.addSubview(photoButton)
        photoButton.setTitle("📷", for: .normal)
        photoButton.snp.makeConstraints { make in
            make.left.equalTo(messageTextField.snp.right).offset(10)
            make.centerY.equalTo(messageTextField)
            make.width.equalTo(40)
        }
        
        // 메시지 보내기 버튼 설정
        inputContainerView.addSubview(sendButton)
        sendButton.setTitle("Send", for: .normal)
        sendButton.snp.makeConstraints { make in
            make.left.equalTo(photoButton.snp.right).offset(10)
            make.right.equalToSuperview().inset(10)
            make.centerY.equalTo(messageTextField)
            make.width.equalTo(60)
        }
    }
    
    // CollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChatCell", for: indexPath) as! ChatCell
        cell.messageLabel.text = messages[indexPath.item]
        return cell
    }
    
    // CollectionView Cell Size 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
}

// ChatCell 클래스 정의 (메시지 표시용)
class ChatCell: UICollectionViewCell {
    
    let messageLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(messageLabel)
        messageLabel.numberOfLines = 0
        messageLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
