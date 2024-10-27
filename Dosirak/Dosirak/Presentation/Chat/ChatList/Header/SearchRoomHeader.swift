//
//  SearchRoom.swift
//  Dosirak
//
//  Created by 권민재 on 10/26/24.
//

import UIKit
import SnapKit

class SearchRoomHeader: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        let label = UILabel()
        label.text = "검색 및 채팅방 리스트"
        label.textAlignment = .center
        label.textColor = .white
        label.backgroundColor = .yellow
        addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
