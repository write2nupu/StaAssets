import Foundation
import CoreData
import SwiftUI
import Combine

@MainActor
final class TransactionViewModel: ObservableObject {
    
    @Published private(set) var transactions: [Transaction] = []
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    @Published var notifications: [String] = []
    
    var balance: Double {
        transactions.reduce(0) {
            $0 + ($1.isIncome ? $1.amount : -$1.amount)
        }
    }
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext? = nil) {
        self.context = context ?? PersistenceController.shared.context
        fetchTransactions()
    }
    
    // MARK: - Fetch
    func fetchTransactions() {
        let request: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \TransactionEntity.date, ascending: false)
        ]
        
        do {
            let result = try context.fetch(request)
            self.transactions = result.map { $0.toModel() }
        } catch {
            print("❌ Fetch failed:", error.localizedDescription)
        }
    }
    
    // MARK: - Add
    func addTransaction(
        amount: Double,
        category: String,
        note: String,
        isIncome: Bool
    ) {
        
        if !isIncome && amount > balance {
            alertMessage = "Insufficient balance.\nCannot spend ₹\(Int(amount))"
            showAlert = true
            return
        }
        
        let newTransaction = TransactionEntity(context: context)
        newTransaction.update(
            from: Transaction(
                amount: amount,
                category: category,
                date: Date(),
                note: note,
                isIncome: isIncome
            )
        )
        
        let message = isIncome
        ? "₹\(Int(amount)) credited"
        : "₹\(Int(amount)) debited"
        
        alertMessage = message
        notifications.insert(message, at: 0)
        showAlert = true
        
        save()
    }
    
    // MARK: - Delete
    func deleteTransaction(_ transaction: Transaction) {
        let request: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        
        do {
            let result = try context.fetch(request)
            
            if let match = result.first(where: { $0.id == transaction.id }) {
                context.delete(match)
                save()
            }
        } catch {
            print("Delete failed:", error.localizedDescription)
        }
    }
    
    // MARK: - Save
    private func save() {
        PersistenceController.shared.save()
        fetchTransactions()
    }
}

extension Transaction {
    
    var displayAmount: String {
        let sign = isIncome ? "+ " : "- "
        return "\(sign)₹\(Int(amount))"
    }
    
    var displayColor: Color {
        isIncome ? .green : .primary
    }
}
