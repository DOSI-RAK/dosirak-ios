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

    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        backgroundColor = .bgColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = UIColor(hexCode: "#F7F8FA") // Header background color

        // Setup stack view
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fillEqually

        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }

    func configure(with ranks: [Rank]) {
        // Clear existing subviews
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Add RankCardView for each rank
        ranks.enumerated().forEach { index, rank in
            let rankView = RankCardView(rank: rank.rank)
            rankView.configure(with: rank)
            stackView.addArrangedSubview(rankView)
        }
    }
}
