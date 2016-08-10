//
//  SettingsViewController.swift
//  News
//
//  Created by yavuz on 15/12/14.
//  Copyright (c) 2014 yuka. All rights reserved.
//

import Foundation
import UIKit
import SwiftForms

class SettingsViewController: FormViewController {
    let db = SQLiteDB.sharedInstance()
    
    struct Static {
        static let autorefresh = "autorefresh"
        static let sounds = "sounds"
        static let languages = "languages"
        static let button = "button"
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.loadForm()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationItem.title = localizedString("settings")
        
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor(rgba: YukaColors.DEFAULT_TEXT_COLOR),
            NSFontAttributeName: Font.defaultBoldFont!
        ]
        
        // Create left and right button for navigation item
        let rightButton = UIBarButtonItem(title: localizedString("close"), style: UIBarButtonItemStyle.Plain, target: self, action: "BackSearch:")
        rightButton.setTitleTextAttributes(titleDict as? [String : AnyObject], forState: UIControlState.Normal)
        
        self.navigationItem.rightBarButtonItem = rightButton
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
    }
    
    private func loadForm(){
        
        let form = FormDescriptor()
        
        form.title = localizedString("settings")

        let section1 = FormSectionDescriptor()

        //section1.headerTitle = "app configuration"
        section1.footerTitle = localizedString("settings_footer")
        
        var row = FormRowDescriptor(tag: Static.autorefresh, rowType: .BooleanSwitch, title: localizedString("settings_autorefresh"))
        let appautorefresh:Int = Defaults["appautorefresh"].int!
        row.value=appautorefresh
        section1.addRow(row)
        
        row = FormRowDescriptor(tag: Static.sounds, rowType: .BooleanSwitch, title: localizedString("settings_sounds"))
        let appsounds:Int = Defaults["appsounds"].int!
        row.value=appsounds
        section1.addRow(row)
        
        row = FormRowDescriptor(tag: Static.languages, rowType: .MultipleSelector, title: localizedString("settings_languages"))
        row.configuration[FormRowDescriptor.Configuration.Options] = [0, 1]
        row.configuration[FormRowDescriptor.Configuration.AllowsMultipleSelection] = false
        row.configuration[FormRowDescriptor.Configuration.TitleFormatterClosure] = { value in
            switch( value ) {
            case 0:
                ChangeLanguage("en")
                return "English"
            case 1:
                ChangeLanguage("tr")
                return "Turkish"
            default:
                return nil
            }
            } as TitleFormatterClosure
        
        let ll = StatusLanguage()
        if ll == "tr" {
            row.value=1
        } else if ll == "en" {
            row.value = 0
        }

        section1.addRow(row)
        
        form.sections = [section1]
        
        self.form = form
    }
    
    func BackSearch(sender:UIButton) {
        // set autorefresh
        let confautorefresh: AnyObject? = self.form.formValues().valueForKey("autorefresh")
        Defaults["appautorefresh"] = confautorefresh?.integerValue
        
        // set sound state
        let confsounds: AnyObject? = self.form.formValues().valueForKey("sounds")
        Defaults["appsounds"] = confsounds?.integerValue
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func openCountryPage() {
        let SelectNewsModal = SelectNewsModalViewController()
        self.evo_drawerController?.presentViewController(SelectNewsModal, animated: true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// MARK: FormViewControllerDelegate
    
    func formViewController(controller: FormViewController, didSelectRowDescriptor rowDescriptor: FormRowDescriptor) {
        if rowDescriptor.tag == Static.button {
            self.view.endEditing(true)
        }
    }
}
