import SwiftUI

struct EmailGenerationView: View {
    @State private var userInput: String = ""
    @State private var textType: String = "Email" // Email | Text Message
    @State private var length: String = "Short"   // Short | Medium | Long
    @State private var tone: String = "Professional"
    @State private var voice: String = "First-person, professional"
    @State private var language: LanguageOption = LanguageOption(flag: "🇬🇧", name: "English", backendValue: "English")
    @State private var isLoading = false
    @State private var generatedContent: GeneratedContent? = nil
    @State private var showResult = false
    @State private var activeTab: ComposeMode = .newMail
    @State private var showToneSheet = false
    @State private var showLanguageSheet = false
    @State private var showTypeSheet = false
    @State private var showLengthSheet = false
    @State private var showReplySourceSheet = false
    @State private var replySource: String = ""
    @FocusState private var isFocused: Bool

    private let tones: [(String, String)] = [
        ("Professional", "🧑‍💼"), ("Business", "💼"), ("Academic", "📚"),
        ("Friendly", "😊"), ("Confident", "💪"), ("Flirty", "😘"),
        ("Romantic", "🥰"), ("Happy", "😄"), ("Sad", "😢"),
        ("Sarcastic", "🤓"), ("Witty", "😅")
    ]
    private let types: [(String, String)] = [("Email", "✉️"), ("Text Message", "💬")]
    private let lengths = ["Short", "Medium", "Long"]
    private let languages: [LanguageOption] = [
        .init(flag: "🇿🇦", name: "Afrikaans", backendValue: "Afrikaans"),
        .init(flag: "🇸🇦", name: "Arabic", backendValue: "Arabic"),
        .init(flag: "🇧🇩", name: "Bengali", backendValue: "Bengali"),
        .init(flag: "🇨🇳", name: "Chinese (Simplified)", backendValue: "Chinese (Simplified)"),
        .init(flag: "🇹🇼", name: "Chinese (Traditional)", backendValue: "Chinese (Traditional)"),
        .init(flag: "🇬🇧", name: "English", backendValue: "English"),
        .init(flag: "🇫🇷", name: "French", backendValue: "French"),
        .init(flag: "🇩🇪", name: "German", backendValue: "German"),
        .init(flag: "🇮🇳", name: "Hindi", backendValue: "Hindi"),
        .init(flag: "🇮🇹", name: "Italian", backendValue: "Italian"),
        .init(flag: "🇯🇵", name: "Japanese", backendValue: "Japanese"),
        .init(flag: "🇰🇷", name: "Korean", backendValue: "Korean"),
        .init(flag: "🇵🇹", name: "Portuguese", backendValue: "Portuguese"),
        .init(flag: "🇷🇺", name: "Russian", backendValue: "Russian"),
        .init(flag: "🇪🇸", name: "Spanish", backendValue: "Spanish"),
        .init(flag: "🇹🇿", name: "Swahili", backendValue: "Swahili"),
        .init(flag: "🇸🇪", name: "Swedish", backendValue: "Swedish"),
        .init(flag: "🇮🇳", name: "Tamil", backendValue: "Tamil"),
        .init(flag: "🇮🇳", name: "Telugu", backendValue: "Telugu"),
        .init(flag: "🇹🇭", name: "Thai", backendValue: "Thai"),
        .init(flag: "🇹🇷", name: "Turkish", backendValue: "Turkish"),
        .init(flag: "🇺🇦", name: "Ukrainian", backendValue: "Ukrainian"),
        .init(flag: "🇵🇰", name: "Urdu", backendValue: "Urdu"),
        .init(flag: "🇻🇳", name: "Vietnamese", backendValue: "Vietnamese"),
        .init(flag: "🇿🇦", name: "Zulu", backendValue: "Zulu")
    ]

