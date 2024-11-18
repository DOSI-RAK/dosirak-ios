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
    case rankCards(items: [Rank])  // Top 3 카드 섹션
    case myRank(item: Rank)       // 내 등수 섹션
    case rankList(items: [Rank])  // 나머지 랭킹 리스트 섹션
}

extension GreenHeroSection: SectionModelType {
    typealias Item = Rank
    
    var items: [Item] {
        switch self {
        case .rankCards(let items): return items
        case .myRank(let item): return [item]
        case .rankList(let items): return items
        }
    }
    
    init(original: GreenHeroSection, items: [Item]) {
        switch original {
        case .rankCards: self = .rankCards(items: items)
        case .myRank: self = .myRank(item: items.first!)
        case .rankList: self = .rankList(items: items)
        }
    }
}

// MARK: - GreenHeroesViewController
class GreenHeroesViewController: UIViewController {
    private let collectionView: UICollectionView
    private let layout = UICollectionViewFlowLayout()
    private let disposeBag = DisposeBag()

    private let fetchTotalRankTrigger = PublishRelay<Void>()
    private let fetchMyRankTrigger = PublishRelay<Void>()

    // Data Source
    private let dataSource = RxCollectionViewSectionedReloadDataSource<GreenHeroSection>(
        configureCell: { dataSource, collectionView, indexPath, item in
            switch dataSource[indexPath.section] {
            case .rankList:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RankingCell.identifier, for: indexPath) as! RankingCell
                cell.configure(with: item)
                return cell
            default:
                // 빈 셀 처리
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyCell", for: indexPath)
                return cell
            }
        },
        configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
            
            switch dataSource[indexPath.section] {
            case .rankCards(let ranks):
                let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: RankingHeaderReusableView.identifier,
                    for: indexPath
                ) as! RankingHeaderReusableView
                header.configure(with: ranks)
                return header
                
            case .myRank(let rank):
                let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: MyRankReusableView.identifier,
                    for: indexPath
                ) as! MyRankReusableView
                header.configure(with: rank)
                return header
                
            default:
                return UICollectionReusableView()
            }
        }
    )
    
    
    init() {
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        setupUI()
        setupConstraints()
        bindDummyData() // 더미 데이터로 테스트
    }
    
    private func configureCollectionView() {
        collectionView.register(
            RankingHeaderReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: RankingHeaderReusableView.identifier
        )
        
        collectionView.register(
            MyRankReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: MyRankReusableView.identifier
        )
        
        collectionView.register(
            RankingCell.self,
            forCellWithReuseIdentifier: RankingCell.identifier
        )
        
        collectionView.register(
            UICollectionViewCell.self,
            forCellWithReuseIdentifier: "EmptyCell" // 빈 셀 등록
        )
        
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
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
    
    private func bindDummyData() {
        // Dummy Data
        let topThreeRanks = [
            Rank(userId: 1, profileImg: "https://via.placeholder.com/40", rank: 1, nickName: "Top Hero 1", reward: 1000),
            Rank(userId: 2, profileImg: "https://via.placeholder.com/40", rank: 2, nickName: "Top Hero 2", reward: 900),
            Rank(userId: 3, profileImg: "https://via.placeholder.com/40", rank: 3, nickName: "Top Hero 3", reward: 800)
        ]
        
        let myRank = Rank(userId: 4, profileImg: "https://via.placeholder.com/40", rank: 4, nickName: "My Hero", reward: 750)
        
        let rankingList = (5...50).map {
            Rank(userId: $0, profileImg: "https://via.placeholder.com/40", rank: $0, nickName: "Hero \($0)", reward: 700 - $0 * 10)
        }
        
        let sections: [GreenHeroSection] = [
            .rankCards(items: topThreeRanks),
            .myRank(item: myRank),
            .rankList(items: rankingList)
        ]
        
        Observable.just(sections)
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension GreenHeroesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch section {
        case 0: // Rank Cards Header
            return CGSize(width: collectionView.bounds.width, height: 200)
        case 1: // My Rank Header
            return CGSize(width: collectionView.bounds.width, height: 100)
        default: // No Header for Other Sections
            return .zero
        }
    }
}
