import SwiftUI

struct QuestNode: Identifiable {
    enum Status { case locked, current, completed }

    let level: CurriculumLevel
    let status: Status

    var id: CurriculumLevel.ID { level.id }
}

struct QuestMapView: View {
    @EnvironmentObject private var curriculumStore: CurriculumProgressStore
    @State private var selectedSubject: CurriculumSubject = .math
    @State private var selectedLevel: CurriculumLevel?
    @State private var activePlayLevel: CurriculumLevel?

    private var path: CurriculumSubjectPath {
        CurriculumCatalog.subjectPath(for: selectedSubject)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient.cqSoftAdventure
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    header

                    subjectPicker

                    storylineCard

                    GeometryReader { geometry in
                        ZStack {
                            mapPath(in: geometry.size)
                            questNodes(in: geometry.size)
                        }
                    }
                    .padding(20)
                    .frame(minHeight: 420)

                    Spacer(minLength: 32)
                }
            }
            .sheet(item: $selectedLevel) { level in
                let status = statusForLevel(level)
                QuestDetailSheet(
                    level: level,
                    subject: selectedSubject,
                    status: status,
                    onStart: {
                        selectedLevel = nil
                        if status != .locked {
                            activePlayLevel = level
                        }
                    }
                )
                .presentationDetents([.medium, .large])
            }
            .sheet(item: $activePlayLevel) { level in
                CurriculumLevelPlayView(
                    level: level,
                    subject: selectedSubject,
                    onComplete: {
                        curriculumStore.markLevelCompleted(level, subject: selectedSubject)
                    }
                )
            }
            .navigationTitle("Quest Map")
            .toolbar { ToolbarItem(placement: .principal) { EmptyView() } }
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text("Journey Progress")
                .font(.cqTitle2)
                .foregroundStyle(CQTheme.textPrimary)

            Text("Climb each subject path from the ground up. Finish the active level to unlock the next quest above.")
                .font(.cqBody2)
                .foregroundStyle(CQTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .padding(.top, 24)
    }

    private var subjectPicker: some View {
        Picker("Subject", selection: $selectedSubject) {
            ForEach(CurriculumSubject.allCases) { subject in
                Text(subject.displayName)
                    .tag(subject)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 24)
    }

    private var storylineCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: selectedSubject.iconSystemName)
                    .foregroundStyle(selectedSubject.accentColor)
                Text("Storyline")
                    .font(.cqBody1)
                    .foregroundStyle(CQTheme.textPrimary)
            }

            Text(path.storyline)
                .font(.cqBody2)
                .foregroundStyle(CQTheme.textSecondary)
                .multilineTextAlignment(.leading)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(CQTheme.cardBackground)
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
        .padding(.horizontal, 24)
    }

    private func mapPath(in size: CGSize) -> some View {
        let positions = nodePositions(in: size)

        return Path { path in
            guard let first = positions.first?.1 else { return }
            path.move(to: first)
            for (index, element) in positions.enumerated() where index > 0 {
                let previous = positions[index - 1].1
                let current = element.1
                let control = CGPoint(
                    x: (previous.x + current.x) / 2,
                    y: min(previous.y, current.y) - 80
                )
                path.addQuadCurve(to: current, control: control)
            }
        }
        .stroke(style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round))
        .fill(Color(.tertiarySystemFill))
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 6)
    }

    private func questNodes(in size: CGSize) -> some View {
        let positions = nodePositions(in: size)

        return ForEach(positions, id: \.0.id) { node, point in
            Button {
                selectedLevel = node.level
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

                    VStack(spacing: 2) {
                        Text(node.level.title)
                            .font(.cqCaption)
                            .foregroundStyle(CQTheme.textPrimary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 140)

                        Text(node.level.grade.displayName)
                            .font(.cqCaption)
                            .foregroundStyle(CQTheme.textSecondary)
                    }
                }
                .scaleEffect(node.status == .current ? 1.05 : 1)
                .opacity(node.status == .locked ? 0.55 : 1)
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
        case .current: return selectedSubject.accentColor
        case .completed: return CQTheme.yellowAccent
        }
    }

    private var questNodesData: [QuestNode] {
        let levels = path.levels
        return levels.map { level in
            let status = statusForLevel(level)
            return QuestNode(level: level, status: status)
        }
    }

    private func nodePositions(in size: CGSize) -> [(QuestNode, CGPoint)] {
        let nodes = questNodesData
        guard !nodes.isEmpty else { return [] }
        let step = size.height / CGFloat(nodes.count + 1)
        return nodes.enumerated().map { index, node in
            let y = size.height - CGFloat(index + 1) * step
            let xFactor: CGFloat
            if nodes.count == 1 {
                xFactor = 0.5
            } else {
                xFactor = (index % 2 == 0) ? 0.28 : 0.72
            }
            return (node, CGPoint(x: size.width * xFactor, y: y))
        }
    }

    private func statusForLevel(_ level: CurriculumLevel) -> QuestNode.Status {
        switch curriculumStore.status(for: level, subject: selectedSubject) {
        case .locked: return .locked
        case .current: return .current
        case .completed: return .completed
        }
    }
}

