import Foundation
import CoreData

@objc(SubjectProgress)
public class SubjectProgress: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SubjectProgress> {
        NSFetchRequest<SubjectProgress>(entityName: "SubjectProgress")
    }

    @NSManaged public var id: String
    @NSManaged public var lastExerciseDate: Date?
    @NSManaged public var dailyExerciseCount: Int16
    @NSManaged public var totalSessions: Int32
    @NSManaged public var totalCorrectAnswers: Int32
}

extension SubjectProgress {
    static func fetchRequest(for id: String) -> NSFetchRequest<SubjectProgress> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        return request
    }
}

@objc(SkillProgress)
public class SkillProgress: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SkillProgress> {
        NSFetchRequest<SkillProgress>(entityName: "SkillProgress")
    }

    @NSManaged public var id: String
    @NSManaged public var subjectID: String
    @NSManaged public var proficiency: Double
    @NSManaged public var lastReviewed: Date?
    @NSManaged public var streak: Int16
}

extension SkillProgress {
    static func fetchRequest(for id: String, subjectID: String) -> NSFetchRequest<SkillProgress> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "id == %@ AND subjectID == %@", id, subjectID)
        request.fetchLimit = 1
        return request
    }
}
