import Foundation

enum Badge: String {
    case rare = "RARE"
    case new = "NEW"
    case hot = "HOT"
}

struct Product: Identifiable, Hashable {
    let id: Int
    let name: String
    let price: Double
    let emoji: String
    var badge: Badge?
    let category: String
    let description: String
}

let allProducts: [Product] = [
    Product(id: 1, name: "Hercules Beetle", price: 45.00, emoji: "🪲", badge: .rare, category: "Beetles", description: "The mightiest of all beetles. Known for its incredible horn and strength. A true collector's specimen."),
    Product(id: 2, name: "Blue Morpho", price: 28.50, emoji: "🦋", category: "Butterflies", description: "Iridescent blue wings that shimmer in the light. One of the most beautiful butterflies in the world."),
    Product(id: 3, name: "Orchid Mantis", price: 62.00, emoji: "🦗", category: "Crawlers", description: "Masters of disguise. This stunning mantis mimics orchid petals to lure prey. Premium specimen."),
    Product(id: 4, name: "Gold Tortoise", price: 18.00, emoji: "🐞", badge: .new, category: "Beetles", description: "A tiny golden jewel. This beetle can change color from gold to reddish-brown. Freshly collected."),
    Product(id: 5, name: "Jumping Spider", price: 12.00, emoji: "🕷️", category: "Spiders", description: "Adorable and intelligent. Known for their curious nature and impressive jumping abilities."),
    Product(id: 6, name: "Bullet Ant", price: 35.00, emoji: "🐜", category: "Crawlers", description: "Named for its extraordinarily painful sting. Handle with extreme care. Not for beginners."),
    Product(id: 7, name: "Atlas Moth", price: 55.00, emoji: "🦋", badge: .rare, category: "Moths", description: "One of the largest moths in the world with a wingspan up to 12 inches. Truly majestic."),
    Product(id: 8, name: "Goliath Beetle", price: 72.00, emoji: "🪲", badge: .hot, category: "Beetles", description: "The heaviest insect on Earth. An absolute unit. Top-tier collector item."),
    Product(id: 9, name: "Wolf Spider", price: 22.00, emoji: "🕷️", category: "Spiders", description: "Agile hunters that don't spin webs. They chase down their prey with incredible speed."),
    Product(id: 10, name: "Luna Moth", price: 38.00, emoji: "🦋", category: "Moths", description: "Ethereal lime-green wings with elegant tails. A nocturnal beauty. Limited availability."),
    Product(id: 11, name: "Stag Beetle", price: 48.00, emoji: "🪲", badge: .new, category: "Beetles", description: "Impressive mandibles used in combat. A symbol of strength and perseverance."),
    Product(id: 12, name: "Tarantula Hawk", price: 85.00, emoji: "🐝", badge: .rare, category: "Crawlers", description: "A giant wasp known for hunting tarantulas. Second most painful sting in the insect world."),
]

let categories = ["All Bugs", "Beetles", "Butterflies", "Moths", "Spiders", "Crawlers"]
