//
//  UploadViewModel.swift
//  LoadManagement
//
//  Created by Ásmundur Óskar Ásmundsson on 4.12.2024.
//

import Foundation
import ZIPFoundation

enum UploadError: Error {
    case failedToAccessSecurityScopedResource
    case userNotFound
    case recordingNameTaken
    case serverError(statusCode: Int)
    case unknownError
    case fileReadError
    case noCSVFiles
}

@Observable
class UploadViewModel {
    func uploadData(user: User, recordingName: String, directoryUrl: URL, completion: @escaping (Result<Void, Error>) -> Void) {
        print("Uploading data for \(user.user_name) with user_id \(user.id) to \(recordingName) in \(directoryUrl)")
        guard directoryUrl.startAccessingSecurityScopedResource() else {
            print("Failed to access security-scoped resource for the directory")
            completion(.failure(UploadError.failedToAccessSecurityScopedResource))
            return
        }
        defer { directoryUrl.stopAccessingSecurityScopedResource() }
        let tmpDirectory = FileManager.default.temporaryDirectory
        // Create a folder within the tmp directory
        let recordingFolderURL = tmpDirectory.appendingPathComponent(recordingName)
        do {
            // if the folder already exists we will delete it
            if FileManager.default.fileExists(atPath: recordingFolderURL.path) {
                do {
                    try FileManager.default.removeItem(at: recordingFolderURL)
                } catch {
                    print("Failed to delete existing directory: \(error.localizedDescription)")
                    completion(.failure(UploadError.unknownError))
                    return
                }
            }
            // Create a folder within the tmp directory
            try FileManager.default.createDirectory(at: recordingFolderURL, withIntermediateDirectories: true)
            
            // Get all CSV files and videos in the directory
            let files = try findFiles(in: directoryUrl)
           
            if files.isEmpty {
                print("No files found in the directory.")
                completion(.failure(UploadError.noCSVFiles))
                return
            }
            
            // Copy CSV files to the temporary folder, preserving directory structure
            for file in files {
                let relativePath = file.path.replacingOccurrences(of: directoryUrl.path, with: "")
                let destinationURL = recordingFolderURL.appendingPathComponent(relativePath)
                let destinationDirectory = destinationURL.deletingLastPathComponent()
                try FileManager.default.createDirectory(at: destinationDirectory, withIntermediateDirectories: true)
                try FileManager.default.copyItem(at: file, to: destinationURL)
            }

            // Create the zip file
            let zipFileURL = tmpDirectory.appendingPathComponent("\(recordingName).zip")
            try FileManager.default.zipItem(at: recordingFolderURL, to: zipFileURL)
            
            if let fileAttributes = try? FileManager.default.attributesOfItem(atPath: zipFileURL.path) {
                if let fileSize = fileAttributes[.size] as? NSNumber {
                    let fileSizeInMB = fileSize.doubleValue / (1024 * 1024) // Convert to MB
                    print("File size: \(fileSizeInMB) MB")
                }
            }
            
            // Call the API service to upload the ZIP file
            APIService.shared.uploadRecording(zipURL: zipFileURL, userId: user.id, recordingName: recordingName) { result in
                DispatchQueue.main.async {
                    // Attempt to remove the temporary ZIP file
                    do {
                        try FileManager.default.removeItem(at: zipFileURL)
                    } catch {
                        print("Failed to delete temporary ZIP file: \(error.localizedDescription)")
                    }
                    switch result {
                    case .success:
                        print("Data has been uploaded successfully.")
                        completion(.success(())) // Inform the caller of success
                        
                    case .failure(let error):
                        print("Failed to upload recording: \(error.localizedDescription)")
                        completion(.failure(error)) // Pass the error to the caller
                    }
                }
            }
        } catch {
            print("Error during preparation or zipping: \(error.localizedDescription)")
            completion(.failure(error)) // Pass the error to the caller
        }
    }
    
    // Helper function to recursively find CSV files and videos
    private func findFiles(in directoryURL: URL) throws -> [URL] {
        var files: [URL] = []
        
        let fileManager = FileManager.default
        let directoryContents = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
        
        for item in directoryContents {
            var isDirectory: ObjCBool = false
            if fileManager.fileExists(atPath: item.path, isDirectory: &isDirectory) {
                if isDirectory.boolValue {
                    // Recursively search subdirectory
                    let subdirectoryFiles = try findFiles(in: item)
                    files.append(contentsOf: subdirectoryFiles)
                } else {
                    files.append(item)
                }
            }
        }
        
        return files
    }
}
