import SwiftUI

struct QuestNode: Identifiable {
    enum Status { case locked, current, completed }

    let id = UUID()
    let title: String
    let reward: Int
    let status: Status
}

struct QuestMapView: View {
    @State private var nodes: [QuestNode] = [
        QuestNode(title: "Warm-up", reward: 10, status: .completed),
        QuestNode(title: "Puzzle Peak", reward: 12, status: .completed),
        QuestNode(title: "Logic Lake", reward: 15, status: .current),
        QuestNode(title: "Galaxy Gate", reward: 18, status: .locked),
        QuestNode(title: "Victory Vault", reward: 25, status: .locked)
    ]
    @State private var selectedNode: QuestNode?

    var body: some View {
        ZStack {
            LinearGradient.cqSoftAdventure
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("Adventure Map")
                    .font(.cqTitle2)
                    .foregroundStyle(CQTheme.textPrimary)
                    .padding(.top, 24)

                Text("Follow the winding path and claim your rewards.")
                    .font(.cqBody2)
                    .foregroundStyle(CQTheme.textSecondary)
                    .padding(.horizontal, 32)
                    .multilineTextAlignment(.center)

                GeometryReader { geometry in
                    ZStack {
                        mapPath(in: geometry.size)
                        questNodes(in: geometry.size)
                    }
                }
                .padding(20)

                Spacer(minLength: 32)
            }
        }
        .sheet(item: $selectedNode) { node in
            QuestDetailSheet(node: node)
                .presentationDetents([.medium])
        }
    }

    private func mapPath(in size: CGSize) -> some View {
        let pathPoints: [CGPoint] = [
            CGPoint(x: size.width * 0.1, y: size.height * 0.85),
            CGPoint(x: size.width * 0.3, y: size.height * 0.6),
            CGPoint(x: size.width * 0.55, y: size.height * 0.75),
            CGPoint(x: size.width * 0.8, y: size.height * 0.45),
            CGPoint(x: size.width * 0.5, y: size.height * 0.25)
        ]

        return Path { path in
            guard let first = pathPoints.first else { return }
            path.move(to: first)
            for point in pathPoints.dropFirst() {
                path.addQuadCurve(to: point, control: CGPoint(x: (point.x + first.x) / 2, y: point.y - 60))
            }
        }
        .stroke(style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round))
        .fill(Color(.tertiarySystemFill))
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 6)
    }

    private func questNodes(in size: CGSize) -> some View {
        let points: [CGPoint] = [
            CGPoint(x: size.width * 0.1, y: size.height * 0.85),
            CGPoint(x: size.width * 0.3, y: size.height * 0.6),
            CGPoint(x: size.width * 0.55, y: size.height * 0.75),
            CGPoint(x: size.width * 0.8, y: size.height * 0.45),
            CGPoint(x: size.width * 0.5, y: size.height * 0.25)
        ]

        return ForEach(Array(zip(nodes.indices, points)), id: \.0) { index, point in
            let node = nodes[index]
            Button {
                if node.status != .locked {
                    selectedNode = node
                }
            } label: {
                VStack(spacing: 6) {
                    Image(systemName: symbol(for: node.status))
                        .font(.title2)
                        .foregroundStyle(color(for: node.status))
                        .padding(16)
                        .background(
                            Circle()
                                .fill(CQTheme.cardBackground)
                                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
                        )
                        .overlay(
                            Circle()
                                .stroke(color(for: node.status), lineWidth: node.status == .current ? 4 : 2)
                                .shadow(color: node.status == .completed ? CQTheme.yellowAccent.opacity(0.6) : .clear, radius: 12)
                        )

                    Text(node.title)
                        .font(.cqCaption)
                        .foregroundStyle(CQTheme.textPrimary)
                }
                .scaleEffect(node.status == .current ? 1.05 : 1)
            }
            .buttonStyle(.plain)
            .position(point)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: node.status)
        }
    }

    private func symbol(for status: QuestNode.Status) -> String {
        switch status {
        case .locked: return "lock.fill"
        case .current: return "flag.fill"
        case .completed: return "star.fill"
        }
    }

    private func color(for status: QuestNode.Status) -> Color {
        switch status {
        case .locked: return CQTheme.textSecondary
        case .current: return CQTheme.bluePrimary
        case .completed: return CQTheme.yellowAccent
        }
    }
}

private struct QuestDetailSheet: View {
    let node: QuestNode

    var body: some View {
        VStack(spacing: 16) {
            Capsule()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 40, height: 4)
                .padding(.top, 12)

            Text(node.title)
                .font(.cqTitle2)
                .foregroundStyle(CQTheme.textPrimary)

            Text("Reward: ⭐️ \(node.reward)")
                .font(.cqBody1)
                .foregroundStyle(CQTheme.yellowAccent)

            Text(detail(for: node.status))
                .font(.cqBody2)
                .foregroundStyle(CQTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Spacer()
        }
        .padding(.bottom, 32)
        .background(CQTheme.cardBackground)
    }

    private func detail(for status: QuestNode.Status) -> String {
        switch status {
        case .locked:
            return "This quest unlocks after you finish the previous stop. Keep going!"
        case .current:
            return "Ready to play! Tap start from the Learn tab to dive in."
        case .completed:
            return "Amazing job! You've collected this reward already."
        }
    }
}

#Preview {
    QuestMapView()
}
