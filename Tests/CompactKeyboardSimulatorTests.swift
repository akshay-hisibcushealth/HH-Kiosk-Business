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
    @State private var focus: PhysicalAttributesInputField?
    @State private var email: String?
    @State private var pin = ""
    @State private var age: Int?
    @State private var weight: Int?
    @State private var pounds: Int?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ProfileEmailSection(email: $email, focusedField: $focus)
                ProfilePINSection(pin: $pin, focusedField: $focus)
                ProfileWeightSection(selectedWeight: $weight, selectedWeightInPounds: $pounds, focusedField: $focus)
                ProfileAgeSection(selectedAge: $age, focusedField: $focus)
            }.padding(30)
        }
    }
}

@main final class PreviewDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let model = TestModel()
    let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        try? FileManager.default.removeItem(at: documents.appendingPathComponent("rotation.txt"))
        try? FileManager.default.removeItem(at: documents.appendingPathComponent("profile.txt"))
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
                keyboard.onDone?()
                try? await Task.sleep(for: .milliseconds(250))
                precondition(!input.isFirstResponder, "Done still dismisses profile keyboard")
            }
        }
        try! "PASS: repeated key presses in all four actual profile sections preserve keyboard in portrait and landscape; Done dismisses\n".write(to: documents.appendingPathComponent("profile.txt"), atomically: true, encoding: .utf8)
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
