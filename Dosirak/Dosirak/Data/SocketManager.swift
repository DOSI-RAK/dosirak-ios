//
//  SocketManager.swift
//  Dosirak
//
//  Created by 권민재 on 10/18/24.
//
import RxCocoa
import RxSwift
import SocketIO
import Foundation



class RxSocketManager {
    
    static let shared = RxSocketManager()
    
    private let manager: SocketManager
    private let socket: SocketIOClient
    private let disposeBag = DisposeBag()
    
    private init() {
        self.manager = SocketManager(socketURL: URL(string: "https://yourserver.com")!, config: [.log(true), .compress])
        self.socket = manager.defaultSocket
    }
    
    // 소켓 연결
    func connect() {
        socket.connect()
    }
    
    // 소켓 연결 종료
    func disconnect() {
        socket.disconnect()
    }
    
   
    var isConnected: Observable<Bool> {
        return Observable.create { observer in
            self.socket.on(clientEvent: .connect) { _, _ in
                observer.onNext(true)
            }
            self.socket.on(clientEvent: .disconnect) { _, _ in
                observer.onNext(false)
            }
            return Disposables.create {
                self.socket.off(clientEvent: .connect)
                self.socket.off(clientEvent: .disconnect)
            }
        }
    }
 
//    func emit(event: String, with data: [Any]) -> Observable<Void> {
//        return Observable.create { observer in
//            self.socket.emit(event, with: data)
//            observer.onNext(())
//            observer.onCompleted()
//            return Disposables.create()
//        }
//    }
    
    func on(event: String) -> Observable<[Any]> {
        return Observable.create { observer in
            self.socket.on(event) { (data, ack) in
                observer.onNext(data)
            }
            return Disposables.create {
                self.socket.off(event)
            }
        }
    }
}
