import SwiftUI

struct NexoCommands: Commands {
    @FocusedValue(\.addPageAction) private var addPageAction

    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("Nueva página") {
                addPageAction?()
            }
            .keyboardShortcut("n", modifiers: .command)
            .disabled(addPageAction == nil)
        }
    }
}
