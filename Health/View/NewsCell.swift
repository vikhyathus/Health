//
//  NewsCell.swift
//  Health
//
//  Created by Vikhyath on 28/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import UIKit

class NewsCell: UITableViewCell {

    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var titleText: UITextView!
    @IBOutlet weak var descriptionText: UITextView!
    
    
    func setUpCell(row: Article) {
        
        self.newsImage.downloadImage(from: row.urlToImage)
        self.titleText.text = row.title
        self.descriptionText.text = row.description
    }
}
