//
//  GreenHeroViewController.swift
//  Dosirak
//
//  Created by 권민재 on 11/15/24.

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Kingfisher

class GreenHeroesViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let viewModel = GreenHeroViewModel()

    // MARK: - UI Components
    private let top3View: UIView = UIView()

    private let firstPlaceImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "1등")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private let secondPlaceImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "2등")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private let thirdPlaceImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "3등")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private let myRankView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 12
        return view
    }()

    private let rankTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .clear
        return tableView
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .bgColor
        setupLayout()
        bindViewModel()

        rankTableView.register(RankingCell.self, forCellReuseIdentifier: RankingCell.identifier)
        rankTableView.delegate = self
    }

    // MARK: - Layout
    private func setupLayout() {
        view.addSubview(top3View)
        top3View.addSubview(secondPlaceImageView)
        top3View.addSubview(firstPlaceImageView)
        top3View.addSubview(thirdPlaceImageView)

        view.addSubview(myRankView)
        view.addSubview(rankTableView)

        top3View.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(25)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(150)
        }

        secondPlaceImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview().offset(10)
            make.width.equalToSuperview().multipliedBy(0.3)
            make.height.equalToSuperview()
        }

        firstPlaceImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-10)
            make.width.equalToSuperview().multipliedBy(0.4)
            make.height.equalToSuperview()
        }

        thirdPlaceImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview().offset(10)
            make.width.equalToSuperview().multipliedBy(0.3)
            make.height.equalToSuperview()
        }

        myRankView.snp.makeConstraints { make in
            make.top.equalTo(top3View.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(70)
        }

        rankTableView.snp.makeConstraints { make in
            make.top.equalTo(myRankView.snp.bottom).offset(20)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func setupMyRankView(rank: Rank) {
        // 기존 뷰 내부의 서브뷰 제거
        myRankView.subviews.forEach { $0.removeFromSuperview() }

        // 순위 라벨
        let rankLabel = UILabel()
        rankLabel.font = UIFont.boldSystemFont(ofSize: 16)
        rankLabel.textColor = .black
        rankLabel.textAlignment = .center
        rankLabel.text = "\(rank.rank)"

        // 프로필 이미지
        let profileImageView = UIImageView()
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        profileImageView.kf.setImage(
            with: URL(string: rank.profileImg ?? ""),
            placeholder: UIImage(named: "placeholder")
        )

        // 닉네임 라벨
        let nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: 14)
        nameLabel.textColor = .black
        nameLabel.lineBreakMode = .byTruncatingTail
        nameLabel.text = rank.nickName ?? "Unknown"

        // 점수 라벨
        let scoreLabel = UILabel()
        scoreLabel.font = UIFont.systemFont(ofSize: 14)
        scoreLabel.textColor = UIColor.gray
        scoreLabel.textAlignment = .right
        scoreLabel.text = "\(rank.reward)점"

        // Add subviews
        myRankView.addSubview(rankLabel)
        myRankView.addSubview(profileImageView)
        myRankView.addSubview(nameLabel)
        myRankView.addSubview(scoreLabel)

        // Layout constraints
        rankLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(30) // 고정된 폭
        }

        profileImageView.snp.makeConstraints { make in
            make.leading.equalTo(rankLabel.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40) // 정사각형
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(scoreLabel.snp.leading).offset(-8)
        }

        scoreLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
    }

    // MARK: - Binding
    private func bindViewModel() {
        let input = GreenHeroViewModel.Input(
            fetchTotalRankTrigger: PublishRelay<Void>(),
            fetchMyRankTrigger: PublishRelay<Void>()
        )
        let output = viewModel.transform(input: input)

        // Bind 1st Rank
        output.firstRank
            .drive(onNext: { [weak self] rank in
                guard let self = self, let rank = rank else { return }
                self.configurePlaceImageView(self.firstPlaceImageView, with: rank)
            })
            .disposed(by: disposeBag)

        // Bind 2nd Rank
        output.secondRank
            .drive(onNext: { [weak self] rank in
                guard let self = self, let rank = rank else { return }
                self.configurePlaceImageView(self.secondPlaceImageView, with: rank)
            })
            .disposed(by: disposeBag)

        // Bind 3rd Rank
        output.thirdRank
            .drive(onNext: { [weak self] rank in
                guard let self = self, let rank = rank else { return }
                self.configurePlaceImageView(self.thirdPlaceImageView, with: rank)
            })
            .disposed(by: disposeBag)

       
        output.myRank
            .drive(onNext: { [weak self] rank in
                guard let self = self else { return }
                if let rank = rank {
                    self.setupMyRankView(rank: rank) // 업데이트
                }
            })
            .disposed(by: disposeBag)

       
        output.rankList
            .drive(rankTableView.rx.items(
                cellIdentifier: RankingCell.identifier,
                cellType: RankingCell.self
            )) { _, rank, cell in
                cell.configure(with: rank)
            }
            .disposed(by: disposeBag)

        output.error
            .drive(onNext: { errorMessage in
                if !errorMessage.isEmpty {
                    print("[ERROR] \(errorMessage)")
                }
            })
            .disposed(by: disposeBag)

        input.fetchTotalRankTrigger.accept(())
        input.fetchMyRankTrigger.accept(())
    }

    // MARK: - Configure Place Image View
    private func configurePlaceImageView(_ imageView: UIImageView, with rank: Rank) {
        imageView.subviews.forEach { $0.removeFromSuperview() }

        // Profile Image
        let profileImageView = UIImageView()
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 30
        profileImageView.clipsToBounds = true
        profileImageView.kf.setImage(
            with: URL(string: rank.profileImg ?? ""),
            placeholder: UIImage(named: "profile")
        )

        // Name Label
        let nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        nameLabel.textAlignment = .center
        nameLabel.text = rank.nickName ?? "Unknown"

        // Score Label
        let scoreLabel = UILabel()
        scoreLabel.font = UIFont.systemFont(ofSize: 12)
        scoreLabel.textAlignment = .center
        scoreLabel.textColor = .black
        scoreLabel.text = "\(rank.reward)점"

        imageView.addSubview(profileImageView)
        imageView.addSubview(nameLabel)
        imageView.addSubview(scoreLabel)

        profileImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(30)
            make.width.height.equalTo(60)
        }

        nameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(profileImageView.snp.bottom).offset(8)
        }

        scoreLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
        }
    }
}

extension GreenHeroesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let spacerView = UIView()
        spacerView.backgroundColor = .clear
        return spacerView
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
}
