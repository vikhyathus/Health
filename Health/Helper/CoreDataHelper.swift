//
//  CoreDataHelper.swift
//  Health
//
//  Created by Vikhyath on 11/10/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataHelper {

    static func deleteObject(entityName: String) {
        
        let context = managedObjectContext()
        let request = NSFetchRequest<NewsArticle>(entityName: "NewsArticle")
            
        do {
            let obj = try context.fetch(request)
            for item in obj {
                context.delete(item)
            }
            try context.save()
        } catch let error {
            print(error)
        }
            
    }
    
    static func managedObjectContext() -> NSManagedObjectContext {
            
        let appdelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appdelegate?.persistentContainer.viewContext
            
        return context!
    }
}
