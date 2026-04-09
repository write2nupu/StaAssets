import SwiftUI

struct RootView: View {
    
    @State private var isLoggedIn = false
    
    @StateObject private var userVM = UserViewModel()
    @StateObject private var transactionVM = TransactionViewModel()
    
    var body: some View {
        Group {
            if isLoggedIn {
                MainTabView()
                    .environmentObject(userVM)
                    .environmentObject(transactionVM)
            } else {
                AuthView(isLoggedIn: $isLoggedIn)
                    .environmentObject(userVM)
            }
        }
    }
}
