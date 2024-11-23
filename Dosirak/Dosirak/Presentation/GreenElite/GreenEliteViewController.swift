//
//  GreenEliteViewController.swift
//  Dosirak
//
//  Created by 권민재 on 11/23/24.
//
import UIKit
import SnapKit

class GreenEliteViewController: UIViewController {

    private let progressContainerView: UIView = UIView()

    private let progressTrackLayer = CAShapeLayer()
    private let progressBarLayer = CAShapeLayer()

    private let sproutImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "새싹이") // "새싹" 이미지 사용
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let scoreView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor // 그림자 색상
        view.layer.shadowOpacity = 0.2 // 그림자 투명도
        view.layer.shadowOffset = CGSize(width: 0, height: 4) // 그림자 위치
        view.layer.shadowRadius = 8 // 그림자 퍼짐 정도
        return view
    }()

    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.text = "총 0문제 중\n0%\n정답"
        label.numberOfLines = 3
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        return label
    }()

    private let correctWrongView: UIStackView = {
        let correctLabel = UILabel()
        correctLabel.text = "맞은문제\n0"
        correctLabel.textAlignment = .center
        correctLabel.textColor = .blue
        correctLabel.numberOfLines = 2

        let wrongLabel = UILabel()
        wrongLabel.text = "틀린문제\n0"
        wrongLabel.textAlignment = .center
        wrongLabel.textColor = .red
        wrongLabel.numberOfLines = 2

        let stackView = UIStackView(arrangedSubviews: [correctLabel, wrongLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 1
        stackView.backgroundColor = .white
        
        
        stackView.layer.cornerRadius = 12
        stackView.layer.shadowColor = UIColor.black.cgColor // 그림자 색상
        stackView.layer.shadowOpacity = 0.2 // 그림자 투명도
        stackView.layer.shadowOffset = CGSize(width: 0, height: 4) // 그림자 위치
        stackView.layer.shadowRadius = 8 // 그림자 퍼짐 정도
        
        
        return stackView
    }()

    private let todayQuizButton: UIButton = {
        let button = UIButton()
        button.setTitle("오늘의 문제", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .mainColor
        button.layer.cornerRadius = 12
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .bgColor
        setupNavigation()
        setupViews()
        setupConstraints()
        setupHalfCircularProgressBar()
        
        updateProgress(to: 0.1)
    }

    private func setupNavigation() {
        navigationItem.title = "Green Elite"
    }

    private func setupViews() {
        view.addSubview(progressContainerView)
        view.addSubview(sproutImageView)
        view.addSubview(scoreView)
        view.addSubview(correctWrongView)
        view.addSubview(todayQuizButton)
        scoreView.addSubview(scoreLabel)
    }

    private func setupConstraints() {
        progressContainerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(280) // ProgressBar 크기를 키움
        }

        sproutImageView.snp.makeConstraints { make in
            make.center.equalTo(progressContainerView)
            make.height.equalTo(100)
            make.width.equalTo(200)
        }

        scoreView.snp.makeConstraints { make in
            make.top.equalTo(progressContainerView.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.width.equalTo(353)
            make.height.equalTo(190)
        }

        scoreLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }

        correctWrongView.snp.makeConstraints { make in
            make.top.equalTo(scoreView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(60)
        }

        todayQuizButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
    }

    private func setupHalfCircularProgressBar() {
        let centerPoint = CGPoint(x: 140, y: 140) // 중앙 좌표
        let circularPath = UIBezierPath(
            arcCenter: centerPoint,
            radius: 120, // 반지름
            startAngle: CGFloat.pi,
            endAngle: 0,
            clockwise: true
        )

        // Track Layer (배경)
        progressTrackLayer.path = circularPath.cgPath
        progressTrackLayer.strokeColor = UIColor.lightGray.cgColor
        progressTrackLayer.lineWidth = 20 // 두께
        progressTrackLayer.fillColor = UIColor.clear.cgColor
        progressTrackLayer.lineCap = .round
        progressContainerView.layer.addSublayer(progressTrackLayer)

        // Progress Layer (진행 레이어)
        progressBarLayer.path = circularPath.cgPath
        progressBarLayer.strokeColor = UIColor.black.cgColor // 실제 색상은 보이지 않음
        progressBarLayer.lineWidth = 60 // 두께
        progressBarLayer.fillColor = UIColor.clear.cgColor
        progressBarLayer.lineCap = .round
        progressBarLayer.strokeEnd = 0.0 // 초기 진행 상태
        progressContainerView.layer.addSublayer(progressBarLayer)

        // Gradient Layer (그라데이션)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = progressContainerView.bounds
        gradientLayer.colors = [
            UIColor.systemBlue.cgColor,
            UIColor.systemGreen.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5) // 왼쪽에서 시작
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5) // 오른쪽 끝

        // Gradient Layer와 Progress Layer 결합
        gradientLayer.mask = progressBarLayer
        progressContainerView.layer.addSublayer(gradientLayer)
    }

    // Progress 업데이트 함수
    func updateProgress(to value: CGFloat) {
        progressBarLayer.strokeEnd = value// 0.0 ~ 1.0 사이의 값
    }
}
