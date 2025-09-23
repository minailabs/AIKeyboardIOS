import UIKit

final class NumericKeyboardView: UIView {
    init(controller: KeyboardViewController, rows: [[String]]) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        let numericStackView = UIStackView()
        numericStackView.axis = .vertical
        numericStackView.spacing = 9
        numericStackView.distribution = .fillEqually
        numericStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(numericStackView)

        NSLayoutConstraint.activate([
            numericStackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            numericStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            numericStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            numericStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])

        rows.forEach { row in
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.spacing = 6
            rowStackView.distribution = .fillEqually
            numericStackView.addArrangedSubview(rowStackView)

            row.forEach { key in
                let button = controller.createKeyButton(title: key, isSpecial: controller.isSpecialKey(key))
                rowStackView.addArrangedSubview(button)
            }
        }

        let bottomRow = UIStackView()
        bottomRow.axis = .horizontal
        bottomRow.spacing = 7
        bottomRow.distribution = .fillProportionally

        let abcButton = controller.createKeyButton(title: "ABC", isSpecial: true)
        // Prevent inserting text when tapping ABC; only switch layout
        abcButton.removeTarget(controller, action: #selector(KeyboardViewController.keyPressed(_:)), for: .touchUpInside)
        abcButton.addTarget(controller, action: #selector(KeyboardViewController.switchToAlphabeticKeyboard), for: .touchUpInside)

        let emojiButton = controller.createKeyButton(title: "😊", isSpecial: true)
        // Prevent inserting text when tapping emoji; only switch layout
        emojiButton.removeTarget(controller, action: #selector(KeyboardViewController.keyPressed(_:)), for: .touchUpInside)
        emojiButton.addTarget(controller, action: #selector(KeyboardViewController.switchToEmojiKeyboard), for: .touchUpInside)

        let spaceButton = controller.createKeyButton(title: "", identifier: "space", isSpecial: false)
        let returnButton = controller.createKeyButton(title: "return", isSpecial: true)

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

    required init?(coder: NSCoder) {
        return nil
    }
}


