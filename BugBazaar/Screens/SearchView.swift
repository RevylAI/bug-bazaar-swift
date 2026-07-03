import SwiftUI

struct SearchView: View {
    @State private var query = ""
    @EnvironmentObject private var cart: CartStore
    @EnvironmentObject private var router: Router

    private let trendingSearches = ["Beetle", "Rare", "Spider", "Moth"]

    private var results: [Product] {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return [] }
        let q = trimmed.lowercased()
        return allProducts.filter {
            $0.name.lowercased().contains(q)
                || $0.category.lowercased().contains(q)
                || $0.description.lowercased().contains(q)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Search")
                .font(.display(28))
                .foregroundColor(Theme.inkBlack)
                .padding(.horizontal, Spacing.m)
                .padding(.vertical, Spacing.m)

            HStack(spacing: 8) {
                EmojiView(emoji: "🔍", size: 16)
                TextField("Search bugs, beetles, moths...", text: $query)
                    .font(.bodyFont(15))
                    .foregroundColor(Theme.inkBlack)
                    .autocorrectionDisabled()
                    .accessibilityIdentifier("search-input")
                if !query.isEmpty {
                    Button {
                        query = ""
                    } label: {
                        Text("✕")
                            .font(.system(size: 16))
                            .foregroundColor(Theme.gray)
                            .padding(4)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .frame(height: 44)
            .background(RoundedRectangle(cornerRadius: 12).fill(Theme.lightGray))
            .padding(.horizontal, Spacing.m)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    if query.trimmingCharacters(in: .whitespaces).isEmpty {
                        emptyState
                    } else if results.isEmpty {
                        noResults
                    } else {
                        resultsList
                    }
                }
                .padding(Spacing.m)
                .padding(.bottom, Spacing.xl)
            }
        }
        .background(Theme.paperWhite)
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionTitle("TRENDING SEARCHES")
            FlowRow(spacing: Spacing.s) {
                ForEach(trendingSearches, id: \.self) { term in
                    Button {
                        query = term
                    } label: {
                        Text(term)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Theme.inkBlack)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Capsule().fill(Theme.lightGray))
                    }
                    .buttonStyle(.plain)
                }
            }

            sectionTitle("POPULAR SPECIMENS")
                .padding(.top, Spacing.l)
            ForEach(allProducts.prefix(4)) { product in
                Button {
                    router.push(.product(product.id))
                } label: {
                    HStack(spacing: 12) {
                        EmojiView(emoji: product.emoji, size: 32)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(product.name)
                                .font(.display(16))
                                .foregroundColor(Theme.inkBlack)
                            Text(product.price.usd)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Theme.priceGray)
                        }
                        Spacer()
                        if let badge = product.badge {
                            Text(badge.rawValue)
                                .font(.bodyFont(10, bold: true))
                                .foregroundColor(Theme.inkBlack)
                                .padding(.vertical, 2)
                                .padding(.horizontal, 8)
                                .background(RoundedRectangle(cornerRadius: 6).fill(Theme.mangoOrange))
                        }
                    }
                    .padding(.vertical, 12)
                    .overlay(alignment: .bottom) {
                        Rectangle().fill(Theme.hairline).frame(height: 1)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var noResults: some View {
        VStack(spacing: Spacing.s) {
            EmojiView(emoji: "🔍", size: 48)
                .padding(.bottom, Spacing.s)
            Text("No specimens found")
                .font(.display(20))
                .foregroundColor(Theme.inkBlack)
            Text("Try searching for beetles, moths, or spiders")
                .font(.bodyFont(14))
                .foregroundColor(Theme.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    private var resultsList: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("\(results.count) SPECIMEN\(results.count != 1 ? "S" : "") FOUND")
                .font(.bodyFont(12, bold: true))
                .kerning(1)
                .foregroundColor(Theme.gray)
                .padding(.bottom, Spacing.m)

            ForEach(results) { product in
                HStack(spacing: 12) {
                    Button {
                        router.push(.product(product.id))
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12).fill(Theme.cardBg)
                                EmojiView(emoji: product.emoji, size: 28)
                            }
                            .frame(width: 56, height: 56)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(product.name)
                                    .font(.display(16))
                                    .foregroundColor(Theme.inkBlack)
                                Text(product.category.uppercased())
                                    .font(.bodyFont(11))
                                    .kerning(1)
                                    .foregroundColor(Theme.gray)
                                Text(product.price.usd)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(Theme.priceGray)
                            }
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)

                    Button {
                        cart.addToCart(product)
                    } label: {
                        Text("+")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Theme.inkBlack)
                            .frame(width: 32, height: 32)
                            .overlay(Circle().stroke(Theme.inkBlack, lineWidth: 2))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 12)
                .overlay(alignment: .bottom) {
                    Rectangle().fill(Theme.hairline).frame(height: 1)
                }
            }
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.bodyFont(11, bold: true))
            .kerning(1.5)
            .foregroundColor(Theme.gray)
            .padding(.bottom, Spacing.s)
    }
}

/// Simple wrapping HStack for the trending chips.
struct FlowRow<Content: View>: View {
    var spacing: CGFloat
    @ViewBuilder var content: Content

    var body: some View {
        // The four trending chips fit on one line on all target devices.
        HStack(spacing: spacing) { content }
    }
}
