
import SwiftUI

struct ProfileGenderSection: View {
    @Binding var selectedGender: String
    @State private var showPicker: Bool = false
    @State private var localGender: String? = nil   // 🔹 optional local state

    var body: some View {
        VStack(alignment: .leading) {
            Text("Gender (at birth)")
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(Color(AppColors.black))

            HStack {
                Button {
                    // preload if already set
                    if !selectedGender.isEmpty {
                        localGender = selectedGender
                    }
                    showPicker = true
                } label: {
                    HStack {
                        if let gender = localGender, !gender.isEmpty {
                            Text(gender)
                                .foregroundColor(Color(AppColors.black))
                        } else {
                            Text("Select Gender")
                                .foregroundColor(Color(AppColors.gray))
                        }
                        Spacer()
                    }
                    .padding(.vertical, 20.h)
                    .padding(.horizontal, 16.w)
                    .frame(maxWidth: .infinity)
                    .background(Color(AppColors.white))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12.r)
                            .stroke(Color(AppColors.black), lineWidth: 1)
                    )
                }
                .popover(isPresented: $showPicker) {
                    VStack {
                        Text("Select Gender")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(Color(AppColors.black))
                            .padding(.top, 12.h)
                            .padding(.horizontal, 32.w)

                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(["Male", "Female"], id: \.self) { gender in
                                    Text(gender)
                                        .font(.body)
                                        .foregroundColor(Color(AppColors.textPrimary))
                                        .frame(maxWidth: .infinity)
                                        .padding(.top, 4.h)
                                        .padding(.bottom, 4.h)
                                        .background(localGender == gender ? Color(AppColors.gray).opacity(0.2) : Color(AppColors.clear))
                                        .cornerRadius(8.r)
                                        .onTapGesture {
                                            localGender = gender
                                            selectedGender = gender
                                            showPicker = false
                                            HapticFeedback.light()
                                        }
                                }
                            }
                            .padding()
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}
