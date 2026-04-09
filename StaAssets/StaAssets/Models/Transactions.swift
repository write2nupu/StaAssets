
import Foundation

struct Transaction: Identifiable, Equatable, Codable {
    let id: UUID
    let amount: Double
    let category: String
    let date: Date
    let note: String
    let isIncome: Bool
    
    init(
        id: UUID = UUID(),
        amount: Double,
        category: String,
        date: Date,
        note: String,
        isIncome: Bool
    ) {
        self.id = id
        self.amount = amount
        self.category = category
        self.date = date
        self.note = note
        self.isIncome = isIncome
    }
}
