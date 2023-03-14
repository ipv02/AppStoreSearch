//
//  ITunesResultsEntry.swift
//  AppStoreSearch
//
//  Created by Igor P-V on 14.03.2023.
//

import Foundation

struct ITunesResultsEntry: Decodable {
    let results: [ITunesResultEntry]
}
