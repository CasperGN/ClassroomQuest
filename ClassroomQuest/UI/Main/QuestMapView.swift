import SwiftUI

struct QuestNode: Identifiable {
    enum Status { case locked, available, completed }

    let id = UUID()
    let module: CurriculumModule
    let status: Status
}

struct QuestMapView: View {
    private let course = CurriculumCatalog.grade2
    @State private var selectedModule: CurriculumModule?

    private var nodes: [QuestNode] {
        course.modules.enumerated().map { index, module in
            let status: QuestNode.Status
            switch index {
            case 0:
                status = .completed
            case 1:
                status = .available
            default:
                status = .locked
            }
            return QuestNode(module: module, status: status)
        }
    }

    var body: some View {
        ZStack {
            LinearGradient.cqSoftAdventure
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    mapSection
                    courseSummaryCard
                    moduleList
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 20)
            }
        }
        .sheet(item: $selectedModule) { module in
            ModuleDetailSheet(course: course, module: module)
                .presentationDetents([.medium, .large])
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(course.heroTitle)
                .font(.cqTitle2)
                .foregroundStyle(CQTheme.textPrimary)
            Text(course.overview)
                .font(.cqBody2)
                .foregroundStyle(CQTheme.textSecondary)
        }
    }

    private var mapSection: some View {
        VStack(spacing: 16) {
            Text("Quest Path")
                .font(.cqHeadline)
                .foregroundStyle(CQTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            ZStack {
                GeometryReader { geometry in
                    ZStack {
                        mapPath(in: geometry.size, count: nodes.count)
                        questNodes(in: geometry.size)
                    }
                }
                .frame(height: 320)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(CQTheme.cardBackground.opacity(0.92))
                    .shadow(color: Color.black.opacity(0.1), radius: 16, x: 0, y: 12)
            )
        }
    }

    private func mapPath(in size: CGSize, count: Int) -> some View {
        let templatePoints: [CGPoint] = [
            CGPoint(x: size.width * 0.12, y: size.height * 0.85),
            CGPoint(x: size.width * 0.32, y: size.height * 0.6),
            CGPoint(x: size.width * 0.58, y: size.height * 0.75),
            CGPoint(x: size.width * 0.82, y: size.height * 0.45),
            CGPoint(x: size.width * 0.58, y: size.height * 0.18)
        ]
        let points = Array(templatePoints.prefix(max(2, min(count, templatePoints.count))))

        return Path { path in
            guard let first = points.first else { return }
            path.move(to: first)
            for (index, point) in points.dropFirst().enumerated() {
                let previous = points[index]
                let control = CGPoint(x: (point.x + previous.x) / 2, y: point.y - 60)
                path.addQuadCurve(to: point, control: control)
            }
        }
        .stroke(style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round))
        .fill(Color(.tertiarySystemFill))
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
    }

    private func questNodes(in size: CGSize) -> some View {
        let templatePoints: [CGPoint] = [
            CGPoint(x: size.width * 0.12, y: size.height * 0.85),
            CGPoint(x: size.width * 0.32, y: size.height * 0.6),
            CGPoint(x: size.width * 0.58, y: size.height * 0.75),
            CGPoint(x: size.width * 0.82, y: size.height * 0.45),
            CGPoint(x: size.width * 0.58, y: size.height * 0.18)
        ]
        let points = Array(templatePoints.prefix(nodes.count))

        return ForEach(Array(zip(nodes, points)), id: \.0.id) { node, point in
            Button {
                if node.status != .locked {
                    selectedModule = node.module
                }
            } label: {
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(CQTheme.cardBackground)
                            .frame(width: 70, height: 70)
                            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)

                        Image(systemName: node.module.subject.systemImageName)
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(iconColor(for: node))

                        if node.status == .locked {
                            Circle()
                                .strokeBorder(CQTheme.textSecondary.opacity(0.4), lineWidth: 2)
                            Image(systemName: "lock.fill")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(CQTheme.textSecondary.opacity(0.8))
                        }
                    }
                    .overlay(
                        Circle()
                            .stroke(borderColor(for: node), lineWidth: borderWidth(for: node))
                    )

                    Text(node.module.title)
                        .font(.cqCaption)
                        .foregroundStyle(CQTheme.textPrimary)
                        .multilineTextAlignment(.center)
                        .frame(width: 110)
                }
                .scaleEffect(node.status == .available ? 1.05 : 1)
            }
            .buttonStyle(.plain)
            .position(point)
            .animation(.spring(response: 0.6, dampingFraction: 0.85), value: node.status)
        }
    }

    private func iconColor(for node: QuestNode) -> Color {
        switch node.status {
        case .locked:
            return CQTheme.textSecondary
        case .available:
            return node.module.subject.accentColor
        case .completed:
            return CQTheme.yellowAccent
        }
    }

    private func borderColor(for node: QuestNode) -> Color {
        switch node.status {
        case .locked:
            return CQTheme.textSecondary.opacity(0.3)
        case .available:
            return node.module.subject.accentColor.opacity(0.9)
        case .completed:
            return CQTheme.yellowAccent
        }
    }

    private func borderWidth(for node: QuestNode) -> CGFloat {
        switch node.status {
        case .locked: return 1.5
        case .available: return 4
        case .completed: return 3
        }
    }

    private var courseSummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Motivation Focus")
                .font(.cqHeadline)
                .foregroundStyle(CQTheme.textPrimary)
            Text(course.motivationNotes)
                .font(.cqBody2)
                .foregroundStyle(CQTheme.textSecondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(CQTheme.cardBackground)
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 8)
        )
    }

    private var moduleList: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Course Modules")
                .font(.cqHeadline)
                .foregroundStyle(CQTheme.textPrimary)

            ForEach(nodes) { node in
                Button {
                    if node.status != .locked {
                        selectedModule = node.module
                    }
                } label: {
                    HStack(alignment: .center, spacing: 16) {
                        Circle()
                            .fill(node.module.subject.accentColor.opacity(0.2))
                            .frame(width: 52, height: 52)
                            .overlay(
                                Image(systemName: node.module.subject.systemImageName)
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundStyle(node.module.subject.accentColor)
                            )

                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(node.module.title)
                                    .font(.cqBody1)
                                    .foregroundStyle(CQTheme.textPrimary)
                                Spacer()
                                statusBadge(for: node.status)
                            }

                            Text(node.module.overview)
                                .font(.cqCaption)
                                .foregroundStyle(CQTheme.textSecondary)
                                .lineLimit(2)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(CQTheme.cardBackground)
                            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 6)
                    )
                }
                .buttonStyle(.plain)
                .disabled(node.status == .locked)
                .opacity(node.status == .locked ? 0.7 : 1)
            }
        }
    }

    private func statusBadge(for status: QuestNode.Status) -> some View {
        let (text, color): (String, Color) = {
            switch status {
            case .locked:
                return ("Locked", CQTheme.textSecondary)
            case .available:
                return ("Ready", CQTheme.bluePrimary)
            case .completed:
                return ("Cleared", CQTheme.yellowAccent)
            }
        }()

        return Text(text)
            .font(.cqCaption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.18))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

