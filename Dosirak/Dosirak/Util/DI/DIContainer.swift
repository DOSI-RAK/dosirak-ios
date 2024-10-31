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
    }
    
    func resolve<T>(_ type: T.Type) -> T? {
        return container.resolve(type)
    }
}
