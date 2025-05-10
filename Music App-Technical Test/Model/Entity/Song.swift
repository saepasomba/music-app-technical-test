//
//  Song.swift
//  Music App-Technical Test
//
//  Created by Sae Pasomba on 10/05/25.
//

import Foundation

struct SongSearchResponse: Codable {
    var resultCount: Int?
    var results: [Song]?
}

struct Song: Codable, Identifiable {
    var id: Int { trackId ?? 0 }
    var trackId: Int?
    var trackName: String?
    var artistName: String?
    var collectionName: String?
    var previewUrl: String?
    var artworkUrl100: String?
}
