//
//  VideoPlayerViewModel.swift
//  LoadManagement
//
//  Created by Ásmundur Óskar Ásmundsson on 13.11.2024.
//

import Combine
import QuartzCore
import SwiftUI

class VideoPlayerViewModel: ObservableObject {
    @Binding var currentTime: Double
    @Published var isPlaying: Bool = false

    private var displayLink: CADisplayLink?
    private var lastUpdateTime: CFTimeInterval = 0

    init(currentTime: Binding<Double>) {
        self._currentTime = currentTime
    }

    func togglePlayPause() {
        isPlaying.toggle()
        
        if isPlaying {
            startDisplayLink()
        } else {
            stopDisplayLink()
        }
    }

    private func startDisplayLink() {
        lastUpdateTime = CACurrentMediaTime()
        displayLink = CADisplayLink(target: self, selector: #selector(updateCurrentTime))
        displayLink?.add(to: .main, forMode: .default)
    }

    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func updateCurrentTime(displayLink: CADisplayLink) {
        let deltaTime = displayLink.timestamp - lastUpdateTime
        let playbackSpeed: Double = 1.0 // Adjust if needed (1.0 = real-time, 2.0 = 2x speed, etc.)

        currentTime += deltaTime * playbackSpeed
        lastUpdateTime = displayLink.timestamp
    }
}
