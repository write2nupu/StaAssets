
import SwiftUI
import Charts

struct BalanceView: View {
    
    @StateObject private var vm = TransactionViewModel()
    @State private var showAddSheet = false
    
    @State private var selectedPeriod = 0
    @State private var currentDate = Date()
    
    var body: some View {
        
        ZStack {
            
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                AppHeaderView {}
                    .padding(.horizontal)
                
                ScrollView(showsIndicators: false) {
                    
                    VStack(alignment: .leading, spacing: 28) {
                        
                        header
                        
                        expenseGaugeView
                        
                        chartSection
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 120)
                }
            }
            
            FloatingActionButton {
                showAddSheet = true
            }
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
    }
}

extension BalanceView {
    
    var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Your Balances")
                .font(.title.bold())
            
            Text("Track your spending insights")
                .foregroundStyle(.secondary)
        }
        .padding(.top, 15)
    }
    
    // MARK: - TOP GAUGE
    
    var expenseGaugeView: some View {
        
        VStack(spacing: 16) {
            
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
                Text("Daily").tag(0)
                Text("Weekly").tag(1)
                Text("Monthly").tag(2)
            }
            .pickerStyle(.segmented)
            
            ZStack(alignment: .bottom) {
                
                DynamicGaugeSegments(values: segments)
                    .frame(width: 260, height: 160)
                
                VStack(spacing: 6) {
                    Text("₹\(Int(totalExpense))")
                        .font(.title.bold())
                    
                    Text("Total Spend")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .offset(y: 20)
            }
        }
    }
    
    // MARK: - BREAKDOWN
    
    var chartSection: some View {
        
        VStack(alignment: .leading, spacing: 20) {
            
            Text("Spending Breakdown")
                .font(.headline)
            
            VStack(spacing: 12) {
                
                ForEach(categoryTotals, id: \.category) { item in
                    
                    HStack {
                        Text(item.category)
                        
                        Spacer()
                        
                        Text("₹\(Int(item.amount))")
                            .font(.subheadline.bold())
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemBackground))
                    )
                }
            }
        }
    }
}

extension BalanceView {
    
    var expenseTransactions: [Transaction] {
        vm.transactions.filter { !$0.isIncome }
    }
    
    var filteredTransactions: [Transaction] {
        
        let calendar = Calendar.current
        
        return vm.transactions.filter { transaction in
            
            switch selectedPeriod {
                
            case 0: // Daily
                return calendar.isDate(transaction.date, inSameDayAs: currentDate)
                
            case 1: // Weekly
                return calendar.isDate(transaction.date, equalTo: currentDate, toGranularity: .weekOfYear)
                
            default: // Monthly
                return calendar.isDate(transaction.date, equalTo: currentDate, toGranularity: .month)
            }
        }
    }
    
    var categoryTotals: [(category: String, amount: Double)] {
        
        let grouped = Dictionary(grouping: filteredTransactions) { $0.category }
        
        return allCategories.map { category in
            
            let total = grouped[category]?.reduce(0) { $0 + $1.amount } ?? 0
            
            return (category, total)
        }
        .sorted { $0.amount > $1.amount }
    }
    
    var topCategories: [(String, Double)] {
        Array(categoryTotals.prefix(3))
    }
    
    var othersTotal: Double {
        categoryTotals.dropFirst(3).reduce(0) { $0 + $1.amount }
    }
    
    var totalExpense: Double {
        categoryTotals.reduce(0) { $0 + $1.amount }
    }
    
    var segments: [Double] {
        
        guard totalExpense > 0 else { return [] }
        
        let top = categoryTotals.prefix(3).map { $0.amount }
        let others = categoryTotals.dropFirst(3).reduce(0) { $0 + $1.amount }
        
        var raw = top
        
        if others > 0 {
            raw.append(others)
        }
        
        let normalized = raw.map { $0 / totalExpense }
        
        let minValue: Double = 0.05
        
        let adjusted = normalized.map { max($0, minValue) }
        
        let total = adjusted.reduce(0, +)
        
        return adjusted.map { $0 / total }
    }
}

extension BalanceView {
    
    var dateHeader: String {
        
        let calendar = Calendar.current
        let now = Date()
        let formatter = DateFormatter()
        
        switch selectedPeriod {
            
        case 0:
            formatter.dateFormat = "d MMM yyyy"
            return formatter.string(from: now)
            
        case 1:
            let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? now
            
            formatter.dateFormat = "d MMM"
            return "\(formatter.string(from: startOfWeek)) - \(formatter.string(from: endOfWeek))"
            
        default:
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: now)
        }
    }
    
    func changeDate(by value: Int) {
        
        let calendar = Calendar.current
        
        switch selectedPeriod {
            
        case 0: // Daily
            currentDate = calendar.date(byAdding: .day, value: value, to: currentDate) ?? currentDate
            
        case 1: // Weekly
            currentDate = calendar.date(byAdding: .weekOfYear, value: value, to: currentDate) ?? currentDate
            
        default: // Monthly
            currentDate = calendar.date(byAdding: .month, value: value, to: currentDate) ?? currentDate
        }
    }
    
    var formattedDate: String {
        
        let calendar = Calendar.current
        let formatter = DateFormatter()
        
        switch selectedPeriod {
            
        case 0: // DAILY
            formatter.dateFormat = "d MMM yyyy"
            return formatter.string(from: currentDate)
            
        case 1: // WEEKLY
            
            let interval = calendar.dateInterval(of: .weekOfYear, for: currentDate)
            let start = interval?.start ?? currentDate
            let end = calendar.date(byAdding: .day, value: 6, to: start) ?? currentDate
            
            formatter.dateFormat = "d MMM"
            
            return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
            
        default: // MONTHLY
            
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: currentDate)
        }
    }
}

struct DynamicGaugeSegments: View {
    
    let values: [Double]
    
    @State private var progress: Double = 0
    
    let colors: [[Color]] = [
        [.purple, .pink],
        [.blue, .cyan],
        [.green, .mint],
        [.orange, .red]
    ]
    
    let totalAngle: Double = 180
    let startAngle: Double = 180
    let gap: Double = 9
    
    var body: some View {
        
        let totalGap = gap * Double(max(values.count - 1, 0))
        let usableAngle = totalAngle - totalGap
        
        let angles = values.map { $0 * usableAngle }
        
        ZStack {
            
            ForEach(angles.indices, id: \.self) { i in
                
                let fullStart = startAngle
                    + angles.prefix(i).reduce(0, +)
                    + Double(i) * gap
                
                let fullEnd = fullStart + angles[i]
                
                // 👇 Animate END angle only
                let animatedEnd = fullStart + (fullEnd - fullStart) * progress
                
                ArcShape(
                    startAngle: fullStart,
                    endAngle: animatedEnd
                )
                .stroke(
                    LinearGradient(
                        colors: colors[min(i, colors.count - 1)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(
                        lineWidth: 18,
                        lineCap: .round
                    )
                )
            }
        }
        .onAppear {
            animate()
        }
        .onChange(of: values) { _, _ in
            animate()
        }
    }
    
    func animate() {
        progress = 0
        
        withAnimation(.easeOut(duration: 1.2)) {
            progress = 1
        }
    }
}

struct ArcShape: Shape {
    
    var startAngle: Double
    var endAngle: Double
    
    func path(in rect: CGRect) -> Path {
        
        var path = Path()
        
        let center = CGPoint(x: rect.midX, y: rect.maxY)
        let radius = rect.width / 2
        
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(startAngle),
            endAngle: .degrees(endAngle),
            clockwise: false
        )
        
        return path
    }
}
