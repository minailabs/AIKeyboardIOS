//
//  ChatGPTView.swift
//  SwiftGPT
//
//  Created by mbabicz on 25/01/2023.
//

import SwiftUI

struct ChatGPTView: View {
    @StateObject var viewModel = ChatViewModel()
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                messagesScrollView
                MessageInputArea(
                    viewModel: viewModel,
                    isFocusedBinding: $isFocused
                )
            }
            .background(Color(.secondarySystemBackground))
            .onTapGesture { isFocused = false }
            .navigationTitle("AI Chat")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Private Views
    
    private var messagesScrollView: some View {
        ScrollViewReader { reader in
            ScrollView {
                ForEach(viewModel.messages) { message in
                    MessageView(message: message)
                }
                .padding(.horizontal)
                
                // Invisible element to scroll to
                Color.clear
                    .frame(height: 1)
                    .id("bottom")
            }
            .onChange(of: viewModel.messages.count) { _ in
                // Scroll to the bottom when a new message appears
                withAnimation {
                    reader.scrollTo("bottom", anchor: .bottom)
                }
            }
        }
    }
}
