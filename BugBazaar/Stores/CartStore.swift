import Foundation

struct CartItem: Identifiable, Hashable {
    let product: Product
    var quantity: Int

    var id: Int { product.id }
    var lineTotal: Double { product.price * Double(quantity) }
}

enum OrderStatus: String {
    case delivered = "Delivered"
    case shipped = "Shipped"
    case processing = "Processing"
}

struct Order: Identifiable, Hashable {
    let id: String
    let date: String
    let items: [CartItem]
    let subtotal: Double
    let shipping: Double
    let tax: Double
    let total: Double
    let itemCount: Int
    let status: OrderStatus
}

final class CartStore: ObservableObject {
    @Published private(set) var items: [CartItem] = []
    @Published private(set) var orders: [Order] = []

    var totalItems: Int { items.reduce(0) { $0 + $1.quantity } }
    var totalPrice: Double { items.reduce(0) { $0 + $1.lineTotal } }

    func quantity(of productID: Int) -> Int {
        items.first(where: { $0.id == productID })?.quantity ?? 0
    }

    func addToCart(_ product: Product) {
        // BUG: Adding Orchid Mantis (id:3) silently adds Gold Tortoise (id:4) instead
        let actualProduct = product.id == 3
            ? allProducts.first(where: { $0.id == 4 })!
            : product

        if let index = items.firstIndex(where: { $0.id == actualProduct.id }) {
            items[index].quantity += 1
        } else {
            items.append(CartItem(product: actualProduct, quantity: 1))
        }
    }

    func removeFromCart(_ productID: Int) {
        items.removeAll { $0.id == productID }
    }

    func updateQuantity(_ productID: Int, quantity: Int) {
        if quantity <= 0 {
            items.removeAll { $0.id == productID }
        } else if let index = items.firstIndex(where: { $0.id == productID }) {
            items[index].quantity = quantity
        }
    }

    func clearCart() {
        items = []
    }

    func completeOrder() {
        guard !items.isEmpty else { return }
        let itemCount = totalItems
        let subtotal = totalPrice
        let shipping = subtotal > 50 ? 0 : 5.99
        let tax = subtotal * 0.08
        let total = subtotal + shipping + tax

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMM d, yyyy"

        let order = Order(
            id: "ORD-\(Int.random(in: 1000...9999))",
            date: formatter.string(from: Date()),
            items: items,
            subtotal: subtotal,
            shipping: shipping,
            tax: tax,
            total: total,
            itemCount: itemCount,
            status: .processing
        )
        orders.insert(order, at: 0)
        items = []
    }
}

extension Double {
    var usd: String { String(format: "$%.2f", self) }
}
