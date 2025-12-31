import SwiftUI

struct ProfileHeightSection: View {
    @Binding var selectedHeight: Int?

    // COMMITTED (shown in text field)
    @State private var committedFeet: Int? = nil
    @State private var committedInches: Int? = nil

    // TEMP (used inside picker only)
    @State private var tempFeet: Int = 5
    @State private var tempInches: Int = 6

    @State private var showPicker: Bool = false

    let feetRange = Array(4...7)
    let inchRange = Array(0...11)

    var body: some View {
        VStack(alignment: .leading) {
            Text("Height (ft/in)")
                .font(.body)
                .fontWeight(.bold)

            Button {
                // Initialize temp values when opening picker
                if let feet = committedFeet, let inches = committedInches {
                    tempFeet = feet
                    tempInches = inches
                } else if let cm = selectedHeight {
                    let totalInches = Int(round(Double(cm) / 2.54))
                    tempFeet = totalInches / 12
                    tempInches = totalInches % 12
                } else {
                    tempFeet = 5
                    tempInches = 6
                }

                showPicker = true
            } label: {
                HStack {
                    if let feet = committedFeet, let inches = committedInches {
                        Text("\(feet) ft \(inches) in")
                            .foregroundColor(.black)
                    } else {
                        Text("Select height")
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(.vertical, 20.h)
                .padding(.horizontal, 16.w)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12.r)
                        .stroke(Color.black, lineWidth: 1)
                )
            }
            .popover(isPresented: $showPicker) {
                VStack {
                    Text("Select Height")
                        .font(.headline)
                        .padding(.top, 12)

                    HStack(spacing: 16) {
                        WheelSelector(
                            items: feetRange,
                            selection: $tempFeet,
                            label: "ft"
                        )

                        WheelSelector(
                            items: inchRange,
                            selection: $tempInches,
                            label: "in"
                        )
                    }

                    Button("Done") {
                        // ✅ COMMIT ONLY HERE
                        committedFeet = tempFeet
                        committedInches = tempInches

                        let totalInches = tempFeet * 12 + tempInches
                        selectedHeight = Int(Double(totalInches) * 2.54)

                        showPicker = false
                        UIDevice.current.playInputClick()
                    }
                    .padding(.bottom, 12)
                }
                .frame(width: 320.w, height: 300.h)
            }
        }
    }
}


struct WheelSelector<T: Hashable & CustomStringConvertible>: View {
    let items: [T]
    @Binding var selection: T
    let label: String

    var body: some View {
        VStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)

            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 10) {
                        ForEach(items, id: \.self) { item in
                            Text(item.description)
                                .font(selection == item ? .headline : .body)
                                .frame(maxWidth: .infinity)
                                .frame(height: 40.h)
                                .background(selection == item ? Color.gray.opacity(0.2) : Color.clear)
                                .cornerRadius(8.r)
                                .id(item) // important: solid id for scrollTo
                                .onTapGesture {
                                    withAnimation {
                                        selection = item
                                    }
                                    // ensure we scroll to the tapped item (after state update/layout)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) {
                                        withAnimation {
                                            proxy.scrollTo(item, anchor: .center)
                                        }
                                    }
                                }
                        }
                    }
                    .padding(.vertical, 8)
                    .onAppear {
                        // scroll once after the view has appeared and laid out
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) {
                            proxy.scrollTo(selection, anchor: .center)
                        }
                    }
                    .onChange(of: selection) { _,newVal in
                        // when selection changes (only for this wheel), scroll to it
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                            withAnimation {
                                proxy.scrollTo(newVal, anchor: .center)
                            }
                        }
                    }
                }
                .frame(height: 160.h)
            }
            .frame(width: 100.w)
        }
    }
}
