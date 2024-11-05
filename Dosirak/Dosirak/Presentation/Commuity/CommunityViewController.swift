//
//  CommunityViewController.swift
//  Dosirak
//
//  Created by 권민재 on 10/24/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class CommunityViewController: BaseViewController {
    
    var coordinator: CommuityCoordinator?
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "내 활동"
    }
    

    override func setupView() {
        view.addSubview(walkingButton)
        view.addSubview(ddareungButton)
        
    }
    
    override func setupLayout() {
        walkingButton.snp.makeConstraints {
            $0.width.height.equalTo(100)
            $0.leading.equalTo(self.view).inset(20)
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        ddareungButton.snp.makeConstraints {
            $0.width.height.equalTo(100)
            $0.trailing.equalTo(view.snp.trailing).inset(20)
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        
    }
    
    override func bindRX() {
        walkingButton.rx.tap
            .subscribe(onNext: { [weak self] in
                let vc = GreenCommitViewController()
                vc.hidesBottomBarWhenPushed = true
                self?.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    
    //MARK: UI
    lazy var walkingButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .lightGray
        return button
    }()
    
    lazy var ddareungButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .green
        return button
    }()
    
    

}