private struct ModuleDetailSheet: View {
    let course: GradeCourse
    let module: CurriculumModule

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    header

                    ForEach(module.classes) { lesson in
                        CurriculumClassCard(lesson: lesson)
                    }
                }
                .padding(24)
                .padding(.bottom, 40)
                .background(CQTheme.background)
            }
            .navigationTitle(module.title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(course.heroTitle, systemImage: "graduationcap")
                .font(.cqCaption)
                .foregroundStyle(CQTheme.textSecondary)
            Text(module.narrativeHook)
                .font(.cqBody1)
                .foregroundStyle(CQTheme.textPrimary)
            Text(module.rewardSummary)
                .font(.cqCaption)
                .foregroundStyle(CQTheme.yellowAccent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(CQTheme.cardBackground)
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
        )
    }
}

private struct CurriculumClassCard: View {
    let lesson: CurriculumClass

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(lesson.title)
                .font(.cqBody1.weight(.semibold))
                .foregroundStyle(CQTheme.textPrimary)

            VStack(alignment: .leading, spacing: 6) {
                Label(lesson.objective, systemImage: "target")
                    .font(.cqCaption)
                    .foregroundStyle(CQTheme.textSecondary)
                Label(lesson.gamifiedStrategy, systemImage: "gamecontroller")
                    .font(.cqCaption)
                    .foregroundStyle(CQTheme.textSecondary)
            }
            .labelStyle(.titleAndIcon)

            VStack(alignment: .leading, spacing: 8) {
                Text("SwiftUI Implementation Highlights")
                    .font(.cqCaption.weight(.semibold))
                    .foregroundStyle(CQTheme.textPrimary)
                ForEach(lesson.swiftUIHighlights, id: \.self) { highlight in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(CQTheme.bluePrimary)
                            .padding(.top, 2)
                        Text(highlight)
                            .font(.cqCaption)
                            .foregroundStyle(CQTheme.textSecondary)
                    }
                }
            }

            Label(lesson.reward, systemImage: "gift.fill")
                .font(.cqCaption)
                .foregroundStyle(CQTheme.yellowAccent)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(CQTheme.cardBackground)
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 6)
        )
    }
}

#Preview {
    QuestMapView()
}
