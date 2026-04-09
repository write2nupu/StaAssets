
import Foundation

struct PieSlice: Identifiable, Equatable {
    let id: UUID
    let category: String
    let value: Double
    
    init(id: UUID = UUID(), category: String, value: Double) {
        self.id = id
        self.category = category
        self.value = value
    }
}

struct ChartData: Identifiable, Equatable {
    let id: UUID
    let label: String
    let value: Double
    
    init(id: UUID = UUID(), label: String, value: Double) {
        self.id = id
        self.label = label
        self.value = value
    }
}
