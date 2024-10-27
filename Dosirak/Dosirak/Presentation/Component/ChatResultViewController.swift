//
//  ChatResultViewController.swift
//  Dosirak
//
//  Created by 권민재 on 10/27/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ChatResultViewController: BaseViewController {
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    init(state: Bool) {
        super.init(nibName: nil, bundle: nil)
        if state {
            stateImageView.image = UIImage(named: "happy")
            stateTitleLabel.text = "채팅 생성!"
            statesubTitleLabel.text = "채팅방이 생성되었어요.\n 보람찬 다회용기 생활 만들어가요."
        } else {
            stateImageView.image = UIImage(named: "disapoint")
            stateTitleLabel.text = "리워드 부족.."
            statesubTitleLabel.text = "리워드가 부족해요 ㅜ.ㅜ\n 다양한 환경 활동으로 리워드를 쌓아봐요."
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupView() {
        
    }
    
    override func setupLayout() {
    
    }
    
    override func bindRX() {
        homeButton.rx.tap
            .subscribe({ _ in
                self.present(TabbarViewController(), animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    
    
    lazy var homeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "homemint"), for: .normal)
        return button
    }()
    
    lazy var stateImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    lazy var stateTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "채팅 생성!"
        label.textColor = .black
        return label
    }()
    
    lazy var statesubTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "채팅방이 생성되었어요\n 보람찬 다회용기 생활 만들어가요."
        label.textColor = .black
        return label
    }()
    
    lazy var completeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .mainColor
        button.setTitle("내 채팅", for: .normal)
        return button
    }()
    
    
    
    

    
}
