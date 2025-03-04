import SwiftUI

struct ContentView: View {
    @Binding var selectedTab: String

    var body: some View {
        NavigationSplitView {
            SidebarView(selectedTab: $selectedTab)
        } detail: {
            switch selectedTab {
            case "clients":
                ContactListView(selectedTab: $selectedTab)
            case "articles":
                ArticleListView(selectedTab: $selectedTab)
            case "devis":
                NewQuoteView()
            default:
                Text("Sélectionnez un élément")
                    .foregroundColor(.blue)
                    .font(.title2)
            }
        }
    }
}

#Preview {
    ContentView(selectedTab: .constant("clients"))
}
