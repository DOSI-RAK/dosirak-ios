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
    private let viewModel = GreenCommitViewModel()

    private var todayCommits: [CommitActivity] = []
    private var dayCommits: [CommitActivity] = []
    private let accessToken = AppSettings.accessToken

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 460)
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
        
        DispatchQueue.main.async {
        
            self.loadTodayCommits()
            self.loadMonthlyCommits(for: Date())
        }
        
    }
    private func setupViews() {
        view.backgroundColor = .bgColor
        view.addSubview(collectionView)

        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(GreenCommitCell.self, forCellWithReuseIdentifier: GreenCommitCell.reusableIdentifier)
        collectionView.register(EmptyCell.self, forCellWithReuseIdentifier: EmptyCell.reusableIdentifier)
        collectionView.register(GreenCommitHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: GreenCommitHeaderView.identifier)
    }

    private func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func loadTodayCommits() {
        
        viewModel.fetchTodayCommits(accessToken: accessToken ?? "") { [weak self] result in
            switch result {
            case .success(let commits):
                self?.todayCommits = commits
                self?.collectionView.reloadData()
            case .failure(let error):
                print("오늘 데이터 로드 실패:", error)
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
                print("일별 데이터 로드 실패:", error)
            }
        }
    }

    private func loadMonthlyCommits(for month: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        let monthString = formatter.string(from: month)

        viewModel.fetchMonthlyCommits(accessToken: accessToken ?? "", month: monthString) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let commits):
                    print("월별 데이터 로드 성공: \(commits.count)개")
                    self?.viewModel.monthlyCommits = commits

                    if let headerView = self?.collectionView.supplementaryView(
                        forElementKind: UICollectionView.elementKindSectionHeader,
                        at: IndexPath(item: 0, section: 0)
                    ) as? GreenCommitHeaderView {
                        headerView.monthlyCommits = commits
                    }
                case .failure(let error):
                    print("월별 데이터 로드 실패: \(error)")
                }
            }
        }
    }
    
    
    func captureView(view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        view.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func shareToInstagramStory(image: UIImage) {
        let pasteboardItems: [[String: Any]] = [
            [
                "com.instagram.sharedSticker.backgroundImage": image.pngData()!,
                "com.instagram.sharedSticker.appID": "YOUR_APP_ID" // 앱 ID (Facebook 개발자 콘솔에서 생성)
            ]
        ]
        
        let pasteboardOptions: [UIPasteboard.OptionsKey: Any] = [
            .expirationDate: Date().addingTimeInterval(60 * 5) // 5분간 유효
        ]
        
        // Pasteboard에 데이터 추가
        UIPasteboard.general.setItems(pasteboardItems, options: pasteboardOptions)
        
        // Instagram 스토리 열기
        let instagramURL = URL(string: "instagram-stories://share")!
        if UIApplication.shared.canOpenURL(instagramURL) {
            UIApplication.shared.open(instagramURL, options: [:], completionHandler: nil)
        } else {
            print("Instagram이 설치되어 있지 않습니다.")
        }
    }


    
    
    
    
    
    

    // MARK: - UICollectionView DataSource & Delegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if todayCommits.isEmpty && dayCommits.isEmpty {
            return 1
        }
        return dayCommits.isEmpty ? todayCommits.count : dayCommits.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if todayCommits.isEmpty && dayCommits.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyCell.reusableIdentifier, for: indexPath) as! EmptyCell
            return cell
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GreenCommitCell.reusableIdentifier, for: indexPath) as! GreenCommitCell
        let commit = dayCommits.isEmpty ? todayCommits[indexPath.item] : dayCommits[indexPath.item]
        cell.configure(commit: commit)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 40, height: 50)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: GreenCommitHeaderView.identifier, for: indexPath) as! GreenCommitHeaderView
            
         
            headerView.onPageChanged = { [weak self] month in
                self?.loadMonthlyCommits(for: month)
            }

         
            headerView.onDateSelected = { [weak self] date in
                self?.loadDayCommits(for: date)
            }

        
            headerView.monthlyCommits = viewModel.monthlyCommits
            return headerView
        }
        return UICollectionReusableView()
    }
}
