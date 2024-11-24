import RxCocoa
import RxSwift
import SnapKit
//
//  GreenEliteViewController.swift
//  Dosirak
//
//  Created by 권민재 on 11/23/24.
//
import UIKit

class GreenEliteViewController: UIViewController {

    private let progressContainerView: UIView = UIView()
    private let progressTrackLayer = CAShapeLayer()
    private let progressBarLayer = CAShapeLayer()
    private let viewModel = GreenEliteViewModel()
    private let disposeBag = DisposeBag()

    private let sproutImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "새싹이")  // "새싹" 이미지 사용
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let scoreView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor  // 그림자 색상
        view.layer.shadowOpacity = 0.2  // 그림자 투명도
        view.layer.shadowOffset = CGSize(width: 0, height: 4)  // 그림자 위치
        view.layer.shadowRadius = 8  // 그림자 퍼짐 정도
        return view
    }()

    private let scoreLabel: UILabel = {
        let label = UILabel()

        // 멀티 스타일 텍스트 생성
        let attributedText = NSMutableAttributedString()

        // 첫 번째 줄: "총 0문제 중"
        let totalQuestions = NSAttributedString(
            string: "총 0문제 중\n",
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                .foregroundColor: UIColor.darkGray,
            ]
        )
        attributedText.append(totalQuestions)

        // 두 번째 줄: "0%"
        let percentage = NSAttributedString(
            string: "0%\n",
            attributes: [
                .font: UIFont.systemFont(ofSize: 36, weight: .bold),
                .foregroundColor: UIColor.black,
            ]
        )
        attributedText.append(percentage)

        // 세 번째 줄: "정답"
        let correctText = NSAttributedString(
            string: "정답",
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                .foregroundColor: UIColor.darkGray,
            ]
        )
        attributedText.append(correctText)

        // 멀티 스타일 텍스트 설정
        label.attributedText = attributedText
        label.numberOfLines = 3
        label.textAlignment = .center
        return label
    }()

    private let correctWrongView: UIStackView = {
        // 맞은 문제 레이블
        let correctLabel = UILabel()
        let correctAttributedText = NSMutableAttributedString()
        let correctParagraphStyle = NSMutableParagraphStyle()
        correctParagraphStyle.lineSpacing = 16  // 줄 간격 16

        correctAttributedText.append(
            NSAttributedString(
                string: "맞은문제\n",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                    .foregroundColor: UIColor.darkGray,
                    .paragraphStyle: correctParagraphStyle,
                ]
            ))
        correctAttributedText.append(
            NSAttributedString(
                string: "0",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 33, weight: .bold),  // 숫자는 크게
                    .foregroundColor: UIColor.systemBlue,
                ]
            ))
        correctLabel.attributedText = correctAttributedText
        correctLabel.textAlignment = .center
        correctLabel.numberOfLines = 2

        // 틀린 문제 레이블
        let wrongLabel = UILabel()
        let wrongAttributedText = NSMutableAttributedString()
        let wrongParagraphStyle = NSMutableParagraphStyle()
        wrongParagraphStyle.lineSpacing = 16  // 줄 간격 16

        wrongAttributedText.append(
            NSAttributedString(
                string: "틀린문제\n",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                    .foregroundColor: UIColor.darkGray,
                    .paragraphStyle: wrongParagraphStyle,
                ]
            ))
        wrongAttributedText.append(
            NSAttributedString(
                string: "0",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 33, weight: .bold),  // 숫자는 크게
                    .foregroundColor: UIColor.systemRed,
                ]
            ))
        wrongLabel.attributedText = wrongAttributedText
        wrongLabel.textAlignment = .center
        wrongLabel.numberOfLines = 2

        // 구분선
        let divider = UIView()
        divider.backgroundColor = UIColor.lightGray
        divider.snp.makeConstraints { make in
            make.width.equalTo(2)  // 구분선 두께
        }

        // 스택 뷰 구성
        let stackView = UIStackView(arrangedSubviews: [
            correctLabel, wrongLabel,
        ])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 16  // 각 요소 간 간격

        stackView.layer.cornerRadius = 12
        stackView.backgroundColor = .white
        stackView.layer.shadowColor = UIColor.black.cgColor
        stackView.layer.shadowOpacity = 0.2
        stackView.layer.shadowOffset = CGSize(width: 0, height: 4)
        stackView.layer.shadowRadius = 8

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

    private let quizRateLabel: UILabel = {
        let label = UILabel()
        label.text = "퀴즈 정답률"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .darkGray
        return label
    }()

    private let checkQuestionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("문제 확인", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.backgroundColor = UIColor(hexCode: "ededed")
        button.layer.cornerRadius = 12
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .bgColor
        setupNavigation()
        setupViews()
        setupConstraints()
        // 레이아웃 강제 업데이트
        view.layoutIfNeeded()

        // 레이아웃 적용 후 프로그레스바 설정
        setupHalfCircularProgressBar()
        updateProgress(to: 0.0, animated: true)
        bindRX()
    }

    private func setupNavigation() {
        navigationItem.title = "Green Elite"
    }

    private func setupViews() {
        view.addSubview(quizRateLabel)
        view.addSubview(checkQuestionsButton)
        view.addSubview(progressContainerView)
        view.addSubview(sproutImageView)
        view.addSubview(scoreView)
        view.addSubview(correctWrongView)
        view.addSubview(todayQuizButton)
        scoreView.addSubview(scoreLabel)
    }

    private func setupConstraints() {
        quizRateLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.equalToSuperview().offset(20)
        }

        checkQuestionsButton.snp.makeConstraints { make in
            make.centerY.equalTo(quizRateLabel)
            make.trailing.equalToSuperview().offset(-20)
            make.width.equalTo(80)
            make.height.equalTo(32)
        }

        progressContainerView.snp.makeConstraints { make in
            make.top.equalTo(quizRateLabel.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.width.equalTo(280)
            make.height.equalTo(150)
        }

        sproutImageView.snp.makeConstraints { make in
            make.bottom.equalTo(progressContainerView.snp.bottom)
            make.centerX.equalTo(progressContainerView)
            make.top.equalTo(progressContainerView.snp.top).inset(95)
            make.height.equalTo(171)
            make.width.equalTo(138)
        }

        scoreView.snp.makeConstraints { make in
            make.top.equalTo(sproutImageView.snp.bottom).offset(70)
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
            make.height.equalTo(120)
        }

        todayQuizButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
    }

