//
//  EditNickNameViewModel.swift
//  Dosirak
//
//  Created by 권민재 on 11/16/24.
//

import Foundation
import RxSwift
import RxCocoa

class EditNicknameViewModel {
    // Input
    let nicknameInput = BehaviorRelay<String>(value: "")
    let submitTapped = PublishSubject<Void>()

    // Output
    let isLoading = BehaviorRelay<Bool>(value: false)
    let successMessage = PublishSubject<String>()
    let errorMessage = PublishSubject<String>()
    let nicknameValidationMessage = BehaviorRelay<String>(value: "")
    let isSaveButtonEnabled = BehaviorRelay<Bool>(value: false)
    
    private let disposeBag = DisposeBag()

    init() {
        // Debounce nickname input for validation
        nicknameInput
            .distinctUntilChanged() // Prevent duplicate checks for the same nickname
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .flatMapLatest { [weak self] nickname in
                self?.validateNickname(nickname: nickname) ?? .empty()
            }
            .subscribe(onNext: { [weak self] result in
                self?.isLoading.accept(false)
                switch result {
                case .success(let message):
                    self?.nicknameValidationMessage.accept(message)
                    self?.isSaveButtonEnabled.accept(true) // Enable button on success
                case .failure(let error):
                    self?.nicknameValidationMessage.accept("사용할 수 없는 닉네임입니다.")
                    self?.isSaveButtonEnabled.accept(false) // Disable button on failure
                    self?.errorMessage.onNext(error.localizedDescription)
                }
            })
            .disposed(by: disposeBag)
        
        // Bind submit button tap to nickname saving
        submitTapped
            .withLatestFrom(nicknameInput) // Use the latest nickname input
            .filter { !$0.isEmpty } // Ensure the nickname is not empty
            .flatMapLatest { [weak self] nickname in
                self?.sendNicknameToServer(nickname: nickname) ?? .empty()
            }
            .subscribe(onNext: { [weak self] result in
                self?.isLoading.accept(false)
                switch result {
                case .success:
                    self?.successMessage.onNext("닉네임이 성공적으로 저장되었습니다.")
                case .failure(let error):
                    self?.errorMessage.onNext(error.localizedDescription)
                }
            })
            .disposed(by: disposeBag)
    }

    private func sendNicknameToServer(nickname: String?) -> Observable<Result<Void, Error>> {
        return Observable<Result<Void, Error>>.create { observer in
            self.isLoading.accept(true)
            
            guard let url = URL(string: "http://dosirak.store/api/user/nickName") else {
                observer.onNext(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
                observer.onCompleted()
                return Disposables.create()
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let token = UserDefaults.standard.string(forKey: "accessToken") {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            
            let body: [String: Any] = ["nickName": nickname ?? nil]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

            let task = URLSession.shared.dataTask(with: request) { _, response, error in
                if let error = error {
                    observer.onNext(.failure(error))
                } else if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    observer.onNext(.success(()))
                } else {
                    observer.onNext(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unexpected response"])))
                }
                observer.onCompleted()
            }
            task.resume()

            return Disposables.create {
                task.cancel()
            }
        }
    }

    private func validateNickname(nickname: String) -> Observable<Result<String, Error>> {
        return Observable<Result<String, Error>>.create { observer in
            self.isLoading.accept(true)
            
            guard let url = URL(string: "http://dosirak.store/api/user/check-nickName?nickName=\(nickname.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else {
                observer.onNext(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
                observer.onCompleted()
                return Disposables.create()
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            if let token = AppSettings.accessToken {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    observer.onNext(.failure(error))
                } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let message = json["message"] as? String {
                            observer.onNext(.success(message))
                        } else {
                            observer.onNext(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response data"])))
                        }
                    } catch {
                        observer.onNext(.failure(error))
                    }
                } else {
                    observer.onNext(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unexpected response"])))
                }
                observer.onCompleted()
            }
            task.resume()

            return Disposables.create {
                task.cancel()
            }
        }
    }
}
