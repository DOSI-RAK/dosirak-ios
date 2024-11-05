//
//  GreenCommitViewController.swift
//  Dosirak
//
//  Created by 권민재 on 11/4/24.
//
import UIKit
import FSCalendar
import SnapKit

class GreenCommitViewController: UIViewController {
    
    // MARK: - Properties
    private let collectionView: UICollectionView
    private var selectedDateRecords: [String] = [] // 선택된 날짜의 기록들
    
    // MARK: - Initializer
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        
        // 오늘 날짜의 데이터를 디폴트로 설정
        let today = Date()
        selectedDateRecords = fetchRecords(for: today)
        collectionView.reloadData()
    }
    
    // MARK: - Setup Views
    private func setupViews() {
        view.backgroundColor = .bgColor
        view.addSubview(collectionView)
        
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // 헤더와 셀 등록
        collectionView.register(GreenCommitHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: GreenCommitHeaderView.identifier)
        collectionView.register(GreenCommitCell.self, forCellWithReuseIdentifier: GreenCommitCell.reusableIdentifier)
    }
    
    // MARK: - Layout
    private func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // 선택된 날짜에 대한 더미 데이터를 가져오는 메서드
    private func fetchRecords(for date: Date) -> [String] {
        // 예시 데이터 - 실제 데이터로 대체하세요.
        let records = [
            "다회용기 포장 인증",
            "저탄소 이동수단 인증",
            "플라스틱 없는 날 인증",
            "자전거 타기 인증",
        
            
        ]
        return records.shuffled() // 더미 데이터 반환
    }
}

// MARK: - UICollectionView DataSource & DelegateFlowLayout
extension GreenCommitViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedDateRecords.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GreenCommitCell.reusableIdentifier, for: indexPath) as! GreenCommitCell
        let record = selectedDateRecords[indexPath.item]
        let imageName = Bool.random() ? "footprint" : "box" // 더미 이미지를 랜덤으로 설정
        cell.configure(title: record, imageName: imageName)
        cell.backgroundColor = .white
        cell.layer.cornerRadius = 13
        return cell
    }
    
    // 섹션 헤더에 Calendar 헤더 뷰 추가
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: GreenCommitHeaderView.identifier, for: indexPath) as! GreenCommitHeaderView
            headerView.calendar.delegate = self // FSCalendar의 delegate 설정
            headerView.calendar.select(Date()) // 기본으로 오늘 날짜 선택 표시
            return headerView
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 400) // Calendar 높이 설정
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 40, height: 50) // 셀 크기 설정
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 20, bottom: 20, right: 20)
    }
}

// MARK: - FSCalendar Delegate
extension GreenCommitViewController: FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // 날짜를 선택할 때마다 더미 데이터를 가져와 selectedDateRecords를 갱신
        selectedDateRecords = fetchRecords(for: date)
        collectionView.reloadData() // 데이터를 갱신한 후 컬렉션 뷰를 리로드
    }
}
