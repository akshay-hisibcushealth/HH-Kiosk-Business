import SwiftUI

struct ProfileHeightSection: View {
    @Binding var selectedHeight: Int?
    @State private var selectedFeet: Int? = nil
    @State private var selectedInches: Int? = nil
    @State private var showPicker: Bool = false

    let feetRange = Array(4...7)
    let inchRange = Array(0...11)

    var body: some View {
        VStack(alignment: .leading) {
            Text("Height (ft/in)")
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(.black)

            Button {
                // ensure defaults are set when opening picker
                if selectedFeet == nil || selectedInches == nil {
                    if let cm = selectedHeight {
                        let totalInches = Int(round(Double(cm) / 2.54))
                        selectedFeet = totalInches / 12
                        selectedInches = totalInches % 12
                    } else {
                        selectedFeet = feetRange.first
                        selectedInches = inchRange.first
                    }
                }
                showPicker = true
            } label: {
                HStack {
                    if let feet = selectedFeet, let inches = selectedInches {
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
                .frame(maxWidth: .infinity)
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
                        .padding(.top, 12.h)

                    HStack(spacing: 16) {
                        WheelSelector(items: feetRange,
                                      selection: Binding(get: { selectedFeet ?? feetRange.first! },
                                                         set: { selectedFeet = $0 }),
                                      label: "")

                        WheelSelector(items: inchRange,
                                      selection: Binding(get: { selectedInches ?? inchRange.first! },
                                                         set: { selectedInches = $0 }),
                                      label: "")
                    }
                    .padding(.horizontal, 12.w)

                    Button("Done") {
                        // Apply defaults if user didn't pick
                        let feet = selectedFeet ?? feetRange.first!
                        let inches = selectedInches ?? inchRange.first!

                        let totalInches = feet * 12 + inches
                        selectedHeight = Int(Double(totalInches) * 2.54)

                        // Also update state so the button shows correctly afterwards
                        selectedFeet = feet
                        selectedInches = inches

                        showPicker = false
                        // replace with your haptic util if available
                        // HapticFeedback.light()
                        UIDevice.current.playInputClick()
                    }
                    .padding(.bottom, 12.h)
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
