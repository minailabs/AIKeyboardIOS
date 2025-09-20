import UIKit

final class FindSynonymsView: UIView {
    
    private weak var keyboardViewController: KeyboardViewController?
    
    private let titleLabel = UILabel()
    private let synonymsScrollView = UIScrollView()
    private let synonymsStackView = UIStackView()
    private let applyButton = UIButton(type: .system)
    private let reloadButton = UIButton(type: .system)
    private let guidanceLabel = UILabel()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    private var originalText: String?
    private var selectedSynonym: String?
    private var synonymButtons: [UIButton] = []
    
    private var viewBackgroundColor: UIColor { keyboardViewController?.keyboardBackgroundColor ?? .white }
    private var textColor: UIColor { keyboardViewController?.keyTextColor ?? .black }
    private var buttonBackgroundColor: UIColor { keyboardViewController?.specialKeyBackgroundColor ?? .gray }
    private let selectedButtonColor = UIColor(red: 0.6, green: 0.9, blue: 0.6, alpha: 1.0)
    
    init(controller: KeyboardViewController) {
        self.keyboardViewController = controller
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = viewBackgroundColor
        
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        synonymsScrollView.translatesAutoresizingMaskIntoConstraints = false
        synonymsScrollView.showsHorizontalScrollIndicator = false
        addSubview(synonymsScrollView)
        
        synonymsStackView.axis = .vertical
        synonymsStackView.spacing = 8
        synonymsStackView.alignment = .leading
        synonymsStackView.translatesAutoresizingMaskIntoConstraints = false
        synonymsScrollView.addSubview(synonymsStackView)
        
        applyButton.setTitle("Apply", for: .normal)
        applyButton.addTarget(self, action: #selector(applyTapped), for: .touchUpInside)
        applyButton.isHidden = true
        applyButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(applyButton)
        
        reloadButton.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        reloadButton.addTarget(self, action: #selector(reloadTapped), for: .touchUpInside)
        reloadButton.isHidden = true
        reloadButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(reloadButton)
        
        guidanceLabel.font = UIFont.systemFont(ofSize: 14)
        guidanceLabel.textAlignment = .center
        guidanceLabel.numberOfLines = 0
        guidanceLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(guidanceLabel)
        
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            synonymsScrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            synonymsScrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            synonymsScrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            synonymsScrollView.bottomAnchor.constraint(equalTo: applyButton.topAnchor, constant: -10),
            
            synonymsStackView.topAnchor.constraint(equalTo: synonymsScrollView.topAnchor),
            synonymsStackView.bottomAnchor.constraint(equalTo: synonymsScrollView.bottomAnchor),
            synonymsStackView.leadingAnchor.constraint(equalTo: synonymsScrollView.leadingAnchor),
            synonymsStackView.trailingAnchor.constraint(equalTo: synonymsScrollView.trailingAnchor),
            synonymsStackView.widthAnchor.constraint(equalTo: synonymsScrollView.widthAnchor),
            
            applyButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
            applyButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            reloadButton.centerYAnchor.constraint(equalTo: applyButton.centerYAnchor),
            reloadButton.trailingAnchor.constraint(equalTo: applyButton.leadingAnchor, constant: -10),
            
            guidanceLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            guidanceLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            guidanceLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            guidanceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        updateColors()
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
        guidanceLabel.textColor = textColor
        applyButton.backgroundColor = .systemGreen
        applyButton.setTitleColor(.white, for: .normal)
        applyButton.layer.cornerRadius = 8
        applyButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        reloadButton.tintColor = textColor
        loadingIndicator.color = textColor
        synonymButtons.forEach {
            $0.setTitleColor(textColor, for: .normal)
            if $0.isSelected {
                $0.backgroundColor = selectedButtonColor
                $0.setTitleColor(.black, for: .normal)
            } else {
                $0.backgroundColor = buttonBackgroundColor
            }
        }
    }
    
    @MainActor
    func processText(_ text: String?) async {
        guard let text = text, !text.isEmpty else {
            showGuidance("Please select a text to find synonyms.")
            return
        }
        
        originalText = text
        clearResults()
        loadingIndicator.startAnimating()
        
        let result = await APIService.shared.findSynonyms(text: text)
        
        loadingIndicator.stopAnimating()
        
        switch result {
        case .success(let response):
            if response.output.isEmpty {
                showGuidance("No synonyms found for \"\(text)\".")
            } else {
                displaySynonyms(response.output, for: text)
            }
        case .failure(let error):
            showGuidance("Error: \(error.localizedDescription)")
        }
    }
    
    private func showGuidance(_ message: String) {
        clearResults()
        guidanceLabel.text = message
        guidanceLabel.isHidden = false
        reloadButton.isHidden = false
    }
    
    private func clearResults() {
        titleLabel.isHidden = true
        synonymsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        synonymButtons = []
        applyButton.isHidden = true
        reloadButton.isHidden = true
        guidanceLabel.isHidden = true
    }
    
    private func displaySynonyms(_ synonyms: [String], for text: String) {
        titleLabel.text = "Synonyms for \"\(text)\":"
        titleLabel.isHidden = false
        applyButton.isHidden = false
        reloadButton.isHidden = false
        
        for (index, synonym) in synonyms.enumerated() {
            let button = createSynonymButton(with: synonym)
            synonymsStackView.addArrangedSubview(button)
            synonymButtons.append(button)
            if index == 0 {
                synonymButtonTapped(button) // Select first by default
            }
        }
    }
    
    private func createSynonymButton(with title: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.setTitleColor(textColor, for: .normal)
        button.backgroundColor = buttonBackgroundColor
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        button.addTarget(self, action: #selector(synonymButtonTapped(_:)), for: .touchUpInside)
        return button
    }
    
    @objc private func synonymButtonTapped(_ sender: UIButton) {
        selectedSynonym = sender.title(for: .normal)
        
        for button in synonymButtons {
            button.isSelected = (button == sender)
            if button.isSelected {
                button.backgroundColor = selectedButtonColor
                button.setTitleColor(.black, for: .normal)
            } else {
                button.backgroundColor = buttonBackgroundColor
                button.setTitleColor(textColor, for: .normal)
            }
        }
    }
    
    @objc private func reloadTapped() {
        Task { [weak self] in
            await self?.keyboardViewController?.reloadGrammarCheck()
        }
    }
    

    @objc private func applyTapped() {
        guard let synonym = selectedSynonym,
              let _ = originalText else { return }
        
        keyboardViewController?.applyCorrection(newText: synonym)
    }
}
