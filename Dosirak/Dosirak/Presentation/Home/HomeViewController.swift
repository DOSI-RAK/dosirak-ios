//
//  HomeViewController.swift
//  Dosirak
//
//  Created by 권민재 on 10/31/24.
//

import UIKit
import SnapKit
import RxSwift


struct GuideData {
    let title: String
    let subtitle: String
    let imageName: String
}

//class HomeViewController: BaseViewController, UICollectionViewDelegateFlowLayout {
//    
//    private let disposeBag = DisposeBag()
//    
//    let guideItems = Observable.just([
//           GuideData(title: "Green Guide", subtitle: "내 주변 다회용기 포장\n가능 매장 찾기", imageName: "greenguide_bg"),
//           GuideData(title: "Green Club", subtitle: "내 주변 마감\n세일 확인하기", imageName: "greenclub_bg"),
//           GuideData(title: "Green Talk", subtitle: "내 주변 환경 지킴이들과\n이야기하기", imageName: "greentalk_bg"),
//           GuideData(title: "Green Elite", subtitle: "greenelite", imageName: "greenelite"),
//           GuideData(title: "Green Heros", subtitle: "greenheros", imageName: "greenheros"),
//           GuideData(title: "Green Auth", subtitle: "greenauth", imageName: "greenauth")
//       ])
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        setupView()
//        setupLayout()
//    }
//    
//    override func setupView() {
//        view.addSubview(collectionView)
//        collectionView.backgroundColor = .bgColor
//        collectionView.delegate = self
//        collectionView.register(GuideCell.self, forCellWithReuseIdentifier: GuideCell.identifier)
//        collectionView.register(DoubleGridCell.self, forCellWithReuseIdentifier: DoubleGridCell.identifier)
//        collectionView.register(ListCell.self, forCellWithReuseIdentifier: ListCell.identifier)
//    }
//    
//    override func setupLayout() {
//        collectionView.snp.makeConstraints {
//            $0.top.equalTo(view.safeAreaLayoutGuide)
//            $0.bottom.equalTo(view.safeAreaLayoutGuide)
//            $0.leading.trailing.equalTo(view)
//        }
//    }
//    override func bindRX() {
//        guideItems.bind(to: collectionView.rx.items) { collectionView, index, item in
//            let identifier: String
//            switch index {
//            case 0:
//                identifier = GuideCell.identifier
//            case 1, 2:
//                identifier = DoubleGridCell.identifier
//            default:
//                identifier = ListCell.identifier
//            }
//            
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: IndexPath(item: index, section: 0))
//            
//            if let guideCell = cell as? GuideCell {
//                guideCell.configure(image: UIImage(named: item.imageName), title: item.title, subtitle: item.subtitle)
//            } else if let gridCell = cell as? DoubleGridCell {
//                gridCell.configure(image: UIImage(named: item.imageName), title: item.title, subtitle: item.subtitle)
//                
//                // index 값에 따라 titleLabel의 색상 설정
//                if index == 1 {
//                    gridCell.titleLabel.textColor = .white // Green Club에 해당하는 색상
//                } else if index == 2 {
//                    gridCell.titleLabel.textColor = .black // Green Talk에 해당하는 색상
//                }
//            } else if let listCell = cell as? ListCell {
//                listCell.configure(icon: UIImage(named: item.imageName), title: item.title, subTitle: item.subtitle)
//                listCell.backgroundColor = .white
//            }
//            
//            return cell
//        }
//        .disposed(by: disposeBag)
//    }
//    
//    // MARK: - UICollectionView 설정
//    let collectionView: UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        layout.minimumLineSpacing = 16
//        layout.minimumInteritemSpacing = 16
//        return UICollectionView(frame: .zero, collectionViewLayout: layout)
//    }()
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let width = collectionView.bounds.width
//        switch indexPath.item {
//        case 0:
//            return CGSize(width: width - 32, height: 200) // 큰 셀 (Green Guide)
//        case 1, 2:
//            let gridWidth = (width - 48) / 2
//            return CGSize(width: gridWidth, height: 130) // 중간 크기 셀 (Green Club, Green Talk)
//        default:
//            return CGSize(width: width - 32, height: 60) // 작은 셀 (Green Elite, Green Heros, Green Auth)
//        }
//    }
//}
import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SnapKit
import RxGesture

