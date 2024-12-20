//
//  SceneDelegate.swift
//  Dosirak
//
//  Created by 권민재 on 10/17/24.
//

import UIKit
import RxKakaoSDKAuth
import KakaoSDKAuth
import NaverThirdPartyLogin



class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        window.overrideUserInterfaceStyle = .light

        let appCoordinator = AppCoordinator()
        self.appCoordinator = appCoordinator
        self.window = window
        appCoordinator.start(window: window)

        // UINavigationBar Appearance 설정
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .bgColor // 네비게이션 바 배경색
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black] // 기본 제목 색상
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black] // 큰 제목 색상

        // 뒤로가기 버튼 아이콘 설정
        let backImage = UIImage(systemName: "chevron.left") // 원하는 아이콘
        backImage?.withTintColor(.black)
        appearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)

        // Appearance 적용
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = .black

        // 네비게이션 바 투명도 설정
        UINavigationBar.appearance().isTranslucent = false

        // 뒤로가기 버튼 텍스트 숨기기
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(
            UIOffset(horizontal: -1000, vertical: 0),
            for: .default
        )

        window.makeKeyAndVisible()
    }


    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if (AuthApi.isKakaoTalkLoginUrl(url)) {
            return AuthController.rx.handleOpenUrl(url: url)
        }
        
        return false
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
      NaverThirdPartyLoginConnection
        .getSharedInstance()?
        .receiveAccessToken(URLContexts.first?.url)
    }


    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }




}
