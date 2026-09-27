import Foundation

extension Page {
    var childrenArray: [Page] {
        let set = children as? Set<Page> ?? []
        return set.sorted { $0.createdAt ?? Date() < $1.createdAt ?? Date() }
    }

    var childrenArrayOrNil: [Page]? {
        childrenArray.isEmpty ? nil : childrenArray
    }

    var blocksArray: [Block] {
        let set = blocks as? Set<Block> ?? []
        return set.sorted { $0.order < $1.order }
    }
}
