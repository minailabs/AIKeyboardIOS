import UIKit

final class TranslateView: UIView {
    
    private weak var keyboardViewController: KeyboardViewController?
    
    // UI Components
    private let titleLabel = UILabel()
    private let languageSelectionScrollView = UIScrollView()
    private let languageSelectionStackView = UIStackView()
    private let resultContainerView = UIView()
    private let resultTitleLabel = UILabel()
    private let resultTextView = UITextView()
    private let guidanceLabel = UILabel()
    private let reloadButton = UIButton(type: .system)
    private let changeLanguageButton = UIButton(type: .system)
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let emptyStateContainer = UIStackView()
    
    // Data
    private var originalText: String?
    private var translatedText: String?
    private let supportedLanguages: [(flag: String, name: String)] = [
        ("🇿🇦", "Afrikaans"), ("🇸🇦", "Arabic"), ("🇧🇩", "Bengali"), ("🇨🇳", "Chinese (Simplified)"),
        ("🇨🇳", "Chinese (Traditional)"), ("🇺🇸", "English"), ("🇫🇷", "French"), ("🇩🇪", "German"),
        ("🇮🇳", "Hindi"), ("🇮🇹", "Italian"), ("🇯🇵", "Japanese"), ("🇰🇷", "Korean"), ("🇵🇹", "Portuguese"),
        ("🇷🇺", "Russian"), ("🇪🇸", "Spanish"), ("🇰🇪", "Swahili"), ("🇸🇪", "Swedish"), ("🇮🇳", "Tamil"),
        ("🇮🇳", "Telugu"), ("🇹🇭", "Thai"), ("🇹🇷", "Turkish"), ("🇺🇦", "Ukrainian"), ("🇵🇰", "Urdu"),
        ("🇻🇳", "Vietnamese"), ("🇿🇦", "Zulu")
    ]

    // MARK: - Dynamic Colors
    private var viewBackgroundColor: UIColor {
        return keyboardViewController?.keyboardBackgroundColor ?? .white
    }
    private var textColor: UIColor {
        return keyboardViewController?.keyTextColor ?? .black
    }
    private var buttonBackgroundColor: UIColor {
        return keyboardViewController?.specialKeyBackgroundColor ?? .lightGray
    }

