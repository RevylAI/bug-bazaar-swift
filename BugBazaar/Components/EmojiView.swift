import SwiftUI

// Twemoji images bundled locally, matching the original app (which uses them
// to work around iOS 26 Fabric emoji fallback issues). License: CC-BY 4.0.
private let emojiAssets: [String: String] = [
    "🪲": "emoji-beetle",
    "🦋": "emoji-butterfly",
    "🦗": "emoji-cricket",
    "🐞": "emoji-ladybug",
    "🕷️": "emoji-spider",
    "🐜": "emoji-ant",
    "🐝": "emoji-bee",
    "🐛": "emoji-caterpillar",
    "🔍": "emoji-magnifying-glass",
    "🛒": "emoji-shopping-cart",
    "📦": "emoji-package",
    "📍": "emoji-pin",
    "💳": "emoji-credit-card",
    "🔔": "emoji-bell",
    "❓": "emoji-question",
    "✏️": "emoji-pencil",
    "📧": "emoji-email",
]

struct EmojiView: View {
    let emoji: String
    let size: CGFloat

    var body: some View {
        Image(emojiAssets[emoji] ?? "emoji-question")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
    }
}
