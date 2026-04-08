
import Foundation
import SwiftUI

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

