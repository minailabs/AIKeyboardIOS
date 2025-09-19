//
//  KeyboardViewController.swift
//  AIKeyboardExt
//
//  Created by Hien Nguyen on 8/9/25
//

import UIKit

class KeyboardViewController: UIInputViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private var suggestionBar: UIView!
    private var isShiftEnabled = false
    private var isCapsLockEnabled = false
    private var shiftButton: UIButton?
    private var abcButton: UIButton?
    private var deleteTimer: Timer?
    
    private var mainKeyboardView: UIView!
    private var emojiKeyboardView: UIView!
    private var numericKeyboardView: UIView!
    private var symbolsKeyboardView: UIView!
    private var featureContainerView: UIView!
    var emojiCollectionView: UICollectionView!
    private var checkGrammarView: CheckGrammarView?
    private var changeToneView: ChangeToneView?
    private var askAIView: AskAIView?
    
    private var originalTextForCorrection: String?
    
    private var suggestionsContainer: UIView!
    private var featuresContainer: UIView!
    
    private var featureButtonStates: [String: Bool] = [:]
    
    private let emojis: [String] = [
        "😀","😃","😄","😁","😆","😅","😂","🤣","😊","🙂","😉","😍","😘","😗","😜","🤪","😎","🤩","🥳","😏","😒","😞","😔","😟","😕","🙁","☹️","😣","😖","😫","😩","🥺","😢","😭","😤","😠","😡","🤬","🤯","😳","🥵","🥶","😱","😨","😰","😥","😓","🤗","🤔","🤭","🤫","🤥","😶","😐","😑","😬","🙄","😯","😦","😧","😮","😲","🥱","😴","🤤","😪","😵","🤐","🥴","🤢","🤮","🤧","😷","🤒","🤕","🤑","🤠"
    ]
    
    private let keyboardRows = [
        ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
        ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
        ["shift", "Z", "X", "C", "V", "B", "N", "M", "delete"]
    ]
    
    private let numericKeyboardRows = [
        ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
        ["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""],
        ["#+=", ".", ",", "?", "!", "'", "delete"]
    ]
    
    private let symbolKeyboardRows = [
        ["[", "]", "{", "}", "#", "%", "^", "*", "+", "="],
        ["_", "\\", "|", "~", "<", ">", "€", "£", "¥", "•"],
        ["123", ".", ",", "?", "!", "'", "delete"]
    ]
    
    private let suggestions = ["I", "The", "I'm"]
    
    var keyBackgroundColor: UIColor {
        return UIColor { (traits) -> UIColor in
            return traits.userInterfaceStyle == .dark ?
                UIColor(red: 0.25, green: 0.25, blue: 0.27, alpha: 1.0) :
                .white
        }
    }
    
    var specialKeyBackgroundColor: UIColor {
        return UIColor { (traits) -> UIColor in
            return traits.userInterfaceStyle == .dark ?
                UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0) :
                UIColor(red: 0.82, green: 0.84, blue: 0.86, alpha: 1.0)
        }
    }
    
    var keyTextColor: UIColor {
        return UIColor { (traits) -> UIColor in
            return traits.userInterfaceStyle == .dark ? .white : .black
        }
    }
    
    var keyboardBackgroundColor: UIColor {
        return UIColor { (traits) -> UIColor in
            return traits.userInterfaceStyle == .dark ?
                UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0) :
                UIColor(red: 0.9, green: 0.92, blue: 0.94, alpha: 1.0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboard()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        emojiCollectionView?.collectionViewLayout.invalidateLayout()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateKeyboardAppearance()
        updateSuggestionBarAppearance()
    }

    private func updateKeyboardAppearance() {
        view.backgroundColor = keyboardBackgroundColor
        
        func updateButtons(in view: UIView) {
            for subview in view.subviews {
                if let button = subview as? UIButton {
                    let isSpecial = isSpecialKey(button.accessibilityIdentifier ?? "")
                    button.backgroundColor = isSpecial ? specialKeyBackgroundColor : keyBackgroundColor
                    button.setTitleColor(keyTextColor, for: .normal)
                    button.tintColor = keyTextColor
                } else {
                    updateButtons(in: subview)
                }
            }
        }
        
        updateButtons(in: mainKeyboardView)
        updateButtons(in: numericKeyboardView)
        updateButtons(in: symbolsKeyboardView)
        updateShiftButtonAppearance()
    }

    private func updateSuggestionBarAppearance() {
        guard suggestionBar != nil else { return }
        
        // Update feature buttons in the scroll view
        if let featuresScrollView = featuresContainer?.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView,
           let featuresStack = featuresScrollView.subviews.first(where: { $0 is UIStackView }) as? UIStackView {
            for case let button as UIButton in featuresStack.arrangedSubviews {
                // Respect the active (green) state
                let isActive = featureButtonStates[button.currentTitle ?? ""] ?? false
                if !isActive {
                    button.backgroundColor = specialKeyBackgroundColor
                    button.setTitleColor(keyTextColor, for: .normal)
                }
            }
        }
        
        // Update the close button
        if let closeButton = featuresContainer.subviews.first(where: { $0 is UIButton }) as? UIButton {
            closeButton.backgroundColor = specialKeyBackgroundColor
            closeButton.tintColor = keyTextColor
        }
        
        // The main features button is handled at setup and doesn't need to change with theme
    }
    
    private func setupKeyboard() {
        view.backgroundColor = keyboardBackgroundColor
        
        let keyboardHeight: CGFloat = 280
        let heightConstraint = NSLayoutConstraint(item: view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: keyboardHeight)
        heightConstraint.priority = .init(999)
        view.addConstraint(heightConstraint)
        
        setupSuggestionBar()
        
        // Main keyboard container
        mainKeyboardView = UIView()
        mainKeyboardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainKeyboardView)
        
        NSLayoutConstraint.activate([
            mainKeyboardView.topAnchor.constraint(equalTo: suggestionBar.bottomAnchor),
            mainKeyboardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainKeyboardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainKeyboardView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Add alphabetic keyboard view (extracted to its own class)
        let alphabeticView = AlphabeticKeyboardView(controller: self, keyboardRows: keyboardRows)
        mainKeyboardView.addSubview(alphabeticView)
        NSLayoutConstraint.activate([
            alphabeticView.topAnchor.constraint(equalTo: mainKeyboardView.topAnchor),
            alphabeticView.leadingAnchor.constraint(equalTo: mainKeyboardView.leadingAnchor),
            alphabeticView.trailingAnchor.constraint(equalTo: mainKeyboardView.trailingAnchor),
            alphabeticView.bottomAnchor.constraint(equalTo: mainKeyboardView.bottomAnchor)
        ])
        
        // Emoji and Numeric keyboards
        setupEmojiKeyboard()
        setupNumericKeyboard()
        setupSymbolsKeyboard()
        setupFeatureContainerView()
    }
    
    private func setupFeatureSpecificViews() {
        // Removed pre-emptive setup
    }

    private func setupFeatureContainerView() {
        featureContainerView = UIView()
        featureContainerView.translatesAutoresizingMaskIntoConstraints = false
        featureContainerView.isHidden = true
//        featureContainerView.backgroundColor = .red
        view.addSubview(featureContainerView)

        NSLayoutConstraint.activate([
            featureContainerView.topAnchor.constraint(equalTo: suggestionBar.bottomAnchor, constant: 5),
            featureContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            featureContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            featureContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupSymbolsKeyboard() {
        symbolsKeyboardView = UIView()
        symbolsKeyboardView.translatesAutoresizingMaskIntoConstraints = false
        symbolsKeyboardView.isHidden = true
        view.addSubview(symbolsKeyboardView)
        
        NSLayoutConstraint.activate([
            symbolsKeyboardView.topAnchor.constraint(equalTo: suggestionBar.bottomAnchor),
            symbolsKeyboardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            symbolsKeyboardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            symbolsKeyboardView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let symbolsStackView = UIStackView()
        symbolsStackView.axis = .vertical
        symbolsStackView.spacing = 10
        symbolsStackView.distribution = .fillEqually
        symbolsStackView.translatesAutoresizingMaskIntoConstraints = false
        symbolsKeyboardView.addSubview(symbolsStackView)
        
        NSLayoutConstraint.activate([
            symbolsStackView.topAnchor.constraint(equalTo: symbolsKeyboardView.topAnchor, constant: 10),
            symbolsStackView.leadingAnchor.constraint(equalTo: symbolsKeyboardView.leadingAnchor, constant: 4),
            symbolsStackView.trailingAnchor.constraint(equalTo: symbolsKeyboardView.trailingAnchor, constant: -4),
            symbolsStackView.bottomAnchor.constraint(equalTo: symbolsKeyboardView.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
        
        symbolKeyboardRows.forEach { row in
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.spacing = 6
            rowStackView.distribution = .fillProportionally
            symbolsStackView.addArrangedSubview(rowStackView)
            
            row.forEach { key in
                let button = createKeyButton(title: key, isSpecial: isSpecialKey(key))
                rowStackView.addArrangedSubview(button)
            }
        }
        
        let bottomRow = UIStackView()
        bottomRow.axis = .horizontal
        bottomRow.spacing = 6
        bottomRow.distribution = .fillProportionally
        
        let abcButton = createKeyButton(title: "ABC", isSpecial: true)
        // Prevent inserting text when tapping ABC; only switch layout
        abcButton.removeTarget(self, action: #selector(keyPressed(_:)), for: .touchUpInside)
        abcButton.addTarget(self, action: #selector(switchToAlphabeticKeyboard), for: .touchUpInside)
        let emojiButton = createKeyButton(title: "😊", isSpecial: true)
        emojiButton.addTarget(self, action: #selector(switchToEmojiKeyboard), for: .touchUpInside)
        let spaceButton = createKeyButton(title: "", identifier: "space", isSpecial: false)
        let returnButton = createKeyButton(title: "return", isSpecial: true)
        
        bottomRow.addArrangedSubview(abcButton)
        bottomRow.addArrangedSubview(emojiButton)
        bottomRow.addArrangedSubview(spaceButton)
        bottomRow.addArrangedSubview(returnButton)
        
        NSLayoutConstraint.activate([
            abcButton.widthAnchor.constraint(equalTo: returnButton.widthAnchor, multiplier: 1.0),
            emojiButton.widthAnchor.constraint(equalTo: abcButton.widthAnchor, multiplier: 0.8),
            spaceButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 100)
        ])
        
        symbolsStackView.addArrangedSubview(bottomRow)
    }

    private func setupNumericKeyboard() {
        numericKeyboardView = UIView()
        numericKeyboardView.translatesAutoresizingMaskIntoConstraints = false
        numericKeyboardView.isHidden = true
        view.addSubview(numericKeyboardView)

        NSLayoutConstraint.activate([
            numericKeyboardView.topAnchor.constraint(equalTo: suggestionBar.bottomAnchor),
            numericKeyboardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            numericKeyboardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            numericKeyboardView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let numericView = NumericKeyboardView(controller: self, rows: numericKeyboardRows)
        numericKeyboardView.addSubview(numericView)
        NSLayoutConstraint.activate([
            numericView.topAnchor.constraint(equalTo: numericKeyboardView.topAnchor),
            numericView.leadingAnchor.constraint(equalTo: numericKeyboardView.leadingAnchor),
            numericView.trailingAnchor.constraint(equalTo: numericKeyboardView.trailingAnchor),
            numericView.bottomAnchor.constraint(equalTo: numericKeyboardView.bottomAnchor)
        ])
    }
    
    private func setupEmojiKeyboard() {
        emojiKeyboardView = UIView()
        emojiKeyboardView.translatesAutoresizingMaskIntoConstraints = false
        emojiKeyboardView.isHidden = true
        view.addSubview(emojiKeyboardView)

        NSLayoutConstraint.activate([
            emojiKeyboardView.topAnchor.constraint(equalTo: suggestionBar.bottomAnchor),
            emojiKeyboardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emojiKeyboardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emojiKeyboardView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let emojiView = EmojiKeyboardView(controller: self)
        emojiKeyboardView.addSubview(emojiView)
        NSLayoutConstraint.activate([
            emojiView.topAnchor.constraint(equalTo: emojiKeyboardView.topAnchor),
            emojiView.leadingAnchor.constraint(equalTo: emojiKeyboardView.leadingAnchor),
            emojiView.trailingAnchor.constraint(equalTo: emojiKeyboardView.trailingAnchor),
            emojiView.bottomAnchor.constraint(equalTo: emojiKeyboardView.bottomAnchor)
        ])
    }
    
    @objc private func toggleFeatureViews() {
        let isSuggestionsHidden = suggestionsContainer.isHidden
        suggestionsContainer.isHidden = !isSuggestionsHidden
        featuresContainer.isHidden = isSuggestionsHidden
        
        if isSuggestionsHidden {
            closeFeatureContainerView()
            showKeyboardView(mainKeyboardView)
        }
    }

    @objc private func closeFeatureContainerView() {
        showKeyboardView(mainKeyboardView)
        deactivateAllFeatureButtons()
        
        checkGrammarView?.removeFromSuperview()
        checkGrammarView = nil
        
        changeToneView?.removeFromSuperview()
        changeToneView = nil
        
        askAIView?.removeFromSuperview()
        askAIView = nil
        
        originalTextForCorrection = nil
        textDocumentProxy.unmarkText()
        clearSelectionReliably()
    }
    
    private func showKeyboardView(_ viewToShow: UIView) {
        mainKeyboardView.isHidden = true
        numericKeyboardView.isHidden = true
        symbolsKeyboardView.isHidden = true
        emojiKeyboardView.isHidden = true
        featureContainerView.isHidden = true
        
        viewToShow.isHidden = false
    }
    
    @objc func switchToEmojiKeyboard() {
        showKeyboardView(emojiKeyboardView)
    }
    
    @objc func switchToAlphabeticKeyboard() {
        showKeyboardView(mainKeyboardView)
    }
    
    @objc private func switchToNumericKeyboard() {
        showKeyboardView(numericKeyboardView)
    }
    
    @objc private func switchToSymbolsKeyboard() {
        showKeyboardView(symbolsKeyboardView)
    }

    private func switchToFeatureView() {
        showKeyboardView(featureContainerView)
    }

    func createBottomRow() -> UIStackView {
        let bottomRow = UIStackView()
        bottomRow.axis = .horizontal
        bottomRow.spacing = 6
        bottomRow.distribution = .fillProportionally

        let numButton = createKeyButton(title: "123", isSpecial: true)
        let emojiButton = createKeyButton(title: "😊", isSpecial: true)
        let spaceButton = createKeyButton(title: "", identifier: "space", isSpecial: false)
        let returnButton = createKeyButton(title: "return", isSpecial: true)

        // Emoji button toggles custom emoji keyboard
        emojiButton.removeTarget(self, action: #selector(keyPressed(_:)), for: .touchUpInside)
        emojiButton.addTarget(self, action: #selector(switchToEmojiKeyboard), for: .touchUpInside)

        // Numeric button toggles numeric keyboard
        numButton.removeTarget(self, action: #selector(keyPressed(_:)), for: .touchUpInside)
        numButton.addTarget(self, action: #selector(switchToNumericKeyboard), for: .touchUpInside)

        bottomRow.addArrangedSubview(numButton)
        bottomRow.addArrangedSubview(emojiButton)
        bottomRow.addArrangedSubview(spaceButton)
        bottomRow.addArrangedSubview(returnButton)

        NSLayoutConstraint.activate([
            numButton.widthAnchor.constraint(equalTo: returnButton.widthAnchor, multiplier: 1.0),
            emojiButton.widthAnchor.constraint(equalTo: numButton.widthAnchor, multiplier: 0.8),
            spaceButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 100)
        ])
        
        return bottomRow
    }
    
    private func setupSuggestionBar() {
        suggestionBar = UIView()
        suggestionBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(suggestionBar)

        NSLayoutConstraint.activate([
            suggestionBar.topAnchor.constraint(equalTo: view.topAnchor),
            suggestionBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            suggestionBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            suggestionBar.heightAnchor.constraint(equalToConstant: 50)
        ])

        // Suggestions Container
        suggestionsContainer = UIView()
        suggestionsContainer.translatesAutoresizingMaskIntoConstraints = false
        suggestionBar.addSubview(suggestionsContainer)

        let featuresButton = UIButton(type: .system)
        featuresButton.setTitle("✨", for: .normal)
        featuresButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        featuresButton.addTarget(self, action: #selector(toggleFeatureViews), for: .touchUpInside)
        featuresButton.tintColor = .white
        featuresButton.backgroundColor = .white
        featuresButton.layer.cornerRadius = 8
        featuresButton.translatesAutoresizingMaskIntoConstraints = false
        suggestionsContainer.addSubview(featuresButton)

//        let suggestionsStackView = UIStackView()
//        suggestionsStackView.axis = .horizontal
//        suggestionsStackView.distribution = .fillEqually
//        suggestionsStackView.spacing = 1
//        suggestionsStackView.translatesAutoresizingMaskIntoConstraints = false
//        suggestionsContainer.addSubview(suggestionsStackView)
//
//        for suggestion in suggestions {
//            let button = createSuggestionButton(title: suggestion)
//            suggestionsStackView.addArrangedSubview(button)
//        }

        NSLayoutConstraint.activate([
            suggestionsContainer.leadingAnchor.constraint(equalTo: suggestionBar.leadingAnchor),
            suggestionsContainer.trailingAnchor.constraint(equalTo: suggestionBar.trailingAnchor),
            suggestionsContainer.topAnchor.constraint(equalTo: suggestionBar.topAnchor, constant: 5),
            suggestionsContainer.bottomAnchor.constraint(equalTo: suggestionBar.bottomAnchor, constant: 5),

            featuresButton.leadingAnchor.constraint(equalTo: suggestionsContainer.leadingAnchor, constant: 16),
            featuresButton.centerYAnchor.constraint(equalTo: suggestionsContainer.centerYAnchor),
            featuresButton.widthAnchor.constraint(equalToConstant: 35),
            featuresButton.heightAnchor.constraint(equalToConstant: 35),

//            suggestionsStackView.leadingAnchor.constraint(equalTo: featuresButton.trailingAnchor, constant: 16),
//            suggestionsStackView.trailingAnchor.constraint(equalTo: suggestionsContainer.trailingAnchor, constant: -16),
//            suggestionsStackView.centerYAnchor.constraint(equalTo: suggestionsContainer.centerYAnchor)
        ])

        // Features Container
        featuresContainer = UIView()
        featuresContainer.translatesAutoresizingMaskIntoConstraints = false
        featuresContainer.isHidden = true
        suggestionBar.addSubview(featuresContainer)

        let featuresScrollView = UIScrollView()
        featuresScrollView.showsHorizontalScrollIndicator = false
        featuresScrollView.translatesAutoresizingMaskIntoConstraints = false
        featuresContainer.addSubview(featuresScrollView)

        let featuresStack = UIStackView()
        featuresStack.axis = .horizontal
        featuresStack.spacing = 8
        featuresStack.translatesAutoresizingMaskIntoConstraints = false
        featuresScrollView.addSubview(featuresStack)
        featuresScrollView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

        let featureTitles = [
            "✅ Check Grammar", "🎭 Tone Changer", "🤖 Ask AI", "🌐 Translate",
            "✍️ Paraphrase", "💬 Reply", "➡️ Continue Text", "🔎 Find Synonyms"
        ]
        for title in featureTitles {
            featuresStack.addArrangedSubview(createFeatureButton(title: title))
        }

        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.addTarget(self, action: #selector(toggleFeatureViews), for: .touchUpInside)
        closeButton.tintColor = keyTextColor
        closeButton.backgroundColor = specialKeyBackgroundColor
        closeButton.layer.cornerRadius = 8
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        featuresContainer.addSubview(closeButton)

        NSLayoutConstraint.activate([
            featuresContainer.leadingAnchor.constraint(equalTo: suggestionBar.leadingAnchor),
            featuresContainer.trailingAnchor.constraint(equalTo: suggestionBar.trailingAnchor),
            featuresContainer.topAnchor.constraint(equalTo: suggestionBar.topAnchor, constant: 5),
            featuresContainer.bottomAnchor.constraint(equalTo: suggestionBar.bottomAnchor),

            featuresScrollView.leadingAnchor.constraint(equalTo: featuresContainer.leadingAnchor, constant: 0),
            featuresScrollView.topAnchor.constraint(equalTo: featuresContainer.topAnchor, constant: 5),
            featuresScrollView.bottomAnchor.constraint(equalTo: featuresContainer.bottomAnchor, constant: -5),
            // Ensure the scroll view has a trailing anchor relative to the close button
            featuresScrollView.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -8),

            featuresStack.leadingAnchor.constraint(equalTo: featuresScrollView.leadingAnchor),
            featuresStack.trailingAnchor.constraint(equalTo: featuresScrollView.trailingAnchor),
            featuresStack.topAnchor.constraint(equalTo: featuresScrollView.topAnchor),
            featuresStack.bottomAnchor.constraint(equalTo: featuresScrollView.bottomAnchor),
            featuresStack.heightAnchor.constraint(equalTo: featuresScrollView.heightAnchor),
            
            closeButton.trailingAnchor.constraint(equalTo: featuresContainer.trailingAnchor, constant: -16),
            closeButton.centerYAnchor.constraint(equalTo: featuresContainer.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 35),
            closeButton.heightAnchor.constraint(equalToConstant: 35)
        ])
    }
    
    func createKeyButton(title: String, identifier: String? = nil, isSpecial: Bool = false) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityIdentifier = identifier ?? title
        
        button.backgroundColor = isSpecial ? specialKeyBackgroundColor : keyBackgroundColor
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        
        if isSpecial {
            button.setTitleColor(keyTextColor, for: .normal)
            if title == "shift" {
                button.setImage(UIImage(systemName: "shift"), for: .normal)
                button.tintColor = keyTextColor
                self.shiftButton = button
            } else if title == "delete" {
                button.setImage(UIImage(systemName: "delete.left"), for: .normal)
                button.tintColor = keyTextColor
            } else {
                button.setTitle(title, for: .normal)
            }
        } else {
            button.setTitle(title, for: .normal)
            button.setTitleColor(keyTextColor, for: .normal)
        }
        
        button.addTarget(self, action: #selector(keyPressed(_:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(keyTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(keyTouchUp(_:)), for: [.touchUpInside, .touchUpOutside])
        
        return button
    }
    
    private func createSuggestionButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(keyTextColor, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.addTarget(self, action: #selector(suggestionPressed(_:)), for: .touchUpInside)
        return button
    }
    
    private func createFeatureButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        button.backgroundColor = specialKeyBackgroundColor
        button.setTitleColor(keyTextColor, for: .normal)
        
        featureButtonStates[title] = false
        button.addTarget(self, action: #selector(featureButtonTapped(_:)), for: .touchUpInside)
        
        return button
    }
    
    @objc private func featureButtonTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle else { return }
        
        // If the button is already active, do nothing
        if featureButtonStates[title] == true {
            return
        }
        
        // Deactivate all buttons first
        deactivateAllFeatureButtons()
        
        // Activate the tapped button
        featureButtonStates[title] = true
        updateFeatureButtonAppearance(button: sender, isActive: true)
        switchToFeatureView()

        if title == "✅ Check Grammar" {
            changeToneView?.isHidden = true
            askAIView?.isHidden = true
            if checkGrammarView == nil {
                checkGrammarView = CheckGrammarView(controller: self)
                featureContainerView.addSubview(checkGrammarView!)
                NSLayoutConstraint.activate([
                    checkGrammarView!.topAnchor.constraint(equalTo: featureContainerView.topAnchor),
                    checkGrammarView!.leadingAnchor.constraint(equalTo: featureContainerView.leadingAnchor),
                    checkGrammarView!.trailingAnchor.constraint(equalTo: featureContainerView.trailingAnchor),
                    checkGrammarView!.bottomAnchor.constraint(equalTo: featureContainerView.bottomAnchor)
                ])
                Task {
                    await self.reloadGrammarCheck()
                }
            }
            checkGrammarView?.isHidden = false
        } else if title == "🎭 Tone Changer" {
            checkGrammarView?.isHidden = true
            askAIView?.isHidden = true
            if changeToneView == nil {
                changeToneView = ChangeToneView(controller: self)
                featureContainerView.addSubview(changeToneView!)
                NSLayoutConstraint.activate([
                    changeToneView!.topAnchor.constraint(equalTo: featureContainerView.topAnchor),
                    changeToneView!.leadingAnchor.constraint(equalTo: featureContainerView.leadingAnchor),
                    changeToneView!.trailingAnchor.constraint(equalTo: featureContainerView.trailingAnchor),
                    changeToneView!.bottomAnchor.constraint(equalTo: featureContainerView.bottomAnchor)
                ])
                Task {
                    await self.reloadGrammarCheck()
                }
            }
            changeToneView?.isHidden = false
        } else if title == "🤖 Ask AI" {
            checkGrammarView?.isHidden = true
            changeToneView?.isHidden = true
            if askAIView == nil {
                askAIView = AskAIView(controller: self)
                featureContainerView.addSubview(askAIView!)
                NSLayoutConstraint.activate([
                    askAIView!.topAnchor.constraint(equalTo: featureContainerView.topAnchor),
                    askAIView!.leadingAnchor.constraint(equalTo: featureContainerView.leadingAnchor),
                    askAIView!.trailingAnchor.constraint(equalTo: featureContainerView.trailingAnchor),
                    askAIView!.bottomAnchor.constraint(equalTo: featureContainerView.bottomAnchor)
                ])
                Task {
                    await self.reloadGrammarCheck()
                }
            }
            askAIView?.isHidden = false
        } else {
            checkGrammarView?.isHidden = true
            changeToneView?.isHidden = true
            askAIView?.isHidden = true
        }
    }

    private func deactivateAllFeatureButtons() {
        for key in featureButtonStates.keys {
            featureButtonStates[key] = false
        }

        guard let featuresScrollView = featuresContainer?.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView,
              let featuresStack = featuresScrollView.subviews.first(where: { $0 is UIStackView }) as? UIStackView else {
            return
        }

        for case let button as UIButton in featuresStack.arrangedSubviews {
            updateFeatureButtonAppearance(button: button, isActive: false)
        }
        
        
    }

    private func updateFeatureButtonAppearance(button: UIButton, isActive: Bool) {
        if isActive {
            button.backgroundColor = .systemGreen
            button.setTitleColor(.white, for: .normal)
        } else {
            button.backgroundColor = keyBackgroundColor
            button.setTitleColor(keyTextColor, for: .normal)
        }
    }
    
    func isSpecialKey(_ key: String) -> Bool {
        return ["shift", "delete", "123", "😊", "return", "ABC", "#+="].contains(key)
    }
    
    @objc func keyPressed(_ sender: UIButton) {
        let proxy = textDocumentProxy
    
        // Single deleteBackward for selected text
        if let selectedText = proxy.selectedText, !selectedText.isEmpty {
            proxy.deleteBackward()
        }
        
        guard let key = sender.accessibilityIdentifier else { return }

        switch key {
        case "delete":
            // This is now handled by keyTouchDown and keyTouchUp to support long press
            break
        case "shift":
            toggleShift()
        case "space":
            proxy.insertText(" ")
        case "return":
            proxy.insertText("\n")
        case "123":
            switchToNumericKeyboard()
            break
        case "#+=":
            switchToSymbolsKeyboard()
            break
        case "😊":
            switchToEmojiKeyboard()
            break
        default:
            let textToInsert = isShiftEnabled || isCapsLockEnabled ? key.uppercased() : key.lowercased()
            proxy.insertText(textToInsert)
            if isShiftEnabled && !isCapsLockEnabled {
                toggleShift(forceOff: true)
            }
        }
    }
    
    @objc private func suggestionPressed(_ sender: UIButton) {
        if let title = sender.currentTitle {
            textDocumentProxy.insertText(title + " ")
        }
    }
    
    @objc private func keyTouchDown(_ sender: UIButton) {
        // sender.backgroundColor = self.keyBackgroundColor.withAlphaComponent(0.7)
        // sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)

        if sender.accessibilityIdentifier == "delete" {
            textDocumentProxy.deleteBackward()
            deleteTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
                self?.startContinuousDelete()
            }
        }
    }
    
    @objc private func keyTouchUp(_ sender: UIButton) {
        // sender.backgroundColor = self.isSpecialKey(sender.accessibilityIdentifier ?? "") ? self.specialKeyBackgroundColor : self.keyBackgroundColor
        // sender.transform = CGAffineTransform.identity

        if sender.accessibilityIdentifier == "delete" {
            deleteTimer?.invalidate()
            deleteTimer = nil
        }
    }

    private func startContinuousDelete() {
        deleteTimer?.invalidate() // Stop the first timer
        deleteTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.textDocumentProxy.deleteBackward()
        }
    }
    
    private func toggleShift(forceOff: Bool = false) {
        if forceOff {
            isShiftEnabled = false
            isCapsLockEnabled = false
        } else {
            isShiftEnabled.toggle()
        }
        
        updateKeyCaps()
        updateShiftButtonAppearance()
    }

    private func updateShiftButtonAppearance() {
        if isCapsLockEnabled {
            shiftButton?.setImage(UIImage(systemName: "shift.fill"), for: .normal)
            shiftButton?.tintColor = .systemBlue
        } else if isShiftEnabled {
            shiftButton?.setImage(UIImage(systemName: "shift.fill"), for: .normal)
            shiftButton?.tintColor = keyTextColor
        } else {
            shiftButton?.setImage(UIImage(systemName: "shift"), for: .normal)
            shiftButton?.tintColor = keyTextColor
        }
    }

    private func updateKeyCaps() {
        let shouldUppercase = isShiftEnabled || isCapsLockEnabled

        
        
        func updateButtonsRecursively(in view: UIView) {
            for subview in view.subviews {
                if let button = subview as? UIButton, !isSpecialKey(button.accessibilityIdentifier ?? "") {
                    let title = button.accessibilityIdentifier ?? ""
                    button.setTitle(shouldUppercase ? title.uppercased() : title.lowercased(), for: .normal)
                    button.titleLabel?.font = shouldUppercase ? UIFont.systemFont(ofSize: 17, weight: .regular) : UIFont.systemFont(ofSize: 20, weight: .regular)
                } else {
                    updateButtonsRecursively(in: subview)
                }
            }
        }
        
        if let mainView = mainKeyboardView {
            updateButtonsRecursively(in: mainView)
        }
        // if !mainKeyboardView.isHidden {
        //     updateMainKeyboardCaps(shouldUppercase)
        // }
    }

    @MainActor
    func collectFullText() async -> String {
        // Step 1: collect and move to beginning
        let leftPart = await moveLeftUntilStart()
        print("Left part = \(leftPart)")
        
        textDocumentProxy.adjustTextPosition(byCharacterOffset: leftPart.count)
        
//        // Step 2: collect and move to end
        let rightPart = await moveRightUntilEnd()
        print("Right part = \(rightPart)")
//        
        let fullText = leftPart + rightPart
        print("Full collected text = \(fullText)")
//        textDocumentProxy.adjustTextPosition(byCharacterOffset: -leftPart.count)
//        textDocumentProxy.setMarkedText(fullText, selectedRange: NSRange(location: 0, length: leftPart.count))
        
        textDocumentProxy.adjustTextPosition(byCharacterOffset: -rightPart.count)
        
        // Delete left part
        for _ in 0..<leftPart.count {
            textDocumentProxy.deleteBackward()
        }
        textDocumentProxy.setMarkedText(fullText, selectedRange: NSRange(location: 0, length: leftPart.count ))
        try? await Task.sleep(nanoseconds: 200_000_000)
        textDocumentProxy.unmarkText()
        return fullText
    }

    @MainActor
    func markLeftPartForReplacement() async -> String? {
        let leftPart = await moveLeftUntilStart()
        let leftCount = leftPart.count
        if leftCount == 0 {
            return nil
        }
        
        // Restore cursor
        textDocumentProxy.adjustTextPosition(byCharacterOffset: leftCount)
        
//         // Delete left part
        for _ in 0..<leftCount {
//            textDocumentProxy.adjustTextPosition(byCharacterOffset: -1)
            textDocumentProxy.deleteBackward()
        }
        try? await Task.sleep(nanoseconds: 200_000_000)
        // Mark placeholder so typing replaces it
        textDocumentProxy.setMarkedText(leftPart, selectedRange: NSRange(location: 0, length: leftCount))
        return leftPart
    }

    @MainActor
    private func moveLeftUntilStart() async -> String {
        var collected = ""

        while let before = textDocumentProxy.documentContextBeforeInput, !before.isEmpty {
            let step = before.count
            let slice = String(before.suffix(step))
            collected = slice + collected

            textDocumentProxy.adjustTextPosition(byCharacterOffset: -step)
            try? await Task.sleep(nanoseconds: 80_000_000)

            if (textDocumentProxy.documentContextBeforeInput ?? "").isEmpty {
                break
            }
        }

        return collected
    }

    @MainActor
    private func moveRightUntilEnd() async -> String {
        var collected = ""

        while let after = textDocumentProxy.documentContextAfterInput, !after.isEmpty {
            let step = after.count
            let slice = String(after.prefix(step))
            collected += slice

            textDocumentProxy.adjustTextPosition(byCharacterOffset: step)
            try? await Task.sleep(nanoseconds: 80_000_000)

            if (textDocumentProxy.documentContextAfterInput ?? "").isEmpty {
                break
            }
        }

        return collected
    }
    
    
    func getSelectedText() -> String? {
        return textDocumentProxy.selectedText
    }
    
    func applyCorrection(newText: String) {
        // First, verify that the context hasn't changed.
        // The text that is currently marked/selected should be the same as the text we processed.
        guard let originalText = originalTextForCorrection,
              textDocumentProxy.selectedText == originalText
        
        else {
            // If the context has changed, do nothing to avoid applying the correction in the wrong place.
            clearSelectionReliably()
            self.originalTextForCorrection = nil
            return
        }
        
        // Context is valid, so replace the marked text with the correction.
        textDocumentProxy.insertText(newText)
        
        // Clean up
        self.originalTextForCorrection = nil
        
        self.closeFeatureContainerView()
    }

    // Allow the view to request a fresh grammar check using current context
    @MainActor
    func reloadGrammarCheck() async {
        var textToProcess: String?
        var isSelection = false

        if let selectedText = getSelectedText(), !selectedText.isEmpty {
            textToProcess = selectedText
            isSelection = true
            textDocumentProxy.setMarkedText(selectedText, selectedRange: NSRange(location: 0, length: selectedText.count))
        } else {
            // Since markLeftPartForReplacement now returns the marked text, we can use that directly
            if let markedText = await markLeftPartForReplacement() {
                textToProcess = markedText
                isSelection = true // After marking, it becomes a selection
            }
        }

        if let text = textToProcess, !text.isEmpty {
            self.originalTextForCorrection = text // Store the text that is being processed
            
            // Find which feature is active and only process the text for that view
            if featureButtonStates["✅ Check Grammar"] == true {
                await checkGrammarView?.processText(text)
            } else if featureButtonStates["🎭 Tone Changer"] == true {
                await changeToneView?.processText(text)
            } else if featureButtonStates["🤖 Ask AI"] == true {
                await askAIView?.processText(text)
            }
            
            // The text remains marked until it's either applied or the view is closed.
        }
    }
    
    private func clearSelectionReliably() {
        if let selectedText = textDocumentProxy.selectedText, !selectedText.isEmpty {
            // Replacing the selected (marked) text with itself is the most reliable way
            // to force the text input system to clear the visual marking underline.
            textDocumentProxy.insertText(selectedText)
        }
    }
    
    override func textWillChange(_ textInput: UITextInput?) {}
    
    override func textDidChange(_ textInput: UITextInput?) {}
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        var label: UILabel!
        if let existing = cell.contentView.viewWithTag(100) as? UILabel {
            label = existing
        } else {
            label = UILabel(frame: cell.contentView.bounds)
            label.tag = 100
            label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 30)
            cell.contentView.addSubview(label)
        }
        label.text = emojis[indexPath.item]
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        textDocumentProxy.insertText(emojis[indexPath.item])
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return .zero
        }
        let itemsPerRow: CGFloat = 8
        let itemsPerColumn: CGFloat = 4
        
        let totalHorizontalSpacing = (itemsPerRow - 1) * layout.minimumInteritemSpacing
        let availableWidth = collectionView.bounds.width - totalHorizontalSpacing
        let width = availableWidth / itemsPerRow

        let totalVerticalSpacing = (itemsPerColumn - 1) * layout.minimumLineSpacing
        let availableHeight = collectionView.bounds.height - totalVerticalSpacing
        let height = availableHeight / itemsPerColumn

        return CGSize(width: floor(width), height: floor(height))
    }
}
