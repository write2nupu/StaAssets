
import Foundation

let allCategories = [
    "Savings",
    "Debts",
    "Subscriptions",
    "Utilities",
    "Housing",
    "Transportation",
    "Personal Care",
    "Gifts",
    "Insurance",
    "Entertainment",
    "Food",
    "Travel",
    "Shopping",
    "Bills"
]

func categoryIcon(_ category: String) -> String {
    switch category {
    case "Savings": return "banknote"
    case "Debts": return "creditcard"
    case "Subscriptions": return "repeat"
    case "Utilities": return "bolt"
    case "Housing": return "house"
    case "Transportation": return "car"
    case "Personal Care": return "heart.text.square"
    case "Gifts": return "gift"
    case "Insurance": return "shield"
    case "Entertainment": return "gamecontroller"
    case "Food": return "fork.knife"
    case "Travel": return "airplane"
    case "Shopping": return "bag"
    case "Bills": return "doc.text"
    default: return "square.grid.2x2"
    }
}
