//
//  WFAPost+CoreDataProperties.swift
//  WriteFreely-MultiPlatform
//
//  Created by Angelo Stavrow on 2020-09-08.
//
//

import Foundation
import CoreData

extension WFAPost {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<WFAPost> {
        return NSFetchRequest<WFAPost>(entityName: "WFAPost")
    }

    @NSManaged public var appearance: String?
    @NSManaged public var body: String
    @NSManaged public var collectionAlias: String?
    @NSManaged public var createdDate: Date?
    @NSManaged public var language: String?
    @NSManaged public var postId: String?
    @NSManaged public var rtl: Bool
    @NSManaged public var slug: String?
    @NSManaged public var status: Int32
    @NSManaged public var title: String
    @NSManaged public var updatedDate: Date?
    @NSManaged public var hasNewerRemoteCopy: Bool
    @NSManaged public var wasDeletedFromServer: Bool

}

extension WFAPost: Identifiable {

}
