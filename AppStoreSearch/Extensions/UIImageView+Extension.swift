//
//  UIImageView+Extension.swift
//  AppStoreSearch
//
//  Created by Igor P-V on 14.03.2023.
//

import UIKit
import Foundation

extension UIImageView {
    
    private static let imageLoader = ImageLoaderService(cacheCountLimit: 500)
    
    @MainActor
    func setImage(by url: URL) async throws {
        let image = try await Self.imageLoader.loadImage(for: url)
        
        if !Task.isCancelled {
            self.image = image
        }
    }
}