    init(controller: KeyboardViewController) {
        self.keyboardViewController = controller
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        updateColors()
        
        // --- Main Title ---
        titleLabel.text = "Translate to:"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        // --- Language Selection ---
        languageSelectionScrollView.showsHorizontalScrollIndicator = false
        languageSelectionScrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(languageSelectionScrollView)
        
        languageSelectionStackView.axis = .vertical
        languageSelectionStackView.spacing = 10
        languageSelectionStackView.translatesAutoresizingMaskIntoConstraints = false
        languageSelectionScrollView.addSubview(languageSelectionStackView)
        
        populateLanguageButtons()
        
        // --- Result View ---
        resultContainerView.isHidden = true
        resultContainerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(resultContainerView)
        
        resultTitleLabel.text = "Translation"
        resultTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        resultTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        resultContainerView.addSubview(resultTitleLabel)
        
        resultTextView.font = UIFont.systemFont(ofSize: 14)
        resultTextView.isEditable = false
        resultTextView.backgroundColor = .clear
        resultTextView.translatesAutoresizingMaskIntoConstraints = false
        resultContainerView.addSubview(resultTextView)
        
        guidanceLabel.text = "Select or copy text to translate"
        guidanceLabel.font = UIFont.systemFont(ofSize: 12)
        guidanceLabel.textColor = .systemGray
        guidanceLabel.translatesAutoresizingMaskIntoConstraints = false
        resultContainerView.addSubview(guidanceLabel)
        
        reloadButton.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        reloadButton.addTarget(self, action: #selector(reloadTapped), for: .touchUpInside)
        reloadButton.translatesAutoresizingMaskIntoConstraints = false
        resultContainerView.addSubview(reloadButton)
        
        changeLanguageButton.setTitle("Change Language", for: .normal)
        changeLanguageButton.addTarget(self, action: #selector(changeLanguageTapped), for: .touchUpInside)
        changeLanguageButton.layer.cornerRadius = 8
        changeLanguageButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        changeLanguageButton.translatesAutoresizingMaskIntoConstraints = false
        resultContainerView.addSubview(changeLanguageButton)
        
        // --- Loading Indicator ---
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(loadingIndicator)

        // --- Empty State View ---
        let emptyStateLabel = UILabel()
        emptyStateLabel.text = "Select or copy text to translate."
        emptyStateLabel.font = UIFont.systemFont(ofSize: 14)
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        
        let emptyStateReloadButton = UIButton(type: .system)
        emptyStateReloadButton.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        emptyStateReloadButton.addTarget(self, action: #selector(reloadTapped), for: .touchUpInside)
        
        emptyStateContainer.axis = .vertical
        emptyStateContainer.spacing = 12
        emptyStateContainer.alignment = .center
        emptyStateContainer.isHidden = true
        emptyStateContainer.addArrangedSubview(emptyStateLabel)
        emptyStateContainer.addArrangedSubview(emptyStateReloadButton)
        emptyStateContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(emptyStateContainer)

        // --- Layout ---
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            languageSelectionScrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            languageSelectionScrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            languageSelectionScrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            languageSelectionScrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            languageSelectionStackView.topAnchor.constraint(equalTo: languageSelectionScrollView.topAnchor),
            languageSelectionStackView.leadingAnchor.constraint(equalTo: languageSelectionScrollView.leadingAnchor, constant: 16),
            languageSelectionStackView.trailingAnchor.constraint(equalTo: languageSelectionScrollView.trailingAnchor, constant: -16),
            languageSelectionStackView.bottomAnchor.constraint(equalTo: languageSelectionScrollView.bottomAnchor, constant: -10),
            languageSelectionStackView.widthAnchor.constraint(equalTo: languageSelectionScrollView.widthAnchor, constant: -32),
            
            resultContainerView.topAnchor.constraint(equalTo: topAnchor),
            resultContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            resultContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            resultContainerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            resultTitleLabel.topAnchor.constraint(equalTo: resultContainerView.topAnchor, constant: -5),
            resultTitleLabel.leadingAnchor.constraint(equalTo: resultContainerView.leadingAnchor, constant: 16),
            
            resultTextView.topAnchor.constraint(equalTo: resultTitleLabel.bottomAnchor, constant: 0),
            resultTextView.leadingAnchor.constraint(equalTo: resultContainerView.leadingAnchor, constant: 12),
            resultTextView.trailingAnchor.constraint(equalTo: resultContainerView.trailingAnchor, constant: -12),
            resultTextView.bottomAnchor.constraint(equalTo: changeLanguageButton.topAnchor, constant: -10),
            
            guidanceLabel.leadingAnchor.constraint(equalTo: resultContainerView.leadingAnchor, constant: 16),
            guidanceLabel.centerYAnchor.constraint(equalTo: changeLanguageButton.centerYAnchor),
            
            reloadButton.centerYAnchor.constraint(equalTo: changeLanguageButton.centerYAnchor),
            reloadButton.trailingAnchor.constraint(equalTo: changeLanguageButton.leadingAnchor, constant: -8),
            reloadButton.widthAnchor.constraint(equalToConstant: 32),
            reloadButton.heightAnchor.constraint(equalToConstant: 32),
            
            changeLanguageButton.trailingAnchor.constraint(equalTo: resultContainerView.trailingAnchor, constant: -16),
            changeLanguageButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            emptyStateContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyStateContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            emptyStateContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            emptyStateContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
        ])
    }
    
    private func populateLanguageButtons() {
        // Clear any existing buttons
        languageSelectionStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let itemsPerRow = 2
        var currentRowStackView: UIStackView?

        for (index, lang) in supportedLanguages.enumerated() {
            if index % itemsPerRow == 0 {
                currentRowStackView = UIStackView()
                currentRowStackView?.axis = .horizontal
                currentRowStackView?.spacing = 10
                currentRowStackView?.distribution = .fillEqually
                languageSelectionStackView.addArrangedSubview(currentRowStackView!)
            }

            let button = UIButton(type: .system)
            button.setTitle("\(lang.flag) \(lang.name)", for: .normal)
            button.accessibilityIdentifier = lang.name // Store raw name here
            button.addTarget(self, action: #selector(languageButtonTapped), for: .touchUpInside)
            button.layer.cornerRadius = 8
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14) // Increased font size for better readability
            button.contentHorizontalAlignment = .left // Align text to the left
            button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
            button.backgroundColor = buttonBackgroundColor
            button.setTitleColor(textColor, for: .normal)
            currentRowStackView?.addArrangedSubview(button)
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColors()
        }
    }

    private func updateColors() {
        backgroundColor = viewBackgroundColor
        titleLabel.textColor = textColor
        resultTitleLabel.textColor = textColor
        resultTextView.textColor = textColor
        reloadButton.tintColor = textColor
        changeLanguageButton.backgroundColor = buttonBackgroundColor
        changeLanguageButton.setTitleColor(textColor, for: .normal)
        loadingIndicator.color = textColor
        
        languageSelectionStackView.arrangedSubviews.forEach { row in
            (row as? UIStackView)?.arrangedSubviews.forEach {
                if let button = $0 as? UIButton {
                    button.backgroundColor = buttonBackgroundColor
                    button.setTitleColor(textColor, for: .normal)
                }
            }
        }
    }

    @MainActor
    func processText(_ text: String?) {
        self.originalText = text
        
        guard let text = text, !text.isEmpty else {
            titleLabel.isHidden = true
            languageSelectionScrollView.isHidden = true
            emptyStateContainer.isHidden = false
            return
        }
        
        // Reset to language selection screen
        emptyStateContainer.isHidden = true
        changeLanguageTapped()
    }

    @objc private func languageButtonTapped(_ sender: UIButton) {
        guard let language = sender.accessibilityIdentifier, let text = originalText else { return }

        Task {
            await fetchTranslation(for: text, language: language)
        }
    }
    
    @MainActor
    private func fetchTranslation(for text: String, language: String) async {
        showLoading(true)
        
        let result = await APIService.shared.translate(text: text, language: language)
        
        showLoading(false)
        
        switch result {
        case .success(let response):
            self.translatedText = response.output
            Task { await self.resultTextView.setTextAnimated(newText: response.output) }
        case .failure(let error):
            Task { await self.resultTextView.setTextAnimated(newText: error.localizedDescription) }
        }
    }
    
    private func showLoading(_ isLoading: Bool) {
        if isLoading {
            loadingIndicator.startAnimating()
            titleLabel.isHidden = true
            languageSelectionScrollView.isHidden = true
            resultContainerView.isHidden = true
        } else {
            loadingIndicator.stopAnimating()
            resultContainerView.isHidden = false
        }
    }

    @objc private func changeLanguageTapped() {
        resultContainerView.isHidden = true
        titleLabel.isHidden = false
        languageSelectionScrollView.isHidden = false
    }

    @objc private func reloadTapped() {
        Task { [weak self] in
            await self?.keyboardViewController?.reloadGrammarCheck()
        }
    }
}
