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
                List(viewModel.songs, id: \.trackId) { song in
                    songCard(song: song)
                }
            }
        }
        .frame(maxHeight: .infinity)
    }
    
    func songCard(song: Song) -> some View {
        Button(
            action: {
                viewModel.handleSelectSong(song: song)
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
            HStack(spacing: 42) {
                Button {
                    print("PREVIOUS SONG")
                } label: {
                    Image(systemName: "backward.end.alt.fill")
                }
                Button {
                    viewModel.handlePlaySong()
                } label: {
                    Image(systemName: viewModel.isPlaying ? "play.fill" : "pause.fill")
                }
                Button {
                    print("PREVIOUS SONG")
                } label: {
                    Image(systemName: "forward.end.alt.fill")
                }
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
