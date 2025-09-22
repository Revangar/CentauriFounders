import Foundation

actor InputStateActor {
    private var state = InputState()

    func update(_ transform: (inout InputState) -> Void) {
        transform(&state)
    }

    func snapshot() -> InputState {
        state
    }
}
