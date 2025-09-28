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
                        HStack(alignment: .center, spacing: 16) {
                            Text("🤖")
                                .font(.system(size: 34))
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Magic Ask AI")
                                    .font(.headline)
                                Text("Chat with an assistant for instant answers, clarifications, and creative suggestions.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemGray6)))
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        EmailGenerationView()
                    } label: {
                        HStack(alignment: .center, spacing: 16) {
                            Text("✨")
                                .font(.system(size: 34))
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Magic Write AI")
                                    .font(.headline)
                                Text("Draft polished emails or text-message replies with tone, length, and language controls.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemGray6)))
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("")
        }
    }
}

#Preview {
    ContentView()
}
