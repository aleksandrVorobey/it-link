//
//  ViewController.swift
//  it-link
//
//  Created by Александр Воробей on 16.06.2024.
//

import UIKit

class PreviewImagesViewController: UIViewController {
    enum ItemsPerRow: CGFloat {
        case portrait = 4
        case landscape = 8
    }
    private lazy var itemsPerRow = UIDevice.current.orientation == .portrait ? ItemsPerRow.portrait.rawValue : ItemsPerRow.landscape.rawValue
    private let sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    private let viewModel = PreviewImagesViewModel()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PreviewImageCollectionViewCell.self, forCellWithReuseIdentifier: PreviewImageCollectionViewCell.reuseId)
        return collectionView
    }()
    
    private lazy var activityIndicator = {
        let activity = UIActivityIndicatorView()
        activity.translatesAutoresizingMaskIntoConstraints = false
        activity.isHidden = true
        return activity
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        viewModel.delegate = self
        addConstraints()
        viewModel.getUrlsForPreview()
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        navigationItem.title = viewModel.title
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func addConstraints() {
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        itemsPerRow = UIDevice.current.orientation == .portrait ? ItemsPerRow.portrait.rawValue : ItemsPerRow.landscape.rawValue
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

// MARK: UICollectionViewDelegate
extension PreviewImagesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let urlForImage = viewModel.urlsImages[indexPath.row]
        let vc = ImageDetailViewController(key: indexPath.row, url: urlForImage, nameFile: NameFile.originalFile.rawValue)
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: UICollectionViewDataSource
extension PreviewImagesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.urlsImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PreviewImageCollectionViewCell.reuseId, for: indexPath) as! PreviewImageCollectionViewCell
        let urlForPreview = viewModel.urlsImages[indexPath.row]
        cell.configCell(url: urlForPreview, index: indexPath.row,  nameFileForPreview: NameFile.previewFile.rawValue, nameFileForOriginal: NameFile.originalFile.rawValue)
        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension PreviewImagesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let paddingWidth = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = collectionView.frame.width - paddingWidth
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

// MARK: AllphotosViewViewModelDelegate
extension PreviewImagesViewController: AllphotosViewViewModelDelegate {
    func didLoadPhotosUrls() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        self.collectionView.reloadData()
    }
}

