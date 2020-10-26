//
//  DetailViewController.swift
//  GurunaviApp
//
//  Created by Yoshihiro Uda on 2020/10/26.
//

import UIKit
import WebKit
import SDWebImage

class DetailViewController: UIViewController {
    
    
    var url = String()
    var name = String()
    var imageURLString = String()
    var tel = String()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var webView: WKWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.sd_setImage(with: URL(string: imageURLString), completed: nil)
        
        let request = URLRequest(url: URL(string: url)!)
        webView.load(request)
        
    }
    
    
    @IBAction func call(_ sender: Any) {
        
        UIApplication.shared.open(URL(string: "tel://\(tel)")!, options: [:], completionHandler: nil)
        
    }
    
}
