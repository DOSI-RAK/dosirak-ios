//
//  AddressPickerViewController.swift
//  Dosirak
//
//  Created by 권민재 on 11/14/24.
//

import UIKit
import PanModal
import RxSwift
import RxCocoa

class AddressPickerViewController: UIViewController, PanModalPresentable {
    
    private let disposeBag = DisposeBag()
    var selectedDistrict = PublishRelay<String>()
    var selectedNeighborhood = PublishRelay<String>()
    
    let neighborhoods: [String: [String]] = [
        "종로구": ["청운효자동", "사직동", "삼청동", "부암동", "평창동", "무악동", "교남동", "가회동", "종로1.2.3.4가동", "종로5.6가동", "이화동", "혜화동", "창신1동", "창신2동", "창신3동", "숭인1동", "숭인2동"],
        "중구": ["소공동", "회현동", "명동", "필동", "장충동", "광희동", "을지로동", "신당5동", "황학동", "중림동"],
        "용산구": ["후암동", "용산2가동", "남영동", "청파동", "원효로1동", "원효로2동", "효창동", "용문동", "한강로동", "이촌1동", "이촌2동", "이태원1동", "이태원2동", "한남동", "서빙고동", "보광동"],
        "성동구": ["왕십리2동", "왕십리도선동", "마장동", "사근동", "행당1동", "행당2동", "응봉동", "금호1가동", "금호2.3가동", "금호4가동", "성수1가1동", "성수1가2동", "성수2가1동", "성수2가3동", "송정동", "용답동"],
        "광진구": ["중곡1동", "중곡2동", "중곡3동", "중곡4동", "능동", "구의1동", "구의2동", "구의3동", "광장동", "자양1동", "자양2동", "자양3동", "자양4동", "화양동"],
        "동대문구": ["용신동", "제기동", "전농1동", "전농2동", "답십리1동", "답십리2동", "장안1동", "장안2동", "청량리동", "회기동", "휘경1동", "휘경2동", "이문1동", "이문2동"],
        "중랑구": ["면목본동", "면목2동", "면목3.8동", "면목4동", "면목5동", "면목7동", "상봉1동", "상봉2동", "중화1동", "중화2동", "묵1동", "묵2동", "망우본동", "망우3동", "신내1동", "신내2동"],
        "성북구": ["성북동", "삼선동", "동선동", "돈암1동", "돈암2동", "안암동", "보문동", "정릉1동", "정릉2동", "정릉3동", "정릉4동", "길음1동", "길음2동", "종암동", "월곡1동", "월곡2동", "장위1동", "장위2동", "장위3동", "석관동"],
        "강북구": ["삼양동", "미아동", "송중동", "송천동", "삼각산동", "번1동", "번2동", "번3동", "수유1동", "수유2동", "수유3동", "우이동", "인수동"],
        "도봉구": ["창1동", "창2동", "창3동", "창4동", "창5동", "도봉1동", "도봉2동"],
        "노원구": ["월계1동", "월계2동", "월계3동", "공릉1동", "공릉2동", "하계1동", "하계2동", "중계본동", "중계1동", "중계4동", "중계2.3동", "상계1동", "상계2동", "상계3.4동", "상계5동", "상계6.7동", "상계8동", "상계9동", "상계10동"],
        "은평구": ["녹번동", "불광1동", "불광2동", "갈현1동", "갈현2동", "구산동", "대조동", "응암1동", "응암2동", "응암3동", "역촌동", "신사1동", "신사2동", "증산동", "수색동", "진관동"],
        "서대문구": ["천연동", "북아현동", "충현동", "신촌동", "연희동", "홍제1동", "홍제2동", "홍제3동", "홍은1동", "홍은2동", "남가좌1동", "남가좌2동", "북가좌1동", "북가좌2동"],
        "마포구": ["아현동", "공덕동", "도화동", "용강동", "대흥동", "염리동", "신수동", "서강동", "서교동", "합정동", "망원1동", "망원2동", "연남동", "성산1동", "성산2동", "상암동"],
        "양천구": ["목1동", "목2동", "목3동", "목4동", "신월1동", "신월2동", "신월3동", "신월4동", "신월5동", "신월6동", "신월7동", "신정1동", "신정2동", "신정3동", "신정4동", "신정6동", "신정7동"],
        "강서구": ["염창동", "등촌1동", "등촌2동", "등촌3동", "화곡본동", "화곡1동", "화곡2동", "화곡3동", "화곡4동", "화곡6동", "화곡8동", "가양1동", "가양2동", "가양3동", "발산1동", "공항동", "방화1동", "방화2동", "방화3동"],
        "구로구": ["신도림동", "구로1동", "구로2동", "구로3동", "구로4동", "구로5동", "가리봉동"],
        "금천구": ["가산동", "독산1동", "독산2동", "독산3동", "독산4동", "시흥1동", "시흥2동", "시흥3동", "시흥4동", "시흥5동"],
        "영등포구": ["영등포본동", "영등포동", "여의동", "당산1동", "당산2동", "도림동", "문래동", "양평1동", "양평2동", "신길1동", "신길3동", "신길4동", "신길5동", "신길6동", "신길7동", "대림1동", "대림2동", "대림3동"],
        "동작구": ["노량진1동", "노량진2동", "상도1동", "상도2동", "상도3동", "상도4동", "흑석동", "사당1동", "사당2동", "사당3동", "사당4동", "사당5동", "대방동", "신대방1동", "신대방2동"],
        "관악구": ["보라매동", "청림동", "성현동", "행운동", "낙성대동", "중앙동", "인헌동", "남현동", "서원동", "신림동", "신사동", "조원동", "대학동", "은천동", "성북동", "청룡동", "난향동", "미성동", "난곡동", "신원동"],
        "서초구": ["서초1동", "서초2동", "서초3동", "서초4동", "잠원동", "반포본동", "반포1동", "반포2동", "반포3동", "반포4동", "방배본동", "방배1동", "방배2동", "방배3동", "방배4동", "양재1동", "양재2동", "내곡동"],
        "강남구": ["신사동", "논현1동", "논현2동", "압구정동", "청담동", "삼성1동", "삼성2동", "대치1동", "대치2동", "대치4동", "역삼1동", "역삼2동", "도곡1동", "도곡2동", "개포1동", "개포2동", "개포4동", "일원본동", "일원1동", "일원2동", "수서동"],
        "송파구": ["풍납1동", "풍납2동", "거여1동", "거여2동", "마천1동", "마천2동", "방이1동", "방이2동", "오륜동", "오금동", "송파1동", "송파2동", "석촌동", "삼전동", "가락본동", "가락1동", "가락2동", "문정1동", "문정2동", "장지동", "위례동"],
        "강동구": ["강일동", "상일동", "명일1동", "명일2동", "고덕1동", "고덕2동", "암사1동", "암사2동", "암사3동", "천호1동", "천호2동", "천호3동"]
    ]
    
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "구 선택"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    var isDistrictSelection = true
    var currentDistrict: String?
    private var items = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        
        if isDistrictSelection {
            items = Array(neighborhoods.keys)
        } else if let district = currentDistrict, let neighborhoodList = neighborhoods[district] {
            items = neighborhoodList
            titleLabel.text = "동 선택"
        }
        
        tableView.reloadData()
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.trailing.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // PanModal 속성
    var panScrollable: UIScrollView? {
        return tableView
    }
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(450)
    }
    
    var longFormHeight: PanModalHeight {
        return .maxHeightWithTopInset(40)
    }
}

extension AddressPickerViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedText = items[indexPath.row]
        
        if isDistrictSelection {
            selectedDistrict.accept(selectedText)
        } else {
            selectedNeighborhood.accept(selectedText)
        }
        
        dismiss(animated: true)
    }
}
