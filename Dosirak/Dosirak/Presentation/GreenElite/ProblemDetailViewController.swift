//
//  ProblemDetailViewController.swift
//  Dosirak
//
//  Created by 권민재 on 11/30/24.
//
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ProblemDetailViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let viewModel = GreenEliteViewModel()
    private var problemId: Int?
    var correctAnswer: Bool? // 정답 여부
    
    // MARK: - Configure
    func configure(with problemId: Int) {
        self.problemId = problemId
    }
    
    // MARK: - UI Components
    private let problemContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        return view
    }()
    
    private let problemLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private let problemTagLabel: UILabel = {
        let label = UILabel()
        label.text = "문제"
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = UIColor.systemGreen
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        return label
    }()
    
    private let resultContainerView: UIView = UIView()
    
    private let resultTextLabel: UILabel = {
        let label = UILabel()
        label.text = "정답:"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private let resultImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let userChoiceLabel: UILabel = {
        let label = UILabel()
        label.text = "내가 고른 답"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.layer.backgroundColor = UIColor.systemGray5.cgColor
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        return label
    }()
    
    private let correctButton: UIButton = {
        let button = UIButton()
        button.setTitle("O", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.backgroundColor = UIColor(hexCode: "006ae6")
        button.layer.cornerRadius = 12
        return button
    }()
    
    private let wrongButton: UIButton = {
        let button = UIButton()
        button.setTitle("X", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.backgroundColor = UIColor(hexCode: "ff4949")
        button.layer.cornerRadius = 12
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        fetchProblemDetail()
    }
    
    // MARK: - UI Setup
    private func setupView() {
        view.backgroundColor = .systemGray6
        title = correctAnswer == true ? "맞은 문제" : "틀린 문제"
        
        view.addSubview(problemContainerView)
        problemContainerView.addSubview(problemLabel)
        problemContainerView.addSubview(problemTagLabel)
        problemContainerView.addSubview(resultContainerView)
        resultContainerView.addSubview(resultTextLabel)
        resultContainerView.addSubview(resultImageView)
        resultContainerView.addSubview(userChoiceLabel)
        view.addSubview(correctButton)
        view.addSubview(wrongButton)
    }
    
    private func setupConstraints() {
        problemContainerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(580)
        }
        
        problemTagLabel.snp.makeConstraints { make in
            make.top.equalTo(problemContainerView).offset(16)
            make.leading.equalTo(problemContainerView).offset(16)
            make.width.equalTo(50)
            make.height.equalTo(30)
        }
        
        problemLabel.snp.makeConstraints { make in
            make.top.equalTo(problemTagLabel.snp.bottom).offset(16)
            make.leading.trailing.equalTo(problemContainerView).inset(20)
        }
        
        resultContainerView.snp.makeConstraints { make in
            make.top.equalTo(problemLabel.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.height.equalTo(100)
        }
        
        resultTextLabel.snp.makeConstraints { make in
            make.top.equalTo(resultContainerView)
            make.centerX.equalTo(resultContainerView)
        }
        
        resultImageView.snp.makeConstraints { make in
            make.top.equalTo(resultTextLabel.snp.bottom).offset(10)
            make.centerX.equalTo(resultContainerView)
            make.width.height.equalTo(50)
        }
        
        userChoiceLabel.snp.makeConstraints { make in
            make.top.equalTo(resultImageView.snp.bottom).offset(10)
            make.centerX.equalTo(resultContainerView)
            make.height.equalTo(20)
            make.width.equalTo(100)
        }
        
        correctButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.leading.equalToSuperview().offset(30)
            make.height.equalTo(60)
            make.width.equalTo((UIScreen.main.bounds.width - 90) / 2)
        }
        
        wrongButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.trailing.equalToSuperview().offset(-30)
            make.height.equalTo(60)
            make.width.equalTo((UIScreen.main.bounds.width - 90) / 2)
        }
    }
    
    // MARK: - Fetch Problem Detail
    private func fetchProblemDetail() {
        guard let problemId = problemId else { return }
        
        viewModel.fetchProblemDetail(problemId: problemId)
            .subscribe(onSuccess: { [weak self] problem in
                self?.updateUI(with: problem)
            }, onFailure: { error in
                print("Failed to fetch problem detail: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    private func updateUI(with problem: TodayProblem) {
        problemLabel.text = problem.description

        // 정답 확인: problem.answer에 따라 정답 텍스트 및 이미지 설정
        let isCorrectAnswer = problem.answer == "TRUE" // TRUE면 정답이 "O", FALSE면 정답이 "X"
        resultTextLabel.text = "정답:"
        resultImageView.image = UIImage(named: isCorrectAnswer ? "정답" : "오답") // 정답 표시 이미지

        
        var userChoice = ""
        // 내가 고른 답 계산
        if let correctAnswer = correctAnswer {
            // 사용자가 고른 답은 correctAnswer와 problem.answer로 계산
            userChoice = correctAnswer == isCorrectAnswer ? "O" : "X"
            userChoiceLabel.text = "내가 고른 답: \(userChoice)"
        } else {
            userChoiceLabel.text = "내가 고른 답: 없음"
        }

        // 버튼 상태 업데이트
        updateButtons(userChoice: userChoice)
    }

    private func updateButtons(userChoice: String) {
        // 내가 고른 답에 따라 버튼 활성화/비활성화 설정
        if userChoice == "O" {
            correctButton.isEnabled = true
            wrongButton.isEnabled = false
        } else if userChoice == "X" {
            correctButton.isEnabled = false
            wrongButton.isEnabled = true
        }

        // 버튼 색상 설정 (활성화된 버튼은 원래 색상, 비활성화된 버튼은 lightGray)
        correctButton.backgroundColor = correctButton.isEnabled ? UIColor(hexCode: "006ae6") : .lightGray
        wrongButton.backgroundColor = wrongButton.isEnabled ? UIColor(hexCode: "ff4949") : .lightGray
    }




}
