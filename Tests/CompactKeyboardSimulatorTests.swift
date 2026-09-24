// Run with Tests/run-compact-keyboard-tests.sh <booted-iPad-simulator-UDID>.
import SwiftUI
import UIKit

@MainActor final class TestModel: ObservableObject {
    @Published var email = ""
    @Published var pin = ""
    @Published var age = ""
    @Published var focus: PhysicalAttributesInputField? = .email
}
struct TestForm: View {
    @ObservedObject var model: TestModel
    func binding(_ field: PhysicalAttributesInputField) -> Binding<Bool> {
        Binding(get: { model.focus == field }, set: { if $0 { model.focus = field } else if model.focus == field { model.focus = nil } })
    }
    var body: some View {
        VStack(spacing: 24) {
            Text("Compact keyboard verification").font(.title)
            KioskTextField(text: $model.email, isFocused: binding(.email), placeholder: "Enter email", title: "Email", kind: .email).frame(height: 44)
            KioskTextField(text: $model.pin, isFocused: binding(.pin), placeholder: "4-digit PIN", title: "PIN", kind: .pin).frame(height: 44)
            KioskTextField(text: $model.age, isFocused: binding(.age), placeholder: "Age", title: "Age", kind: .integer).frame(height: 44)
            Spacer()
        }.padding(30).background(Color.white)
    }
}

// Exercise the actual profile sections, including their validation-driven view updates.
struct ProfileRegressionForm: View {
    var testsScrolling = false
    @State private var focus: PhysicalAttributesInputField?
    @State private var email: String?
    @State private var pin = ""
    @State private var age: Int?
    @State private var weight: Int?
    @State private var pounds: Int?

    var body: some View {
        PhysicalAttributesScrollView(focusedField: $focus) {
            VStack(spacing: 20) {
                if testsScrolling { Color.clear.frame(height: 400) }
                ProfileEmailSection(email: $email, focusedField: $focus)
                ProfilePINSection(pin: $pin, focusedField: $focus)
                ProfileWeightSection(selectedWeight: $weight, selectedWeightInPounds: $pounds, focusedField: $focus)
                ProfileAgeSection(selectedAge: $age, focusedField: $focus)
                if testsScrolling { Color.clear.frame(height: 400) }
            }.padding(30)
        }
    }
}

