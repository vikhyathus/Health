//
//  WalkDetail+CoreDataProperties.swift
//  
//
//  Created by Vikhyath on 11/10/18.
//
//

import Foundation
import CoreData


extension WalkDetail {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WalkDetail> {
        return NSFetchRequest<WalkDetail>(entityName: "WalkDetail")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var steps: Int32

}
