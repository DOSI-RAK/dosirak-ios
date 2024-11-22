//
//  OnboardingViewController.swift
//  Dosirak
//
//  Created by 권민재 on 10/17/24.
//
import UIKit

class OnboardingViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    private let pages: [UIViewController]
    private let pageControl = UIPageControl()
    private let startButton = UIButton()
    
    init() {
        // Configure pages
        let page1 = OnboardingPageViewController(
            imageName: "onboarding1",
            title: "그거\n아시나요?",
            description1: NSAttributedString(string: "지구 온난화로 인한 서식지 감소로\n하프물범의 개체수가 지난 30년간 ",
                                             attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.darkGray]),
            description2: NSAttributedString(string: "약 50% 감소했어요.",
                                             attributes: [.font: UIFont.boldSystemFont(ofSize: 16), .foregroundColor: UIColor.systemGreen])
        )
        
        let page2 = OnboardingPageViewController(
            imageName: "onboarding2",
            title: "하프물범\n새봄이가",
            description1: NSAttributedString(string: "온전한 집을 찾을 수 있도록, ",
                                             attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.darkGray]),
            description2: NSAttributedString(string: "다회용기 사용 실천 ",
                                             attributes: [.font: UIFont.boldSystemFont(ofSize: 16), .foregroundColor: UIColor.systemBlue])
        )
        
        let page3 = OnboardingPageViewController(
            imageName: "onboarding3",
            title: "다회용기\n사용의 첫걸음",
            description1: NSAttributedString(string: "DOSIRAK이 도와드릴게요!",
                                             attributes: [.font: UIFont.boldSystemFont(ofSize: 16), .foregroundColor: UIColor.systemGreen]),
            description2: NSAttributedString(string: "",
                                             attributes: [:])
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
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.black

        view.addSubview(pageControl)
        pageControl.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-80)
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
        startButton.isHidden = true // 마지막 페이지에서만 보임

        view.addSubview(startButton)
        startButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.leading.trailing.equalToSuperview().inset(40)
            make.height.equalTo(50)
        }
    }

    @objc private func startButtonTapped() {
        print("Onboarding Completed")
        
        
        AppSettings.isFitstLaunch = false
        let vc = UINavigationController(rootViewController: UserInfoSettingViewController())
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
       
//        let tabBarController = TabbarViewController()
//        let tabBarCoordinator = TabBarCoordinator(tabBarController: tabBarController)
//        tabBarCoordinator.start()
//        
//        // RootViewController 변경
//        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//           let window = windowScene.windows.first {
//            window.rootViewController = tabBarController
//            window.makeKeyAndVisible()
//        } else {
//            print("Error: Unable to fetch UIWindowScene or UIWindow.")
//        }
    }

    // MARK: - UIPageViewController DataSource
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex > 0 else { return nil }
        return pages[currentIndex - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex < pages.count - 1 else { return nil }
        return pages[currentIndex + 1]
    }

    // MARK: - UIPageViewController Delegate
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
            startButton.isHidden = currentIndex != pages.count - 1
        }
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
        // ImageView
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        view.addSubview(imageView)

        // Title Label
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0
        view.addSubview(titleLabel)

        // Description Label 1
        descriptionLabel1.numberOfLines = 0
        view.addSubview(descriptionLabel1)

        // Description Label 2
        descriptionLabel2.numberOfLines = 0
        view.addSubview(descriptionLabel2)
    }

    private func setupConstraints() {
        // Image View
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // Title Label
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(50)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        // Description Label 1
        descriptionLabel1.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        // Description Label 2
        descriptionLabel2.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel1.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
}
