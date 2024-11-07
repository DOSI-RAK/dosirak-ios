//
//  DIContainer.swift
//  Dosirak
//
//  Created by 권민재 on 10/29/24.
//
import Swinject
import Moya
import KeychainAccess

final class DIContainer {
    static let shared = DIContainer()
    
    private let container: Container
    
    private init() {
        container = Container()
        setupDependencies()
    }
    
    private func setupDependencies() {
        // KakaoProvider 및 NaverProvider 등록
        container.register(KakaoProviderType.self) { _ in KakaoProvider() }
        container.register(NaverProviderType.self) { _ in NaverProvider() }
        
        // API Provider 등록
        container.register(MoyaProvider<UserAPI>.self) { _ in MoyaProvider<UserAPI>() }
        container.register(MoyaProvider<ChatAPI>.self) { _ in MoyaProvider<ChatAPI>() }
        
        // User Repository 등록
        container.register(UserRepositoryType.self) { resolver in
            UserRepository(
                kakaoProvider: resolver.resolve(KakaoProviderType.self)!,
                naverProvider: resolver.resolve(NaverProviderType.self)!,
                apiProvider: resolver.resolve(MoyaProvider<UserAPI>.self)!
            )
        }
        
        // Chat Repository 등록
        container.register(ChatListRepositoryType.self) { resolver in
            ChatListRepository(
                provider: resolver.resolve(MoyaProvider<ChatAPI>.self)!,
                accessToken: Keychain(service: "com.dosirak.user")["accessToken"] ?? ""
            )
        }
        
    
        
        // UseCase 등록
        container.register(LoginUseCaseType.self) { resolver in
            LoginUseCase(userRepository: resolver.resolve(UserRepositoryType.self)!)
        }
        
        container.register(ChatListUseCaseType.self) { resolver in
            ChatListUseCase(chatListRepository: resolver.resolve(ChatListRepositoryType.self)!)
        }
        
       
                
        
        // Reactor 등록
        container.register(LoginReactor.self) { resolver in
            LoginReactor(useCase: resolver.resolve(LoginUseCaseType.self)!)
        }
        
        container.register(UserProfileReactor.self) { resolver in
            UserProfileReactor(useCase: resolver.resolve(LoginUseCaseType.self)!)
        }
        
        container.register(ChatListReactor.self) { resolver in
            ChatListReactor(chatListUseCase: resolver.resolve(ChatListUseCaseType.self)!)
        }
        
        
        
        //MARK: CHAT
        container.register(ChatRepositoryType.self) { (resolver, chatRoomId: Int) in
                let accessToken = Keychain(service: "com.dosirak.user")["accessToken"] ?? ""
                return ChatRepository(chatRoomId: chatRoomId, accessToken: accessToken)
            }
            
            // ChatUseCase
            container.register(ChatUseCaseType.self) { (resolver, chatRoomId: Int) in
                let repository = resolver.resolve(ChatRepositoryType.self, argument: chatRoomId)!
                return ChatUseCase(repository: repository)
            }
            
            // ChatReactor
            container.register(ChatReactor.self) { (resolver, chatRoomId: Int) in
                let useCase = resolver.resolve(ChatUseCaseType.self, argument: chatRoomId)!
                return ChatReactor(useCase: useCase)
            }
            
            // ChatViewController
            container.register(ChatViewController.self) { (resolver, chatRoomId: Int) in
                let reactor = resolver.resolve(ChatReactor.self, argument: chatRoomId)!
                return ChatViewController(reactor: reactor)
            }
        
        
        //MARK: Green Guide
        container.register(GuideRepositoryType.self) { _ in
            GuideRepository()
        }
        
        // GuideUseCaseType 등록
        container.register(GuideUseCaseType.self) { resolver in
            let repository = resolver.resolve(GuideRepositoryType.self)!
            return GuideUseCase(repository: repository)
        }
        
        // GuideReactor 등록
        container.register(GreenGuideReactor.self) { resolver in
            let useCase = resolver.resolve(GuideUseCaseType.self)!
            let accessToken = Keychain(service: "com.dosirak.user")["accessToken"] ?? ""
            return GreenGuideReactor(useCase: useCase, accessToken: accessToken)
        }
        
        
        
        
    }
    
    func resolve<T>(_ type: T.Type) -> T? {
        return container.resolve(type)
    }
    
    func resolve<T, Arg>(_ type: T.Type, argument: Arg) -> T? {
        return container.resolve(type, argument: argument)
    }
}
