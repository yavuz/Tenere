//
//  SelectNewsModal.swift
//  News
//
//  Created by yavuz on 14/01/15.
//  Copyright (c) 2015 yuka. All rights reserved.
//

import Foundation
import UIKit
//import SwiftyJSON

class SelectNewsModalViewController: UIViewController {
    var SelectCountryView:UIViewController!
    var navigationBar:UINavigationBar!
    var SelectNewsView:SelectSourceViewController!
    var indicator: MaterialActivityIndicatorView!
    var items:[[String:AnyObject]] = []
    var nextButtonEnabled:Bool = false
    var OpenCountryList:Bool = false
    var SelectLang:String!
    var rqueue:NSOperationQueue!
    var timer1:NSTimer!
    var timer2:NSTimer!
    let db = SQLiteDB.sharedInstance()
    var selectedCountry:String!
    var ProgressHUD:JGProgressHUD!
    var rightButtonState:Bool = false
    var AppColors = NSDictionary()
    var AppSources = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let ConfigData = Defaults["appconfig"].dictionary
        self.AppColors = ConfigData?["color"] as! NSDictionary
        self.AppSources = ConfigData?["menu"] as! NSArray
        
        self.view.backgroundColor = UIColor(rgba: (self.AppColors["selectednewspage"] as! String))
        var lang = ""
        if(Defaults.hasKey("SelectCountryIso")) {
            lang = Defaults["SelectCountryIso"].string!
        } else {
            let pre: AnyObject = NSLocale.preferredLanguages()[0]
            //var language = ""
            lang = pre as! String
        }
        

        self.SelectLang = lang
        
        self.indicator = MaterialActivityIndicatorView(style: .Default)
        self.indicator.center = view.center
        self.view.addSubview(indicator)
        
        var frame = indicator.frame
        frame.origin.y += 100
        frame.origin.x = 0
        frame.size.width = self.view.bounds.size.width
        
