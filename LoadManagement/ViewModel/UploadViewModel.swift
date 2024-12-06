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
}

@Observable
class UploadViewModel {
    func uploadData(user: User, recordingName: String, directoryUrl: URL) throws {
        print("Uploading data for \(user.user_name) with user_id \(user.id) to \(recordingName) in \(directoryUrl)")
        guard directoryUrl.startAccessingSecurityScopedResource() else {
            print("Failed to access security-scoped resource for the directory")
            throw UploadError.failedToAccessSecurityScopedResource
        }
        defer { directoryUrl.stopAccessingSecurityScopedResource() }
        let tmpDirectory = FileManager.default.temporaryDirectory
        // Create a folder within the tmp directory
        let recordingFolderURL = tmpDirectory.appendingPathComponent(recordingName)
        try FileManager.default.createDirectory(at: recordingFolderURL, withIntermediateDirectories: true)
        // Copy the directory url to the tmp directory
        let destinationDirectoryURL = recordingFolderURL.appendingPathComponent(directoryUrl.lastPathComponent)
        try FileManager.default.copyItem(at: directoryUrl, to: destinationDirectoryURL)
        // Create the zip file
        let zipFileURL = tmpDirectory.appendingPathComponent("\(recordingName).zip")
        do {
            try FileManager.default.zipItem(at: recordingFolderURL, to: zipFileURL)
            print("ZIP file created at: \(zipFileURL.path)")
        } catch {
            print("Failed to create ZIP file: \(error)")
            return
        }
        APIService.shared.uploadRecording(zipURL: zipFileURL, userId: user.id, recordingName: recordingName) { result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    print("Data has been uploaded successfully.")
                    // Then we remove the file from tmp
                    do {
                        try FileManager.default.removeItem(at: zipFileURL)
                        print("Temporary ZIP file deleted successfully.")
                    } catch {
                        print("Failed to delete temporary ZIP file: \(error)")
                    }
                case .failure(let error):
                    print("Error fetching users: \(error.localizedDescription)")
                }
            }
        }
    }
}
