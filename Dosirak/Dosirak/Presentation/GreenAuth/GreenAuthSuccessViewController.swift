//
//  GreenAuthSuccessViewController.swift
//  Dosirak
//
//  Created by 권민재 on 11/25/24.
//


import UIKit
import SnapKit

extension UIImage {
    // GIF를 로드하는 유틸리티 함수
    static func gif(data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        var images: [UIImage] = []
        var duration: TimeInterval = 0

        let frameCount = CGImageSourceGetCount(source)
        for i in 0..<frameCount {
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) else { continue }
            images.append(UIImage(cgImage: cgImage))
            
            // 프레임마다 지속 시간 추가
            if let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [CFString: Any],
               let gifProperties = properties[kCGImagePropertyGIFDictionary] as? [CFString: Any],
               let delay = gifProperties[kCGImagePropertyGIFDelayTime] as? Double {
                duration += delay
            }
        }

        return UIImage.animatedImage(with: images, duration: duration)
    }
}




class GreenAuthSuccessViewController: UIViewController {
    
    var expPoints: Int = 0

    private let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "coin_animation"))
        imageView.contentMode = .scaleAspectFill
        //imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "다회용기 사용으로 그린지수"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .systemGreen
        label.textAlignment = .center
        return label
    }()
    
    private let expLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        label.textColor = .mainColor
        label.textAlignment = .center
        return label
    }()
    
    private let rewardLabel: UILabel = {
        let label = UILabel()
        label.text = "현재 리워드: 000exp."
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .black
        label.textAlignment = .center
        label.backgroundColor = UIColor(hexCode: "ededed")
        label.clipsToBounds = true
        label.layer.cornerRadius = 15
        return label
    }()
    
    private let confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("확인", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .mainColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        setupConstraints()
        expLabel.text = "\(expPoints) exp. 획득!"
        if let gifUrl = Bundle.main.url(forResource: "coin_animation", withExtension: "gif"),
           let gifData = try? Data(contentsOf: gifUrl) {
            imageView.image = UIImage.gif(data: gifData)
        }
        confirmButton.addTarget(self, action: #selector(goToHome), for: .touchUpInside)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    private func setupViews() {
        view.addSubview(imageView)
        view.addSubview(messageLabel)
        view.addSubview(expLabel)
        view.addSubview(rewardLabel)
        view.addSubview(confirmButton)
        
        
    }
    
    private func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-50)
            make.width.height.equalTo(400)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).inset(170)
            make.centerX.equalToSuperview()
        }
        
        expLabel.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        rewardLabel.snp.makeConstraints { make in
            make.top.equalTo(expLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(130)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
    }
    
    @objc private func goToHome() {
        
        GreenRewardAPIManager.shared.saveDosirak { result in
            switch result {
            case .success:
                print("🎉 Dosirak reward saved successfully!")
            case .failure(let error):
                print("❌ Failed to save dosirak reward: \(error.localizedDescription)")
            }
        }
        
        guard let sceneDelegate = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive })?.delegate as? SceneDelegate else {
            print("SceneDelegate를 찾을 수 없습니다.")
            return
        }
        
        sceneDelegate.appCoordinator?.moveToHomeFromAnyVC()
    }


}
