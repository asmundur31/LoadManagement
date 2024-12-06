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
    var dataFrequency: Double = 1.0 // Set your frequency here
    
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
        // Increment currentTime in real-time based on deltaTime and dataFrequency
        currentTime += dataFrequency
        // Update the lastUpdateTime to maintain continuous playback
        lastUpdateTime = displayLink.timestamp
    }
}
