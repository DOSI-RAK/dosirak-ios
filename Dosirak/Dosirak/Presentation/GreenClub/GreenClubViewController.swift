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
    
 
    
    // Rx
    private let disposeBag = DisposeBag()
    private let filterSelection = BehaviorRelay(value: "가까운 순")
    private let storeItems = BehaviorRelay(value: [StoreItem]())
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        bindUI()
        loadStoreItems()
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
        button.layer.cornerRadius = 15
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.1
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        if isSelected {
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .black
        } else {
            button.setTitleColor(.black, for: .normal)
            button.backgroundColor = .lightGray
        }
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
    private func bindUI() {
        // Filter 버튼 클릭 이벤트 처리
        nearbyButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.filterSelection.accept("가까운 순")
            })
            .disposed(by: disposeBag)
        
        discountButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.filterSelection.accept("할인률 순")
            })
            .disposed(by: disposeBag)
        
        // 필터 선택에 따른 UI 업데이트
        filterSelection
            .subscribe(onNext: { [weak self] selectedFilter in
                self?.updateFilterButtons(selectedFilter: selectedFilter)
            })
            .disposed(by: disposeBag)
        
        // Apply 버튼 클릭 이벤트 처리
        applyButton.rx.tap
            .subscribe(onNext: {
                print("입점 신청하기 버튼이 클릭되었습니다.")
            })
            .disposed(by: disposeBag)
        
        // 데이터 바인딩
        storeItems
            .bind(to: tableView.rx.items(cellIdentifier: StoreCell.identifier, cellType: StoreCell.self)) { index, item, cell in
                cell.configure(with: item)
            }
            .disposed(by: disposeBag)
    }
    
    private func updateFilterButtons(selectedFilter: String) {
        setupFilterButton(nearbyButton, title: "가까운 순", isSelected: selectedFilter == "가까운 순")
        setupFilterButton(discountButton, title: "할인률 순", isSelected: selectedFilter == "할인률 순")
    }
    
    // MARK: - Load Data
    private func loadStoreItems() {
        // 예시 데이터
        let items = [
            StoreItem(name: "가게 이름 1", discount: "20%", distance: "500m", discountTime: "00:00 - 00:00"),
            StoreItem(name: "가게 이름 2", discount: "15%", distance: "300m", discountTime: "10:00 - 22:00"),
            StoreItem(name: "가게 이름 3", discount: "10%", distance: "800m", discountTime: "09:00 - 18:00")
        ]
        storeItems.accept(items)
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
// MARK: - Store Item Model
struct StoreItem {
    let name: String
    let discount: String
    let distance: String
    let discountTime: String
}

// MARK: - Custom StoreCell
class StoreCell: UITableViewCell {
    static let identifier = "StoreCell"
    
    private let storeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .lightGray
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let storeNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = "가게 이름"
        return label
    }()
    
    private let discountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .red
        label.textAlignment = .center
        label.text = "20%"
        return label
    }()
    
    private let distanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private let discountTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .blue
        label.text = "할인 시간"
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(storeImageView)
        contentView.addSubview(storeNameLabel)
        contentView.addSubview(discountLabel)
        contentView.addSubview(distanceLabel)
        contentView.addSubview(discountTimeLabel)
    }
    
    private func setupConstraints() {
        storeImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        storeNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(storeImageView.snp.trailing).offset(16)
            make.top.equalToSuperview().offset(10)
        }
        
        discountTimeLabel.snp.makeConstraints { make in
            make.leading.equalTo(storeNameLabel)
            make.top.equalTo(storeNameLabel.snp.bottom).offset(4)
        }
        
        distanceLabel.snp.makeConstraints { make in
            make.leading.equalTo(storeNameLabel)
            make.top.equalTo(discountTimeLabel.snp.bottom).offset(4)
        }
        
        discountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }
    
    func configure(with item: StoreItem) {
        storeNameLabel.text = item.name
        discountLabel.text = item.discount
        distanceLabel.text = item.distance
        discountTimeLabel.text = item.discountTime
    }
}
