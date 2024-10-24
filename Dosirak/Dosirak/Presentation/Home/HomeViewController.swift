//
//  HomeViewController.swift
//  Dosirak
//
//  Created by 권민재 on 10/17/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import KakaoMapsSDK


class HomeViewController: BaseViewController {
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        //view.backgroundColor = .mainColor
        
    }
    
    override func setupView() {
        view.addSubview(collectionView)
    }
    override func setupLayout() {
        collectionView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.trailing.equalTo(self.view)
        }
    
    }
    
    override func setupAttibure() {
        
        
    }
    
    
    
    //MARK: UI
    let collectionView: UICollectionView = {
        let layout = UICollectionViewLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return view
    }()
    
    

    
    
}
