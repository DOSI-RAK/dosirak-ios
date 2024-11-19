//
//  RankingHeaderReusableView.swift
//  Dosirak
//
//  Created by 권민재 on 11/18/24.
//
import UIKit
import SnapKit

class RankingHeaderReusableView: UICollectionReusableView {
    static let identifier = "RankingHeaderReusableView"

    private let firstPlaceView = RankCardView(rank: 1)
    private let secondPlaceView = RankCardView(rank: 2)
    private let thirdPlaceView = RankCardView(rank: 3)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = UIColor(hexCode: "#F7F8FA")

        addSubview(secondPlaceView)
        addSubview(firstPlaceView)
        addSubview(thirdPlaceView)

        // 2등
        secondPlaceView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview().offset(16)
            make.width.equalTo(110)
            make.height.equalTo(200)
        }

        // 1등
        firstPlaceView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(8)
            make.width.equalTo(110)
            make.height.equalTo(200)
        }

        // 3등
        thirdPlaceView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview().offset(16)
            make.width.equalTo(110)
            make.height.equalTo(200)
        }
    }

    func configure(with ranks: [Rank]) {
        guard ranks.count >= 3 else { return }
        secondPlaceView.configure(with: ranks[1])
        firstPlaceView.configure(with: ranks[0])
        thirdPlaceView.configure(with: ranks[2])
    }
}
