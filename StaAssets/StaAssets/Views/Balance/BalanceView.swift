import SwiftUI
import Charts

struct BalanceView: View {
    
    @EnvironmentObject var vm: TransactionViewModel
    @State private var showAddSheet = false
    
    @State private var selectedPeriod = 0
    @State private var currentDate = Date()
    
    var body: some View {
        NavigationStack{
            
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
                            Spacer()
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
                
                DynamicGaugeSegments(
                    values: segments,
                    categories: topCategories.map { $0.0 } + (othersTotal > 0 ? ["Others"] : [])
                )
                    .frame(width: 280, height: 160)
                
                VStack(spacing: 6) {
                    Text("₹\(Int(totalExpense))")
                        .font(.title.bold())
                    
                    Text("Total Spend")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .offset(y: 10)
            }
            .padding(.top, 20) 
        }
    }
    
    // MARK: - BREAKDOWN
    
    var chartSection: some View {
        
        VStack(alignment: .leading, spacing: 20) {
            
            Text("Spending Breakdown")
                .font(.headline)
            
            VStack(spacing: 12) {
                
                ForEach(categoryTotals, id: \.category) { item in
                    
                    let gradient = Category(rawValue: item.category)?.gradient ?? [.gray, .black]
                    
                    NavigationLink {
                        CategoryDetailView(category: item.category)
                    } label: {
                        
                        HStack(spacing: 12) {
                            
                            Image(systemName: Category(rawValue: item.category)?.icon ?? "square.grid.2x2")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: gradient,
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 32, height: 32)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(
                                            LinearGradient(
                                                colors: gradient.map { $0.opacity(0.15) },
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                )
                            
                            Text(item.category)
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("₹\(Int(item.amount))")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.primary)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.secondarySystemBackground))
                        )
                    }
                }
            }
        }
    }
}

extension BalanceView {
    
    var expenseOnlyTransactions: [Transaction] {
        filteredTransactions.filter { !$0.isIncome }
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
        
        let grouped = Dictionary(grouping: expenseOnlyTransactions) { $0.category }
        
        return Category.allCases.map { category in
            
            let total = grouped[category.rawValue]?.reduce(0) { $0 + $1.amount } ?? 0
            
            return (category.rawValue, total)
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
        expenseOnlyTransactions.reduce(0) { $0 + $1.amount }
    }
    
    var segments: [Double] {
        
        guard totalExpense > 0 else { return [1] }
        
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
    
    var isEmpty: Bool {
        values.count == 1 && values.first == 1
    }
    let values: [Double]
    let categories: [String]
    
    @State private var progresses: [Double] = []
    
    let totalAngle: Double = 180
    let startAngle: Double = 180
    let gap: Double = 12
    
    var body: some View {
        
        let totalGap = gap * Double(max(values.count - 1, 0))
        let usableAngle = totalAngle - totalGap
        let angles = values.map { $0 * usableAngle }
        
        return ZStack {
            
            if isEmpty {
                ArcShape(
                    startAngle: startAngle,
                    endAngle: startAngle + totalAngle
                )
                .stroke(
                    Color.primary.opacity(0.1),
                    style: StrokeStyle(
                        lineWidth: 28,
                        lineCap: .round
                    )
                )
            }
            
            ForEach(angles.indices, id: \.self) { i in
                segmentView(index: i, angles: angles)
            }
        }
        .onAppear {
            setupAnimation()
        }
        .onChange(of: values) { _, _ in
            setupAnimation()
        }
    }
    
    @ViewBuilder
    func segmentView(index i: Int, angles: [Double]) -> some View {
        
        let segmentStart = angles.prefix(i).reduce(0, +) + Double(i) * gap
        let segmentEnd = segmentStart + angles[i]
        
        let progress = progresses.indices.contains(i) ? progresses[i] : 0
        let animatedEnd = segmentStart + (segmentEnd - segmentStart) * progress
        
        let category = categories.indices.contains(i) ? categories[i] : "Others"
        let gradient = Category(rawValue: category)?.gradient ?? [.gray, .black]
        
        ArcShape(
            startAngle: startAngle + segmentStart,
            endAngle: startAngle + animatedEnd
        )
        .stroke(
            LinearGradient(
                colors: gradient,
                startPoint: .leading,
                endPoint: .trailing
            ),
            style: StrokeStyle(
                lineWidth: 28,
                lineCap: .round,
                lineJoin: .round
            )
        )
    }
     
    // MARK: - Smooth Sequential Animation
    
    func setupAnimation() {
        
        progresses = Array(repeating: 0, count: values.count)
        
        Task {
            for i in progresses.indices {
                
                await MainActor.run {
                    withAnimation(.timingCurve(0.22, 1, 0.36, 1, duration: 0.7)) {
                        progresses[i] = 1
                    }
                }
                
                // slight overlap → smooth continuous feel
                try? await Task.sleep(nanoseconds: 400_000_000)
            }
        }
    }
}

struct ArcShape: Shape {
    
    var startAngle: Double
    var endAngle: Double
    
    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(startAngle, endAngle) }
        set {
            startAngle = newValue.first
            endAngle = newValue.second
        }
    }
    
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