    var body: some View {
        VStack(spacing: 16) {
            Picker("Mode", selection: $activeTab) {
                ForEach(ComposeMode.allCases, id: \.self) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            composeEditor
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.horizontal)
        .safeAreaInset(edge: .bottom) { composeControls }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Email Generation")
        .sheet(isPresented: $showTypeSheet) {
            TypePickerSheet(textType: $textType, types: types)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showLengthSheet) {
            LengthPickerSheet(length: $length, lengths: lengths)
                .presentationDetents([.fraction(0.3)])
        }
        .sheet(isPresented: $showToneSheet) {
            TonePickerSheet(tone: $tone, tones: tones)
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showLanguageSheet) {
            LanguagePicker(language: $language, languages: languages)
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showReplySourceSheet) {
            ReplySourceSheet(sourceText: $replySource)
                .presentationDetents([.medium, .large])
        }
        .navigationDestination(isPresented: $showResult) {
            if let content = generatedContent {
                EmailGenerationResultView(content: content) {
                    showResult = false
                }
            } else {
                Text("No content available")
                    .navigationTitle("AI Generated")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

    private var composeEditor: some View {
        VStack(spacing: 12) {
            if activeTab == .replyMail {
                Button {
                    showReplySourceSheet = true
                } label: {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Label("Reply To", systemImage: "envelope.open")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            if replySource.isEmpty {
                                Text("Add the original text you want to reply to")
                                    .foregroundColor(.primary)
                            } else {
                                Text(replySource)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .lineLimit(3)
                                    .multilineTextAlignment(.leading)
                                    .minimumScaleFactor(0.8)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(.gray).opacity(0.5)))
                }
            }

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.gray).opacity(0.1))
                TextEditor(text: $userInput)
                    .padding(10)
                    .focused($isFocused)
                if userInput.isEmpty {
                    Text(activeTab.placeholder)
                        .foregroundColor(.secondary)
                        .padding(16)
                }
            }
            .frame(maxHeight: .infinity)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.systemGray4)))
        }
    }

    private var composeControls: some View {
        VStack(spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    OptionCard(title: "Text Type", subtitle: displayTextType)
                        .onTapGesture { showTypeSheet = true }
                    OptionCard(title: "Text Length", subtitle: length)
                        .onTapGesture { showLengthSheet = true }
                    OptionCard(title: "Tone", subtitle: tone)
                        .onTapGesture { showToneSheet = true }
                    OptionCard(title: "Language", subtitle: language.displayName)
                        .onTapGesture { showLanguageSheet = true }
                }
                .padding(.horizontal)
            }

            Button(action: submit) {
                Text(isLoading ? "Generating…" : activeTab.buttonTitle)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading ? Color(.systemGray5) : Color.green)
                    .foregroundColor(.primary)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 12)
            .disabled(userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
        }
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }

    private var displayTextType: String {
        if let emoji = types.first(where: { $0.0 == textType })?.1 {
            return "\(emoji) \(textType)"
        }
        return textType
    }

    private func submit() {
        isLoading = true
        let payload = ContentGenerationRequest(
            user_input: combinedInput(),
            text_type: textType.lowercased(),
            text_action: activeTab == .newMail ? "new" : "reply",
            length: length.lowercased(),
            writing_tone: tone,
            voice: voice,
            output_language: language.backendValue
        )
        Task {
            let res = await APIService.shared.generateContent(payload)
            isLoading = false
            switch res {
            case .success(let api):
                generatedContent = api.output
                showResult = true
            case .failure(let err):
                generatedContent = GeneratedContent(subject: nil, body: "Error: \(err)", response: nil)
                showResult = true
            }
        }
    }

    private func combinedInput() -> String {
        switch activeTab {
        case .newMail:
            return userInput
        case .replyMail:
            var sections: [String] = []
            if !replySource.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                sections.append("Original text to reply:\n\(replySource)")
            }
            if !userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                sections.append("Reply instructions:\n\(userInput)")
            }
            return sections.joined(separator: "\n\n")
        }
    }

    private func formatResult(_ output: GeneratedContent) -> String {
        if let subject = output.subject, !(subject.isEmpty), let body = output.body {
            return "Subject: \(subject)\n\n\(body)"
        } else if let body = output.body, !(body.isEmpty) {
            return body
        } else if let response = output.response {
            return response
        } else {
            return "No content generated."
        }
    }
}

private enum ComposeMode: CaseIterable { case newMail, replyMail
    var title: String {
        switch self {
        case .newMail: return "✉️ New"
        case .replyMail: return "📩 Reply"
        }
    }
    var placeholder: String {
        switch self {
        case .newMail: return "What is your email going to be about?"
        case .replyMail: return "What do you want to say in your reply?"
        }
    }
    var buttonTitle: String {
        switch self {
        case .newMail: return "✨ Generate"
        case .replyMail: return "✨ Craft Reply"
        }
    }
}

private struct OptionCard: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            Text(subtitle)
                .font(.subheadline)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.gray).opacity(0.1)))
    }
}

private struct TonePickerSheet: View {
    @Binding var tone: String
    let tones: [(String, String)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                    ForEach(tones, id: \.0) { item in
                        Button(action: { tone = item.0 }) {
                            HStack {
                                Text("\(item.1) \(item.0)")
                                Spacer()
                            }
                            .padding()
                            .background(tone == item.0 ? Color(.systemMint).opacity(0.2) : Color(.secondarySystemBackground))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(tone == item.0 ? Color.accentColor : .clear, lineWidth: 2))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .navigationTitle("Select Tone")
            .presentationDragIndicator(.visible)
        }
    }
}

private struct TypePickerSheet: View {
    @Binding var textType: String
    let types: [(String, String)]

