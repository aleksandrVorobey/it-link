//
//  ImageDetailViewModel.swift
//  it-link
//
//  Created by Александр Воробей on 16.06.2024.
//

import Foundation
import UIKit

enum GetImageError: Error {
    case getImageError
}

class ImageDetailViewModel {
    
    func getSavedImage(key: Int, nameFile: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        if let savedImage = ImagesCacheManager.shared.get(key: key, nameFile: nameFile) {
            completion(.success(savedImage))
        } else {
            completion(.failure(GetImageError.getImageError))
        }
    }
    
    func getImage(url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        NetworkManager.shared.downloadImage(url) { result in
            switch result {
            case .success(let image):
                completion(.success(image))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
