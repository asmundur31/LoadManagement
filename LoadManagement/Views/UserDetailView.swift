//
//  UserDetailView.swift
//  LoadManagement
//
//  Created by Ásmundur Óskar Ásmundsson on 17.12.2024.
//

import SwiftUI

struct UserDetailView: View {
    @State private var recordingViewModel = RecordingViewModel()
    var user: User
    @State private var isClearingTemp: Bool = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(user.user_name)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 20)
                .padding(.leading, 16)
            
            Text("Recordings")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top, 10)
                .padding(.leading, 16)
            

            List {
                ForEach(recordingViewModel.recordings, id: \.self.recording_id) { recording in
                    NavigationLink(destination: RecordingView(recording_id: recording.recording_id)) {
                        Text(recording.recording_name)
                            .font(.body)
                            .padding(.horizontal, 16)
                    }
                }
                .onDelete(perform: deleteRecording)
            }
            .listStyle(PlainListStyle()) // Optional for styling

            Spacer()
            if isClearingTemp {
                Text("Clearing Temporary Directory")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(8)
                ProgressView()
                    .padding()
            }
            if errorMessage != nil {
                Text(errorMessage!)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .onAppear {
            recordingViewModel.getRecordings(user: user)
        }
    }
    
    private func deleteRecording(at offsets: IndexSet) {
        for index in offsets {
           let recording = recordingViewModel.recordings[index]
           recordingViewModel.recordings.remove(at: index)
           recordingViewModel.deleteRecording(recording_id: recording.recording_id)
       }
    }
}

#Preview {
    NavigationStack {
        UserDetailView(user: User(id: 3, user_name: "Ásmundur"))
    }
}
