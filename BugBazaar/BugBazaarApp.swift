import SwiftUI

@main
struct BugBazaarApp: App {
    @StateObject private var cart = CartStore()
    @StateObject private var auth = AuthBypassStore()
    @StateObject private var router = Router()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(cart)
                .environmentObject(auth)
                .environmentObject(router)
                .onOpenURL { url in
                    switch auth.handleAuthBypassURL(url) {
                    case .accepted(let redirect):
                        router.apply(redirect)
                    case .rejected:
                        // Mirror the Expo Router backstop: rejected links land on
                        // the Account tab so the failure reason stays visible.
                        router.popToRoot(tab: .account)
                    case .notHandled:
                        break
                    }
                }
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var router: Router

    var body: some View {
        NavigationStack(path: $router.path) {
            MainTabsView()
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(for: Route.self) { route in
                    destination(for: route)
                        .toolbar(.hidden, for: .navigationBar)
                }
        }
        .tint(Theme.inkBlack)
        .sheet(isPresented: $router.cartPresented) {
            CartView()
        }
        .preferredColorScheme(.light)
    }

    @ViewBuilder
    private func destination(for route: Route) -> some View {
        switch route {
        case .product(let id):
            ProductDetailView(productID: id)
        case .order(let id):
            OrderDetailView(orderID: id)
        case .checkout:
            CheckoutView()
        case .confirmation:
            ConfirmationView()
        }
    }
}

struct MainTabsView: View {
    @EnvironmentObject private var router: Router

    var body: some View {
        VStack(spacing: 0) {
            // Keep all tabs alive so per-tab state (search query, expanded
            // category) survives tab switches, matching the original app.
            ZStack {
                ShopView().opacity(router.tab == .shop ? 1 : 0)
                    .allowsHitTesting(router.tab == .shop)
                SearchView().opacity(router.tab == .search ? 1 : 0)
                    .allowsHitTesting(router.tab == .search)
                SpecimensView().opacity(router.tab == .specimens ? 1 : 0)
                    .allowsHitTesting(router.tab == .specimens)
                AccountView().opacity(router.tab == .account ? 1 : 0)
                    .allowsHitTesting(router.tab == .account)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            TabBarView(selected: $router.tab)
        }
        .background(Theme.paperWhite)
    }
}

struct TabBarView: View {
    @Binding var selected: Tab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button {
                    selected = tab
                } label: {
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(selected == tab ? Theme.stickerGreen : Color(hex: 0xEEEEEE))
                            .frame(width: 24, height: 24)
                        Text(tab.rawValue)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(selected == tab ? Theme.inkBlack : Theme.gray)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("tab-\(tab.rawValue.lowercased())")
            }
        }
        .padding(.top, 8)
        .padding(.horizontal, 8)
        .padding(.bottom, 20)
        .background(Theme.paperWhite)
        .overlay(alignment: .top) {
            Rectangle().fill(Color.black.opacity(0.1)).frame(height: 1)
        }
    }
}
