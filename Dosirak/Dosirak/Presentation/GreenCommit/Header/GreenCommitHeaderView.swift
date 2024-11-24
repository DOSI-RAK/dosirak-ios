//
//  GreenCommitHeaderView.swift
//  Dosirak
//
//  Created by 권민재 on 11/5/24.
//
import FSCalendar
import UIKit
import SnapKit

class GreenCommitHeaderView: UICollectionReusableView, FSCalendarDataSource, FSCalendarDelegate {
    static let identifier = "GreenCommitHeaderView"

    // 외부에서 주입받을 월간 커밋 데이터
    var monthlyCommits: [MonthCommit] = [] {
        didSet {
            calendar.reloadData() // 데이터 업데이트 시 캘린더 리로드
        }
    }

    // 날짜 선택 콜백
    var onDateSelected: ((Date) -> Void)?
    var onPageChanged: ((Date) -> Void)?

    // MARK: - UI Components
    private let headerView = UIView()
    private let monthLabel = UILabel()
    private let prevButton = UIButton()
    private let nextButton = UIButton()

    let calendar: FSCalendar = {
        let view = FSCalendar()
        view.locale = Locale(identifier: "ko_KR")
        view.backgroundColor = .mainColor
        view.layer.cornerRadius = 20
        //view.appearance.headerMinimumDissolvedAlpha = 0
        view.appearance.titleFont = UIFont.systemFont(ofSize: 14, weight: .medium)
        view.appearance.subtitleFont = UIFont.systemFont(ofSize: 12)
        view.appearance.todayColor = .clear
        view.appearance.selectionColor = .clear
        view.appearance.weekdayTextColor = .white
        view.appearance.titleDefaultColor = .white
        view.appearance.headerMinimumDissolvedAlpha = 0
        view.appearance.headerDateFormat = ""
        return view
    }()

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        setupActions()
        updateMonthLabel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup Views
    private func setupViews() {
        addSubview(headerView)
        headerView.addSubview(monthLabel)
        headerView.addSubview(prevButton)
        headerView.addSubview(nextButton)
        addSubview(calendar)

        // Month Label
        monthLabel.textAlignment = .left
        monthLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        monthLabel.textColor = .white
        monthLabel.backgroundColor = .black
        monthLabel.layer.cornerRadius = 14
        monthLabel.textAlignment = .center
        monthLabel.clipsToBounds = true

        // Prev Button
        prevButton.setImage(UIImage(named: "left"), for: .normal)
        prevButton.tintColor = .black

        // Next Button
        nextButton.setImage(UIImage(named: "right"), for: .normal)
        nextButton.tintColor = .black

        // Calendar
        calendar.dataSource = self
        calendar.delegate = self
    }

    private func setupConstraints() {
        // Header View
        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }

        // Month Label
        monthLabel.snp.makeConstraints { make in
            make.centerY.equalTo(headerView)
            make.leading.equalToSuperview()
            make.width.equalTo(80)
            make.height.equalTo(34)
        }

        // Prev Button
        prevButton.snp.makeConstraints { make in
            make.centerY.equalTo(headerView)
            make.trailing.equalTo(nextButton.snp.leading).offset(-10)
            make.width.height.equalTo(30)
        }

        // Next Button
        nextButton.snp.makeConstraints { make in
            make.centerY.equalTo(headerView)
            make.trailing.equalToSuperview()
            make.width.height.equalTo(30)
        }

        // Calendar
        calendar.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }
    }

    private func setupActions() {
        prevButton.addTarget(self, action: #selector(didTapPrevButton), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
    }

    // MARK: - Button Actions
    @objc private func didTapPrevButton() {
        if let prevMonth = Calendar.current.date(byAdding: .month, value: -1, to: calendar.currentPage) {
            calendar.setCurrentPage(prevMonth, animated: true)
            updateMonthLabel()
            onPageChanged?(prevMonth)
        }
    }

    @objc private func didTapNextButton() {
        if let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: calendar.currentPage) {
            calendar.setCurrentPage(nextMonth, animated: true)
            updateMonthLabel()
            onPageChanged?(nextMonth)
        }
    }

    private func updateMonthLabel() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM"
        monthLabel.text = formatter.string(from: calendar.currentPage)
    }

    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)

        if let commit = monthlyCommits.first(where: { $0.createdAt == dateString }) {
            switch commit.commitCount {
            case 0:
                return UIImage(named: "0")
            case 1:
                return UIImage(named: "1")
            case 2:
                return UIImage(named: "2")
            default:
                return UIImage(named: "3")
            }
        }

        // 기본 이미지를 반환
        return UIImage(named: "0")
    } 
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        onDateSelected?(date)
    }

    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        updateMonthLabel()
        onPageChanged?(calendar.currentPage)
    }
}
