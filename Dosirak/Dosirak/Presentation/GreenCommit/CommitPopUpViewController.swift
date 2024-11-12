//
//  CommitPopUpViewController.swift
//  Dosirak
//
//  Created by 권민재 on 11/11/24.
//
import UIKit
import SnapKit
import PanModal

class CommitPopUpViewController: UIViewController, PanModalPresentable {
    
    // 중앙 콘텐츠 뷰 (320x320)
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    // 상단 제목
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "나의 기록"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    // 설명 텍스트
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "친환경 활동 횟수에 따라\n다음과 같이 기록돼요!"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = .darkGray
        return label
    }()
    
    // 활동 이미지와 텍스트 뷰를 담을 스택 뷰
    private let activityStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.distribution = .equalSpacing // 간격 균등 설정
        return stackView
    }()
    
    // 확인 버튼
    private let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("확인", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.backgroundColor = .bgColor
        button.layer.cornerRadius = 8
       
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5) // 뒷배경 투명 설정
        setupLayout()
    }
    
    private func setupLayout() {
        // 중앙 콘텐츠 뷰 추가 및 레이아웃 설정
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(320) // 중앙 뷰 크기를 320x320으로 설정
        }
        
        // 콘텐츠 뷰 내부 레이아웃
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(activityStackView)
        contentView.addSubview(confirmButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(24)
            make.centerX.equalTo(contentView)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.centerX.equalTo(contentView)
        }
        
        activityStackView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            make.centerX.equalTo(contentView)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(activityStackView.snp.bottom).offset(24)
            make.leading.equalTo(contentView).offset(20)
            make.trailing.equalTo(contentView).offset(-20)
            make.height.equalTo(40)
            make.bottom.equalTo(contentView).offset(-24)
        }
        
        // 활동 아이템 추가
        addActivityItem(imageName: "1", text: "활동 1회")
        addActivityItem(imageName: "2", text: "활동 2회")
        addActivityItem(imageName: "3", text: "3회 이상")

        // 버튼 액션 추가
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
    }
    
    private func addActivityItem(imageName: String, text: String) {
        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.contentMode = .scaleAspectFit
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
        
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        
        // 수평 스택 뷰에 아이템 배치
        let stack = UIStackView(arrangedSubviews: [imageView, label])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 2
        
        activityStackView.addArrangedSubview(stack)
    }
    
    @objc private func confirmButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
  
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var shortFormHeight: PanModalHeight {
        return .maxHeight
    }
    
    var longFormHeight: PanModalHeight {
        return .maxHeight
    }
    
    var cornerRadius: CGFloat {
        return 0
    }
    
    var showDragIndicator: Bool {
        return false
    }
}
