//
//  GreenCommitViewController.swift
//  Dosirak
//
//  Created by 권민재 on 11/4/24.
//
import UIKit
import SnapKit

class GreenCommitViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private let collectionView: UICollectionView
    private let headerView: GreenCommitHeaderView
    private let viewModel = GreenCommitViewModel()

    private var todayCommits: [CommitActivity] = []
    private var dayCommits: [CommitActivity] = []
    private let accessToken = AppSettings.accessToken

    init() {
        self.headerView = GreenCommitHeaderView()

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Green Commit"
        setupViews()
        setupConstraints()
        setupHeaderCallbacks()
        loadTodayCommits() // 기본적으로 오늘 데이터를 로드
    }

    private func setupViews() {
        view.backgroundColor = .bgColor
        view.addSubview(headerView)
        view.addSubview(collectionView)

        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(GreenCommitCell.self, forCellWithReuseIdentifier: GreenCommitCell.reusableIdentifier)
    }

    private func setupConstraints() {
        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(400)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func setupHeaderCallbacks() {
        // 날짜 선택 이벤트
        headerView.onDateSelected = { [weak self] date in
            self?.loadDayCommits(for: date)
        }

        // 월 변경 이벤트
        headerView.onPageChanged = { [weak self] month in
            self?.loadMonthlyCommits(for: month)
        }
    }

    // MARK: - Data Loading Methods

    private func loadTodayCommits() {
        viewModel.fetchTodayCommits(accessToken: accessToken ?? "") { [weak self] result in
            switch result {
            case .success(let commits):
                self?.todayCommits = commits
                self?.collectionView.reloadData()
            case .failure(let error):
                print("데이터가 없스비다.")
            }
        }
    }

    private func loadDayCommits(for date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)

        viewModel.fetchDayCommits(accessToken: accessToken ?? "", date: dateString) { [weak self] result in
            switch result {
            case .success(let commits):
                self?.dayCommits = commits
                self?.collectionView.reloadData()
            case .failure(let error):
                print("데이터가 없스비다.")
            }
        }
    }

    private func loadMonthlyCommits(for month: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        let monthString = formatter.string(from: month)

        viewModel.fetchMonthlyCommits(accessToken: accessToken ?? "", month: monthString) { [weak self] result in
            switch result {
            case .success(let commits):
                self?.headerView.monthlyCommits = commits
            case .failure(let error):
                print("데이터가 없스비다.")
            }
        }
    }


    // MARK: - UICollectionView DataSource & Delegate

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dayCommits.isEmpty ? todayCommits.count : dayCommits.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GreenCommitCell.reusableIdentifier, for: indexPath) as! GreenCommitCell
        let commit = dayCommits.isEmpty ? todayCommits[indexPath.item] : dayCommits[indexPath.item]
        print("Configuring cell with CommitActivity:", commit) // 데이터 디버깅
        cell.configure(commit: commit)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 40, height: 50)
    }
}
