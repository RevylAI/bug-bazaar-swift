import SwiftUI

struct SpecimensView: View {
    @EnvironmentObject private var router: Router
    @State private var expandedCategory: String? = "Beetles"

    private var grouped: [(name: String, products: [Product])] {
        categories.dropFirst().map { cat in
            (name: cat, products: allProducts.filter { $0.category == cat })
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Specimens")
                    .font(.display(28))
                    .foregroundColor(Theme.inkBlack)
                Text("COLLECTION CATALOG")
                    .font(.bodyFont(11, bold: true))
                    .kerning(1.5)
                    .foregroundColor(Theme.gray)
            }
            .padding(.horizontal, Spacing.m)
            .padding(.top, Spacing.m)
            .padding(.bottom, Spacing.s)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    statsRow
                        .padding(.bottom, Spacing.l)
                    ForEach(grouped, id: \.name) { group in
                        categorySection(group)
                            .padding(.bottom, Spacing.s)
                    }
                }
                .padding(Spacing.m)
                .padding(.bottom, Spacing.xl)
            }
        }
        .background(Theme.paperWhite)
    }

    private var statsRow: some View {
        HStack(spacing: Spacing.s) {
            statBox("\(allProducts.count)", "TOTAL")
            statBox("\(allProducts.filter { $0.badge == .rare }.count)", "RARE")
            statBox("\(allProducts.filter { $0.badge == .new }.count)", "NEW")
            statBox("\(categories.count - 1)", "TYPES")
        }
    }

    private func statBox(_ number: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(number)
                .font(.display(24))
                .foregroundColor(Theme.inkBlack)
            Text(label)
                .font(.bodyFont(9, bold: true))
                .kerning(1)
                .foregroundColor(Theme.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Theme.cardBg))
    }

    private func categorySection(_ group: (name: String, products: [Product])) -> some View {
        VStack(spacing: 0) {
            Button {
                expandedCategory = expandedCategory == group.name ? nil : group.name
            } label: {
                HStack {
                    Text(group.name)
                        .font(.display(18))
                        .foregroundColor(Theme.inkBlack)
                    Spacer()
                    HStack(spacing: 8) {
                        Text("\(group.products.count)")
                            .font(.bodyFont(12, bold: true))
                            .foregroundColor(Theme.gray)
                        Text(expandedCategory == group.name ? "▾" : "▸")
                            .font(.system(size: 16))
                            .foregroundColor(Theme.gray)
                    }
                }
                .padding(Spacing.m)
                .background(Theme.lightGray)
            }
            .buttonStyle(.plain)

            if expandedCategory == group.name {
                ForEach(group.products) { product in
                    Button {
                        router.push(.product(product.id))
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10).fill(Theme.cardBg)
                                EmojiView(emoji: product.emoji, size: 22)
                            }
                            .frame(width: 40, height: 40)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(product.name)
                                    .font(.display(14))
                                    .foregroundColor(Theme.inkBlack)
                                Text(product.description)
                                    .font(.system(size: 11))
                                    .foregroundColor(Theme.gray)
                                    .lineLimit(1)
                            }
                            Spacer()
                            Text(product.price.usd)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Theme.priceGray)
                        }
                        .padding(12)
                        .background(Theme.paperWhite)
                        .overlay(alignment: .bottom) {
                            Rectangle().fill(Theme.hairline).frame(height: 1)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12).stroke(Theme.hairline, lineWidth: 1)
        )
    }
}
