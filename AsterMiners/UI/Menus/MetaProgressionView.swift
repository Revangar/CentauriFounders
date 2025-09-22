import SwiftUI

struct MetaProgressionView: View {
    @State private var currency: Int = 0
    @State private var unlocks: [String] = []

    var body: some View {
        NavigationView {
            List {
                Section(header: Text(LocalizedStringKey("meta_currency"))) {
                    Text(String(format: NSLocalizedString("credits_format", comment: ""), currency))
                }
                Section(header: Text(LocalizedStringKey("meta_unlocks"))) {
                    ForEach(unlocks, id: \.self) { unlock in
                        Text(unlock)
                    }
                }
                Section(header: Text(LocalizedStringKey("blueprints"))) {
                    ForEach(blueprints(), id: \.self) { blueprint in
                        Text(blueprint)
                    }
                }
            }
            .navigationTitle(LocalizedStringKey("meta_unlocks"))
            .onAppear(perform: load)
        }
    }

    private func load() {
        if let save = try? SaveService.shared.load() {
            currency = save.unlocks.currency
            unlocks = Array(save.unlocks.unlockedClasses)
        }
    }

    private func blueprints() -> [String] {
        if let save = try? SaveService.shared.load() {
            return Array(save.unlocks.craftedBlueprints)
        }
        return []
    }
}
