//
//  test.swift
//  Health
//
//  Created by Vikhyath on 28/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import Foundation
import UIKit

class News: UIViewController {
    
    var newsArticles: [Article] = []
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchArticles()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func fetchArticles() {
        
        let session = URLSession(configuration: .default)
        let newsUrl = URL(string: "https://newsapi.org/v2/top-headlines?country=gb&category=health&apiKey=cd3ec0f787d44f0394e68b8fa111b4f7")!
        
        let task = session.dataTask(with: newsUrl) { (data,response,error) in
            
            if error != nil {
                print(error?.localizedDescription)
                return
            }
            
            //json serialisation
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String : AnyObject]
                if let articles = json?["articles"] as? [[String : AnyObject]] {
                    
                    for article in articles {
                        if let title = article["title"] as? String, let description = article["description"] as? String, let urlToImage = article["urlToImage"] as? String, let webUrl = article["url"] as? String {
                            print(urlToImage)
                            self.newsArticles.append(Article(title: title, description: description, urlToImage: urlToImage, url: webUrl))
                        }
                        else {
                            print("error")
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            catch let error {
                print(error)
            }
        }
        task.resume()
    }
}

extension UIImageView {
    
    func downloadImage(from url: String) {
        
        guard let imageUrl = URL(string: url) else { return }
        let urlRequest = URLRequest(url: imageUrl)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            
            if error != nil {
                print(error)
                return
            }
            
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
            }
        }
        task.resume()
    }
}
