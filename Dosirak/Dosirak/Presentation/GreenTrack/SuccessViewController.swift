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
    
    let coordinator = AppCoordinator()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .mainColor
        
        if let gifUrl = Bundle.main.url(forResource: "success", withExtension: "gif"),
           let gifData = try? Data(contentsOf: gifUrl) {
            backgroundGIF.image = UIImage.gif(data: gifData)
        }
    }

    override func setupView() {
        view.addSubview(backgroundGIF)
        view.addSubview(earthLabel)
        view.addSubview(emitLabel)
        view.addSubview(carbonContainerView)
        view.addSubview(stepInfoContainerView)
        
        view.addSubview(homeButton)
        homeButton.addTarget(self, action: #selector(goHome), for: .touchUpInside)
    }

    override func setupLayout() {
       
        backgroundGIF.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }


        earthLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            $0.centerX.equalToSuperview()
        }

     
        emitLabel.snp.makeConstraints {
            $0.top.equalTo(earthLabel.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }


        carbonContainerView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(emitLabel.snp.bottom).offset(24)
            $0.height.equalTo(80)
        }

    
        stepInfoContainerView.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(40)
        }
        
        homeButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.trailing.equalTo(view).inset(20)
            $0.width.height.equalTo(60)
        }
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
        view.contentMode = .scaleToFill
        return view
    }()

    let earthLabel: UILabel = {
        let label = UILabel()
        label.text = "지구를 위해 절약된"
        label.textColor = UIColor(hexCode: "464b4a")
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()

    let emitLabel: UILabel = {
        let label = UILabel()
        label.text = "탄소배출량"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 24)
        return label
    }()
    

    let carbonContainerView: UIView = {
        let container = UIView()

        let firstDigitLabel = UILabel()
        firstDigitLabel.text = "9"
        firstDigitLabel.font = UIFont.boldSystemFont(ofSize: 40)
        firstDigitLabel.textColor = .white
        firstDigitLabel.textAlignment = .center
        container.addSubview(firstDigitLabel)

        let secondDigitLabel = UILabel()
        secondDigitLabel.text = "9"
        secondDigitLabel.font = UIFont.boldSystemFont(ofSize: 40)
        secondDigitLabel.textColor = .white
        secondDigitLabel.textAlignment = .center
        container.addSubview(secondDigitLabel)

        let unitLabel = UILabel()
        unitLabel.text = "kg"
        unitLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        unitLabel.textColor = .white
        unitLabel.textAlignment = .center
        container.addSubview(unitLabel)

        firstDigitLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(40)
        }

        secondDigitLabel.snp.makeConstraints { make in
            make.leading.equalTo(firstDigitLabel.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
            make.width.equalTo(40)
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
        container.layer.cornerRadius = 8

        let stepLabel = UILabel()
        stepLabel.text = "총 NKm 측정되었습니다."
        stepLabel.font = UIFont.systemFont(ofSize: 14)
        stepLabel.textColor = UIColor.darkGray
        container.addSubview(stepLabel)

        let checkmarkImageView = UIImageView()
        checkmarkImageView.image = UIImage(systemName: "checkmark.circle.fill")
        checkmarkImageView.tintColor = UIColor.green
        container.addSubview(checkmarkImageView)

        stepLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }

        checkmarkImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(25)
        }

        return container
    }()
}
