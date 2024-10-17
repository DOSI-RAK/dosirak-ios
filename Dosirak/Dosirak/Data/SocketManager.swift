//
//  SocketManager.swift
//  Dosirak
//
//  Created by 권민재 on 10/18/24.
//
import RxCocoa
import RxSwift
import SocketIO

final class SocketManager {
    
    let user = PublishRelay<[Any]>()
    let activities = PublishRelay<[Any]>()
    
    let socketConnection = PublishRelay<Bool>()
    
    static let shared = SocketManager()
    
    
    
}
