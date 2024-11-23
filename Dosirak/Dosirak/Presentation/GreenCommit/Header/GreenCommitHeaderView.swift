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
    // 페이지 변경 콜백
    var onPageChanged: ((Date) -> Void)?

    // MARK: - UI Components
    private let calendar: FSCalendar = {
        let view = FSCalendar()
        view.locale = Locale(identifier: "ko_KR")
        view.backgroundColor = .mainColor
        view.headerHeight = 0
        view.layer.cornerRadius = 20
        view.appearance.weekdayTextColor = .white
        view.appearance.titleFont = UIFont.systemFont(ofSize: 14)
        view.appearance.subtitleFont = UIFont.systemFont(ofSize: 12)
        view.appearance.todayColor = .clear
        view.appearance.selectionColor = .clear
        view.register(CalendarCell.self, forCellReuseIdentifier: "calendarCell")
        return view
    }()

    private let headerContainerView = UIView()

    private let monthLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.textColor = .white
        label.backgroundColor = .black
        label.layer.cornerRadius = 17
        label.clipsToBounds = true
        return label
    }()

    private let prevButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "left"), for: .normal)
        button.tintColor = .white
        return button
    }()

    private let nextButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "right"), for: .normal)
        button.tintColor = .white
        return button
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
        addSubview(headerContainerView)
        addSubview(calendar)

        headerContainerView.addSubview(monthLabel)
        headerContainerView.addSubview(prevButton)
        headerContainerView.addSubview(nextButton)

        calendar.dataSource = self
        calendar.delegate = self
    }

    private func setupConstraints() {
        headerContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }

        monthLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(34)
        }

        prevButton.snp.makeConstraints { make in
            make.centerY.equalTo(monthLabel)
            make.trailing.equalTo(monthLabel.snp.leading).offset(-10)
            make.width.height.equalTo(30)
        }

        nextButton.snp.makeConstraints { make in
            make.centerY.equalTo(monthLabel)
            make.leading.equalTo(monthLabel.snp.trailing).offset(10)
            make.width.height.equalTo(30)
        }

        calendar.snp.makeConstraints { make in
            make.top.equalTo(headerContainerView.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview().inset(20)
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

    // MARK: - Update Month Label
    private func updateMonthLabel() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM"
        monthLabel.text = formatter.string(from: calendar.currentPage)
    }

    // MARK: - FSCalendar DataSource & Delegate
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        onDateSelected?(date)
    }

    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        updateMonthLabel()
        onPageChanged?(calendar.currentPage)
    }

    func calendar(_ calendar: FSCalendar, cellFor date: Date, at monthPosition: FSCalendarMonthPosition) -> FSCalendarCell {
        guard let cell = calendar.dequeueReusableCell(withIdentifier: "calendarCell", for: date, at: monthPosition) as? CalendarCell else {
            return FSCalendarCell()
        }

        if monthPosition == .current {
            let day = Calendar.current.component(.day, from: date)
            let imageName = getImageName(for: date)
            let commitCount = getCommitCount(for: date)
            cell.configure(day: "\(day)", imageName: imageName, commitCount: commitCount)
        } else {
            cell.configure(day: "", imageName: nil, commitCount: nil)
        }

        return cell
    }

    // MARK: - Helpers
    private func getImageName(for date: Date) -> String? {
        if let commitCount = getCommitCount(for: date) {
            switch commitCount {
            case 0:
                return "commit_0"
            case 1...5:
                return "commit_1"
            case 6...10:
                return "commit_2"
            default:
                return "commit_3"
            }
        }
        return nil
    }

    private func getCommitCount(for date: Date) -> Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)

        return monthlyCommits.first(where: { $0.createdAt == dateString })?.commitCount
    }
}

extension GreenCommitHeaderView: FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, sizeFor date: Date) -> CGSize {
        return CGSize(width: 40, height: 50)
    }
}
