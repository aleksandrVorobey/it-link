//
//  ImagesCacheManager.swift
//  it-link
//
//  Created by Александр Воробей on 16.06.2024.
//

import Foundation
import UIKit

enum NameFile: String {
    case previewFile = "preview.png"
    case originalFile = "original.png"
}

class ImagesCacheManager {
    static let shared = ImagesCacheManager()
    private init() {
        createFolderIfNeeded()
    }
    
    let folderName = "downloaded_images"
    
    private func createFolderIfNeeded() {
        guard let url = getFolderPath() else { return }
        
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
                print("Create Folder")
            } catch let error {
                print("Error creating folder. \(error)")
            }
        }
    }
    
    private func getFolderPath() -> URL? {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent(folderName)
    }
    
    func add(key: Int, value: UIImage, nameFile: String) {
        guard let data = value.pngData(), let url = getFolderPath() else { return  }
        
        do {
            let imageFolder = url.appending(path: "\(key)")
            try FileManager.default.createDirectory(at: imageFolder, withIntermediateDirectories: true)
            try data.write(to: imageFolder.appending(path: "\(nameFile)"))
        } catch let error {
            print("Error saving to File Manager. \(error)")
        }
    }
    
    func get(key: Int, nameFile: String) -> UIImage? {
        guard let url = getFolderPath()?.appending(path: "\(key)").appending(path: "\(nameFile)"), FileManager.default.fileExists(atPath: url.path) else { return nil }
        return UIImage(contentsOfFile: url.path)
    }
    
}
