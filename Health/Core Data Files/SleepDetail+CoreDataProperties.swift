//
//  SleepDetail+CoreDataProperties.swift
//  
//
//  Created by Vikhyath on 11/10/18.
//
//

import Foundation
import CoreData


extension SleepDetail {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SleepDetail> {
        return NSFetchRequest<SleepDetail>(entityName: "SleepDetail")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var duration: Int32

}
