import SwiftUI

struct ContentView: View {
    @Binding var selectedTab: String // 🔹 Permet de gérer la sélection

    var body: some View {
        NavigationSplitView {
            SidebarView(selectedTab: $selectedTab) // 🔥 Passe selectedTab à la sidebar
        } detail: {
            if selectedTab == "clients" {
                ContactListView(selectedTab: $selectedTab)
            } else if selectedTab == "articles" {
                ArticleListView(selectedTab: $selectedTab)
            } else {
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
