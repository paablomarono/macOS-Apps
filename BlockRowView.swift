import SwiftUI

struct BlockRowView: View {
    @ObservedObject var block: Block
    var focusedBlockID: FocusState<UUID?>.Binding
    var number: Int?
    var onSave: () -> Void
    var onSubmit: () -> Void
    var onDelete: () -> Void

    var body: some View {
        Group {
            if block.blockType == .table {
                TableBlockView(block: block, onSave: onSave)
                    .padding(.leading, CGFloat(block.indentLevel) * 24)
                    .padding(.vertical, 4)
            } else {
                HStack(alignment: .top, spacing: 10) {
                    if block.blockType == .checkbox {
                        Toggle("", isOn: Binding(
                            get: { block.isChecked },
                            set: { block.isChecked = $0; onSave() }
                        ))
                        .toggleStyle(.checkbox)
                        .labelsHidden()
                        .padding(.top, 3)
                    } else if block.blockType == .bulletList {
                        Circle()
                            .fill(Color.secondary)
                            .frame(width: 5, height: 5)
                            .padding(.top, 10)
                    } else if block.blockType == .numberedList {
                        Text("\(number ?? 1).")
                            .font(.body)
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                            .frame(minWidth: 22, alignment: .trailing)
                            .padding(.top, 2)
                    }

                    TextField("", text: Binding(
                        get: { block.text ?? "" },
                        set: { handleTextChange($0) }
                    ), axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(fontForType(block.blockType))
                    .lineSpacing(3)
                    .strikethrough(block.blockType == .checkbox && block.isChecked)
                    .foregroundStyle(block.blockType == .checkbox && block.isChecked ? .secondary : .primary)
                    .focused(focusedBlockID, equals: block.id)
                    .onSubmit {
                        onSubmit()
                    }
                }
                .padding(.vertical, 4)
                .padding(.leading, CGFloat(block.indentLevel) * 24)
            }
        }
        .contextMenu {
            Menu("Tipo de bloque") {
                ForEach(BlockType.allCases.filter { $0 != .table }, id: \.self) { type in
                    Button {
                        block.blockType = type
                        onSave()
                    } label: {
                        Label(type.rawValue, systemImage: type.displayIcon)
                    }
                }
            }
            Divider()
            Button {
                block.indentLevel += 1
                onSave()
            } label: {
                Label("Aumentar sangría", systemImage: "increase.indent")
            }
            Button {
                if block.indentLevel > 0 {
                    block.indentLevel -= 1
                    onSave()
                }
            } label: {
                Label("Reducir sangría", systemImage: "decrease.indent")
            }
            Divider()
            Button("Eliminar bloque", role: .destructive) {
                onDelete()
            }
        }
    }

    private func handleTextChange(_ newValue: String) {
        if newValue.hasPrefix("# ") {
            block.blockType = .heading
            block.text = String(newValue.dropFirst(2))
        } else if newValue.hasPrefix("- ") {
            block.blockType = .bulletList
            block.text = String(newValue.dropFirst(2))
        } else if newValue.hasPrefix("1. ") {
            block.blockType = .numberedList
            block.text = String(newValue.dropFirst(3))
        } else if newValue.hasPrefix("[] ") {
            block.blockType = .checkbox
            block.text = String(newValue.dropFirst(3))
        } else {
            block.text = newValue
        }
        DispatchQueue.main.async {
            onSave()
        }
    }

    private func fontForType(_ type: BlockType) -> Font {
        switch type {
        case .heading: return .title2.bold()
        case .paragraph, .bulletList, .numberedList, .checkbox, .table: return .body
        }
    }
}
