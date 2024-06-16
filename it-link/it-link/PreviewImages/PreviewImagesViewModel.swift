//
//  PreviewImagesViewModel.swift
//  it-link
//
//  Created by Александр Воробей on 16.06.2024.
//

import Foundation

protocol AllphotosViewViewModelDelegate: AnyObject {
    func didLoadPhotosUrls()
}

class PreviewImagesViewModel {
    private let url = "https://it-link.ru/test/images.txt"
    let title = "Images"
    weak var delegate: AllphotosViewViewModelDelegate?
    
    var urlsImages = [URL]()
    
    func getUrlsForPreview() {
        NetworkManager.shared.getImageUrls(url: url) { [weak self] urls in
            self?.urlsImages = urls
            DispatchQueue.main.async {
                self?.delegate?.didLoadPhotosUrls()
            }
            
        }
    }
}
