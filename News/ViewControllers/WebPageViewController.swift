//
//  WebPageViewController.swift
//  News
//
//  Created by yavuz on 03/11/14.
//  Copyright (c) 2014 yuka. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class WebPageViewController: UIViewController {
    var newsid:String!
    var WebView:WKWebView!
    let db = SQLiteDB.sharedInstance()
    var AppColors = NSDictionary()

    override func viewDidLoad() {
        
        let ConfigData = Defaults["appconfig"].dictionary
        self.AppColors = ConfigData?["color"] as! NSDictionary
        
        let NavigationBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.bounds.width, CGFloat(64)))
        let NavigationBarButton = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: "backDescView:")

        let NavigationItem = UINavigationItem()
        NavigationItem.title = "Title"
        NavigationItem.leftBarButtonItem = NavigationBarButton
        NavigationBar.items = [NavigationItem]
        self.view.addSubview(NavigationBar)
        
        self.view.backgroundColor = UIColor(rgba: (self.AppColors["maincolor"] as! String))
        
        let userContentController = WKUserContentController()
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        self.WebView = WKWebView(frame:CGRectMake(0,64,self.view.bounds.width,self.view.bounds.height),configuration:configuration)
        self.view.addSubview(self.WebView)

        var myURL = ""
        let data = db.query("SELECT url FROM news WHERE id=?", parameters:[self.newsid])
        let row = data[0]

        if let url = row["url"] {
            myURL = url.asString()
        }

        let url = NSURL(string:myURL)
        let req = NSURLRequest(URL:url!)
        self.WebView!.loadRequest(req)

    }
    
    func backDescView(barButtonItem: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}