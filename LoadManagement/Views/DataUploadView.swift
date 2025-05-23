//
//  DataUpload.swift
//  LoadManagement
//
//  Created by Ásmundur Óskar Ásmundsson on 5.11.2024.
//

import SwiftUI

struct DataUploadView: View {
    @State private var usersViewModel = UsersViewModel()
    @State private var uploadViewModel = UploadViewModel()
    @State private var isPickerPresented = false
    @State private var dataPreview: String = ""
    @State private var selectedDirectoryURL: URL?
    @State private var selectedUser: User?
    @State private var selectedRecordingName: String = ""
    
    @State private var errorMessage: String = ""
    @State private var showError = false
    @State private var successMessage: String = ""
    @State private var showSuccess = false
    
    @State private var isLoading = false
    
    var body: some View {
        VStack {
            CustomButton(title: "Choose Data", color: Color.blue) {
                isPickerPresented = true
            }
            .fileImporter(
                isPresented: $isPickerPresented,
                allowedContentTypes: [.folder],
                onCompletion: handleFileImport
            )
            
            Menu {
                ForEach(usersViewModel.users, id: \.self) { user in
                    Button(action: {
                        selectedUser = user
                    }) {
                        Text(user.user_name)
                    }
                }
            } label: {
                HStack {
                    Text(selectedUser?.user_name ?? "Select a User")
                        .foregroundColor(selectedUser == nil ? .gray : .primary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)
            }
            .padding()
            // Input field for recording name
            TextField("Enter Recording Name", text: $selectedRecordingName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            VStack {
                Text("Data Preview")
                    .font(.title)
            }
            ScrollView {
                // Display selected data
                if let selectedDirectoryURL = selectedDirectoryURL {
                    Text("Selected Data: \(selectedDirectoryURL.lastPathComponent)/")
                    Text(dataPreview)
                        .padding()
                        .border(Color.gray, width: 1)
                } else {
                    Text("No Data Selected")
                }
            }
            VStack {
                // Show error message if there's an error
                if showError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                if showSuccess {
                    Text(successMessage)
                        .foregroundColor(.green)
                        .padding()
                }
                if isLoading {
                    Text("Uploading data...")
                        .foregroundColor(.blue)
                        .padding()
                }
                HStack {
                    // Navigation link triggered by a selected directory
                    if let user = selectedUser, !selectedRecordingName.isEmpty, let directoryUrl = selectedDirectoryURL {
                        CustomButton(title: "Save Data", color: Color.green) {
                            showError = false
                            showError = false
                            isLoading = true
                            uploadViewModel.uploadData(user: user, recordingName: selectedRecordingName, directoryUrl: directoryUrl) { result in
                                DispatchQueue.main.async {
                                    switch result {
                                    case .success:
                                        print("Upload succeeded.")
                                        isLoading = false
                                        // Reset error message if successful
                                        errorMessage = ""
                                        showError = false
                                        successMessage = "Data uploaded successfully!"
                                        showSuccess = true
                                        // Update UI to reflect successful upload
                                    case .failure(let error):
                                        print("Upload failed: \(error.localizedDescription)")
                                        isLoading = false
                                        successMessage = ""
                                        showSuccess = false
                                        errorMessage = "Failed to upload data: \(error.localizedDescription)"
                                        showError = true
                                        // Show an error message to the user
                                        if let uploadError = error as? UploadError {
                                            switch uploadError {
                                            case .userNotFound:
                                                print("Error: User not found.")
                                            case .recordingNameTaken:
                                                print("Error: Recording name is already taken.")
                                            case .failedToAccessSecurityScopedResource:
                                                print("Error: Could not access security-scoped resource.")
                                            default:
                                                print("Other error: \(error.localizedDescription)")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Upload Data")
        .onAppear() {
            usersViewModel.fetchUsers()
        }
    }
    
    func handleFileImport(result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            parseCSVFiles(at: url)
            selectedDirectoryURL = url
        case .failure(let error):
            print("File import failed: \(error.localizedDescription)")
        }
    }
    
    func parseCSVFiles(at url: URL) {
        let fileManager = FileManager.default
        var combinedContent = ""

        // Start accessing the security-scoped resource for the directory
        guard url.startAccessingSecurityScopedResource() else {
            dataPreview = "Failed to access security-scoped resource for the directory"
            return
        }
        
        defer { url.stopAccessingSecurityScopedResource() } // Stop accessing when done

        // Recursive function to process all files, including nested ones
        func processDirectory(at directoryURL: URL) {
            do {
                let files = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)

                for fileURL in files {
                    var isDirectory: ObjCBool = false
                    if fileManager.fileExists(atPath: fileURL.path, isDirectory: &isDirectory), isDirectory.boolValue {
                        // If the item is a directory, call the function recursively
                        processDirectory(at: fileURL)
                    } else if fileURL.pathExtension.lowercased() == "csv" {

                        do {
                            // Read the contents of the file
                            let content = try String(contentsOf: fileURL, encoding: .utf8)
                            
                            // Take the top 10 lines, filtering out empty lines
                            let lines = content.components(separatedBy: .newlines)
                            let top10Lines = lines.prefix(10).filter { !$0.isEmpty }
                            
                            // Add to the combined content
                            combinedContent += top10Lines.joined(separator: "\n") + "\n"
                        } catch {
                            print("Error reading file \(fileURL.lastPathComponent): \(error.localizedDescription)")
                        }
                    }
                }
            } catch {
                print("Error reading directory: \(error.localizedDescription)")
            }
        }

        // Start processing from the given directory URL
        processDirectory(at: url)

        // Update the annotation content with all the gathered lines
        dataPreview = combinedContent.isEmpty ? "No valid content found in selected files" : combinedContent
    }
}


#Preview {
    DataUploadView()
}
