import SwiftUI

struct CartView: View {
    @EnvironmentObject private var cart: CartStore
    @EnvironmentObject private var router: Router
    @Environment(\.dismiss) private var dismiss

    private var shipping: Double { cart.totalPrice > 50 ? 0 : 5.99 }
    private var tax: Double { cart.totalPrice * 0.08 }
    private var grandTotal: Double { cart.totalPrice + shipping + tax }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                BackCircleButton(glyph: "✕") { dismiss() }
                Spacer()
                Text("Your Cart")
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

            if cart.items.isEmpty {
                emptyState
            } else {
                filledState
            }
        }
        .background(Theme.paperWhite)
    }

    private var emptyState: some View {
        VStack(spacing: 0) {
            EmojiView(emoji: "🛒", size: 64)
                .padding(.bottom, Spacing.m)
            Text("Cart is empty")
                .font(.display(24))
                .foregroundColor(Theme.inkBlack)
                .padding(.bottom, Spacing.s)
            Text("Add some bugs to get started!")
                .font(.bodyFont(14))
                .foregroundColor(Theme.gray)
                .padding(.bottom, Spacing.l)
            Button {
                dismiss()
            } label: {
                Text("BROWSE BUGS")
                    .font(.bodyFont(14, bold: true))
                    .foregroundColor(Theme.inkBlack)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 28)
                    .background(Capsule().fill(Theme.stickerGreen))
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Spacing.xl)
    }

    private var filledState: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(cart.items) { item in
                        cartRow(item)
                    }
                    summarySection
                        .padding(.top, Spacing.l)
                }
                .padding(Spacing.m)
                .padding(.bottom, 100)
            }

            VStack {
                Button {
                    dismiss()
                    router.push(.checkout)
                } label: {
                    Text("CHECKOUT · \(grandTotal.usd)")
                        .font(.bodyFont(14, bold: true))
                        .foregroundColor(Theme.inkBlack)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Capsule().fill(Theme.stickerGreen))
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("checkout-button")
            }
            .padding(Spacing.m)
            .background(Theme.paperWhite)
            .overlay(alignment: .top) {
                Rectangle().fill(Theme.hairline).frame(height: 1)
            }
        }
    }

    private func cartRow(_ item: CartItem) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14).fill(Theme.cardBg)
                EmojiView(emoji: item.product.emoji, size: 32)
            }
            .frame(width: 64, height: 64)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.product.name)
                    .font(.display(16))
                    .foregroundColor(Theme.inkBlack)
                Text(item.lineTotal.usd)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Theme.priceGray)
                HStack(spacing: 12) {
                    Button {
                        cart.updateQuantity(item.id, quantity: item.quantity - 1)
                    } label: {
                        Text("−")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Theme.inkBlack)
                            .frame(width: 28, height: 28)
                            .background(Circle().fill(Theme.lightGray))
                    }
                    .buttonStyle(.plain)
                    Text("\(item.quantity)")
                        .font(.bodyFont(14, bold: true))
                        .foregroundColor(Theme.inkBlack)
                        .frame(minWidth: 20)
                    Button {
                        cart.updateQuantity(item.id, quantity: item.quantity + 1)
                    } label: {
                        Text("+")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Theme.inkBlack)
                            .frame(width: 28, height: 28)
                            .background(Circle().fill(Theme.lightGray))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 8)
            }
            Spacer()
            Button {
                cart.removeFromCart(item.id)
            } label: {
                Text("✕")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.gray)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 12)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Theme.hairline).frame(height: 1)
        }
    }

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ORDER SUMMARY")
                .font(.bodyFont(11, bold: true))
                .kerning(1.5)
                .foregroundColor(Theme.gray)
                .padding(.bottom, Spacing.s)
            HStack {
                Text("Subtotal (\(cart.totalItems) item\(cart.totalItems != 1 ? "s" : ""))")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.priceGray)
                Spacer()
                Text(cart.totalPrice.usd)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Theme.inkBlack)
            }
            HStack {
                Text("Shipping")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.priceGray)
                Spacer()
                Text(shipping == 0 ? "FREE" : shipping.usd)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(shipping == 0 ? Theme.stickerGreen : Theme.inkBlack)
            }
            HStack {
                Text("Tax")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.priceGray)
                Spacer()
                Text(tax.usd)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Theme.inkBlack)
            }
            if shipping > 0 {
                Text("Add \((50 - cart.totalPrice).usd) more for free shipping!")
                    .font(.bodyFont(11, bold: true))
                    .foregroundColor(Theme.mangoOrange)
                    .padding(.top, 4)
            }
            Rectangle()
                .fill(Color.black.opacity(0.1))
                .frame(height: 1)
                .padding(.vertical, 8)
            HStack {
                Text("Total")
                    .font(.display(18))
                    .foregroundColor(Theme.inkBlack)
                Spacer()
                Text(grandTotal.usd)
                    .font(.display(18))
                    .foregroundColor(Theme.inkBlack)
            }
        }
        .padding(Spacing.m)
        .background(RoundedRectangle(cornerRadius: 16).fill(Theme.cardBg))
    }
}
