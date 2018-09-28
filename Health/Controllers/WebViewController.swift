//
//  WebViewController.swift
//  Health
//
//  Created by Vikhyath on 28/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    
    @IBOutlet weak var webView: UIWebView!
    var urlString: String?
    var urlrequest: URLRequest!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = URL(string: urlString!) else {
            return
        }
        urlrequest = URLRequest(url: url)
        webView.loadRequest(urlrequest)
        
    }
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}
