import SwiftUI

struct HomeView: View {
    
    @State private var selectedSegment = 0
    @State private var showAddSheet = false
    @State private var selectedCategory: String? = nil
    
    @State private var showFilterSheet = false
    @State private var selectedCategories: Set<String> = []
    @State private var selectedType: String? = nil
    @State private var selectedPeriod = 0
    @State private var currentDate = Date()
    @State private var animateList = false
    @State private var transactionToDelete: Transaction?
    @State private var showDeleteAlert = false
    
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
        .alert("Delete Transaction?", isPresented: $showDeleteAlert) {
            
            Button("Delete", role: .destructive) {
                if let transactionToDelete {
                    withAnimation {
                        vm.deleteTransaction(transactionToDelete)
                    }
                }
                self.transactionToDelete = nil
            }
            
            Button("Cancel", role: .cancel) {}
            
        } message: {
            Text("This action cannot be undone.")
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
            
            VStack(spacing: 12) {
                
                HStack {
                    
                    Button {
                        changeDate(by: -1)
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    
                    Spacer()
                    
                    Text(formattedDate)
                        .font(.headline)
                    
                    Spacer()
                    
                    Button {
                        changeDate(by: 1)
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                }
                
                Picker("", selection: $selectedPeriod) {
                    Text("Day").tag(0)
                    Text("Week").tag(1)
                    Text("Month").tag(2)
                }
                .pickerStyle(.segmented)
                .onChange(of: selectedPeriod) { _, _ in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentDate = Date()
                    }
                }
            }
            
            LazyVStack(spacing: 12) {
                
                let calendar = Calendar.current
                
                let filtered = vm.transactions.filter { transaction in
                    let categoryMatch = selectedCategories.isEmpty ||
                    selectedCategories.contains(transaction.category)
                    
                    let typeMatch: Bool
                    if let selectedType {
                        typeMatch = selectedType == "Income" ? transaction.isIncome : !transaction.isIncome
                    } else {
                        typeMatch = true
                    }
                    
                    let dateMatch: Bool
                    switch selectedPeriod {
                    case 0:
                        dateMatch = calendar.isDate(transaction.date, inSameDayAs: currentDate)
                    case 1:
                        dateMatch = calendar.isDate(transaction.date, equalTo: currentDate, toGranularity: .weekOfYear)
                    default:
                        dateMatch = calendar.isDate(transaction.date, equalTo: currentDate, toGranularity: .month)
                    }
                    
                    return categoryMatch && typeMatch && dateMatch
                }
                
                if filtered.isEmpty {
                    Text("No transactions")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 20)
                } else {
                    ForEach(filtered) { transaction in
                        
                        expenseCard(transaction: transaction)
                            .padding(.horizontal, 6)
                            .contextMenu {
                                
                                Button(role: .destructive) {
                                    transactionToDelete = transaction
                                    showDeleteAlert = true
                                } label: {
                                    Label {
                                        Text("Delete")
                                    } icon: {
                                        Image(systemName: "trash")
                                            .symbolRenderingMode(.monochrome)
                                            .foregroundStyle(.red)
                                    }
                                }
                            }
                    }
                }
            }
        }
    }
    
    func changeDate(by value: Int) {
        
        let calendar = Calendar.current
        
        withAnimation(.easeInOut(duration: 0.3)) {
            switch selectedPeriod {
            case 0:
                currentDate = calendar.date(byAdding: .day, value: value, to: currentDate) ?? currentDate
            case 1:
                currentDate = calendar.date(byAdding: .weekOfYear, value: value, to: currentDate) ?? currentDate
            default:
                currentDate = calendar.date(byAdding: .month, value: value, to: currentDate) ?? currentDate
            }
        }
    }
    
    var formattedDate: String {
        
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        switch selectedPeriod {
            
        case 0:
            formatter.dateFormat = "d MMM yyyy"
            return formatter.string(from: currentDate)
            
        case 1:
            let interval = calendar.dateInterval(of: .weekOfYear, for: currentDate)
            let start = interval?.start ?? currentDate
            let end = calendar.date(byAdding: .day, value: 6, to: start) ?? currentDate
            
            formatter.dateFormat = "d MMM"
            return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
            
        default:
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: currentDate)
        }
    }
    
    func expenseCard(transaction: Transaction) -> some View {
        
        let gradient = Category(rawValue: transaction.category)?.gradient ?? [.gray, .black]
        
        return HStack {
            
            ZStack {
                Circle()
                    .fill(Color.primary.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: Category(rawValue: transaction.category)?.icon ?? "square.grid.2x2")
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
            
            Text(transaction.displayAmount)
                .foregroundStyle(transaction.displayColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.primary.opacity(0.1))
                .cornerRadius(10)
        }
        .padding()
        .background(
            ZStack {
                
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.secondarySystemBackground))
                
                LinearGradient(
                    colors: gradient,
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .opacity(0.25)
                .mask(
                    LinearGradient(
                        colors: [.clear, .black, .clear],
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
}

#Preview {
    HomeView()
}
