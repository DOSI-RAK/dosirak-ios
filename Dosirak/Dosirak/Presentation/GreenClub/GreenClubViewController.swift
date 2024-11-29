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
    
    
    private let viewModel = SaleStoresViewModel()
    
  
    private let disposeBag = DisposeBag()
    private let fetchTrigger = PublishRelay<Void>()
    private let addressInput = BehaviorRelay<String>(value: "강남구")
    private let filterSelection = BehaviorRelay<String>(value: "할인률 순")
   
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        bindViewModel()
        tableView.backgroundColor = .bgColor
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .bgColor
        
        // Title Label
        titleLabel.text = "강남구 역삼동"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        
        // Change Button
        changeButton.setTitle("변경하기", for: .normal)
        changeButton.setTitleColor(.gray, for: .normal)
        
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
        button.layer.cornerRadius = 10 // 버튼 크기를 더 크게
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
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(16)
            make.width.equalTo(148)
            make.height.equalTo(35)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(filterStackView.snp.bottom).offset(20)
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
    
    private func bindViewModel() {
        let input = SaleStoresViewModel.Input(
            fetchTrigger: fetchTrigger,
            address: addressInput
        )
        
        let output = viewModel.transform(input: input)
        

        updateFilterButtons(selectedFilter: "가까운 순")
        
        // 가까운 순 버튼 클릭
        nearbyButton.rx.tap
            .bind { [weak self] in
                self?.filterSelection.accept("가까운 순")
                self?.updateFilterButtons(selectedFilter: "가까운 순") // 버튼 스타일 업데이트
                self?.fetchTrigger.accept(()) // 데이터 재정렬
            }
            .disposed(by: disposeBag)
        
        // 할인률 순 버튼 클릭
        discountButton.rx.tap
            .bind { [weak self] in
                self?.filterSelection.accept("할인률 순")
                self?.updateFilterButtons(selectedFilter: "할인률 순") // 버튼 스타일 업데이트
                self?.fetchTrigger.accept(()) // 데이터 재정렬
            }
            .disposed(by: disposeBag)
        
        output.saleStores
            .map { stores in
                if self.filterSelection.value == "가까운 순" {
                    return stores.sorted { ($0.distance ?? 0) < ($1.distance ?? 0) }
                } else {
                    return stores.sorted { $0.saleDiscount > $1.saleDiscount }
                }
            }
            .bind(to: tableView.rx.items(cellIdentifier: StoreCell.identifier, cellType: StoreCell.self)) { _, item, cell in
                cell.configure(with: item)
            }
            .disposed(by: disposeBag)
        
        // 초기 데이터 로드
        fetchTrigger.accept(())
        
        changeButton.rx.tap
            .bind { [weak self] in
                self?.navigationController?.pushViewController(AddressInputViewController(), animated: true)
                
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
extension GreenClubViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
