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

class UserProfileViewController: BaseViewController, UITableViewDelegate {
    
    weak var coordinator: UserProfileCoordinator?
    private let score = BehaviorRelay<Int>(value: 153)
    
    let data: Observable<[(image: String, text: String)]> = Observable.just([
        ("contract", "서비스 이용약관"),
        ("personal", "개인정보 처리방침"),
        ("version", "버전 정보")
    ])
    
    private let disposeBag = DisposeBag()
    
    // 자릿수 뷰 배열
    private var digitLabels: [UILabel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
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
        
        infoView.addSubview(buttonContainerView)
        buttonContainerView.addSubview(logoutButton)
        buttonContainerView.addSubview(separatorLabel)
        buttonContainerView.addSubview(withdrawButton)
        
        buttonContainerView.isUserInteractionEnabled = true
        logoutButton.isUserInteractionEnabled = true
        withdrawButton.isUserInteractionEnabled = true

    }
    
    // StackView 설정 메서드
    private func setupStackView() {
        digitViewsStack.axis = .horizontal
        digitViewsStack.distribution = .fillEqually
        digitViewsStack.spacing = 5
        digitViewsStack.isUserInteractionEnabled = true
        scoreContainerView.addSubview(digitViewsStack)
        
        // 각 자릿수 뷰 생성
        for _ in 0..<3 {
            let digitView = UIView()
            let digitLabel = UILabel()
            digitLabel.font = .boldSystemFont(ofSize: 25)
            digitLabel.textAlignment = .center
            digitLabel.text = "0" // 초기값 설정
            digitView.addSubview(digitLabel)
            digitView.backgroundColor = .white
            digitView.layer.cornerRadius = 15
            digitLabel.snp.makeConstraints { $0.edges.equalToSuperview() }
            digitLabels.append(digitLabel) // UILabel을 배열에 추가
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
            $0.top.equalTo(baseView.snp.top)
            $0.leading.trailing.equalTo(baseView).inset(20)
            $0.height.equalTo(417)
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
            $0.top.equalTo(profileView.snp.bottom).offset(5)
            $0.height.equalTo(190)
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
        
        buttonContainerView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(tableView.snp.bottom).offset(20)
            make.height.equalTo(44)
        }
        
        logoutButton.snp.makeConstraints { make in
            make.leading.equalTo(buttonContainerView).offset(20)
            make.top.bottom.equalToSuperview()
        }
        
        separatorLabel.snp.makeConstraints { make in
            make.leading.equalTo(logoutButton.snp.trailing).offset(10)
            make.centerY.equalTo(logoutButton)
        }
        
        withdrawButton.snp.makeConstraints { make in
            make.leading.equalTo(separatorLabel.snp.trailing).offset(10)
            make.trailing.equalTo(buttonContainerView).inset(20)
            make.top.bottom.equalToSuperview()
        }
    }
    
    override func bindRX() {
        data.bind(to: tableView.rx.items(cellIdentifier: ProfileCell.reusableIdentifier, cellType: ProfileCell.self)) { _, item, cell in
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
        
        // 점수 업데이트 및 애니메이션
        score
            .map { String(format: "%03d", $0) } // 3자리 문자열로 포맷
            .subscribe(onNext: { [weak self] scoreString in
                self?.updateDigitLabels(with: scoreString)
            })
            .disposed(by: disposeBag)
        
        logoutButton.rx.tap
            .subscribe(onNext: { [weak self] in
                
                print("로그아웃 버튼 클릭됨")
                self?.coordinator?.moveToLoginSheet()
                // 로그아웃 처리 코드 추가
            })
            .disposed(by: disposeBag)
        
        withdrawButton.rx.tap
            .subscribe(onNext: { [weak self] in
            
            print("로그아웃 버튼 클릭됨")
            self?.coordinator?.moveToLoginSheet()
            // 로그아웃 처리 코드 추가
        })
        .disposed(by: disposeBag)
    }
    
    
    private func updateDigitLabels(with scoreString: String) {
        let currentDigits = score.value // 현재 점수의 자리수
        _ = Int(scoreString) ?? 0 // 새로운 점수의 자리수

        let currentString = String(format: "%03d", currentDigits)
        let newString = scoreString

        // 각 자리수를 비교하여 애니메이션을 추가
        for index in 0..<newString.count {
            let currentIndex = currentString.index(currentString.startIndex, offsetBy: index)
            let newIndex = newString.index(newString.startIndex, offsetBy: index)

            let currentChar = currentString[currentIndex]
            let newChar = newString[newIndex]

            if currentChar != newChar {
                animateDigitChange(label: digitLabels[index], newDigit: String(newChar))
            } else {
                digitLabels[index].text = String(newChar)
            }
        }
    }

       private func animateDigitChange(label: UILabel, newDigit: String) {
           // 애니메이션 효과를 추가
           UIView.transition(with: label, duration: 0.3, options: .transitionFlipFromTop, animations: {
               label.text = newDigit
           }, completion: nil)
       }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return infoView.frame.height / 3
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
        return label
    }()
    
    
    lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.setTitle("로그아웃", for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.backgroundColor = .clear
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        return button
    }()

    // Withdraw Button
    lazy var withdrawButton: UIButton = {
        let button = UIButton()
        button.setTitle("탈퇴하기", for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.backgroundColor = .clear
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        return button
    }()
}
