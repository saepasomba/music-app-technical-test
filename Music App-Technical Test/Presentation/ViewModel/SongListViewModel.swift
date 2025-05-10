//
//  SongListViewModel.swift
//  Music App-Technical Test
//
//  Created by Sae Pasomba on 10/05/25.
//

import Foundation
import AVFoundation

class SongListViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var debouncedSearchText: String = ""
    
    @Published var songsSearchResult: SongSearchResponse?
    @Published var songs: [Song] = []
    @Published var hasError: Bool = false
    @Published var apiState: ApiState = .initial
    
    @Published var selectedSong: Song?
    @Published var isPlaying: Bool = false
    @Published var musicPlayerManager = MusicPlayerManager.shared
    @Published var currentIndex: Int?
    
    var audioPlayer: AVPlayer?
    
    init() {
        setupSearchDebounce()
    }
    
    func setupSearchDebounce() {
        debouncedSearchText = self.searchText
        $searchText
            .debounce(for: .seconds(0.50), scheduler: RunLoop.main)
            .assign(to: &$debouncedSearchText)
    }
    
    func handleSelectSong(song: Song, index: Int) {
        currentIndex = index
        
        if selectedSong?.trackId == song.trackId {
            isPlaying = false
            selectedSong = nil
        } else {
            selectedSong = song
            isPlaying = true
        }
        
        if isPlaying {
            musicPlayerManager.play(song: song)
        } else {
            musicPlayerManager.pause()
        }
    }
    
    func handlePlaySong(_ musicControl: MusicControl = .playPause) {
        if musicControl == .playPause {
            guard let selectedSong = selectedSong else { return }
            isPlaying.toggle()
            if isPlaying {
                musicPlayerManager.play(song: selectedSong)
            } else {
                musicPlayerManager.pause()
            }
        } else {
            guard let currentIndex = currentIndex else { return }
            var targetindex = musicControl == .next ? currentIndex + 1 : currentIndex - 1
            targetindex = targetindex < 0 ? 0 : targetindex
            targetindex = targetindex >= songs.count ? songs.count - 1 : targetindex
            let targetSong: Song = songs[targetindex]
            DispatchQueue.main.async {
                self.selectedSong = targetSong
                self.currentIndex = targetindex
            }
            musicPlayerManager.play(song: targetSong)
        }
    }
    
    @MainActor
    func searchSongs() async {
        apiState = .loading
        guard let data = try? await SongApi().searchSongs(debouncedSearchText) else {
            self.songs = []
            self.hasError = true
            return
        }
        self.songs = data.results ?? []
        self.songsSearchResult = data
        apiState = .finished
    }
}
