//
//  MainLeftMenuViewController.swift
//  News
//
//  Created by yavuz on 30/09/14.
//  Copyright (c) 2014 yuka. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
//import QuartzCore

// table koyulacak
class MainLeftMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, FeedParserDelegate {

    var tableView: UITableView!
    let db = SQLiteDB.sharedInstance()
    var DatabaseItems:[[String:AnyObject]] = []
    var SearchItems:Array<[String:AnyObject]> = []
    var items:[[String:AnyObject]] = []
    var RSSItems: [String] = []
    var SearchBox: UISearchBar!
    var topbutton1,topbutton2,topbutton3,topbutton4:UIButton!
    var settingsButton:UIButton!
    var sourcesButton:UIButton!
    var editButton:UIButton!
    var addSourceButton:UIButton!
    enum STATE {
        case VIEW, EDIT, SEARCH
    }
    var TableState:STATE = STATE.VIEW
    var device: Device = Device.currentDevice;
    var MainLeftFrame:CGRect!
    var isOrientation:Bool = false
    var ItemData:Array<FeedItem> = []
    var doneClicked:Bool = false
    var isChannelURLParse:Bool = false
    var leftMenuStatic = ["name":localizedString("last_news"),"url":"native","identifier":"native-last-news"]
    var ProgressHUD:JGProgressHUD!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        

        /*
        let rect : CGRect = CGRectMake(0,0,320,100)
        var vista:UIView = UIView(frame: rect)
        let gradient : CAGradientLayer = CAGradientLayer()
        gradient.frame = vista.bounds
        
        let cor1 = UIColor.blackColor().CGColor
        let cor2 = UIColor.whiteColor().CGColor
        let arrayColors = [cor1, cor2]
        
        gradient.colors = arrayColors
        self.view.layer.insertSublayer(gradient, atIndex: 0)*/
        
        var MBackgroundColor = "#F4F4F4"
        
        self.MainLeftFrame = self.view.bounds
        self.DatabaseItems = self.SetDBData()
        self.items = self.DatabaseItems
        
        //self.items.insert(self.leftMenuStatic, atIndex: 0)    // last news menu bolumu
        
        //self.navigationController?.navigationBar.barTintColor = UIColor(rgba: "#CCCCCC")
        //self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(rgba: "#CCCCCC")]
        // F8F8F8
        /*
        self.SearchBox = UISearchBar(frame: CGRect(x: 0, y: 20, width: 205, height: 45))
        //self.SearchBox.backgroundColor = UIColor(rgba: "#32374B")
        self.SearchBox.delegate = self
        self.SearchBox.layer.borderWidth = 1
        self.SearchBox.backgroundColor = UIColor(rgba: MBackgroundColor)
        self.SearchBox.layer.borderColor = UIColor(rgba: MBackgroundColor).CGColor
        self.SearchBox.barTintColor = UIColor(rgba: MBackgroundColor)
        self.SearchBox.layer.borderColor = UIColor(rgba: MBackgroundColor).CGColor
        self.SearchBox.barStyle = UIBarStyle.Default
        self.view.addSubview(SearchBox)
        */
        
