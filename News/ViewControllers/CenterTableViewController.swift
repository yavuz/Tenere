//
//  CenterTableViewController.swift
//  News
//
//  Created by yavuz on 14/11/14.
//  Copyright (c) 2014 yuka. All rights reserved.
//

import Foundation
import UIKit

class CenterTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var items:Array<NewsFeedItem>
    var tableView:UITableView!
    var device: Device = Device.currentDevice
    var customTagStateView:Bool = false
    var RTLState:Bool = false
    var AppColors = NSDictionary()
    var opendirectlink = Bool()
    //var refreshControl:UIRefreshControl!  // An optional variable
    
    init(items: Array<NewsFeedItem>) {
        self.items = items
        super.init(nibName: nil, bundle: nil)
        let ConfigData = Defaults["appconfig"].dictionary
        self.AppColors = ConfigData?["color"] as! NSDictionary
        self.opendirectlink = ConfigData?["opendirectlink"] as! Bool

    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setData(item: Array<NewsFeedItem>,operation:String, RTL:Bool) {
        self.items = item
        self.RTLState = RTL
        if operation == "database" {
            self.tableView.beginUpdates()
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Right)
            self.tableView.endUpdates()
        } else if operation == "parser" {
            self.tableView.reloadData()
        }
    }
    
    func setViewTag(state:Bool) {
        self.customTagStateView = state
    }
    
    override func loadView() {
        self.tableView = UITableView()
        self.tableView.autoresizingMask = [.FlexibleWidth,.FlexibleHeight]
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.backgroundColor = UIColor.whiteColor()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        /*
        if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
            self.tableView.layoutMargins = UIEdgeInsetsZero;
        }*/
        
        self.tableView.registerClass(CenterTableViewCell.self, forCellReuseIdentifier: "First")
        self.tableView.registerClass(CenterTableViewCell.self, forCellReuseIdentifier: "Cell")
        
        /*
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refersh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        */
        
        self.view = self.tableView
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var CellIdentifier = ""
        if indexPath.row == 0 {
            CellIdentifier = "First"
        } else {
            CellIdentifier = "Cell"
        }
        
        var cell: CenterTableViewCell! = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as? CenterTableViewCell
        
        if cell == nil {
            cell = CenterTableViewCell(style: .Default, reuseIdentifier: CellIdentifier)
        }
        
        cell.setRTLStateFunc(self.RTLState)
        if(self.items.count > 0) {
            cell.setViewTag(self.customTagStateView)
            cell.setData(self.items[indexPath.row])
        }
        //cell.selectionStyle = UITableViewCellSelectionStyle.Gray
        //#CONFIG : selected colors
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(rgba: (self.AppColors["mainselectednews"] as! String))
        cell.selectedBackgroundView = bgColorView
        cell.separatorInset = UIEdgeInsetsZero
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if device.isPad() {
            let vc = ReadViewController()
            let item: NewsFeedItem = self.items[indexPath.row] as NewsFeedItem
            vc.newsid = item.title
            //self.splitViewController?.showViewController(vc, sender: nil)
            //self.splitViewController?.showDetailViewController(vc, sender: nil)

            
            if(self.opendirectlink == true) {
                self.OpenWebView(item.link)
            } else {
                let sp:UINavigationController = self.splitViewController!.viewControllers[1] as! UINavigationController
                if device.isPad() {
                    sp.popToRootViewControllerAnimated(false)
                }
                sp.pushViewController(vc, animated: true)
                //self.splitViewController?.viewControllers[1].navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            self.evo_drawerController?.closeDrawerAnimated(true, completion: nil)
            let vc = ReadViewController() //change this to your class name
            let item: NewsFeedItem = self.items[indexPath.row] as NewsFeedItem
            vc.newsid = item.title
            if(self.opendirectlink == true) {
                self.OpenWebView(item.link)
            } else {
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        }

    }
    
    // webview ac
    func OpenWebView(nid:String) {
        //NavigationController
        if device.isPad() {
            let WebPage = SVWebViewController(address: nid)
            WebPage.barsTintColor = UIColor(rgba: (self.AppColors["webviewfooter"] as! String))
            WebPage.barsBackgroundColor = UIColor(rgba: (self.AppColors["webviewfootertint"] as! String))
            
            let sp:UINavigationController = self.splitViewController!.viewControllers[1] as! UINavigationController
            if device.isPad() {
                sp.popToRootViewControllerAnimated(false)
            }
            sp.pushViewController(WebPage, animated: true)
        } else {
            let WebPage = SVWebViewController(address: nid)
            WebPage.barsTintColor = UIColor(rgba: (self.AppColors["webviewfooter"] as! String))
            WebPage.barsBackgroundColor = UIColor(rgba: (self.AppColors["webviewfootertint"] as! String))
            //WebPage.navigationController?.toolbar.backgroundColor = UIColor.blackColor()
            //WebPage.navigationController?.toolbar.barTintColor = UIColor.blackColor()
            self.navigationController?.pushViewController(WebPage, animated: true)
        }

        
        // Modal
        /*
        let WebPage = SVModalWebViewController(address: nid)
        presentViewController(WebPage, animated: true, completion: nil)
        */
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 170
        } else {
            return 100
        }
        
    }
    
    // MARK: Pull To Refresh
    func refresh(sender:AnyObject) {
        // Code to refresh table view

    }
}