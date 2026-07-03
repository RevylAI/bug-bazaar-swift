import SwiftUI

struct HalftoneOverlay: View {
    var dotSize: CGFloat = 0.8
    var spacing: CGFloat = 4
    var opacity: Double = 0.1

    var body: some View {
        Canvas { context, size in
            let dot = Color.black.opacity(opacity)
            var y = spacing / 2
            while y < size.height {
                var x = spacing / 2
                while x < size.width {
                    let rect = CGRect(
                        x: x - dotSize, y: y - dotSize,
                        width: dotSize * 2, height: dotSize * 2
                    )
                    context.fill(Path(ellipseIn: rect), with: .color(dot))
                    x += spacing
                }
                y += spacing
            }
        }
        .allowsHitTesting(false)
    }
}
