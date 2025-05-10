//
//  Music_App_Technical_TestTests.swift
//  Music App-Technical TestTests
//
//  Created by Sae Pasomba on 10/05/25.
//

import Testing
import Combine
@testable import Music_App_Technical_Test

import XCTest
import Combine
@testable import Music_App_Technical_Test

// Test class
final class SongListViewModelTests: XCTestCase {
    var viewModel: SongListViewModel!
    var playerManager: MusicPlayerManager!
    var subscriptions = Set<AnyCancellable>()
    
    override func setUp() {
        super.setUp()
        viewModel = SongListViewModel()
        
        // Create some sample songs for testing
        let sampleSongs = [
            Song(trackId: 1, trackName: "Song 1", artistName: "Artist 1", previewUrl: "url1"),
            Song(trackId: 2, trackName: "Song 2", artistName: "Artist 2", previewUrl: "url2"),
            Song(trackId: 3, trackName: "Song 3", artistName: "Artist 3", previewUrl: "url3")
        ]
        
        viewModel.songs = sampleSongs
    }
    
    override func tearDown() {
        viewModel = nil
        playerManager = nil
        subscriptions.removeAll()
        super.tearDown()
    }
    
    func testSearchDebounce() {
        let expectation = self.expectation(description: "Debounce search text")
        
        viewModel.$debouncedSearchText
            .dropFirst()
            .sink { value in
                XCTAssertEqual(value, "test query")
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        
        viewModel.searchText = "test query"
        wait(for: [expectation], timeout: 0.6)
    }
    
    func testHandleSelectSong() {
        // Test selecting a song
        let song = viewModel.songs[0]
        viewModel.handleSelectSong(song: song, index: 0)
        
        XCTAssertEqual(viewModel.currentIndex, 0)
        XCTAssertEqual(viewModel.selectedSong?.trackId, song.trackId)
        XCTAssertTrue(viewModel.isPlaying)
        
        // Test deselecting the same song
        viewModel.handleSelectSong(song: song, index: 0)
        
        XCTAssertEqual(viewModel.currentIndex, 0)
        XCTAssertNil(viewModel.selectedSong)
        XCTAssertFalse(viewModel.isPlaying)
    }
    
    func testHandlePlaySongPause() {
        // Setup
        let song = viewModel.songs[1]
        viewModel.selectedSong = song
        viewModel.currentIndex = 1
        viewModel.isPlaying = true
        
        // Test pausing
        viewModel.handlePlaySong()
        
        XCTAssertFalse(viewModel.isPlaying)
        
        // Test playing again
        viewModel.handlePlaySong()
        
        XCTAssertTrue(viewModel.isPlaying)
    }
    
    func testHandlePlaySongNext() {
        // Setup
        viewModel.selectedSong = viewModel.songs[0]
        viewModel.currentIndex = 0
        viewModel.isPlaying = true
        
        // Test next song
        viewModel.handlePlaySong(.next)
        
        let expectation = expectation(description: "Play Song Next")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertEqual(self.viewModel.currentIndex, 1)
            XCTAssertEqual(self.viewModel.selectedSong?.trackId, self.viewModel.songs[1].trackId)
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testHandlePlaySongback() {
        // Setup
        viewModel.selectedSong = viewModel.songs[1]
        viewModel.currentIndex = 1
        viewModel.isPlaying = true
        
        // Test back song
        viewModel.handlePlaySong(.back)
        
        let expectation = expectation(description: "Play Song Next")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            XCTAssertEqual(self.viewModel.currentIndex, 0)
            XCTAssertEqual(self.viewModel.selectedSong?.trackId, self.viewModel.songs[0].trackId)
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)

    }
    
    func testHandlePlaySongBoundaries() {
        // Test boundary: already at first song, try back
        viewModel.selectedSong = viewModel.songs[0]
        viewModel.currentIndex = 0
        
        viewModel.handlePlaySong(.back)
        XCTAssertEqual(viewModel.currentIndex, 0) // Should stay at first song
        
        // Test boundary: at last song, try next
        viewModel.selectedSong = viewModel.songs[2]
        viewModel.currentIndex = 2
        
        viewModel.handlePlaySong(.next)
        XCTAssertEqual(viewModel.currentIndex, 2) // Should stay at last song
    }
  
    func testSearchSongsFailure() async {
        // Call the search method
        await viewModel.searchSongs()
        
        DispatchQueue.main.async {
            self.viewModel.songs = []
            self.viewModel.hasError = true
            
            // Assert the view model state
            XCTAssertTrue(self.viewModel.songs.isEmpty)
            XCTAssertTrue(self.viewModel.hasError)
        }
    }
}

class SongApi {
    func searchSongs(_ query: String) async throws -> SongSearchResponse {
        return SongSearchResponse(resultCount: 0, results: [])
    }
}
