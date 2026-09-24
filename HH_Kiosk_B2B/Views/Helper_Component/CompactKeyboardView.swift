import UIKit

/// An in-app input view; it never reads or stores text from other apps.
final class CompactKeyboardView: UIInputView, UIInputViewAudioFeedback {
    weak var textField: UITextField?
    var onDone: (() -> Void)?
    var enableInputClicksWhenVisible: Bool { true }

    private var kind: KioskKeyboardKind
    private var fieldTitle: String
    private weak var titleLabel: UILabel?
    private enum Page { case letters, numbers, symbols }
    private var page: Page = .letters
    private var shifted = false
    private var deleteTimer: Timer?
    private let content = UIStackView()
    private var lastHeight: CGFloat = 0

    init(kind: KioskKeyboardKind, fieldTitle: String) {
        self.kind = kind
        self.fieldTitle = fieldTitle
        super.init(frame: CGRect(x: 0, y: 0, width: 768, height: 308), inputViewStyle: .keyboard)
        allowsSelfSizing = true
        overrideUserInterfaceStyle = .light
        backgroundColor = UIColor(red: 0.82, green: 0.84, blue: 0.87, alpha: 1)
        content.axis = .vertical
        content.spacing = 6
        addSubview(content)
        rebuildKeys()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(for field: UITextField, kind: KioskKeyboardKind, title: String, onDone: @escaping () -> Void) {
        let layoutChanged = self.kind.isNumeric != kind.isNumeric || (self.kind != kind && !kind.isNumeric)
        if textField !== field {
            deleteTimer?.invalidate()
            deleteTimer = nil
        }
        textField = field
        self.onDone = onDone
        self.kind = kind
        fieldTitle = title
        // Keep the input view attached and at the same size during focus changes.
        // Numeric fields only need a new title; Email changes the keys in place.
        UIView.performWithoutAnimation {
            if layoutChanged {
                shifted = false
                page = .letters
                rebuildKeys()
            } else {
                titleLabel?.text = title
            }
            layoutIfNeeded()
        }
    }

    private var keyboardHeight: CGFloat {
        let size = textField?.window?.bounds.size ?? UIScreen.main.bounds.size
        return (size.width > size.height ? 260 : 308) + (textField?.window?.safeAreaInsets.bottom ?? 0)
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: keyboardHeight)
    }

