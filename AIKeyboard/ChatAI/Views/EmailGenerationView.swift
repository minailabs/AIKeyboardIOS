import SwiftUI

struct EmailGenerationView: View {
    @State private var userInput: String = ""
    @State private var textType: String = "Email" // Email | Text Message
    @State private var length: String = "Short"   // Short | Medium | Long
    @State private var tone: String = "Professional"
    @State private var voice: String = "First-person, professional"
    @State private var language: LanguageOption = LanguageOption(flag: "🇬🇧", name: "English", backendValue: "English")
    @State private var isLoading = false
    @State private var result: String? = nil
    @State private var showPreferences = false
    @State private var showLanguage = false
    @State private var activeTab: TabSelection = .compose
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
        VStack(spacing: 0) {
            contentArea
        }.padding(.vertical, 10)
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.horizontal)
        .safeAreaInset(edge: .bottom) { bottomControls }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Mode", selection: $activeTab) {
                    ForEach(TabSelection.allCases, id: \.self) { tab in
                        Text(tab.title).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 220)
            }
        }.navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var contentArea: some View {
        switch activeTab {
        case .compose:
            ZStack(alignment: .topLeading) {
//                RoundedRectangle(cornerRadius: 16)
//                    .fill(Color(.secondarySystemBackground))
                TextEditor(text: $userInput)
                    .padding(10)
                    .focused($isFocused)
                if userInput.isEmpty {
                    Text("What is your email going to be about?")
                        .foregroundColor(.secondary)
                        .padding(16)
                }
            }
            .frame(maxHeight: .infinity)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.systemGray4)))
        case .result:
            GeneratedContentView(text: result ?? "No content yet. Submit to generate.")
                .frame(maxHeight: .infinity)
        }
    }

    private var bottomControls: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button(action: { showPreferences = true }) {
                    tile(title: "Text Preferences", subtitle: "\(textType), \(length)", height: 60)
                }
                .sheet(isPresented: $showPreferences) {
                    PreferencesSheet(textType: $textType, length: $length, tone: $tone, types: types, tones: tones)
                        .presentationDetents([.medium, .large])
                }

                Button(action: { showLanguage = true }) {
                    tile(title: "Output Language", subtitle: language.displayName, height: 60)
                }
                .sheet(isPresented: $showLanguage) {
                    LanguagePicker(language: $language, languages: languages)
                        .presentationDetents([.medium, .large])
                }
            }

            Button(action: submit) {
                Text(isLoading ? "Generating…" : "Submit")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading ? Color(.systemGray5) : Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            .disabled(userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }

    @ViewBuilder
    private func tile(title: String, subtitle: String, height: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: height, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
    }

    private func submit() {
        isLoading = true
        result = nil
        let payload = ContentGenerationRequest(
            user_input: userInput,
            text_type: textType.lowercased(),
            length: length.lowercased(),
            writing_tone: tone,
            voice: voice,
            output_language: language.backendValue
        )
        Task {
            let res = await APIService.shared.generateContent(payload)
            isLoading = false
            switch res {
            case .success(let api): result = api.output
            case .failure(let err): result = "Error: \(err)"
            }
        }
    }
}

private enum TabSelection: CaseIterable { case compose, result
    var title: String { self == .compose ? "Compose" : "Result" }
}

private struct PreferencesSheet: View {
    @Binding var textType: String
    @Binding var length: String
    @Binding var tone: String
    let types: [(String, String)]
    let tones: [(String, String)]
    private let lengths = ["Short", "Medium", "Long"]

    var body: some View {
        VStack(spacing: 24) {
            CapsulePicker(title: "Purpose", items: types, selection: $textType)
            List {
                Section("Text Length") {
                    Picker("", selection: $length) {
                        ForEach(lengths, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.segmented)
                }
                Section("Writing Tone") {
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
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(.top, 12)
        .presentationDragIndicator(.visible)
    }
}

private struct CapsulePicker: View {
    let title: String
    let items: [(String, String)]
    @Binding var selection: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)
            HStack(spacing: 8) {
                ForEach(items, id: \.0) { item in
                    Button(action: { selection = item.0 }) {
                        Text("\(item.1) \(item.0)")
                            .fontWeight(.semibold)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(selection == item.0 ? Color.accentColor : Color(.systemGray5))
                            .foregroundColor(selection == item.0 ? .white : .primary)
                            .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

private struct LanguagePicker: View {
    @Binding var language: LanguageOption
    let languages: [LanguageOption]
    var body: some View {
        List(languages) { lang in
            Button(action: { language = lang }) {
                HStack {
                    Text(lang.displayName)
                    Spacer()
                    if language.id == lang.id { Image(systemName: "checkmark") }
                }
            }
        }
        .presentationDragIndicator(.visible)
        .navigationTitle("Output Language")
    }
}

private struct GeneratedContentView: View {
    let text: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Result")
                .font(.headline)
            ScrollView {
                Text(text)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Button(action: { UIPasteboard.general.string = text }) {
                Label("Copy", systemImage: "doc.on.doc")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.horizontal)
        .padding(.bottom, 16)
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
