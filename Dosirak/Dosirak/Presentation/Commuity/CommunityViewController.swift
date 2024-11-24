//
//  CommunityViewController.swift
//  Dosirak
//
//  Created by 권민재 on 10/24/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class CommunityViewController: BaseViewController {
    
    var coordinator: CommuityCoordinator?
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "내 활동"
        setupView()
        setupLayout()
    }

    override func setupView() {
        view.backgroundColor = UIColor.systemGray6 // 전체 배경색 설정
        
        view.addSubview(carbonCardView)
        carbonCardView.addSubview(cardBackgroundImageView)
        carbonCardView.addSubview(carbonReductionLabel)
        carbonCardView.addSubview(currentValueLabel)
        carbonCardView.addSubview(currentValueUnitLabel)
        carbonCardView.addSubview(현재까지라벨)
        
        view.addSubview(activitySectionTitleLabel)
        view.addSubview(activityButton)
    }

    override func setupLayout() {
        // 탄소 배출량 카드
        carbonCardView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(40)
            $0.height.equalTo(280)
        }
        
        // 카드 배경 이미지
        cardBackgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        // 탄소 배출량 라벨
        carbonReductionLabel.snp.makeConstraints {
            $0.top.equalTo(carbonCardView).offset(20)
            $0.leading.equalTo(carbonCardView).offset(20)
        }
        
        현재까지라벨.snp.makeConstraints {
            $0.top.equalTo(carbonReductionLabel.snp.bottom).offset(60)
            $0.width.equalTo(66)
            $0.height.equalTo(30)
            $0.leading.equalTo(currentValueLabel)
        }
        
        
        // 현재 값 라벨
        currentValueLabel.snp.makeConstraints {
            $0.top.equalTo(현재까지라벨.snp.bottom)
            $0.leading.equalTo(carbonReductionLabel)
        }
        
        // 단위 라벨
        currentValueUnitLabel.snp.makeConstraints {
            $0.bottom.equalTo(currentValueLabel.snp.bottom)
            $0.leading.equalTo(currentValueLabel.snp.trailing).offset(5)
        }
        
        // "내 환경 활동 현황" 섹션 제목
        activitySectionTitleLabel.snp.makeConstraints {
            $0.top.equalTo(carbonCardView.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        
        // Green Commit 버튼
        activityButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(activitySectionTitleLabel.snp.bottom).offset(20)
            $0.height.equalTo(50)
        }
    }

    override func bindRX() {
        // Green Commit 버튼 액션
        activityButton.rx.tap
            .subscribe(onNext: { [weak self] in
                let vc = GreenCommitViewController()
                vc.hidesBottomBarWhenPushed = true
                self?.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
    }

    lazy var carbonCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear // 배경 이미지를 위해 투명 처리
        view.layer.cornerRadius = 28
        view.clipsToBounds = true
        return view
    }()
    
    // 카드 배경 이미지
    lazy var cardBackgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "내활동_bg") // 카드 배경 이미지
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var carbonReductionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .left

        let fullText = "지구를 위해 절약한\n탄소배출량"
        let attributedString = NSMutableAttributedString(string: fullText)

        // NSMutableParagraphStyle 생성
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6 // 줄 간격 설정 (6pt)
        paragraphStyle.alignment = .left // 왼쪽 정렬

        if let range = fullText.range(of: "지구를 위해 절약한") {
            let nsRange = NSRange(range, in: fullText)
            attributedString.addAttributes([
                .font: UIFont.systemFont(ofSize: 18, weight: .medium),
                .foregroundColor: UIColor.darkGray
            ], range: nsRange)
        }

        // "탄소배출량" 스타일 설정
        if let range = fullText.range(of: "탄소배출량") {
            let nsRange = NSRange(range, in: fullText)
            attributedString.addAttributes([
                .font: UIFont.systemFont(ofSize: 30, weight: .heavy),
                .foregroundColor: UIColor.white
            ], range: nsRange)
        }

        // 전체 텍스트에 paragraphStyle 적용
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: fullText.count))

        label.attributedText = attributedString
        return label
    }()
    lazy var 현재까지라벨: UILabel = {
        let label = UILabel()
        label.text = "현재까지"
        label.backgroundColor = UIColor(hexCode: "#ededed")
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textAlignment = .center
        label.layer.cornerRadius = 13
        return label
    }()
    
    // 현재 값 라벨 (숫자)
    lazy var currentValueLabel: UILabel = {
        let label = UILabel()
        label.text = "9.9" // 예시 값
        label.font = UIFont.boldSystemFont(ofSize: 50)
        label.textColor = .white
        return label
    }()
    
    // 단위 라벨 (kg)
    lazy var currentValueUnitLabel: UILabel = {
        let label = UILabel()
        label.text = "kg"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    // "내 환경 활동 현황" 제목
    lazy var activitySectionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "내 환경 활동 현황"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .darkGray
        return label
    }()
    
    // Green Commit 바로가기 버튼
    lazy var activityButton: UIButton = {
        let button = UIButton()
        button.setTitle("Green Commit 바로가기", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.setImage(UIImage(named: "달력"), for: .normal)
        button.tintColor = .black
        button.contentHorizontalAlignment = .left
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return button
    }()
}
