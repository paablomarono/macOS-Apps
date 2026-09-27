import SwiftUI

private struct AddPageActionKey: FocusedValueKey {
    typealias Value = () -> Void
}

extension FocusedValues {
    var addPageAction: (() -> Void)? {
        get { self[AddPageActionKey.self] }
        set { self[AddPageActionKey.self] = newValue }
    }
}
