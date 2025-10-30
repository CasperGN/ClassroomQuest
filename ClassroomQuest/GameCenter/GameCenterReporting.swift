import Foundation

struct GameSessionReport {
    let subject: LearningSubject
    let totalSessions: Int
    let totalCorrectAnswers: Int
    let newMasteredSkills: [MathSkill]
}

protocol GameCenterAchievementReporting: AnyObject {
    func recordSession(report: GameSessionReport)
}
