import Foundation
internal import CoreData

extension SubjectProgress {
    static func fetchRequest(for id: String) -> NSFetchRequest<SubjectProgress> {
        let request = NSFetchRequest<SubjectProgress>(entityName: "SubjectProgress")
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        return request
    }
}

extension SkillProgress {
    static func fetchRequest(for id: String, subjectID: String) -> NSFetchRequest<SkillProgress> {
        let request = NSFetchRequest<SkillProgress>(entityName: "SkillProgress")
        request.predicate = NSPredicate(format: "id == %@ AND subjectID == %@", id, subjectID)
        request.fetchLimit = 1
        return request
    }
}
