import SwiftUI

struct AccountView: View {
    @EnvironmentObject private var cart: CartStore
    @EnvironmentObject private var auth: AuthBypassStore
    @EnvironmentObject private var router: Router

    @State private var activeSection = "Orders"
    @State private var demoAlert: String?

    private var totalOrders: Int { cart.orders.count }
    private var totalBugs: Int { cart.orders.reduce(0) { $0 + $1.itemCount } }
    private var totalSpent: Double { cart.orders.reduce(0) { $0 + $1.total } }

    private var statusLabel: String {
        switch auth.status.state {
        case .accepted: return "ACCEPTED"
        case .rejected: return "REJECTED"
        case .idle: return "IDLE"
        }
    }

    private func formatSpent(_ amount: Double) -> String {
        amount >= 1000
            ? String(format: "$%.1fk", amount / 1000)
            : String(format: "$%.0f", amount)
    }

    private func orderStatusColor(_ status: OrderStatus) -> Color {
        switch status {
        case .delivered: return Theme.stickerGreen
        case .shipped: return Theme.mangoOrange
        case .processing: return Theme.mangoYellow
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Account")
                .font(.display(28))
                .foregroundColor(Theme.inkBlack)
                .padding(.horizontal, Spacing.m)
                .padding(.vertical, Spacing.m)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    profileCard
                        .padding(.bottom, Spacing.m)
                    authCard
                        .padding(.bottom, Spacing.m)
                    statsRow
                        .padding(.bottom, Spacing.l)
                    sectionTabs
                        .padding(.bottom, Spacing.m)
                    if activeSection == "Orders" {
                        ordersSection
                    } else {
                        settingsSection
                    }
                }
                .padding(Spacing.m)
                .padding(.bottom, Spacing.xl + 20)
            }
        }
        .background(Theme.paperWhite)
        .alert(demoAlert ?? "", isPresented: Binding(
            get: { demoAlert != nil },
            set: { if !$0 { demoAlert = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(demoAlert == "Logged Out" ? "You have been logged out (demo)." : "This is a demo feature.")
        }
    }

    private var profileCard: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(Theme.stickerGreen)
                EmojiView(emoji: "🐛", size: 28)
            }
            .frame(width: 52, height: 52)
            VStack(alignment: .leading, spacing: 2) {
                Text(auth.session?.name ?? "Bug Collector")
                    .font(.display(18))
                    .foregroundColor(Theme.inkBlack)
                Text(auth.session?.email ?? "collector@bugbazaar.com")
                    .font(.bodyFont(12))
                    .foregroundColor(Theme.gray)
            }
            Spacer()
            if auth.session != nil || totalOrders > 0 {
                Text((auth.session?.role.rawValue ?? "PRO").uppercased())
                    .font(.bodyFont(10, bold: true))
                    .foregroundColor(Theme.inkBlack)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 10)
                    .background(RoundedRectangle(cornerRadius: 6).fill(Theme.mangoOrange))
            }
        }
        .padding(Spacing.m)
        .background(RoundedRectangle(cornerRadius: 16).fill(Theme.cardBg))
    }

    private var authCard: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            HStack(spacing: Spacing.s) {
                Text("Revyl Auth Bypass")
                    .font(.display(17))
                    .foregroundColor(Theme.inkBlack)
                Spacer()
                Text(statusLabel)
                    .font(.bodyFont(10, bold: true))
                    .foregroundColor(Theme.inkBlack)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 6).fill(
                            auth.status.state == .accepted
                                ? Theme.stickerGreen
                                : auth.status.state == .rejected
                                    ? Theme.rejectedRed
                                    : Theme.lightGray
                        )
                    )
                    .accessibilityIdentifier("auth-status-badge")
            }
            Text(auth.status.message)
                .font(.bodyFont(12))
                .foregroundColor(Theme.priceGray)
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                Text("Token source")
                    .font(.bodyFont(11))
                    .foregroundColor(Theme.gray)
                Spacer()
                Text(auth.launchConfig.source == .launchEnv ? "Launch vars" : "Demo fallback")
                    .font(.bodyFont(11, bold: true))
                    .foregroundColor(Theme.inkBlack)
            }
            .padding(.top, 6)
            HStack {
                Text("Handler gate")
                    .font(.bodyFont(11))
                    .foregroundColor(Theme.gray)
                Spacer()
                Text(auth.launchConfig.enabled ? "Enabled" : "Disabled")
                    .font(.bodyFont(11, bold: true))
                    .foregroundColor(Theme.inkBlack)
            }
            .padding(.top, 6)
            if auth.session != nil {
                Button {
                    auth.signOut()
                } label: {
                    Text("Reset demo session")
                        .font(.bodyFont(12, bold: true))
                        .foregroundColor(Theme.paperWhite)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Theme.inkBlack))
                }
                .buttonStyle(.plain)
                .padding(.top, Spacing.s)
            }
        }
        .padding(Spacing.m)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Theme.paperWhite)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.inkBlack, lineWidth: 2))
        )
    }

    private var statsRow: some View {
        HStack(spacing: Spacing.s) {
            statBox("\(totalOrders)", "ORDERS", highlight: false)
            statBox("\(totalBugs)", "BUGS", highlight: false)
            statBox(formatSpent(totalSpent), "SPENT", highlight: totalSpent > 0)
        }
    }

    private func statBox(_ number: String, _ label: String, highlight: Bool) -> some View {
        VStack(spacing: 2) {
            Text(number)
                .font(.display(20))
                .foregroundColor(Theme.inkBlack)
            Text(label)
                .font(.bodyFont(9, bold: true))
                .kerning(1)
                .foregroundColor(Theme.inkBlack.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12).fill(highlight ? Theme.stickerGreen : Theme.cardBg)
        )
    }

    private var sectionTabs: some View {
        HStack(spacing: Spacing.s) {
            ForEach(["Orders", "Settings"], id: \.self) { section in
                Button {
                    activeSection = section
                } label: {
                    Text(section)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(activeSection == section ? Theme.paperWhite : Theme.inkBlack)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 20)
                        .background(
                            Capsule().fill(activeSection == section ? Theme.inkBlack : Theme.lightGray)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var ordersSection: some View {
        VStack(spacing: Spacing.s) {
            if cart.orders.isEmpty {
                VStack(spacing: Spacing.s) {
                    EmojiView(emoji: "📦", size: 48)
                        .padding(.bottom, Spacing.s)
                    Text("No orders yet")
                        .font(.display(20))
                        .foregroundColor(Theme.inkBlack)
                    Text("Your order history will appear here")
                        .font(.bodyFont(13))
                        .foregroundColor(Theme.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 48)
            } else {
                ForEach(cart.orders) { order in
                    Button {
                        router.push(.order(order.id))
                    } label: {
                        VStack(spacing: 8) {
                            HStack {
                                Text(order.id)
                                    .font(.bodyFont(14, bold: true))
                                    .foregroundColor(Theme.inkBlack)
                                Spacer()
                                Text(order.status.rawValue)
                                    .font(.bodyFont(10, bold: true))
                                    .foregroundColor(Theme.inkBlack)
                                    .padding(.vertical, 2)
                                    .padding(.horizontal, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(orderStatusColor(order.status))
                                    )
                            }
                            HStack {
                                Text(order.date)
                                    .font(.system(size: 12))
                                    .foregroundColor(Theme.gray)
                                Spacer()
                                Text("\(order.itemCount) item\(order.itemCount != 1 ? "s" : "") · \(order.total.usd)")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(Theme.priceGray)
                                    .padding(.trailing, 20)
                            }
                        }
                        .padding(Spacing.m)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Theme.cardBg))
                        .overlay(alignment: .trailing) {
                            Text("›")
                                .font(.system(size: 22))
                                .foregroundColor(Theme.gray)
                                .padding(.trailing, Spacing.m)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var settingsSection: some View {
        VStack(spacing: 0) {
            ForEach([
                ("Edit Profile", "✏️"),
                ("Shipping Addresses", "📦"),
                ("Payment Methods", "💳"),
                ("Notifications", "🔔"),
                ("Help & Support", "❓"),
            ], id: \.0) { item in
                Button {
                    demoAlert = item.0
                } label: {
                    HStack(spacing: 12) {
                        EmojiView(emoji: item.1, size: 20)
                        Text(item.0)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Theme.inkBlack)
                        Spacer()
                        Text("›")
                            .font(.system(size: 22))
                            .foregroundColor(Theme.gray)
                    }
                    .padding(.vertical, 14)
                    .overlay(alignment: .bottom) {
                        Rectangle().fill(Theme.hairline).frame(height: 1)
                    }
                }
                .buttonStyle(.plain)
            }

            Button {
                if auth.session != nil {
                    auth.signOut()
                } else {
                    demoAlert = "Logged Out"
                }
            } label: {
                Text("Log Out")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Theme.hotRed)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .overlay(Capsule().stroke(Theme.hotRed, lineWidth: 2))
            }
            .buttonStyle(.plain)
            .padding(.top, Spacing.l)
        }
    }
}
