//
//  SortToggleButton.swift
//  Dosirak
//
//  Created by 권민재 on 10/28/24.
//


import UIKit

// MARK: - SortToggleButton Class
class SortToggleButton: UIButton {
    
    // MARK: - Properties
    override var isSelected: Bool {
        didSet {
            updateAppearance()
        }
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        layer.cornerRadius = 16
        titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        setTitleColor(.white, for: .selected)
        setTitleColor(.black, for: .normal)
        updateAppearance()
    }
    
    private func updateAppearance() {
        backgroundColor = isSelected ? .black : .white
        layer.borderWidth = isSelected ? 0 : 1
        layer.borderColor = UIColor.black.cgColor
    }
}
