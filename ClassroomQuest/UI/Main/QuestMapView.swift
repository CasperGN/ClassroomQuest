internal import CoreData
import SwiftUI

struct QuestNode: Identifiable, Equatable {
    enum Status { case locked, current, completed }

    let level: CurriculumLevel
    let subject: CurriculumSubject
    let status: Status
    var id: String { "\(subject.rawValue)-\(level.id.uuidString)" }

    static func == (lhs: QuestNode, rhs: QuestNode) -> Bool {
        lhs.id == rhs.id
    }
}

struct QuestMapView: View {
    @EnvironmentObject private var progressStore: ProgressStore
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedSubject: CurriculumSubject = .math
    @State private var selectedNode: QuestNode?
    @State private var activePlayNode: QuestNode?
    @State private var scrollTarget: ScrollTarget?
    @State private var isProgrammaticScroll = false

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
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text("Level \(progressSnapshot.level)")
                    .font(.cqBody1)
                    .foregroundStyle(CQTheme.textPrimary)

                Spacer(minLength: 12)

                HStack(spacing: 6) {
                    Text("\(starBalance)")
                        .font(.cqBody1)
                        .foregroundStyle(CQTheme.textPrimary)
                    Image(systemName: "star.fill")
                        .foregroundStyle(CQTheme.yellowAccent)
                }
            }

            levelProgressBar
        }
        .padding(.horizontal, 24)
    }

    private var levelProgressBar: some View {
        let progress = progressSnapshot.progressToNext
        let percent = Int(progress * 100)
        let labelText: String
        if progressSnapshot.totalLevels > progressSnapshot.completedLevels {
            labelText = "\(percent)% to Level \(progressSnapshot.level + 1)"
        } else {
            labelText = "Max level reached"
        }

        return GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.18))

                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(CQTheme.yellowAccent.opacity(0.9))
                    .frame(width: geometry.size.width * CGFloat(max(0, min(progress, 1))))

                Text(labelText)
                    .font(.cqCaption)
                    .foregroundStyle(CQTheme.textPrimary)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 32)
    }

    private var subjectChips: some View {
        Group {
            if horizontalSizeClass == .compact {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                    subjectChipButtons(fillWidth: true)
                }
            } else {
                HStack(spacing: 12) {
                    subjectChipButtons(fillWidth: false)
                }
            }
        }
        .padding(.horizontal, 24)
    }

    @ViewBuilder
    private func subjectChipButtons(fillWidth: Bool) -> some View {
        ForEach(CurriculumSubject.allCases) { subject in
            Button {
                let targetNode = firstFocusableNode(for: subject)
                withAnimation(.spring(response: 0.6, dampingFraction: 0.85)) {
                    selectedSubject = subject
                }
                DispatchQueue.main.async {
                    if let node = targetNode {
                        scrollTarget = .node(id: node.id)
                    } else {
                        scrollTarget = .subject(subject)
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: subject.iconSystemName)
                    Text(subject.displayName)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 14)
                .frame(maxWidth: fillWidth ? .infinity : nil, alignment: .center)
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

    private var mapCanvas: some View {
        GeometryReader { containerGeo in
            let containerMidX = containerGeo.frame(in: .global).midX

            ScrollViewReader { proxy in
                ScrollView([.horizontal, .vertical], showsIndicators: false) {
                    HStack(alignment: .top, spacing: 160) {
                        ForEach(CurriculumSubject.allCases) { subject in
                            let nodes = questNodes(for: subject)
                            SubjectColumnView(
                                subject: subject,
                                nodes: nodes,
                                isFocused: selectedSubject == subject,
                                containerMidX: containerMidX,
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
                .onChange(of: scrollTarget) { _, target in
                    guard let target else { return }
                    isProgrammaticScroll = true
                    withAnimation(.spring(response: 0.7, dampingFraction: 0.85)) {
                        switch target {
                        case .subject(let subject):
                            proxy.scrollTo(subject, anchor: .center)
                        case .node(let id):
                            proxy.scrollTo(id, anchor: .top)
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        isProgrammaticScroll = false
                    }
                    DispatchQueue.main.async {
                        scrollTarget = nil
                    }
                }
                .onPreferenceChange(SubjectFocusPreferenceKey.self) { metrics in
                    guard !isProgrammaticScroll else { return }
                    guard let nearest = metrics.min(by: { $0.distance < $1.distance }) else { return }
                    if nearest.subject != selectedSubject {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedSubject = nearest.subject
                        }
                    }
                }
                .onAppear {
                    DispatchQueue.main.async {
                        if let node = firstFocusableNode(for: selectedSubject) {
                            scrollTarget = .node(id: node.id)
                        } else {
                            scrollTarget = .subject(selectedSubject)
                        }
                    }
                }
            }
        }
    }

    private func questNodes(for subject: CurriculumSubject) -> [QuestNode] {
        let path = CurriculumCatalog.subjectPath(for: subject)
        return path.levels.map { level in
            let status = statusForLevel(level, subject: subject)
            return QuestNode(level: level, subject: subject, status: status)
        }
    }

    private func firstFocusableNode(for subject: CurriculumSubject) -> QuestNode? {
        let nodes = questNodes(for: subject)
        return nodes.first(where: { $0.status != .locked }) ?? nodes.first
    }

    private func symbol(for status: QuestNode.Status) -> String {
        switch status {
        case .locked: return "lock.fill"
        case .current: return "sparkles"
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

private struct SubjectFocusMetric: Equatable {
    let subject: CurriculumSubject
    let distance: CGFloat
}

private struct SubjectFocusPreferenceKey: PreferenceKey {
    static var defaultValue: [SubjectFocusMetric] = []

    static func reduce(value: inout [SubjectFocusMetric], nextValue: () -> [SubjectFocusMetric]) {
        value.append(contentsOf: nextValue())
    }
}

private enum ScrollTarget: Equatable {
    case subject(CurriculumSubject)
    case node(id: String)
}

private struct SubjectColumnView: View {
    let subject: CurriculumSubject
    let nodes: [QuestNode]
    let isFocused: Bool
    let containerMidX: CGFloat
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
                        .id(node.id)
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
        .background(
            GeometryReader { columnGeo in
                Color.clear
                    .preference(
                        key: SubjectFocusPreferenceKey.self,
                        value: [
                            SubjectFocusMetric(
                                subject: subject,
                                distance: abs(columnGeo.frame(in: .global).midX - containerMidX)
                            )
                        ]
                    )
            }
        )
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
            context.addFilter(
                .shadow(
                    color: .init(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.18),
                    radius: 8,
                    x: 0,
                    y: 6
                )
            )
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
