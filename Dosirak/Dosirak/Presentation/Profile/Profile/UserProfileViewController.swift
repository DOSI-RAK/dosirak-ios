//
//  UserProfileViewController.swift
//  Dosirak
//
//  Created by 권민재 on 10/18/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class UserProfileViewController: BaseViewController,UITableViewDelegate  {
    
    weak var coordinator: UserProfileCoordinator?
    
    
    let data: Observable<[(image: String, text: String)]> = Observable.just([
            ("contract", "서비스 이용약관"),
            ("personal", "개인정보 처리방침"),
            ("version", "버전 정보")
        ])
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
     

    }
    
    
    override func setupView() {
        view.addSubview(baseView)
        view.addSubview(profileView)
        profileView.addSubview(earthImageview)
        profileView.addSubview(editProfileButton)
        profileView.addSubview(profileImageView)
        profileView.addSubview(userNameLabel)
        profileView.addSubview(greenLabel)
        
        baseView.addSubview(infoView)
        
        infoView.addSubview(tableView)
    }
    
    override func setupLayout() {
        baseView.snp.makeConstraints {
            $0.leading.trailing.equalTo(view)
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        profileView.snp.makeConstraints {
            $0.top.equalTo(baseView.snp.top)
            $0.leading.equalTo(baseView).inset(20)
            $0.trailing.equalTo(baseView).inset(20)
            $0.height.equalTo(417)
        }
        
        earthImageview.snp.makeConstraints {
            $0.bottom.equalTo(profileView.snp.bottom)
            $0.leading.equalTo(profileView)
            $0.trailing.equalTo(profileView)
        }
        editProfileButton.snp.makeConstraints {
            $0.top.equalTo(profileView.snp.top).inset(10)
            $0.width.height.equalTo(52)
            $0.trailing.equalTo(profileView).inset(10)
            
        }
        
        profileImageView.snp.makeConstraints {
            $0.width.height.equalTo(94)
            $0.top.equalTo(profileView).inset(50)
            $0.centerX.equalTo(profileView)
        }
        userNameLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(15)
            $0.centerX.equalTo(profileImageView)
        }
        greenLabel.snp.makeConstraints {
            $0.height.equalTo(30)
            $0.width.equalTo(66)
            $0.centerX.equalTo(profileImageView)
            $0.bottom.equalTo(earthImageview.snp.top).offset(-15)
        }
        
        
        infoView.snp.makeConstraints {
            $0.leading.equalTo(profileView)
            $0.trailing.equalTo(profileView)
            $0.top.equalTo(profileView.snp.bottom).offset(20)
            $0.height.equalTo(190)
        }
        tableView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalTo(infoView)
        }
    }
    
    override func bindRX() {
        
        data.bind(to: tableView.rx.items(cellIdentifier: ProfileCell.reusableIdentifier, cellType: ProfileCell.self)) { row,item,cell in
            cell.imgView.image = UIImage(named: item.image)
            cell.label.text = item.text
            cell.selectionStyle = .none
        }
        .disposed(by: disposeBag)
        
        
        editProfileButton.rx.tap
            .bind { [weak self] in
                self?.coordinator?.moveToEditProfile()
            }
            .disposed(by: disposeBag)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // infoView의 높이를 기준으로 셀을 3등분
        return infoView.frame.height / 3
    }
    
    
    
    
    //MARK: UI
    lazy var baseView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        return view
    }()
    
    
    lazy var profileView: UIView = {
        let view = UIView()
        view.backgroundColor = .mainColor
        view.layer.cornerRadius = 30
        return view
    }()
    
    lazy var earthImageview: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "earth")
        return imageView
    }()
    
    lazy var editProfileButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "setting"), for: .normal)
        return button
    }()
    
    lazy var profileImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "profile")
        return imageView
    }()
    
    lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "니노막시무스카이저소제소제님"
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .white
        return label
    }()
    
    lazy var greenLabel: UILabel = {
        let label = UILabel()
        label.text = "그린지수"
        label.textColor = .white
        label.backgroundColor = .black
        label.layer.cornerRadius = 14
        label.font = UIFont.systemFont(ofSize: 12,weight: .semibold)
        label.textAlignment = .center
        label.clipsToBounds = true
        return label
    }()
    
    lazy var infoView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 30
        
        return view
    }()
    
    lazy var tableView: UITableView = {
        let view = UITableView()
        view.register(ProfileCell.self, forCellReuseIdentifier: ProfileCell.reusableIdentifier)
        view.separatorStyle = .none
        view.isScrollEnabled = false
        view.layer.cornerRadius = 30
        return view
    }()
}
