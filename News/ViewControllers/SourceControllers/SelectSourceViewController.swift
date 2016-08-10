//
//  SelectSourceView.swift
//  News
//
//  Created by yavuz on 26/01/15.
//  Copyright (c) 2015 yuka. All rights reserved.
//

import Foundation
import UIKit

class SelectSourceViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    var collectionView:UICollectionView!
    var items:[[String:AnyObject]]!
    var selectedItems2 = Dictionary<String, AnyObject>()
    var NextSelectLimit:Int = 1 // kac haber secerse ileri gidebilecek
    let db = SQLiteDB.sharedInstance()
    var SelectItemsRow:Array<NSIndexPath> = Array<NSIndexPath>()
    var device: Device = Device.currentDevice
    var AppColors = NSDictionary()
    
    override func viewDidLoad() {
        self.items = []
        
        
        let ConfigData = Defaults["appconfig"].dictionary
        self.AppColors = ConfigData?["color"] as! NSDictionary
        //self.selectedItems2["test"] = ["test":"test","test2":"test2"]
        let collectionViewLayout = UICollectionViewFlowLayout()
        self.collectionView = UICollectionView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height-64), collectionViewLayout: collectionViewLayout)
        collectionViewLayout.minimumInteritemSpacing = 0
        

        self.collectionView.registerClass(SourceViewCell.self, forCellWithReuseIdentifier: "cell")
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.allowsMultipleSelection = true
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = UIColor(rgba: (self.AppColors["selectednewspage"] as! String))
        self.collectionView.autoresizingMask = [.FlexibleHeight,.FlexibleWidth]
        self.view.addSubview(self.collectionView)
        
        /*
        self.collectionView = UICollectionView(frame: self.view.bounds)
        self.collectionView.delegate = self
        
        self.collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        self.collectionView.allowsMultipleSelection = true
        self.collectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        */

        self.view.backgroundColor = UIColor(rgba: (self.AppColors["selectednewspage"] as! String))
    }
    
    override func viewDidLayoutSubviews() {
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:SourceViewCell = self.collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! SourceViewCell

        let key: String = self.items[indexPath.row]["identifier"] as! String
        if (self.selectedItems2[key] != nil) {
            cell.backgroundColor = UIColor(rgba: (self.AppColors["selectednewspageclickitem"] as! String))
            self.SelectItemsRow.append(indexPath)
        } else {
            cell.backgroundColor = UIColor(rgba: (self.AppColors["selectednewspageitem"] as! String))
        }
        if(self.items.count > 0) {
            cell.setData(self.items[indexPath.row])
        }


        cell.layer.cornerRadius = 4
        cell.contentView.autoresizingMask = [UIViewAutoresizing.FlexibleHeight,UIViewAutoresizing.FlexibleWidth]
        cell.translatesAutoresizingMaskIntoConstraints = true

        return cell
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var size = CGSizeMake((self.view.bounds.width/2)-8,50)
        if device.isPhone() {
            size = CGSizeMake((self.view.bounds.width/2)-8,50)
        } else if device.isPad() {
            size = CGSizeMake((self.view.bounds.width/3)-8,50)
        }

        return size
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake( 5,5,5,5)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.collectionView.cellForItemAtIndexPath(indexPath)?.backgroundColor = UIColor(rgba: (self.AppColors["selectednewspageclickitem"] as! String))
        
        let key: String = self.items[indexPath.row]["identifier"] as! String
        self.selectedItems2[key] = self.items[indexPath.row]
        
        // istenilen sayiya ulastiginda
        if self.CountSelectedItems() >= self.NextSelectLimit {
            let notification: NSNotification = NSNotification(name: "SelectNewsLimit", object: nil, userInfo: ["stat":true])
            NSNotificationCenter.defaultCenter().postNotification(notification)
        } else {
            let notification: NSNotification = NSNotification(name: "SelectNewsLimit", object: nil, userInfo: ["stat":false])
            NSNotificationCenter.defaultCenter().postNotification(notification)
        }
        
    }
    
    func CountSelectedItems() -> Int {
        return self.selectedItems2.count
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        self.collectionView.cellForItemAtIndexPath(indexPath)?.backgroundColor = UIColor(rgba: (self.AppColors["selectednewspageitem"] as! String))
        
        let key: String = self.items[indexPath.row]["identifier"] as! String
        self.selectedItems2[key] = nil
        if self.CountSelectedItems() >= self.NextSelectLimit {
            let notification: NSNotification = NSNotification(name: "SelectNewsLimit", object: nil, userInfo: ["stat":true])
            NSNotificationCenter.defaultCenter().postNotification(notification)
        } else {
            let notification: NSNotification = NSNotification(name: "SelectNewsLimit", object: nil, userInfo: ["stat":false])
            NSNotificationCenter.defaultCenter().postNotification(notification)
        }
    }
    
    func setData(item: [[String:AnyObject]]) {
        self.items = item
        
        let DBList = db.query("SELECT * FROM mylist")
        if !DBList.isEmpty {
            for row in DBList {
                let key = row["identifier"]?.asString()
                let name = row["name"]?.asString()
                let url = row["url"]?.asString()
                let favicon = row["favicon"]?.asString()
                var temparray = [String:AnyObject]()
                temparray["name"] = name
                temparray["url"] = url
                temparray["favicon"] = favicon
                temparray["identifier"] = key
                self.selectedItems2[key!] = temparray
                //self.collectionView.cellForItemAtIndexPath(NSIndexPath(index: 0))?.selected
            }
        }
        
        self.collectionView.reloadData()
        self.collectionView!.performBatchUpdates({
            if (!self.SelectItemsRow.isEmpty && !self.selectedItems2.isEmpty){
                for srow in self.SelectItemsRow {
                    self.collectionView.selectItemAtIndexPath(srow, animated: false, scrollPosition: UICollectionViewScrollPosition.Top)
                }
            }
            
        }, completion: nil)
    }
}