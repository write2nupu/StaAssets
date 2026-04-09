import Foundation

extension TransactionEntity {
    
    func toModel() -> Transaction {
        Transaction(
            id: self.id ?? UUID(),
            amount: self.amount,
            category: self.category ?? "",
            date: self.date ?? Date(),
            note: self.note ?? "",
            isIncome: self.isIncome
        )
    }
    
    func update(from model: Transaction) {
        self.id = model.id
        self.amount = model.amount
        self.category = model.category
        self.date = model.date
        self.note = model.note
        self.isIncome = model.isIncome
    }
}
