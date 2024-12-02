//
//  SuccessViewController.swift
//  Dosirak
//
//  Created by 권민재 on 11/28/24.
//
import UIKit
import SnapKit
import ImageIO

class SuccessViewController: BaseViewController {
    
    var measuredDistance: Double = 0.0
    let carEmissionPerKm: Double = 0.12 // 자동차 CO2 배출량 (kg/km)

    let coordinator = AppCoordinator()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        
        // GIF 파일 로드 및 설정
        if let gifUrl = Bundle.main.url(forResource: "success", withExtension: "gif"),
           let gifData = try? Data(contentsOf: gifUrl) {
            backgroundGIF.image = UIImage.gif(data: gifData)
        } else {
            print("GIF 파일을 찾을 수 없거나 로드할 수 없습니다.")
        }
    }

    override func setupView() {
        view.addSubview(backgroundGIF)
        view.addSubview(homeButton)
        view.addSubview(earthLabel)
        view.addSubview(emitLabel)
        view.addSubview(carbonContainerView)
        view.addSubview(stepInfoContainerView)
        
        homeButton.addTarget(self, action: #selector(goHome), for: .touchUpInside)
        
        if let stepLabel = stepInfoContainerView.subviews.compactMap({ $0 as? UILabel }).first {
            stepLabel.text = String(format: "총 %.2f Km 측정되었습니다.", measuredDistance)
        }

        let carbonLabels = carbonContainerView.subviews.compactMap { $0 as? UILabel }
        if carbonLabels.count >= 2 {
            let carbonSaved = calculateCarbonSaved() // 탄소 배출량 절약 계산
            carbonLabels[0].text = String(format: "%.0f", floor(carbonSaved)) // 첫째 자리
            carbonLabels[1].text = String(format: "%.0f", floor(carbonSaved * 10).truncatingRemainder(dividingBy: 10)) // 둘째 자리
        }
    }

    override func setupLayout() {
        backgroundGIF.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        homeButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.height.equalTo(40)
        }
        
        earthLabel.snp.makeConstraints {
            $0.top.equalTo(homeButton.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
        }

        emitLabel.snp.makeConstraints {
            $0.top.equalTo(earthLabel.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }

        carbonContainerView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(210)
            $0.height.equalTo(100)
        }

        stepInfoContainerView.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-40)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(40)
        }
    }

    private func calculateCarbonSaved() -> Double {
        return measuredDistance * carEmissionPerKm
    }

    @objc func goHome() {
        coordinator.moveToHomeFromAnyVC()
    }

    // MARK: - UI Components
    
    let homeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "home_white"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    let backgroundGIF: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        return view
    }()

    let earthLabel: UILabel = {
        let label = UILabel()
        label.text = "지구를 위해 절약된"
        label.textColor = UIColor(hexCode: "464b4a")
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .center
        return label
    }()

    let emitLabel: UILabel = {
        let label = UILabel()
        label.text = "탄소배출량"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 35)
        label.textAlignment = .center
        return label
    }()

    let carbonContainerView: UIView = {
        let container = UIView()

        // 첫 번째 숫자
        let firstDigitLabel = UILabel()
        firstDigitLabel.text = "0"
        firstDigitLabel.font = UIFont.boldSystemFont(ofSize: 40)
        firstDigitLabel.textColor = .black
        firstDigitLabel.textAlignment = .center
        firstDigitLabel.backgroundColor = .white
        firstDigitLabel.layer.cornerRadius = 10
        firstDigitLabel.layer.masksToBounds = true
        container.addSubview(firstDigitLabel)

        // 두 번째 숫자
        let secondDigitLabel = UILabel()
        secondDigitLabel.text = "0"
        secondDigitLabel.font = UIFont.boldSystemFont(ofSize: 40)
        secondDigitLabel.textColor = .black
        secondDigitLabel.textAlignment = .center
        secondDigitLabel.backgroundColor = .white
        secondDigitLabel.layer.cornerRadius = 10
        secondDigitLabel.layer.masksToBounds = true
        container.addSubview(secondDigitLabel)

        // 소수점
        let decimalLabel = UILabel()
        decimalLabel.text = "."
        decimalLabel.font = UIFont.boldSystemFont(ofSize: 20)
        decimalLabel.textColor = .black
        decimalLabel.textAlignment = .center
        container.addSubview(decimalLabel)

        // kg 단위
        let unitLabel = UILabel()
        unitLabel.text = "kg"
        unitLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        unitLabel.textColor = .white
        unitLabel.textAlignment = .center
        container.addSubview(unitLabel)

        // 레이아웃
        firstDigitLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(50)
        }

        decimalLabel.snp.makeConstraints { make in
            make.leading.equalTo(firstDigitLabel.snp.trailing).offset(4)
            make.centerY.equalToSuperview()
        }

        secondDigitLabel.snp.makeConstraints { make in
            make.leading.equalTo(decimalLabel.snp.trailing).offset(4)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(50)
        }

        unitLabel.snp.makeConstraints { make in
            make.leading.equalTo(secondDigitLabel.snp.trailing).offset(8)
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        return container
    }()

    let stepInfoContainerView: UIView = {
        let container = UIView()
        container.backgroundColor = UIColor.systemGray5
        container.layer.cornerRadius = 14
        
        let footprintView = UIImageView()
        footprintView.image = UIImage(named: "footprint")
        container.addSubview(footprintView)

        let stepLabel = UILabel()
        stepLabel.text = "총 NKm 측정되었습니다."
        stepLabel.font = UIFont.systemFont(ofSize: 14)
        stepLabel.textColor = UIColor.darkGray
        container.addSubview(stepLabel)

        let checkmarkImageView = UIImageView()
        checkmarkImageView.image = UIImage(named: "check")
        checkmarkImageView.tintColor = UIColor.green
        container.addSubview(checkmarkImageView)

        footprintView.snp.makeConstraints {
            $0.leading.equalTo(container.snp.leading).inset(20)
            $0.centerY.equalToSuperview()
        }

        stepLabel.snp.makeConstraints { make in
            make.leading.equalTo(footprintView.snp.trailing).offset(12)
            make.bottom.equalTo(footprintView.snp.bottom)
        }

        checkmarkImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }

        return container
    }()
}
