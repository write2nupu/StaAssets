import SwiftUI

enum Category: String, CaseIterable, Codable {
    case savings = "Savings"
    case debts = "Debts"
    case subscriptions = "Subscriptions"
    case utilities = "Utilities"
    case housing = "Housing"
    case transportation = "Transportation"
    case personalCare = "Personal Care"
    case gifts = "Gifts"
    case insurance = "Insurance"
    case entertainment = "Entertainment"
    case food = "Food"
    case travel = "Travel"
    case shopping = "Shopping"
    case bills = "Bills"
    
    var icon: String {
        switch self {
        case .savings: return "banknote"
        case .debts: return "creditcard"
        case .subscriptions: return "repeat"
        case .utilities: return "bolt"
        case .housing: return "house"
        case .transportation: return "car"
        case .personalCare: return "heart.text.square"
        case .gifts: return "gift"
        case .insurance: return "shield"
        case .entertainment: return "gamecontroller"
        case .food: return "fork.knife"
        case .travel: return "airplane"
        case .shopping: return "bag"
        case .bills: return "doc.text"
        }
    }
    
    var gradient: [Color] {
        switch self {
        case .savings: return [.green, .mint]
        case .debts: return [.red, .pink]
        case .subscriptions: return [.purple, .indigo]
        case .utilities: return [.yellow, .orange]
        case .housing: return [.brown, .orange]
        case .transportation: return [.blue, .cyan]
        case .personalCare: return [.pink, .red]
        case .gifts: return [.purple, .pink]
        case .insurance: return [.gray, .blue]
        case .entertainment: return [.indigo, .purple]
        case .food: return [.orange, .red]
        case .travel: return [.teal, .blue]
        case .shopping: return [.pink, .purple]
        case .bills: return [.teal, .green]
        }
    }
}
