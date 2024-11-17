//
//  GreenHeroViewController.swift
//  Dosirak
//
//  Created by 권민재 on 11/15/24.
import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources

// MARK: - Section Model
enum GreenHeroSection {
    case topThree(items: [Rank])
    case myRank(item: Rank)
    case rankingList(items: [Rank])
}

extension GreenHeroSection: SectionModelType {
    typealias Item = Rank
    
    var items: [Item] {
        switch self {
        case .topThree(let items): return items
        case .myRank(let item): return [item]
        case .rankingList(let items): return items
        }
    }
    
    init(original: GreenHeroSection, items: [Item]) {
        switch original {
        case .topThree: self = .topThree(items: items)
        case .myRank: self = .myRank(item: items.first!)
        case .rankingList: self = .rankingList(items: items)
        }
    }
}

// MARK: - GreenHeroesViewController
class GreenHeroesViewController: UIViewController {
    private let collectionView: UICollectionView
    private let layout = UICollectionViewFlowLayout()
    private let disposeBag = DisposeBag()
    private let viewModel = GreenHeroViewModel()

    private let fetchTotalRankTrigger = PublishRelay<Void>()
    private let fetchMyRankTrigger = PublishRelay<Void>()

    private let headerHeight: CGFloat = 200

    // Data
    private let dataSource = RxCollectionViewSectionedReloadDataSource<GreenHeroSection>(
        configureCell: { dataSource, collectionView, indexPath, item in
            switch dataSource[indexPath.section] {
            case .rankingList:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RankingCell.identifier, for: indexPath) as! RankingCell
                cell.configure(with: item)
                return cell
            default:
                return UICollectionViewCell() // Top Three & My Rank handled in header.
            }
        },
        configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
            switch dataSource[indexPath.section] {
            case .topThree(let items):
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: RankingHeaderReusableView.identifier, for: indexPath) as! RankingHeaderReusableView
                header.configure(with: items)
                return header
            case .myRank(let item):
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: MyRankReusableView.identifier, for: indexPath) as! MyRankReusableView
                header.configure(with: item)
                return header
            default:
                return UICollectionReusableView()
            }
        }
    )

    init() {
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
        setupUI()
        setupConstraints()
        bindViewModel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        title = "Green Heroes"
        navigationController?.navigationBar.prefersLargeTitles = true

        // Trigger API fetch
        fetchTotalRankTrigger.accept(())
        fetchMyRankTrigger.accept(())
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(collectionView)
    }

    private func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func configureCollectionView() {
        collectionView.register(RankingHeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: RankingHeaderReusableView.identifier)
        collectionView.register(MyRankReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: MyRankReusableView.identifier)
        collectionView.register(RankingCell.self, forCellWithReuseIdentifier: RankingCell.identifier)
        
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
    }

    private func bindViewModel() {
        let input = GreenHeroViewModel.Input(
            fetchTotalRankTrigger: fetchTotalRankTrigger,
            fetchMyRankTrigger: fetchMyRankTrigger
        )

        let output = viewModel.transform(input: input)

        Observable.combineLatest(
            output.totalRanks.map { GreenHeroSection.topThree(items: Array($0.prefix(3))) },
            output.myRank.compactMap { $0 }.map { GreenHeroSection.myRank(item: $0) },
            output.totalRanks.map { GreenHeroSection.rankingList(items: Array($0.dropFirst(3))) }
        )
        .map { [$0.0, $0.1, $0.2] } // Combine sections
        .bind(to: collectionView.rx.items(dataSource: dataSource))
        .disposed(by: disposeBag)

        // Handle errors
        output.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { errorMessage in
                print("Error: \(errorMessage)")
            })
            .disposed(by: disposeBag)
    }
}

/// MARK: - MyRankReusableView
class MyRankReusableView: UICollectionReusableView {
    static let identifier = "MyRankReusableView"

    private let rankLabel = UILabel()
    private let nameLabel = UILabel()
    private let scoreLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .white

        let stackView = UIStackView(arrangedSubviews: [rankLabel, nameLabel, scoreLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 16

        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }

        rankLabel.font = UIFont.boldSystemFont(ofSize: 18)
        rankLabel.textColor = .black

        nameLabel.font = UIFont.systemFont(ofSize: 16)
        nameLabel.textColor = .darkGray

        scoreLabel.font = UIFont.systemFont(ofSize: 16)
        scoreLabel.textColor = .systemBlue
    }

    func configure(with rank: Rank) {
        rankLabel.text = "\(rank.rank)"
        nameLabel.text = rank.nickName
        scoreLabel.text = "\(rank.reward)점"
    }
}


// MARK: - RankingHeaderReusableView
class RankingHeaderReusableView: UICollectionReusableView {
    static let identifier = "RankingHeaderReusableView"

    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .bottom

        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }

    func configure(with ranks: [Rank]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        ranks.enumerated().forEach { index, rank in
            let rankView = RankCardView(rank: rank.rank)
            rankView.configure(with: rank)
            stackView.addArrangedSubview(rankView)
        }
    }
}

// MARK: - RankCardView
class RankCardView: UIView {
    private let nameLabel = UILabel()
    private let scoreLabel = UILabel()

    init(rank: Int) {
        super.init(frame: .zero)
        setupUI(rank: rank)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI(rank: Int) {
        backgroundColor = rank == 1 ? UIColor.systemGreen : UIColor.systemGray5
        layer.cornerRadius = 12

        let stack = UIStackView(arrangedSubviews: [nameLabel, scoreLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .center

        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
    }

    func configure(with item: Rank) {
        nameLabel.text = item.nickName
        scoreLabel.text = String(item.reward)
    }
}

// MARK: - RankingCell
class RankingCell: UICollectionViewCell {
    static let identifier = "RankingCell"

    private let rankLabel = UILabel()
    private let nameLabel = UILabel()
    private let scoreLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.lightGray.cgColor

        let stack = UIStackView(arrangedSubviews: [rankLabel, nameLabel, scoreLabel])
        stack.axis = .horizontal
        stack.spacing = 8

        contentView.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
    }

    func configure(with item: Rank) {
        rankLabel.text = "\(item.rank)"
        nameLabel.text = item.nickName
        scoreLabel.text = String(item.reward)
    }
}

