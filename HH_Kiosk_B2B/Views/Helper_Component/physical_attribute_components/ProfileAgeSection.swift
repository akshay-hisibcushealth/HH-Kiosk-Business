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
                    .padding(.vertical, 20.h)
                    .padding(.horizontal, 16.w)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12.r)
                            .stroke(Color.black, lineWidth: 1)
                    )
                }
                .popover(isPresented: $showPicker) {
                    VStack {
                        Text("Select Age")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                            .padding(.top, 12.h)
                            .padding(.horizontal, 32.w)

                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(13...75, id: \.self) { age in
                                    Text("\(age) years")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.top, 4.h)
                                        .padding(.bottom, 4.h)
                                        .background(localAge == age ? Color.gray.opacity(0.2) : Color.clear)
                                        .cornerRadius(8.r)
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
                    .frame(height: 400.h)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}
