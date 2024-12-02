//
//  StoreDetailViewController.swift
//  Dosirak
//
//  Created by 권민재 on 11/4/24.
//

import Kingfisher
import ReactorKit
import RxSwift
import SnapKit
import UIKit

class StoreDetailViewController: UIViewController {

    private var isOperatingTimeExpanded = false
    private let disposeBag = DisposeBag()
    var storeId: Int?
    var reactor: GreenGuideReactor?

    private let packageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("다회용기 포장하기", for: .normal)
        button.backgroundColor = .mainColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        return button
    }()

    private let upDownImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "drop_down"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        setupFloatingPackageButton()
        bind(reactor: reactor!)

        packageButton.addTarget(
            self, action: #selector(handlePackageButtonTap), for: .touchUpInside
        )
        arriveButton.addTarget(
            self, action: #selector(handleArriveButtonTap), for: .touchUpInside)
    }

    @objc private func handlePackageButtonTap() {
        let greenAuthVC = GreenAuthViewController()
        navigationController?.pushViewController(greenAuthVC, animated: true)
    }

    @objc private func handleArriveButtonTap() {
        let greenTrackVC = GreenTrackViewController()
        greenTrackVC.destination = title
        navigationController?.pushViewController(greenTrackVC, animated: true)
    }

    init(storeId: Int, reactor: GreenGuideReactor) {
        super.init(nibName: nil, bundle: nil)
        self.storeId = storeId
        self.reactor = reactor
        self.reactor?.action.onNext(.loadStoreDetail(storeId))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    func bind(reactor: GreenGuideReactor) {
        reactor.state
            .map { $0.storeDetail }
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] storeDetail in
                self?.updateUI(with: storeDetail)
            })
            .disposed(by: disposeBag)
    }

    private func setupUI() {
        scrollView.backgroundColor = UIColor(hexCode: "#ffffff")
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.axis = .vertical
        contentView.spacing = 16

        storeImageView.clipsToBounds = true

        contentView.addArrangedSubview(storeImageView)
        contentView.addArrangedSubview(baseView)
        contentView.addArrangedSubview(buttonStackView)
        contentView.addArrangedSubview(addressLabel)
        contentView.addArrangedSubview(operatingTimeButton)
        contentView.addArrangedSubview(operatingTimeDetailStackView)

        operatingTimeButton.backgroundColor = UIColor(hexCode: "#f8f8f8")
        operatingTimeDetailStackView.backgroundColor = UIColor(
            hexCode: "#f8f8f8")

        baseView.addSubview(categoryLabel)
        baseView.addSubview(storeStatusLabel)
        baseView.addSubview(storeTitleLabel)
        baseView.addSubview(benefitImage)

        setupFloatingPackageButton()
    }

    private func setupLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        storeImageView.snp.makeConstraints {
            $0.height.equalTo(190)
            $0.leading.trailing.equalToSuperview()
        }

        baseView.snp.makeConstraints {
            $0.height.equalTo(120)
        }

        categoryLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(20)
            $0.width.equalTo(70)
            $0.height.equalTo(25)
        }
        benefitImage.snp.makeConstraints {
            $0.leading.equalTo(categoryLabel)
            $0.top.equalTo(categoryLabel.snp.bottom).offset(10)
            $0.width.equalTo(23)
            $0.height.equalTo(12)
        }

        storeStatusLabel.snp.makeConstraints {
            $0.top.equalTo(categoryLabel.snp.bottom).offset(10)
            $0.leading.equalTo(benefitImage.snp.trailing).offset(5)
        }

        storeTitleLabel.snp.makeConstraints {
            $0.top.equalTo(storeStatusLabel.snp.bottom).offset(10)
            $0.leading.equalTo(categoryLabel)
        }

        buttonStackView.snp.makeConstraints {
            $0.height.equalTo(43)
            $0.leading.trailing.equalToSuperview().inset(40)
        }

        startButton.snp.makeConstraints {
            $0.width.equalTo(104)
        }

        arriveButton.snp.makeConstraints {
            $0.width.equalTo(104)
        }

        operatingTimeButton.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }

        operatingTimeDetailStackView.axis = .vertical
        operatingTimeDetailStackView.spacing = 0
        operatingTimeDetailStackView.isHidden = true
    }

    private func updateUI(with storeDetail: StoreDetail) {
        title = storeDetail.storeName
        storeImageView.kf.setImage(with: URL(string: storeDetail.storeImg))
        categoryLabel.text = storeDetail.storeCategory
        //storeStatusLabel.text = storeDetail.ifValid
        storeTitleLabel.text = storeDetail.storeName

        let benefitText = storeDetail.ifValid
        let highlightText = "다회용기 혜택"
        let attributedText = NSMutableAttributedString(string: benefitText)

        if let range = benefitText.range(of: highlightText) {
            let nsRange = NSRange(range, in: benefitText)
            attributedText.addAttribute(
                .foregroundColor, value: UIColor.systemBlue, range: nsRange)
        }
        storeStatusLabel.attributedText = attributedText

        if let operationTimes = decodeOperationTime(
            from: storeDetail.operationTime)
        {
            setupOperatingTimeSection(with: operationTimes)
        }

        setupMenuListSection(with: storeDetail.menus)
    }

    private func setupOperatingTimeSection(with operationTimes: [OperatingTime])
    {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "E"
        let today = dateFormatter.string(from: Date())

        // Button Title 설정
        operatingTimeButton.setTitle(
            " 오늘(\(today))   \(operationTimes.first(where: { $0.day == today })?.hours ?? "영업 정보 없음")",
            for: .normal)
        operatingTimeButton.setTitleColor(.black, for: .normal)
        operatingTimeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        operatingTimeButton.contentHorizontalAlignment = .left
        operatingTimeButton.titleEdgeInsets = UIEdgeInsets(
            top: 0, left: 20, bottom: 0, right: 0)  // 제목 왼쪽 여백
        operatingTimeButton.addTarget(
            self, action: #selector(toggleOperatingTime), for: .touchUpInside)

        // Drop Down 이미지 설정
        operatingTimeButton.addSubview(upDownImageView)
        upDownImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(20)  // 오른쪽 여백
            make.width.height.equalTo(24)
        }

        // 기존 Detail StackView 내용 제거
        operatingTimeDetailStackView.subviews.forEach {
            $0.removeFromSuperview()
        }

        // Operation Times 데이터로 StackView 구성
        for time in operationTimes {
            let timeStackView = UIStackView()
            timeStackView.axis = .horizontal
            timeStackView.distribution = .fillProportionally
            timeStackView.spacing = 0

            let dayLabel = UILabel()
            dayLabel.text = time.day
            dayLabel.font = UIFont.systemFont(ofSize: 16)
            dayLabel.textColor = time.day == today ? .systemBlue : .black

            let hoursLabel = UILabel()
            hoursLabel.text = time.hours
            hoursLabel.font = UIFont.systemFont(ofSize: 16)
            hoursLabel.textColor = .gray

            timeStackView.addArrangedSubview(dayLabel)
            timeStackView.addArrangedSubview(hoursLabel)

            dayLabel.snp.makeConstraints {
                $0.leading.equalToSuperview().inset(45)
            }

            operatingTimeDetailStackView.addArrangedSubview(timeStackView)
        }

        contentView.addArrangedSubview(operatingTimeDetailStackView)
    }

    private func setupMenuListSection(with menus: [Menu]) {
        menuSectionContainerView.subviews.forEach { $0.removeFromSuperview() }

        menuSectionContainerView.axis = .vertical
        menuSectionContainerView.spacing = 8

        let menuSectionLabel = UILabel()
        menuSectionLabel.text = "메뉴"
        menuSectionLabel.font = UIFont.boldSystemFont(ofSize: 18)
        menuSectionContainerView.addArrangedSubview(menuSectionLabel)

        menuSectionLabel.snp.makeConstraints {
            $0.leading.equalTo(menuSectionContainerView).inset(20)
        }

        for menu in menus {
            let menuItemView = createMenuItemView(for: menu)
            menuSectionContainerView.addArrangedSubview(menuItemView)
        }

        // 메뉴 섹션 컨테이너를 contentView에 추가
        if contentView.arrangedSubviews.contains(menuSectionContainerView)
            == false
        {
            contentView.addArrangedSubview(menuSectionContainerView)
        }
    }

