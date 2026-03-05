import SwiftUI
import Foundation
import AnuraCore

struct EmailResultPopup: View {
    let results: [String: MeasurementResults.SignalResult]
    @Environment(\.dismiss) var dismiss
    @State private var email: String = ""
    @State private var pin: String = ""
    @State private var isLoading: Bool = false
    @State private var isEmailSent: Bool = false
    @FocusState private var isPinFocused: Bool
    @State private var showEmailError: Bool = false
    
    
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
        VStack(spacing: 16.h) {
            if isLoading {
                loadingView
            } else if isEmailSent {
                emailSentView
            } else {
                emailFormView
            }
        }
        .padding(.horizontal, 20.h)
        .background(Color.white)
        .cornerRadius(16.r)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
        
    }
    
    
    
    @ViewBuilder
    private var loadingView: some View {
        Spacer()
        HStack {
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color(AppColors.gray)))
                .scaleEffect(2)
            Spacer()
        }
        Spacer()
    }
    
    @ViewBuilder
    private var emailSentView: some View {
        Spacer()
        Image("email_sent")
            .resizable()
            .scaledToFit()
            .padding(.top)
            .frame(width: 160.w, height: 160.w)
        
        Text("Check your inbox!")
            .font(.system(size: 28.sp))
            .bold()
            .padding(.bottom, 12.h)
        
        Text("Your result has been sent to your email!\nTell a colleague about our Kiosk!")
            .multilineTextAlignment(.center)
            .font(.system(size: 24.sp))
            .padding(.bottom, 12)
        
        Button(action: {
            navigateToHome()
            dismiss()
        }) {
            Text("Return to Home Screen")
                .foregroundColor(Color(AppColors.black))
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(AppColors.ctaGreen))
                .cornerRadius(10)
        }
        .padding(.horizontal)
        
        Spacer()

    }
    
    @ViewBuilder
    private var emailFormView: some View {
        HStack{
            Image("email_lock")
                .resizable()
                .scaledToFit()
                .frame(width: 70.w, height: 70.h)
            
            buildSemiBoldText("Send result to your mail",32.sp)
            Button(action: { dismiss() }) {
                if !isEmailSent {
                    Image(systemName: "xmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30.w, height: 20.h)
                        .foregroundColor(Color(AppColors.gray))
                    
                }
            }
            .padding(.leading,80.w)
        }
        .padding(.top,32.w)
        Spacer()
        // Email field
        VStack(alignment: .leading) {
            Text("Email address")
                .font(.system(size: 24.sp))
                .padding(.horizontal)
                .foregroundColor(Color(AppColors.black))
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding(.vertical, 24.h)
                .padding(.horizontal)
                .background(RoundedRectangle(cornerRadius: 10.r).stroke(Color(AppColors.gray).opacity(0.3)))
                .padding(.horizontal)
        }
        
        
        // PIN field
        VStack(alignment: .leading) {
            Text("Create a 4-digit secret key")
                .font(.system(size: 24.sp))
                .padding(.horizontal)
                .foregroundColor(Color(AppColors.black))
            
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
                    .foregroundColor(Color(AppColors.clear))
                
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color(AppColors.gray).opacity(0.3)))
                    .onChange(of: pin) { _,newValue in
                        pin = String(newValue.prefix(4).filter { $0.isNumber })
                    }
                
            }
            .font(.custom("NewSpirit-SemiBold", size: 30.sp))
            // ========================================================================
            .padding(.horizontal)
            
            Text("This will be used to view your result ")
                .font(.system(size: 22.sp))
                .italic()
                .padding(.horizontal)
                .foregroundColor(Color(AppColors.gray))
        }
        
        
        // Send button
        Button(action: {
            Task {
                isLoading = true
                let success = await sendResultsToEmail(to: email, pin: pin)
                isLoading = false
                if success {
                    isEmailSent = true
                } else {
                    // Trigger failure message
                    showEmailError = true
                }
            }
        }) {
            HStack {
                Image(systemName: "envelope.fill")
                    .resizable()
                    .frame(width: 24.w,height: 24.w)
                    .foregroundColor(Color(AppColors.black))
                Text("Send mail")
                    .font(.system(size: 26.sp))
                    .foregroundColor(Color(AppColors.black))
                    .fontWeight(.bold)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background((isEmailValid && isPinValid) ? Color(AppColors.ctaGreen) : Color(AppColors.ctaGreen).opacity(0.5))
            .cornerRadius(10.r)
        }
        .disabled(!(isEmailValid && isPinValid))
        .padding(.horizontal)
        
        // ✅ Show message depending on success/failure
        if showEmailError {
            HStack(spacing: 8.w) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(Color(AppColors.error))
                Text("Failed to send email. Please try again.")
                    .foregroundColor(Color(AppColors.error))
                    .font(.body)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 8.h)
        } else {
            HStack(spacing: 8.w) {
                Image(systemName: "lock.shield")
                    .resizable()
                    .frame(width: 28.w, height: 28.w)
                    .foregroundColor(Color(AppColors.blue))
                Text("Secure and Private")
                    .foregroundColor(Color(AppColors.blue))
                    .font(.system(size: 20.sp))
            }
            .padding(.bottom,24.h)
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

