import SwiftUI
import CoreData

struct PageDetailView: View {
    @ObservedObject var page: Page
    @Environment(\.managedObjectContext) private var viewContext
    @FocusState private var focusedBlockID: UUID?

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                Button {
                    addTableBlock()
                } label: {
                    Image(systemName: "tablecells")
                }
                .help("Crear tabla")
                .buttonStyle(.borderless)

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(.regularMaterial)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    TextField("Título", text: Binding(
                        get: { page.title ?? "" },
                        set: { newValue in
                            page.title = newValue
                            DispatchQueue.main.async {
                                saveContext()
                            }
                        }
                    ))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 8)

                    ForEach(page.blocksArray, id: \.id) { block in
                        BlockRowView(
                            block: block,
                            focusedBlockID: $focusedBlockID,
                            number: numberForBlock(block),
                            onSave: saveContext,
                            onSubmit: { addBlock(after: block) },
                            onDelete: { deleteBlock(block) }
                        )
                        .padding(.horizontal, 24)
                    }

                    Button {
                        addBlock(after: nil)
                    } label: {
                        Label("Agregar bloque", systemImage: "plus.circle")
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 24)
                    .padding(.top, 6)

                    Button {
                        let child = Page(context: viewContext)
                        child.title = "Nueva subpágina"
                        child.content = ""
                        child.createdAt = Date()
                        child.parent = page
                        try? viewContext.save()
                    } label: {
                        Label("Agregar subpágina", systemImage: "plus.rectangle.on.folder")
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(Color("AccentPrimary"))
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                }
                .frame(maxWidth: 760, alignment: .leading)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 60)
            }
        }
    }

    private func numberForBlock(_ block: Block) -> Int? {
        guard block.blockType == .numberedList else { return nil }
        let blocks = page.blocksArray
        guard let index = blocks.firstIndex(of: block) else { return nil }

        var count = 1
        var i = index - 1
        while i >= 0 && blocks[i].blockType == .numberedList {
            count += 1
            i -= 1
        }
        return count
    }

    private func addBlock(after block: Block?) {
        let newBlock = Block(context: viewContext)
        newBlock.id = UUID()
        newBlock.text = ""
        newBlock.page = page

        if let block, block.blockType == .bulletList || block.blockType == .numberedList {
            newBlock.blockType = block.blockType
        } else {
            newBlock.blockType = .paragraph
        }

        var blocks = page.blocksArray
        if let block, let index = blocks.firstIndex(of: block) {
            blocks.insert(newBlock, at: index + 1)
        } else {
            blocks.append(newBlock)
        }

        reindexAndSave(blocks)
        focusedBlockID = newBlock.id
    }

    private func addTableBlock() {
        let newBlock = Block(context: viewContext)
        newBlock.id = UUID()
        newBlock.blockType = .table
        newBlock.tableRows = 2
        newBlock.tableColumns = 2
        newBlock.page = page

        for r in 0..<2 {
            for c in 0..<2 {
                let cell = TableCell(context: viewContext)
                cell.id = UUID()
                cell.row = Int16(r)
                cell.column = Int16(c)
                cell.text = ""
                cell.block = newBlock
            }
        }

        var blocks = page.blocksArray
        blocks.append(newBlock)
        reindexAndSave(blocks)
    }

    private func deleteBlock(_ block: Block) {
        var blocks = page.blocksArray
        guard let index = blocks.firstIndex(of: block) else { return }

        let previousID = index > 0 ? blocks[index - 1].id : nil

        blocks.remove(at: index)
        viewContext.delete(block)
        reindexAndSave(blocks)

        focusedBlockID = previousID
    }

    private func reindexAndSave(_ blocks: [Block]) {
        for (index, block) in blocks.enumerated() {
            block.order = Int32(index)
        }
        saveContext()
    }

    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Error al guardar: \(error.localizedDescription)")
        }
    }
}
