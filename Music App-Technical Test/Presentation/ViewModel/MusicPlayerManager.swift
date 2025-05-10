//
//  MusicPlayerManager.swift
//  Music App-Technical Test
//
//  Created by Sae Pasomba on 10/05/25.
//

import Foundation
import AVFoundation

class MusicPlayerManager: ObservableObject {
    static let shared = MusicPlayerManager()
    private var player: AVPlayer?
    
    func play(song: Song) {
        stop()
        guard let previewUrl = song.previewUrl, let url = URL(string: previewUrl) else { return }
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        player?.play()
    }
    func pause() {
        player?.pause()
    }
    func stop() {
        player?.pause()
        player = nil
    }
}
