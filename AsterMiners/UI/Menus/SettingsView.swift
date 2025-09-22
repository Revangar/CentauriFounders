import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: MainMenuViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                Toggle(isOn: $viewModel.autoAim) {
                    Text(LocalizedStringKey("auto_aim"))
                }
                Slider(value: $viewModel.joystickScale, in: 0.5...1.5, step: 0.1) {
                    Text(LocalizedStringKey("joystick_scale"))
                }
                Picker(selection: $viewModel.graphicsQuality, label: Text(LocalizedStringKey("quality"))) {
                    Text(LocalizedStringKey("quality_low")).tag(0)
                    Text(LocalizedStringKey("quality_medium")).tag(1)
                    Text(LocalizedStringKey("quality_high")).tag(2)
                }
                Button(LocalizedStringKey("reset_progress")) {
                    viewModel.resetProgress()
                }
            }
            .navigationTitle(LocalizedStringKey("settings"))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(LocalizedStringKey("done")) {
                        viewModel.persistOptions()
                        dismiss()
                    }
                }
            }
        }
    }
}
