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
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    func setUpCell(row: Article) {
        
        self.newsImage.downloadImage(from: row.urlToImage)
        self.titleLabel.text = row.title
        self.descriptionLabel.text = row.description
    }
}
