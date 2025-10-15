import SwiftUI

struct ProfileAgeSection: View {
    @State private var showAlert = false
    @Binding var selectedAge: Int?
    @State private var showPicker: Bool = false
    @State private var localAge: Int? = nil   // 🔹 optional local state

    var body: some View {
        VStack(alignment: .leading) {
            Text("Age (years)")
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(.black)

            HStack {
                Button {
                    // Only preload if binding has a valid value
                    if let age = selectedAge, age > 0 {
                        localAge = age
                    }
                    showPicker = true
                } label: {
                    HStack {
                        if let age = localAge, age > 0 {
                            Text("\(age) years")
                                .foregroundColor(.black)
                        } else {
                            Text("Select age")
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.black, lineWidth: 1)
                    )
                }
                .popover(isPresented: $showPicker) {
                    VStack {
                        Text("Select Age")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                            .padding(.top, 12)
                            .padding(.horizontal, 32)

                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(13...120, id: \.self) { age in
                                    Text("\(age) years")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.top, 4)
                                        .padding(.bottom, 4)
                                        .background(localAge == age ? Color.gray.opacity(0.2) : Color.clear)
                                        .cornerRadius(8)
                                        .onTapGesture {
                                            localAge = age
                                            selectedAge = age
                                            showPicker = false
                                            HapticFeedback.light()
                                        }
                                }
                            }
                            .padding()
                        }
                    }
                    .presentationDetents([.fraction(0.45)])
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}
