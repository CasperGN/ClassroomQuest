import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        let subject = SubjectProgress(context: viewContext)
        subject.id = LearningSubject.math.id
        subject.totalSessions = 2
        subject.totalCorrectAnswers = 8
        subject.dailyExerciseCount = 0
        subject.lastExerciseDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())

        let skill = SkillProgress(context: viewContext)
        skill.id = MathSkill.additionWithin10.id
        skill.subjectID = LearningSubject.math.id
        skill.proficiency = 0.4
        skill.lastReviewed = Date()

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ClassroomQuest")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
