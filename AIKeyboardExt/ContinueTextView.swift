import UIKit

final class ContinueTextView: UIView {
    
    private weak var keyboardViewController: KeyboardViewController?
    
    private let resultTitleLabel = UILabel()
    private let resultTextView = UITextView()
    private let applyButton = UIButton(type: .system)
    private let reloadButton = UIButton(type: .system)
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    private var continuedText: String?
    private var processedText: String?
    
    private var viewBackgroundColor: UIColor { keyboardViewController?.keyboardBackgroundColor ?? .white }
    private var textColor: UIColor { keyboardViewController?.keyTextColor ?? .black }
    
    init(controller: KeyboardViewController) {
        self.keyboardViewController = controller
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = viewBackgroundColor
        
        resultTitleLabel.text = "Result"
        resultTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        resultTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        resultTitleLabel.isHidden = true
        addSubview(resultTitleLabel)
        
        resultTextView.textAlignment = .left
        resultTextView.isEditable = false
        resultTextView.font = UIFont.systemFont(ofSize: 14)
        resultTextView.backgroundColor = .clear
        resultTextView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(resultTextView)
        
        applyButton.setTitle("Insert", for: .normal)
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
            
            resultTextView.topAnchor.constraint(equalTo: resultTitleLabel.bottomAnchor, constant: -5),
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
        resultTitleLabel.textColor = textColor
        resultTextView.textColor = textColor
        applyButton.tintColor = keyboardViewController?.specialKeyBackgroundColor
        reloadButton.tintColor = textColor
        loadingIndicator.color = textColor
    }
    
    @MainActor
    func processText(_ text: String?) async {
        guard let text = text, !text.isEmpty else {
            resultTitleLabel.isHidden = true
            resultTextView.text = "Select text or place the cursor to continue."
            return
        }
        
        processedText = text
        
        resultTextView.isHidden = true
        loadingIndicator.startAnimating()
        applyButton.isHidden = true
        reloadButton.isHidden = true
        resultTitleLabel.isHidden = true
        
        let result = await APIService.shared.continueText(text: text)
        
        loadingIndicator.stopAnimating()
        resultTextView.isHidden = false
        resultTitleLabel.isHidden = false
        
        switch result {
        case .success(let response):
            continuedText = response.output
            Task { await resultTextView.setTextAnimated(newText: response.output) }
            applyButton.isHidden = false
            reloadButton.isHidden = false
        case .failure(let error):
            Task { await resultTextView.setTextAnimated(newText: error.localizedDescription) }
            applyButton.isHidden = true
            reloadButton.isHidden = false
        }
    }
    
    @objc private func reloadTapped() {
        Task { [weak self] in
            await self?.keyboardViewController?.reloadGrammarCheck()
        }
    }
    
    @objc private func applyTapped() {
        guard let txt = continuedText, !txt.isEmpty else { return }
        // Insert at cursor; do not replace selection
        Task {
            await self.keyboardViewController?.continueTextInsert(text: txt)
        }
    }
}
