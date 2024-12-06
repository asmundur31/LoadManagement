//
//  DataViewModel.swift
//  LoadManagement
//
//  Created by Ásmundur Óskar Ásmundsson on 7.11.2024.
//

import Foundation
import AVFoundation

@Observable
class DataViewModel {
    func getSensors(directoryUrl: URL) -> [Sensor] {
        var sensors: [Sensor] = []
        let fileManager = FileManager.default
        
        guard directoryUrl.startAccessingSecurityScopedResource() else {
            print("Failed to access security-scoped resource for the directory")
            return []
        }
        defer { directoryUrl.stopAccessingSecurityScopedResource() }
        
        do {
            // Now we try to open the given directory url
            let sensorFolders = try fileManager.contentsOfDirectory(at: directoryUrl, includingPropertiesForKeys: [.isDirectoryKey], options: .skipsHiddenFiles)
            for sensorFolder in sensorFolders {
                let resourceValues = try sensorFolder.resourceValues(forKeys: [.isDirectoryKey])
                if resourceValues.isDirectory == true {
                    var accData: [String] = []
                    var gyroData: [String] = []
                    var magnData: [String] = []
                    do {
                        // Now we try to open the sensor folder
                        let dataFiles = try fileManager.contentsOfDirectory(at: sensorFolder, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                        for dataFile in dataFiles {
                            if dataFile.pathExtension.lowercased() == "csv" { // Check if file is csv
                                do {
                                    // Now we try getting the content of each data file
                                    let content = try String(contentsOf: dataFile, encoding: .utf8)
                                    let lines = content.components(separatedBy: .newlines)
                                    let data = lines.dropFirst(2).filter { !$0.isEmpty }
                                    if dataFile.lastPathComponent.lowercased().hasPrefix("acc") {
                                        accData = data
                                    } else if dataFile.lastPathComponent.lowercased().hasPrefix("gyro") {
                                        gyroData = data
                                    } else if dataFile.lastPathComponent.lowercased().hasPrefix("magn") {
                                        magnData = data
                                    }
                                } catch {
                                    print("Error reading file \(dataFile.lastPathComponent): \(error.localizedDescription)")
                                }
                            }
                        }
                    } catch {
                        print("Error reading file \(sensorFolder.lastPathComponent): \(error.localizedDescription)")
                    }
                    let data = SensorData.convertData(accData: accData, gyroData: gyroData, magnData: magnData)
                    sensors.append(Sensor(id: sensorFolder.lastPathComponent, frequency: data.frequency, data: data.sensorData))
                }
            }
        } catch {
            print("Error reading directory: \(error.localizedDescription)")
        }

        return sensors
    }
        
    func getVideos(directoryUrl: URL) async -> [VideoData] {
        let fileManager = FileManager.default
        var videoAnnotationLines: [(Double, String)] = []
        
        guard directoryUrl.startAccessingSecurityScopedResource() else {
            print("Failed to access security-scoped resource for the directory")
            return []
        }
        defer { directoryUrl.stopAccessingSecurityScopedResource() }
        
        // Start by opening the annotation file
        do {
            // Get all files in the directory
            let files = try fileManager.contentsOfDirectory(at: directoryUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            // Find the first file that starts with "Annotations" and has a .csv extension
            if let annotationFile = files.first(where: { $0.lastPathComponent.hasPrefix("Annotations") && $0.pathExtension.lowercased() == "csv" }) {
                // Read the content of the CSV file
                let content = try String(contentsOf: annotationFile, encoding: .utf8)
                let lines = content.components(separatedBy: .newlines).filter { !$0.isEmpty } // Split into lines, ignoring empty lines
                let data = lines.dropFirst(2)
                let typeIndex = 1
                for line in data {
                    let values = line.components(separatedBy: ",")
                    if values.count > typeIndex && values[typeIndex].contains("VideoAnnotation") {
                        videoAnnotationLines.append((Double(values[0])!, values[1]))
                    }
                }
            } else {
                print("No file starting with 'Annotations' and ending in .csv found.")
                return []
            }
        } catch {
            print("Error reading directory or file: \(error.localizedDescription)")
            return []
        }
        var videoData: [VideoData] = []
        do {
            // Get all video files in the directory
            let files = try fileManager.contentsOfDirectory(at: directoryUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            // Filter files to include only those with video extensions
            let videoExtensions = ["mp4", "mov", "avi", "mkv", "flv"]
            let videoFiles = files.filter { file in
                videoExtensions.contains(file.pathExtension.lowercased())
            }
            let sortedVideoFiles = videoFiles.sorted { $0.lastPathComponent < $1.lastPathComponent }
            for i in 0..<sortedVideoFiles.count {
                let startTime = videoAnnotationLines[2 * i].0
                let endTime = videoAnnotationLines[2 * i + 1].0
                let videoURL = URL(fileURLWithPath: sortedVideoFiles[i].path)
                let localURL = saveFileToAppDirectory(from: videoURL)
                if let localURL = localURL {
                    let asset = AVURLAsset(url: localURL)
                    var videoDuration = 0.0
                    do {
                        let duration = try await asset.load(.duration)
                        let durationInSeconds = CMTimeGetSeconds(duration)
                        videoDuration = durationInSeconds
                    } catch {
                        print("Failed to load video duration: \(error.localizedDescription)")
                    }
                    let segment = VideoData(url: localURL, startTime: startTime, startTimeAdjustment: 0.0, endTime: endTime, duration: videoDuration)
                    videoData.append(segment)
                }
            }
            return videoData
        } catch {
            print("Error reading directory \(directoryUrl.lastPathComponent): \(error.localizedDescription)")
            return []
        }
    }
    
    func saveFileToAppDirectory(from url: URL) -> URL? {
        let fileManager = FileManager.default
        do {
            // Get the destination URL in the app's Documents directory
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationURL = documentsDirectory.appendingPathComponent(url.lastPathComponent)
            // If file already exists at destination, skip copying
            if fileManager.fileExists(atPath: destinationURL.path) {
                return destinationURL
            }
            try fileManager.copyItem(at: url, to: destinationURL)
            return destinationURL
        } catch {
            print("Error copying file to app directory: \(error)")
            return nil
        }
    }
}
