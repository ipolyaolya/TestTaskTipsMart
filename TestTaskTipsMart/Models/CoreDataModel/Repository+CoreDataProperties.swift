//
//  Repository+CoreDataProperties.swift
//  TestTaskTipsMart
//
//  Created by olli on 08.08.19.
//  Copyright © 2019 Oli Poli. All rights reserved.
//

import Foundation
import CoreData


extension Repository {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Repository> {
        return NSFetchRequest<Repository>(entityName: "Repository")
    }
    
    @NSManaged public var name: String?
    @NSManaged public var htmlURL: String?
    @NSManaged public var repoDescription: String?
    @NSManaged public var ownerLogin: String?
    @NSManaged public var starsCount: Int64
    
}
