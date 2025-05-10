//
//  ContentView.swift
//  Music App-Technical Test
//
//  Created by Sae Pasomba on 10/05/25.
//

import SwiftUI
import AVFoundation

struct SongListView: View {
    @StateObject var viewModel: SongListViewModel = SongListViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            songSearchBar()
            songList()
            songControlSection()
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    func songSearchBar() -> some View {
        VStack {
            HStack {
                TextField(
                    "Search Song",
                    text: $viewModel.searchText
                )
                .textFieldStyle(.roundedBorder)
            }
            .padding()
            .background(Color.gray.opacity(0.2))
        }
        .onChange(of: viewModel.debouncedSearchText) {
            Task {
                await viewModel.searchSongs()
            }
        }
        .onAppear {
            Task {
                await viewModel.searchSongs()
            }
        }
    }
    
    @ViewBuilder
    func songList() -> some View {
        Group {
            if viewModel.debouncedSearchText.isEmpty {
                Text("Search for a song!")
            } else if viewModel.apiState == .loading {
                Text("Loading...")
            } else if viewModel.songsSearchResult?.resultCount == 0 && viewModel.apiState == .finished {
                Text("No song found!")
            } else {
                List(Array(viewModel.songs.enumerated()), id: \.element.trackId) { index, song in
                    songCard(song: song, index: index)
                }
            }
        }
        .frame(maxHeight: .infinity)
    }
    
    func songCard(song: Song, index: Int) -> some View {
        Button(
            action: {
                viewModel.handleSelectSong(song: song, index: index)
            }, label: {
                HStack {
                    AsyncImage(url: URL(string: song.artworkUrl100 ?? "")) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray.opacity(0.2)
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(.rect(cornerRadius: 5))
                    VStack(alignment: .leading) {
                        Text(song.trackName ?? "Unknown")
                            .font(.subheadline)
                            .lineLimit(2)
                        Text(song.artistName ?? "Unknown")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        Text(song.collectionName ?? "Unknown")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    if viewModel.selectedSong?.trackId == song.trackId {
                        Image(systemName: "waveform.path")
                    }
                }
                .tint(.primary)
            }
        )
    }
    
    @ViewBuilder
    func songControlSection() -> some View {
        if viewModel.selectedSong != nil {
            VStack {
                HStack(spacing: 42) {
                    Button {
                        viewModel.handlePlaySong(.back)
                    } label: {
                        Image(systemName: "backward.end.alt.fill")
                    }
                    Button {
                        viewModel.handlePlaySong()
                    } label: {
                        Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                    }
                    Button {
                        viewModel.handlePlaySong(.next)
                    } label: {
                        Image(systemName: "forward.end.alt.fill")
                    }
                }
                
                Slider(value: .constant(viewModel.musicPlayerManager.currentTime))
                    .padding(.horizontal)
                    .padding(.top)
            }
            .font(.title)
            .padding(.vertical)
            .padding(.top)
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.2))
        }
    }
}

#Preview {
    SongListView()
}
