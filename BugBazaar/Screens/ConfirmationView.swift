import SwiftUI

struct ConfirmationView: View {
    @EnvironmentObject private var router: Router
    @State private var appeared = false
    @State private var orderID = "ORD-\(Int.random(in: 1000...9999))"

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                ZStack {
                    Circle().fill(Theme.stickerGreen)
                    EmojiView(emoji: "🪲", size: 48)
                }
                .frame(width: 100, height: 100)
                .shadow(color: Theme.stickerGreen.opacity(0.3), radius: 20, x: 0, y: 8)
                .scaleEffect(appeared ? 1 : 0.5)
                .opacity(appeared ? 1 : 0)
                .padding(.bottom, Spacing.l)

                VStack(spacing: 0) {
                    Text("Order Placed!")
                        .font(.display(32))
                        .foregroundColor(Theme.inkBlack)
                        .padding(.bottom, Spacing.s)
                    Text("Your specimens are on their way")
                        .font(.bodyFont(14))
                        .foregroundColor(Theme.gray)
                        .padding(.bottom, Spacing.l)

                    VStack(spacing: 4) {
                        Text("ORDER ID")
                            .font(.bodyFont(9, bold: true))
                            .kerning(1.5)
                            .foregroundColor(Theme.gray)
                        Text(orderID)
                            .font(.bodyFont(20, bold: true))
                            .foregroundColor(Theme.inkBlack)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Theme.cardBg))
                    .padding(.bottom, Spacing.l)

                    VStack(spacing: 0) {
                        detailRow("📦", "Estimated Delivery", "3-5 business days")
                        divider
                        detailRow("📧", "Confirmation Email", "Sent to collector@bugbazaar.com")
                        divider
                        detailRow("🔔", "Tracking", "Updates will be sent via notification")
                    }
                    .padding(Spacing.m)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Theme.cardBg))
                }
                .opacity(appeared ? 1 : 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(Spacing.xl)

            VStack(spacing: Spacing.s) {
                Button {
                    router.popToRoot(tab: .shop)
                } label: {
                    Text("CONTINUE SHOPPING")
                        .font(.bodyFont(14, bold: true))
                        .foregroundColor(Theme.stickerGreen)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Capsule().fill(Theme.inkBlack))
                }
                .buttonStyle(.plain)
                Button {
                    router.popToRoot(tab: .account)
                } label: {
                    Text("VIEW ORDERS")
                        .font(.bodyFont(14, bold: true))
                        .foregroundColor(Theme.inkBlack)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .overlay(Capsule().stroke(Theme.inkBlack, lineWidth: 2))
                }
                .buttonStyle(.plain)
            }
            .padding(Spacing.m)
        }
        .background(Theme.paperWhite)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.6)) {
                appeared = true
            }
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(Theme.hairline)
            .frame(height: 1)
            .padding(.leading, 36)
    }

    private func detailRow(_ emoji: String, _ title: String, _ value: String) -> some View {
        HStack(spacing: 12) {
            EmojiView(emoji: emoji, size: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Theme.inkBlack)
                Text(value)
                    .font(.system(size: 12))
                    .foregroundColor(Theme.gray)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
}
