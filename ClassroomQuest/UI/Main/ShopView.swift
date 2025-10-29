import SwiftUI

struct ShopCategory: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    let items: [ShopItem]
}

struct ShopItem: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
    let cost: Int
}

struct ShopView: View {
    let starBalance: Int
    let onSpend: (ShopItem) -> Void

    @State private var selectedCategoryIndex: Int = 0

    private var categories: [ShopCategory] {
        [
            ShopCategory(
                name: "Clothing",
                icon: "🧥",
                color: CQTheme.bluePrimary,
                items: [
                    ShopItem(name: "Explorer Jacket", emoji: "🧥", cost: 28),
                    ShopItem(name: "Mystic Robe", emoji: "🧙", cost: 32),
                    ShopItem(name: "Rainbow Sneakers", emoji: "👟", cost: 20)
                ]
            ),
            ShopCategory(
                name: "Furniture",
                icon: "🪑",
                color: CQTheme.greenSecondary,
                items: [
                    ShopItem(name: "Story Chair", emoji: "🪑", cost: 18),
                    ShopItem(name: "Comfy Beanbag", emoji: "🛋️", cost: 22),
                    ShopItem(name: "Reading Lamp", emoji: "💡", cost: 14)
                ]
            ),
            ShopCategory(
                name: "Decor",
                icon: "🖼️",
                color: CQTheme.purpleLanguage,
                items: [
                    ShopItem(name: "Star Garland", emoji: "✨", cost: 12),
                    ShopItem(name: "World Map", emoji: "🗺️", cost: 16),
                    ShopItem(name: "Plant Buddy", emoji: "🪴", cost: 10)
                ]
            ),
            ShopCategory(
                name: "Pets",
                icon: "🐾",
                color: CQTheme.goldReligious,
                items: [
                    ShopItem(name: "Singing Bird", emoji: "🐦", cost: 30),
                    ShopItem(name: "Mini Llama", emoji: "🦙", cost: 35),
                    ShopItem(name: "Shiny Fish", emoji: "🐠", cost: 18)
                ]
            )
        ]
    }

    var body: some View {
        ZStack {
            LinearGradient.cqSoftAdventure
                .ignoresSafeArea()

            VStack(spacing: 24) {
                header
                categoryCarousel
                itemGrid
            }
            .padding(.top, 24)
            .padding(.bottom, 16)
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Market Plaza")
                    .font(.cqTitle2)
                    .foregroundStyle(CQTheme.textPrimary)
                Text("Trade your stars for joyful loot!")
                    .font(.cqBody2)
                    .foregroundStyle(CQTheme.textSecondary)
            }
            Spacer()
            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .foregroundStyle(CQTheme.yellowAccent)
                Text("\(starBalance)")
                    .font(.cqBody1)
                    .foregroundStyle(CQTheme.textPrimary)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .background(CQTheme.cardBackground)
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
        }
        .padding(.horizontal, 20)
    }

    private var categoryCarousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(Array(categories.enumerated()), id: \.offset) { index, category in
                    Button {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            selectedCategoryIndex = index
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(category.icon)
                                .font(.system(size: 36))
                            Text(category.name)
                                .font(.cqBody1)
                                .foregroundStyle(CQTheme.cardBackground)
                        }
                        .padding(20)
                        .frame(width: 160, height: 120, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(category.color)
                                .shadow(color: category.color.opacity(0.3), radius: 18, x: 0, y: 12)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(index == selectedCategoryIndex ? Color.white.opacity(0.8) : Color.clear, lineWidth: 3)
                        )
                        .scaleEffect(index == selectedCategoryIndex ? 1.05 : 1.0)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private var itemGrid: some View {
        let selectedItems = categories[selectedCategoryIndex].items
        return ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                ForEach(selectedItems) { item in
                    VStack(spacing: 12) {
                        Text(item.emoji)
                            .font(.system(size: 44))
                        Text(item.name)
                            .font(.cqBody2)
                            .foregroundStyle(CQTheme.textPrimary)
                            .multilineTextAlignment(.center)
                        Text("⭐️ \(item.cost)")
                            .font(.cqCaption)
                            .foregroundStyle(CQTheme.textSecondary)
                        Button {
                            onSpend(item)
                        } label: {
                            Text("Purchase")
                                .font(.cqCaption)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(CQTheme.bluePrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(CQTheme.cardBackground.opacity(0.95))
                            .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 8)
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }
}

#Preview {
    ShopView(starBalance: 120) { _ in }
}
