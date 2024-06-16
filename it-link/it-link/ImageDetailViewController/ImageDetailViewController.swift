//
//  ImageDetailViewController.swift
//  it-link
//
//  Created by Александр Воробей on 16.06.2024.
//

import UIKit

class ImageDetailViewController: UIViewController {
    
    private let viewModel = ImageDetailViewModel()
    
    private var imageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .systemBackground
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let key: Int
    private let url: URL
    private let nameFile: String
    
    init(key: Int, url: URL, nameFile: String) {
        self.key = key
        self.url = url
        self.nameFile = nameFile
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        addConstraints()
        getImage()
        setupGesture()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let transform = CGAffineTransformMakeScale(1, 1)
        UIView.animate(withDuration: 0.1) {
            self.view.transform = transform
        }
        
    }
    private func getImage() {
        viewModel.getSavedImage(key: key, nameFile: nameFile) { result in
            switch result {
            case .success(let savedImage):
                self.imageView.image = savedImage
                
            case .failure(_):
                self.viewModel.getImage(url: self.url) { [weak self] result in
                    switch result {
                    case .success(let data):
                        DispatchQueue.main.async {
                            self?.imageView.image = UIImage(data: data)
                        }
                    case .failure(let error):
                        print("Error get image \(error)")
                    }
                }
            }
        }
    }
    
    private func setupGesture() {
        let singleTap = UITapGestureRecognizer()
        singleTap.delaysTouchesBegan = true
        singleTap.addTarget(self, action: #selector(singleTapAction))
        view.addGestureRecognizer(singleTap)
        
        let pinchToZoomGesture = UIPinchGestureRecognizer()
        pinchToZoomGesture.addTarget(self, action: #selector(pinchToZoomGestureAction))
        view.addGestureRecognizer(pinchToZoomGesture)
    }
    
    @objc private func singleTapAction() {
        guard let opacityNavigationController = navigationController?.navigationBar.layer.opacity else { return }
        
        if opacityNavigationController < 1.0 {
            UIView.animate(withDuration: 0.2) {
                self.navigationController?.navigationBar.layer.opacity = 1.0
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.navigationController?.navigationBar.layer.opacity = 0.0
            }
        }
        
    }
    
    @objc private func pinchToZoomGestureAction(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .ended || gesture.state == .changed {
            
            let currentScale = self.view.frame.size.width / self.view.bounds.size.width
            var newScale = currentScale * gesture.scale
            
            if newScale < 1 { newScale = 1 }
            if newScale > 3 { newScale = 3 }
            
            let transform = CGAffineTransformMakeScale(newScale, newScale)
            
            self.view.transform = transform
            gesture.scale = 1
        }
    }
    
    private func addConstraints() {
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
