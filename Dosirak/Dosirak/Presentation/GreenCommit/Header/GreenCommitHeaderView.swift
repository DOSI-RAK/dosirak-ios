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
    
    let calendar: FSCalendar = {
        let view = FSCalendar()
        view.locale = Locale(identifier: "ko_KR")
        view.backgroundColor = .mainColor
        view.headerHeight = 0
        view.layer.cornerRadius = 20
        view.tintColor = .white
        view.scope = .month
        view.appearance.weekdayTextColor = .white
        view.appearance.titleFont = UIFont.systemFont(ofSize: 14)
        view.appearance.subtitleFont = UIFont.systemFont(ofSize: 12)
        view.appearance.borderRadius = 0.5
        view.register(CalendarCell.self, forCellReuseIdentifier: "calendarCell")
        view.appearance.todayColor = .clear
        view.appearance.selectionColor = .clear
        view.weekdayHeight = 18
        view.adjustsBoundingRectWhenChangingMonths = true
        return view
    }()
    
    private let headerView = UIView()
    private let monthLabel = UILabel()
    private let prevButton = UIButton()
    private let nextButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHeader()
        setupCalendar()
        updateMonthLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupHeader() {
        addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        prevButton.setImage(UIImage(named: "left"), for: .normal)
        prevButton.tintColor = .black
        prevButton.addTarget(self, action: #selector(didTapPrevButton), for: .touchUpInside)
        headerView.addSubview(prevButton)
        
        nextButton.setImage(UIImage(named: "right"), for: .normal)
        nextButton.tintColor = .black
        nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        headerView.addSubview(nextButton)
     
        monthLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        monthLabel.textColor = .white
        monthLabel.backgroundColor = .black
        monthLabel.textAlignment = .center
        monthLabel.layer.cornerRadius = 17
        monthLabel.clipsToBounds = true
        headerView.addSubview(monthLabel)
        
        monthLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalTo(87)
            make.height.equalTo(38)
        }
        
        nextButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalTo(monthLabel)
            make.width.height.equalTo(52)
        }
        
        prevButton.snp.makeConstraints { make in
            make.centerY.equalTo(monthLabel)
            make.width.height.equalTo(52)
            make.trailing.equalTo(nextButton.snp.leading)
        }
    }
    
    private func setupCalendar() {
        addSubview(calendar)
        calendar.dataSource = self
        calendar.delegate = self
        calendar.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)//.offset(10)
            $0.leading.equalTo(self).inset(20)
            $0.trailing.equalTo(self).inset(20)
            $0.height.equalTo(400)
        }
    }
    
    private func updateMonthLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM"
        monthLabel.text = dateFormatter.string(from: calendar.currentPage)
    }
    
    @objc private func didTapPrevButton() {
        let prevMonth = Calendar.current.date(byAdding: .month, value: -1, to: calendar.currentPage) ?? calendar.currentPage
        calendar.setCurrentPage(prevMonth, animated: true)
        updateMonthLabel()
    }
    
    @objc private func didTapNextButton() {
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: calendar.currentPage) ?? calendar.currentPage
        calendar.setCurrentPage(nextMonth, animated: true)
        updateMonthLabel()
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        updateMonthLabel()
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at monthPosition: FSCalendarMonthPosition) -> FSCalendarCell {
        guard let cell = calendar.dequeueReusableCell(withIdentifier: "calendarCell", for: date, at: monthPosition) as? CalendarCell else {
            return FSCalendarCell()
        }
        
        if monthPosition == .current {
            let day = Calendar.current.component(.day, from: date)
            cell.configure(day: "\(day)", imageName: getImageName(for: date))
        } else {
            cell.configure(day: "", imageName: nil)
        }
        cell.titleLabel = nil
        
        return cell
    }
    
    private func getImageName(for date: Date) -> String? {
        let day = Calendar.current.component(.day, from: date)
        switch day % 3 {
        case 0:
            return "0"
        case 1:
            return "1"
        case 2:
            return "2"
        default:
            return nil
        }
    }
}

extension GreenCommitHeaderView: FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, sizeFor date: Date) -> CGSize {
        return CGSize(width: 40, height: 50)
    }
}
