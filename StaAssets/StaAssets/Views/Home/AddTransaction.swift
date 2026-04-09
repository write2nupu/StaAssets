import SwiftUI

struct AddTransactionView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var amount = ""
    @State private var category = Category.food.rawValue
    @State private var note = ""
    @State private var isIncome = false
    
    var onSave: (Double, String, String, Bool) -> Void
    
    var body: some View {
        
        NavigationStack {
            
            Form {
                
                // MARK: - Amount
                Section("Amount") {
                    TextField("Enter amount", text: $amount)
                        .keyboardType(.decimalPad)
                }
                
                // MARK: - Category
                Section("Category") {
                    
                    let categories = Category.allCases.map { $0.rawValue }
                    
                    Picker("Select Category", selection: $category) {
                        ForEach(categories, id: \.self) { item in
                            
                            let icon = Category(rawValue: item)?.icon ?? "square.grid.2x2"
                            
                            Label {
                                Text(item)
                            } icon: {
                                Image(systemName: icon)
                            }
                            .tag(item)
                        }
                    }
                }
                
                // MARK: - Note
                Section("Note") {
                    TextField("Add note", text: $note)
                }
                
                // MARK: - Income Toggle
                Section {
                    Toggle("Is Income?", isOn: $isIncome)
                }
            }
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            
            // MARK: - Toolbar
            .toolbar {
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let value = Double(amount) {
                            onSave(value, category, note, isIncome)
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(amount.isEmpty)
                }
            }
        }
    }
}
