//
//  ProblemListViewController.swift
//  Dosirak
//
//  Created by 권민재 on 11/29/24.
//
import UIKit
import RxSwift
import RxCocoa
import SnapKit

enum correctType {
    case correct
    case incorrect
}

class ProblemListViewController: UIViewController, UITableViewDelegate {
    
    private let disposeBag = DisposeBag()
    private let viewModel = GreenEliteViewModel()
    
    var type: correctType = .correct
    
    // UI Components
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    private let correctButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("맞은문제", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 20
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        return button
    }()
    
    private let incorrectButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("틀린문제", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 20
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        return button
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [correctButton, incorrectButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }()
    
    // Data Source
    private let correctProblems = BehaviorRelay<[Problem]>(value: [])
    private let incorrectProblems = BehaviorRelay<[Problem]>(value: [])
    private let currentProblems = BehaviorRelay<[Problem]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        setupTableViewDelegate()
    }
    
    private func setupUI() {
        view.backgroundColor = .bgColor
        
        title = "문제 확인"
        
        view.addSubview(buttonStackView)
        view.addSubview(tableView)
        
        tableView.backgroundColor = .bgColor
        
        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(buttonStackView.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        tableView.register(CustomProblemCell.self, forCellReuseIdentifier: "ProblemCell")
        tableView.separatorStyle = .none
    }
    
    private func bindViewModel() {
        let accessToken = AppSettings.accessToken ?? ""
        
        viewModel.fetchCorrectAnswers(accessToken: accessToken)
            .subscribe(onSuccess: { [weak self] correctProblems in
                self?.correctProblems.accept(correctProblems)
                self?.currentProblems.accept(correctProblems) // Default to correct problems
            })
            .disposed(by: disposeBag)
        
        viewModel.fetchIncorrectAnswers(accessToken: accessToken)
            .subscribe(onSuccess: { [weak self] incorrectProblems in
                self?.incorrectProblems.accept(incorrectProblems)
            })
            .disposed(by: disposeBag)
        
        currentProblems
            .bind(to: tableView.rx.items(cellIdentifier: "ProblemCell", cellType: CustomProblemCell.self)) { _, problem, cell in
                cell.configure(with: problem)
            }
            .disposed(by: disposeBag)
        
        correctButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.updateButtonUI(selectedButton: self?.correctButton, deselectedButton: self?.incorrectButton)
                self?.currentProblems.accept(self?.correctProblems.value ?? [])
                self?.type = .correct
            })
            .disposed(by: disposeBag)
        
        incorrectButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.updateButtonUI(selectedButton: self?.incorrectButton, deselectedButton: self?.correctButton)
                self?.currentProblems.accept(self?.incorrectProblems.value ?? [])
                self?.type = .incorrect
            })
            .disposed(by: disposeBag)
    }
    
    private func updateButtonUI(selectedButton: UIButton?, deselectedButton: UIButton?) {
        selectedButton?.backgroundColor = .black
        selectedButton?.setTitleColor(.white, for: .normal)
        
        deselectedButton?.backgroundColor = .white
        deselectedButton?.setTitleColor(.black, for: .normal)
    }
    
    private func setupTableViewDelegate() {
        tableView.delegate = self
        
        tableView.rx.modelSelected(Problem.self)
            .subscribe(onNext: { [weak self] selectedProblem in
                guard let self = self else { return }
                // ProblemDetailViewController 생성 및 문제 ID 전달
                let detailVC = ProblemDetailViewController()
                detailVC.configure(with: selectedProblem.problemId)
                if type == .correct {
                    detailVC.correctAnswer = true
                } else {
                    detailVC.correctAnswer = false
                }
                self.navigationController?.pushViewController(detailVC, animated: true)
            })
            .disposed(by: disposeBag)
    }
  
    // MARK: - UITableViewDelegate
    
    // Setting cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    // Adding space between cells
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .clear
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 15 // Space between cells
    }
}


class CustomProblemCell: UITableViewCell {
    
    private let problemIndicator: UILabel = {
        let label = UILabel()
        label.text = "Q."
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .mainColor
        return label
    }()
    
    private let problemLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.numberOfLines = 2
        return label
    }()
  
    
    private let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(problemIndicator)
        contentView.addSubview(problemLabel)
        contentView.addSubview(separatorLine)
        
        
        
        problemIndicator.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(24)
        }
        
        problemLabel.snp.makeConstraints { make in
            make.leading.equalTo(problemIndicator.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        
        separatorLine.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    func configure(with problem: Problem) {
        problemLabel.text = problem.problemDesc
    }
}
