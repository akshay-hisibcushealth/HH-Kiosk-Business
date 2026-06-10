
import SwiftUI

struct ProfileGenderSection: View {
    @Binding var selectedGender: String
    @State private var showPicker: Bool = false
    @State private var localGender: String? = nil   // 🔹 optional local state

    var body: some View {
        VStack(alignment: .leading) {
            Text(PhysicalAttributesScreenStrings.Form.genderLabel)
                .font(.system(size: 24.sp, weight: .bold))
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
                            Text(PhysicalAttributesScreenStrings.Form.genderPlaceholder)
                                .foregroundColor(Color(AppColors.physicalAttributeFieldPlaceholder))
                        }
                        Spacer()
                    }
                    .font(.system(size: 28.sp, weight: .regular))
                    .padding(.vertical, 26.h)
                    .padding(.horizontal, 28.w)
                    .frame(maxWidth: .infinity, minHeight: 94.h)
                    .background(
                        localGender == nil
                            ? Color(AppColors.physicalAttributeFieldBackground)
                            : Color(AppColors.white)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12.r, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12.r)
                            .stroke(Color(AppColors.physicalAttributeFieldBorder), lineWidth: 1.5)
                    )
                }
                .popover(isPresented: $showPicker) {
                    VStack {
                        Text(PhysicalAttributesScreenStrings.Form.genderPlaceholder)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(Color(AppColors.black))
                            .padding(.top, 12.h)
                            .padding(.horizontal, 32.w)

                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(PhysicalAttributesScreenStrings.Form.genderOptions, id: \.self) { gender in
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
        .onAppear {
            syncLocalGender()
        }
        .onChange(of: selectedGender) { _, _ in
            syncLocalGender()
        }
    }
    
    private func syncLocalGender() {
        localGender = selectedGender.isEmpty ? nil : selectedGender
    }
}
