//
//  HomeView.swift
//  LoadManagement
//
//  Created by Ásmundur Óskar Ásmundsson on 6.11.2024.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Load Management")
                    .font(.title)
                    .padding(.bottom, 40)
                Spacer()
                CustomButtonWithDestination(title: "Upload data", color: Color.blue, destination: DataUploadView())
                CustomButtonWithDestination(title: "Users", color: Color.blue, destination: UsersView())
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    HomeView()
}
