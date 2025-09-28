//
//  ChatGPTView.swift
//  SwiftGPT
//
//  Created by mbabicz on 25/01/2023.
//

import SwiftUI

struct ChatGPTView: View {
    @StateObject var viewModel = ChatViewModel()
    @StateObject private var historyStore = ChatHistoryStore()
    @State private var showHistory = false
    @State private var conversationId: UUID? = nil
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                messagesScrollView.padding(.top, 10)
                MessageInputArea(
                    viewModel: viewModel,
                    isFocusedBinding: $isFocused
                )
            }
            .background(Color(.systemBackground))
            .onTapGesture { isFocused = false }
            .navigationTitle("🤖 Magic Ask AI")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showHistory = true }) {
                        Image(systemName: "clock")
                    }
                }
            }
            .onChange(of: viewModel.messages) { _ in
                // Create conversation when first user message arrives
                let export = viewModel.exportHistory()
                let hasUser = export.contains(where: { $0.role == "user" })
                if conversationId == nil, hasUser {
                    let title = export.first(where: { $0.role == "user" })?.content ?? "New chat"
                    conversationId = historyStore.createNew(title: title, messages: export)
                } else if let id = conversationId {
                    let title = export.first(where: { $0.role == "user" })?.content ?? "New chat"
                    historyStore.update(id: id, messages: export, title: title)
                }
            }
            .sheet(isPresented: $showHistory) {
                HistoryListView(store: historyStore) { convo in
                    conversationId = convo.id
                    viewModel.loadConversation(convo)
                }
            }
        }
    }
    
    // MARK: - Private Views
    
    private var messagesScrollView: some View {
        ScrollViewReader { reader in
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(viewModel.messages) { message in
                        MessageView(message: message)
                            .id(message.id)
                    }
                }
                .padding(.horizontal)
                
                Color.clear
                    .frame(height: 1)
                    .id("bottom")
            }
            .onChange(of: viewModel.messages.count) { _ in
                withAnimation { reader.scrollTo("bottom", anchor: .bottom) }
            }
            .onReceive(NotificationCenter.default.publisher(for: .typewriterProgress)) { _ in
                withAnimation(.easeOut(duration: 0.15)) {
                    reader.scrollTo("bottom", anchor: .bottom)
                }
            }
        }
    }
}
