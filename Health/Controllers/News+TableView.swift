//
//  News+TableView.swift
//  Health
//
//  Created by Vikhyath on 28/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import Foundation
import UIKit

extension News: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsArticles.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = newsArticles[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell") as? NewsCell
        if isError {
            cell?.imageView?.image = UIImage(data: imageData[indexPath.row] as Data)
        }
        cell?.setUpCell(row: row)
        cell?.setNeedsUpdateConstraints()
        cell?.updateConstraints()
        //cell?.selectionStyle = .gray
        //cell?.focusStyle = .custom
        cell?.separatorInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let webvc = storyboard?.instantiateViewController(withIdentifier: "web") as? WebViewController
        webvc?.urlString = newsArticles[indexPath.row].url
        present(webvc!, animated: true, completion: nil)
    }
}