        self.navigationBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.frame.size.width, 64)) // Offset by 20 pixels vertically to take the status bar into account
        self.navigationBar.backgroundColor = UIColor(rgba: (self.AppColors["selectednewspagetitle"] as! String))
        self.navigationBar.barTintColor = UIColor(rgba: (self.AppColors["selectednewspagetitle"] as! String))
        //self.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationBar.translucent = false
        self.navigationBar.layer.zPosition = 1
        self.navigationItem.title = localizedString("select_news")
        
        // Create a navigation item with a title
        //let navigationItem = UINavigationItem()
        //navigationItem.title = localizedString("select_news")
        

        let titleNavDict: NSDictionary = [NSForegroundColorAttributeName: UIColor(rgba: (self.AppColors["selectednewspagenavfontcolor"] as! String)),
            NSFontAttributeName: Font.defaultFont!
        ]
        navigationBar.titleTextAttributes = titleNavDict as? [String : AnyObject]

        //navigationItem.titleView
        

        let DBLang = db.query("SELECT * FROM country WHERE iso=?",parameters:[convertCountryCode(self.SelectLang)])
        //self.setCountryButton(localizedString("select_country"))
        if !DBLang.isEmpty {
            let DLang = DBLang[0]
            
            if let mname = DLang["name"] {
                //self.setCountryButton(mname.asString().capitalizedString)
                print(mname)
            }
        }
        
        
        //self.menuButton.addTarget(target, action: action, forControlEvents: UIControlEvents.TouchUpInside)
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor(rgba: (self.AppColors["selectednewspagenavfontcolor"] as! String)),
            NSFontAttributeName: Font.defaultFont!
        ]
        
        // Create left and right button for navigation item
        let rightButton = UIBarButtonItem(title: localizedString("select_close"), style: UIBarButtonItemStyle.Plain, target: self, action: "BackSearch:")
        rightButton.setTitleTextAttributes(titleDict as? [String : AnyObject], forState: UIControlState.Normal)
        //navigationItem.rightBarButtonItem = rightButton
        self.navigationItem.rightBarButtonItem = rightButton
        self.navigationItem.rightBarButtonItem?.enabled = true
        self.navigationBar.items = [self.navigationItem]
        self.view.addSubview(navigationBar)
        
        self.SelectNewsView = SelectSourceViewController()
        //self.SelectNewsView.view.hidden = false
        self.SelectNewsView.view.frame.origin.x = 0
        self.SelectNewsView.view.frame.origin.y = self.navigationBar.frame.height
        self.view.addSubview(self.SelectNewsView.view)
        self.view.sendSubviewToBack(self.SelectNewsView.view)
        
        self.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "SelectNewsLimit", object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "EnabledNextButton:", name: "SelectNewsLimit", object:nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "ChangeCountryNot", object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "SelectTableViewCountry:", name: "ChangeCountryNot", object:nil)

        NSNotificationCenter.defaultCenter().removeObserver(self, name: "rotated", object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotated", name: UIDeviceOrientationDidChangeNotification, object: nil)

        
        self.navigationBar.autoresizingMask = .FlexibleWidth
        self.SelectNewsView.view.autoresizingMask = [.FlexibleWidth,.FlexibleHeight]
        
        // set progresshud view
        self.ProgressHUD = JGProgressHUD(style: JGProgressHUDStyle.Dark)
        self.ProgressHUD.indicatorView = nil
        self.ProgressHUD.interactionType = JGProgressHUDInteractionType.BlockTouchesOnHUDView
        self.ProgressHUD.position = JGProgressHUDPosition.Center
        self.ProgressHUD.textLabel.text = localizedString("select_news_limit")
        self.ProgressHUD.tapOnHUDViewBlock = { _ in
            //println("kapaniyor")
            self.ProgressHUD.dismiss()
        }
        /*
        layout(self.navigationBar,self.SelectNewsView.view) { nview,sview in
            nview.width == (nview.superview?.width)!
            nview.height == (nview.height)+20
            //sview.top == nview.bottom
            //sview.width == (nview.superview?.width)!
            //nview.top == (nview.superview?.top)!
        }*/
    }
    
    func setCountryButton(country:String) {
        if self.navigationItem.titleView != nil {
            self.navigationItem.titleView?.removeFromSuperview()
        }
        self.selectedCountry = country
        
        let navigationItemButton = UIButton(frame: CGRectMake(0, 0, 100, 100))
        navigationItemButton.setTitle(country+" ▼", forState: UIControlState.Normal)
        navigationItemButton.addTarget(self, action: "ChangeCountry:", forControlEvents: UIControlEvents.TouchUpInside)
        navigationItemButton.titleLabel?.font = Font.defaultFont
        navigationItemButton.setTitleColor(UIColor(rgba: (self.AppColors["selectednewspagenavfontcolor"] as! String)), forState: UIControlState.Normal)
        self.navigationItem.titleView = navigationItemButton
    }
    
    func updateBarButtonItems(alpha:CGFloat){
        if let left = self.navigationItem.leftBarButtonItems {
            for item:UIBarButtonItem in left {
                if let view = item.customView {
                    view.alpha = alpha
                }
            }
        }
        
        if let right = self.navigationItem.rightBarButtonItems {
            for item:UIBarButtonItem in  right {
                if let view = item.customView {
                    view.alpha = alpha
                    //println("alpha dustu ")
                }
            }
        }
        
        let black = UIColor(rgba: (self.AppColors["selectednewspagenavfontcolor"] as! String))
        let semi = black.colorWithAlphaComponent(alpha)
        let nav = self.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: semi]
        
        self.navigationController?.navigationBar.tintColor = self.navigationController?.navigationBar.tintColor.colorWithAlphaComponent(alpha)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        //NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: "startAnimation", userInfo: nil, repeats: false)
        super.viewDidAppear(animated)
        self.startAnimation()
        //#CONFIG : urlden mi yoksa filedan mi cekecegi otomatik olarak belirlenecek
        //self.getNewsSourceData()
        self.getNewsSourceFileData()
    }
    
    func startAnimation() {
        self.indicator!.startAnimating()
        //NSTimer.scheduledTimerWithTimeInterval(15.0, target: self, selector: "stopAnimation", userInfo: nil, repeats: false)
    }
    
    func stopAnimation() {
        self.indicator!.stopAnimating()
    }
    
    func EnabledNextButton(notification: NSNotification) {
        if notification.userInfo != nil {
            let state = notification.userInfo?["stat"] as! Bool
            if state {
                self.updateBarButtonItems(1)
                self.rightButtonState = true
            } else {
                self.updateBarButtonItems(0.4)
                self.rightButtonState = false
            }
            //self.navigationItem.rightBarButtonItem?.enabled = state
        }
        
    }
    
    func SelectTableViewCountry(notification: NSNotification) {
        self.CloseTableView()
        
        if self.SelectNewsView != nil {
            if self.timer1 != nil {
                self.timer1.invalidate()
            }
            
            if self.timer2 != nil {
                self.timer2.invalidate()
            }
            
            self.SelectNewsView.view.hidden = true
            //self.SelectNewsView.view.removeFromSuperview()
            //self.SelectNewsView.removeFromParentViewController()
        }
        self.rqueue.cancelAllOperations()
        
        self.indicator.startAnimating()
        let Lang = notification.userInfo?["item"]?["iso"] as! String
        //let LangTitle = notification.userInfo?["item"]?["name"] as! String
        //self.setCountryButton(LangTitle)
        /*
        self.navigationItem.titleView?.titleLabel?.text = "asdas"
        self.navigationItem.titleView
        navigationItemButton.titleLabel?.text
        */
        self.SelectLang = Lang.lowercaseString
        self.OpenCountryList = false
        //self.getNewsSourceData()
    }
    
    func CloseTableView() {
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
            if self.SelectCountryView != nil {
                self.SelectCountryView.view.frame.origin.y = 0-self.SelectCountryView.view.frame.height
            }

            }, completion: { finished in
                if self.SelectCountryView != nil {
                    self.SelectCountryView.view.hidden = true
                }
                // collectionview remove edilecek
                // yeni data set edilecek
                // gosterilecek
                
        })
        
    }
    
    func OpenTableView() {
        self.SelectCountryView.view.hidden = false
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
            self.SelectCountryView.view.frame.origin.y = self.navigationBar.bounds.height
            }, completion: { finished in
                //println("animation success")
        })
    }
    
    func ChangeCountry(sender:UIButton) {
        //println("change country")
        if self.OpenCountryList {
            self.CloseTableView()
            self.OpenCountryList = false
            //println("close")
        } else {
            //println("open")
            if (self.SelectCountryView != nil) {
                self.SelectCountryView.view.removeFromSuperview()
            }
            
            if(Defaults.hasKey("SelectCountryName")) {
                let Pname = Defaults["SelectCountryName"].string
                self.SelectCountryView = SelectCountryViewController(selectItem: Pname!)
                //self.setCountryButton((Pname?.capitalizedString)!)
            } else {
                self.SelectCountryView = SelectCountryViewController(selectItem: self.selectedCountry)
            }
            
            self.OpenTableView()
            //
            //self.SelectCountryView.view.hidden = true
            self.SelectCountryView.view.backgroundColor = UIColor(rgba: (self.AppColors["selectednewspage"] as! String))
            self.view.addSubview(self.SelectCountryView.view)
            
            self.SelectCountryView.view.frame.origin.y = 0-self.SelectCountryView.view.frame.height
            self.view.bringSubviewToFront(self.SelectCountryView.view)
            self.OpenTableView()
            
            self.SelectCountryView.view.userInteractionEnabled = true
            self.OpenCountryList = true
        }
        

    }
    
    func BackSearch(sender:UIButton) {
        if self.SelectNewsView != nil && self.rightButtonState == true {
            var tempDeleteArray:Array<String> = Array<String>()
            //println(SelectNewsView.selectedItems2)
            
            for (_,val) in self.SelectNewsView.selectedItems2 {
                
                let MaxData = db.query("SELECT MAX(orderlist) as maxorder FROM mylist")
                var maxnumber:Int = 1
                if !MaxData.isEmpty {
                    let MaxRow = MaxData[0]
                    
                    if let mrow = MaxRow["maxorder"] {
                        maxnumber = (mrow.asInt())+1
                    }
                }
                
                let sname = (val["name"] as? String)!
                let surl = (val["url"] as? String)!
                let sidentifier = (val["identifier"] as? String)!
                let sfavicon = (val["favicon"] as? String)!
                //name,url,identifier
                db.execute("INSERT INTO mylist (name,url,orderlist,identifier,favicon) VALUES (?,?,?,?,?)", parameters:[sname,surl,maxnumber,sidentifier,sfavicon])
                tempDeleteArray.append(sidentifier)
            }
            
            if !tempDeleteArray.isEmpty {
                    let joiner = "','"
                    var joinedStrings = tempDeleteArray.joinWithSeparator(joiner)
                    joinedStrings = "'"+joinedStrings+"'"
                    
                    db.query("DELETE FROM mylist where identifier NOT IN (\(joinedStrings))")
                    db.query("DELETE FROM news where CatIdentifier NOT IN (\(joinedStrings))")
            }

            
            if !Defaults.hasKey("firstOpenApp") {
                Defaults["firstOpenApp"] = true
                Defaults["firstNewsSource"] = true
            }
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            if self.ProgressHUD.hidden {
                self.ProgressHUD.showInView(self.view)
                self.ProgressHUD.dismissAfterDelay(5)
            }
        }
    }
    
    
    // dosyadan sources cek
    func getNewsSourceFileData() {
        //var error: NSError?

        if self.AppSources.count > 0 {
            for SearchData in self.AppSources {
                var ObjectData = [String: String]()

                ObjectData["name"] = SearchData["title"] as? String
                ObjectData["url"] = SearchData["rsslink"] as? String
                ObjectData["favicon"] = SearchData["favicon"] as? String
                //let identifier = SearchData["identifier"].stringValue
                let ident = SearchData["rsslink"] as? String
                ObjectData["identifier"] = ident!.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
                //let searchname = turkishSlug(name).lowercaseString
                self.items.append(ObjectData)
            }
            
            if !self.items.isEmpty {
                self.timer1 = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: "stopAnimation", userInfo: nil, repeats: false)
                self.timer2 = NSTimer.scheduledTimerWithTimeInterval(1.8, target: self, selector: "getSourceView", userInfo: nil, repeats: false)
            } else {
                // eger data yoksa viewi gosterilecek
            }
        }

        /*

        //let jsonData: NSData = /* get your json data */
        let filepath = NSBundle.mainBundle().pathForResource("sources", ofType: "json")
        
        let JsonUrlData = NSData(contentsOfFile: filepath!, options: .DataReadingMappedIfSafe, error: nil)
        //let jsonDict = NSJSONSerialization.JSONObjectWithData(jsonData!, options: nil, error: &error) as! NSDictionary
        
        if JsonUrlData != nil {
                    /*
            //println("json var/////////////////////////////////////////////////")
            let json = SwiftyJSON.JSON(data: JsonUrlData!)
            self.items = []
            for(key: String, SearchData: JSON) in json {
                
                var ObjectData = [String: String]()
                
                ObjectData["name"] = SearchData["title"].stringValue
                ObjectData["url"] = SearchData["rsslink"].stringValue
                ObjectData["favicon"] = SearchData["favicon"].stringValue
                //let identifier = SearchData["identifier"].stringValue
                var ident = SearchData["rsslink"].stringValue
                ObjectData["identifier"] = ident.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
                //let searchname = turkishSlug(name).lowercaseString
                self.items.append(ObjectData)
            }
            */
            //println(self.items)
            
            
            
            if !self.items.isEmpty {
                self.timer1 = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: "stopAnimation", userInfo: nil, repeats: false)
                self.timer2 = NSTimer.scheduledTimerWithTimeInterval(1.8, target: self, selector: "getSourceView", userInfo: nil, repeats: false)
            } else {
                // eger data yoksa viewi gosterilecek
            }
            
        }
