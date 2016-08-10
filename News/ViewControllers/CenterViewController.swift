//
//  CenterViewController.swift
//  News
//
//  Created by yavuz on 30/09/14.
//  Copyright (c) 2014 yuka. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds

class NewsFeedItem {
    var title: String = ""
    var identifier:String = ""
    var link:String = ""
    var date:NSDate!
    var updated:NSDate!
    var summary:String = ""
    var content:String = ""
    var author:String = ""
    var enclosures:String = ""
    var image:String = ""
    var imageLink:String = ""
    var sname:String = ""   // Source Name
    var language:String = ""
}

class CenterViewController: MainViewController, FeedParserDelegate {
    var tableViewController: CenterTableViewController!
    var refreshControl:UIRefreshControl!  // An optional variable
    var MainTitle:String! = "News"
    var ItemData:Array<NewsFeedItem> = []
    let db = SQLiteDB.sharedInstance()
    var device: Device = Device.currentDevice
    var SourceData:Dictionary<String,String> = [ "ParseURL":"","CatIdentifier":"first-news-sources","Title":"" ]
    //var SourceData:Dictionary<String,String> = [ "ParseURL":"https://news.google.com/news/section?output=rss&geo=Türkiye","CatIdentifier":"http%3A%2F%2Frss.hurriyet.com.tr%2Frss.aspx%3FsectionID=1","Title":"Hürriyet" ]
    var FetchLoadingTimer = NSTimer()
    var FetchTimer = NSTimer()
    var ParserFeed: FeedParser?
    var hamburgerButtonCloseSmall:LBHamburgerButton!
    var ProgressHUD:JGProgressHUD!
    var RTLState:Bool = false
    var mode = String()
    var AppColors = NSDictionary()
    var AppName = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Defaults.hasKey("appconfig") {
            let pp = Defaults["appconfig"].dictionary
            //println(pp?["properties"]?["age"])
            if let title: AnyObject = pp?["title"] {
                print(title)
            }
        }
        
        self.mode = Defaults["appmode"].string as String!
        let ConfigData = Defaults["appconfig"].dictionary
        self.AppName = ConfigData?["appname"] as! String
        self.AppColors = ConfigData?["color"] as! NSDictionary
        
        // eger ilk defa aciyorsa
        // Defaults["firstOpenApp"] = 0
        //Defaults.remove("firstOpenApp");
        if !Defaults.hasKey("firstOpenApp") {
            print(mode)
            if(self.mode == "newsapp") {
                let SelectNewsModal = SelectNewsModalViewController()
                self.navigationController?.presentViewController(SelectNewsModal, animated: true, completion: nil)
                Defaults.remove("firstNewsSource")
            }
        }

        
        /*
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "FLEX", style: UIBarButtonItemStyle.Plain, target: self, action: "flexButtonTapped:")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)*/


        //#CONFIG : single mode olursa hamburger button kaldirilacak - start
        
        
        if self.mode != "singleapp" {
            self.hamburgerButtonCloseSmall = LBHamburgerButton(frame: CGRectMake(0, 0, 64, 64), type: LBHamburgerButtonType.CloseButton, lineWidth: 24, lineHeight: 20/6, lineSpacing: 3, lineCenter: CGPointMake(10, 30), color: UIColor(rgba: YukaColors.DEFAULT_TEXT_COLOR))
            //hamburgerButtonCloseSmall.center = CGPointMake(hamburgerButtonCloseBig.center.x + 100, 120)
            //hamburgerButtonCloseSmall.backgroundColor = UIColor.blackColor()
            self.hamburgerButtonCloseSmall.addTarget(self, action: "leftMenuButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            
            //self.view.addSubview(hamburgerButtonCloseSmall)
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: hamburgerButtonCloseSmall)
        }

        // kaldirilacak - finish

        self.view.backgroundColor = UIColor(rgba: (self.AppColors["maincolor"] as! String))//UIColor.whiteColor()
        
        self.tableViewController = CenterTableViewController(items: self.ItemData)
        self.addChildViewController(self.tableViewController)
        self.view.addSubview(self.tableViewController.view)
        self.tableViewController.view.frame = self.view.bounds;
        //println(self.tableViewController)
        if (self.SourceData["Title"] != nil && !(self.SourceData["Title"]?.isEmpty != nil)) {
            self.title = self.SourceData["Title"]
        } else {
            self.title = self.AppName
        }
        
