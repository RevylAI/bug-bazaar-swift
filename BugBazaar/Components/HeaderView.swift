import SwiftUI

struct HeaderView: View {
    @EnvironmentObject private var cart: CartStore
    @EnvironmentObject private var router: Router

    var body: some View {
        HStack {
            Text("BUG BAZAAR")
                .font(.display(20))
                .kerning(-0.5)
                .foregroundColor(Theme.inkBlack)
            Spacer()
            Button {
                router.cartPresented = true
            } label: {
                ZStack {
                    Circle()
                        .fill(Theme.stickerGreen)
                        .frame(width: 32, height: 32)
                    Image(systemName: "bag")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.inkBlack)
                }
                .overlay(alignment: .topTrailing) {
                    if cart.totalItems > 0 {
                        Text("\(cart.totalItems)")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 16, height: 16)
                            .background(Circle().fill(Theme.mangoOrange))
                            .overlay(Circle().stroke(Theme.paperWhite, lineWidth: 2))
                            .offset(x: 4, y: -4)
                    }
                }
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("cart-button")
        }
        .padding(.horizontal, Spacing.m)
        .padding(.vertical, Spacing.m)
        .background(Theme.paperWhite.opacity(0.95))
        .overlay(alignment: .bottom) {
            Rectangle().fill(Theme.hairline).frame(height: 1)
        }
    }
}

/// The circular "←" / "✕" back button used across detail screens.
struct BackCircleButton: View {
    var glyph: String = "←"
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(glyph)
                .font(.system(size: glyph == "✕" ? 16 : 18, weight: .bold))
                .foregroundColor(Theme.inkBlack)
                .frame(width: 32, height: 32)
                .background(Circle().fill(Theme.lightGray))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("back-button")
    }
}
