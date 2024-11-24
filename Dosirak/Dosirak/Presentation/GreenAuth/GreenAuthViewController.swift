//
//  GreenAuthViewController.swift
//  Dosirak
//
//  Created by 권민재 on 11/23/24.
//

import UIKit
import CoreML
import Vision
import SnapKit

class GreenAuthViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        presentCamera() // 뷰 로드 시 바로 카메라 실행
    }
    
    private func presentCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func classifyImage(_ image: UIImage) {
        guard let model = try? VNCoreMLModel(for: DisposableModel().model) else {
            showFailureScreen(reason: "모델 로드 실패")
            return
        }

        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let self = self else { return }
            if let results = request.results as? [VNClassificationObservation],
               let topResult = results.first {
                DispatchQueue.main.async {
                    if topResult.identifier == "lunchbox" && topResult.confidence > 0.7 {
                        self.showSuccessScreen(exp: Int(topResult.confidence * 100))
                    } else {
                        self.showFailureScreen(reason: "다회용기가 확인되지 않았습니다.")
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.showFailureScreen(reason: "이미지를 분석할 수 없습니다.")
                }
            }
        }

        guard let ciImage = CIImage(image: image) else {
            showFailureScreen(reason: "이미지를 처리할 수 없습니다.")
            return
        }

        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    self.showFailureScreen(reason: "분류 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func showSuccessScreen(exp: Int) {
        let successVC = GreenAuthSuccessViewController()
        successVC.expPoints = exp
        successVC.modalPresentationStyle = .fullScreen
        present(successVC, animated: true, completion: nil)
    }

    private func showFailureScreen(reason: String) {
        let failureVC = GreenAuthFailureViewController()
        failureVC.reason = reason
        failureVC.modalPresentationStyle = .fullScreen
        present(failureVC, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            classifyImage(selectedImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
