//
//  OnboardingViewController.swift
//  Dosirak
//
//  Created by 권민재 on 10/17/24.
//
import UIKit
import SnapKit


extension NSObject {
    @objc func injected() {
        if let vc = self as? UIViewController {
            print("Injected: \(type(of: vc))")
            vc.viewDidLoad()
        }
    }
}



extension NSMutableParagraphStyle {
    func apply(_ block: (NSMutableParagraphStyle) -> Void) -> NSMutableParagraphStyle {
        block(self)
        return self
    }
}


class OnboardingPageViewController: UIViewController {
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel1 = UILabel()
    private let descriptionLabel2 = UILabel()
    
    init(imageName: String, title: String, description1: NSAttributedString, description2: NSAttributedString) {
        super.init(nibName: nil, bundle: nil)
        imageView.image = UIImage(named: imageName)
        titleLabel.text = title
        descriptionLabel1.attributedText = description1
        descriptionLabel2.attributedText = description2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
       
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        view.addSubview(imageView)
        
      
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .heavy)
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0
        view.addSubview(titleLabel)
        
       
        descriptionLabel1.numberOfLines = 0
        descriptionLabel1.textAlignment = .left
        view.addSubview(descriptionLabel1)
        
    
        descriptionLabel2.numberOfLines = 0
        descriptionLabel2.textAlignment = .left
        view.addSubview(descriptionLabel2)
    }
    
    private func setupConstraints() {
      
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
       
        descriptionLabel1.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        descriptionLabel2.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel1.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
}

class OnboardingViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    private let pages: [UIViewController]
    private let pageControl = UIPageControl()
    private let startButton = UIButton()
    
    init() {
    
        let page1 = OnboardingPageViewController(
            imageName: "onboarding1",
            title: "그거\n아시나요?",
            description1: NSMutableAttributedString()
                .apply(text: "지구 온난화로 인한 서식지 감소로\n하프물범의 개체수가 지난 30년간\n", attributes: [
                    .font: UIFont.systemFont(ofSize: 16),
                    .foregroundColor: UIColor.darkGray,
                ])
                .apply(text: "\n", attributes: [
                    .font: UIFont.systemFont(ofSize: 16),
                    .foregroundColor: UIColor.darkGray,
                ])
            
                .apply(text: "약 50% ", attributes: [
                    .font: UIFont.boldSystemFont(ofSize: 20),
                    .foregroundColor: UIColor.mainColor
                ])
                .apply(text: "감소했어요", attributes: [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.black
                ]),
            description2: NSMutableAttributedString()
        )
        
        let page2 = OnboardingPageViewController(
            imageName: "onboarding2",
            title: "하프물범\n새봄이가",
            description1: NSMutableAttributedString()
                .apply(text: "온전한 집을 찾을 수 있도록, \n", attributes: [
                    .font: UIFont.systemFont(ofSize: 16),
                    .foregroundColor: UIColor.darkGray,
                ])
                .apply(text: "\n", attributes: [
                    .font: UIFont.systemFont(ofSize: 16),
                    .foregroundColor: UIColor.darkGray,
                ])
                .apply(text: "다회용기 사용 실천 ", attributes: [
                    .font: UIFont.boldSystemFont(ofSize: 20),
                    .foregroundColor: UIColor.mainColor
                ])
                .apply(text: "해보는건 어떨까요?", attributes: [
                    .font: UIFont.boldSystemFont(ofSize: 16),
                    .foregroundColor: UIColor.black
                ]),
            description2: NSMutableAttributedString()
        )
        
        let page3 = OnboardingPageViewController(
            imageName: "onboarding3",
            title: "다회용기\n사용의 첫걸음",
            description1: NSMutableAttributedString()
                .apply(text: "DOSIRAK", attributes: [
                    .font: UIFont.boldSystemFont(ofSize: 16),
                    .foregroundColor: UIColor.mainColor
                ])
                .apply(text: "이 도와드릴게요!", attributes: [
                    .font: UIFont.systemFont(ofSize: 16),
                    .foregroundColor: UIColor.darkGray
                ]),
            description2: NSMutableAttributedString()
        )
        
        self.pages = [page1, page2, page3]
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        dataSource = self
        delegate = self
        setViewControllers([pages[0]], direction: .forward, animated: true, completion: nil)
        
        setupPageControl()
        setupStartButton()
    }
    
    private func setupPageControl() {
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor.white
        pageControl.currentPageIndicatorTintColor = UIColor.mainColor
        
        view.addSubview(pageControl)
        pageControl.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-60)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupStartButton() {
        startButton.setTitle("시작하기", for: .normal)
        startButton.backgroundColor = .mainColor
        startButton.layer.cornerRadius = 10
        startButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        startButton.setTitleColor(.white, for: .normal)
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        startButton.isHidden = true
        
        view.addSubview(startButton)
        startButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.leading.trailing.equalToSuperview().inset(40)
            make.height.equalTo(50)
        }
    }
    
    @objc private func startButtonTapped() {
        print("Onboarding Completed")
    
        let vc = UINavigationController(rootViewController: UserInfoSettingViewController())
        vc.modalPresentationStyle = .fullScreen
        vc.navigationBar.isTranslucent = false
        vc.navigationBar.barTintColor = .white 
        present(vc, animated: true)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex > 0 else { return nil }
        return pages[currentIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex < pages.count - 1 else { return nil }
        return pages[currentIndex + 1]
    }
    
   
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
            startButton.isHidden = currentIndex != pages.count - 1
            
           
            pageControl.isHidden = currentIndex == pages.count - 1
        }
    }
}

extension NSMutableAttributedString {
    func apply(text: String, attributes: [NSAttributedString.Key: Any]) -> NSMutableAttributedString {
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        self.append(attributedString)
        return self
    }
}
