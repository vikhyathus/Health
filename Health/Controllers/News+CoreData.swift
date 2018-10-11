//
//  News+CoreData.swift
//  Health
//
//  Created by Vikhyath on 08/10/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import Foundation
import CoreData
import UIKit

extension News {
    
    
    func addToCoreData() {
        
        deleteObject()
        for article in newsArticles {
            addObject(object: article)
        }
        //fetch()
    }
    
    func deleteObject() {
        
        let context = managedObjectContext()
        let request = NSFetchRequest<NewsArticle>(entityName: "NewsArticle")
        
        do {
            let obj = try context.fetch(request)
            for item in obj {
                context.delete(item)
            }
            try context.save()
        }
        catch {
            
        }
        
    }
    
    func populateFromCoreData() {
        
        fetch()
    }
    
    func fetch() {
        let context = managedObjectContext()
        
        let request = NSFetchRequest<NewsArticle>(entityName: "NewsArticle")
        request.returnsObjectsAsFaults = false
        
        do {
            let articles = try context.fetch(request)
            for article in articles {
                newsArticles.append(Article(title: article.title!, description: article.detailednews!, urlToImage: "none", url: "none"))
                imageData.append(article.image!)
            }
        } catch {
            
        }
    }
    
    func downloadImage(from url: String, completion: @escaping (Data) -> Void) {
        
        guard let imageUrl = URL(string: url) else { return }
        let urlRequest = URLRequest(url: imageUrl)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            
            if error != nil {
                print(error)
                return
            }
            completion(data!)
        }
        task.resume()
        
    }
    
    func addObject(object: Article) {
        
        let context = managedObjectContext()
        let entity = NSEntityDescription.insertNewObject(forEntityName: "NewsArticle", into: context) as? NewsArticle
        
       //entity information goes here
        entity?.title = object.title
        entity?.detailednews = object.description
        downloadImage(from: object.urlToImage) { data in
            entity?.image = data as? NSData
        }
        
        do {
            try context.save()
        } catch {
            print("error")
        }
    }
    
    func managedObjectContext() -> NSManagedObjectContext {
        
        let appdelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appdelegate?.persistentContainer.viewContext
        
        return context!
        
    }
}