//    private func createMenuItemView(for menu: Menu) -> UIView {
//        let containerView = UIView()
//        containerView.backgroundColor = .systemGray6
//        containerView.layer.cornerRadius = 8
//        containerView.snp.makeConstraints { make in
//            make.height.equalTo(80)
//        }
//
//        let menuImageView = UIImageView()
//        menuImageView.kf.setImage(with: URL(string: menu.menuImg))
//        menuImageView.contentMode = .scaleAspectFill
//        menuImageView.clipsToBounds = true
//        menuImageView.layer.cornerRadius = 8
//        containerView.addSubview(menuImageView)
//
//        let menuLabel = UILabel()
//        menuLabel.text = menu.menuName
//        menuLabel.font = UIFont.systemFont(ofSize: 16)
//        containerView.addSubview(menuLabel)
//
//        let priceLabel = UILabel()
//        priceLabel.text = "\(menu.menuPrice)원"
//        priceLabel.textColor = .gray
//        priceLabel.font = UIFont.systemFont(ofSize: 16)
//        containerView.addSubview(priceLabel)
//
//        let packageSizeLabel = UILabel()
//        packageSizeLabel.text = menu.menuPackSize
//        packageSizeLabel.font = UIFont.systemFont(ofSize: 12)
//        packageSizeLabel.textColor = .systemGreen
//        containerView.addSubview(packageSizeLabel)
//
//        menuImageView.snp.makeConstraints { make in
//            make.leading.equalToSuperview().inset(10)
//            make.centerY.equalToSuperview()
//            make.width.height.equalTo(60)
//        }
//
//        menuLabel.snp.makeConstraints { make in
//            make.top.equalToSuperview().inset(10)
//            make.leading.equalTo(menuImageView.snp.trailing).offset(10)
//            make.trailing.equalToSuperview().inset(10)
//        }
//
//        priceLabel.snp.makeConstraints { make in
//            make.top.equalToSuperview().inset(10)
//            make.trailing.equalToSuperview().inset(10)
//        }
//
//        packageSizeLabel.snp.makeConstraints { make in
//            make.top.equalTo(menuLabel.snp.bottom).offset(4)
//            make.leading.equalTo(menuLabel)
//        }
//
//        return containerView
//    }
    private func createMenuItemView(for menu: Menu) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .clear
        containerView.snp.makeConstraints { make in
            make.height.equalTo(80)
        }

        // 메뉴 이미지
        let menuImageView = UIImageView()
        menuImageView.kf.setImage(with: URL(string: menu.menuImg))
        menuImageView.contentMode = .scaleAspectFill
        menuImageView.clipsToBounds = true
        menuImageView.layer.cornerRadius = 8
        containerView.addSubview(menuImageView)

        // 메뉴 이름
        let menuLabel = UILabel()
        menuLabel.text = menu.menuName
        menuLabel.font = UIFont.systemFont(ofSize: 16)
        menuLabel.textColor = .black
        containerView.addSubview(menuLabel)

        // 가격 라벨
        let priceLabel = UILabel()
        priceLabel.text = "\(menu.menuPrice)원"
        priceLabel.font = UIFont.systemFont(ofSize: 14)
        priceLabel.textColor = .gray
        priceLabel.textAlignment = .right
        containerView.addSubview(priceLabel)

        // 다회용기 추천용량 라벨
        let benefitLabel = UILabel()
        benefitLabel.text = "다회용기 추천 용량"
        benefitLabel.font = UIFont.systemFont(ofSize: 12)
        benefitLabel.textColor = .systemBlue

        // (1인분 기준) 라벨
        let subLabel = UILabel()
        subLabel.text = "(1인분 기준)"
        subLabel.font = UIFont.systemFont(ofSize: 12)
        subLabel.textColor = .gray

        // 추천용량 StackView
        let descriptionStackView = UIStackView(arrangedSubviews: [benefitLabel, subLabel])
        descriptionStackView.axis = .vertical
        descriptionStackView.spacing = 2
        containerView.addSubview(descriptionStackView)

        // 1L 텍스트와 이미지 StackView
        let packageSizeStackView = UIStackView()
        packageSizeStackView.axis = .horizontal
        packageSizeStackView.spacing = 4
        packageSizeStackView.alignment = .center

        let packageSizeLabel = UILabel()
        packageSizeLabel.text = menu.menuPackSize // e.g., "1L"
        packageSizeLabel.font = UIFont.systemFont(ofSize: 12)
        packageSizeLabel.textColor = .black

        let boxImageView = UIImageView()
        boxImageView.image = UIImage(named: "box")
        boxImageView.contentMode = .scaleAspectFit
        boxImageView.snp.makeConstraints { make in
            make.width.height.equalTo(16)
        }

        packageSizeStackView.addArrangedSubview(packageSizeLabel)
        packageSizeStackView.addArrangedSubview(boxImageView)
        containerView.addSubview(packageSizeStackView)

        // Layout constraints
        menuImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(60)
        }

        menuLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.leading.equalTo(menuImageView.snp.trailing).offset(10)
            make.trailing.lessThanOrEqualTo(priceLabel.snp.leading).offset(-10)
        }

        priceLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.trailing.equalToSuperview().inset(10)
        }

        descriptionStackView.snp.makeConstraints { make in
            make.leading.equalTo(menuLabel)
            make.top.equalTo(menuLabel.snp.bottom).offset(4)
        }

        packageSizeStackView.snp.makeConstraints { make in
            make.leading.equalTo(descriptionStackView.snp.trailing).offset(7)
            make.top.equalTo(descriptionStackView.snp.top)
        }

        return containerView
    }



    private func setupFloatingPackageButton() {
        view.addSubview(packageButton)
        packageButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(52)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.trailing.leading.equalToSuperview().inset(20)
        }
    }

    @objc private func toggleOperatingTime() {
        isOperatingTimeExpanded.toggle()

        UIView.animate(withDuration: 0.3) {
            self.operatingTimeDetailStackView.isHidden = !self
                .isOperatingTimeExpanded

            // 메뉴 리스트 위치 조정
            if self.isOperatingTimeExpanded {
                self.contentView.insertArrangedSubview(
                    self.menuSectionContainerView,
                    at: self.contentView.arrangedSubviews.firstIndex(
                        of: self.operatingTimeDetailStackView)! + 1)
            } else {
                self.contentView.insertArrangedSubview(
                    self.menuSectionContainerView,
                    at: self.contentView.arrangedSubviews.firstIndex(
                        of: self.operatingTimeButton)! + 1)
            }

            // 'updown' 이미지 변경
            let imageName = self.isOperatingTimeExpanded ? "up" : "drop_down"
            if let upDownImageView = self.operatingTimeButton.subviews.first(
                where: { $0 is UIImageView }) as? UIImageView
            {
                upDownImageView.image = UIImage(named: imageName)
            }

            self.contentView.layoutIfNeeded()
        }
    }

    private func decodeOperationTime(from jsonString: String)
        -> [OperatingTime]?
    {
        guard let data = jsonString.data(using: .utf8) else { return nil }

        do {
            let operationTimes = try JSONDecoder().decode(
                [OperatingTime].self, from: data)
            return operationTimes
        } catch {
            print("Failed to decode operationTime: \(error)")
            return nil
        }
    }

    // MARK: UI Components
    let scrollView = UIScrollView()
    let contentView = UIStackView()
    let benefitImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "reuse")
        return view
    }()
    let storeImageView = UIImageView()
    let baseView = UIView()
    let categoryLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .bgColor
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    let storeStatusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    let storeTitleLabel = UILabel()
    let addressLabel = UILabel()
    let operatingTimeButton = UIButton()
    let operatingTimeDetailStackView = UIStackView()
    let startButton: UIButton = {
        let button = UIButton()
        button.setTitle("출발", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setImage(UIImage(named: "depart"), for: .normal)
        button.backgroundColor = .bgColor
        button.layer.cornerRadius = 8
        let spacing: CGFloat = 10
        var configuration = UIButton.Configuration.plain()
        configuration.imagePadding = spacing
        button.configuration = configuration

        return button
    }()

    let arriveButton: UIButton = {
        let button = UIButton()
        button.setTitle("도착", for: .normal)
        button.backgroundColor = .mainColor
        button.setTitleColor(.white, for: .normal)
        button.setImage(UIImage(named: "arrive"), for: .normal)
        let spacing: CGFloat = 10
        var configuration = UIButton.Configuration.plain()
        configuration.imagePadding = spacing
        button.layer.cornerRadius = 8
        button.configuration = configuration
        return button
    }()

    lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            startButton, arriveButton,
        ])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }()

    // 메뉴 리스트를 담을 컨테이너 뷰
    private let menuSectionContainerView = UIStackView()
}
