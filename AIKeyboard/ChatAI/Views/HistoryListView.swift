import SwiftUI

struct HistoryListView: View {
    @ObservedObject var store: ChatHistoryStore
    var onSelect: (Conversation) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(store.conversations) { convo in
                Button(action: { onSelect(convo); dismiss() }) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(convo.title)
                            .font(.body)
                            .foregroundColor(.primary)
                            .lineLimit(2)
                        Text(convo.createdAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear") { store.clearAll() }
                }
            }
        }
    }
}
