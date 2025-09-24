//
//  MessageInputArea.swift
//  SwiftGPT
//
//  Created by Michał Babicz on 04/04/2025.
//

import SwiftUI

struct MessageInputArea: View {
    @ObservedObject var viewModel: ChatViewModel
    @FocusState.Binding var isFocusedBinding: Bool
    @State private var text: String = ""

    var body: some View {
        HStack(spacing: 12) {
            TextField("Ask me anything...", text: $text, axis: .vertical)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .lineLimit(5)
                .focused($isFocusedBinding)
            
            Button(action: {
                if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    viewModel.sendMessage(text)
                    text = ""
                }
            }) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title)
            }
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isSendingMessage)
        }
        .padding()
        .background(Color(.systemBackground))
    }
}
