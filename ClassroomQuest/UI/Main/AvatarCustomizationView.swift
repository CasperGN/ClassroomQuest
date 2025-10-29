import SwiftUI

enum AvatarCategory: String, CaseIterable {
    case clothes = "Clothes"
    case hats = "Hats"
    case pets = "Pets"
}

struct AvatarCustomizationView: View {

    let starBalance: Int
    @State private var selectedCategory: AvatarCategory = .clothes
    @State private var equippedItems: Set<String> = []
    @State private var avatarBounce = false

    private var items: [AvatarItem] {
        AvatarItem.sample.filter { $0.category == selectedCategory }
    }

    var body: some View {
        ZStack {
            CQTheme.background.ignoresSafeArea()

            VStack(spacing: 24) {
                avatarCanvas

                categoryTabs

                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
                        ForEach(items) { item in
                            AvatarItemTile(
                                item: item,
                                isEquipped: equippedItems.contains(item.id)
                            ) {
                                toggleEquip(item)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
                .safeAreaInset(edge: .bottom) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundStyle(CQTheme.yellowAccent)
                        Text("\(starBalance) Stars")
                            .font(.cqBody2)
                            .foregroundStyle(CQTheme.textPrimary)
                        Spacer()
                        Button(action: {}) {
                            Text("Buy / Equip")
                                .font(.cqCaption)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(CQTheme.bluePrimary.opacity(0.2))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                    .background(.ultraThinMaterial)
                    .cornerRadius(24)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
            .padding(.top, 16)
        }
    }

    private var avatarCanvas: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(CQTheme.cardBackground)
                    .frame(width: 260, height: 260)
                    .shadow(color: Color.black.opacity(0.08), radius: 24, x: 0, y: 18)
                Text(avatarBounce ? "😄" : "😊")
                    .font(.system(size: 120))
                    .scaleEffect(avatarBounce ? 1.05 : 1)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: avatarBounce)
                    .onAppear { avatarBounce = true }
            }
            Text("Tap items to equip your adventurer!")
                .font(.cqBody2)
                .foregroundStyle(CQTheme.textSecondary)
        }
    }

    private var categoryTabs: some View {
        HStack(spacing: 12) {
            ForEach(AvatarCategory.allCases, id: \.self) { category in
                Button {
                    selectedCategory = category
                } label: {
                    Text(category.rawValue)
                        .font(.cqCaption)
                        .foregroundStyle(selectedCategory == category ? CQTheme.cardBackground : CQTheme.textSecondary)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(
                            Capsule()
                                .fill(selectedCategory == category ? CQTheme.bluePrimary : CQTheme.cardBackground)
                        )
                        .shadow(color: selectedCategory == category ? CQTheme.bluePrimary.opacity(0.2) : .clear, radius: 10, x: 0, y: 6)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
    }

    private func toggleEquip(_ item: AvatarItem) {
        if equippedItems.contains(item.id) {
            equippedItems.remove(item.id)
        } else {
            equippedItems.insert(item.id)
        }
    }
}

private struct AvatarItem: Identifiable {
    let id: String
    let name: String
    let emoji: String
    let cost: Int
    let category: AvatarCategory

    static let sample: [AvatarItem] = [
        AvatarItem(id: "cape", name: "Hero Cape", emoji: "🦸‍♀️", cost: 25, category: .clothes),
        AvatarItem(id: "rainbow", name: "Rainbow Tee", emoji: "🌈", cost: 18, category: .clothes),
        AvatarItem(id: "astronaut", name: "Space Suit", emoji: "🧑‍🚀", cost: 35, category: .clothes),
        AvatarItem(id: "topHat", name: "Top Hat", emoji: "🎩", cost: 20, category: .hats),
        AvatarItem(id: "crown", name: "Royal Crown", emoji: "👑", cost: 40, category: .hats),
        AvatarItem(id: "beanie", name: "Beanie", emoji: "🧢", cost: 15, category: .hats),
        AvatarItem(id: "panda", name: "Panda Pal", emoji: "🐼", cost: 30, category: .pets),
        AvatarItem(id: "dragon", name: "Baby Dragon", emoji: "🐉", cost: 45, category: .pets),
        AvatarItem(id: "kitty", name: "Playful Kitty", emoji: "🐱", cost: 22, category: .pets)
    ]
}

private struct AvatarItemTile: View {
    let item: AvatarItem
    let isEquipped: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Text(item.emoji)
                    .font(.system(size: 48))
                Text(item.name)
                    .font(.cqCaption)
                    .foregroundStyle(CQTheme.textPrimary)
                    .multilineTextAlignment(.center)
                Text("⭐️ \(item.cost)")
                    .font(.cqCaption)
                    .foregroundStyle(CQTheme.textSecondary)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(isEquipped ? CQTheme.bluePrimary.opacity(0.2) : CQTheme.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(isEquipped ? CQTheme.bluePrimary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AvatarCustomizationView(starBalance: 120)
}
