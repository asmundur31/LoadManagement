//
//  CustomButton.swift
//  LoadManagement
//
//  Created by Ásmundur Óskar Ásmundsson on 3.12.2024.
//

import SwiftUI

struct CustomButtonWithDestination<Destination: View>: View {
    let title: String
    let color: Color
    let destination: Destination

    var body: some View {
        NavigationLink(destination: destination) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(color)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .frame(maxWidth: 200)
    }
}

struct CustomButton: View {
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(color)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .frame(maxWidth: 200)
    }
}

#Preview {
    NavigationStack {
        HStack {
            CustomButtonWithDestination(title: "With navigation", color: Color.blue, destination: UsersView())
            CustomButton(title: "Without navigation", color: Color.green, action: {print("halló heimur")})
        }
    }
}
