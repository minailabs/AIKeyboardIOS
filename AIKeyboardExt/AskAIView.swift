import UIKit

final class AskAIView: UIView {
    
    private weak var keyboardViewController: KeyboardViewController?
    
    private let resultTitleLabel: UILabel
    private let resultTextView: UITextView
    private let applyButton: UIButton
    private let reloadButton: UIButton
    private let loadingIndicator: UIActivityIndicatorView
    private var correctedText: String?
    private var processedText: String?

    // MARK: - Dynamic Colors
    private var viewBackgroundColor: UIColor {
        return keyboardViewController?.keyboardBackgroundColor ?? .white
    }
    private var textColor: UIColor {
        return keyboardViewController?.keyTextColor ?? .black
    }

    init(controller: KeyboardViewController) {
        self.keyboardViewController = controller
        self.resultTitleLabel = UILabel()
        self.resultTextView = UITextView()
        self.applyButton = UIButton(type: .system)
        self.reloadButton = UIButton(type: .system)
        self.loadingIndicator = UIActivityIndicatorView(style: .large)
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        updateColors()

        resultTitleLabel.text = "AI Response"
        resultTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        resultTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        resultTitleLabel.isHidden = true
        addSubview(resultTitleLabel)

        resultTextView.text = ""
        resultTextView.textAlignment = .left
        resultTextView.isEditable = false
        resultTextView.font = UIFont.systemFont(ofSize: 14)
        resultTextView.backgroundColor = .clear
        resultTextView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(resultTextView)
        
        applyButton.setTitle("Insert", for: .normal) // Changed title to "Insert"
        applyButton.addTarget(self, action: #selector(applyTapped), for: .touchUpInside)
        applyButton.isHidden = true
        applyButton.translatesAutoresizingMaskIntoConstraints = false
        applyButton.layer.cornerRadius = 8
        applyButton.backgroundColor = .systemGreen
        applyButton.setTitleColor(.white, for: .normal)
        applyButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        addSubview(applyButton)
        
        reloadButton.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        reloadButton.addTarget(self, action: #selector(reloadTapped), for: .touchUpInside)
        reloadButton.isHidden = true
        reloadButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(reloadButton)
        
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            resultTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            resultTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            resultTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            resultTextView.topAnchor.constraint(equalTo: resultTitleLabel.bottomAnchor, constant: 0),
            resultTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            resultTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            resultTextView.bottomAnchor.constraint(equalTo: applyButton.topAnchor, constant: -10),
            
            applyButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            applyButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),

            reloadButton.centerYAnchor.constraint(equalTo: applyButton.centerYAnchor),
            reloadButton.trailingAnchor.constraint(equalTo: applyButton.leadingAnchor, constant: -8),
            reloadButton.widthAnchor.constraint(equalToConstant: 32),
            reloadButton.heightAnchor.constraint(equalToConstant: 32),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColors()
        }
    }

    private func updateColors() {
        backgroundColor = viewBackgroundColor
        resultTitleLabel.textColor = textColor
        resultTextView.textColor = textColor
        reloadButton.tintColor = textColor
        loadingIndicator.color = textColor
    }
    
    @MainActor
    func processText(_ text: String?) async {
        guard let text = text, !text.isEmpty else {
            resultTitleLabel.isHidden = true
            resultTextView.text = "To get an AI response, select a topic or question, or place your cursor at the end of the text you want to discuss."
            return
        }
        
        if text == processedText { return }
        processedText = text

        resultTextView.isHidden = true
        loadingIndicator.startAnimating()
        applyButton.isHidden = true
        reloadButton.isHidden = true
        resultTitleLabel.isHidden = true
        
        let result = await APIService.shared.askAI(text: text)
        
        loadingIndicator.stopAnimating()
        resultTextView.isHidden = false
        resultTitleLabel.isHidden = false
        
        switch result {
        case .success(let response):
            self.correctedText = response.output
            self.resultTextView.text = response.output
            self.applyButton.isHidden = false
            self.reloadButton.isHidden = false
        case .failure(let error):
            self.resultTextView.text = error.localizedDescription
            self.applyButton.isHidden = true
            self.reloadButton.isHidden = false
        }
    }
    
    @objc private func applyTapped() {
        guard let correctedText = correctedText else { return }
        keyboardViewController?.applyCorrection(newText: correctedText)
    }

    @objc private func reloadTapped() {
        Task { [weak self] in
            await self?.keyboardViewController?.reloadGrammarCheck()
        }
    }
}
