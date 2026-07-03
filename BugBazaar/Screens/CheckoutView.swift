import SwiftUI

struct CheckoutView: View {
    private enum Step: Int {
        case shipping = 1
        case payment = 2
        case review = 3
    }

    @EnvironmentObject private var cart: CartStore
    @EnvironmentObject private var router: Router

    @State private var step: Step = .shipping
    @State private var name = ""
    @State private var address = ""
    @State private var city = ""
    @State private var zip = ""
    @State private var cardNumber = ""
    @State private var expiry = ""
    @State private var cvv = ""
    @State private var cardName = ""
    @State private var processing = false

    private var shippingCost: Double { cart.totalPrice > 50 ? 0 : 5.99 }
    private var tax: Double { cart.totalPrice * 0.08 }
    private var grandTotal: Double { cart.totalPrice + shippingCost + tax }

    // BUG: When Goliath Beetle is in cart, button total excludes tax
    private var hasGoliath: Bool { cart.items.contains { $0.id == 8 } }
    private var buttonTotal: Double { hasGoliath ? cart.totalPrice + shippingCost : grandTotal }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                BackCircleButton {
                    switch step {
                    case .shipping: router.pop()
                    case .payment: step = .shipping
                    case .review: step = .payment
                    }
                }
                Spacer()
                Text("Checkout")
                    .font(.display(18))
                    .foregroundColor(Theme.inkBlack)
                Spacer()
                Text("\(step.rawValue)/3")
                    .font(.bodyFont(12, bold: true))
                    .foregroundColor(Theme.gray)
                    .frame(width: 32)
            }
            .padding(.horizontal, Spacing.m)
            .padding(.vertical, Spacing.m)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2).fill(Theme.lightGray)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Theme.stickerGreen)
                        .frame(width: geo.size.width * CGFloat(step.rawValue) / 3)
                }
            }
            .frame(height: 3)
            .padding(.horizontal, Spacing.m)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    switch step {
                    case .shipping: shippingForm
                    case .payment: paymentForm
                    case .review: reviewSection
                    }
                }
                .padding(Spacing.m)
                .padding(.bottom, 100)
            }

            footer
        }
        .background(Theme.paperWhite)
    }

    // MARK: Steps

    private var shippingForm: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionTitle("SHIPPING ADDRESS")
            formField("Full Name", placeholder: "Bug Collector", text: $name)
            formField("Street Address", placeholder: "123 Entomology Lane", text: $address)
            HStack(alignment: .top, spacing: Spacing.m) {
                formField("City", placeholder: "Bugville", text: $city)
                    .frame(maxWidth: .infinity)
                formField("ZIP", placeholder: "90210", text: $zip, keyboard: .numberPad)
                    .frame(width: 110)
            }
            fillButton("📍", "Use saved address") {
                name = "Bug Collector"
                address = "123 Entomology Lane"
                city = "Bugville"
                zip = "90210"
            }
        }
    }

    private var paymentForm: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionTitle("PAYMENT METHOD")
            formField("Card Number", placeholder: "4242 4242 4242 4242", text: $cardNumber, keyboard: .numberPad)
            HStack(alignment: .top, spacing: Spacing.m) {
                formField("Expiry", placeholder: "12/28", text: $expiry, keyboard: .numberPad)
                formField("CVV", placeholder: "123", text: $cvv, keyboard: .numberPad, secure: true)
            }
            formField("Name on Card", placeholder: "BUG COLLECTOR", text: $cardName)
            fillButton("💳", "Use demo card") {
                cardNumber = "4242 4242 4242 4242"
                expiry = "12/28"
                cvv = "123"
                cardName = "BUG COLLECTOR"
            }
        }
    }

    private var reviewSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionTitle("ORDER REVIEW")

            ForEach(cart.items) { item in
                HStack(spacing: 12) {
                    EmojiView(emoji: item.product.emoji, size: 28)
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

            VStack(alignment: .leading, spacing: 2) {
                reviewSectionTitle("SHIPPING TO")
                Text(name.isEmpty ? "Bug Collector" : name)
                Text(address.isEmpty ? "123 Entomology Lane" : address)
                Text("\(city.isEmpty ? "Bugville" : city), \(zip.isEmpty ? "90210" : zip)")
            }
            .font(.system(size: 14))
            .foregroundColor(Theme.inkBlack)
            .padding(.top, Spacing.l)
            .padding(.bottom, Spacing.m)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(alignment: .bottom) {
                Rectangle().fill(Theme.hairline).frame(height: 1)
            }

            VStack(alignment: .leading, spacing: 2) {
                reviewSectionTitle("PAYMENT")
                Text("•••• •••• •••• \(String((cardNumber.isEmpty ? "4242" : cardNumber).suffix(4)))")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.inkBlack)
            }
            .padding(.top, Spacing.l)
            .padding(.bottom, Spacing.m)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(alignment: .bottom) {
                Rectangle().fill(Theme.hairline).frame(height: 1)
            }

            VStack(spacing: 6) {
                totalRow("Subtotal", cart.totalPrice.usd)
                totalRow("Shipping", shippingCost == 0 ? "FREE" : shippingCost.usd,
                         valueColor: shippingCost == 0 ? Theme.stickerGreen : Theme.inkBlack)
                totalRow("Tax", tax.usd)
                Rectangle()
                    .fill(Color.black.opacity(0.1))
                    .frame(height: 1)
                    .padding(.vertical, 4)
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
            .background(RoundedRectangle(cornerRadius: 14).fill(Theme.cardBg))
            .padding(.top, Spacing.l)
        }
    }

    private var footer: some View {
        VStack {
            Button {
                switch step {
                case .shipping:
                    step = .payment
                case .payment:
                    step = .review
                case .review:
                    placeOrder()
                }
            } label: {
                Text(footerLabel)
                    .font(.bodyFont(14, bold: true))
                    .foregroundColor(Theme.stickerGreen)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Capsule().fill(processing ? Theme.gray : Theme.inkBlack))
            }
            .buttonStyle(.plain)
            .disabled(processing)
            .accessibilityIdentifier("checkout-footer-button")
        }
        .padding(Spacing.m)
        .background(Theme.paperWhite)
        .overlay(alignment: .top) {
            Rectangle().fill(Theme.hairline).frame(height: 1)
        }
    }

    private var footerLabel: String {
        switch step {
        case .shipping: return "CONTINUE TO PAYMENT"
        case .payment: return "REVIEW ORDER"
        case .review: return processing ? "PROCESSING..." : "PLACE ORDER · \(buttonTotal.usd)"
        }
    }

    private func placeOrder() {
        processing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            cart.completeOrder()
            router.replaceTop(with: .confirmation)
        }
    }

    // MARK: Form helpers

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.bodyFont(11, bold: true))
            .kerning(1.5)
            .foregroundColor(Theme.gray)
            .padding(.top, Spacing.s)
            .padding(.bottom, Spacing.m)
    }

    private func reviewSectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.bodyFont(10, bold: true))
            .kerning(1.5)
            .foregroundColor(Theme.gray)
            .padding(.bottom, 6)
    }

    private func formField(
        _ label: String,
        placeholder: String,
        text: Binding<String>,
        keyboard: UIKeyboardType = .default,
        secure: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.bodyFont(12, bold: true))
                .kerning(0.5)
                .foregroundColor(Theme.priceGray)
            Group {
                if secure {
                    SecureField(placeholder, text: text)
                } else {
                    TextField(placeholder, text: text)
                }
            }
            .font(.bodyFont(15))
            .foregroundColor(Theme.inkBlack)
            .keyboardType(keyboard)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(RoundedRectangle(cornerRadius: 10).fill(Theme.lightGray))
            .accessibilityIdentifier("field-\(label.lowercased().replacingOccurrences(of: " ", with: "-"))")
        }
        .padding(.bottom, Spacing.m)
    }

    private func fillButton(_ emoji: String, _ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                EmojiView(emoji: emoji, size: 13)
                Text(label)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Theme.inkBlack)
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 10).fill(Theme.cardBg))
        }
        .buttonStyle(.plain)
        .padding(.top, Spacing.s)
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
