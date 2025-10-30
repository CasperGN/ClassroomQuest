internal import CoreData
import SwiftUI

struct QuestNode: Identifiable, Equatable {
    enum Status { case locked, current, completed }

    let level: CurriculumLevel
    let subject: CurriculumSubject
    let status: Status
    let needsReview: Bool

    var id: String { "\(subject.rawValue)-\(level.id.uuidString)" }

    static func == (lhs: QuestNode, rhs: QuestNode) -> Bool {
        lhs.id == rhs.id
    }
}

struct QuestMapView: View {
    @EnvironmentObject private var progressStore: ProgressStore
    @State private var selectedSubject: CurriculumSubject = .math
    @State private var selectedNode: QuestNode?
    @State private var activePlayNode: QuestNode?

    private var progressSnapshot: ProgressStore.CurriculumOverallProgress {
        progressStore.curriculumOverallProgress()
    }

    private var starBalance: Int {
        guard let progress = try? progressStore.subjectProgress(for: .math) else { return 0 }
        let correct = Int(progress.totalCorrectAnswers)
        return Int(progress.totalSessions) * 12 + correct
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient.cqSoftAdventure
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    progressHeader

                    subjectChips

                    storylineCard

                    mapCanvas
                        .frame(minHeight: 520)

                    Spacer(minLength: 12)
                }
                .padding(.top, 24)
            }
            .sheet(item: $selectedNode) { node in
                let status = statusForLevel(node.level, subject: node.subject)
                let record = progressStore.curriculumLevelRecord(for: node.level, subject: node.subject)
                QuestDetailSheet(
                    level: node.level,
                    subject: node.subject,
                    status: status,
                    record: record,
                    onStart: {
                        selectedNode = nil
                        if status != .locked {
                            activePlayNode = node
                        }
                    }
                )
                .presentationDetents([.medium, .large])
            }
            .sheet(item: $activePlayNode) { node in
                CurriculumLevelPlayView(
                    level: node.level,
                    subject: node.subject
                )
                .environmentObject(progressStore)
            }
            .navigationTitle("Quest Map")
            .toolbar { ToolbarItem(placement: .principal) { EmptyView() } }
        }
    }

    private var progressHeader: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                levelCard
                starCard
            }
            .padding(.horizontal, 24)

            Text("Guide your hero up each subject path. Tap a glowing quest node to dive in!")
                .font(.cqBody2)
                .foregroundStyle(CQTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)
        }
    }

    private var levelCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "flag.checkered")
                Text("Level \(progressSnapshot.level)")
            }
            .font(.cqBody1)
            .foregroundStyle(CQTheme.textPrimary)

            ProgressView(value: progressSnapshot.progressToNext)
                .tint(CQTheme.yellowAccent)
                .scaleEffect(x: 1, y: 1.4, anchor: .center)

            let percent = Int(progressSnapshot.progressToNext * 100)
            Text(progressSnapshot.totalLevels > progressSnapshot.completedLevels
                ? "\(percent)% to Level \(progressSnapshot.level + 1)"
                : "Max level reached")
                .font(.cqCaption)
                .foregroundStyle(CQTheme.textSecondary)
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(CQTheme.cardBackground.opacity(0.92))
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
        )
    }

    private var starCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                Text("Stars")
            }
            .font(.cqBody1)
            .foregroundStyle(CQTheme.textPrimary)

            Text("\(starBalance)")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(CQTheme.yellowAccent)

            Text("Earn stars by conquering quests and revisiting mastered skills.")
                .font(.cqCaption)
                .foregroundStyle(CQTheme.textSecondary)
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(CQTheme.cardBackground.opacity(0.92))
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
        )
    }

    private var subjectChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(CurriculumSubject.allCases) { subject in
                    Button {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.85)) {
                            selectedSubject = subject
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: subject.iconSystemName)
                            Text(subject.displayName)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 14)
                        .background(
                            Capsule()
                                .fill(selectedSubject == subject
                                    ? subject.accentColor.opacity(0.2)
                                    : Color.white.opacity(0.12))
                        )
                        .overlay(
                            Capsule()
                                .stroke(selectedSubject == subject ? subject.accentColor : Color.clear, lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)
        }
    }

    private var storylineCard: some View {
        let path = CurriculumCatalog.subjectPath(for: selectedSubject)

        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
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
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(CQTheme.cardBackground)
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
        .padding(.horizontal, 24)
    }

    private var mapCanvas: some View {
        ScrollViewReader { proxy in
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                HStack(alignment: .top, spacing: 160) {
                    ForEach(CurriculumSubject.allCases) { subject in
                        let nodes = questNodes(for: subject)
                        SubjectColumnView(
                            subject: subject,
                            nodes: nodes,
                            isFocused: selectedSubject == subject,
                            symbolProvider: { symbol(for: $0) },
                            colorProvider: { color(for: $0, subject: subject) }
                        ) { node in
                            selectedSubject = subject
                            selectedNode = node
                        }
                        .id(subject)
                    }
                }
                .padding(.horizontal, 80)
                .padding(.vertical, 60)
            }
            .onChange(of: selectedSubject) { subject in
                withAnimation(.spring(response: 0.7, dampingFraction: 0.85)) {
                    proxy.scrollTo(subject, anchor: .center)
                }
            }
            .onAppear {
                DispatchQueue.main.async {
                    proxy.scrollTo(selectedSubject, anchor: .center)
                }
            }
        }
    }

    private func questNodes(for subject: CurriculumSubject) -> [QuestNode] {
        let path = CurriculumCatalog.subjectPath(for: subject)
        return path.levels.map { level in
            let status = statusForLevel(level, subject: subject)
            let needsReview = progressStore.curriculumLevelRecord(for: level, subject: subject)?.needsReview ?? false
            return QuestNode(level: level, subject: subject, status: status, needsReview: needsReview)
        }
    }

    private func symbol(for status: QuestNode.Status) -> String {
        switch status {
        case .locked: return "lock.fill"
        case .current: return "flag.fill"
        case .completed: return "star.fill"
        }
    }

    private func color(for status: QuestNode.Status, subject: CurriculumSubject) -> Color {
        switch status {
        case .locked: return CQTheme.textSecondary
        case .current: return subject.accentColor
        case .completed: return CQTheme.yellowAccent
        }
    }

    private func statusForLevel(_ level: CurriculumLevel, subject: CurriculumSubject) -> QuestNode.Status {
        switch progressStore.curriculumStatus(for: level, subject: subject) {
        case .locked: return .locked
        case .current: return .current
        case .completed: return .completed
        }
    }
}

