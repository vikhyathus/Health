//
//  NewsArticle+CoreDataProperties.swift
//  
//
//  Created by Vikhyath on 08/10/18.
//
//

import Foundation
import CoreData


extension NewsArticle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NewsArticle> {
        return NSFetchRequest<NewsArticle>(entityName: "NewsArticle")
    }

    @NSManaged public var title: String?
    @NSManaged public var detailednews: String?
    @NSManaged public var image: NSData?

}
