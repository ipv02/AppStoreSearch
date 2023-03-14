//
//  ITunesResultEntry.swift
//  AppStoreSearch
//
//  Created by Igor P-V on 14.03.2023.
//

import Foundation

struct ITunesResultEntry: Decodable {
    let trackName: String
    let trackId: Int
    let bundleId: String
    let trackViewUrl: String
    let artworkUrl512: String
    let artistName: String
    let screenshotUrls: [String]
    let formattedPrice: String
    let averageUserRating: Double
}
