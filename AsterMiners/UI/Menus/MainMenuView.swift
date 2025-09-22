import SwiftUI

struct MainMenuView: View {
    @ObservedObject var viewModel: MainMenuViewModel

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [.black, Color(red: 0.05, green: 0.08, blue: 0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                VStack(spacing: 24) {
                    Text(LocalizedStringKey("title_riftfall"))
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                        .padding(.top, 60)

                    Picker(selection: $viewModel.selectedClass, label: Text(LocalizedStringKey("class"))) {
                        Text(LocalizedStringKey("class_prospector")).tag("prospector")
                        Text(LocalizedStringKey("class_warden")).tag("warden")
                        Text(LocalizedStringKey("class_engineer")).tag("engineer")
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 48)

                    Stepper(value: $viewModel.difficulty, in: 1...5) {
                        Text(String(format: NSLocalizedString("difficulty_format", comment: ""), viewModel.difficulty))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 48)

                    Button(action: viewModel.startRun) {
                        Text(LocalizedStringKey("play"))
                            .font(.title2.bold())
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.cyan)
                    .padding(.horizontal, 48)

                    HStack(spacing: 20) {
                        Button(LocalizedStringKey("settings")) { viewModel.showSettings = true }
                        Button(LocalizedStringKey("meta_unlocks")) { viewModel.showMeta = true }
                        Button(action: viewModel.toggleLanguage) {
                            Text(viewModel.languageCode.uppercased())
                        }
                    }
                    .buttonStyle(.bordered)
                    .foregroundStyle(.white)

                    Spacer()
                }
            }
            .sheet(isPresented: $viewModel.showSettings) {
                SettingsView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showMeta) {
                MetaProgressionView()
            }
        }
        .navigationViewStyle(.stack)
    }
}