    var body: some View {
        NavigationStack {
            List(types, id: \.0) { type in
                Button(action: { textType = type.0 }) {
                    HStack {
                        Text("\(type.1) \(type.0)")
                        Spacer()
                        if textType == type.0 { Image(systemName: "checkmark") }
                    }
                }
            }
            .navigationTitle("Select Type")
            .presentationDragIndicator(.visible)
        }
    }
}

private struct LengthPickerSheet: View {
    @Binding var length: String
    let lengths: [String]

    var body: some View {
        NavigationStack {
            List(lengths, id: \.self) { item in
                Button(action: { length = item }) {
                    HStack {
                        Text(item)
                        Spacer()
                        if length == item { Image(systemName: "checkmark") }
                    }
                }
            }
            .navigationTitle("Select Length")
            .presentationDragIndicator(.visible)
        }
    }
}

private struct GeneratedContentView: View {
    let content: GeneratedContent

    var body: some View {
        VStack(spacing: 12) {
            if let subject = content.subject, !subject.isEmpty {
                SelectableTextContainer(title: "Subject", content: subject, maxLines: 2).frame(maxHeight: 100)
            }
            if let body = content.body, !body.isEmpty {
                SelectableTextContainer(title: "Body", content: body)
            }
            if let response = content.response, !response.isEmpty {
                SelectableTextContainer(title: "Response", content: response)
            }
        }
        .padding(.top, 16)
    }
}

private struct SelectableTextContainer: View {
    let title: String
    let content: String
    var maxLines: Int? = nil
    var maxHeight: CGFloat? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.gray).opacity(0.1))
                SelectableTextView(text: content, maxLines: maxLines, maxHeight: maxHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .frame(maxHeight: maxHeight)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.systemGray4)))
        }
    }
}

private struct SelectableTextView: UIViewRepresentable {
    let text: String
    var maxLines: Int? = nil
    var maxHeight: CGFloat? = nil

    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.isEditable = false
        view.isSelectable = true
        view.backgroundColor = .clear
        view.textColor = UIColor.label
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        return view
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        if let lines = maxLines {
            uiView.textContainer.maximumNumberOfLines = lines
            uiView.textContainer.lineBreakMode = .byTruncatingTail
        } else {
            uiView.textContainer.maximumNumberOfLines = 0
            uiView.textContainer.lineBreakMode = .byWordWrapping
        }
        if let height = maxHeight {
            uiView.isScrollEnabled = true
            uiView.setContentOffset(.zero, animated: false)
            DispatchQueue.main.async {
                uiView.flashScrollIndicators()
            }
        } else {
            uiView.isScrollEnabled = true
        }
    }
}

struct EmailGenerationResultView: View {
    let content: GeneratedContent
    var onEdit: () -> Void

    private var copyText: String {
        var parts: [String] = []
        if let subject = content.subject, !subject.isEmpty {
            parts.append("Subject: \(subject)")
        }
        if let body = content.body, !body.isEmpty {
            parts.append(body)
        }
        if let response = content.response, !response.isEmpty {
            parts.append(response)
        }
        return parts.joined(separator: "\n\n")
    }

    var body: some View {
        VStack(spacing: 20) {
            GeneratedContentView(content: content)
            HStack(spacing: 12) {
                Button(action: onEdit) {
                    Text("✏️ Edit Prompt")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray3))
                        .foregroundColor(.primary)
                        .cornerRadius(16)
                }
                Button(action: { UIPasteboard.general.string = copyText }) {
                    Text("📄 Copy")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
            }
            Spacer()
        }
        .padding()
        .navigationTitle("AI Generated")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct LanguagePicker: View {
    @Binding var language: LanguageOption
    let languages: [LanguageOption]

    var body: some View {
        NavigationStack {
            List(languages) { lang in
                Button(action: { language = lang }) {
                    HStack {
                        Text(lang.displayName)
                        Spacer()
                        if language.id == lang.id { Image(systemName: "checkmark") }
                    }
                }
            }
            .navigationTitle("Select Output Language")
            .presentationDragIndicator(.visible)
        }
    }
}

private struct ReplySourceSheet: View {
    @Binding var sourceText: String
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isEditorFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Text("Paste the email you want to reply to")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                    TextEditor(text: $sourceText)
                        .padding(10)
                        .scrollContentBackground(.hidden)
                        .focused($isEditorFocused)
                }
                .frame(minHeight: 220)
                Spacer()
            }
            .padding()
            .navigationTitle("Original Text")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isEditorFocused = true
                }
            }
        }
    }
}

struct LanguageOption: Identifiable, Equatable {
    let id = UUID()
    let flag: String
    let name: String
    let backendValue: String

    var displayName: String { "\(flag) \(name)" }
}

#Preview {
    NavigationStack {
        EmailGenerationView()
    }
}
