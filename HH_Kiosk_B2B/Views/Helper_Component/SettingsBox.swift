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
                Picker("External camera preset", selection: $selectedPreset) {
                    ForEach(presets, id: \.self) { preset in
                        Text(preset.label) // see extension below
                    }
                }

                // Orientation Picker
                Picker("Preview orientation", selection: $selectedOrientation) {
                    ForEach(orientations, id: \.self) { orientation in
                        Text(orientation.label)
                    }
                }

                // Toggle Options
                Toggle("Mirror external camera video", isOn: $mirrorVideo)
                Toggle("Use external camera only", isOn: $useExternalCameraOnly)
                    .padding(.vertical, 4)

                Text("If enabled, only the external camera will be used. If disabled, the app will automatically switch between the built-in camera and an external camera (external camera is prioritized).")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .navigationTitle("Camera Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
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
        @unknown default: return "Unknown"
        }
    }
}

extension AnuraCore.PreviewOrientation {
    var label: String {
        switch self {
        case .portrait: return "Portrait"
        case .landscapeLeft: return "LandscapeLeft"
        case .landscapeRight: return "LandscapeRight"
        case .portraitUpsideDown: return "PortraitUpsideDown"
        @unknown default: return "Unknown"
        }
    }
}
