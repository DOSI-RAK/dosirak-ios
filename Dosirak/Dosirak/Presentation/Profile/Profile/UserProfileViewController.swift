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
import KeychainAccess
import PanModal

class UserProfileViewController: BaseViewController {
    
    weak var coordinator: UserProfileCoordinator?
    private let viewModel = ProfileViewModel()
    let token = AppSettings.accessToken ?? ""
    
    let data: Observable<[(image: String, text: String)]> = Observable.just([
        ("contract", "서비스 이용약관"),
        ("personal", "개인정보 처리방침"),
        ("version", "버전 정보")
    ])
    
    private let disposeBag = DisposeBag()
    private var digitLabels: [UILabel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchUserProfile(accessToken: token)
            .subscribe(onSuccess: { userProfile in
                print(userProfile)
                self.userNameLabel.text = UserInfo.nickName
                self.updateScore(userProfile.reward)
            }, onFailure: { error in
            })
            .disposed(by: disposeBag)
    }
    
    override func setupView() {
        view.addSubview(baseView)
        view.addSubview(profileView)
        view.addSubview(scoreContainerView)
        setupStackView()
        
        profileView.addSubview(earthImageview)
        profileView.addSubview(editProfileButton)
        profileView.addSubview(profileImageView)
        profileView.addSubview(userNameLabel)
        profileView.addSubview(greenLabel)
        
        baseView.addSubview(infoView)
        infoView.addSubview(tableView)
        
        // 버튼 및 separator를 직접 추가
        view.addSubview(separatorLabel)
        view.addSubview(logoutButton)
        view.addSubview(withdrawButton)
    }
    
    private func setupStackView() {
        digitViewsStack.axis = .horizontal
        digitViewsStack.distribution = .fillEqually
        digitViewsStack.spacing = 5
        scoreContainerView.addSubview(digitViewsStack)
        
        for _ in 0..<3 {
            let digitView = UIView()
            let digitLabel = UILabel()
            digitLabel.font = .boldSystemFont(ofSize: 25)
            digitLabel.textAlignment = .center
            digitLabel.text = "0"
            digitView.addSubview(digitLabel)
            digitView.backgroundColor = .white
            digitView.layer.cornerRadius = 15
            digitLabel.snp.makeConstraints { $0.edges.equalToSuperview() }
            digitLabels.append(digitLabel)
            digitViewsStack.addArrangedSubview(digitView)
        }
        let expLabel = UILabel()
        expLabel.font = .boldSystemFont(ofSize: 18)
        expLabel.textColor = .black
        expLabel.text = "EXP"
        digitViewsStack.addArrangedSubview(expLabel)
    }
    