@main final class PreviewDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var keyboardHideCount = 0
    var keyboardHideObserver: NSObjectProtocol?
    let model = TestModel()
    let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        keyboardHideObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { [weak self] _ in
            MainActor.assumeIsolated { self?.keyboardHideCount += 1 }
        }
        for result in ["result.txt", "rotation.txt", "profile.txt", "scroll.txt"] {
            try? FileManager.default.removeItem(at: documents.appendingPathComponent(result))
        }
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIHostingController(rootView: TestForm(model: model))
        window.makeKeyAndVisible()
        self.window = window
        Task { @MainActor in
            window.windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            try? await Task.sleep(for: .seconds(1))
            runTypingTests()
        }
        return true
    }
    func descendants(_ view: UIView) -> [UIView] { [view] + view.subviews.flatMap(descendants) }
    func field(_ title: String) -> UITextField {
        descendants(window!).compactMap { $0 as? UITextField }.first { $0.accessibilityLabel == title }!
    }
    func runTypingTests() {
        Task { @MainActor in
            let email = field("Email")
            email.becomeFirstResponder()
            try? await Task.sleep(for: .milliseconds(300))
            email.insertText("test@example.com")
            precondition(model.email == "test@example.com", "Custom input must update binding")
            let start = email.position(from: email.beginningOfDocument, offset: 4)!
            email.selectedTextRange = email.textRange(from: start, to: start)
            email.insertText("+tag")
            precondition(model.email == "test+tag@example.com", "Must insert at caret")
            email.deleteBackward()
            precondition(model.email == "test+ta@example.com")
            let keyboard = email.inputView as! CompactKeyboardView
            precondition(!descendants(keyboard).compactMap { $0 as? UIButton }.contains { $0.title(for: .normal) == "Next" || $0.configuration?.title == "Next" }, "Keyboard must not show Next")
            keyboard.onDone?()
            try? await Task.sleep(for: .milliseconds(300))
            precondition(!email.isFirstResponder && model.focus == nil, "Email Done dismisses instead of advancing")
            model.focus = .pin
            try? await Task.sleep(for: .milliseconds(400))
            let pin = field("PIN")
            precondition(pin.isFirstResponder && model.focus == .pin, "Manual field selection must focus PIN")
            pin.insertText("00123")
            precondition(model.pin == "0012", "PIN maximum length")
            precondition(pin.text == "••••", "PIN must mask immediately")
            pin.deleteBackward()
            precondition(model.pin == "001" && pin.text == "•••", "Masked deletion")
            let pinStart = pin.beginningOfDocument
            let pinEnd = pin.position(from: pinStart, offset: 2)!
            pin.selectedTextRange = pin.textRange(from: pinStart, to: pinEnd)
            pin.insertText("98")
            precondition(model.pin == "981" && pin.text == "•••", "Masked selection replacement")
            (pin.inputView as! CompactKeyboardView).onDone?()
            model.focus = .age
            try? await Task.sleep(for: .milliseconds(400))
            let age = field("Age")
            precondition(age.isFirstResponder && model.focus == .age)
            age.insertText("2a8")
            precondition(model.age == "28")
            (age.inputView as! CompactKeyboardView).onDone?()
            try? await Task.sleep(for: .milliseconds(400))
            precondition(!age.isFirstResponder && model.focus == nil, "Done must dismiss")
            renderKeyboards()
            try! "PASS: Native insertion, mid-string editing, deletion, immediate PIN masking, PIN replacement, numeric filtering, Manual field focus, Done dismissal, no Next button\n".write(to: documents.appendingPathComponent("result.txt"), atomically: true, encoding: .utf8)
            model.focus = .email
            try? await Task.sleep(for: .milliseconds(400))
            window?.windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeLeft))
            try? await Task.sleep(for: .seconds(1))
            let activeKeyboard = field("Email").inputView as! CompactKeyboardView
            let size = window!.bounds.size
            precondition(size.width > size.height, "Landscape rotation")
            precondition(field("Email").isFirstResponder, "Rotation preserves focus")
            let diagnostic = "HEIGHT actual \(activeKeyboard.bounds.height), preferred \(activeKeyboard.intrinsicContentSize.height), window \(size), keyboardAttached \(activeKeyboard.window != nil)\n"
            FileHandle.standardError.write(Data(diagnostic.utf8))
            precondition(abs(activeKeyboard.bounds.height - activeKeyboard.intrinsicContentSize.height) < 2, "Keyboard must honor compact height")
            window?.windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            try? await Task.sleep(for: .seconds(1))
            precondition(window!.bounds.width < window!.bounds.height, "Return to portrait")
            precondition(field("Email").isFirstResponder, "Return rotation preserves focus")
            precondition(abs(activeKeyboard.bounds.height - activeKeyboard.intrinsicContentSize.height) < 2, "Portrait keyboard height")
            try! "PASS: portrait editing, Done, rotation in both directions, focus preservation; portrait keyboard height \(activeKeyboard.bounds.height)\n".write(to: documents.appendingPathComponent("rotation.txt"), atomically: true, encoding: .utf8)
            await runProfileRegression()
            await runScrollRegression()
            exit(0)
        }
    }
    func runProfileRegression() async {
        for orientation: UIInterfaceOrientationMask in [.portrait, .landscapeLeft] {
            window?.windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: orientation))
            window?.rootViewController = UIHostingController(rootView: ProfileRegressionForm())
            try? await Task.sleep(for: .seconds(1))
            for (title, keys) in [
                (PhysicalAttributesScreenStrings.Form.emailLabel, ["a", "b", "@", "c", ".com"]),
                (PhysicalAttributesScreenStrings.Form.pinLabel, ["0", "1", "2", "3"]),
                (PhysicalAttributesScreenStrings.Form.weightLabel, ["1", "8", "0"]),
                (PhysicalAttributesScreenStrings.Form.ageLabel, ["2", "8"])
            ] {
                let input = field(title)
                if #available(iOS 26.0, *) {
                    precondition(!input.allowsNumberPadPopover, "Custom keyboard must disable the system number-pad popover")
                }
                input.becomeFirstResponder()
                try? await Task.sleep(for: .milliseconds(300))
                let keyboard = input.inputView as! CompactKeyboardView
                for value in keys {
                    let button = descendants(keyboard).compactMap { $0 as? UIButton }.first { $0.accessibilityIdentifier == "compact-key-\(value)" }!
                    button.sendActions(for: .touchUpInside)
                    // Allow all profile validation and SwiftUI updates to complete between keys.
                    try? await Task.sleep(for: .milliseconds(250))
                    precondition(input.isFirstResponder && keyboard.window != nil, "Profile keyboard closed after typing in \(title)")
                }
                let scroll = descendants(window!).compactMap { $0 as? UIScrollView }.first!
                let nextInput: UITextField? = title == PhysicalAttributesScreenStrings.Form.emailLabel
                    ? field(PhysicalAttributesScreenStrings.Form.pinLabel)
                    : title == PhysicalAttributesScreenStrings.Form.pinLabel
                        ? field(PhysicalAttributesScreenStrings.Form.weightLabel) : nil
                // Let the opening keyboard finish its layout before measuring handoff.
                try? await Task.sleep(for: .milliseconds(500))
                let offsetBeforeHandoff = scroll.contentOffset.y
                let visibleRect = scroll.bounds.inset(by: scroll.adjustedContentInset)
                let nextFieldAlreadyVisible = nextInput.map { visibleRect.contains($0.convert($0.bounds, to: scroll)) } ?? false
                let hidesBeforeDone = keyboardHideCount
                let keyboardWindow = keyboard.window
                let keyboardSuperview = keyboard.superview
                let keyboardFrame = keyboard.convert(keyboard.bounds, to: keyboardWindow)
                if let nextInput {
                    precondition(nextInput.inputView === keyboard, "The form must reuse one keyboard across fields")
                }
                keyboard.onDone?()
                if nextInput != nil {
                    for _ in 0..<42 {
                        try? await Task.sleep(for: .milliseconds(17))
                        precondition(keyboard.window === keyboardWindow && keyboard.superview === keyboardSuperview, "Keyboard must stay attached throughout handoff")
                        let frame = keyboard.convert(keyboard.bounds, to: keyboardWindow)
                        precondition(abs(frame.minY - keyboardFrame.minY) < 2 && abs(frame.height - keyboardFrame.height) < 2, "Keyboard must stay stationary throughout handoff")
                    }
                    precondition(keyboard.textField === nextInput, "Shared keyboard must route input to the newly focused field")
                } else {
                    try? await Task.sleep(for: .milliseconds(700))
                }
                precondition(!input.isFirstResponder, "Done leaves the current field")
                let nextTitle: String?
                switch title {
                case PhysicalAttributesScreenStrings.Form.emailLabel:
                    nextTitle = PhysicalAttributesScreenStrings.Form.pinLabel
                case PhysicalAttributesScreenStrings.Form.pinLabel:
                    nextTitle = PhysicalAttributesScreenStrings.Form.weightLabel
                default:
                    nextTitle = nil
                }
                if let nextTitle {
                    precondition(field(nextTitle).isFirstResponder, "Done must advance from \(title) to \(nextTitle)")
                    precondition(keyboardHideCount == hidesBeforeDone, "Done must keep the keyboard open between fields")
                    if nextFieldAlreadyVisible {
                        precondition(abs(scroll.contentOffset.y - offsetBeforeHandoff) < 2, "An already-visible field must not cause the form to jump")
                    }
                    // Hardware Return must follow the same route as the custom Done key.
                    input.becomeFirstResponder()
                    try? await Task.sleep(for: .milliseconds(250))
                    precondition(keyboardHideCount == hidesBeforeDone, "Direct field selection must keep the keyboard open")
                    _ = input.delegate?.textFieldShouldReturn?(input)
                    try? await Task.sleep(for: .milliseconds(250))
                    precondition(field(nextTitle).isFirstResponder, "Return must advance from \(title) to \(nextTitle)")
                    precondition(keyboardHideCount == hidesBeforeDone, "Return must keep the keyboard open between fields")
                }
            }
        }
        try! "PASS: one shared keyboard stays attached and stationary during Email/PIN/Weight handoff; typing targets the current field; Done/Return and direct selection preserve focus in both orientations\n".write(to: documents.appendingPathComponent("profile.txt"), atomically: true, encoding: .utf8)
    }

    func runScrollRegression() async {
        for orientation: UIInterfaceOrientationMask in [.portrait, .landscapeLeft] {
            window?.windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: orientation))
            window?.rootViewController = UIHostingController(rootView: ProfileRegressionForm(testsScrolling: true))
            try? await Task.sleep(for: .seconds(1))
            let scroll = descendants(window!).compactMap { $0 as? UIScrollView }.first!
            for baseline: CGFloat in [0, 120] {
                scroll.setContentOffset(CGPoint(x: 0, y: baseline - scroll.adjustedContentInset.top), animated: false)
                try? await Task.sleep(for: .milliseconds(300))
                let originalOffset = scroll.contentOffset.y + scroll.adjustedContentInset.top
                let age = field(PhysicalAttributesScreenStrings.Form.ageLabel)
                age.becomeFirstResponder()
                try? await Task.sleep(for: .seconds(1))
                let visibleRect = scroll.bounds.inset(by: scroll.adjustedContentInset)
                let ageRect = age.convert(age.bounds, to: scroll)
                precondition(visibleRect.insetBy(dx: -1, dy: -1).contains(ageRect), "Age must be visible above the keyboard: \(ageRect) in \(visibleRect)")
                if baseline == 0 {
                    (age.inputView as! CompactKeyboardView).onDone?()
                } else {
                    // The background-tap dismissal path also resigns first responder.
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                try? await Task.sleep(for: .seconds(1))
                let restoredOffset = scroll.contentOffset.y + scroll.adjustedContentInset.top
                precondition(abs(restoredOffset - originalOffset) < 2, "Keyboard dismissal must restore the original offset: \(originalOffset) -> \(restoredOffset)")
            }
        }
        try! "PASS: Age scrolls into view and Done/background dismissal restore both top and manually scrolled positions in portrait and landscape\n".write(to: documents.appendingPathComponent("scroll.txt"), atomically: true, encoding: .utf8)
    }

    func renderKeyboards() {
        for (name, size) in [("portrait", CGSize(width: 834, height: 1194)), ("landscape", CGSize(width: 1194, height: 834))] {
            let renderWindow = UIWindow(frame: CGRect(origin: .zero, size: size))
            let controller = UIViewController()
            renderWindow.rootViewController = controller
            let target = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
            renderWindow.addSubview(target)
            renderWindow.bounds = CGRect(origin: .zero, size: size)
            for kind: KioskKeyboardKind in [.email, .integer] {
                let keyboard = CompactKeyboardView(kind: kind, fieldTitle: kind == .email ? "Email" : "Age")
                keyboard.textField = target
                keyboard.frame = CGRect(x: 0, y: 0, width: size.width, height: keyboard.intrinsicContentSize.height)
                keyboard.layoutIfNeeded()
                precondition(keyboard.bounds.height == (name == "landscape" ? 260 : 308) + renderWindow.safeAreaInsets.bottom, "Compact layout size")
                let renderer = UIGraphicsImageRenderer(size: keyboard.bounds.size)
                let image = renderer.image { ctx in keyboard.layer.render(in: ctx.cgContext) }
                let file = "\(name)-\(kind == .email ? "email" : "numeric").png"
                try! image.pngData()!.write(to: documents.appendingPathComponent(file))
            }
        }
    }
}