        // add refresh controller
        self.refreshControl = UIRefreshControl()
        let attr = [NSForegroundColorAttributeName:UIColor(rgba: (self.AppColors["mainfontcolor"] as! String))]
        self.refreshControl.attributedTitle = NSAttributedString(string: localizedString("center_pull_to_refresh"), attributes:attr)
        self.refreshControl.backgroundColor = UIColor(rgba: (self.AppColors["maincolor"] as! String))
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableViewController.tableView.addSubview(refreshControl)
        
        // Status bar white font
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Default
        self.navigationController?.navigationBar.barTintColor = UIColor(rgba: (self.AppColors["mainnavigationtitle"] as! String))
        self.navigationController?.navigationBar.tintColor = UIColor(rgba: (self.AppColors["mainnavigationtitletint"] as! String))
        self.navigationController?.navigationBar.translucent = false
        
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor(rgba: (self.AppColors["mainnavigationtitlefontcolor"] as! String)),NSFontAttributeName: Font.defaultBoldFont!]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        
        // set progresshud view
        let progressAnimation = JGProgressHUDFadeZoomAnimation()
        self.ProgressHUD = JGProgressHUD(style: JGProgressHUDStyle.ExtraLight)
        self.ProgressHUD.interactionType = JGProgressHUDInteractionType.BlockTouchesOnHUDView
        self.ProgressHUD.animation = progressAnimation
        self.ProgressHUD.indicatorView = JGProgressHUDGifIndicatorView()
        self.ProgressHUD.tapOnHUDViewBlock = { _ in
            self.StopParsingTime()
        }
        self.SetDBData()
        if self.ItemData.count > 0 {
            if self.tableViewController != nil {
                self.RemoveNoFeedContentView()
                self.tableViewController.setData(self.ItemData, operation: "database",RTL: self.RTLState)
            }
        } else {
            print("no feed content")
        }
        
        if (!Defaults.hasKey("firstNewsSource")) {
            if self.SourceData["ParseURL"]?.length == 0 && self.SourceData["CatIdentifier"]?.length == 0 {
                self.SourceData["CatIdentifier"] = "first-news-sources"
                self.requestContent()
            } else {
                self.FetchTimer = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: Selector("requestContent"), userInfo: nil, repeats: false)
            }
        }
        
        //self.requestContent()
        //#CONFIG : hamburger button kaldirilacak - start
        if self.mode != "singleapp" {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: "LeftMenuChangedNotification", object:nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "LeftMenuAnimatedButton:", name: "LeftMenuChangedNotification", object:nil)
        }
        // kaldirilacak - finish
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "LeftMenuSelectedItem", object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "LeftMenuSelected:", name: "LeftMenuSelectedItem", object:nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "StopParsingTimer", object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "StopParsingTimeNotification:", name: "StopParsingTimer", object:nil)
        //NSNotificationCenter.defaultCenter().removeObserver(self, name: "StopParsingTimer", object:nil)
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "RefreshApp:", name: UIApplicationDidBecomeActiveNotification, object:nil)

    }
    
    func adView(view: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        print(error)
    }
    
    func RefreshApp(notification:NSNotification) {
        if self.tableViewController != nil {
            self.tableViewController.tableView.reloadData()   
        }
        //println("didbecomeactive")
    }
    
    func LeftMenuSelected(notification:NSNotification) {
        if notification.userInfo != nil {
            let topIndex = NSIndexPath(forRow: 0, inSection: 0)
            
            if !self.ItemData.isEmpty {
                self.tableViewController.tableView.reloadData()
                self.tableViewController.tableView.scrollToRowAtIndexPath(topIndex, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
            }


            // @FIX bu islemler sirayla yapilacak. ilk once yukari cikacak daha sonra gecis yapilacak
            if self.SourceData["CatIdentifier"] != notification.userInfo?["CatIdentifier"] as? String {
                self.SourceData["ParseURL"] = notification.userInfo?["ParseURL"] as? String
                self.SourceData["CatIdentifier"] = notification.userInfo?["CatIdentifier"] as? String
                self.SourceData["Title"] = notification.userInfo?["Title"] as? String
                self.title = self.SourceData["Title"]
                self.ItemData = Array<NewsFeedItem>()
                self.RemoveNoFeedContentView()
                self.SetDBData()
                if(self.SourceData["CatIdentifier"] == "native-last-news") {
                    self.tableViewController.setViewTag(true)
                } else {
                    self.tableViewController.setViewTag(false)
                }
                self.tableViewController.setData(self.ItemData, operation: "database",RTL:self.RTLState)
                //self.requestContent()
                if StatusAutoRefresh() {
                    self.FetchTimer = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: Selector("requestContent"), userInfo: nil, repeats: false)
                }

            }
            self.tableViewController.tableView.reloadData()
        }
    }
    
    func leftMenuButtonPressed(sender: UIButton) {
        let btn = sender as! LBHamburgerButton
        btn.switchState()
        self.evo_drawerController?.toggleDrawerSide(.Left, animated: true, completion: nil)
    }
    
    // left menu button ikon
    func LeftMenuAnimatedButton(notification: NSNotification) {
        if notification.userInfo != nil {
            if notification.userInfo?["name"] as! String == "openmenu" && self.hamburgerButtonCloseSmall.hamburgerState.hashValue == 0 {
                self.hamburgerButtonCloseSmall.switchState()
            } else if notification.userInfo?["name"] as! String == "closemenu" && self.hamburgerButtonCloseSmall.hamburgerState.hashValue == 1 {
                self.hamburgerButtonCloseSmall.switchState()
            }
        }
    }
    
    func LeftMenuButtonClose() {
        if self.hamburgerButtonCloseSmall.hamburgerState.hashValue == 1 {
            self.hamburgerButtonCloseSmall.switchState()
        }
    }
    
    func SetDBData() {
        if (self.SourceData["CatIdentifier"] != nil && self.SourceData["CatIdentifier"]?.length > 0) {
            /*
            var now1 = NSDate()
            let twodays = now1.dateByAddingTimeInterval(-3 * 24 * 3600) // 2 gun onceki haberleri sil
            
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:00"
            let twodayformat = dateFormatter.stringFromDate(twodays)
            */
            
            // filtreyi cek
            let FiltreData = db.query("SELECT * FROM filtre")
            var FiltreArray:Array<[String:String]> = Array<[String:String]>()
            for frow in FiltreData {
                var tPreg = ""
                if let fpreg = frow["preg"] {
                    tPreg = fpreg.asString()
                }
                
                var tMatch = ""
                if let fmatch = frow["match"] {
                    tMatch = fmatch.asString()
                }
                
                if !tPreg.isEmpty {
                    // pattern for
                    //myHTMLString = String.ReplaceHTMLTag(myHTMLString, mypattern: tPreg, mytemplate: tMatch)
                    var ObjectData = [String: String]()
                    ObjectData["preg"] = tPreg
                    ObjectData["match"] = tMatch
                    
                    FiltreArray.append(ObjectData)
                }
            }
            
            
            let CatIdentifier:String = self.SourceData["CatIdentifier"]!
            var DatabaseData = [SQLRow]()
            if CatIdentifier.isEmpty {
                DatabaseData = db.query("SELECT news.*,mylist.name as sname,mylist.language as RTL FROM news LEFT JOIN mylist ON mylist.identifier=news.CatIdentifier ORDER BY news.date DESC")
            } else if CatIdentifier == "first-news-sources" {
                DatabaseData = db.query("SELECT news.*,mylist.name as sname,mylist.language as RTL FROM news LEFT JOIN mylist ON mylist.identifier=news.CatIdentifier WHERE CatIdentifier = (SELECT identifier FROM mylist ORDER BY orderlist ASC LIMIT 1) ORDER BY news.date DESC")
            } else if CatIdentifier == "native-last-news" {
                DatabaseData = db.query("SELECT news.*,mylist.name as sname,mylist.language as RTL FROM news LEFT JOIN mylist ON mylist.identifier=news.CatIdentifier ORDER BY news.date DESC")
            } else {
                db.query("DELETE FROM news WHERE id NOT IN (SELECT id FROM news WHERE CatIdentifier='\(CatIdentifier)' ORDER BY date DESC LIMIT 100) AND CatIdentifier='\(CatIdentifier)'")
                DatabaseData = db.query("SELECT news.*,mylist.name as sname,mylist.language as RTL FROM news LEFT JOIN mylist ON mylist.identifier=news.CatIdentifier WHERE news.CatIdentifier=? ORDER BY news.date DESC",parameters:[CatIdentifier])
            }
            
            for row in DatabaseData {
                let Items = NewsFeedItem()
                if let ntitle = row["title"] {
                    Items.title = ntitle.asString()
                }
                
                if let nsummary = row["summary"] {
                    Items.summary = nsummary.asString()
                    /*
                    for farray in FiltreArray {
                        Items.summary = String.ReplaceHTMLTag(Items.summary, mypattern: farray["preg"]!, mytemplate: farray["match"]!)
                    }*/
                }
                
                if let nenclosures = row["enclosures"] {
                    Items.enclosures = nenclosures.asString()
                }
                
                if let nimage = row["image"] {
                    Items.imageLink = nimage.asString()
                }
                
                if let ndate = row["date"] {
                    Items.date = ndate.asDate()
                }
                
                if let nlink = row["link"] {
                    Items.link = nlink.asString()
                }
                
                if let sname = row["sname"] {
                    Items.sname = sname.asString()
                }
                if let lname = row["RTL"] {
                    Items.language = lname.asString()

                    if lname.asString() == "RTL" {
                        self.RTLState = true
                    } else {
                        self.RTLState = false
                    }
                } else {
                    self.RTLState = false
                }
                
                //debug icin kapatildi
/*
                var tempimage = String.FindImageTag(Items.summary, Enclosures: Items.enclosures, Image: Items.image)
                if tempimage["image"]?.length > 0 {
                    Items.imageLink = tempimage["image"]!
                    //println(Items.imageLink)
                }*/
                
                self.ItemData.append(Items)
            }
            
        }
    }
    
    func StopParsingTimeNotification(notification:NSNotification) {
        self.StopParsingTime()
    }
    
    func StopParsingTime() {
        if !self.ProgressHUD.hidden {
            //self.ProgressHUD.dismiss()
            //self.ProgressHUD.textLabel.text = "iptal edildi"
            self.ProgressHUD.dismissAfterDelay(1.5)
        }
        self.FetchLoadingTimer.invalidate()
        self.ParserFeed?.abortParsing()
    }
    
    func requestContent() {
        //@FIX request edilmis mi ona bakacak eger yapildiysa tekrar yapmayacak
        self.StopParsingTime()
        let CatID = self.SourceData["CatIdentifier"]
        if CatID == "native-last-news" {
            // do it
        } else if CatID == "first-news-sources" {
            // first kaydi cek veya en son haberleri goster
            if self.ProgressHUD.hidden {
                self.ProgressHUD.showInView(self.view)
            }
            var SourceDatabaseData = [SQLRow]()
            SourceDatabaseData = db.query("SELECT * FROM mylist ORDER BY orderlist ASC LIMIT 1")
            //var doRequest:Bool = false
            for row in SourceDatabaseData {
                if let nname = row["name"] {
                    self.SourceData["Title"] = nname.asString()
                    self.title = self.SourceData["Title"]
                }
                if let nurl = row["url"] {
                    self.SourceData["ParseURL"] = nurl.asString()
                }
                if let nidentifier = row["identifier"] {
                    self.SourceData["CatIdentifier"] = nidentifier.asString()
                }
                
                if let nlanguage = row["language"] {
                    self.SourceData["language"] = nlanguage.asString()
                    if self.SourceData["language"] == "RTL" {
                        self.RTLState = true
                    } else {
                        self.RTLState = false
                    }
                } else {
                    self.RTLState = false
                }
            }
            
            if self.SourceData["Title"]?.length > 0 && self.SourceData["ParseURL"]?.length > 0 && self.SourceData["CatIdentifier"]?.length > 0 {
                self.request()
            }
        }else if CatID?.length > 0 {
            // eski timeri durdur yenisi calistir
            self.FetchLoadingTimer = NSTimer.scheduledTimerWithTimeInterval(35.4, target: self, selector: "StopParsingTime", userInfo: nil, repeats: false)
            if self.ProgressHUD.hidden {
                self.ProgressHUD.showInView(self.view)
            }

            self.request()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let vc = MainLeftMenuViewController()
        //let navC = UINavigationController(rootViewController: vc)
        self.evo_drawerController?.leftDrawerViewController = vc
        
        //self.evo_drawerController?.closeDrawerGestureModeMask = .All
        //self.evo_drawerController?.openDrawerGestureModeMask = .All

        /*
        self.evo_drawerController?.toggleDrawerSide(.Left, animated: true, completion: { (finished: Bool) in
            let vc = MainLeftMenuViewController()
            let navC = UINavigationController(rootViewController: vc)
            self.evo_drawerController?.leftDrawerViewController = navC
        })
        */
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //#CONFIG : hamburger menu kaldirilacak
        if self.mode != "singleapp" {
            self.LeftMenuButtonClose()
        }
        if (Defaults.hasKey("firstNewsSource")) {
            self.SourceData["Title"] = ""
            self.SourceData["ParseURL"] = ""
            self.SourceData["CatIdentifier"] = "first-news-sources"
            Defaults.remove("firstNewsSource")
            self.FetchTimer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: Selector("requestContent"), userInfo: nil, repeats: false)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.evo_drawerController?.leftDrawerViewController = nil
        self.StopParsingTime()
        self.FetchTimer.invalidate()
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func setupRightMenuButton() {

    }
    
    override func contentSizeDidChange(size: String) {
        //println("contentsizechange")
    }

    // MARK: - Button Handlers
    
    func leftDrawerButtonPress(sender: AnyObject?) {
        self.evo_drawerController?.toggleDrawerSide(.Left, animated: true, completion: nil)
    }
    
    func rightDrawerButtonPress(sender: AnyObject?) {
        self.evo_drawerController?.toggleDrawerSide(.Right, animated: true, completion: nil)
    }
    
    func doubleTap(gesture: UITapGestureRecognizer) {
        self.evo_drawerController?.bouncePreviewForDrawerSide(.Left, completion: nil)
    }
    
    func twoFingerDoubleTap(gesture: UITapGestureRecognizer) {
        self.evo_drawerController?.bouncePreviewForDrawerSide(.Right, completion: nil)
    }
    
    // MARK: RSS Parser Events
    func request() {
        let URL = self.SourceData["ParseURL"]!
        if hasInternetConnection {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                self.ParserFeed = FeedParser(feedURL: URL)
                self.ParserFeed?.delegate = self
                self.ParserFeed?.parse()
            })
        } else {
            //println("no internet connection")
            if !self.ProgressHUD.hidden {
                self.ProgressHUD.dismissAfterDelay(0.4)
            }
            
            if self.ItemData.count <= 0 {
                self.view.addSubview(self.NoNetConnectionContentView())
            }
        }

    }
    
    // MARK: FeedParserDelegate
    // Parse Channel
    func feedParser(parser: FeedParser, didParseChannel channel: FeedChannel) {
        // Here you could react to the FeedParser identifying a feed channel.
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.ItemData = Array<NewsFeedItem>()
            let ArrayRTLLanguages:Array<String> = ["ar","fa","ur","ps","syr","dv","he","yi"]
            self.RTLState = false
            for RTLString in ArrayRTLLanguages {
                if (channel.channelLanguage?.hasPrefix(RTLString) == true) {
                    // yazilari sagdan sola sirala
                    // database update et
                    if(self.SourceData["ParseURL"] == channel.channelURL) {
                        let iden = self.SourceData["CatIdentifier"]! as String
                        self.db.execute("UPDATE mylist SET language='RTL' WHERE identifier=? ", parameters: [iden])
                        self.RTLState = true
                    }

                }
            }

            /*
            Arabic (ar-**)
            Farsi (fa-**)
            Urdu (ur-**)
            Pashtu (ps-**)
            Syriac (syr-**)
            Divehi (dv-**)
            Hebrew (he-**)
            Yiddish (yi-**)
            // http://blogs.msdn.com/b/rssteam/archive/2007/05/17/reading-feeds-in-right-to-left-order.aspx
            */
        })
    }
    
    func feedParser(parser: FeedParser, didParseItem item: FeedItem) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            //println("Feed parser did parse item \(item.feedTitle)")
            
            let tempitem = NewsFeedItem()
            
            // haberleri database ekle
            var enclosures:String = ""
            
            if item.feedTitle == nil {
                item.feedTitle = ""
            } else {
                tempitem.title = item.feedTitle!
            }
            
            if item.feedContent == nil {
                item.feedContent = ""
            } else {
                tempitem.summary = item.feedContent!
            }

            if item.feedPubDate != nil {
                tempitem.date = item.feedPubDate
            }
            
            if item.feedLink == nil {
                item.feedLink = ""
            } else {
                tempitem.link = item.feedLink!
            }
            
            if !item.feedEnclosures.isEmpty {
                for enc in item.feedEnclosures {
                    if !enc.url.isEmpty {
                        enclosures = enc.url as String
                    } else {
                        enclosures = ""
                    }
                }
            }
            
            if item.feedEnclosures.isEmpty {
                if !item.feedMedia.isEmpty {
                    for media in item.feedMedia {
                        if !media.url.isEmpty {
                            if media.type == "image/jpeg" || media.type == "image/png" || media.type == "image/gif" {
                                enclosures = media.url as NSString as String
                            } else {
                                enclosures = ""
                            }
                        } else {
                            enclosures = ""
                        }
                    }
                }
            }
            
            
            if item.feedImage != nil {
                tempitem.image = item.feedImage!
            } else {
                tempitem.image = ""
            }
            
            if (self.title != nil) {
                tempitem.sname = self.title!
            }
            
            tempitem.enclosures = enclosures
            
            self.ItemData.append(tempitem)
            
        })
    }
    
    // Finish Parse
    func feedParser(parser: FeedParser, successfullyParsedURL url: String) {
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            // filtreyi cek
            let FiltreData = self.db.query("SELECT * FROM filtre")
            var FiltreArray:Array<[String:String]> = Array<[String:String]>()
            for frow in FiltreData {
                var tPreg = ""
                if let fpreg = frow["preg"] {
                    tPreg = fpreg.asString()
                }
                
                var tMatch = ""
                if let fmatch = frow["match"] {
                    tMatch = fmatch.asString()
                }
                
                if !tPreg.isEmpty {
                    // pattern for
                    //myHTMLString = String.ReplaceHTMLTag(myHTMLString, mypattern: tPreg, mytemplate: tMatch)
                    var ObjectData = [String: String]()
                    ObjectData["preg"] = tPreg
                    ObjectData["match"] = tMatch
                    
                    FiltreArray.append(ObjectData)
                }
            }
            
            let catid = self.SourceData["CatIdentifier"]
            if (self.ItemData.count > 0 && catid?.length > 0) {
                
                for NewsItem in self.ItemData {
                    var ndate:String = ""
                    if NewsItem.date != nil {

                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss" // @FIX zaman ayari duzetilecek
                        //EE, yyyy-MM-dd hh:mm:ss
                        ndate = dateFormatter.stringFromDate(NewsItem.date!)
                    }
                    
                    for farray in FiltreArray {
                        NewsItem.summary = String.ReplaceHTMLTag(NewsItem.summary, mypattern: farray["preg"]!, mytemplate: farray["match"]!)
                    }
                    
                    var tempimage = String.FindImageTag(NewsItem.summary, Enclosures: NewsItem.enclosures, Image: NewsItem.image)
                    if tempimage["image"]?.length > 0 {
                        NewsItem.image = tempimage["image"]!
                        //println(Items.imageLink)
                    }

                    if(self.SourceData["ParseURL"] == url) {
                        
                        var trimTitleString = NewsItem.title.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                        
                        trimTitleString = trimTitleString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                        
                        var trimSummaryString = NewsItem.summary.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                        
                        trimSummaryString = trimSummaryString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                        

                        self.db.execute("INSERT OR REPLACE INTO news (title, enclosures, image, summary, date, link, CatIdentifier,language) VALUES (?,?,?,?,?,?,?,?)", parameters:[trimTitleString,NewsItem.enclosures, NewsItem.image, trimSummaryString, ndate, NewsItem.link, catid!,NewsItem.language])
                        //println([NewsItem.title,NewsItem.enclosures, NewsItem.image, NewsItem.summary, ndate, NewsItem.link, catid!,NewsItem.language])
                    }

                }
            } else {
                //println("No feeds found at url \(url).")
            }
            
            // reload data
            if !self.ProgressHUD.hidden {
                self.ProgressHUD.dismissAfterDelay(0.4)
            }
            //println(self.ProgressHUD)
            if(self.ItemData.count > 0) {
                if(self.tableViewController != nil) {
                    self.RemoveNoFeedContentView()
                    self.ItemData = Array<NewsFeedItem>()
                    self.SetDBData()
                    self.tableViewController.setData(self.ItemData, operation: "parser",RTL:self.RTLState)
                }
            } else {
                //println("no feed")
                if self.ItemData.count <= 0 {
                    self.view.addSubview(self.NoFeedContentView())
                }
            }
        })
    }
    
    func NoFeedContentView()-> UIView {
        let NoFeedView = UIView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height))
        //NoFeedView.backgroundColor = UIColor(rgba: "#DFDFDF")
        NoFeedView.tag = 100
        
        let customNoLabel = UILabel(frame: CGRectMake(0, (self.view.bounds.height/2)-50, self.view.bounds.width, 100))
        customNoLabel.textColor = UIColor(rgba: YukaColors.DEFAULT_TEXT_COLOR)
        customNoLabel.textAlignment = NSTextAlignment.Center
        customNoLabel.text = localizedString("no_feed")
        customNoLabel.font = Font.defaultLargeFont
        
        NoFeedView.addSubview(customNoLabel)
        
        return NoFeedView
    }
    
    func NoNetConnectionContentView()-> UIView {
        let NoFeedView = UIView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height))
        //NoFeedView.backgroundColor = UIColor(rgba: "#DFDFDF")
        NoFeedView.tag = 100
        
        let customNoLabel = UILabel(frame: CGRectMake(0, (self.view.bounds.height/2)-100, self.view.bounds.width, 100))
        customNoLabel.textColor = UIColor.purpleColor()
        customNoLabel.textAlignment = NSTextAlignment.Center
        customNoLabel.text = "No Internet Connection"
        customNoLabel.font = Font.defaultLargeFont
        
        NoFeedView.addSubview(customNoLabel)
        
        return NoFeedView
    }
    
    func RemoveNoFeedContentView() {
        var RView = self.view.viewWithTag(100)
        if RView != nil {
            while RView != nil {
                RView?.removeFromSuperview()
                RView = self.view.viewWithTag(100)
            }
            
        }
    }
    
    func feedParser(parser: FeedParser, parsingFailedReason reason: String) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            //println("Feed parsed failed: \(reason)")
        })
    }
    
    func feedParserParsingAborted(parser: FeedParser) {
        //println("Feed parsing aborted by the user")
        if self.ItemData.count <= 0 {
            self.view.addSubview(self.NoFeedContentView())
        }
    }

    // MARK: Pull To Refresh
    func refresh(sender:AnyObject) {
        // Code to refresh table view
        self.requestContent()
        let nowDateString = localizedString("center_last_update")
        let nowDate = nowDateString+" "+(dateformatterDate(NSDate()) as String)
        self.refreshControl.attributedTitle = NSAttributedString(string: nowDate)
        self.refreshControl.endRefreshing()
        //loadAndPlaySounds()
        if StatusSounds() { AppSound(name: "refresh", type: "wav").play() }
    }
    
    // webview ac
    func OpenWebView(nid:String) {
        //NavigationController
        let WebPage = SVWebViewController(address: nid)
        WebPage.barsTintColor = UIColor(rgba: (self.AppColors["webviewfooter"] as! String))
        WebPage.barsBackgroundColor = UIColor(rgba: (self.AppColors["webviewfootertint"] as! String))
        //WebPage.navigationController?.toolbar.backgroundColor = UIColor.blackColor()
        //WebPage.navigationController?.toolbar.barTintColor = UIColor.blackColor()
        self.navigationController?.pushViewController(WebPage, animated: true)
        
        // Modal
        /*
        let WebPage = SVModalWebViewController(address: nid)
        presentViewController(WebPage, animated: true, completion: nil)
        */
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    }
    
    
}