//    private func setupHalfCircularProgressBar() {
//        // 중앙 좌표 및 경로 설정
//        let centerPoint = CGPoint(x: 140, y: 140)  // progressContainerView 안의 중심 좌표
//        let circularPath = UIBezierPath(
//            arcCenter: centerPoint,
//            radius: 120,  // 반지름
//            startAngle: CGFloat.pi,
//            endAngle: 0,
//            clockwise: true
//        )
//      
//        // 배경 트랙 설정
//        progressTrackLayer.path = circularPath.cgPath
//        progressTrackLayer.strokeColor = UIColor(hexCode: "ededed").cgColor
//        progressTrackLayer.lineWidth = 40
//        progressTrackLayer.fillColor = UIColor.clear.cgColor
//        progressTrackLayer.lineCap = .round
//        progressContainerView.layer.addSublayer(progressTrackLayer)
//
//        // 프로그레스 레이어 설정
//        progressBarLayer.path = circularPath.cgPath
//        progressBarLayer.strokeColor = UIColor.black.cgColor
//        progressBarLayer.lineWidth = 40
//        progressBarLayer.fillColor = UIColor.clear.cgColor
//        progressBarLayer.lineCap = .round
//        progressBarLayer.strokeEnd = 0.0
//        progressContainerView.layer.addSublayer(progressBarLayer)
//
//        // 그라데이션 레이어 설정
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.frame = progressContainerView.bounds
//        gradientLayer.colors = [
//            UIColor(hexCode: "20b8c9").cgColor,
//            UIColor(hexCode: "20c997").cgColor,
//            UIColor(hexCode: "47c920").cgColor,
//            
//        ]
//        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
//        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
//
//        // 그라데이션과 프로그레스 레이어 결합
//        gradientLayer.mask = progressBarLayer
//        progressContainerView.layer.addSublayer(gradientLayer)
//
//        print("Progress Container Frame: \(progressContainerView.frame)")
//        print(
//            "Progress Bar Path Bounds: \(progressBarLayer.path?.boundingBox ?? .zero)"
//        )
//    }
    private func setupHalfCircularProgressBar() {
        // 중앙 좌표 및 반지름 설정
           let centerPoint = CGPoint(x: progressContainerView.bounds.width / 2, y: progressContainerView.bounds.height) // 중심은 아래쪽 중앙
           let radius: CGFloat = progressContainerView.bounds.width / 2 - 20 // 패딩을 고려한 반지름

           // 반원 경로 설정
           let circularPath = UIBezierPath(
               arcCenter: centerPoint,
               radius: radius,
               startAngle: CGFloat.pi + 0.15,
               endAngle: -0.15,
               clockwise: true
           )
        // 배경 트랙 설정
        progressTrackLayer.path = circularPath.cgPath
        progressTrackLayer.strokeColor = UIColor(hexCode: "ededed").cgColor
        progressTrackLayer.lineWidth = 40
        progressTrackLayer.fillColor = UIColor.clear.cgColor
        progressTrackLayer.lineCap = .round
        progressContainerView.layer.addSublayer(progressTrackLayer)

        // 프로그레스 레이어 설정
        progressBarLayer.path = circularPath.cgPath
        progressBarLayer.strokeColor = UIColor.black.cgColor
        progressBarLayer.lineWidth = 40
        progressBarLayer.fillColor = UIColor.clear.cgColor
        progressBarLayer.lineCap = .round
        progressBarLayer.strokeEnd = 0.0
        progressContainerView.layer.addSublayer(progressBarLayer)

        // 그라데이션 레이어 설정
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = progressContainerView.bounds
        gradientLayer.colors = [
            UIColor(hexCode: "20b8c9").cgColor, // 파란색
            UIColor(hexCode: "20c997").cgColor, // 청록색
            UIColor(hexCode: "47c920").cgColor  // 녹색
        ]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)

        // 그라데이션과 프로그레스 레이어 결합
        gradientLayer.mask = progressBarLayer
        progressContainerView.layer.addSublayer(gradientLayer)

        print("Progress Container Frame: \(progressContainerView.frame)")
        print("Progress Bar Path Bounds: \(progressBarLayer.path?.boundingBox ?? .zero)")
    }



    private func updateProgress(to value: CGFloat, animated: Bool = true) {
        let clampedValue = max(0.0, min(value, 1.0))  // 0.0 ~ 1.0 사이로 제한
        print("Updating Progress to: \(clampedValue)")

        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.duration = 1.0
            animation.fromValue = progressBarLayer.strokeEnd
            animation.toValue = clampedValue
            animation.timingFunction = CAMediaTimingFunction(
                name: .easeInEaseOut)
            progressBarLayer.strokeEnd = clampedValue
            progressBarLayer.add(animation, forKey: "progressAnimation")
        } else {
            progressBarLayer.strokeEnd = clampedValue
        }
    }

    private func bindRX() {
        viewModel.fetchUserInfo(accessToken: AppSettings.accessToken ?? "")
            .subscribe(onSuccess: { [weak self] userInfo in
                guard let self = self else { return }
                updateUI(with: userInfo)
            })
            .disposed(by: disposeBag)

        checkQuestionsButton.rx.tap
            .bind { [weak self] in
                print("문제 확인 버튼 클릭됨")
            }
            .disposed(by: disposeBag)

        todayQuizButton.rx.tap
            .bind { [weak self] in
                let todayVC = TodayProblemViewController()
                if let navigationController = self?.navigationController {
                    navigationController.pushViewController(
                        todayVC, animated: true)
                } else {
                    let navigationController = UINavigationController(
                        rootViewController: todayVC)
                    navigationController.modalPresentationStyle = .fullScreen
                    self?.present(
                        navigationController, animated: true, completion: nil)
                }
            }
            .disposed(by: disposeBag)
    }

    private func updateUI(with userInfo: EliteUserInfo) {
        let totalAnswers = userInfo.totalAnswers
        let correctAnswers = userInfo.correctAnswers
        let incorrectAnswers = userInfo.incorrectAnswers
        let correctPercentage =
            totalAnswers > 0
            ? (Double(correctAnswers) / Double(totalAnswers)) * 100 : 0.0

        // `scoreLabel` 업데이트
        let attributedText = NSMutableAttributedString()

        // 줄 간격 및 중앙 정렬 설정
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 16  // 줄 간격 16
        paragraphStyle.alignment = .center  // 텍스트 중앙 정렬

        // 첫 번째 줄: "총 X문제 중"
        let totalQuestions = NSAttributedString(
            string: "총 \(totalAnswers)문제 중\n",
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                .foregroundColor: UIColor.darkGray,
                .paragraphStyle: paragraphStyle,
            ]
        )
        attributedText.append(totalQuestions)

        // 두 번째 줄: 숫자와 % 크기 조정
        let percentageValue = NSAttributedString(
            string: "\(Int(correctPercentage))",
            attributes: [
                .font: UIFont.systemFont(ofSize: 36, weight: .bold),
                .foregroundColor: UIColor.black,
                .paragraphStyle: paragraphStyle,
            ]
        )
        let percentageSymbol = NSAttributedString(
            string: "%",
            attributes: [
                .font: UIFont.systemFont(ofSize: 18, weight: .medium),  // 상대적으로 작은 크기
                .foregroundColor: UIColor.black,
                .paragraphStyle: paragraphStyle,
            ]
        )
        attributedText.append(percentageValue)
        attributedText.append(percentageSymbol)
        attributedText.append(NSAttributedString(string: "\n"))  // 줄바꿈 추가

        // 세 번째 줄: "정답"
        let correctText = NSAttributedString(
            string: "정답",
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                .foregroundColor: UIColor.darkGray,
                .paragraphStyle: paragraphStyle,
            ]
        )
        attributedText.append(correctText)

        self.scoreLabel.attributedText = attributedText

        // `correctWrongView` 업데이트
        if let correctLabel = self.correctWrongView.arrangedSubviews.first
            as? UILabel
        {
            let correctAttributedText = NSMutableAttributedString()
            correctAttributedText.append(
                NSAttributedString(
                    string: "맞은문제\n",
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                        .foregroundColor: UIColor.darkGray,
                    ]
                ))
            correctAttributedText.append(
                NSAttributedString(
                    string: "\(correctAnswers)",
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 32, weight: .bold),
                        .foregroundColor: UIColor.systemBlue,
                    ]
                ))
            correctLabel.attributedText = correctAttributedText
        }

        if let wrongLabel = self.correctWrongView.arrangedSubviews.last
            as? UILabel
        {
            let wrongAttributedText = NSMutableAttributedString()
            wrongAttributedText.append(
                NSAttributedString(
                    string: "틀린문제\n",
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                        .foregroundColor: UIColor.darkGray,
                    ]
                ))
            wrongAttributedText.append(
                NSAttributedString(
                    string: "\(incorrectAnswers)",
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 32, weight: .bold),
                        .foregroundColor: UIColor.systemRed,
                    ]
                ))
            wrongLabel.attributedText = wrongAttributedText
        }
        var value = correctPercentage / 100
        value = floor(value * 10) / 10  // 소수점 첫째 자리까지만 남기기
        print("============> \(value)")
        self.updateProgress(to: value, animated: true)
    }

}
