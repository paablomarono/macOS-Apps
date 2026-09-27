import Foundation

extension Block {
    var blockType: BlockType {
        get { BlockType(rawValue: type ?? "") ?? .paragraph }
        set { type = newValue.rawValue }
    }
}
