//
//  GreenGuideViewController.swift
//  Dosirak
//
//  Created by 권민재 on 11/1/24.
//
import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import NMapsMap

// MARK: - GreenGuideViewController

class GreenGuideViewController: UIViewController {
    
    let mapView = NMFMapView()
    private let disposeBag = DisposeBag()
    private let reactor: GreenGuideReactor
    private let overlayView = UIView()
    

    private let categoryTitles = ["전체", "한식", "일식", "양식", "분식", "카페", "디저트"]
    private var selectedCategoryButton: UIButton?
    
    
    init(reactor: GreenGuideReactor) {
        self.reactor = reactor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
        setupBottomSheet()
        bindReactor()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    private func setupView() {
        view.addSubview(mapView)
        
        overlayView.backgroundColor = .clear // 터치 우선 오버레이 설정
        overlayView.isUserInteractionEnabled = true
        view.addSubview(overlayView)
        
        overlayView.addSubview(searchTextField)
        overlayView.addSubview(findRouteButton)
        overlayView.addSubview(homeButton)
        setupCategoryButtons()
        
        // myLocationButton을 mapView에 추가
        mapView.addSubview(myLocationButton)
    }
    
    private func setupLayout() {
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        overlayView.snp.makeConstraints {
            $0.leading.trailing.equalTo(view)
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(120)
        }
        
        searchTextField.snp.makeConstraints {
            $0.top.equalTo(overlayView.safeAreaLayoutGuide).offset(10)
            $0.leading.equalTo(overlayView).inset(20)
            $0.width.equalTo(252)
            $0.height.equalTo(52)
        }
        
        findRouteButton.snp.makeConstraints {
            $0.leading.equalTo(searchTextField.snp.trailing).offset(10)
            $0.width.height.equalTo(52)
            $0.top.equalTo(searchTextField)
        }
        
        homeButton.snp.makeConstraints {
            $0.leading.equalTo(findRouteButton.snp.trailing).offset(5)
            $0.width.height.equalTo(52)
            $0.top.equalTo(searchTextField)
        }
        
        myLocationButton.snp.makeConstraints {
            $0.leading.equalTo(view).inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20) // 지도 위 아래쪽에 고정
            $0.width.height.equalTo(52)
        }
    }
    
    private func setupBottomSheet() {
        let bottomSheetVC = BottomSheetViewController()
        bottomSheetVC.reactor = self.reactor // Reactor 주입
        
        if let sheet = bottomSheetVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.selectedDetentIdentifier = .medium
            
            // Bottom sheet detent 상태 변화 감지
            sheet.delegate = self
        }
        
        present(bottomSheetVC, animated: true)
    }
    
    // 카테고리 버튼들을 오버레이 수평 스택 뷰에 추가
    private func setupCategoryButtons() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        
        categoryTitles.forEach { title in
            let button = UIButton()
            button.setTitle(title, for: .normal)
            button.backgroundColor = .white
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 14)
            button.layer.cornerRadius = 15
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.lightGray.cgColor
            button.layer.masksToBounds = true
            button.addTarget(self, action: #selector(categoryButtonTapped(_:)), for: .touchUpInside)
            
            if title == "전체" {
                selectCategoryButton(button) // 기본 선택 버튼 설정
            }
            
            stackView.addArrangedSubview(button)
        }
        
        overlayView.addSubview(stackView)
        
        // 스택 뷰의 제약 조건 설정
        stackView.snp.makeConstraints {
            $0.top.equalTo(searchTextField.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(overlayView).inset(20)
            $0.height.equalTo(30)
        }
    }
    
    // 카테고리 버튼 탭 시 액션
    @objc private func categoryButtonTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle else { return }
        print("\(title) 버튼이 탭되었습니다.")
        selectCategoryButton(sender)
        // 카테고리 필터링 로직을 여기에 구현합니다. 예: 지도 마커 업데이트
    }
    
    private func selectCategoryButton(_ button: UIButton) {
        // 기존 선택된 버튼 스타일 초기화
        selectedCategoryButton?.backgroundColor = .white
        selectedCategoryButton?.setTitleColor(.black, for: .normal)
        selectedCategoryButton?.layer.borderColor = UIColor.lightGray.cgColor
        
        // 새로 선택된 버튼 스타일 적용
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        
        // 현재 선택된 버튼 업데이트
        selectedCategoryButton = button
    }

    // MARK: - Reactor Binding
    private func bindReactor() {
        // Reactor Action: 초기 상점 목록 불러오기
        reactor.action.onNext(.loadAllStores)
        
        // Reactor State Binding 예시: 로딩 상태 관찰
        reactor.state
            .map { $0.isLoading }
            .distinctUntilChanged()
            .subscribe(onNext: { isLoading in
                if isLoading {
                    print("로딩 중...")
                } else {
                    print("로딩 완료")
                }
            })
            .disposed(by: disposeBag)
        
        homeButton.rx.tap
            .bind { [weak self] in
                print("homeButton tapped")
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: UI Components
    lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "장소, 주소 검색"
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 12
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always // 항상 leftView가 보이도록 설정
        return textField
    }()
    
    lazy var findRouteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "goto"), for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        return button
    }()
    
    lazy var myLocationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "mylocation"), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        return button
    }()
    
    lazy var homeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "home_green"), for: .normal)
        button.backgroundColor = .clear
        return button
    }()
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension GreenGuideViewController: UISheetPresentationControllerDelegate {
    func presentationControllerDidChangeSelectedDetentIdentifier(_ presentationController: UIPresentationController) {
        guard let sheet = presentationController as? UISheetPresentationController else { return }
        
        // Bottom sheet가 large일 때 myLocationButton 숨기기
        if sheet.selectedDetentIdentifier == .large {
            myLocationButton.isHidden = true
        } else {
            myLocationButton.isHidden = false
        }
    }
}