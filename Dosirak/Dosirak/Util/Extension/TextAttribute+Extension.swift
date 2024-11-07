//
//  TextAttribute+Extension.swift
//  Dosirak
//
//  Created by 권민재 on 11/7/24.
//
import UIKit

extension NSMutableAttributedString {
    func setColor(for text: String, with color: UIColor) -> NSMutableAttributedString {
            let range = (self.string as NSString).range(of: text)
            if range.location != NSNotFound {
                self.addAttribute(.foregroundColor, value: color, range: range)
            }
            return self
        }
}
