import SwiftUI

enum Tab: String, CaseIterable {
    case shop = "Shop"
    case search = "Search"
    case specimens = "Specimens"
    case account = "Account"
}

enum Route: Hashable {
    case product(Int)
    case order(String)
    case checkout
    case confirmation
}

final class Router: ObservableObject {
    @Published var tab: Tab = .shop
    @Published var path: [Route] = []
    @Published var cartPresented = false

    func push(_ route: Route) {
        path.append(route)
    }

    func pop() {
        if !path.isEmpty { path.removeLast() }
    }

    func replaceTop(with route: Route) {
        if path.isEmpty {
            path = [route]
        } else {
            path[path.count - 1] = route
        }
    }

    func popToRoot(tab: Tab) {
        path = []
        cartPresented = false
        self.tab = tab
    }

    func apply(_ redirect: AuthBypassRedirect) {
        cartPresented = false
        switch redirect {
        case .shop:
            path = []
            tab = .shop
        case .account:
            path = []
            tab = .account
        case .cart:
            path = []
            cartPresented = true
        case .checkout:
            path = [.checkout]
        case .productThree:
            path = [.product(3)]
        }
    }
}