private struct SubjectColumnView: View {
    let subject: CurriculumSubject
    let nodes: [QuestNode]
    let isFocused: Bool
    let symbolProvider: (QuestNode.Status) -> String
    let colorProvider: (QuestNode.Status) -> Color
    let onSelect: (QuestNode) -> Void

    private let columnWidth: CGFloat = 220
    private let verticalSpacing: CGFloat = 160
    private let topOffset: CGFloat = 100

    var body: some View {
        VStack(spacing: 20) {
            Label(subject.displayName, systemImage: subject.iconSystemName)
                .font(.cqBody1)
                .foregroundStyle(isFocused ? subject.accentColor : CQTheme.textSecondary)
                .padding(.bottom, 4)

            GeometryReader { geometry in
                let positions = nodePositions(in: geometry.size)
                ZStack {
                    mapPath(positions: positions, size: geometry.size)

                    ForEach(Array(zip(nodes.indices, nodes)), id: \.1.id) { index, node in
                        Button {
                            onSelect(node)
                        } label: {
                            nodeView(for: node)
                        }
                        .buttonStyle(.plain)
                        .position(positions[index])
                        .animation(.spring(response: 0.6, dampingFraction: 0.85), value: node.status)
                    }
                }
            }
            .frame(width: columnWidth, height: columnHeight)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(isFocused ? Color.white.opacity(0.22) : Color.white.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(isFocused ? subject.accentColor.opacity(0.7) : Color.clear, lineWidth: 2)
        )
        .animation(.easeInOut(duration: 0.3), value: isFocused)
    }

    private var columnHeight: CGFloat {
        let segments = max(nodes.count - 1, 0)
        return topOffset + CGFloat(segments) * verticalSpacing + 140
    }

    private func nodePositions(in size: CGSize) -> [CGPoint] {
        nodes.enumerated().map { index, _ in
            let horizontalOffset: CGFloat = (index % 2 == 0) ? -32 : 32
            let x = size.width / 2 + horizontalOffset
            let y = topOffset + CGFloat(index) * verticalSpacing
            return CGPoint(x: x, y: y)
        }
    }

    @ViewBuilder
    private func mapPath(positions: [CGPoint], size: CGSize) -> some View {
        Canvas { context, _ in
            guard positions.count > 1 else { return }
            var path = Path()
            path.move(to: positions[0])
            for index in 1..<positions.count {
                let previous = positions[index - 1]
                let current = positions[index]
                let control = CGPoint(
                    x: (previous.x + current.x) / 2,
                    y: min(previous.y, current.y) - 90
                )
                path.addQuadCurve(to: current, control: control)
            }
            context.stroke(
                path,
                with: .color(subject.accentColor.opacity(isFocused ? 0.6 : 0.35)),
                lineWidth: isFocused ? 12 : 9
            )
            context.addFilter(.shadow(color: .init(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.18), radius: 8, offset: CGSize(width: 0, height: 6)))
            context.stroke(
                path,
                with: .color(Color.white.opacity(0.1)),
                lineWidth: isFocused ? 16 : 12
            )
        }
    }

    private func nodeView(for node: QuestNode) -> some View {
        VStack(spacing: 6) {
            Image(systemName: symbolProvider(node.status))
                .font(.title2)
                .foregroundStyle(colorProvider(node.status))
                .padding(16)
                .background(
                    Circle()
                        .fill(CQTheme.cardBackground)
                        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
                )
                .overlay(
                    Circle()
                        .stroke(colorProvider(node.status), lineWidth: node.status == .current ? 4 : 2)
                )
                .overlay(alignment: .topTrailing) {
                    if node.needsReview {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(CQTheme.orangeWarning)
                            .offset(x: 8, y: -8)
                    }
                }

            VStack(spacing: 2) {
                Text(node.level.title)
                    .font(.cqCaption)
                    .foregroundStyle(CQTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 150)

                Text(node.level.grade.displayName)
                    .font(.cqCaption)
                    .foregroundStyle(CQTheme.textSecondary)
            }
        }
        .scaleEffect(node.status == .current ? 1.08 : 1)
        .opacity(node.status == .locked ? 0.55 : 1)
    }
}

private struct QuestDetailSheet: View {
    let level: CurriculumLevel
    let subject: CurriculumSubject
    let status: QuestNode.Status
    let record: ProgressStore.CurriculumLevelRecord?
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

