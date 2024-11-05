//
//  CalendarCell.swift
//  Dosirak
//
//  Created by 권민재 on 11/5/24.
//

import FSCalendar
import UIKit
import SnapKit

class CalendarCell: FSCalendarCell {
    
    // MARK: - UI Components
    let activityImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()
    
    let dayLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup View
    private func setupView() {
        
        contentView.addSubview(dayLabel)
        contentView.addSubview(activityImageView)
        
        dayLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(8) // 상단에서 약간 여백 추가
        }
        
        activityImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(dayLabel.snp.bottom).offset(4)
            make.width.height.equalTo(30)
        }
    }
    
    // MARK: - Configure Cell
    func configure(day: String, imageName: String?) {
        dayLabel.text = day
        if let imageName = imageName {
            activityImageView.image = UIImage(named: imageName)
            activityImageView.isHidden = false
        } else {
            activityImageView.isHidden = true
        }
    }
}