    override func setupLayout() {
        baseView.snp.makeConstraints {
            $0.leading.trailing.equalTo(view)
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        profileView.snp.makeConstraints {
            $0.top.equalTo(baseView.snp.top).inset(20)
            $0.leading.trailing.equalTo(baseView).inset(20)
            $0.height.equalTo(400)
        }
        
        earthImageview.snp.makeConstraints {
            $0.bottom.leading.trailing.equalTo(profileView)
        }
        
        editProfileButton.snp.makeConstraints {
            $0.top.trailing.equalTo(profileView).inset(10)
            $0.width.height.equalTo(52)
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
            $0.leading.trailing.equalTo(profileView)
            $0.top.equalTo(profileView.snp.bottom).offset(20)
            $0.height.equalTo(160)
        }
        
        tableView.snp.makeConstraints {
            $0.edges.equalTo(infoView)
        }
        
        scoreContainerView.snp.makeConstraints {
            $0.centerX.equalTo(view)
            $0.top.equalTo(earthImageview.snp.top).inset(10)
            $0.height.equalTo(74)
            $0.width.equalTo(200)
        }
        
        digitViewsStack.snp.makeConstraints {
            $0.edges.equalTo(scoreContainerView)
        }
        
        // 버튼 및 separator 레이아웃 설정
        separatorLabel.snp.makeConstraints {
            $0.centerX.equalTo(baseView)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        logoutButton.snp.makeConstraints {
            $0.leading.equalTo(separatorLabel.snp.trailing).offset(5)
            $0.centerY.equalTo(separatorLabel)
            $0.width.equalTo(80)
        }
                
        withdrawButton.snp.makeConstraints {
            $0.trailing.equalTo(separatorLabel.snp.leading).offset(-5)
            $0.centerY.equalTo(separatorLabel)
            $0.width.equalTo(80)
        }
    }
    override func bindRX() {
        data.bind(to: tableView.rx.items(cellIdentifier: ProfileCell.reusableIdentifier, cellType: ProfileCell.self)) { _, item, cell in
            cell.imgView.image = UIImage(named: item.image)
            cell.label.text = item.text
            cell.selectionStyle = .none
        }
        .disposed(by: disposeBag)
        
        viewModel.fetchUserProfile(accessToken: token)
            .subscribe(onSuccess: { userProfile in
                print(userProfile)
                self.userNameLabel.text = "\(UserInfo.nickName)님"
                self.updateScore(userProfile.reward)
                
                self.editProfileButton.rx.tap
                    .bind { [weak self] in
                        self?.coordinator?.moveToEditProfile(userInfo: userProfile)
                    }
                    .disposed(by: self.disposeBag)
                
            }, onFailure: { error in
            })
            .disposed(by: disposeBag)
        
       
        
        // 로그아웃 버튼 클릭 시
        logoutButton.rx.tap
            .bind { [weak self] in
                let vc = ConfirmAuthViewController(
                    title: "잠시만요!",
                    message: "로그아웃 시 app push 알림을\n받을 수 없습니다.",
                    primaryButtonTitle: "취소",
                    secondaryButtonTitle: "로그아웃",
                    primaryAction: {
                        // 취소 동작
                    },
                    secondaryAction: {
                        // 로그아웃 처리 동작
                        print("로그아웃 처리")
                    }
                )
                self?.presentPanModal(vc)
            }
            .disposed(by: disposeBag)

        // 탈퇴하기 버튼 클릭 시
        withdrawButton.rx.tap
            .bind { [weak self] in
                let vc = ConfirmAuthViewController(
                    title: "잠시만요!",
                    message: "탈퇴 시 계정 및 이용 기록은 모두 삭제되며,\n삭제된 데이터는 복구가 불가능합니다.",
                    primaryButtonTitle: "취소",
                    secondaryButtonTitle: "탈퇴하기",
                    primaryAction: {
                        // 취소 동작
                    },
                    secondaryAction: {
                        // 탈퇴 처리 동작
                        print("탈퇴 처리")
                    }
                )
                self?.presentPanModal(vc)
            }
            .disposed(by: disposeBag)
    }
    
    private func updateScore(_ score: Int) {
        let scoreString = String(format: "%03d", score) // 3자리 포맷으로 점수 변환
        updateDigitLabels(with: scoreString) // 자릿수별 애니메이션 적용
        
    }
    
    
    private func updateDigitLabels(with scoreString: String) {
        for (index, character) in scoreString.enumerated() {
            let newDigit = String(character)
            animateDigitChange(label: digitLabels[index], newDigit: newDigit)
        }
    }

       private func animateDigitChange(label: UILabel, newDigit: String) {
           // 애니메이션 효과를 추가
           UIView.transition(with: label, duration: 0.3, options: .transitionFlipFromTop, animations: {
               label.text = newDigit
           }, completion: nil)
       }


    
    private let scoreContainerView = UIView()
    private let digitViewsStack = UIStackView()
    
    
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
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "profile")
        return imageView
    }()
    
    lazy var userNameLabel: UILabel = {
        let label = UILabel()
        //label.text = "니노막시무스카이저소제소제님"
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
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
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
    private let buttonContainerView = UIView()
    private let separatorLabel: UILabel = {
        let label = UILabel()
        label.text = "|"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .lightGray
        label.backgroundColor = .clear
        return label
    }()
    
    
    lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.setTitle("로그아웃", for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.backgroundColor = .clear
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        return button
    }()

    // Withdraw Button
    lazy var withdrawButton: UIButton = {
        let button = UIButton()
        button.setTitle("탈퇴하기", for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.backgroundColor = .clear
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        return button
    }()
}


extension UserProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return infoView.frame.height / 3
    }
    
}
