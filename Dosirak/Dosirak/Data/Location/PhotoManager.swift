//
//  PhotoManager.swift
//  Dosirak
//
//  Created by 권민재 on 11/4/24.

import Foundation
import Photos
import RxSwift
import UIKit

class PhotoManager {
    static let shared = PhotoManager()
    
    private let photoSubject = PublishSubject<[UIImage]>()
    
    var photos: Observable<[UIImage]> {
        return photoSubject.asObservable()
    }
    
    private init() {
       
    }
    

    func fetchPhotos() {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                self.loadPhotos()
            } else {
                self.photoSubject.onError(NSError(domain: "Photo Access Denied", code: 1, userInfo: nil))
            }
        }
    }
    
    private func loadPhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        var images: [UIImage] = []
        
        let imageManager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        
        fetchResult.enumerateObjects { asset, _, _ in
            imageManager.requestImage(for: asset, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFit, options: options) { image, _ in
                if let image = image {
                    images.append(image)
                }
                
                if images.count == fetchResult.count {
                    self.photoSubject.onNext(images)
                    self.photoSubject.onCompleted()
                }
            }
        }
    }
}
