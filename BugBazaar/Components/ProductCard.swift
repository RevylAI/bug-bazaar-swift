import SwiftUI

struct BadgeView: View {
    let badge: Badge

    private var color: Color {
        switch badge {
        case .rare: return Theme.mangoOrange
        case .new: return Theme.stickerGreen
        case .hot: return Theme.hotRed
        }
    }

    var body: some View {
        Text(badge.rawValue)
            .font(.bodyFont(10, bold: true))
            .foregroundColor(Theme.inkBlack)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(RoundedRectangle(cornerRadius: 6).fill(color))
            .overlay(
                RoundedRectangle(cornerRadius: 6).stroke(Theme.hairline, lineWidth: 1)
            )
    }
}

struct ProductCard: View {
    let product: Product
    @EnvironmentObject private var cart: CartStore
    @EnvironmentObject private var router: Router

    var body: some View {
        let qty = cart.quantity(of: product.id)

        VStack(alignment: .leading, spacing: Spacing.s) {
            Button {
                router.push(.product(product.id))
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 16).fill(Theme.cardBg)
                    HalftoneOverlay()
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    EmojiView(emoji: product.emoji, size: 48)
                }
                .aspectRatio(1, contentMode: .fit)
                .overlay(alignment: .topLeading) {
                    if let badge = product.badge {
                        BadgeView(badge: badge).padding(8)
                    }
                }
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.display(15))
                    .lineLimit(1)
                    .foregroundColor(Theme.inkBlack)
                HStack {
                    Text(product.price.usd)
                        .font(.bodyFont(13, bold: true))
                        .foregroundColor(Theme.priceGray)
                    Spacer()
                    if qty == 0 {
                        Button {
                            cart.addToCart(product)
                        } label: {
                            Text("+")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Theme.inkBlack)
                                .frame(width: 28, height: 28)
                                .overlay(Circle().stroke(Theme.inkBlack, lineWidth: 2))
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("add-\(product.id)")
                    } else {
                        HStack(spacing: 2) {
                            Button {
                                cart.updateQuantity(product.id, quantity: qty - 1)
                            } label: {
                                Text("−")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(Theme.stickerGreen)
                                    .frame(width: 26, height: 28)
                            }
                            .buttonStyle(.plain)
                            Text("\(qty)")
                                .font(.bodyFont(13, bold: true))
                                .foregroundColor(Theme.paperWhite)
                                .frame(minWidth: 18)
                            Button {
                                cart.addToCart(product)
                            } label: {
                                Text("+")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(Theme.stickerGreen)
                                    .frame(width: 26, height: 28)
                            }
                            .buttonStyle(.plain)
                        }
                        .background(RoundedRectangle(cornerRadius: 14).fill(Theme.inkBlack))
                    }
                }
            }
        }
    }
}

struct ProductGrid: View {
    let products: [Product]

    private var rows: [[Product]] {
        stride(from: 0, to: products.count, by: 2).map {
            Array(products[$0..<min($0 + 2, products.count)])
        }
    }

    var body: some View {
        VStack(spacing: Spacing.m) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(alignment: .top, spacing: Spacing.m) {
                    ForEach(row) { product in
                        ProductCard(product: product)
                    }
                    if row.count == 1 {
                        Color.clear.frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.m)
    }
}
