import Foundation
import CoreData

extension WFACollection {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<WFACollection> {
        return NSFetchRequest<WFACollection>(entityName: "WFACollection")
    }

    @NSManaged public var alias: String?
    @NSManaged public var blogDescription: String?
    @NSManaged public var email: String?
    @NSManaged public var isPublic: Bool
    @NSManaged public var styleSheet: String?
    @NSManaged public var title: String
    @NSManaged public var url: String?

}

extension WFACollection: Identifiable {

}