private struct QuestDetailSheet: View {
    let level: CurriculumLevel
    let subject: CurriculumSubject
    let status: QuestNode.Status
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Capsule()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 40, height: 4)
                .padding(.top, 12)

            Text(level.title)
                .font(.cqTitle2)
                .foregroundStyle(CQTheme.textPrimary)

            Text("\(level.grade.displayName) • \(subject.displayName)")
                .font(.cqCaption)
                .foregroundStyle(subject.accentColor)

            VStack(alignment: .leading, spacing: 12) {
                infoSection(title: "Focus", icon: "target", content: level.focus)
                infoSection(title: "Overview", icon: "info.circle", content: level.overview)

                VStack(alignment: .leading, spacing: 6) {
                    Label("Quest Checklist", systemImage: "checkmark.seal")
                        .font(.cqCaption)
                        .foregroundStyle(CQTheme.textPrimary)

                    Text("Complete at least \(level.questsRequiredForMastery) of the quests below to finish this level.")
                        .font(.cqBody2)
                        .foregroundStyle(CQTheme.textSecondary)

                    ForEach(level.quests) { quest in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(quest.name)
                                .font(.cqBody1)
                                .foregroundStyle(CQTheme.textPrimary)
                            Text(quest.description)
                                .font(.cqBody2)
                                .foregroundStyle(CQTheme.textSecondary)
                            ForEach(quest.checklist, id: \.self) { item in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 6))
                                        .foregroundStyle(subject.accentColor.opacity(0.8))
                                        .padding(.top, 6)
                                    Text(item)
                                        .font(.cqCaption)
                                        .foregroundStyle(CQTheme.textSecondary)
                                }
                            }
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(CQTheme.cardBackground.opacity(0.9))
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        )
                    }
                }

                infoSection(title: "Reward", icon: "star.fill", content: level.reward)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)

            Button {
                onStart()
            } label: {
                Text(buttonTitle)
                    .font(.cqBody1)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(status == .locked)
            .padding(.horizontal, 24)

            Spacer(minLength: 16)
        }
        .padding(.bottom, 32)
        .background(CQTheme.cardBackground)
    }

    @ViewBuilder
    private func infoSection(title: String, icon: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: icon)
                .font(.cqCaption)
                .foregroundStyle(CQTheme.textPrimary)
            Text(content)
                .font(.cqBody2)
                .foregroundStyle(CQTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var buttonTitle: String {
        switch status {
        case .locked: return "Locked"
        case .current: return "Start Quest"
        case .completed: return "Replay Quest"
        }
    }
}

private struct CurriculumLevelPlayView: View {
    let level: CurriculumLevel
    let subject: CurriculumSubject
    let onComplete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var completedChecklist: [UUID: Set<Int>] = [:]

    private var completedQuestCount: Int {
        level.quests.filter { quest in
            guard let set = completedChecklist[quest.id] else { return false }
            return set.count == quest.checklist.count
        }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Subject: \(subject.displayName)")
                        .font(.cqCaption)
                        .foregroundStyle(subject.accentColor)

                    Text(level.overview)
                        .font(.cqBody2)
                        .foregroundStyle(CQTheme.textSecondary)

                    ForEach(level.quests) { quest in
                        questCard(for: quest)
                    }

                    completionFooter
                }
                .padding(24)
            }
            .background(LinearGradient.cqSoftAdventure.ignoresSafeArea())
            .navigationTitle(level.title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private func questCard(for quest: CurriculumQuest) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(quest.name)
                        .font(.cqBody1)
                        .foregroundStyle(CQTheme.textPrimary)
                    Text(quest.description)
                        .font(.cqBody2)
                        .foregroundStyle(CQTheme.textSecondary)
                }
                Spacer()
                Image(systemName: completedChecklist[quest.id]?.count == quest.checklist.count ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(completedChecklist[quest.id]?.count == quest.checklist.count ? CQTheme.yellowAccent : CQTheme.textSecondary)
            }

            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(quest.checklist.enumerated()), id: \.0) { index, item in
                    Button {
                        toggle(quest: quest, index: index)
                    } label: {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: isChecked(quest: quest, index: index) ? "checkmark.square.fill" : "square")
                                .foregroundStyle(isChecked(quest: quest, index: index) ? CQTheme.greenSecondary : CQTheme.textSecondary)
                            Text(item)
                                .font(.cqBody2)
                                .foregroundStyle(CQTheme.textPrimary)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(CQTheme.cardBackground.opacity(0.95))
                .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 8)
        )
    }

    private var completionFooter: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Complete \(level.questsRequiredForMastery) quests to finish this level. Completed: \(completedQuestCount)")
                .font(.cqBody2)
                .foregroundStyle(CQTheme.textPrimary)

            Button {
                onComplete()
                dismiss()
            } label: {
                Text(completedQuestCount >= level.questsRequiredForMastery ? "Finish Level" : "Keep Working")
                    .font(.cqBody1)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(completedQuestCount < level.questsRequiredForMastery)

            Text("Finishing unlocks the next quest and awards: \(level.reward)")
                .font(.cqCaption)
                .foregroundStyle(CQTheme.textSecondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(CQTheme.cardBackground.opacity(0.95))
                .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 8)
        )
    }

    private func toggle(quest: CurriculumQuest, index: Int) {
        var set = completedChecklist[quest.id] ?? []
        if set.contains(index) {
            set.remove(index)
        } else {
            set.insert(index)
        }
        completedChecklist[quest.id] = set
    }

    private func isChecked(quest: CurriculumQuest, index: Int) -> Bool {
        completedChecklist[quest.id]?.contains(index) ?? false
    }
}

#Preview {
    QuestMapView()
        .environmentObject(CurriculumProgressStore())
}
