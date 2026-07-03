import SwiftUI

struct HeroBanner: View {
    var body: some View {
        VStack(spacing: Spacing.s) {
            Text("Rare Species\nCollection")
                .font(.display(32))
                .multilineTextAlignment(.center)
                .foregroundColor(Theme.inkBlack)
                .rotationEffect(.degrees(-2))
            Text("SUPERIOR SPECIMENS")
                .font(.display(14))
                .kerning(1)
                .foregroundColor(Theme.inkBlack)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.l)
        .background(
            ZStack {
                UnevenRoundedRectangle(
                    topLeadingRadius: 20,
                    bottomLeadingRadius: 24,
                    bottomTrailingRadius: 28,
                    topTrailingRadius: 24
                )
                .fill(Theme.mangoOrange)
                HalftoneOverlay(dotSize: 1, spacing: 4, opacity: 0.12)
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 20,
                            bottomLeadingRadius: 24,
                            bottomTrailingRadius: 28,
                            topTrailingRadius: 24
                        )
                    )
            }
        )
        .shadow(color: Theme.stickerGreen.opacity(0.2), radius: 12, x: 0, y: 4)
        .padding(Spacing.m)
    }
}
