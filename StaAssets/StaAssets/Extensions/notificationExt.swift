import SwiftUI

func notificationRow(_ text: String) -> some View {
    HStack(alignment: .top) {
        
        Image(systemName: "bell.fill")
            .foregroundStyle(.primary)
        
        Text(text)
            .font(.caption)
            .foregroundStyle(.primary)
        
        Spacer()
    }
    .padding()
    .background(Color(.secondarySystemBackground))
    .clipShape(RoundedRectangle(cornerRadius: 12))
}

struct NotificationPopoverView: View {
    
    @EnvironmentObject var vm: TransactionViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            
            Text("Notifications")
                .font(.subheadline.bold())
            
            if vm.notifications.isEmpty {
                Text("No notifications")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                
                ForEach(vm.notifications.prefix(3), id: \.self) { note in
                    Text(note)
                        .font(.caption)
                        .lineLimit(2)
                }
                
                if vm.notifications.count > 3 {
                    Divider()
                    
                    Text("Show All")
                        .font(.caption.bold())
                        .foregroundStyle(.blue)
                }
            }
        }
        .padding(12)
        .frame(width: 200)
    }
}
