//
//  SelectNewsView.swift
//  News
//
//  Created by yavuz on 26/01/15.
//  Copyright (c) 2015 yuka. All rights reserved.
//

import Foundation
import UIKit

class SelectCountryViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    var tableView: UITableView!
    var CountryItem:[[String: String]]!
    let db = SQLiteDB.sharedInstance()
    var selectedItem:String!
    var selectedItemID:Int!
    
    init(selectItem: String) {
        self.selectedItem = selectItem
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        // scrollRectToVisible
        //self.CountryItem = ["Afganistan","İngiltere","Türkiye","Yeni Zelanda","Afganistan","İngiltere","Türkiye","Yeni Zelanda","Afganistan","İngiltere","Türkiye","Yeni Zelanda","Afganistan","İngiltere","Türkiye","Yeni Zelanda","Afganistan","İngiltere","Türkiye","Yeni Zelanda","Afganistan","İngiltere","Türkiye","Yeni Zelanda"]
        
        self.tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height-64))
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.userInteractionEnabled = true
        self.tableView.autoresizingMask = [.FlexibleWidth,.FlexibleHeight]
        self.view.addSubview(self.tableView)
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.CountryItem = []
        let DatabaseData = db.query("SELECT * FROM country ORDER BY name ASC")
        var nn = 0
        for row in DatabaseData {
            var ObjectData = [String: String]()
            
            ObjectData["name"] = row["name"]?.asString()
            ObjectData["iso"] = row["iso"]?.asString()
            if(self.selectedItem == ObjectData["name"]) {
                Defaults["SelectCountry"] = nn
            }
            self.CountryItem.append(ObjectData)
            nn++
        }
        
        self.tableView.reloadData()
        
        if(Defaults.hasKey("SelectCountry")) {
            let Pindex = Defaults["SelectCountry"].int
            //var tempPindex = NSIndexPath(index: Pindex!)
            let tempPindex = NSIndexPath(forRow: Pindex!, inSection: 0)
            self.tableView.reloadData()
            self.tableView.scrollToRowAtIndexPath(tempPindex, atScrollPosition: UITableViewScrollPosition.None, animated: true)
        }
        /*
        if(!self.tableViewController.tableView.scrollsToTop) {
            self.tableViewController.tableView.scrollToRowAtIndexPath(topIndex, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        }*/
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell")!
        cell.textLabel?.text = self.CountryItem[indexPath.row]["name"]
        cell.textLabel?.font = Font.defaultMediumFont
        //
        if self.selectedItem == self.CountryItem[indexPath.row]["name"] {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.CountryItem.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        Defaults["SelectCountry"] = indexPath.row
        Defaults["SelectCountryName"] = self.CountryItem[indexPath.row]["name"]
        Defaults["SelectCountryIso"] = self.CountryItem[indexPath.row]["iso"]

        self.tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.Checkmark
        
        let notification: NSNotification = NSNotification(name: "ChangeCountryNot", object: nil, userInfo: ["item":self.CountryItem[indexPath.row]])
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }
    
}