        self.settingsButton = UIButton(frame: CGRect(x: 205, y: 20, width: 45, height: 45))
        self.settingsButton.setImage(UIImage(named: "settings"), forState: .Normal)
        //self.settingsButton.backgroundColor = UIColor(rgba: "#32374B")
        self.settingsButton.backgroundColor = UIColor(rgba: MBackgroundColor)
        self.settingsButton.imageEdgeInsets = UIEdgeInsetsMake(10,10,10,10);
        //self.settingsButton.addTarget(self, action: "OpenCountryView:", forControlEvents: UIControlEvents.TouchUpInside)
        self.settingsButton.addTarget(self, action: "OpenSettingsView:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(self.settingsButton)
        
        self.addSourceButton = UIButton(frame: CGRect(x: 0, y: 20, width: 45, height: 45))
        self.addSourceButton.setImage(UIImage(named: "world"), forState: .Normal)
        //self.addSourceButton.backgroundColor = UIColor(rgba: "#32374B")
        self.addSourceButton.backgroundColor = UIColor(rgba: MBackgroundColor)
        //self.addSourceButton.hidden = false
        //self.addSourceButton.alpha = 0
        self.addSourceButton.imageEdgeInsets = UIEdgeInsetsMake(10,10,10,10);
        self.addSourceButton.addTarget(self, action: "OpenCountryView:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(self.addSourceButton)
        
        self.editButton = UIButton(frame: CGRect(x: 0, y: 20, width: 45, height: 45))
        self.editButton.setImage(UIImage(named: "edit"), forState: .Normal)
        //self.addSourceButton.backgroundColor = UIColor(rgba: "#32374B")
        self.editButton.backgroundColor = UIColor(rgba: MBackgroundColor)
        //self.addSourceButton.hidden = false
        //self.addSourceButton.alpha = 0
        self.editButton.imageEdgeInsets = UIEdgeInsetsMake(10,10,10,10);
        self.editButton.addTarget(self, action: "editMode:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(self.editButton)
        
        self.title = "Sources"
        self.navigationController?.navigationBarHidden = true
        
        self.tableView = UITableView(frame: CGRect(x: 0, y: 50, width: 250, height: self.view.bounds.height))
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.view.addSubview(self.tableView)
        self.tableView.registerClass(LeftMenuViewCell.self, forCellReuseIdentifier: "MENU")
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.tableView.separatorColor = UIColor(rgba: MBackgroundColor)
        self.tableView.backgroundColor = UIColor(rgba: MBackgroundColor)
        self.view.backgroundColor = UIColor(rgba: MBackgroundColor)
        
        let RightBorder = UIView(frame: CGRectMake(249, 0, 1, self.view.bounds.height))
        RightBorder.backgroundColor = UIColor.grayColor()
        RightBorder.alpha = 0.4
        RightBorder.tag = 200
        self.view.addSubview(RightBorder)
        
        self.SetSearchBarBackground()
/*
        layout(self.tableView, self.addSourceButton, self.SearchBox) { aview,SourceBut,SettingsButton in
            SourceBut.top == aview.top+20
            SourceBut.width == 45
            SourceBut.height == 45
        }*/
        
        // @FIX en ustteki searchbox yazan bolum degisecek. en ustte yazan bolum neyse o yazilacak
        
        layout(self.tableView,self.settingsButton) { tview,sBox in
            tview.top == sBox.bottom
            tview.width == (tview.superview?.width)!
            tview.bottom == (tview.superview?.bottom)!
        }
        
        layout(self.addSourceButton,self.editButton,self.settingsButton) { abutton,ebutton,sbutton in
            //ebutton.width == (ebutton.superview?.width)!
            //ebutton.height == (ebutton.superview?.height)!
            //align(top: abutton, ebutton, sbutton)
            ebutton.right == sbutton.left
            ebutton.top == sbutton.top
            abutton.right == ebutton.left
            abutton.top == sbutton.top
            ebutton.width == 45
            ebutton.height == 45
            abutton.width == 45
            abutton.height == 45
            //tview.top == searchBox.bottom
            //tview.width == (tview.superview?.width)!
            //tview.bottom == (tview.superview?.bottom)!
        }
        self.tableView.frame.origin.y = 60
        
        // set progresshud view
        var progressAnimation = JGProgressHUDFadeZoomAnimation()
        self.ProgressHUD = JGProgressHUD(style: JGProgressHUDStyle.ExtraLight)
        self.ProgressHUD.interactionType = JGProgressHUDInteractionType.BlockTouchesOnHUDView
        self.ProgressHUD.animation = progressAnimation
        self.ProgressHUD.indicatorView = JGProgressHUDGifIndicatorView()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)

    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if self.evo_drawerController != nil {
            self.MainLeftFrame = (self.evo_drawerController?.view.bounds)!
            self.view.frame = self.MainLeftFrame
        }
        
        if self.isOrientation {
            self.isOrientation = false
            self.startSearchMode()
            self.evo_drawerController?.setMaximumLeftDrawerWidth(self.MainLeftFrame.width, animated: true, completion: nil)
        }

    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        if self.TableState == STATE.EDIT {
            self.isOrientation = true
        }
    }
    
    
    func AddSourceURLView(sender: UIButton!) {
        /*
        self.evo_drawerController?.closeDrawerAnimated(true, completion: nil)
        let center = AddSourceViewController()
        let nav = UINavigationController(rootViewController: center)
        self.evo_drawerController?.setCenterViewController(nav, withCloseAnimation: true, completion: nil)
        */
        
        let vc = AddSourceViewController() //change this to your class name
        //self.navigationController?.presentViewController(vc, animated: true, completion: nil)
        self.evo_drawerController?.presentViewController(vc, animated: true, completion: nil)
    }
    
    func OpenSettingsView(sender: UIButton!) {
        let vc = SettingsViewController() //change this to your class name
        
        let nsettingsController = UINavigationController(rootViewController: vc)
        nsettingsController.restorationIdentifier = "ExampleCenterNavigationControllerRestorationKey"

        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: Font.defaultBoldFont!
        ]
        nsettingsController.navigationBar.titleTextAttributes = titleDict as [NSObject : AnyObject]
        
        // Status bar white font
        nsettingsController.navigationBar.barStyle = UIBarStyle.Default
        nsettingsController.navigationBar.barTintColor = UIColor(rgba: "#F7F7F7")   // 2961C7    // 2068C6
        nsettingsController.navigationBar.tintColor = UIColor(rgba: "#FFFFFF")
        nsettingsController.navigationBar.translucent = false
        

        
        //nsettingsController.navigationBar.items = [navigationItem]
        
        self.evo_drawerController?.presentViewController(nsettingsController, animated: true, completion: nil)
    }
    
