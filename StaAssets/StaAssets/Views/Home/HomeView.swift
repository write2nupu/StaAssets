
import SwiftUI
import Combine

struct HomeView: View {
    
    @State private var selectedSegment = 0
    @State private var showAddSheet = false
    @State private var selectedCategory: String? = nil
    
    @State private var showFilterSheet = false
    @State private var selectedCategories: Set<String> = []
    @State private var selectedType: String? = nil
    
    @EnvironmentObject var vm: TransactionViewModel
    @EnvironmentObject var userVM: UserViewModel
    
    var body: some View {
        
        ZStack {
            
            Color(.systemBackground).ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                AppHeaderView(
                    showFilter: true,
                    onFilterTap: {
                        showFilterSheet = true
                    }
                )
                .environmentObject(vm)
                
                ScrollView(showsIndicators: false) {
                    
                    VStack(spacing: 25) {
                        
                        greetingView
                        
                        cardView
                        
                        expenseSection
                    }
                    .padding(.bottom, 100)
                }
            }
            .padding(.horizontal)
            
            FloatingActionButton {
                showAddSheet = true
            }
        }
        .alert(vm.alertMessage, isPresented: $vm.showAlert) {
            Button("OK", role: .cancel) {}
        }
        .sheet(isPresented: $showAddSheet) {
            AddTransactionView { amount, category, note, isIncome in
                vm.addTransaction(
                    amount: amount,
                    category: category,
                    note: note,
                    isIncome: isIncome
                )
            }
        }
        .sheet(isPresented: $showFilterSheet) {
            FilterView(
                selectedCategories: $selectedCategories,
                selectedType: $selectedType
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationContentInteraction(.scrolls)
        }
        
    }
}

extension HomeView {
    
    var greetingView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Hey, \(userVM.name.isEmpty ? "User" : userVM.name)")
                .foregroundStyle(.primary)
                .font(.title2.bold())
            
            Text("Add your yesterday’s expense")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var cardView: some View {
        
        ZStack(alignment: .leading) {
            
            LinearGradient(
                colors: [
                    Color(#colorLiteral(red: 0.85, green: 0.75, blue: 0.6, alpha: 1)),
                    Color(#colorLiteral(red: 0.2, green: 0.7, blue: 0.6, alpha: 1))
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 🔥 adaptive overlay
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.primary.opacity(0.15))
            
            VStack(alignment: .leading, spacing: 20) {
                
                Text("ADRBank")
                    .foregroundStyle(.white)
                    .font(.headline)
                
                Text("8763 1111 2222 0329")
                    .foregroundStyle(.white)
                    .font(.title2.bold())
                
                HStack {
                    
                    VStack(alignment: .leading) {
                        Text("Card Holder Name")
                            .foregroundStyle(.white.opacity(0.7))
                            .font(.caption)
                        
                        Text(userVM.name)
                            .textCase(.uppercase)
                            .foregroundStyle(.white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("Expired Date")
                            .foregroundStyle(.white.opacity(0.7))
                            .font(.caption)
                        
                        Text("10/28")
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding()
        }
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .frame(height: 200)
    }
    
    var expenseSection: some View {
        
        VStack(alignment: .leading, spacing: 20) {
            
            Text("Your expenses")
                .font(.headline)
                .foregroundStyle(.primary)
            
            Picker("", selection: $selectedSegment) {
                Text("Weekly").tag(0)
                Text("Monthly").tag(1)
            }
            .pickerStyle(.segmented)
            
            VStack(spacing: 16) {
                
                let filtered = vm.transactions.filter { transaction in
                    
                    // Category
                    let categoryMatch = selectedCategories.isEmpty ||
                        selectedCategories.contains(transaction.category)
                    
                    // Type
                    let typeMatch: Bool
                    if let selectedType {
                        if selectedType == "Income" {
                            typeMatch = transaction.isIncome
                        } else {
                            typeMatch = !transaction.isIncome
                        }
                    } else {
                        typeMatch = true
                    }
                    
                    return categoryMatch && typeMatch
                }
                
                if filtered.isEmpty {
                    Text("No transactions")
                        .foregroundStyle(.secondary)
                        .padding(.top, 20)
                } else {
                    ForEach(filtered) { transaction in
                        expenseCard(transaction: transaction)
                    }
                }
            }
        }
    }
    
    func expenseCard(transaction: Transaction) -> some View {
        
        HStack {
            
            ZStack {
                Circle()
                    .fill(Color.primary.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: categoryIcon(transaction.category))
                    .font(.system(size: 16, weight: .semibold))
            }
            
            VStack(alignment: .leading) {
                Text(transaction.category.uppercased())
                    .font(.headline)
                
                Text(transaction.note.isEmpty ? "No note" : transaction.note)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text("₹\(Int(transaction.amount))")
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.primary.opacity(0.1))
                .cornerRadius(10)
        }
        .padding()
        .background(
            ZStack {
                
                // Base card (adaptive)
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.secondarySystemBackground))
                
                // Gradient (left fade only)
                LinearGradient(
                    colors: gradientColors(for: transaction.category),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .opacity(0.25) // softer
                .mask(
                    LinearGradient(
                        colors: [.black, .clear], // FIXED
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color.primary.opacity(0.06))
        )
    }
    
    func gradientColors(for category: String) -> [Color] {
        switch category {

        case "Savings":
            return [.green, .mint]
        case "Debts":
            return [.red, .pink]
        case "Subscriptions":
            return [.purple, .indigo]
        case "Utilities":
            return [.yellow, .orange]
        case "Housing":
            return [.brown, .orange]
        case "Transportation":
            return [.blue, .cyan]
        case "Personal Care":
            return [.pink, .red]
        case "Gifts":
            return [.purple, .pink]
        case "Insurance":
            return [.gray, .blue]
        case "Entertainment":
            return [.indigo, .purple]
        case "Food":
            return [.orange, .red]
        case "Travel":
            return [.teal, .blue]
        case "Shopping":
            return [.pink, .purple]
        case "Bills":
            return [.teal, .green]
            
        default:
            return [.gray, .black]
        }
    }
}

#Preview {
    HomeView()
}
