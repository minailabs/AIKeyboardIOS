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
            TextField("Type a message...", text: $text, axis: .vertical)
                .padding(.horizontal, 4)
                .lineLimit(5)
                .focused($isFocusedBinding)
            
            Button(action: {
                if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    viewModel.sendMessage(text)
                    text = ""
                }
            }) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 18))
                    .frame(width: 32, height: 32)
                    .background(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color(.systemGray4) : Color.accentColor)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isSendingMessage)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6))
        .cornerRadius(22)
        .padding()
    }
}
