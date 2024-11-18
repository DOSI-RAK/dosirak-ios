//
//  GreenTrackViewController.swift
//  Dosirak
//
//  Created by 권민재 on 11/18/24.
//

import UIKit
import NMapsMap
import CoreLocation
import RxSwift
import RxCocoa
import SnapKit
import RxKeyboard



class GreenTrackViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Green Track"
        

        // Do any additional setup after loading the view.
    }
    

   
    
    
    
    
    //MARK: UI
    let mapView: NMFMapView = {
        let mapView = NMFMapView()
        return mapView
    }()
    
    let startPoingTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Start Point"
        return textField
    }()
    
    let endPointTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "End Point"
        return textField
    }()
    
    let walkTimeView: UIView = {
        let view = UIView()
        return view
    }()
    
    let bicycleTimeView: UIView = {
        let view = UIView()
        return view
    }()
    
    
    

}
