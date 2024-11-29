//
//  CreateBottomViewController.swift
//  Dosirak
//
//  Created by 권민재 on 11/4/24.
//

import UIKit
import SnapKit
import PanModal

class CreateBottomViewController: UIViewController, PanModalPresentable, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // 아이콘 선택 콜백
    var didSelectIcon: ((UIImage?) -> Void)?
    
    // 아이콘 이미지 배열
    private let iconImages: [UIImage?] = [
        UIImage(named: "teamprofile01"),
        UIImage(named: "teamprofile02"),
        UIImage(named: "teamprofile03"),
        UIImage(named: "photo") // 카메라 아이콘
    ]
    
    // 각 행을 구성할 수평 스택뷰
    private let topRowStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 20
        return stackView
    }()
    
    private let bottomRowStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 20
        return stackView
    }()
    
    // 전체를 감싸는 수직 스택뷰
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 20
        return stackView
    }()
    
    // 하단 시트의 내용 뷰
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupLayout()
    }
    
    private func setupViews() {
        view.backgroundColor = .clear
        
        // 아이콘을 각 행에 나누어 배치
        for (index, icon) in iconImages.enumerated() {
            let iconButton = UIButton()
            iconButton.setImage(icon, for: .normal)
            iconButton.addTarget(self, action: #selector(iconTapped(_:)), for: .touchUpInside)
            
            if index < 2 {
                topRowStackView.addArrangedSubview(iconButton)
            } else {
                bottomRowStackView.addArrangedSubview(iconButton)
            }
        }
        
        // 상단 및 하단 행을 메인 스택뷰에 추가
        mainStackView.addArrangedSubview(topRowStackView)
        mainStackView.addArrangedSubview(bottomRowStackView)
        
        // 뷰 계층 구조 추가
        view.addSubview(contentView)
        contentView.addSubview(mainStackView)
    }
    
    private func setupLayout() {
        contentView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(300) // 고정 높이 설정
        }
        
        mainStackView.snp.makeConstraints { make in
            make.center.equalToSuperview() // 중앙 정렬
            make.leading.trailing.equalToSuperview().inset(20) // 좌우 여백
        }
    }
    
    @objc private func iconTapped(_ sender: UIButton) {
        if sender.image(for: .normal) == UIImage(named: "photo") {
            // 앨범으로 이동
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion: nil)
        } else {
            // 선택된 이미지를 콜백으로 전달
            didSelectIcon?(sender.image(for: .normal))
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            didSelectIcon?(selectedImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - PanModalPresentable Configuration
    
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(300) // 고정 높이 설정
    }
    
    var longFormHeight: PanModalHeight {
        return .contentHeight(300) // 동일한 높이 유지
    }
    
    var cornerRadius: CGFloat {
        return 20.0 // 모서리 둥글기
    }
    
    var allowsDragToDismiss: Bool {
        return true // 드래그로 닫기 허용
    }
    
    var allowsTapToDismiss: Bool {
        return true // 배경 탭으로 닫기 허용
    }
    
    var backgroundDimColor: UIColor {
        return UIColor.black.withAlphaComponent(0.5) // 어두운 배경 설정
    }
}
