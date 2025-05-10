//
//  Api.swift
//  Music App-Technical Test
//
//  Created by Sae Pasomba on 10/05/25.
//

import Foundation

struct SongApi {
    func searchSongs(_ term: String) async throws -> SongSearchResponse {
        guard let url = URL(string: "https://itunes.apple.com/search?term=\(term)&media=music") else {
            throw APIError.invalidUrl
        }
        
        guard let (data, response) = try? await URLSession.shared.data(from: url) else {
            throw APIError.requestError
        }
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw APIError.statusNotOk
        }
        
        guard let result = try? JSONDecoder().decode(SongSearchResponse.self, from: data) else {
            throw APIError.decodingError
        }
        
        return result
    }
}
