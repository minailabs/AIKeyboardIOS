import UIKit

final class CheckGrammarView: UIView {
    
    private weak var keyboardViewController: KeyboardViewController?
    
    private let resultTextView: UITextView
    private let applyButton: UIButton
    private let loadingIndicator: UIActivityIndicatorView
    private var correctedText: String?
    private var processedText: String?

    // MARK: - Dynamic Colors
    private let viewBackgroundColor: UIColor = {
        return UIColor { (traits) -> UIColor in
            return traits.userInterfaceStyle == .dark ? UIColor(white: 0.2, alpha: 1.0) : .white
        }
    }()

    private let textColor: UIColor = {
        return UIColor { (traits) -> UIColor in
            return traits.userInterfaceStyle == .dark ? .white : .black
        }
    }()

    init(controller: KeyboardViewController) {
        self.keyboardViewController = controller
        self.resultTextView = UITextView()
        self.applyButton = UIButton(type: .system)
        self.applyButton.setTitleColor(.black, for: .normal)
        self.applyButton.backgroundColor = .systemGreen
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

        resultTextView.text = "Check Grammar View"
        resultTextView.textAlignment = .left
        resultTextView.isEditable = false
        resultTextView.font = UIFont.systemFont(ofSize: 16)
        resultTextView.backgroundColor = .clear
        resultTextView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(resultTextView)
        
        applyButton.setTitle("Apply", for: .normal)
        applyButton.addTarget(self, action: #selector(applyTapped), for: .touchUpInside)
        applyButton.isHidden = true
        applyButton.translatesAutoresizingMaskIntoConstraints = false
        applyButton.layer.cornerRadius = 8
        applyButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        addSubview(applyButton)
        
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            resultTextView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            resultTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            resultTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            applyButton.topAnchor.constraint(equalTo: resultTextView.bottomAnchor, constant: 10),
            applyButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            applyButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
            
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
        resultTextView.textColor = textColor
        applyButton.tintColor = keyboardViewController?.specialKeyBackgroundColor
        loadingIndicator.color = textColor
    }
    
    func processSelectedText(_ text: String?) {
        guard let text = text, !text.isEmpty else {
            resultTextView.text = "No text selected to check."
            return
        }
        
        if processedText != nil {
            if processedText!.isEmpty == false {
                return
            }
        }
        
        if text == processedText {
            return
        }
        
        processedText = text

        resultTextView.isHidden = true
        loadingIndicator.startAnimating()
        
        Task {
            let result = await APIService.shared.checkGrammar(text: text)
            
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
                self.resultTextView.isHidden = false
                
                switch result {
                case .success(let response):
                    self.correctedText = response.output
                    self.resultTextView.text = "Result:\n\(response.output)"
                    self.applyButton.isHidden = false
                case .failure(let error):
                    self.resultTextView.text = "Error:\n\(error.localizedDescription)"
                    self.applyButton.isHidden = true
                }
            }
        }
    }
    
    @objc private func applyTapped() {
        guard let correctedText = correctedText else { return }
        keyboardViewController?.replaceSelectedText(with: correctedText)
    }
}
