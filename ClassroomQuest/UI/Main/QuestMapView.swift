import SwiftUI

struct QuestNode: Identifiable {
    enum Status { case locked, current, completed }

    let quest: CurriculumQuest
    let status: Status

    var id: CurriculumQuest.ID { quest.id }
}

struct QuestMapView: View {
    @AppStorage("placementGradeBand") private var placementGradeRaw: String = ""
    @State private var selectedGrade: CurriculumGrade = .grade2
    @State private var selectedSubject: CurriculumSubject = .math
    @State private var selectedQuest: CurriculumQuest?
    @State private var didApplyPlacementSelection = false

    var body: some View {
        ZStack {
            LinearGradient.cqSoftAdventure
                .ignoresSafeArea()

            VStack(spacing: 20) {
                header

                gradePicker

                subjectPicker

                storylineCard

                GeometryReader { geometry in
                    ZStack {
                        mapPath(in: geometry.size)
                        questNodes(in: geometry.size)
                    }
                }
                .padding(20)
                .frame(minHeight: 360)

                Spacer(minLength: 32)
            }
        }
        .sheet(item: $selectedQuest) { quest in
            if let track = currentTrack {
                QuestDetailSheet(
                    quest: quest,
                    grade: selectedGrade,
                    subject: selectedSubject,
                    storyline: track.storyline
                )
                .presentationDetents([.medium, .large])
            }
        }
        .onAppear {
            applyPlacementIfNeeded()
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text(course.guidingTheme)
                .font(.cqTitle2)
                .foregroundStyle(CQTheme.textPrimary)

            Text(course.overview)
                .font(.cqBody2)
                .foregroundStyle(CQTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .padding(.top, 24)
    }

    private var gradePicker: some View {
        Picker("Grade", selection: $selectedGrade) {
            ForEach(CurriculumGrade.allCases) { grade in
                Text(grade.displayName).tag(grade)
            }
        }
        .pickerStyle(.menu)
        .padding(.horizontal, 32)
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

            Text(currentTrack?.storyline ?? "Select a subject to view quests.")
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
                if node.status != .locked {
                    selectedQuest = node.quest
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

                    Text(node.quest.title)
                        .font(.cqCaption)
                        .foregroundStyle(CQTheme.textPrimary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 120)
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
        case .current: return selectedSubject.accentColor
        case .completed: return CQTheme.yellowAccent
        }
    }

    private var course: CurriculumCourse {
        CurriculumCourse.course(for: selectedGrade)
    }

    private var currentTrack: CurriculumTrack? {
        course.tracks.first { $0.subject == selectedSubject }
    }

    private var questNodes: [QuestNode] {
        guard let track = currentTrack else { return [] }
        let progressIndex = 0
        return track.quests.enumerated().map { index, quest in
            let status: QuestNode.Status
            if index < progressIndex {
                status = .completed
            } else if index == progressIndex {
                status = .current
            } else {
                status = .locked
            }
            return QuestNode(quest: quest, status: status)
        }
    }

    private func nodePositions(in size: CGSize) -> [(QuestNode, CGPoint)] {
        let nodes = questNodes
        guard !nodes.isEmpty else { return [] }
        let step = size.height / CGFloat(nodes.count + 1)
        return nodes.enumerated().map { index, node in
            let y = size.height - CGFloat(index + 1) * step
            let xFactor: CGFloat = (index % 2 == 0) ? 0.28 : 0.72
            return (node, CGPoint(x: size.width * xFactor, y: y))
        }
    }

    private func applyPlacementIfNeeded() {
        guard !didApplyPlacementSelection else { return }
        defer { didApplyPlacementSelection = true }
        guard let band = GradeBand(rawValue: placementGradeRaw) else {
            selectedGrade = .preK
            return
        }
        switch band {
        case .kindergarten: selectedGrade = .kindergarten
        case .grade1: selectedGrade = .grade1
        case .grade2: selectedGrade = .grade2
        case .grade3: selectedGrade = .grade3
        case .grade4: selectedGrade = .grade4
        case .grade5: selectedGrade = .grade5
        }
    }
}

private struct QuestDetailSheet: View {
    let quest: CurriculumQuest
    let grade: CurriculumGrade
    let subject: CurriculumSubject
    let storyline: String

    var body: some View {
        VStack(spacing: 16) {
            Capsule()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 40, height: 4)
                .padding(.top, 12)

            Text(quest.title)
                .font(.cqTitle2)
                .foregroundStyle(CQTheme.textPrimary)

            Text("\(grade.displayName) • \(subject.displayName)")
                .font(.cqCaption)
                .foregroundStyle(subject.accentColor)

            VStack(alignment: .leading, spacing: 12) {
                infoSection(title: "Quest Goal", icon: "target", content: quest.topic)
                infoSection(title: "Game Mechanics", icon: "gamecontroller.fill", items: quest.gameMechanics)
                infoSection(title: "SwiftUI Toolkit", icon: "swift", items: quest.swiftUITechniques)
                infoSection(title: "Story Reward", icon: "star.fill", content: quest.reward)
                infoSection(title: "Narrative Context", icon: "text.book.closed", content: storyline)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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

    @ViewBuilder
    private func infoSection(title: String, icon: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: icon)
                .font(.cqCaption)
                .foregroundStyle(CQTheme.textPrimary)
            VStack(alignment: .leading, spacing: 4) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "checkmark.seal")
                            .foregroundStyle(CQTheme.yellowAccent)
                        Text(item)
                            .font(.cqBody2)
                            .foregroundStyle(CQTheme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }
}

#Preview {
    QuestMapView()
}
