//
//  TodayProblemViewController.swift
//  Dosirak
//
//  Created by 권민재 on 11/24/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class TodayProblemViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let viewModel = GreenEliteViewModel()
    
    
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
        label.text = "음료수 캔은 깨끗이 헹구지 않아도 재활용할 수 있다."
        label.font = UIFont.systemFont(ofSize: 25, weight: .medium)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .left
        //label.backgroundColor = .red
        return label
    }()
    
    private let problemTagLabel: UILabel = {
        let label = UILabel()
        label.text = "문제"
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = .mainColor
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        return label
    }()
    
    private let correctButton: UIButton = {
        let button = UIButton()
        button.setTitle("O", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        button.backgroundColor = UIColor(hexCode: "006ae6")
        button.layer.cornerRadius = 12
        return button
    }()
    
    private let wrongButton: UIButton = {
        let button = UIButton()
        button.setTitle("X", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        button.backgroundColor = UIColor(hexCode: "ff4949")
        button.layer.cornerRadius = 12
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        
        bindViewModel()
    }
    
    private func setupView() {
        view.backgroundColor = .systemGray6
        title = "오늘의 문제"
        
        view.addSubview(problemContainerView)
        problemContainerView.addSubview(problemLabel)
        problemContainerView.addSubview(problemTagLabel)
        view.addSubview(correctButton)
        view.addSubview(wrongButton)
    }
    
    private func setupConstraints() {
        problemContainerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
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
            make.top.equalTo(problemTagLabel.snp.bottom).offset(16) // 문제 라벨을 문제 태그 아래로 배치
            make.leading.trailing.equalTo(problemContainerView).inset(20)
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
    
    private func bindViewModel() {
           // 문제 데이터 가져오기
           viewModel.fetchTodayProblem(accessToken: AppSettings.accessToken ?? "")
               .subscribe(onSuccess: { [weak self] problem in
                   guard let self = self else { return }
                   self.problemLabel.text = problem.description // 문제 텍스트 업데이트
               }, onFailure: { error in
                   print("Failed to fetch today's problem: \(error.localizedDescription)")
               })
               .disposed(by: disposeBag)
           
           // O 버튼 클릭 이벤트
           correctButton.rx.tap
               .bind { [weak self] in
                   guard let self = self else { return }
                   self.handleAnswer(isCorrect: true)
               }
               .disposed(by: disposeBag)
           
           // X 버튼 클릭 이벤트
           wrongButton.rx.tap
               .bind { [weak self] in
                   guard let self = self else { return }
                   self.handleAnswer(isCorrect: false)
               }
               .disposed(by: disposeBag)
       }
       
    private func handleAnswer(isCorrect: Bool) {
        guard let problem = viewModel.todayProblem.value else {
            print("No problem data available")
            return
        }
        
        // 서버에서 받은 정답과 사용자의 답변 비교
        let correctAnswer = problem.answer // "TRUE" 또는 "FALSE"
        let isAnswerCorrect = isCorrect.description.uppercased() == correctAnswer
        
        // 서버로 정답 여부 기록
        viewModel.recordAnswer(
            accessToken: AppSettings.accessToken ?? "",
            problemId: problem.id,
            isCorrect: isAnswerCorrect // 서버로 전달할 값
        )
        .subscribe(onSuccess: { [weak self] in
            guard let self = self else { return }
            // 성공 시 메시지 표시
            let message = isAnswerCorrect ? "정답입니다!" : "오답입니다!"
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }, onFailure: { [weak self] error in
            guard let self = self else { return }
            // 실패 시 메시지 표시
            print("Failed to record answer: \(error.localizedDescription)")
            let alert = UIAlertController(title: "오류", message: "서버에 정답을 기록하지 못했습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        })
        .disposed(by: disposeBag)
    }

    
}
