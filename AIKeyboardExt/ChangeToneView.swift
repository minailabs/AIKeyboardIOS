import UIKit

final class ChangeToneView: UIView {
    
    private weak var keyboardViewController: KeyboardViewController?
    
    // UI Components
    private let titleLabel = UILabel()
    private let toneSelectionScrollView = UIScrollView()
    private let toneSelectionStackView = UIStackView()
    private let resultContainerView = UIView()
    private let resultTitleLabel = UILabel()
    private let resultTextView = UITextView()
    private let applyButton = UIButton(type: .system)
    private let changeToneButton = UIButton(type: .system)
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    // Data
    private var originalText: String?
    private var correctedText: String?
    private let availableTones: [(emoji: String, name: String)] = [
        ("😊", "Friendly"), ("🤔", "Witty"), ("🎓", "Academic"),
        ("😏", "Flirty"), ("❤️", "Romantic"), ("😢", "Sad"),
        ("😎", "Confident"), ("😠", "Angry"), ("😃", "Happy"),
        ("👔", "Professional"), ("😒", "Sarcastic")
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
        titleLabel.text = "Select a Tone"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        // --- Tone Selection ---
        toneSelectionScrollView.showsHorizontalScrollIndicator = false
        toneSelectionScrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(toneSelectionScrollView)
        
        toneSelectionStackView.axis = .vertical
        toneSelectionStackView.spacing = 10
        toneSelectionStackView.translatesAutoresizingMaskIntoConstraints = false
        toneSelectionScrollView.addSubview(toneSelectionStackView)
        
        populateToneButtons()
        
        // --- Result View ---
        resultContainerView.isHidden = true
        resultContainerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(resultContainerView)
        
        resultTitleLabel.text = "Result"
        resultTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        resultTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        resultContainerView.addSubview(resultTitleLabel)
        
        resultTextView.font = UIFont.systemFont(ofSize: 14)
        resultTextView.isEditable = false
        resultTextView.backgroundColor = .clear
        resultTextView.translatesAutoresizingMaskIntoConstraints = false
        resultContainerView.addSubview(resultTextView)
        
        applyButton.setTitle("Apply", for: .normal)
        applyButton.addTarget(self, action: #selector(applyTapped), for: .touchUpInside)
        applyButton.backgroundColor = .systemGreen
        applyButton.setTitleColor(.white, for: .normal)
        applyButton.layer.cornerRadius = 8
        applyButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        applyButton.translatesAutoresizingMaskIntoConstraints = false
        resultContainerView.addSubview(applyButton)
        
        changeToneButton.setTitle("Change Tone", for: .normal)
        changeToneButton.addTarget(self, action: #selector(changeToneTapped), for: .touchUpInside)
        changeToneButton.layer.cornerRadius = 8
        changeToneButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        changeToneButton.translatesAutoresizingMaskIntoConstraints = false
        resultContainerView.addSubview(changeToneButton)
        
        // --- Loading Indicator ---
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(loadingIndicator)

        // --- Layout ---
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            toneSelectionScrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            toneSelectionScrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            toneSelectionScrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            toneSelectionScrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            toneSelectionStackView.topAnchor.constraint(equalTo: toneSelectionScrollView.topAnchor),
            toneSelectionStackView.leadingAnchor.constraint(equalTo: toneSelectionScrollView.leadingAnchor, constant: 16),
            toneSelectionStackView.trailingAnchor.constraint(equalTo: toneSelectionScrollView.trailingAnchor, constant: -16),
            toneSelectionStackView.bottomAnchor.constraint(equalTo: toneSelectionScrollView.bottomAnchor),
            toneSelectionStackView.widthAnchor.constraint(equalTo: toneSelectionScrollView.widthAnchor, constant: -32),
            
            resultContainerView.topAnchor.constraint(equalTo: topAnchor),
            resultContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            resultContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            resultContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            resultTitleLabel.topAnchor.constraint(equalTo: resultContainerView.topAnchor, constant: 10),
            resultTitleLabel.leadingAnchor.constraint(equalTo: resultContainerView.leadingAnchor, constant: 16),
            
            resultTextView.topAnchor.constraint(equalTo: resultTitleLabel.bottomAnchor, constant: 4),
            resultTextView.leadingAnchor.constraint(equalTo: resultContainerView.leadingAnchor, constant: 12),
            resultTextView.trailingAnchor.constraint(equalTo: resultContainerView.trailingAnchor, constant: -12),
            resultTextView.bottomAnchor.constraint(equalTo: applyButton.topAnchor, constant: -10),
            
            applyButton.topAnchor.constraint(equalTo: resultTextView.bottomAnchor, constant: 10),
            applyButton.trailingAnchor.constraint(equalTo: resultContainerView.trailingAnchor, constant: -16),
            applyButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
            
            changeToneButton.centerYAnchor.constraint(equalTo: applyButton.centerYAnchor),
            changeToneButton.trailingAnchor.constraint(equalTo: applyButton.leadingAnchor, constant: -8),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private func populateToneButtons() {
        // Clear any existing buttons
        toneSelectionStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let itemsPerRow = 3
        var currentRowStackView: UIStackView?

        for (index, tone) in availableTones.enumerated() {
            if index % itemsPerRow == 0 {
                currentRowStackView = UIStackView()
                currentRowStackView?.axis = .horizontal
                currentRowStackView?.spacing = 10
                currentRowStackView?.distribution = .fillEqually
                toneSelectionStackView.addArrangedSubview(currentRowStackView!)
            }

            let button = UIButton(type: .system)
            button.setTitle("\(tone.emoji) \(tone.name)", for: .normal)
            button.accessibilityIdentifier = tone.name // Store raw name here
            button.addTarget(self, action: #selector(toneButtonTapped), for: .touchUpInside)
            button.layer.cornerRadius = 8
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
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
        changeToneButton.backgroundColor = buttonBackgroundColor
        changeToneButton.setTitleColor(textColor, for: .normal)
        loadingIndicator.color = textColor
        
        toneSelectionStackView.arrangedSubviews.forEach {
            if let button = $0 as? UIButton {
                button.backgroundColor = buttonBackgroundColor
                button.setTitleColor(textColor, for: .normal)
            }
        }
    }

    @MainActor
    func processText(_ text: String?) {
        self.originalText = text
        
        guard let text = text, !text.isEmpty else {
            titleLabel.text = "Select text or place cursor to change tone."
            toneSelectionScrollView.isHidden = true
            return
        }
    }

    @objc private func toneButtonTapped(_ sender: UIButton) {
        // Use the accessibilityIdentifier to get the clean tone name
        guard let tone = sender.accessibilityIdentifier, let text = originalText else { return }

        Task {
            await fetchToneChange(for: text, tone: tone)
        }
    }
    
    @MainActor
    private func fetchToneChange(for text: String, tone: String) async {
        showLoading(true)
        
        let result = await APIService.shared.changeTone(text: text, tone: tone)
        
        showLoading(false)
        
        switch result {
        case .success(let response):
            self.correctedText = response.output
            Task {
                await self.resultTextView.setTextAnimated(newText: response.output)
            }
        case .failure(let error):
            Task {
                await self.resultTextView.setTextAnimated(newText: error.localizedDescription)
            }
        }
    }
    
    private func showLoading(_ isLoading: Bool) {
        if isLoading {
            loadingIndicator.startAnimating()
            titleLabel.isHidden = true
            toneSelectionScrollView.isHidden = true
            resultContainerView.isHidden = true
        } else {
            loadingIndicator.stopAnimating()
            resultContainerView.isHidden = false
        }
    }

    @objc private func changeToneTapped() {
        // Hide result, show tone selection
        resultContainerView.isHidden = true
        titleLabel.isHidden = false
        toneSelectionScrollView.isHidden = false
    }

    @objc private func applyTapped() {
        guard let correctedText = correctedText else { return }
        keyboardViewController?.applyCorrection(newText: correctedText)
    }
}
