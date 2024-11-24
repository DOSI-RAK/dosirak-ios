//
//  UserInfoSettingViewController.swift
//  Dosirak
//
//  Created by 권민재 on 11/14/24.
//

import UIKit
import RxSwift
import RxCocoa

class UserInfoSettingViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    private var pages = [UIViewController]()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let userAgreeVC = UserAgreeViewController()
        let addressInputVC = AddressInputViewController()
        
        pages = [userAgreeVC, addressInputVC]
        
        setViewControllers([pages[0]], direction: .forward, animated: true, completion: nil)
        
        dataSource = self
        delegate = self
        
        // 스와이프 제스처 비활성화
        disableSwipeGesture()

        // userAgreeVC의 nextButtonTapped 이벤트 감지
        userAgreeVC.nextButtonTapped
            .subscribe(onNext: { [weak self] in
                self?.goToNextPage()
            })
            .disposed(by: disposeBag)
    }
    
    private func disableSwipeGesture() {
        // UIPageViewController의 제스처 인식기를 반복문으로 순회하여 스크롤 관련 제스처를 비활성화합니다.
        for view in self.view.subviews {
            if let scrollView = view as? UIScrollView {
                scrollView.isScrollEnabled = false
            }
        }
    }
    
    private func goToNextPage() {
        guard let currentViewController = viewControllers?.first,
              let currentIndex = pages.firstIndex(of: currentViewController),
              currentIndex < pages.count - 1 else { return }
        
        let nextViewController = pages[currentIndex + 1]
        setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex > 0 else { return nil }
        return pages[currentIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex < pages.count - 1 else { return nil }
        return pages[currentIndex + 1]
    }
}
