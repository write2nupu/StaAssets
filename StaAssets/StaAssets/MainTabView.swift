import SwiftUI

struct MainTabView: View {
    
    var body: some View {
        
        TabView {
            
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            
            BalanceView()
                .tabItem {
                    Image(systemName: "wallet.pass")
                    Text("Balances")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
        }
    }
}
