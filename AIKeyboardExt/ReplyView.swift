import UIKit

final class ReplyView: UIView {
    
    private weak var keyboardViewController: KeyboardViewController?
    
    private let resultContainerView = UIView()
    private let resultTitleLabel = UILabel()
    private let resultTextView = UITextView()
    private let reloadButton = UIButton(type: .system)
    private let insertButton = UIButton(type: .system)
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let emptyStateContainer = UIStackView()
    
    private var originalText: String?
    private var replyText: String?
    
    private var viewBackgroundColor: UIColor { keyboardViewController?.keyboardBackgroundColor ?? .white }
    private var textColor: UIColor { keyboardViewController?.keyTextColor ?? .black }
    private var buttonBackgroundColor: UIColor { keyboardViewController?.specialKeyBackgroundColor ?? .lightGray }
    
    init(controller: KeyboardViewController) {
        self.keyboardViewController = controller
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        
        // Result container
        addSubview(resultContainerView)
        resultContainerView.translatesAutoresizingMaskIntoConstraints = false
        resultContainerView.isHidden = true
        
        resultTitleLabel.text = "Result"
        resultTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        resultTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        resultContainerView.addSubview(resultTitleLabel)
        
        resultTextView.font = UIFont.systemFont(ofSize: 14)
        resultTextView.isEditable = false
        resultTextView.backgroundColor = .clear
        resultTextView.translatesAutoresizingMaskIntoConstraints = false
        resultContainerView.addSubview(resultTextView)
        
        reloadButton.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        reloadButton.addTarget(self, action: #selector(reloadTapped), for: .touchUpInside)
        reloadButton.translatesAutoresizingMaskIntoConstraints = false
        resultContainerView.addSubview(reloadButton)
        
        insertButton.setTitle("Insert", for: .normal)
        insertButton.addTarget(self, action: #selector(insertTapped), for: .touchUpInside)
        insertButton.layer.cornerRadius = 8
        insertButton.backgroundColor = .systemGreen
        insertButton.setTitleColor(.white, for: .normal)
        insertButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        insertButton.translatesAutoresizingMaskIntoConstraints = false
        resultContainerView.addSubview(insertButton)
        
        // Loading
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(loadingIndicator)
        
        // Empty state
        let emptyLabel = UILabel()
        emptyLabel.text = "Select or copy text to reply"
        emptyLabel.font = UIFont.systemFont(ofSize: 14)
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0
        
        let emptyReload = UIButton(type: .system)
        emptyReload.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        emptyReload.addTarget(self, action: #selector(reloadTapped), for: .touchUpInside)
        
        emptyStateContainer.axis = .vertical
        emptyStateContainer.spacing = 12
        emptyStateContainer.alignment = .center
        emptyStateContainer.isHidden = true
        emptyStateContainer.addArrangedSubview(emptyLabel)
        emptyStateContainer.addArrangedSubview(emptyReload)
        emptyStateContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(emptyStateContainer)
        
        NSLayoutConstraint.activate([
            resultContainerView.topAnchor.constraint(equalTo: topAnchor),
            resultContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            resultContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            resultContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            resultTitleLabel.topAnchor.constraint(equalTo: resultContainerView.topAnchor, constant: 0),
            resultTitleLabel.leadingAnchor.constraint(equalTo: resultContainerView.leadingAnchor, constant: 16),
            
            resultTextView.topAnchor.constraint(equalTo: resultTitleLabel.bottomAnchor, constant: -5),
            resultTextView.leadingAnchor.constraint(equalTo: resultContainerView.leadingAnchor, constant: 12),
            resultTextView.trailingAnchor.constraint(equalTo: resultContainerView.trailingAnchor, constant: -12),
            resultTextView.bottomAnchor.constraint(equalTo: insertButton.topAnchor, constant: -10),
            
            insertButton.trailingAnchor.constraint(equalTo: resultContainerView.trailingAnchor, constant: -16),
            insertButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
            
            reloadButton.centerYAnchor.constraint(equalTo: insertButton.centerYAnchor),
            reloadButton.trailingAnchor.constraint(equalTo: insertButton.leadingAnchor, constant: -8),
            reloadButton.widthAnchor.constraint(equalToConstant: 32),
            reloadButton.heightAnchor.constraint(equalToConstant: 32),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            emptyStateContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyStateContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            emptyStateContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            emptyStateContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
        ])
        
        updateColors()
    }
    
    private func updateColors() {
        backgroundColor = viewBackgroundColor
        resultTitleLabel.textColor = textColor
        resultTextView.textColor = textColor
        reloadButton.tintColor = textColor
    }
    
    @MainActor
    func processText(_ text: String?) {
        self.originalText = text
        
        guard let text = text, !text.isEmpty else {
            resultContainerView.isHidden = true
            emptyStateContainer.isHidden = false
            return
        }
        
        emptyStateContainer.isHidden = true
        Task { await fetchReply(for: text) }
    }
    
    @MainActor
    private func fetchReply(for text: String) async {
        showLoading(true)
        let result = await APIService.shared.reply(text: text)
        showLoading(false)
        
        switch result {
        case .success(let response):
            replyText = response.output
            Task { await resultTextView.setTextAnimated(newText: response.output) }
        case .failure(let error):
            Task { await resultTextView.setTextAnimated(newText: error.localizedDescription) }
        }
    }
    
    private func showLoading(_ isLoading: Bool) {
        if isLoading {
            loadingIndicator.startAnimating()
            resultContainerView.isHidden = true
        } else {
            loadingIndicator.stopAnimating()
            resultContainerView.isHidden = false
        }
    }
    
    @objc private func reloadTapped() {
        // Task { [weak self] in
        //     guard let self, let text = self.originalText else { return }
        //     await self.fetchReply(for: text)
        // }
        Task { [weak self] in
            await self?.keyboardViewController?.reloadGrammarCheck()
        }
    }
    
    @objc private func insertTapped() {
        guard let replyText = replyText else { return }
        keyboardViewController?.applyCorrection(newText: replyText)
    }
}
