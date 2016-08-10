//
//  AddSourceViewController.swift
//  News
//
//  Created by yavuz on 14/12/14.
//  Copyright (c) 2014 yuka. All rights reserved.
//

import Foundation
import UIKit

class AddSourceViewController: UIViewController, FeedParserDelegate {
    var SourceURLText:UITextView!
    let db = SQLiteDB.sharedInstance()
    var ProgressHUD:JGProgressHUD!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.frame.size.width, 64)) // Offset by 20 pixels vertically to take the status bar into account
        navigationBar.backgroundColor = UIColor(rgba: "#F7F7F7")
        navigationBar.barTintColor = UIColor(rgba: "#F7F7F7")
        navigationBar.tintColor = UIColor.whiteColor()
        
        // Create a navigation item with a title
        let navigationItem = UINavigationItem()
        navigationItem.title = "Add Source Page"
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: Font.defaultFont!
        ]
        
        navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        
        // Create left and right button for navigation item
        let leftButton = UIBarButtonItem(title: localizedString("close"), style: UIBarButtonItemStyle.Plain, target: self, action: "BackSearch:")
        let rightButton = UIBarButtonItem(title: localizedString("add"), style: UIBarButtonItemStyle.Plain, target: self, action: "SourceParseInfo:")
        leftButton.setTitleTextAttributes(titleDict as? [String : AnyObject], forState: UIControlState.Normal)
        rightButton.setTitleTextAttributes(titleDict as? [String : AnyObject], forState: UIControlState.Normal)

        navigationItem.leftBarButtonItem = leftButton
        navigationItem.rightBarButtonItem = rightButton
        navigationBar.items = [navigationItem]
        
        self.SourceURLText = UITextView(frame: CGRectMake(0, navigationBar.bounds.height, self.view.bounds.width, (self.view.bounds.height-navigationBar.bounds.height)))
        self.SourceURLText.font = Font.defaultFont
        
        self.view.addSubview(self.SourceURLText)
        
        self.view.addSubview(navigationBar)
        
        self.SourceURLText.text = "http://"
        
        // set progresshud view
        let progressAnimation = JGProgressHUDFadeZoomAnimation()
        self.ProgressHUD = JGProgressHUD(style: JGProgressHUDStyle.ExtraLight)
        self.ProgressHUD.interactionType = JGProgressHUDInteractionType.BlockAllTouches
        self.ProgressHUD.animation = progressAnimation
        self.ProgressHUD.indicatorView = JGProgressHUDGifIndicatorView()
        
        /*
        layout(navigationBar, self.SourceURLText) { nbar,stext in
            stext.top == nbar.bottom
            stext.width == nbar.width
        }*/
        /*
        layout(self.tableView,self.SearchBox) { tview,searchBox in
        }*/
    }
    
    func BackSearch(sender:UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func SourceParseInfo(sender:UIButton!) {
        request(self.SourceURLText.text)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func request(SourceURL:String) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            let feedParser = FeedParser(feedURL: SourceURL)
            feedParser.delegate = self
            feedParser.parse()
        })
    }
    
    func addSourceDatabase(nname:String, nurl:String) -> Bool {
        let MaxData = db.query("SELECT MAX(orderlist) as maxorder FROM mylist")
        var maxnumber:Int = 1
        if !MaxData.isEmpty {
            let MaxRow = MaxData[0]
            
            if let mrow = MaxRow["maxorder"] {
                maxnumber = (mrow.asInt())+1
            }
        }
        
        let identifier = slug(nname)
        
        // database insert
        let result = db.execute("INSERT OR REPLACE INTO mylist (name,url,orderlist,identifier,favicon) VALUES (?,?,?,?,?)", parameters:[nname,nurl,maxnumber,identifier])
        if result != 0 {
            return true
        } else {
            return false
        }
    }
    
    // Parse Channel
    func feedParser(parser: FeedParser, didParseChannel channel: FeedChannel) {
        // Here you could react to the FeedParser identifying a feed channel.
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            print("Feed parser did parse channel \(channel)")
            if channel.channelTitle != nil && channel.channelURL != nil {
                let title:String = channel.channelTitle!
                let url:String = channel.channelURL!
                let result = self.addSourceDatabase(title, nurl: url)
                if result {
                    // dismiss modal
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        })
    }
    
    func feedParser(parser: FeedParser, parsingFailedReason reason: String) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            print("parsed failed: \(reason)")
        })
    }
    
    func feedParserParsingAborted(parser: FeedParser) {
        print("Feed parsing aborted by the user")
    }
}
