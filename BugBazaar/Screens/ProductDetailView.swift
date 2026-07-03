import SwiftUI

struct ProductDetailView: View {
    let productID: Int
    @EnvironmentObject private var cart: CartStore
    @EnvironmentObject private var router: Router

    private var product: Product? {
        allProducts.first { $0.id == productID }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                BackCircleButton { router.pop() }
                Spacer()
                Text(product?.category.uppercased() ?? "")
                    .font(.bodyFont(11, bold: true))
                    .kerning(1.5)
                    .foregroundColor(Theme.gray)
                Spacer()
                Color.clear.frame(width: 32, height: 32)
            }
            .padding(.horizontal, Spacing.m)
            .padding(.vertical, Spacing.m)

            if let product {
                detail(product)
            } else {
                VStack(spacing: Spacing.m) {
                    EmojiView(emoji: "🔍", size: 48)
                    Text("Specimen not found")
                        .font(.display(20))
                        .foregroundColor(Theme.inkBlack)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Theme.paperWhite)
    }

    private func detail(_ product: Product) -> some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20).fill(Theme.cardBg)
                        EmojiView(emoji: product.emoji, size: 80)
                    }
                    .frame(height: 240)
                    .overlay(alignment: .topLeading) {
                        if let badge = product.badge {
                            BadgeView(badge: badge).padding(12)
                        }
                    }
                    .padding(.horizontal, Spacing.m)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(product.name)
                            .font(.display(28))
                            .foregroundColor(Theme.inkBlack)
                        Text(product.price.usd)
                            .font(.display(22))
                            .foregroundColor(Theme.priceGray)
                        Text(product.description)
                            .font(.bodyFont(14))
                            .foregroundColor(Theme.priceGray)
                            .lineSpacing(6)
                            .padding(.top, Spacing.m)
                    }
                    .padding(Spacing.m)
                    .padding(.top, Spacing.s)

                    VStack(alignment: .leading, spacing: 0) {
                        Text("SPECIMEN DETAILS")
                            .font(.bodyFont(11, bold: true))
                            .kerning(1.5)
                            .foregroundColor(Theme.gray)
                            .padding(.bottom, Spacing.m)
                        detailRow("Category", product.category)
                        detailRow("Rarity", product.badge?.rawValue ?? "Standard")
                        detailRow("Condition", "Preserved")
                        detailRow("Origin", "Lab Bred")
                    }
                    .padding(Spacing.m)

                    let related = allProducts
                        .filter { $0.category == product.category && $0.id != product.id }
                        .prefix(3)
                    if !related.isEmpty {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("RELATED SPECIMENS")
                                .font(.bodyFont(11, bold: true))
                                .kerning(1.5)
                                .foregroundColor(Theme.gray)
                                .padding(.bottom, Spacing.m)
                            ForEach(Array(related)) { r in
                                Button {
                                    router.push(.product(r.id))
                                } label: {
                                    HStack(spacing: 12) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12).fill(Theme.cardBg)
                                            EmojiView(emoji: r.emoji, size: 24)
                                        }
                                        .frame(width: 44, height: 44)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(r.name)
                                                .font(.display(15))
                                                .foregroundColor(Theme.inkBlack)
                                            Text(r.price.usd)
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(Theme.priceGray)
                                        }
                                        Spacer()
                                    }
                                    .padding(.vertical, 10)
                                    .overlay(alignment: .bottom) {
                                        Rectangle().fill(Theme.hairline).frame(height: 1)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(Spacing.m)
                    }
                }
                .padding(.bottom, 100)
            }

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("PRICE")
                        .font(.bodyFont(11))
                        .kerning(1)
                        .foregroundColor(Theme.gray)
                    Text(product.price.usd)
                        .font(.display(22))
                        .foregroundColor(Theme.inkBlack)
                }
                Button {
                    cart.addToCart(product)
                    router.cartPresented = true
                } label: {
                    Text("ADD TO CART")
                        .font(.bodyFont(14, bold: true))
                        .foregroundColor(Theme.stickerGreen)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Capsule().fill(Theme.inkBlack))
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("add-to-cart")
            }
            .padding(Spacing.m)
            .background(Theme.paperWhite)
            .overlay(alignment: .top) {
                Rectangle().fill(Theme.hairline).frame(height: 1)
            }
        }
    }

    private func detailRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(Theme.gray)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(Theme.inkBlack)
        }
        .padding(.vertical, 10)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Theme.hairline).frame(height: 1)
        }
    }
}