                if let record, record.attempts > 0 {
                    VStack(alignment: .leading, spacing: 4) {
                        Label("Practice Attempts", systemImage: "number")
                            .font(.cqCaption)
                            .foregroundStyle(CQTheme.textPrimary)
                        Text("Attempts logged: \(record.attempts). Best quest completion so far: \(record.bestCompletedQuestCount)/\(level.questsRequiredForMastery) required quests.")
                            .font(.cqBody2)
                            .foregroundStyle(CQTheme.textSecondary)
                        if record.needsReview {
                            Text("This level was unlocked with coach assist and should be reviewed together soon.")
                                .font(.cqCaption)
                                .foregroundStyle(CQTheme.orangeWarning)
                        }
                    }
                }
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

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var progressStore: ProgressStore
    @State private var completedChecklist: [UUID: Set<Int>] = [:]
    @State private var didRegisterOutcome = false

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
                    Button("Close") {
                        progressStore.recordCurriculumIncompleteAttempt(
                            for: level,
                            subject: subject,
                            completedQuests: completedQuestCount
                        )
                        didRegisterOutcome = true
                        dismiss()
                    }
                }
            }
        }
        .onDisappear {
            if !didRegisterOutcome {
                progressStore.recordCurriculumIncompleteAttempt(
                    for: level,
                    subject: subject,
                    completedQuests: completedQuestCount
                )
                didRegisterOutcome = true
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
                progressStore.markCurriculumLevelCompleted(
                    level,
                    subject: subject,
                    completedQuests: completedQuestCount,
                    assisted: false
                )
                didRegisterOutcome = true
                dismiss()
            } label: {
                Text(completedQuestCount >= level.questsRequiredForMastery ? "Finish Level" : "Keep Working")
                    .font(.cqBody1)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(completedQuestCount < level.questsRequiredForMastery)

            if progressStore.shouldOfferCurriculumAssistedUnlock(
                for: level,
                subject: subject,
                pendingCompletedQuests: completedQuestCount
            ) {
                Button {
                    progressStore.markCurriculumLevelCompleted(
                        level,
                        subject: subject,
                        completedQuests: completedQuestCount,
                        assisted: true
                    )
                    didRegisterOutcome = true
                    dismiss()
                } label: {
                    Text("Finish with Coach Assist")
                        .font(.cqBody1)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(CQTheme.purpleLanguage)
            }

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
        .environmentObject(ProgressStore(viewContext: PersistenceController.preview.container.viewContext))
}
