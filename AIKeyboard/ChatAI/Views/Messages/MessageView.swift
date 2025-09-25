//
//  MessageView.swift
//  SwiftGPT
//
//  Created by mbabicz on 02/02/2023.
//

import SwiftUI

struct MessageView: View {
    var message: Message

    var body: some View {
        HStack {
            if message.isUserMessage { Spacer() }
            
            VStack(alignment: .leading, spacing: 4) {
                switch message.content {
                case let .text(output):
                    HStack(alignment: .top, spacing: 10) {
                        if !message.isUserMessage {
                            Image("AppLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        }
                        
                        if message.isUserMessage {
                            Text(LocalizedStringKey(output.trimmingCharacters(in: .whitespacesAndNewlines)))
                                .padding(.vertical, 10)
                                .padding(.horizontal, 10)
                                .background(Color(.systemGray6))
                                .cornerRadius(16)
                        } else {
                            TypewriterText(fullText: output.trimmingCharacters(in: .whitespacesAndNewlines))
                                .padding(.vertical, 5)
                                .padding(.horizontal, 0)
                        }
                    }
                    .textSelection(.enabled)
                
                case let .error(output):
                    Text(output)
                        .padding()
                        .background(Color.red.opacity(0.7))
                        .cornerRadius(16)
                        .foregroundColor(.white)
                
                case .indicator:
                    MessageIndicatorView()
                
                case .image:
                    Text("Image content not supported.")
                }
            }
            
            if !message.isUserMessage { Spacer() }
        }
        .padding(.vertical, 4)
    }
}
