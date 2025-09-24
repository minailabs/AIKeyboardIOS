//
//  MessageView.swift
//  SwiftGPT
//
//  Created by mbabicz on 02/02/2023.
//

import SwiftUI
import PhotosUI

struct MessageView: View {
    var message: Message

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: message.isUserMessage ? "person.crop.circle" : "keyboard.fill")
                        .resizable()
                        .frame(width: 30, height: 30)

                    switch message.content {
                    case let .text(output):
                        Text(output.trimmingCharacters(in: .whitespacesAndNewlines))
                            .textSelection(.enabled)
                    case let .error(output):
                        Text(output.trimmingCharacters(in: .whitespacesAndNewlines))
                            .foregroundStyle(.red)
                            .textSelection(.enabled)
                    case .indicator:
                        MessageIndicatorView()
                    case .image:
                        // Image handling removed for simplicity
                        Text("Image content is not supported in this version.")
                    }
                }
                .padding()
            }
            Spacer()
        }
        .background(message.isUserMessage ? Color(.systemBackground) : Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}
