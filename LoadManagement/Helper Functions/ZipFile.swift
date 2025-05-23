//
//  Zip.swift
//  LoadManagement
//
//  Created by Ásmundur Óskar Ásmundsson on 4.12.2024.
//

import Foundation

enum CreateZipError: Swift.Error {
    case urlNotADirectory(URL)
    case failedToCreateZIP(Swift.Error)
}

func createZip(
    zipFinalURL: URL,
    fromDirectory directoryURL: URL
) throws -> URL {
    // see URL extension below
    guard directoryURL.isDirectory else {
        throw CreateZipError.urlNotADirectory(directoryURL)
    }
    
    var fileManagerError: Swift.Error?
    var coordinatorError: NSError?
    let coordinator = NSFileCoordinator()
    coordinator.coordinate(
        readingItemAt: directoryURL,
        options: .forUploading,
        error: &coordinatorError
    ) { zipCreatedURL in
        do {
            // will fail if file already exists at finalURL
            // use `replaceItem` instead if you want "overwrite" behavior
            try FileManager.default.moveItem(at: zipCreatedURL, to: zipFinalURL)
        } catch {
            fileManagerError = error
        }
    }
    if let error = coordinatorError ?? fileManagerError {
        throw CreateZipError.failedToCreateZIP(error)
    }
    return zipFinalURL
}

func createZipAtTmp(
    zipFilename: String,
    zipExtension: String = "zip",
    fromDirectory directoryURL: URL
) throws -> URL {
    let finalURL = FileManager.default.temporaryDirectory
        .appending(path: zipFilename)
        .appendingPathExtension(zipExtension)
    return try createZip(
        zipFinalURL: finalURL,
        fromDirectory: directoryURL
    )
}

extension URL {
    var isDirectory: Bool {
       (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}