    func OpenCountryView(sender: UIButton!) {
        self.minimizeLeftMenu()
        let vc = SelectNewsModalViewController() //change this to your class name
        vc.rightButtonState = true
        self.evo_drawerController?.presentViewController(vc, animated: true, completion: nil)
    }
    
    func keyboardWillBeHidden (notification: NSNotification) {
        //println("hidden keyboard")
        var info = notification.userInfo
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.tableView.frame.size.height = self.view.frame.size.height-(20)
            //self.SearchBox.resignFirstResponder()
        }
    }
    
    func keyboardWasShown (notification: NSNotification) {
        //println("show keyboard")
        var info = notification.userInfo
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.tableView.frame.size.height = self.view.frame.size.height-(keyboardSize.height+self.SearchBox.frame.size.height+20)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.isOrientation = false
        
        let notification: NSNotification = NSNotification(name: "LeftMenuChangedNotification", object: nil, userInfo: ["name":"openmenu"])
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        /*
        if (self.SearchBox != nil) {
            self.SearchBox.resignFirstResponder()
            self.SearchBox.text = nil
        }
*/
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        let notification: NSNotification = NSNotification(name: "LeftMenuChangedNotification", object: nil, userInfo: ["name":"closemenu"])
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        //self.AutoCompleteDatabase(searchText)
        self.TextChange(searchText)
    }
    
    func TextChange(name: String) {
        if name.length <= 0 {
            self.items = SetDBData()
            self.tableView.reloadData()
            self.OpenEditTable()
        }
    }
    
    func AutoCompleteDatabase(name: String) {
        if name.length > 0 {
            self.CloseEditTable()
            //let DatabaseData = db.query("SELECT * FROM sources WHERE name=? ORDER BY name ASC",parameters:[data])
            let DatabaseData = db.query("SELECT * FROM sources WHERE searchname like lower('\(name)%') OR upper('\(name)') ORDER BY name ASC")
            self.items = []
            self.SearchItems = []
            for row in DatabaseData {
                // "name":"Radikal","url":"http://www.radikal.com.tr/d/rss/RssSD.xml","identifier":"radikal"
                //var ObjectData = Dictionary<String;:String>()
                var ObjectData = [String: String]()

                ObjectData["name"] = row["name"]?.asString()
                ObjectData["url"] = row["url"]?.asString()
                ObjectData["identifier"] = row["identifier"]?.asString()
                
                self.items.append(ObjectData)
                self.SearchItems.append(ObjectData)
            }
            
        } else {
            self.items = self.SetDBData()
            self.OpenEditTable()
        }
        self.tableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        if self.doneClicked {
            self.minimizeLeftMenu()
        }
    }
    
    func minimizeLeftMenu() {
        self.evo_drawerController?.setMaximumLeftDrawerWidth(250, animated: true, completion: nil)
        self.DatabaseItems = self.SetDBData()
        self.items = self.DatabaseItems
        //self.items.insert(self.leftMenuStatic, atIndex: 0)    // last news menu bolumu
        
        //self.SearchBox.showsScopeBar = false
        //self.tableView.frame.size.height = self.view.frame.height
        self.tableView.reloadData()
        self.stopSearchMode()
        //self.SearchBox.resignFirstResponder()
        self.TableState = STATE.VIEW
        self.doneClicked = false
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        self.SearchBox.showsCancelButton = true

        var cancelButton: UIButton
        var topView: UIView = self.SearchBox.subviews[0] as! UIView
        for subView in topView.subviews {
            if subView.isKindOfClass(NSClassFromString("UINavigationButton")) {
                cancelButton = subView as! UIButton
                cancelButton.setTitle(localizedString("done"), forState: UIControlState.Normal)
            }
        }
        
        return true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.doneClicked = true
        self.SearchBox.text = ""
        self.SearchBox.resignFirstResponder()
        self.minimizeLeftMenu()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        var pre: String = NSLocale.preferredLanguages()[0] as! String
        var stext:String = searchBar.text
        if self.ProgressHUD.hidden {
            self.ProgressHUD.showInView(self.view)
        }
        
        if validateUrl(stext) {
            isChannelURLParse = true
            var ParseURL:String = stext
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                let feedParser = FeedParser(feedURL: ParseURL)
                feedParser.delegate = self
                feedParser.parse()
            })
        } else {
            isChannelURLParse = false
            
            self.SearchItems = []
            self.items = []
            self.tableView.reloadData()
            //self.items.removeAll(keepCapacity: false)
            
            var language = ""
            if !(pre.isEmpty) { language = "&l=\(pre)" }
            
            var apikey = "7623f17e443203c0780982a1672ea06a"
            
            
            //let url = NSURL(string: "http://yapps.co/tenereapi/tenereapi.php?q=\(stext)&l=\(pre)&tkey=\(apikey)")
            stext = stext.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
            let url = NSURL(string: "http://yapps.co/tenereapi/tenereapi.php?q=\(stext)\(language)&tkey=\(apikey)")
            let request = NSURLRequest(URL: url!)
            //var JsonUrlData:NSString!
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, JsonUrlData, error) in
                //JsonUrlData = NSString(data: data, encoding: NSUTF8StringEncoding)
                if JsonUrlData != nil {
                    var datastring = NSString(data: JsonUrlData, encoding: UInt())
                    let jsondata = JSON(data: JsonUrlData)

                    
                    for(index: String, SearchData: JSON) in jsondata {
                        
                        var ObjectData = [String: String]()
                        
                        ObjectData["name"] = SearchData["title"].stringValue
                        ObjectData["url"] = SearchData["rsslink"].stringValue
                        ObjectData["favicon"] = SearchData["favicon"].stringValue
                        //let identifier = SearchData["identifier"].stringValue
                        var ident = SearchData["rsslink"].stringValue
                        ObjectData["identifier"] = ident.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
                        self.items.append(ObjectData)
                        self.SearchItems.append(ObjectData)
                    }
                    
                    self.CloseEditTable()
                    self.tableView.reloadData()
                    self.SearchBox.resignFirstResponder()
                    
                    // fonksiyon haline gelecek
                    var cancelButton: UIButton
                    var topView: UIView = self.SearchBox.subviews[0] as! UIView
                    for subView in topView.subviews {
                        if subView.isKindOfClass(NSClassFromString("UINavigationButton")) {
                            cancelButton = subView as! UIButton
                            cancelButton.enabled = true
                        }
                    }
                    if !self.ProgressHUD.hidden {
                        self.ProgressHUD.dismissAfterDelay(0.2)
                    }
                }
            }
        }

        

    }
    
    func reloadTableAllData() {
        self.tableView.reloadData()
    }
    
    // edit mode gecis
    func editMode(sender: UIButton!) {
        self.evo_drawerController?.setMaximumLeftDrawerWidth(self.MainLeftFrame.width, animated: true, completion: nil)
        self.TableState = STATE.SEARCH
        self.items = self.SearchItems
        self.tableView.reloadData()
        self.startSearchMode()
        self.OpenEditTable()
        self.settingsButton.frame.origin.x = self.tableView.bounds.size.width - self.settingsButton.bounds.size.width
    
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        //let notification: NSNotification = NSNotification(name: "StopParsingTimer", object: nil, userInfo: nil)
        //NSNotificationCenter.defaultCenter().postNotification(notification)
        //var bounds: CGRect = UIScreen.mainScreen().bounds
        //var width:CGFloat = bounds.size.width
        self.evo_drawerController?.setMaximumLeftDrawerWidth(self.MainLeftFrame.width, animated: true, completion: nil)
        self.TableState = STATE.SEARCH
        self.items = self.SearchItems
        //self.tableView.reloadData()
        self.startSearchMode()
        self.OpenEditTable()
    }
    
    func startSearchMode() {
        //self.settingsButton.hidden = true
        //self.SearchBox.frame.size.width = self.MainLeftFrame.width-self.addSourceButton.bounds.width
        //self.addSourceButton.hidden = false
        //self.addSourceButton.alpha = 1
        //self.SearchBox.frame.origin.x = 45
        
        self.items = SetDBData()
        self.tableView.reloadData()
        //self.SearchBox.placeholder = localizedString("left_menu_search_box")
        
        self.view.viewWithTag(200)?.hidden = true
    }
    
    func stopSearchMode() {
        /*
        UIView.animateWithDuration(0.5,
            delay: 0.0,
            options: .CurveEaseInOut | .AllowUserInteraction,
            animations: {
                
            },
            completion: { finished in
        })*/

        //self.SearchBox.frame.size.width = self.evo_visibleDrawerFrame.width-45
        //self.SearchBox.frame.origin.x = 0
        self.settingsButton.hidden = false
        //self.SearchBox.showsCancelButton = false
        self.addSourceButton.hidden = true
        
        self.CloseEditTable()
        //self.SearchBox.text = ""
        //self.SearchBox.placeholder = ""
        self.view.viewWithTag(200)?.hidden = false
    }
    
    // search dictionary isequal
    func eqDictionary(array: [[String:AnyObject]], key: String, value: AnyObject) -> [[String:AnyObject]] {
        var all : [[String:AnyObject]] = []
        for dict in array {
            if let val: AnyObject = dict[key] {
                if (val as! NSString) == (value as! NSString) {
                    all.append(dict)
                }
            }
        }
        return all
    }
    
    // search dictionary key for value
    func eqDictionaryGetKey(array: [[String:AnyObject]], key: String, value: AnyObject) -> Int {
        var all : [[String:AnyObject]] = []
        var number = -1
        for dict in array {
            number++
            if let val: AnyObject = dict[key] {
                if (val as! NSString) == (value as! NSString) {
                    return number
                }
            }
        }
        return number
    }
    
    // set db data
    func SetDBData() -> [[String:AnyObject]] {
        var tempItems:[[String:AnyObject]] = []
        let DatabaseData = db.query("SELECT * FROM mylist ORDER BY orderlist ASC")
        var tempDictionary:[String:AnyObject] = ["name":"","url":""]
        for row in DatabaseData {
            if let ntitle = row["name"] {
                
                if !ntitle.asString().isEmpty {
                    tempDictionary["name"] = ntitle.asString() as String
                }
            }
            
            if let nsummary = row["url"] {
                tempDictionary["url"] = nsummary.asString()
            }
            
            if let norder = row["orderlist"] {
                tempDictionary["orderlist"] = norder.asInt()
            }
            
            if let nidentifier = row["identifier"] {
                tempDictionary["identifier"] = nidentifier.asString()
            }
            
            if let nfavicon = row["favicon"] {
                tempDictionary["favicon"] = nfavicon.asString()
            }
            
            if let nid = row["id"] {
                tempDictionary["id"] = nid.asInt()
            }
            
            tempItems.append(tempDictionary)
        }
        return tempItems
    }
    
    // #TABLEVIEW METHODS
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        /*
        var CellIdentifier = "MENU"
        
        var cell: LeftMenuViewCell! = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as? LeftMenuViewCell
        
        
        if cell == nil {
            cell = LeftMenuViewCell(style: .Default, reuseIdentifier: CellIdentifier)
        }
        cell.customLabel1.text = items[indexPath.row]*/
        
        var cell:LeftMenuViewCell = self.tableView.dequeueReusableCellWithIdentifier("MENU") as! LeftMenuViewCell
        
        if self.TableState == STATE.VIEW {
            cell.accessoryType = UITableViewCellAccessoryType.None
        } else if self.TableState == STATE.EDIT {  }
        else if self.TableState == STATE.SEARCH {
            
            var res = eqDictionary(self.DatabaseItems, key: "name", value: self.items[indexPath.row]["name"]!)
            
            if (res.count > 0) {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
        }
        
        if !(self.items[indexPath.row].isEmpty) {
            cell.setData(self.items[indexPath.row])
        }
        
        
        //self.tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.None
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if self.TableState == STATE.VIEW {
            var passdata = [String:String]()
            passdata["ParseURL"] = self.items[indexPath.row]["url"] as? String
            passdata["CatIdentifier"] = self.items[indexPath.row]["identifier"] as? String
            passdata["Title"] = self.items[indexPath.row]["name"] as? String
            
            self.evo_drawerController?.toggleLeftDrawerSideAnimated(true, completion: { _ in
                let notification: NSNotification = NSNotification(name: "LeftMenuSelectedItem", object: nil, userInfo: passdata)
                NSNotificationCenter.defaultCenter().postNotification(notification)
            })
            
        } else if self.TableState == STATE.EDIT {
            //println("birsey yapma")
        } else if self.TableState == STATE.SEARCH {
            //println("search yapıyor")
            var name = self.items[indexPath.row]["name"] as! String
            var url = self.items[indexPath.row]["url"] as! String
            var identifier = self.items[indexPath.row]["identifier"] as! String
            var favicon = self.items[indexPath.row]["favicon"] as! String
            if self.tableView.cellForRowAtIndexPath(indexPath)?.accessoryType == UITableViewCellAccessoryType.None {
                //println("eklendi")
                self.tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.Checkmark
                
                let MaxData = db.query("SELECT MAX(orderlist) as maxorder FROM mylist")
                var maxnumber:Int = 1
                if !MaxData.isEmpty {
                    var MaxRow = MaxData[0]
                    
                    if let mrow = MaxRow["maxorder"] {
                        maxnumber = (mrow.asInt())+1
                    }
                }


                // database insert edecek
                let result = db.execute("INSERT INTO mylist (name,url,orderlist,identifier,favicon) VALUES (?,?,?,?,?)", parameters:[name,url,maxnumber,identifier,favicon])
                if result != 0 {
                    self.DatabaseItems.append(self.items[indexPath.row])
                }
            } else {
                self.tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.None
                // database delete edecek
                let result = db.execute("DELETE FROM mylist WHERE identifier='\(identifier)'")
                db.execute("DELETE FROM news WHERE CatIdentifier='\(identifier)'")
                if result != 0{
                    var deleteIndex = eqDictionaryGetKey(self.items, key: "name", value: name)
                    if deleteIndex != -1 {
                        self.DatabaseItems.removeAtIndex(eqDictionaryGetKey(self.DatabaseItems, key: "name", value: name))
                    }
                }

            }
            
            self.SetDBData()
        }
        //super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        //self.evo_drawerController?.setCenterViewController(nav, withFullCloseAnimation: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    // no separator left
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if(self.tableView.respondsToSelector(Selector("setSeparatorInset:"))){
            self.tableView.separatorInset = UIEdgeInsetsZero
        }
        
        if(self.tableView.respondsToSelector(Selector("setLayoutMargins:"))){
            self.tableView.layoutMargins = UIEdgeInsetsZero
        }
        
        if(cell.respondsToSelector(Selector("setLayoutMargins:"))){
            cell.layoutMargins = UIEdgeInsetsZero
        }     
    }
    
    // can you move
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true;
    }
    
    // Process the row move. This means updating the data model to correct the item indices.
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        // remove the dragged row's model
        let val = self.items.removeAtIndex(sourceIndexPath.row)
        // insert it into the new position
        self.items.insert(val, atIndex: destinationIndexPath.row)
        self.setReOrderItems()
    }
    
    // siralanan tablodaki itemslari tekrar siralar
    func setReOrderItems() {
        // yeniden sirala
        let deleteresult = db.execute("DELETE FROM mylist")
        if deleteresult != 0 {
            var order:Int = 1
            if !self.items.isEmpty {
                for row in self.items {
                    let nname:String = row["name"] as! String
                    let nurl:String = row["url"] as! String
                    let identifier:String = row["identifier"] as! String
                    let favicon:String = row["favicon"] as! String
                    let result = db.execute("INSERT OR REPLACE INTO mylist (name,url,orderlist,identifier,favicon) VALUES (?,?,?,?,?)", parameters:[nname,nurl,order,identifier,favicon])
                    order++
                }
                db.execute("DELETE FROM news WHERE CatIdentifier NOT IN (SELECT identifier FROM mylist)")
            }
        }
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        /*
        if indexPath.row == 0 {
            return UITableViewCellEditingStyle.None
        }
        */
        return UITableViewCellEditingStyle.Delete
    }
    
    // Update the data model according to edit actions delete or insert.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            // remove the deleted item from the model
            self.items.removeAtIndex(indexPath.row)
            self.DatabaseItems.removeAtIndex(indexPath.row)
            // remove the deleted item from the `UITableView`
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            self.setReOrderItems()
        default:
            return
        }
    }
    
    func setupLeftMenuButton() {
        let leftDrawerButton = DrawerBarButtonItem(target: self, action: "leftDrawerButtonPress:")
        self.navigationItem.setLeftBarButtonItem(leftDrawerButton, animated: false)
    }
    
    func leftDrawerButtonPress(sender: AnyObject?) {
        if self.TableState == STATE.EDIT {
            self.CloseEditTable()
        } else {
            self.OpenEditTable()
        }
    }
    
    func CloseEditTable() {
        self.tableView.setEditing(false, animated: true)
        self.evo_drawerController?.openDrawerGestureModeMask = .All
        self.evo_drawerController?.closeDrawerGestureModeMask = .All

        self.TableState = STATE.SEARCH
    }
    
    func OpenEditTable() {
        self.evo_drawerController?.openDrawerGestureModeMask = .None
        self.evo_drawerController?.closeDrawerGestureModeMask = .None
        self.tableView.setEditing(true, animated: true)
        self.TableState = STATE.EDIT
    }
    
    // MARK: FeedParserDelegate
    // Parse Channel
    func feedParser(parser: FeedParser, didParseChannel channel: FeedChannel) {
        // Here you could react to the FeedParser identifying a feed channel.
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            //println("Feed parser did parse channel \(channel)")
            self.ItemData = Array<FeedItem>()
            //self.SearchItems.removeAll(keepCapacity: false)
            self.SearchItems = []
            //self.items.removeAll(keepCapacity: false)
            self.items = []
            
            if self.isChannelURLParse == true && channel.channelTitle != nil && channel.channelURL != nil {
                // eger url girdiyse
                var title:String = channel.channelTitle!
                var url:String = channel.channelURL!
                
                var ObjectData = [String: String]()
                
                var ident = title
                ident = ident.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
                ObjectData["name"] = title
                ObjectData["url"] = url
                ObjectData["identifier"] = ident
                
                self.SearchItems.append(ObjectData)
                self.items.append(ObjectData)
            }
        })
    }
    
    func feedParser(parser: FeedParser, didParseItem item: FeedItem) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            //println("Feed parser did parse item \(item.feedTitle)")
            
            if self.isChannelURLParse == false {
                self.ItemData.append(item)
                
                var ObjectData = [String: String]()
                var ident = item.feedLink
                ident = ident?.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
                ObjectData["name"] = item.feedTitle
                ObjectData["url"] = item.feedLink
                ObjectData["identifier"] = ident
                
                self.items.append(ObjectData)
                self.SearchItems.append(ObjectData)
            }

        })
    }
    
    // Finish Parse
    func feedParser(parser: FeedParser, successfullyParsedURL url: String) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if (self.SearchItems.count > 0) {
                //println("All feeds parsed.")
                self.CloseEditTable()
                self.tableView.reloadData()
                self.SearchBox.resignFirstResponder()
                
                // fonksiyon haline gelecek
                var cancelButton: UIButton
                var topView: UIView = self.SearchBox.subviews[0] as! UIView
                for subView in topView.subviews {
                    if subView.isKindOfClass(NSClassFromString("UINavigationButton")) {
                        cancelButton = subView as! UIButton
                        cancelButton.enabled = true
                    }
                }
                //self.SearchBox.showsSearchResultsButton = true
            } else {
                println("No feeds found at url \(url).")
            }
        })

        if !self.ProgressHUD.hidden {
            self.ProgressHUD.dismissAfterDelay(0.2)
        }
    }
    
    func feedParser(parser: FeedParser, parsingFailedReason reason: String) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            //println("Feed parsed failed: \(reason)")
        })
    }
    
    func feedParserParsingAborted(parser: FeedParser) {
        //println("Feed parsing aborted by the user")
    }
    
    func getOnlineDatabaseParse(searchKey:String) {
        
    }
    
    func SetSearchBarBackground() {
        /*
        var cancelButton: UIButton
        var topView: UIView = self.SearchBox.subviews[0] as! UIView
        for subView in topView.subviews {
            if subView.isKindOfClass(NSClassFromString("UITextField")) {
                var textField = subView as! UITextField
                textField.backgroundColor = UIColor.grayColor()
            }
        }*/
    }
}
