//
//  News+TableView.swift
//  Health
//
//  Created by Vikhyath on 28/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import Foundation
import UIKit

extension NewsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsArticles.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = newsArticles[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell") as? NewsCell
        cell?.setNeedsUpdateConstraints()
        cell?.updateConstraints()
        cell?.selectionStyle = .none
        cell?.newsImage.image = UIImage(named: "imagePlaceHolder")
        cell?.titleLabel.text = row.title
        cell?.descriptionLabel.text = row.description
        ImageDownloader.downloadImage(urlString: row.urlToImage) { image, _ in
            DispatchQueue.main.async {
                cell?.newsImage?.image = image
            }
        }
        cell?.separatorInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        guard let unwrappedCell = cell else {
            return UITableViewCell()
        }
        return unwrappedCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let webvc = storyboard?.instantiateViewController(withIdentifier: "web") as? WebViewController
        webvc?.urlString = newsArticles[indexPath.row].url
        guard let unwrappedwebvc = webvc else {
            return
        }
        navigationController?.pushViewController(unwrappedwebvc, animated: true)
        //present(unwrappedwebvc, animated: true, completion: nil)
    }
}
