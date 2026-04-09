import Foundation
import Combine

@MainActor
final class UserViewModel: ObservableObject {
    
    @Published var name: String = ""
    @Published var email: String = ""
}
