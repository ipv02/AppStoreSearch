//
//  ImageLoaderService.swift
//  AppStoreSearch
//
//  Created by Igor P-V on 14.03.2023.
//

import UIKit
import Foundation

actor ImageLoaderService {
    
    private var cache = NSCache<NSURL, UIImage>()
    
    init(cacheCountLimit: Int) {
        cache.countLimit = cacheCountLimit
    }
    
    func loadImage(for url: URL) async throws -> UIImage {
        if let image = lookUpCache(for: url) {
            return image
        }
        
        let image = try await doLoadImage(for: url)
        
        updateCache(image: image, and: url)
        
        return image
    }
}

private extension ImageLoaderService {
    
    func lookUpCache(for url: URL) -> UIImage? {
        cache.object(forKey: url as NSURL)
    }
    
    func doLoadImage(for url: URL) async throws -> UIImage {
        let urlRequest = URLRequest(url: url)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        guard let image = UIImage(data: data) else {
            throw URLError(.cannotDecodeContentData)
        }
        
        return image
    }
    
    func updateCache(image: UIImage, and url: URL) {
        if cache.object(forKey: url as NSURL) == nil {
            cache.setObject(image, forKey: url as NSURL)
        }
    }
}