    override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        CGSize(width: targetSize.width, height: keyboardHeight)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if lastHeight != keyboardHeight {
            lastHeight = keyboardHeight
            invalidateIntrinsicContentSize()
        }
        let bottomInset = textField?.window?.safeAreaInsets.bottom ?? 0
        let width = min(bounds.width - 24, kind.isNumeric ? 620 : 1120)
        content.frame = CGRect(x: (bounds.width - width) / 2, y: 6, width: width, height: bounds.height - bottomInset - 18)
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window == nil {
            deleteTimer?.invalidate()
            deleteTimer = nil
            shifted = false
            page = .letters
            rebuildKeys()
        }
    }

    private func rebuildKeys() {
        content.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let toolbar = UIStackView()
        toolbar.spacing = 12
        let title = UILabel()
        titleLabel = title
        title.text = fieldTitle
        title.font = .systemFont(ofSize: 15, weight: .semibold)
        title.textColor = .darkGray
        toolbar.addArrangedSubview(title)
        toolbar.addArrangedSubview(UIView())
        toolbar.addArrangedSubview(actionButton("Done", action: { [weak self] in self?.finish() }))
        toolbar.heightAnchor.constraint(equalToConstant: 32).isActive = true
        content.addArrangedSubview(toolbar)

        let rows = UIStackView()
        rows.axis = .vertical
        rows.spacing = 6
        rows.distribution = .fillEqually
        content.addArrangedSubview(rows)
        if kind.isNumeric {
            for characters in ["123", "456", "789"] {
                rows.addArrangedSubview(row(characters.map { characterKey(String($0)) }))
            }
            rows.addArrangedSubview(row([key("Done", special: true) { [weak self] in self?.finish() }, characterKey("0"), deleteKey()]))
        } else {
            let first: String
            let second: String
            let third: String
            switch page {
            case .letters:
                first = "qwertyuiop"; second = "asdfghjkl"; third = "zxcvbnm"
            case .numbers:
                first = "1234567890"; second = "-/:;()$&@\""; third = ".,?!'"
            case .symbols:
                first = "[]{}#%^*+="; second = "_\\|~<>€£¥•"; third = ".,?!'"
            }
            rows.addArrangedSubview(row(first.map { characterKey(String($0)) }))
            rows.addArrangedSubview(row(second.map { characterKey(String($0)) }, inset: page == .letters ? 24 : 0))
            let shift = key(page == .letters ? "Shift" : (page == .numbers ? "#+=" : "123"), symbol: page == .letters ? (shifted ? "shift.fill" : "shift") : nil, special: true) { [weak self] in
                guard let self else { return }
                if page == .letters { shifted.toggle() } else { page = page == .numbers ? .symbols : .numbers }
                rebuildKeys()
            }
            shift.accessibilityValue = shifted ? "Uppercase" : "Lowercase"
            rows.addArrangedSubview(row([shift] + third.map { characterKey(String($0)) } + [deleteKey()]))
            let mode = key(page == .letters ? "123" : "ABC", special: true) { [weak self] in
                guard let self else { return }
                page = page == .letters ? .numbers : .letters
                rebuildKeys()
            }
            let space = key("space") { [weak self] in self?.insert(" ") }
            // Email addresses have no spaces; offer a useful domain shortcut in that position.
            let middle = kind == .email ? characterKey(".com") : space
            let done = key("Done", special: true, primary: true) { [weak self] in self?.finish() }
            rows.addArrangedSubview(row([mode, characterKey("@"), middle, characterKey("."), done]))
        }
        setNeedsLayout()
    }

    private func row(_ keys: [UIView], inset: CGFloat = 0) -> UIView {
        let stack = UIStackView(arrangedSubviews: keys)
        stack.spacing = 6
        stack.distribution = .fillEqually
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        return stack
    }

    private func characterKey(_ text: String) -> UIButton {
        let value = page == .letters && shifted ? text.uppercased() : text
        return key(value) { [weak self] in
            self?.insert(value)
            if self?.shifted == true {
                self?.shifted = false
                self?.rebuildKeys()
            }
        }
    }

    private func insert(_ text: String) {
        textField?.insertText(text)
    }

    private func finish() {
        if let onDone { onDone() } else { textField?.resignFirstResponder() }
    }

    private func deleteKey() -> UIButton {
        let button = key("Delete", symbol: "delete.left", special: true) { [weak self] in self?.textField?.deleteBackward() }
        let hold = UILongPressGestureRecognizer(target: self, action: #selector(repeatDelete(_:)))
        hold.minimumPressDuration = 0.4
        button.addGestureRecognizer(hold)
        return button
    }

    @objc private func repeatDelete(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state != .changed else { return }
        deleteTimer?.invalidate()
        deleteTimer = nil
        if gesture.state == .began {
            textField?.deleteBackward()
            deleteTimer = Timer.scheduledTimer(withTimeInterval: 0.09, repeats: true) { [weak self] _ in
                MainActor.assumeIsolated { self?.textField?.deleteBackward() }
            }
        }
    }

    private func actionButton(_ title: String, symbol: String? = nil, action: @escaping () -> Void) -> UIButton {
        let button = UIButton(type: .system)
        var configuration = UIButton.Configuration.plain()
        configuration.title = title
        configuration.image = symbol.map { UIImage(systemName: $0) } ?? nil
        configuration.imagePlacement = .trailing
        configuration.imagePadding = 6
        configuration.contentInsets = .init(top: 0, leading: 10, bottom: 0, trailing: 10)
        button.configuration = configuration
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
        return button
    }

    private func key(_ title: String, symbol: String? = nil, special: Bool = false, primary: Bool = false, action: @escaping () -> Void) -> UIButton {
        let button = UIButton(type: .custom)
        button.accessibilityLabel = title
        button.accessibilityIdentifier = "compact-key-\(title)"
        button.backgroundColor = primary ? .systemBlue : special ? UIColor(red: 0.68, green: 0.71, blue: 0.76, alpha: 1) : .white
        button.setTitleColor(primary ? .white : .black, for: .normal)
        button.tintColor = primary ? .white : .black
        button.titleLabel?.font = .systemFont(ofSize: title.count > 2 ? 18 : 23, weight: .regular)
        if let symbol {
            button.setImage(UIImage(systemName: symbol, withConfiguration: UIImage.SymbolConfiguration(pointSize: 21)), for: .normal)
        } else {
            button.setTitle(title, for: .normal)
        }
        button.layer.cornerRadius = 6
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.22
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowRadius = 0
        button.addAction(UIAction { _ in
            UIDevice.current.playInputClick()
            action()
        }, for: .touchUpInside)
        button.addAction(UIAction { [weak button] _ in button?.alpha = 0.55 }, for: .touchDown)
        button.addAction(UIAction { [weak button] _ in button?.alpha = 1 }, for: [.touchUpInside, .touchUpOutside, .touchCancel])
        return button
    }
}
