//
//  NewsViewController.swift
//  Health
//
//  Created by Vikhyath on 28/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import Foundation
import UIKit

class NewsViewController: UIViewController {
    
    var newsArticles: [Article] = []
    var imageData: [NSData] = []
    var isError: Bool = false
    @IBOutlet weak var tableView: UITableView!
    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setActivityIndicator()
        activityIndicator.startAnimating()
        activityIndicator.backgroundColor = .white
        activityIndicator.isHidden = false
        fetchArticles()
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = Colors.lightBlue
        tableView.estimatedRowHeight = 400
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setActivityIndicator() {
        
        activityIndicator = {
            
            let activity = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            activity.center = view.center
            activity.style = UIActivityIndicatorView.Style.gray
            activity.center = view.center
            activity.hidesWhenStopped = true
            //activity.isHidden = true
            return activity
        }()
        tableView.addSubview(activityIndicator)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func fetchArticles() {
        
        let session = URLSession(configuration: .default)
        let newsUrl = URL(string: "https://newsapi.org/v2/top-headlines?country=gb&category=health&apiKey=cd3ec0f787d44f0394e68b8fa111b4f7")!
        
        let task = session.dataTask(with: newsUrl) { data, _, error in
            
            if error != nil {
                //self.isError = true
                self.populateFromCoreData()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.activityIndicator.stopAnimating()
                }
                //self.isError = false
                return
            }
            guard let dataUnwrapped = data else {
                return
            }
            //json serialisation
            do {
                let json = try JSONSerialization.jsonObject(with: dataUnwrapped, options: .mutableContainers) as? [String: AnyObject]
                if let articles = json?["articles"] as? [[String: AnyObject]] {
                    
                    for article in articles {
                        if let title = article["title"] as? String, let description = article["description"] as? String, let urlToImage = article["urlToImage"] as? String, let webUrl = article["url"] as? String {
                            print(urlToImage)
                            self.newsArticles.append(Article(title: title, description: description, urlToImage: urlToImage, url: webUrl))
                        } else {
                            print("error")
                        }
                    }
                }
                //self.addToCoreData()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.activityIndicator.stopAnimating()
                }
            } catch let error {
                print(error)
            }
        }
        task.resume()
    }
}

class ImageDownloader {
    
    static let imageCache = NSCache<NSString, UIImage>()

    static func downloadImage(urlString: String, completion: @escaping (_ image: UIImage?, _ error: Error? ) -> Void) {
        guard let url = URL(string: urlString) else { return }
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            completion(cachedImage, nil)
        } else {
            guard let imageUrl = url as? URL else { return }
            let urlRequest = URLRequest(url: imageUrl)
            
            let task = URLSession.shared.dataTask(with: urlRequest) { data, _, error in
                
                if error != nil {
                    return
                }
                
                if let error = error {
                    completion(nil, error)
                    
                } else if let data = data, let image = UIImage(data: data) {
                    self.imageCache.setObject(image, forKey: url.absoluteString as NSString)
                    completion(image, nil)
                } else {
                    completion(nil, error)
                }
            }
            task.resume()
        }
    }
}
