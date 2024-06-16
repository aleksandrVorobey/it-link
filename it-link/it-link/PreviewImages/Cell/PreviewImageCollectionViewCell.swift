//
//  PreviewImageCollectionViewCell.swift
//  it-link
//
//  Created by Александр Воробей on 16.06.2024.
//

import UIKit

class PreviewImageCollectionViewCell: UICollectionViewCell {
    static let reuseId = "PreviewImageCollectionViewCell"
    let cacheManager = ImagesCacheManager.shared
    
    private var previewView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .systemBackground
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private var activityIndicator = {
        let activity = UIActivityIndicatorView()
        activity.translatesAutoresizingMaskIntoConstraints = false
        activity.isHidden = true
        return activity
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configPreviewView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        previewView.image = nil
    }
    
    private func configPreviewView() {
        addSubview(previewView)
        addSubview(activityIndicator)
        NSLayoutConstraint.activate([
        previewView.topAnchor.constraint(equalTo: self.topAnchor),
        previewView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        previewView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
        previewView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func configCell(url: URL, index: Int, nameFileForPreview: String, nameFileForOriginal: String) {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        if let savedImage = cacheManager.get(key: index, nameFile: nameFileForPreview) {
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
            previewView.image = savedImage
        } else {
            NetworkManager.shared.downloadImage(url) { [weak self] result in
                switch result {
                case .success(let data):
                    guard let image = UIImage(data: data) else {return}
                    self?.cacheManager.add(key: index, value: image, nameFile: nameFileForOriginal)
                    if let preview = image.preparingThumbnail(of: CGSize(width: 100, height: 100)) {
                        self?.cacheManager.add(key: index, value: preview, nameFile: nameFileForPreview)
                        DispatchQueue.main.async {
                            self?.activityIndicator.isHidden = true
                            self?.activityIndicator.stopAnimating()
                            self?.previewView.image = preview
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    break
                }
            }
        }
    }
}
