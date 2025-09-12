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
    
    private var mainKeyboardView: UIView!
    private var emojiKeyboardView: UIView!
    private var numericKeyboardView: UIView!
    private var symbolsKeyboardView: UIView!
    private var emojiCollectionView: UICollectionView!
    
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
    
    private var keyBackgroundColor: UIColor {
        return UIColor { (traits) -> UIColor in
            return traits.userInterfaceStyle == .dark ?
                UIColor(red: 0.25, green: 0.25, blue: 0.27, alpha: 1.0) :
                .white
        }
    }
    
    private var specialKeyBackgroundColor: UIColor {
        return UIColor { (traits) -> UIColor in
            return traits.userInterfaceStyle == .dark ?
                UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0) :
                UIColor(red: 0.82, green: 0.84, blue: 0.86, alpha: 1.0)
        }
    }
    
    private var keyTextColor: UIColor {
        return UIColor { (traits) -> UIColor in
            return traits.userInterfaceStyle == .dark ? .white : .black
        }
    }
    
    private var keyboardBackgroundColor: UIColor {
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
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateKeyboardAppearance()
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
        
        updateButtons(in: view)
        updateShiftButtonAppearance()
    }

    private func setupKeyboard() {
        view.backgroundColor = keyboardBackgroundColor
        
        let keyboardHeight: CGFloat = 280
        let heightConstraint = NSLayoutConstraint(item: view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: keyboardHeight)
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
        
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.spacing = 10
        mainStackView.distribution = .fillEqually
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainKeyboardView.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: mainKeyboardView.topAnchor, constant: 10),
            mainStackView.leadingAnchor.constraint(equalTo: mainKeyboardView.leadingAnchor, constant: 4),
            mainStackView.trailingAnchor.constraint(equalTo: mainKeyboardView.trailingAnchor, constant: -4),
            mainStackView.bottomAnchor.constraint(equalTo: mainKeyboardView.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
        
        keyboardRows.enumerated().forEach { (rowIndex, row) in
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.spacing = 6
            rowStackView.distribution = .fillProportionally
            
            if rowIndex == 1 {
                let container = UIView()
                container.addSubview(rowStackView)
                rowStackView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    rowStackView.topAnchor.constraint(equalTo: container.topAnchor),
                    rowStackView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                    rowStackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
                    rowStackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20)
                ])
                mainStackView.addArrangedSubview(container)
            } else {
                mainStackView.addArrangedSubview(rowStackView)
            }
            
            row.forEach { key in
                let button = createKeyButton(title: key, isSpecial: isSpecialKey(key))
                rowStackView.addArrangedSubview(button)
            }
        }
        
        let bottomRowStackView = createBottomRow()
        mainStackView.addArrangedSubview(bottomRowStackView)
        
        // Emoji and Numeric keyboards
        setupEmojiKeyboard()
        setupNumericKeyboard()
        setupSymbolsKeyboard()
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
        
        let numericStackView = UIStackView()
        numericStackView.axis = .vertical
        numericStackView.spacing = 10
        numericStackView.distribution = .fillEqually
        numericStackView.translatesAutoresizingMaskIntoConstraints = false
        numericKeyboardView.addSubview(numericStackView)
        
        NSLayoutConstraint.activate([
            numericStackView.topAnchor.constraint(equalTo: numericKeyboardView.topAnchor, constant: 10),
            numericStackView.leadingAnchor.constraint(equalTo: numericKeyboardView.leadingAnchor, constant: 4),
            numericStackView.trailingAnchor.constraint(equalTo: numericKeyboardView.trailingAnchor, constant: -4),
            numericStackView.bottomAnchor.constraint(equalTo: numericKeyboardView.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
        
        numericKeyboardRows.forEach { row in
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.spacing = 6
            rowStackView.distribution = .fillProportionally
            numericStackView.addArrangedSubview(rowStackView)
            
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
        
        numericStackView.addArrangedSubview(bottomRow)
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
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.isPagingEnabled = true
        emojiCollectionView = collection
        collection.dataSource = self
        collection.delegate = self
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collection.backgroundColor = .clear
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.showsHorizontalScrollIndicator = false
        emojiKeyboardView.addSubview(collection)
        
        let abcButton = createKeyButton(title: "ABC", isSpecial: true)
        abcButton.addTarget(self, action: #selector(switchToAlphabeticKeyboard), for: .touchUpInside)
        emojiKeyboardView.addSubview(abcButton)
        self.abcButton = abcButton
        
        NSLayoutConstraint.activate([
            collection.topAnchor.constraint(equalTo: emojiKeyboardView.topAnchor, constant: 10),
            collection.leadingAnchor.constraint(equalTo: emojiKeyboardView.leadingAnchor, constant: 8),
            collection.trailingAnchor.constraint(equalTo: emojiKeyboardView.trailingAnchor, constant: -8),
            
            abcButton.leadingAnchor.constraint(equalTo: emojiKeyboardView.leadingAnchor, constant: 8),
            abcButton.bottomAnchor.constraint(equalTo: emojiKeyboardView.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            abcButton.widthAnchor.constraint(equalToConstant: 80),
            abcButton.heightAnchor.constraint(equalToConstant: 44),
            
            collection.bottomAnchor.constraint(equalTo: abcButton.topAnchor, constant: -10)
        ])
    }
    
    @objc private func switchToEmojiKeyboard() {
        mainKeyboardView.isHidden = true
        emojiKeyboardView.isHidden = false
        numericKeyboardView.isHidden = true
        symbolsKeyboardView.isHidden = true
    }
    
    @objc private func switchToAlphabeticKeyboard() {
        emojiKeyboardView.isHidden = true
        mainKeyboardView.isHidden = false
        numericKeyboardView.isHidden = true
        symbolsKeyboardView.isHidden = true
    }
    
    @objc private func switchToNumericKeyboard() {
        mainKeyboardView.isHidden = true
        emojiKeyboardView.isHidden = true
        numericKeyboardView.isHidden = false
        symbolsKeyboardView.isHidden = true
    }
    
    @objc private func switchToSymbolsKeyboard() {
        mainKeyboardView.isHidden = true
        emojiKeyboardView.isHidden = true
        numericKeyboardView.isHidden = true
        symbolsKeyboardView.isHidden = false
    }

    private func createBottomRow() -> UIStackView {
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
        suggestionBar.backgroundColor = .clear
        view.addSubview(suggestionBar)
        
        NSLayoutConstraint.activate([
            suggestionBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            suggestionBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            suggestionBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            suggestionBar.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 1
        stackView.translatesAutoresizingMaskIntoConstraints = false
        suggestionBar.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: suggestionBar.centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: suggestionBar.centerXAnchor),
            stackView.widthAnchor.constraint(equalTo: suggestionBar.widthAnchor, multiplier: 0.6)
        ])
        
        for suggestion in suggestions {
            let button = createSuggestionButton(title: suggestion)
            stackView.addArrangedSubview(button)
        }
    }
    
    private func createKeyButton(title: String, identifier: String? = nil, isSpecial: Bool = false) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityIdentifier = identifier ?? title
        
        button.backgroundColor = isSpecial ? specialKeyBackgroundColor : keyBackgroundColor
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        
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
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(suggestionPressed(_:)), for: .touchUpInside)
        return button
    }
    
    private func isSpecialKey(_ key: String) -> Bool {
        return ["shift", "delete", "123", "😊", "return", "ABC", "#+="].contains(key)
    }
    
    @objc private func keyPressed(_ sender: UIButton) {
        let proxy = textDocumentProxy
        guard let key = sender.accessibilityIdentifier else { return }

        switch key {
        case "delete":
            proxy.deleteBackward()
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
        UIView.animate(withDuration: 0.1) {
            sender.backgroundColor = self.keyBackgroundColor.withAlphaComponent(0.7)
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    @objc private func keyTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.backgroundColor = self.isSpecialKey(sender.accessibilityIdentifier ?? "") ? self.specialKeyBackgroundColor : self.keyBackgroundColor
            sender.transform = CGAffineTransform.identity
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
        
        updateButtonsRecursively(in: view)
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
        let horizontalPadding = collectionView.contentInset.left + collectionView.contentInset.right + 10
        let verticalPadding = collectionView.contentInset.top + collectionView.contentInset.bottom
        
        let availableWidth = collectionView.bounds.width - horizontalPadding
        let availableHeight = collectionView.bounds.height - verticalPadding
        
        let width = (availableWidth / itemsPerRow) - (layout.minimumInteritemSpacing * (itemsPerRow - 1) / itemsPerRow)
        let height = (availableHeight / itemsPerColumn) - (layout.minimumLineSpacing * (itemsPerColumn - 1) / itemsPerColumn)

        return CGSize(width: floor(width), height: floor(height))
    }
}
