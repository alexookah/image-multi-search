//
//  UIImageView.swift
//  PhotoViewerApp
//
//  Created by Alexandros Lykesas on 28/11/20.
//

import UIKit

extension UIImageView {
    
    func downloadImage(from url: URL) {
        // Generate and execute the request
        APIService.shared.downloadImage(from: url) { (result: Result<UIImage, APIService.APIServiceError>) in
            switch result {
                case .success(let image):
                    DispatchQueue.main.async() { [weak self] in
                        self?.image = image
                    }
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
    }
    
    func downloadImage(from link: String) {
        guard let url = URL(string: link) else { return }
        downloadImage(from: url)
    }
}
