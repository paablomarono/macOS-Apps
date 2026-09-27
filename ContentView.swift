import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Page.createdAt, ascending: true)],
        predicate: NSPredicate(format: "parent == nil")
    )
    private var rootPages: FetchedResults<Page>

    @State private var selectedPage: Page?

    var body: some View {
        NavigationSplitView {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 10) {
                    Image("NexoIcon")
                        .resizable()
                        .frame(width: 26, height: 26)
                        .clipShape(RoundedRectangle(cornerRadius: 6))

                    Text("Nexo")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 10)

                List(selection: $selectedPage) {
                    OutlineGroup(Array(rootPages), children: \.childrenArrayOrNil) { page in
                        HStack(spacing: 6) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                            Text(page.title?.isEmpty == false ? page.title! : "Sin título")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .tag(page)
                        .onTapGesture {
                            selectedPage = page
                        }
                        .contextMenu {
                            Button("Eliminar", role: .destructive) {
                                deletePage(page)
                            }
                        }
                    }
                }
                .listStyle(.sidebar)
            }
            .toolbar {
                ToolbarItem {
                    Button(action: addPage) {
                        Label("Nueva página", systemImage: "square.and.pencil")
                    }
                }
            }
        } detail: {
            if let selectedPage {
                PageDetailView(page: selectedPage)
            } else {
                VStack(spacing: 12) {
                    Image("NexoIcon")
                        .resizable()
                        .frame(width: 64, height: 64)
                        .opacity(0.3)
                    Text("Selecciona una página")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .focusedValue(\.addPageAction, addPage)
        .tint(Color("AccentPrimary"))
    }

    private func addPage() {
        let newPage = Page(context: viewContext)
        newPage.title = "Nueva página"
        newPage.content = ""
        newPage.createdAt = Date()

        do {
            try viewContext.save()
            selectedPage = newPage
        } catch {
            print("Error al guardar: \(error.localizedDescription)")
        }
    }

    private func deletePage(_ page: Page) {
        if selectedPage == page {
            selectedPage = nil
        }
        viewContext.delete(page)

        do {
            try viewContext.save()
        } catch {
            print("Error al borrar: \(error.localizedDescription)")
        }
    }
}
