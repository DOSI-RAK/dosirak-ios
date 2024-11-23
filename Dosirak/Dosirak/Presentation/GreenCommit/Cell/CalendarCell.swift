//
//  CalendarCell.swift
//  Dosirak
//
//  Created by 권민재 on 11/5/24.
//]
import UIKit
import FSCalendar

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
    
    let commitCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
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
        contentView.addSubview(commitCountLabel)
        
        dayLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(5)
        }
        
        activityImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(dayLabel.snp.bottom).offset(5)
            make.width.height.equalTo(25)
        }

        commitCountLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(activityImageView.snp.bottom).offset(3)
        }
    }
    
    // MARK: - Configure Cell
    func configure(day: String, imageName: String?, commitCount: Int?) {
        dayLabel.text = day
        if let imageName = imageName {
            activityImageView.image = UIImage(named: imageName)
            activityImageView.isHidden = false
        } else {
            activityImageView.isHidden = true
        }
        
        if let count = commitCount, count > 0 {
            commitCountLabel.text = "\(count)" // 커밋 횟수
            commitCountLabel.isHidden = false
        } else {
            commitCountLabel.isHidden = true
        }
    }
}
