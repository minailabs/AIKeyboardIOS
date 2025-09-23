import UIKit

final class AlphabeticKeyboardView: UIView {
    init(controller: KeyboardViewController, keyboardRows: [[String]]) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.spacing = 9
        mainStackView.distribution = .fillEqually
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStackView)

        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            mainStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])

        keyboardRows.enumerated().forEach { (rowIndex, row) in
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.spacing = 6
            rowStackView.distribution = .fillEqually

            if rowIndex == 1 {
                let container = UIView()
                container.addSubview(rowStackView)
                rowStackView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    rowStackView.topAnchor.constraint(equalTo: container.topAnchor),
                    rowStackView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                    rowStackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 15),
                    rowStackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -15)
                ])
                mainStackView.addArrangedSubview(container)
            } else {
                mainStackView.addArrangedSubview(rowStackView)
            }

            row.forEach { key in
                let button = controller.createKeyButton(title: key, isSpecial: controller.isSpecialKey(key))
                rowStackView.addArrangedSubview(button)
            }
        }

        let bottomRowStackView = controller.createBottomRow()
        mainStackView.addArrangedSubview(bottomRowStackView)
    }

    required init?(coder: NSCoder) {
        return nil
    }
}


