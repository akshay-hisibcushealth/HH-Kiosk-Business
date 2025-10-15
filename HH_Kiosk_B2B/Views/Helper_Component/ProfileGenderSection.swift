//
//  ProfileGenderSection.swift
//  AnuraSampleApp
//
//  Created by Applite Solutions on 04/06/25.
//

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
                .foregroundColor(.black)

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
                                .foregroundColor(.black)
                        } else {
                            Text("Select Gender")
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
                        Text("Select Gender")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                            .padding(.top, 12)
                            .padding(.horizontal, 32)

                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(["Male", "Female"], id: \.self) { gender in
                                    Text(gender)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.top, 4)
                                        .padding(.bottom, 4)
                                        .background(localGender == gender ? Color.gray.opacity(0.2) : Color.clear)
                                        .cornerRadius(8)
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
                    .presentationDetents([.fraction(0.3)])
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}
