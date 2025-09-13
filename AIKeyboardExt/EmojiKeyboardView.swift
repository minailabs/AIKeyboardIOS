import UIKit

final class EmojiKeyboardView: UIView {
    init(controller: KeyboardViewController) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10

        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.isPagingEnabled = false
        collection.backgroundColor = .clear
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.showsHorizontalScrollIndicator = false
        collection.dataSource = controller
        collection.delegate = controller
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        addSubview(collection)

        let abcButton = controller.createKeyButton(title: "ABC", isSpecial: true)
        // Ensure ABC switches layout only
        abcButton.removeTarget(controller, action: #selector(KeyboardViewController.keyPressed(_:)), for: .touchUpInside)
        abcButton.addTarget(controller, action: #selector(KeyboardViewController.switchToAlphabeticKeyboard), for: .touchUpInside)
        addSubview(abcButton)

        // Expose collection to controller to keep behavior identical
        controller.emojiCollectionView = collection

        NSLayoutConstraint.activate([
            collection.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            collection.leadingAnchor.constraint(equalTo: leadingAnchor),
            collection.trailingAnchor.constraint(equalTo: trailingAnchor),

            abcButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            abcButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8),
            abcButton.widthAnchor.constraint(equalToConstant: 80),
            abcButton.heightAnchor.constraint(equalToConstant: 44),

            collection.bottomAnchor.constraint(equalTo: abcButton.topAnchor, constant: -10)
        ])
    }

    required init?(coder: NSCoder) {
        return nil
    }
}