*/
    }
    
    // urlden sources cek
    /*
    func getNewsSourceData() {
        
        var lang = convertCountryCode(self.SelectLang)
        //if let lang = pre as? String { language = "language:\(lang)" }
        //lang = "tr"
        var apikey = ""
        
        let url = NSURL(string: "http://yuka/api.php?l=\(lang)&tkey=\(apikey)")
        println(url)
        let request = NSURLRequest(URL: url!)
        //var JsonUrlData:NSString!
        self.rqueue = NSOperationQueue.mainQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: self.rqueue) {(response, JsonUrlData, error) in
            //JsonUrlData = NSString(data: data, encoding: NSUTF8StringEncoding)
            //println(JsonUrlData)
            if JsonUrlData != nil {
                //println("json var/////////////////////////////////////////////////")
                let json = SwiftyJSON.JSON(data: JsonUrlData)
                self.items = []
                for(key: String, SearchData: JSON) in json {
                    
                    var ObjectData = [String: String]()
                    
                    ObjectData["name"] = SearchData["title"].stringValue
                    ObjectData["url"] = SearchData["rsslink"].stringValue
                    ObjectData["favicon"] = SearchData["favicon"].stringValue
                    //let identifier = SearchData["identifier"].stringValue
                    var ident = SearchData["rsslink"].stringValue
                    ObjectData["identifier"] = ident.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
                    //let searchname = turkishSlug(name).lowercaseString
                    self.items.append(ObjectData)
                }
                //println(self.items)
                
                
                
                if !self.items.isEmpty {
                    self.timer1 = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: "stopAnimation", userInfo: nil, repeats: false)
                    self.timer2 = NSTimer.scheduledTimerWithTimeInterval(1.8, target: self, selector: "getSourceView", userInfo: nil, repeats: false)
                } else {
                    // eger data yoksa viewi gosterilecek
                }

            }
        }
    }*/
    
    func getSourceView() {
        self.SelectNewsView.SelectItemsRow.removeAll(keepCapacity: true)
        //self.SelectNewsView.selectedItems2.removeAll(keepCapacity: true)
        self.SelectNewsView.collectionView.reloadData()
        self.SelectNewsView.view.hidden = false
        self.SelectNewsView.setData(self.items)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func rotated() {
        self.indicator.center = view.center
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