// Section 모델 설정
struct GuideSection {
    var header: String
    var items: [GuideData]
}

extension GuideSection: SectionModelType {
    typealias Item = GuideData
    
    init(original: GuideSection, items: [GuideData]) {
        self = original
        self.items = items
    }
}

class HomeViewController: BaseViewController, UICollectionViewDelegateFlowLayout {
    
    private let disposeBag = DisposeBag()
    var coordinator = HomeCoordinator()
    
    
    // Section별 데이터
    let guideSections = Observable.just([
        GuideSection(header: "Large Section", items: [
            GuideData(title: "Green Guide", subtitle: "내 주변 다회용기 포장\n가능 매장 찾기", imageName: "greenguide_bg")
        ]),
        GuideSection(header: "Grid Section", items: [
            GuideData(title: "Green Club", subtitle: "내 주변 마감\n세일 확인하기", imageName: "greenclub_bg"),
            GuideData(title: "Green Talk", subtitle: "내 주변 환경 지킴이들과\n이야기하기", imageName: "greentalk_bg")
        ]),
        GuideSection(header: "List Section", items: [
            GuideData(title: "Green Elite", subtitle: "환경 문제 풀고 리워드 받자!", imageName: "greenelite"),
            GuideData(title: "Green Heros", subtitle: "지구를 지키는 주역! 내 순위 보기", imageName: "greenheros"),
            GuideData(title: "Green Auth", subtitle: "다회용기 사용 인증하기", imageName: "greenauth")
        ])
    ])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func setupView() {
        view.addSubview(collectionView)
        collectionView.backgroundColor = .bgColor
        collectionView.register(GuideCell.self, forCellWithReuseIdentifier: GuideCell.identifier)
        collectionView.register(DoubleGridCell.self, forCellWithReuseIdentifier: DoubleGridCell.identifier)
        collectionView.register(ListCell.self, forCellWithReuseIdentifier: ListCell.identifier)
        
        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
    }
    
    override func setupLayout() {
        collectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalTo(view)
        }
    }
    
    override func bindRX() {
        // RxCollectionViewSectionedReloadDataSource의 타입을 명확히 지정
        let dataSource = RxCollectionViewSectionedReloadDataSource<GuideSection>(
            configureCell: { dataSource, collectionView, indexPath, item in
                let identifier: String
                switch indexPath.section {
                case 0:
                    identifier = GuideCell.identifier
                case 1:
                    identifier = DoubleGridCell.identifier
                default:
                    identifier = ListCell.identifier
                }
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
                
                if let guideCell = cell as? GuideCell {
                    guideCell.configure(image: UIImage(named: item.imageName), title: item.title, subtitle: item.subtitle)
                } else if let gridCell = cell as? DoubleGridCell {
                    gridCell.configure(image: UIImage(named: item.imageName), title: item.title, subtitle: item.subtitle)
                    gridCell.titleLabel.textColor = indexPath.row == 0 ? .white : .black
                } else if let listCell = cell as? ListCell {
                    listCell.configure(icon: UIImage(named: item.imageName), title: item.title, subTitle: item.subtitle)
                    listCell.backgroundColor = .white
                }
               
                
                return cell
            }
            
        )
        
        guideSections
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
                .bind { [weak self] indexPath in
                    print(indexPath.section)
                    self?.coordinator.navigateToDetail(for: indexPath)
                }
                .disposed(by: disposeBag)
    }
    
   
    
    
    
    // MARK: - UICollectionView 설정
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    // UICollectionViewDelegateFlowLayout 구현
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        switch indexPath.section {
        case 0:
            return CGSize(width: width - 32, height: 200) // 큰 셀 (Green Guide)
        case 1:
            let gridWidth = (width - 48) / 2
            return CGSize(width: gridWidth, height: 130) // 중간 크기 셀 (Green Club, Green Talk)
        default:
            return CGSize(width: width - 32, height: 60) // 작은 셀 (Green Elite, Green Heros, Green Auth)
        }
    }
}
