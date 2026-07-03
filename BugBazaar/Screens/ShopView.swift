import SwiftUI

struct ShopView: View {
    @State private var activeFilter = "All Bugs"

    private var filteredProducts: [Product] {
        activeFilter == "All Bugs"
            ? allProducts
            : allProducts.filter { $0.category == activeFilter }
    }

    var body: some View {
        VStack(spacing: 0) {
            HeaderView()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    HeroBanner()
                    FilterChips(activeFilter: $activeFilter)
                    ProductGrid(products: filteredProducts)
                }
                .padding(.bottom, Spacing.xl)
            }
        }
        .background(Theme.paperWhite)
    }
}
