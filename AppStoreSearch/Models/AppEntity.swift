//
//  AppEntity.swift
//  AppStoreSearch
//
//  Created by Igor P-V on 14.03.2023.
//

import Foundation

struct AppEntity: Hashable {
    let id: Int
    let bundleId: String
    let position: Int
    
    let name: String
    let developer: String
    let rating: Double
    
    let appStoreUrl: URL
    let iconUrl: URL
    let screenshotUrls: [URL]
    
    static func == (lhs: AppEntity, rhs: AppEntity) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
