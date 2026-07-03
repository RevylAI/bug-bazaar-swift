import SwiftUI

struct OrderDetailView: View {
    let orderID: String
    @EnvironmentObject private var cart: CartStore
    @EnvironmentObject private var router: Router

    private var order: Order? {
        cart.orders.first { $0.id == orderID }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                BackCircleButton { router.pop() }
                Spacer()
                Text("Order Details")
                    .font(.display(18))
                    .foregroundColor(Theme.inkBlack)
                Spacer()
                Color.clear.frame(width: 32, height: 32)
            }
            .padding(.horizontal, Spacing.m)
            .padding(.vertical, Spacing.m)
            .overlay(alignment: .bottom) {
                Rectangle().fill(Theme.hairline).frame(height: 1)
            }

            if let order {
                detail(order)
            } else {
                VStack(spacing: Spacing.m) {
                    EmojiView(emoji: "📦", size: 48)
                    Text("Order not found")
                        .font(.display(20))
                        .foregroundColor(Theme.inkBlack)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Theme.paperWhite)
    }

    private func statusColor(_ status: OrderStatus) -> Color {
        switch status {
        case .delivered: return Theme.stickerGreen
        case .shipped: return Theme.mangoOrange
        case .processing: return Theme.mangoYellow
        }
    }

    private func detail(_ order: Order) -> some View {
        let shippedOrDelivered = order.status == .shipped || order.status == .delivered

        return ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(order.id)
                        .font(.bodyFont(20, bold: true))
                        .foregroundColor(Theme.inkBlack)
                    Spacer()
                    Text(order.status.rawValue)
                        .font(.bodyFont(11, bold: true))
                        .foregroundColor(Theme.inkBlack)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 12)
                        .background(RoundedRectangle(cornerRadius: 6).fill(statusColor(order.status)))
                }
                Text(order.date)
                    .font(.bodyFont(13))
                    .foregroundColor(Theme.gray)
                    .padding(.top, 4)
                    .padding(.bottom, Spacing.l)

                VStack(alignment: .leading, spacing: 0) {
                    timelineStep(
                        done: true,
                        label: "Order Placed",
                        detail: order.date
                    )
                    timelineLine
                    timelineStep(
                        done: shippedOrDelivered,
                        label: "Shipped",
                        detail: shippedOrDelivered ? "In transit" : "Pending"
                    )
                    timelineLine
                    timelineStep(
                        done: order.status == .delivered,
                        label: "Delivered",
                        detail: order.status == .delivered ? "Complete" : "Estimated 3-5 days"
                    )
                }
                .padding(Spacing.m)
                .background(RoundedRectangle(cornerRadius: 14).fill(Theme.cardBg))
                .padding(.bottom, Spacing.l)

                Text("ITEMS")
                    .font(.bodyFont(11, bold: true))
                    .kerning(1.5)
                    .foregroundColor(Theme.gray)
                    .padding(.bottom, Spacing.m)

                ForEach(order.items) { item in
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12).fill(Theme.cardBg)
                            EmojiView(emoji: item.product.emoji, size: 24)
                        }
                        .frame(width: 44, height: 44)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.product.name)
                                .font(.display(14))
                                .foregroundColor(Theme.inkBlack)
                            Text("Qty: \(item.quantity)")
                                .font(.bodyFont(12))
                                .foregroundColor(Theme.gray)
                        }
                        Spacer()
                        Text(item.lineTotal.usd)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Theme.inkBlack)
                    }
                    .padding(.vertical, 10)
                    .overlay(alignment: .bottom) {
                        Rectangle().fill(Theme.hairline).frame(height: 1)
                    }
                }

                VStack(spacing: 6) {
                    totalRow("Subtotal", order.subtotal.usd)
                    totalRow("Shipping", order.shipping == 0 ? "FREE" : order.shipping.usd,
                             valueColor: order.shipping == 0 ? Theme.stickerGreen : Theme.inkBlack)
                    totalRow("Tax", order.tax.usd)
                    Rectangle()
                        .fill(Color.black.opacity(0.1))
                        .frame(height: 1)
                        .padding(.vertical, 4)
                    HStack {
                        Text("Total")
                            .font(.display(18))
                            .foregroundColor(Theme.inkBlack)
                        Spacer()
                        Text(order.total.usd)
                            .font(.display(18))
                            .foregroundColor(Theme.inkBlack)
                    }
                }
                .padding(Spacing.m)
                .background(RoundedRectangle(cornerRadius: 14).fill(Theme.cardBg))
                .padding(.top, Spacing.l)
            }
            .padding(Spacing.m)
            .padding(.bottom, Spacing.xl)
        }
    }

    private var timelineLine: some View {
        Rectangle()
            .fill(Theme.lightGray)
            .frame(width: 2, height: 20)
            .padding(.leading, 5)
            .padding(.vertical, 2)
    }

    private func timelineStep(done: Bool, label: String, detail: String) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(done ? Theme.stickerGreen : Theme.lightGray)
                .frame(width: 12, height: 12)
            Text(label)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Theme.inkBlack)
            Spacer()
            Text(detail)
                .font(.bodyFont(12))
                .foregroundColor(Theme.gray)
        }
    }

    private func totalRow(_ label: String, _ value: String, valueColor: Color = Theme.inkBlack) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(Theme.priceGray)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(valueColor)
        }
    }
}
