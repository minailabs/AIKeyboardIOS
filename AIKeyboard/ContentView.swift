//
//  ContentView.swift
//  AIKeyboard
//
//  Created by Hien Nguyen on 8/9/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                VStack(spacing: 20) {
                    Image(systemName: "keyboard")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)
                    
                    Text("AI Keyboard")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Custom keyboard with dark theme and predictive text")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("How to Enable:")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack(alignment: .top, spacing: 10) {
                        Text("1.")
                            .fontWeight(.medium)
                            .foregroundStyle(.blue)
                        Text("Go to Settings → General → Keyboard → Keyboards")
                    }
                    
                    HStack(alignment: .top, spacing: 10) {
                        Text("2.")
                            .fontWeight(.medium)
                            .foregroundStyle(.blue)
                        Text("Tap 'Add New Keyboard...'")
                    }
                    
                    HStack(alignment: .top, spacing: 10) {
                        Text("3.")
                            .fontWeight(.medium)
                            .foregroundStyle(.blue)
                        Text("Select 'AIKeyboard' from the list")
                    }
                    
                    HStack(alignment: .top, spacing: 10) {
                        Text("4.")
                            .fontWeight(.medium)
                            .foregroundStyle(.blue)
                        Text("Switch to the keyboard by tapping the globe icon")
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                VStack(spacing: 12) {
                    NavigationLink {
                        ChatGPTView()
                    } label: {
                        HStack { Image(systemName: "bubble.left.and.bubble.right.fill"); Text("Open TypeAI Chat").fontWeight(.semibold) }
                            .padding(.horizontal, 16).padding(.vertical, 12)
                            .background(Color.accentColor).foregroundColor(.white).cornerRadius(10)
                    }

                    NavigationLink {
                        EmailGenerationView()
                    } label: {
                        HStack { Image(systemName: "envelope.fill"); Text("Email Generation").fontWeight(.semibold) }
                            .padding(.horizontal, 16).padding(.vertical, 12)
                            .background(Color(.systemGreen)).foregroundColor(.white).cornerRadius(10)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("TypeAI")
        }
    }
}

#Preview {
    ContentView()
}
