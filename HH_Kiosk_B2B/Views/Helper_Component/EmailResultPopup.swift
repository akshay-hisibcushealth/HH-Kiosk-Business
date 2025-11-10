import SwiftUI
import Foundation
import AnuraCore

struct EmailResultPopup: View {
    @StateObject private var appState = AppState()
    let results: [String: MeasurementResults.SignalResult]
    @Environment(\.dismiss) var dismiss
    @State private var email: String = ""
    @State private var pin: String = ""
    @State private var isLoading: Bool = false
    @State private var isEmailSent: Bool = false
    @FocusState private var isPinFocused: Bool  

    // Email validation
    private var isEmailValid: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return predicate.evaluate(with: email)
    }

    // Pin validation
    private var isPinValid: Bool {
        let pinRegex = #"^\d{4}$"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", pinRegex)
        return predicate.evaluate(with: pin)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            closeButton
                .padding(.top, 16.h)
                .padding(.trailing, 16.w)

            VStack(spacing: 16.h) {
                if isLoading {
                    loadingView
                } else if isEmailSent {
                    emailSentView
                } else {
                    emailFormView
                }
            }
            .padding(.top, 20.h)
        }
    }

    @ViewBuilder
    private var closeButton: some View {
        Button(action: { dismiss() }) {
            if !isEmailSent {
                HStack {
                    Spacer()
                    Image(systemName: "xmark")
                        .padding(.trailing, 32.w)
                        .foregroundColor(.black)
                }
            }
        }
    }

    @ViewBuilder
    private var loadingView: some View {
        Spacer()
        HStack {
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                .scaleEffect(2)
            Spacer()
        }
        Spacer()
    }

    @ViewBuilder
    private var emailSentView: some View {
        Image("email_sent")
            .resizable()
            .scaledToFit()
            .padding(.top)
            .frame(width: 120.w, height: 120.w)

        Text("Check your inbox!")
            .font(.title)
            .bold()
            .padding(.bottom, 24)

        Text("Your result has been sent to your email!\nTell a colleague about our Kiosk!")
            .font(.headline)
            .multilineTextAlignment(.center)
            .padding(.bottom, 12)

        Button(action: {
            navigateToHome(appState: appState)
            dismiss()
        }) {
            Text("Return to Home Screen")
                .foregroundColor(.black)
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(hex: "#B8EB5E"))
                .cornerRadius(10)
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private var emailFormView: some View {
        Image("email_lock")
            .resizable()
            .scaledToFit()
            .padding(.top)
            .frame(width: 50.w, height: 60.h)

        Text("Send result to your mail")
            .font(.headline)
            .bold()
            .padding(.bottom, 12)

        // Email field
        VStack(alignment: .leading) {
            Text("Email address")
                .font(.headline)
                .padding(.horizontal)
                .foregroundColor(.black)
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding(.vertical, 24.h)
                .padding(.horizontal)
                .background(RoundedRectangle(cornerRadius: 10.r).stroke(Color.gray.opacity(0.3)))
                .padding(.horizontal)
        }
        

        // PIN field
                    VStack(alignment: .leading) {
                        Text("Create a 4-digit secret key")
                            .font(.headline)
                            .padding(.horizontal)
                            .foregroundColor(.black)

                        ZStack(alignment: .leading) {
                            // Background display of asterisks
                            HStack(spacing: 1.w) { // Set spacing to 0 if not already minimal
                                ForEach(0..<pin.count, id: \.self) { _ in
                                    Text("*")
                                        .font(.system(size: 24.sp,weight: .bold))
                                        .padding(.top,8.h)
                                        .padding(.trailing,4.h)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)

                            // The actual input field
                            TextField("* * * *", text: $pin)
                                .keyboardType(.numberPad)
                                .foregroundColor(.clear)
                                
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3)))
                                .onChange(of: pin) { _,newValue in
                                    pin = String(newValue.prefix(4).filter { $0.isNumber })
                                }

                        }
                        .font(.custom("NewSpirit-SemiBold", size: 28.sp))
                        // ========================================================================
                        .padding(.horizontal)

                        Text("This will be used to view your result ")
                            .font(.caption)
                            .italic()
                            .padding(.horizontal)
                            .foregroundColor(.blue)
                    }
        

        // Send button
        Button(action: {
            Task {
                 isLoading = true
                let success = await sendResultsToEmail(to: email,pin: pin)
                 isLoading = false
                 if success {
                     isEmailSent = true
                 } else {
                     // Optionally show error UI (if you decide to handle fail later)
                 }
             }
        }) {
            HStack {
                Image(systemName: "envelope.fill")
                    .foregroundColor(.black)
                Text("Send mail")
                    .foregroundColor(.black)
                    .fontWeight(.bold)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background((isEmailValid && isPinValid) ? Color(hex: "#B8EB5E") : Color(hex: "#B8EB5E").opacity(0.5))
            .cornerRadius(10.r)
        }
        .disabled(!(isEmailValid && isPinValid))
        .padding(.horizontal)

        HStack(spacing: 8.w) {
            Image(systemName: "lock.shield")
                .foregroundColor(.blue)
            Text("Secure and Private")
                .foregroundColor(.blue)
                .font(.footnote)
        }
    }

    // ... rest of your functions unchanged (sendResultsToEmail, createEmailResultJSON, etc.)
    func sendResultsToEmail(to email: String,pin:String) async -> Bool {
        // Build JSON payload string
        guard let jsonString = createEmailResultJSON(email: email,pin:pin, results: results) else {
            print("❌ Failed to create JSON payload")
            return false
        }

        guard let url = URL(string: "\(AppConfig.baseURL)/kiosk-email/") else {
            return false
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonString.data(using: .utf8)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                print("✅ Email request response code:", httpResponse.statusCode)
                if (200..<300).contains(httpResponse.statusCode) {
                    return true
                } else {
                    print("Result: \(results)")
                    print("URL: \(url)")
                    print("pin: \(pin)")
                    print("❌ Server error:", String(data: data, encoding: .utf8) ?? "")
                    return false
                }
            }
        } catch {
            print("❌ Network error:", error.localizedDescription)
            return false
        }

        return false
    }

    func createEmailResultJSON(email: String,pin:String, results: [String: MeasurementResults.SignalResult]) -> String? {
        var formattedData: [String: ResultEntry] = [:]

        for (key, result) in results {
            let entry = ResultEntry(value: result.value, notes: result.notes)
            formattedData[key] = entry
        }

        let payload = EmailResultPayload(email: email,pin:pin, data: formattedData)

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        if let jsonData = try? encoder.encode(payload) {
            return String(data: jsonData, encoding: .utf8)
        } else {
            return nil
        }
    }
}
