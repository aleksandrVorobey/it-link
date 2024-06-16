//
//  NetworkManager.swift
//  it-link
//
//  Created by Александр Воробей on 16.06.2024.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    func getImageUrls(url: String, completion: @escaping ([URL]) -> Void) {
        let url = URL(string: url)
        guard let url = url else { return }
        var validUrlsArray = [URL]()
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            let stringURLs = String(data: data, encoding: .utf8)
            guard let stringURLs = stringURLs else { return }
            
            validUrlsArray = stringURLs.components(separatedBy: "\n").compactMap({ url in
                if let urlComponents = URLComponents.init(string: url), urlComponents.host != nil, urlComponents.url != nil {
                    let urlValid = URL(string: url)
                    return urlValid
                }
                return nil
            })
            completion(validUrlsArray)
        }.resume()
    }
    
    func downloadImage(_ url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? URLError(.badServerResponse)))
                return }
            completion(.success(data))
        }.resume()
    }
}
