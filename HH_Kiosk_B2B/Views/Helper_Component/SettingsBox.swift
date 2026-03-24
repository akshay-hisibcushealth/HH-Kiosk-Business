import SwiftUI
import AnuraCore

struct SettingsView: View {
    @Binding var showSettings: Bool
    @Binding var selectedPreset: AnuraCore.CameraPreset
    @Binding var selectedOrientation: AnuraCore.PreviewOrientation
    @Binding var mirrorVideo: Bool
    @Binding var useExternalCameraOnly: Bool

    let presets: [AnuraCore.CameraPreset] = [.hd1280x720, .hd1920x1080, .hd2K2560x1440, .hd4K3840x2160]
    let orientations: [AnuraCore.PreviewOrientation] = [.portrait, .landscapeLeft, .landscapeRight, .portraitUpsideDown]

    var body: some View {
        NavigationView {
            Form {
                // Camera Preset Picker
                Picker(PhysicalAttributesScreenStrings.Settings.cameraPreset, selection: $selectedPreset) {
                    ForEach(presets, id: \.self) { preset in
                        Text(preset.label) // see extension below
                    }
                }

                // Orientation Picker
                Picker(PhysicalAttributesScreenStrings.Settings.previewOrientation, selection: $selectedOrientation) {
                    ForEach(orientations, id: \.self) { orientation in
                        Text(orientation.label)
                    }
                }

                // Toggle Options
                Toggle(PhysicalAttributesScreenStrings.Settings.mirrorExternalVideo, isOn: $mirrorVideo)
                Toggle(PhysicalAttributesScreenStrings.Settings.useExternalCameraOnly, isOn: $useExternalCameraOnly)
                    .padding(.vertical, 4)

                Text(PhysicalAttributesScreenStrings.Settings.externalCameraDescription)
                    .font(.caption2)
                    .foregroundColor(Color(AppColors.gray))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .navigationTitle(PhysicalAttributesScreenStrings.Settings.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(PhysicalAttributesScreenStrings.Settings.closeButton) {
                        showSettings = false
                    }
                }
            }
        }
    }
}


extension AnuraCore.CameraPreset {
    var label: String {
        switch self {
        case .hd1280x720: return "HD1280x720"
        case .hd1920x1080: return "HD1920x1080"
        case .hd2K2560x1440: return "HD2K2560x1440"
        case .hd4K3840x2160: return "HD4K3840x2160"
        @unknown default: return PhysicalAttributesScreenStrings.Settings.unknownOption
        }
    }
}

extension AnuraCore.PreviewOrientation {
    var label: String {
        switch self {
        case .portrait: return PhysicalAttributesScreenStrings.Settings.portrait
        case .landscapeLeft: return PhysicalAttributesScreenStrings.Settings.landscapeLeft
        case .landscapeRight: return PhysicalAttributesScreenStrings.Settings.landscapeRight
        case .portraitUpsideDown: return PhysicalAttributesScreenStrings.Settings.portraitUpsideDown
        @unknown default: return PhysicalAttributesScreenStrings.Settings.unknownOption
        }
    }
}
