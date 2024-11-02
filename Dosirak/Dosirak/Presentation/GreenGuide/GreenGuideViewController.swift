//
//  GreenGuideViewController.swift
//  Dosirak
//
//  Created by 권민재 on 11/1/24.
//
import UIKit
import RxSwift
import RxCocoa
import SnapKit
import NMapsMap


class GreenGuideViewController: UIViewController {
    
    let mapView = NMFMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
        setupBottomSheet()
    }
    
    private func setupView() {
        view.addSubview(mapView)
        mapView.addSubview(searchTextField)
        mapView.addSubview(findRouteButtton)
    }
    
    private func setupLayout() {
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        searchTextField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalTo(view.snp.leading).inset(30)
            $0.width.equalTo(252)
            $0.height.equalTo(52)
        }
        
        findRouteButtton.snp.makeConstraints {
            $0.leading.equalTo(searchTextField.snp.trailing).offset(10)
            $0.width.height.equalTo(52)
            $0.top.equalTo(searchTextField)
        }
    }
    
    private func setupBottomSheet() {
        let bottomSheetVC = BottomSheetViewController()
        if let sheet = bottomSheetVC.sheetPresentationController {
            sheet.detents = [
                .medium(), // Minimum height
                .large() // Maximum height
            ]
           
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.selectedDetentIdentifier = .medium
        }
        
        present(bottomSheetVC, animated: true)
    }
    
    //MARK: UI
    lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "상호 동 검색"
        textField.backgroundColor = .white
        return textField
    }()
    
    lazy var findRouteButtton: UIButton = {
        let button = UIButton()
       
        button.setImage(UIImage(named: "goto"), for: .normal)
        button.backgroundColor = .systemBlue
        return button
    }()
}

