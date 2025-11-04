import SwiftUI

struct ProfileWeightSection: View {
    @Binding var selectedWeight: Int?  // Stored in kg
    @State private var showPicker: Bool = false
    @State private var selectedPounds: Int? = nil   // 🔹 optional now

    var body: some View {
        VStack(alignment: .leading) {
            Text("Weight (lbs)")
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(.black)

            Button {
                // Only set if there's already a weight stored
                if let weight = selectedWeight,weight  > 0 {
                    selectedPounds = Int(Double(weight) * 2.20462)
                }
                showPicker = true
            } label: {
                HStack {
                    if let pounds = selectedPounds {
                        Text("\(pounds) lbs")
                            .foregroundColor(.black)
                    } else {
                        Text("Select weight")
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
                    Text("Select Weight")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                        .padding(.top, 12.h)
                        .padding(.horizontal, 32.h)

                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(75...400, id: \.self) { lbs in
                                Text("\(lbs) lbs")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 4.h)
                                    .padding(.bottom, 4.h)
                                    .background(selectedPounds == lbs ? Color.gray.opacity(0.2) : Color.clear)
                                    .cornerRadius(8.r)
                                    .onTapGesture {
                                        selectedPounds = lbs
                                        selectedWeight = Int(Double(lbs) / 2.20462)  // Convert lbs back to kg
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
