//
//  ProblemListViewController.swift
//  Dosirak
//
//  Created by 권민재 on 11/29/24.
//
import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ProblemListViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let viewModel = GreenEliteViewModel()
    
    // UI Components
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["맞은문제", "틀린문제"])
        control.selectedSegmentIndex = 0
        control.backgroundColor = .white
        control.selectedSegmentTintColor = .black
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        control.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        return control
    }()
    
    // Data Source
    private let correctProblems = BehaviorRelay<[String]>(value: [])
    private let incorrectProblems = BehaviorRelay<[String]>(value: [])
    private let currentProblems = BehaviorRelay<[String]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "문제 확인"
        
        view.addSubview(segmentedControl)
        view.addSubview(tableView)
        
        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ProblemCell")
        tableView.separatorStyle = .none
    }
    
    private func bindViewModel() {
        // Fetch correct and incorrect problems
        let accessToken = AppSettings.accessToken ?? ""
        
        // 맞은 문제 데이터 바인딩
        viewModel.fetchCorrectAnswers(accessToken: accessToken)
            .subscribe(onSuccess: { [weak self] correctProblems in
                guard let self = self else { return }
                self.correctProblems.accept(correctProblems.map { $0.problemDesc }) // 문제 설명만 추출
                self.currentProblems.accept(self.correctProblems.value) // 초기 데이터 설정
            }, onFailure: { error in
                print("Failed to fetch correct problems: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
        
        // 틀린 문제 데이터 바인딩
        viewModel.fetchIncorrectAnswers(accessToken: accessToken)
            .subscribe(onSuccess: { [weak self] incorrectProblems in
                self?.incorrectProblems.accept(incorrectProblems.map { $0.problemDesc }) // 문제 설명만 추출
            }, onFailure: { error in
                print("Failed to fetch incorrect problems: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
        
        // Bind tableView data to the selected segment
        currentProblems
            .bind(to: tableView.rx.items(cellIdentifier: "ProblemCell", cellType: UITableViewCell.self)) { _, element, cell in
                cell.textLabel?.text = element
                cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
                cell.textLabel?.textColor = .black
                cell.textLabel?.numberOfLines = 1
            }
            .disposed(by: disposeBag)
        
        // Switch data based on the selected segment
        segmentedControl.rx.selectedSegmentIndex
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                if index == 0 {
                    self.currentProblems.accept(self.correctProblems.value)
                } else {
                    self.currentProblems.accept(self.incorrectProblems.value)
                }
            })
            .disposed(by: disposeBag)
    }
}

