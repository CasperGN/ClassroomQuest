internal import CoreData
import Foundation
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
                            proxy.scrollTo(id, anchor: UnitPoint(x: 0.5, y: 0.05))
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
        if let current = nodes.first(where: { $0.status == .current }) {
            return current
        }
        if let completed = nodes.first(where: { $0.status == .completed }) {
            return completed
        }
        return nodes.first
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
        ScrollView {
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

                Spacer(minLength: 12)
            }
            .padding(.bottom, 24)
        }
        .safeAreaInset(edge: .bottom) {
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
            .padding(.top, 12)
            .background(.ultraThinMaterial)
        }
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
    @State private var completedQuests: Set<UUID> = []
    @State private var activeQuest: CurriculumQuest?
    @State private var didRegisterOutcome = false

    private var completedQuestCount: Int {
        completedQuests.count
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
        .sheet(item: $activeQuest) { quest in
            QuestActivityRunner(
                quest: quest,
                level: level,
                subject: subject
            ) { success in
                if success {
                    completedQuests.insert(quest.id)
                }
                activeQuest = nil
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
        let isComplete = completedQuests.contains(quest.id)

        return VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(quest.name)
                        .font(.cqBody1)
                        .foregroundStyle(CQTheme.textPrimary)
                    Text(quest.description)
                        .font(.cqBody2)
                        .foregroundStyle(CQTheme.textSecondary)
                }

                Spacer(minLength: 12)

                VStack(spacing: 6) {
                    Button {
                        activeQuest = quest
                    } label: {
                        Text(isComplete ? "Replay" : "Continue")
                            .font(.cqCaption)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(subject.accentColor)

                    Image(systemName: isComplete ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundStyle(isComplete ? CQTheme.yellowAccent : CQTheme.textSecondary)

                    Text(isComplete ? "Complete" : "Pending")
                        .font(.cqCaption)
                        .foregroundStyle(isComplete ? CQTheme.greenSecondary : CQTheme.textSecondary)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(quest.checklist.prefix(2), id: \.self) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "sparkle")
                            .foregroundStyle(subject.accentColor.opacity(0.8))
                        Text(item)
                            .font(.cqCaption)
                            .foregroundStyle(CQTheme.textSecondary)
                    }
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
}


struct QuestChallenge: Identifiable, Equatable {
    enum Kind: Equatable {
        case counting(symbol: String, quantity: Int)
        case multipleChoice(options: [String], correctIndex: Int)
    }

    let id = UUID()
    let prompt: String
    let kind: Kind
}

private struct ChallengeFeedback: Equatable {
    let text: String
    let isPositive: Bool
}

enum QuestActivityFactory {
    static func challenges(for quest: CurriculumQuest, level: CurriculumLevel, subject: CurriculumSubject) -> [QuestChallenge] {
        switch subject {
        case .math:
            return mathChallenges(for: quest, grade: level.grade)
        case .language:
            return languageChallenges(for: quest, grade: level.grade)
        case .science:
            return scienceChallenges(for: quest)
        case .social:
            return socialChallenges(for: quest)
        }
    }

    static func fallbackChallenges(for subject: CurriculumSubject, grade: CurriculumGrade) -> [QuestChallenge] {
        switch subject {
        case .math:
            return countingChallenges(symbols: ["circle.fill"], range: 2...5)
        case .language:
            return vocabularyChallenges()
        case .science:
            return lifeScienceChallenges()
        case .social:
            return empathyChallenges()
        }
    }

    private static func mathChallenges(for quest: CurriculumQuest, grade: CurriculumGrade) -> [QuestChallenge] {
        let normalized = normalizedText(from: quest)

        if normalized.contains("count") {
            return countingChallenges(symbols: ["ladybug.fill", "leaf.fill", "star.fill"], range: 3...9)
        }

        if normalized.contains("pattern") || normalized.contains("sequence") {
            return patternChallenges()
        }

        if normalized.contains("compare") || normalized.contains("greater") || normalized.contains("less") {
            return comparisonChallenges()
        }

        if normalized.contains("add") || normalized.contains("sum") {
            return arithmeticChallenges(operation: .addition, grade: grade)
        }

        if normalized.contains("subtract") || normalized.contains("take away") {
            return arithmeticChallenges(operation: .subtraction, grade: grade)
        }

        if normalized.contains("multiply") || normalized.contains("product") {
            return arithmeticChallenges(operation: .multiplication, grade: grade)
        }

        if normalized.contains("divide") || normalized.contains("quotient") {
            return arithmeticChallenges(operation: .division, grade: grade)
        }

        if normalized.contains("fraction") {
            return fractionChallenges()
        }

        return arithmeticChallenges(operation: .mixed, grade: grade)
    }

    private static func languageChallenges(for quest: CurriculumQuest, grade: CurriculumGrade) -> [QuestChallenge] {
        let normalized = normalizedText(from: quest)

        if normalized.contains("letter") || normalized.contains("alphabet") || normalized.contains("phon") {
            return letterSoundChallenges()
        }

        if normalized.contains("vocab") || normalized.contains("word") {
            return vocabularyChallenges()
        }

        if normalized.contains("sentence") || normalized.contains("grammar") {
            return sentenceChallenges()
        }

        if normalized.contains("story") || normalized.contains("read") || normalized.contains("comprehension") {
            return storyChallenges(for: grade)
        }

        return vocabularyChallenges()
    }

    private static func scienceChallenges(for quest: CurriculumQuest) -> [QuestChallenge] {
        let normalized = normalizedText(from: quest)

        if normalized.contains("plant") || normalized.contains("animal") || normalized.contains("habitat") {
            return lifeScienceChallenges()
        }

        if normalized.contains("weather") || normalized.contains("water") || normalized.contains("earth") || normalized.contains("rock") {
            return earthScienceChallenges()
        }

        if normalized.contains("force") || normalized.contains("energy") || normalized.contains("motion") {
            return physicalScienceChallenges()
        }

        if normalized.contains("space") || normalized.contains("planet") {
            return spaceScienceChallenges()
        }

        return lifeScienceChallenges()
    }

    private static func socialChallenges(for quest: CurriculumQuest) -> [QuestChallenge] {
        let normalized = normalizedText(from: quest)

        if normalized.contains("share") || normalized.contains("kind") || normalized.contains("feel") || normalized.contains("empathy") {
            return empathyChallenges()
        }

        if normalized.contains("community") || normalized.contains("civic") || normalized.contains("helper") {
            return communityChallenges()
        }

        if normalized.contains("history") || normalized.contains("tradition") || normalized.contains("culture") {
            return traditionChallenges()
        }

        return empathyChallenges()
    }

    private static func normalizedText(from quest: CurriculumQuest) -> String {
        (quest.name + " " + quest.description + " " + quest.checklist.joined(separator: " ")).lowercased()
    }

    private enum ArithmeticOperation {
        case addition, subtraction, multiplication, division, mixed
    }

    private static func countingChallenges(symbols: [String], range: ClosedRange<Int>) -> [QuestChallenge] {
        (0..<3).map { index in
            let symbol = symbols[index % symbols.count]
            let quantity = Int.random(in: range)
            return QuestChallenge(
                prompt: "Count the shapes and enter how many you see.",
                kind: .counting(symbol: symbol, quantity: quantity)
            )
        }
    }

    private static func patternChallenges() -> [QuestChallenge] {
        let patterns: [(String, String, [String])] = [
            ("🔵 🔺 🔵 🔺", "🔵", ["🔵", "🔺", "🟢"]),
            ("🐸 🦋 🐸 🦋", "🐸", ["🐸", "🦋", "🐝"]),
            ("🍎 🍎 🍐 🍎 🍎", "🍐", ["🍐", "🍎", "🍊"])
        ]

        return patterns.map { sequence, correct, options in
            multipleChoiceChallenge(
                prompt: "What comes next in this pattern? \(sequence)",
                correct: correct,
                distractors: options.filter { $0 != correct }
            )
        }
    }

    private static func comparisonChallenges() -> [QuestChallenge] {
        let comparisons: [(Int, Int, String)] = [
            (4, 7, "7 is greater"),
            (9, 3, "9 is greater"),
            (5, 5, "They are equal")
        ]

        return comparisons.map { left, right, answer in
            let prompt = "Which statement is true about \(left) and \(right)?"
            return multipleChoiceChallenge(
                prompt: prompt,
                correct: answer,
                distractors: ["\(left) is greater", "\(right) is greater", "They are equal"].filter { $0 != answer }
            )
        }
    }

    private static func arithmeticChallenges(operation: ArithmeticOperation, grade: CurriculumGrade) -> [QuestChallenge] {
        let numberRange: ClosedRange<Int>
        switch grade {
        case .preK, .kindergarten:
            numberRange = 0...10
        case .grade1, .grade2:
            numberRange = 0...20
        case .grade3, .grade4:
            numberRange = 0...50
        case .grade5, .grade6:
            numberRange = 0...99
        }

        func makeProblem(op: ArithmeticOperation) -> (prompt: String, answer: Int) {
            switch op {
            case .addition:
                let a = Int.random(in: numberRange)
                let b = Int.random(in: numberRange)
                return ("\(a) + \(b) = ?", a + b)
            case .subtraction:
                let a = Int.random(in: numberRange)
                let b = Int.random(in: 0...a)
                return ("\(a) − \(b) = ?", a - b)
            case .multiplication:
                let a = Int.random(in: 2...max(3, numberRange.upperBound / 2))
                let b = Int.random(in: 2...max(3, numberRange.upperBound / 2))
                return ("\(a) × \(b) = ?", a * b)
            case .division:
                let b = Int.random(in: 2...9)
                let answer = Int.random(in: 2...12)
                let a = b * answer
                return ("\(a) ÷ \(b) = ?", answer)
            case .mixed:
                let operations: [ArithmeticOperation] = [.addition, .subtraction, .addition]
                return makeProblem(op: operations.randomElement() ?? .addition)
            }
        }

        let selectedOperation: [ArithmeticOperation]
        switch operation {
        case .mixed:
            selectedOperation = [.addition, .subtraction, .addition]
        default:
            selectedOperation = Array(repeating: operation, count: 3)
        }

        return selectedOperation.map { op in
            let problem = makeProblem(op: op)
            let correct = String(problem.answer)
            let distractors = uniqueDistractors(for: problem.answer)
            return multipleChoiceChallenge(prompt: problem.prompt, correct: correct, distractors: distractors)
        }
    }

    private static func fractionChallenges() -> [QuestChallenge] {
        let prompts = [
            ("Half of a pizza is", "1/2", ["1/3", "2/2", "3/4"]),
            ("Which shows a quarter?", "1/4", ["4/4", "1/3", "2/4"]),
            ("Two equal parts make", "halves", ["thirds", "quarters", "fifths"])
        ]

        return prompts.map { prompt, correct, distractors in
            multipleChoiceChallenge(prompt: prompt, correct: correct, distractors: distractors)
        }
    }

    private static func letterSoundChallenges() -> [QuestChallenge] {
        let prompts = [
            ("Which word begins with the letter B?", "Ball", ["Cat", "Fish", "Orange"]),
            ("Pick the letter that makes the \"sss\" sound.", "S", ["M", "A", "R"]),
            ("Choose the picture that starts with T.", "Tree", ["Moon", "Apple", "Sun"])
        ]

        return prompts.map { prompt, correct, distractors in
            multipleChoiceChallenge(prompt: prompt, correct: correct, distractors: distractors)
        }
    }

    private static func vocabularyChallenges() -> [QuestChallenge] {
        let prompts = [
            ("Select the synonym for happy.", "Joyful", ["Angry", "Sleepy", "Frozen"]),
            ("What is the opposite of begin?", "Finish", ["Start", "Continue", "Open"]),
            ("Which word fits the sentence: The puppy is very ___.", "Playful", ["Silent", "Invisible", "Hungry"])
        ]

        return prompts.map { prompt, correct, distractors in
            multipleChoiceChallenge(prompt: prompt, correct: correct, distractors: distractors)
        }
    }

    private static func sentenceChallenges() -> [QuestChallenge] {
        let prompts = [
            ("Choose the sentence with correct punctuation.", "Can we go to the park?", ["can we go to the park", "Can we go to the park.", "Can we go to the park!"]),
            ("Which word correctly completes: She ___ to school.", "walks", ["walk", "walking", "walked"]),
            ("Pick the sentence that uses a comma correctly.", "After lunch, we played outside.", ["After lunch we played outside", "After lunch we played, outside.", "After, lunch we played outside."])
        ]

        return prompts.map { prompt, correct, distractors in
            multipleChoiceChallenge(prompt: prompt, correct: correct, distractors: distractors)
        }
    }

    private static func storyChallenges(for grade: CurriculumGrade) -> [QuestChallenge] {
        let stories = [
            ("A fox loses his kite in a tree and asks friends for help. Who first offers to assist?", "The bird", ["The turtle", "The rabbit", "The bear"]),
            ("Mina reads about planets and shares one fact with her class. What did she learn about Earth?", "It has air and water for life.", ["It is the hottest planet.", "It has three moons.", "It is made of ice."]),
            ("Kai planted seeds on Monday. By Friday, what did he notice?", "The sprouts had small leaves.", ["Nothing changed.", "The seeds turned into rocks.", "It started snowing."])
        ]

        return stories.map { prompt, correct, distractors in
            multipleChoiceChallenge(prompt: prompt, correct: correct, distractors: distractors)
        }
    }

    private static func lifeScienceChallenges() -> [QuestChallenge] {
        let prompts = [
            ("What do plants need to make food?", "Sunlight", ["Moonlight", "Sand", "Smoke"]),
            ("Which animal is a mammal?", "Dolphin", ["Frog", "Robin", "Salmon"]),
            ("A habitat that is hot and dry is called a", "Desert", ["Rainforest", "Ocean", "Glacier"])
        ]

        return prompts.map { prompt, correct, distractors in
            multipleChoiceChallenge(prompt: prompt, correct: correct, distractors: distractors)
        }
    }

    private static func earthScienceChallenges() -> [QuestChallenge] {
        let prompts = [
            ("What causes day and night?", "Earth spinning on its axis", ["The moon glowing", "Clouds moving", "Stars blinking"]),
            ("Water that falls from the sky is called", "Precipitation", ["Evaporation", "Condensation", "Irrigation"]),
            ("Which rock forms from cooling lava?", "Igneous", ["Sedimentary", "Metamorphic", "Crystal"])
        ]

        return prompts.map { prompt, correct, distractors in
            multipleChoiceChallenge(prompt: prompt, correct: correct, distractors: distractors)
        }
    }

    private static func physicalScienceChallenges() -> [QuestChallenge] {
        let prompts = [
            ("Pushing a swing is an example of", "Force", ["Energy loss", "Gravity", "Friction"]),
            ("What happens when objects rub together?", "Friction slows them down", ["They freeze", "They glow", "They disappear"]),
            ("Energy we use to see things is called", "Light energy", ["Sound energy", "Stored energy", "Shadow energy"])
        ]

        return prompts.map { prompt, correct, distractors in
            multipleChoiceChallenge(prompt: prompt, correct: correct, distractors: distractors)
        }
    }

    private static func spaceScienceChallenges() -> [QuestChallenge] {
        let prompts = [
            ("Which planet is known as the Red Planet?", "Mars", ["Mercury", "Venus", "Saturn"]),
            ("What does the sun give to Earth?", "Light and warmth", ["Rain", "Wind", "Mountains"]),
            ("A group of stars that forms a pattern is a", "Constellation", ["Galaxy", "Comet", "Orbit"])
        ]

        return prompts.map { prompt, correct, distractors in
            multipleChoiceChallenge(prompt: prompt, correct: correct, distractors: distractors)
        }
    }

    private static func empathyChallenges() -> [QuestChallenge] {
        let prompts = [
            ("A classmate looks sad after recess. What is a kind first step?", "Ask if they're okay and listen", ["Ignore them", "Tell others to stay away", "Laugh to cheer them up"]),
            ("Your friend forgot their snack. How can you show kindness?", "Share part of your snack", ["Hide your snack", "Say it's their fault", "Walk away"]),
            ("Two classmates want the same toy. What should you suggest?", "Take turns and set a timer", ["Grab the toy", "Tell them to fight", "Throw the toy away"])
        ]

        return prompts.map { prompt, correct, distractors in
            multipleChoiceChallenge(prompt: prompt, correct: correct, distractors: distractors)
        }
    }

    private static func communityChallenges() -> [QuestChallenge] {
        let prompts = [
            ("Who helps keep the community safe?", "Firefighters", ["Painters", "Chefs", "Librarians"]),
            ("What is a responsibility of a good neighbor?", "Keep shared spaces tidy", ["Play loud music at night", "Ignore others", "Lock the park"]),
            ("Why do communities have rules?", "To help everyone stay safe and respectful", ["To make life boring", "To confuse visitors", "To keep kids indoors"])
        ]

        return prompts.map { prompt, correct, distractors in
            multipleChoiceChallenge(prompt: prompt, correct: correct, distractors: distractors)
        }
    }

    private static func traditionChallenges() -> [QuestChallenge] {
        let prompts = [
            ("Why do families celebrate traditions?", "To remember special people and stories", ["To win prizes", "To skip chores", "To buy toys"]),
            ("What is a respectful way to learn about another culture's holiday?", "Ask questions and listen kindly", ["Make fun of it", "Say yours is better", "Ignore the celebration"]),
            ("How can you share your own tradition at school?", "Explain what it means and invite friends to join", ["Keep it secret", "Change it for others", "Say no one can join"])
        ]

        return prompts.map { prompt, correct, distractors in
            multipleChoiceChallenge(prompt: prompt, correct: correct, distractors: distractors)
        }
    }

    private static func multipleChoiceChallenge(prompt: String, correct: String, distractors: [String]) -> QuestChallenge {
        var options = distractors
        options.append(correct)
        options = Array(Set(options))
        options.shuffle()
        let correctIndex = options.firstIndex(of: correct) ?? 0
        return QuestChallenge(prompt: prompt, kind: .multipleChoice(options: options, correctIndex: correctIndex))
    }

    private static func uniqueDistractors(for answer: Int) -> [String] {
        var distractors = Set<String>()
        while distractors.count < 3 {
            let offset = Int.random(in: -3...3)
            let candidate = answer + offset
            if candidate >= 0 && candidate != answer {
                distractors.insert(String(candidate))
            }
        }
        return Array(distractors)
    }
}

struct QuestActivityRunner: View {
    let quest: CurriculumQuest
    let level: CurriculumLevel
    let subject: CurriculumSubject
    let onComplete: (Bool) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var currentIndex = 0
    @State private var feedback: ChallengeFeedback?
    @State private var isComplete = false
    @State private var hasReportedResult = false

    private let challenges: [QuestChallenge]

    init(quest: CurriculumQuest, level: CurriculumLevel, subject: CurriculumSubject, onComplete: @escaping (Bool) -> Void) {
        self.quest = quest
        self.level = level
        self.subject = subject
        self.onComplete = onComplete

        let generated = QuestActivityFactory.challenges(for: quest, level: level, subject: subject)
        self.challenges = generated.isEmpty ? QuestActivityFactory.fallbackChallenges(for: subject, grade: level.grade) : generated
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient.cqSoftAdventure
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    Text(quest.name)
                        .font(.cqTitle2)
                        .foregroundStyle(CQTheme.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 12)

                    if isComplete {
                        completionView
                    } else {
                        challengeContainer
                    }

                    if let feedback {
                        Text(feedback.text)
                            .font(.cqBody2)
                            .foregroundStyle(feedback.isPositive ? CQTheme.greenSecondary : CQTheme.orangeWarning)
                            .transition(.opacity)
                    }

                    Spacer()
                }
                .padding(24)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        reportResult(success: false)
                        dismiss()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .onDisappear {
            reportResult(success: isComplete)
        }
    }

    private var challengeContainer: some View {
        VStack(spacing: 20) {
            progressIndicator

            QuestChallengeView(challenge: challenges[currentIndex]) { isCorrect in
                handleResponse(isCorrect: isCorrect)
            }
            .id(challenges[currentIndex].id)
            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
        }
        .frame(maxWidth: .infinity)
    }

    private var progressIndicator: some View {
        let total = max(challenges.count, 1)

        return VStack(spacing: 6) {
            Text("Challenge \(currentIndex + 1) of \(total)")
                .font(.cqBody2)
                .foregroundStyle(CQTheme.textSecondary)

            ProgressView(value: Double(currentIndex), total: Double(total))
                .progressViewStyle(.linear)
                .tint(subject.accentColor)
        }
        .frame(maxWidth: .infinity)
    }

    private var completionView: some View {
        VStack(spacing: 18) {
            Image(systemName: "sparkles")
                .font(.system(size: 54))
                .foregroundStyle(CQTheme.yellowAccent)

            Text("Quest Complete!")
                .font(.cqTitle2)
                .foregroundStyle(CQTheme.textPrimary)

            Text("Great work finishing every activity. Ready for the next quest?")
                .font(.cqBody2)
                .foregroundStyle(CQTheme.textSecondary)
                .multilineTextAlignment(.center)

            Button {
                reportResult(success: true)
                dismiss()
            } label: {
                Text("Return to Level")
                    .font(.cqBody1)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(CQTheme.cardBackground.opacity(0.95))
                .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 8)
        )
    }

    private func handleResponse(isCorrect: Bool) {
        withAnimation(.easeInOut(duration: 0.3)) {
            feedback = ChallengeFeedback(text: isCorrect ? "Great job!" : "Try again.", isPositive: isCorrect)
        }

        guard isCorrect else { return }

        if currentIndex < challenges.count - 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.85)) {
                    currentIndex += 1
                    feedback = nil
                }
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.9)) {
                    isComplete = true
                    feedback = ChallengeFeedback(text: "Level objective cleared!", isPositive: true)
                }
            }
        }
    }

    private func reportResult(success: Bool) {
        guard !hasReportedResult else { return }
        hasReportedResult = true
        onComplete(success)
    }
}

