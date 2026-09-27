import Foundation

enum BlockType: String, CaseIterable {
    case paragraph
    case heading
    case bulletList
    case numberedList
    case checkbox
    case table

    var displayIcon: String {
        switch self {
        case .paragraph: return "text.alignleft"
        case .heading: return "textformat.size"
        case .bulletList: return "list.bullet"
        case .numberedList: return "list.number"
        case .checkbox: return "checklist"
        case .table: return "tablecells"
        }
    }
}
