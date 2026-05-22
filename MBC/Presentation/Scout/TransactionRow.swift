import MBCDesignSystem
import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack {
            Text(iconForType)
            VStack(alignment: .leading) {
                Text(labelForType)
                    .font(DSFont.caption)
                    .fontWeight(.medium)
                    .foregroundColor(DSColor.textPrimary)
                Text(formattedDate)
                    .font(.system(size: 11))
                    .foregroundColor(DSColor.textSecondary)
            }
            Spacer()
            Text(amountText)
                .font(DSFont.caption)
                .fontWeight(.semibold)
                .foregroundColor(amountColor)
        }
        .padding(.vertical, 4)
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: transaction.timestamp)
    }

    private var iconForType: String {
        switch transaction.type {
        case .topUp: "💰"
        case .checkIn: "🚪"
        case .checkOut: "🚏"
        }
    }

    private var labelForType: String {
        switch transaction.type {
        case .topUp: "Top-up"
        case .checkIn: "Masuk"
        case .checkOut: "Keluar"
        }
    }

    private var amountText: String {
        switch transaction.type {
        case .topUp: "+Rp \(transaction.amount.currencyFormatted)"
        case .checkOut: "-Rp \(transaction.amount.currencyFormatted)"
        case .checkIn: "—"
        }
    }

    private var amountColor: Color {
        switch transaction.type {
        case .topUp: DSColor.success
        case .checkOut: DSColor.error
        case .checkIn: DSColor.textSecondary
        }
    }
}
