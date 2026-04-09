import SwiftUI
import Charts

struct CategoryDetailView: View {
    
    let category: String
    
    @EnvironmentObject var vm: TransactionViewModel
    @State private var selectedPeriod = 0
    @State private var animateChart = false
    
    var body: some View {
        
        ScrollView {
            
            VStack(spacing: 20) {
                
                // MARK: - Segmented Control
                Picker("", selection: $selectedPeriod) {
                    Text("Weekly").tag(0)
                    Text("Monthly").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // MARK: - Chart
                Chart {
                    ForEach(data) { item in
                        chartContent(for: item)
                    }
                }
                .frame(height: 260)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 7)) {
                        AxisGridLine().foregroundStyle(.gray.opacity(0.2))
                        AxisValueLabel().foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.secondarySystemBackground))
                )
                .padding(.horizontal)
                
                // MARK: - Summary Section
                VStack(spacing: 12) {
                    
                    statRow(title: "Total Expense", value: total)
                    statRow(title: "Transactions", value: filteredTransactions.count)
                    statRow(title: "Average", value: average)
                    
                }
                .padding(.horizontal)
            }
            .padding(.top)
        }
        .onAppear {
            animateChart = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeOut(duration: 0.8)) {
                    animateChart = true
                }
            }
        }
        .onChange(of: selectedPeriod) { _, _ in
            animateChart = false
            
            withAnimation(.easeOut(duration: 0.8)) {
                animateChart = true
            }
        }
        .navigationTitle("\(category) Insights")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemBackground))
    }
}

extension CategoryDetailView {
    
    var filteredTransactions: [Transaction] {
        vm.transactions.filter { $0.category == category }
    }
    
    var data: [ChartData] {
        
        let calendar = Calendar.current
        
        if selectedPeriod == 0 {
            
            return (1...7).map { index in
                
                let total = filteredTransactions
                    .filter {
                        calendar.component(.weekday, from: $0.date) == index
                    }
                    .reduce(0) { $0 + $1.amount }
                
                let label = calendar.shortWeekdaySymbols[index - 1]
                
                return ChartData(label: label, value: total)
            }
            
        } else {
            
            let grouped = Dictionary(grouping: filteredTransactions) {
                calendar.component(.weekOfMonth, from: $0.date)
            }
            
            return (1...5).map { week in
                
                let total = grouped[week]?.reduce(0) { $0 + $1.amount } ?? 0
                
                return ChartData(label: "Week \(week)", value: total)
            }
        }
    }
    
    var total: Int {
        Int(filteredTransactions.reduce(0) { $0 + $1.amount })
    }
    
    var average: Int {
        filteredTransactions.isEmpty ? 0 : total / filteredTransactions.count
    }
}

extension CategoryDetailView {
    
    func statRow(title: String, value: Int) -> some View {
        
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(title == "Transactions" ? "\(value)" : "₹\(value)")
                .fontWeight(.semibold)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    @ChartContentBuilder
    func chartContent(for item: ChartData) -> some ChartContent {
        
        let gradient = Category(rawValue: category)?.gradient ?? [.gray, .black]
        
        AreaMark(
            x: .value("Time", item.label),
            y: .value("Amount", animateChart ? item.value : 0)
        )
        .interpolationMethod(.catmullRom)
        .foregroundStyle(
            LinearGradient(
                colors: gradient.map { $0.opacity(0.3) },
                startPoint: .top,
                endPoint: .bottom
            )
        )
        
        LineMark(
            x: .value("Time", item.label),
            y: .value("Amount", item.value)
        )
        .interpolationMethod(.catmullRom)
        .foregroundStyle(
            LinearGradient(
                colors: gradient,
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .symbol(Circle())
    }
}
