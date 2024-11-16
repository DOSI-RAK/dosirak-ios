//
//  GreenClubViewController.swift
//  Dosirak
//
//  Created by 권민재 on 11/15/24.
//
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class GreenClubViewController: UIViewController {
    
    // ViewModel
    private let viewModel = SaleStoresViewModel()
    
    // Rx
    private let disposeBag = DisposeBag()
    private let fetchTrigger = PublishRelay<Void>()
    private let addressInput = BehaviorRelay<String>(value: "강남구") // 기본 주소
    private let filterSelection = BehaviorRelay<String>(value: "할인률 순")
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        bindViewModel()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        // Title Label
        titleLabel.text = "Green Club"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        
        // Change Button
        changeButton.setTitle("변경하기", for: .normal)
        changeButton.setTitleColor(.systemBlue, for: .normal)
        
        // Filter Buttons
        setupFilterButton(nearbyButton, title: "가까운 순", isSelected: true)
        setupFilterButton(discountButton, title: "할인률 순", isSelected: false)
        
        // Filter Stack View
        filterStackView.axis = .horizontal
        filterStackView.spacing = 10
        
        // Table View
        tableView.register(StoreCell.self, forCellReuseIdentifier: StoreCell.identifier)
        tableView.rowHeight = 100  // 셀 높이 고정
        tableView.separatorStyle = .none
        
        // Apply Button (Floating)
        applyButton.setTitle("입점 신청하기", for: .normal)
        applyButton.backgroundColor = UIColor.mainColor
        applyButton.setTitleColor(.white, for: .normal)
        applyButton.layer.cornerRadius = 14
        applyButton.layer.shadowColor = UIColor.black.cgColor
        applyButton.layer.shadowOpacity = 0.3
        applyButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        applyButton.layer.shadowRadius = 6
        
        // Add Subviews
        view.addSubview(titleLabel)
        view.addSubview(changeButton)
        view.addSubview(filterStackView)
        view.addSubview(tableView)
        view.addSubview(applyButton)
    }
    
    private func setupFilterButton(_ button: UIButton, title: String, isSelected: Bool) {
        button.setTitle(title, for: .normal)
        button.layer.cornerRadius = 20 // 버튼 크기를 더 크게
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16) // 폰트 크기 조정

        if isSelected {
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .black
            button.layer.shadowOpacity = 0 // 선택된 상태에서는 그림자 없음
        } else {
            button.setTitleColor(.black, for: .normal)
            button.backgroundColor = .white
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOpacity = 0.1
            button.layer.shadowOffset = CGSize(width: 0, height: 2)
            button.layer.shadowRadius = 4
        }
    }

    private func updateFilterButtons(selectedFilter: String) {
        let isNearbySelected = selectedFilter == "가까운 순"
        setupFilterButton(nearbyButton, title: "가까운 순", isSelected: isNearbySelected)
        setupFilterButton(discountButton, title: "할인률 순", isSelected: !isNearbySelected)
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.leading.equalToSuperview().offset(16)
        }
        
        changeButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        filterStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(16)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(filterStackView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-70) // 아래 플로팅 버튼 공간 확보
        }
        
        applyButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
            make.leading.trailing.equalTo(view).inset(40)
            make.height.equalTo(50)
        }
    }
    
    // MARK: - Binding
    private func bindViewModel() {
        let input = SaleStoresViewModel.Input(
            fetchTrigger: fetchTrigger,
            address: addressInput
        )
        
        let output = viewModel.transform(input: input)
        
        // Address 변경 처리
        changeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                let alert = UIAlertController(title: "주소 변경", message: "새로운 주소를 입력하세요.", preferredStyle: .alert)
                alert.addTextField { textField in
                    textField.placeholder = "주소 입력"
                }
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                    if let newAddress = alert.textFields?.first?.text, !newAddress.isEmpty {
                        self?.addressInput.accept(newAddress)
                        self?.fetchTrigger.accept(()) // 새로운 주소로 데이터 가져오기
                    }
                }))
                alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        // 필터 버튼 클릭
        nearbyButton.rx.tap
            .bind { [weak self] in
                self?.fetchTrigger.accept(()) // 가까운 순 필터로 데이터 가져오기
            }
            .disposed(by: disposeBag)
        
        discountButton.rx.tap
            .bind { [weak self] in
                self?.filterSelection.accept("할인률 순")
                self?.fetchTrigger.accept(()) // 할인률 순 필터로 데이터 가져오기
            }
            .disposed(by: disposeBag)
        
        output.saleStores
            .map { stores in
                if self.filterSelection.value == "가까운 순" {
                    // 거리순 정렬
                    return stores.sorted { ($0.distance ?? 0) < ($1.distance ?? 0) }
                } else {
                    // 할인율순 정렬
                    return stores.sorted { $0.saleDiscount > $1.saleDiscount }
                }
            }
            .bind(to: tableView.rx.items(cellIdentifier: StoreCell.identifier, cellType: StoreCell.self)) { _, item, cell in
                cell.configure(with: item)
            }
            .disposed(by: disposeBag)
        
        // 로딩 상태
        output.isLoading
            .subscribe(onNext: { isLoading in
                print("로딩 상태: \(isLoading)")
            })
            .disposed(by: disposeBag)
        
        // 에러 처리
        output.error
            .subscribe(onNext: { errorMessage in
                print("에러 메시지: \(errorMessage)")
            })
            .disposed(by: disposeBag)
        
        // 초기 데이터 로드
        fetchTrigger.accept(())
        nearbyButton.rx.tap
            .bind { [weak self] in
                self?.filterSelection.accept("가까운 순") // 필터 값 변경
                self?.fetchTrigger.accept(()) // 데이터 재정렬
            }
            .disposed(by: disposeBag)

        // 할인율 순 버튼 클릭
        discountButton.rx.tap
            .bind { [weak self] in
                self?.filterSelection.accept("할인률 순") // 필터 값 변경
                self?.fetchTrigger.accept(()) // 데이터 재정렬
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - UI Components
    private let tableView = UITableView()
    private let applyButton = UIButton()
    private let titleLabel = UILabel()
    private let changeButton = UIButton()
    private let nearbyButton = UIButton()
    private let discountButton = UIButton()
    private lazy var filterStackView = UIStackView(arrangedSubviews: [nearbyButton, discountButton])
}
