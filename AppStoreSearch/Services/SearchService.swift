//
//  SearchService.swift
//  AppStoreSearch
//
//  Created by Igor P-V on 14.03.2023.
//

import Foundation

actor SearchService {
    
    func search(with query: String) async throws -> [AppEntity] {
        let url = buildSearchRequest(for: query)
        let urlRequest = URLRequest(url: url)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let
                response = response as? HTTPURLResponse,
                response.statusCode == 200
        else {
            throw URLError(.badServerResponse)
        }
        
        let result = try JSONDecoder().decode(ITunesResultsEntry.self, from: data)
        
        let entites = result.results
            .enumerated()
            .compactMap { item -> AppEntity? in
                let (position, entry) = item
                return convert(entry: entry, position: position)
            }
        
        return entites
    }
}

private extension SearchService {
    
    static let baseUrlStr = "https://itunes.apple.com"
    
    func buildSearchRequest(for query: String) -> URL {
        var components = URLComponents(string: Self.baseUrlStr)
        
        components?.path = "/search"
        components?.queryItems = [
            URLQueryItem(name: "entity", value: "software"),
            URLQueryItem(name: "term", value: query)
        ]
        
        guard let url = components?.url else {
            fatalError("developer error: cannot build url for search request: query=\"(query)\"")
        }
        
        return url
    }
    
    func convert(entry: ITunesResultEntry, position: Int) -> AppEntity? {
        guard
            let appStoreUrl = URL(string: entry.trackViewUrl),
            let iconUrl = URL(string: entry.artworkUrl512)
        else {
            return nil
        }
        
        return AppEntity(
            id: entry.trackId,
            bundleId: entry.bundleId,
            position: position,
            name: entry.trackName,
            developer: entry.artistName,
            rating: entry.averageUserRating,
            appStoreUrl: appStoreUrl,
            iconUrl: iconUrl,
            screenshotUrls: entry.screenshotUrls.compactMap { URL(string: $0) }
        )
    }
}
