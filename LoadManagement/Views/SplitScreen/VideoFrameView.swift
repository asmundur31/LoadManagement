//
//  VideoFrameView.swift
//  LoadManagement
//
//  Created by Ásmundur Óskar Ásmundsson on 8.11.2024.
//

import SwiftUI
import AVKit

struct VideoPlayerViewController: UIViewControllerRepresentable {
    var player: AVPlayer?

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.showsPlaybackControls = true // Show playback controls
        return playerViewController
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player
    }
}

struct VideoFrameView: View {
    @Environment(RecordingViewModel.self) var recordingViewModel: RecordingViewModel

    @Binding var currentTime: Double
    @State private var player: AVPlayer? = nil
    @State private var currentSegment: VideoData? = nil
    var playbackSpeed = 4.0

    var body: some View {
        VStack {
            if let player = player {
                VideoPlayerViewController(player: player)
            } else {
                // Placeholder view
                Color.black
                    .aspectRatio(16/9, contentMode: .fit)
                    .overlay(
                        Text("No Video Available")
                            .foregroundColor(.white)
                            .font(.headline)
                    )
            }
        }
        .onChange(of: currentTime) { _, newTime in
            DispatchQueue.main.async {
                updateVideoPlayer(for: newTime)
            }
        }
    }

    private func updateVideoPlayer(for time: Double) {
        guard let videoSegment = recordingViewModel.recording?.videos.first(where: { segment in
            let adjustedStart = segment.startTime + segment.startTimeAdjustment
            let adjustedEnd = adjustedStart + segment.duration
            return time >= adjustedStart && time <= adjustedEnd
        }) else {
            // No matching segment, clear the player
            if player != nil {
                player?.pause()
                player = nil
                currentSegment = nil
            }
            return
        }

        if currentSegment?.url != videoSegment.url {
            // If it's a new segment, replace the current item instead of creating a new player
            if let existingPlayer = player {
                let newItem = AVPlayerItem(url: videoSegment.url)
                existingPlayer.replaceCurrentItem(with: newItem)
            } else {
                player = AVPlayer(url: videoSegment.url)
            }
            currentSegment = videoSegment
        }

        // Seek to the correct position
        let segmentRelativeTime = time - (videoSegment.startTime + videoSegment.startTimeAdjustment)
        let cmTime = CMTime(seconds: segmentRelativeTime*videoSegment.playbackSpeed, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.seek(to: cmTime, toleranceBefore: CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), toleranceAfter: CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
    }
}


#Preview {
    @Previewable @State var previewCurrentTime: Double = 0.0
    @Previewable @State var previewTimeWindow: Double = 10.0
    @Previewable @State var previewDataCategory: String = "Acc"
    @Previewable @State var previewSensor: Int = 0

    VStack {
        VideoFrameView(
            currentTime: $previewCurrentTime
        )
        CustomToolbar(
            currentTime: $previewCurrentTime,
            currentTimeWindow: $previewTimeWindow,
            currentDataCategory: $previewDataCategory,
            currentSensor: $previewSensor
        )
    }
    
}