private struct QuestChallengeView: View {
    let challenge: QuestChallenge
    let onValidated: (Bool) -> Void

    @State private var numberAnswer: Int = 0

    var body: some View {
        VStack(spacing: 18) {
            Text(challenge.prompt)
                .font(.cqBody1)
                .foregroundStyle(CQTheme.textPrimary)
                .multilineTextAlignment(.center)

            switch challenge.kind {
            case .counting(let symbol, let quantity):
                countingView(symbol: symbol, quantity: quantity)
            case .multipleChoice(let options, let correctIndex):
                multipleChoiceView(options: options, correctIndex: correctIndex)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(CQTheme.cardBackground.opacity(0.95))
                .shadow(color: Color.black.opacity(0.12), radius: 14, x: 0, y: 8)
        )
        .onAppear(perform: resetInputs)
        .onChange(of: challenge.id) { _, _ in
            resetInputs()
        }
    }

    @ViewBuilder
    private func countingView(symbol: String, quantity: Int) -> some View {
        VStack(spacing: 16) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: min(4, max(2, Int(sqrt(Double(quantity))))))) {
                ForEach(0..<quantity, id: \.self) { _ in
                    Image(systemName: symbol)
                        .font(.system(size: 36))
                        .foregroundStyle(CQTheme.yellowAccent)
                        .padding(6)
                }
            }
            .padding(.horizontal, 12)

            Stepper(value: $numberAnswer, in: 0...20) {
                Text("Your count: \(numberAnswer)")
                    .font(.cqBody2)
                    .foregroundStyle(CQTheme.textSecondary)
            }
            .padding(.horizontal, 24)

            Button {
                onValidated(numberAnswer == quantity)
            } label: {
                Text("Check Answer")
                    .font(.cqBody1)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    @ViewBuilder
    private func multipleChoiceView(options: [String], correctIndex: Int) -> some View {
        VStack(spacing: 12) {
            ForEach(Array(options.enumerated()), id: \.0) { index, option in
                Button {
                    onValidated(index == correctIndex)
                } label: {
                    Text(option)
                        .font(.cqBody1)
                        .foregroundStyle(CQTheme.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private func resetInputs() {
        numberAnswer = 0
    }
}

#Preview {
    QuestMapView()
        .environmentObject(ProgressStore(viewContext: PersistenceController.preview.container.viewContext))
}
